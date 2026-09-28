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

## Testing

CI's `goss` check is build-time only (binary exists, `--help` exits clean) —
this image needs real Jetson/Tegra GPU hardware to do anything meaningful,
which CI doesn't have. Real verification is deploying to `nv1` and checking
`ggml_cuda_init` succeeds with full layer offload, same as any other spike
pod in the home-ops plan referenced above.

## Version tracking

`ci/latest.sh` tracks the latest `ggml-org/llama.cpp` release tag (llama.cpp
cuts one per merge to master, so this is effectively "current upstream").
Pin the consumed image by digest as usual — this repo's tags are not
immutable on their own.
