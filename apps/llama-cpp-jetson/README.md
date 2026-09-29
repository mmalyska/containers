# llama-cpp-jetson

`llama-server` rebuilt from a current [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp)
release on top of NVIDIA's last known-good Jetson image for JetPack 6 / L4T
r36.4 / CUDA 12.6 / Orin (`sm_87`):
`ghcr.io/nvidia-ai-iot/llama_cpp:b8708-r36.4-tegra-aarch64-cu126-22.04`.

## Why this exists

Built for `nv1` in [home-ops](https://github.com/mmalyska/home-ops) — see
`docs/superpowers/plans/2026-09-28-llm-model-swap-lfm2.5.md` there for the
full story. Short version:

- NVIDIA's `nvidia-ai-iot/llama_cpp` package has no `cu126` build newer than
  `b8708` (~April 2026). Later builds for this Jetson target moved to
  `cu129` — an untested CUDA runtime bump for this driver.
- The one `cu129` build tested (`b9066-r36.4.tegra-aarch64-cu129-22.04`)
  crashes on startup: `error while loading shared libraries:
  libllama-common.so.0` — a packaging bug in that specific release.
- `b8708` predates two upstream fixes needed for clean reasoning output on
  LFM2.5-8B-A1B: [ggml-org/llama.cpp#24234](https://github.com/ggml-org/llama.cpp/pull/24234)
  (think-tag leak into `content` when reasoning is capped, merged
  2026-06-06) and the `b9660` fix for LFM2 tool-call double-escaping
  (2026-06-16).

Rather than chase NVIDIA's cu129 tag (broken) or NGC's `l4t-cuda` devel
images (NVIDIA doesn't publish one for CUDA 12.6 — only `12.6.11-runtime`
exists), this rebuilds `llama-server` in place on the *proven-working*
`b8708` image, which already carries a full CUDA 12.6 devel toolchain
(`nvcc`, CMake, `CUDA_ARCHITECTURES=87`) baked in by NVIDIA's own
jetson-containers pipeline. Only the llama.cpp source/binary changes; the
CUDA/Tegra runtime stack that's already verified to work on this hardware
does not.

`BUILD_SHARED_LIBS=OFF` is deliberate — it statically links llama.cpp's own
internal libraries (not the CUDA runtime itself, which stays dynamic from
the base image), closing off the exact class of bug that broke the `cu129`
image.

`GGML_NATIVE=OFF` is required, not optional. It defaults ON and
auto-detects/targets whatever CPU the *build* runs on — but this builds on
a generic hosted arm64 CI runner, not nv1. Left at its default, the
resulting binary used CPU instructions Orin's Cortex-A78AE cores don't
have and crashed on nv1 with `SIGILL` (exit 132) the instant it started —
confirmed first-hand by deploying it. `GGML_NATIVE=OFF` forces a portable
baseline instead.

`GGML_CPU_KLEIDIAI=ON` claws some of that back. [KleidiAI](https://github.com/ARM-software/kleidiai)
is a separate ARM CPU microkernel library that does its own *runtime*
feature detection (dotprod, i8mm, SVE) instead of baking a fixed `-march`
into the binary at build time — safe on any build host, still gets
Orin-specific speedups for matmul-heavy CPU ops on nv1 at runtime. We
considered `GGML_CPU_ALL_VARIANTS` (compiles a full CPU backend per ARM
revision, picks the right one at load time) too — it's a more complete fix
for the same build-host-vs-target-host gap — but it hard-requires
`GGML_BACKEND_DL`, which itself hard-requires `BUILD_SHARED_LIBS=ON`,
directly reintroducing the dynamic-linking bug class this image closed off
(see above). Our workload is mostly GPU-offloaded (`-ngl 99`) anyway, so
KleidiAI's narrower, lower-risk win was the better trade. Worth
revisiting `GGML_CPU_ALL_VARIANTS` later if CPU-bound work (MoE
routing/gating, sampling) turns out to matter more than expected.

We considered compiling natively **on nv1 itself** instead of this whole
build-host-mismatch problem — `GGML_NATIVE=ON` on the real target would be
strictly more optimal than either fix above. Decided against it: nv1 is a
production device serving Hermes/Honcho, not a CI runner, and tying up its
CPU for a compile (likely longer than this CI takes — Orin NX's cores are
weaker per-core than a modern cloud arm64 CI instance) competes with
whatever it's actually running. No pipeline exists for it either; building
here keeps a reviewable PR + versioned digest instead of an ad-hoc on-device
build.

### ccache

The compile step uses a BuildKit cache mount (`--mount=type=cache`) for
ccache's object cache — a *different* caching layer from this repo's Docker
layer cache (`cache-to`/`cache-from: type=gha` in the CI workflow). Whether
that mount's contents actually persist across separate GitHub Actions
runner instances depends on the buildx/GHA-cache-export version's behavior
for mount caches specifically, which isn't confirmed here. Worst case if it
doesn't persist: ccache starts cold every build, identical to not having it
at all — not a regression, just a possibly-unrealized speedup. Check a
build's logs (`ccache -s` output, printed at the end of the compile step)
to see whether it's actually getting hits.

## Testing

Neither the Dockerfile's own build-time check nor CI's `goss` check ever
*executes* `llama-server` — both only check the binary exists and is
executable (`test -x`). This isn't just caution: it's confirmed necessary.
The base image's `/usr/lib/aarch64-linux-gnu/nvidia/libcuda.so.1` is a stub
that only becomes a real library when NVIDIA's container runtime overlays
the actual driver on real Jetson hardware — on any generic build/CI
environment (tried both QEMU-emulated `amd64` and native `ubuntu-24.04-arm`)
it stays a stub the dynamic linker can't resolve, and running
`llama-server --help` fails with `error while loading shared libraries:
...libcuda.so.1: file too short`. An earlier version of this Dockerfile ran
that check and broke the build over it. Real verification is deploying to
`nv1` and checking `ggml_cuda_init` succeeds with full layer offload, same
as any other spike pod in the home-ops plan referenced above.

## Version tracking

`ci/latest.sh` tracks the latest `ggml-org/llama.cpp` release tag (llama.cpp
cuts one per merge to master, so this is effectively "current upstream").

This was pinned to `b9660` for a while, over a worry that newer builds
carried a think-tag-leak regression
([ggml-org/llama.cpp#28675](https://github.com/ggml-org/llama.cpp/issues/28675),
first bad commit `f8e67fc`). Traced that commit: it's a WebUI "Thinking mode
toggle" change, not a server/API backend change — this image never builds
the UI (`LLAMA_BUILD_UI=OFF`), so it almost certainly doesn't apply here.
Combined with `b9660` itself still showing ~10-15% multi-turn reasoning
corruption in home-ops' own testing (a separate, still-open upstream bug,
unrelated to batching or checkpointing — see the plan referenced above for
the isolation testing behind that conclusion), pinning bought little:
home-ops has its own reasoning-correctness test suite to catch a real
regression directly, so tracking upstream and pinning the consumed image by
digest at the home-ops end (as usual — this repo's tags are not immutable
on their own) is the better default.
