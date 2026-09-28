# llama-cpp-jetson

`llama-server` rebuilt from a pinned [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp)
release (`b9660`) on top of NVIDIA's last known-good Jetson image for
JetPack 6 / L4T r36.4 / CUDA 12.6 / Orin (`sm_87`):
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
baseline instead. Reclaiming SIMD performance for Orin specifically would
mean pinning explicit `-march`/`-mcpu` flags for its real feature set; not
attempted here.

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

`ci/latest.sh` is deliberately **pinned to `b9660`**, not tracking upstream
latest — that's the earliest release carrying both fixes this image exists
for (see above). Bump it by hand when there's reason to (and re-run the
plan's Test 1/Test 2 checks against the new build first); it will not move
on its own via Renovate or the hourly rebuild poll. Pin the consumed image
by digest at the home-ops end as usual — this repo's tags are not immutable
on their own.
