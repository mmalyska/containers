# Rebuilds llama-server on top of the last known-good NVIDIA Jetson image for
# nv1 (JetPack 6 / r36.4 / CUDA 12.6 / Orin sm_87), pinned (via ci/latest.sh,
# deliberately not tracking upstream) to llama.cpp b9660. This exists because:
#   - ghcr.io/nvidia-ai-iot/llama_cpp has no cu126 build past b8708 (~April
#     2026); the newer builds moved to cu129, an untested CUDA bump for this
#     driver.
#   - The one cu129 build we tried (b9066) is broken: llama-server fails with
#     "error while loading shared libraries: libllama-common.so.0" — a
#     packaging bug in that release, unrelated to CUDA version.
#   - b8708 predates two upstream fixes we need for LFM2.5's reasoning output:
#     ggml-org/llama.cpp#24234 (think-tag leak into content, merged 2026-06-06)
#     and the b9660 LFM2 tool-call double-escaping fix (2026-06-16).
#
# The base image already carries a full CUDA 12.6 devel toolchain (nvcc,
# CMake, CUDA_ARCHITECTURES=87) baked in by NVIDIA's own jetson-containers
# pipeline — confirmed via its image config (CUDA_HOME=/usr/local/cuda,
# NVCC_PATH set, CUDA_INSTALLED_VERSION=126) — so no separate devel base is
# needed; NVIDIA doesn't publish one for l4t-cuda:12.6 anyway (only
# 12.6.11-runtime exists, no -devel tag).
#
# BUILD_SHARED_LIBS=OFF is deliberate: the cu129 image's crash was a missing
# shared lib in the final image layer. Statically linking llama.cpp's own
# internal libs (not the CUDA runtime, which stays dynamic from the base
# image) removes that whole class of packaging bug.

ARG BASE_IMAGE=ghcr.io/nvidia-ai-iot/llama_cpp:b8708-r36.4-tegra-aarch64-cu126-22.04@sha256:8fa5df9a76d3ddce89ade0ae67822afdfac27a5fe3a9e5eff7b6dfd72cd34f6b
FROM ${BASE_IMAGE}

ARG VERSION
ARG CHANNEL
# Orin's compute capability. Matches CUDA_ARCHITECTURES already set in the
# base image's env, restated here so the build doesn't depend on inheriting it.
ARG CUDA_ARCHITECTURES=87

RUN set -eux; \
    command -v git >/dev/null && command -v cmake >/dev/null

RUN set -eux; \
    rm -rf /tmp/llama-cpp-src; \
    git clone --branch="${VERSION}" --depth=1 https://github.com/ggml-org/llama.cpp /tmp/llama-cpp-src; \
    cmake \
        -B /tmp/llama-cpp-src/build \
        -S /tmp/llama-cpp-src \
        -DCMAKE_BUILD_TYPE=Release \
        -DGGML_CUDA=ON \
        -DGGML_CUDA_FA_ALL_QUANTS=ON \
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} \
        -DLLAMA_BUILD_SERVER=ON \
        -DLLAMA_BUILD_TESTS=OFF \
        -DLLAMA_BUILD_EXAMPLES=OFF \
        -DBUILD_SHARED_LIBS=OFF; \
    cmake --build /tmp/llama-cpp-src/build --config Release --parallel "$(nproc)"; \
    cmake --install /tmp/llama-cpp-src/build --prefix /usr/local; \
    rm -rf /tmp/llama-cpp-src; \
    llama-server --help >/dev/null

WORKDIR /workspace
