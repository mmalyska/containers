# syntax=docker/dockerfile:1.27@sha256:bde3983e9c939224420ddaf6b784cc30e09b035a4dea01f581230c50809f372e
# ^ required for the --mount=type=cache (ccache) syntax below.
# Rebuilds llama-server on top of the last known-good NVIDIA Jetson image for
# nv1 (JetPack 6 / r36.4 / CUDA 12.6 / Orin sm_87), tracking upstream
# ggml-org/llama.cpp releases via ci/latest.sh (pin the consumed digest at
# the home-ops end, as usual). This exists because:
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
#
# LLAMA_BUILD_UI=OFF / LLAMA_USE_PREBUILT_UI=OFF: llama.cpp now embeds a web
# UI into llama-server by default, provisioned via npm (not installed here)
# or a Hugging Face download at build time (which failed/returned an
# incomplete asset set in CI and hard-failed the build instead of falling
# back). nv1 serves this headlessly from k8s — no browser ever hits it — so
# skip UI provisioning entirely rather than depend on either path.
#
# The build's own smoke check only proves the binary exists and is
# executable (`test -x`) — it must NOT actually run llama-server. The base
# image's /usr/lib/aarch64-linux-gnu/nvidia/libcuda.so.1 is a stub that only
# becomes a real library when NVIDIA's container runtime overlays the actual
# Jetson driver at container start on real hardware; in any generic build
# environment (this CI runner included, regardless of arch) it's a stub the
# dynamic linker can't resolve, so `llama-server --help` fails with "error
# while loading shared libraries" there even though the binary is fine.
# Functional verification only happens by deploying to nv1 itself.
#
# GGML_NATIVE=OFF is required, not optional tuning: it defaults ON and
# auto-detects/targets whatever CPU the BUILD runs on (cmake's
# `-march=native` equivalent). This is built on a generic hosted arm64 CI
# runner, not nv1 — with GGML_NATIVE left at its default, the binary used
# CPU instructions Orin's Cortex-A78AE cores don't have and crashed with
# SIGILL (exit 132) the moment it ran, confirmed first-hand on nv1.
#
# GGML_CPU_KLEIDIAI=ON claws back some of what GGML_NATIVE=OFF gives up:
# KleidiAI is a separate ARM CPU microkernel library that does its own
# *runtime* feature detection (dotprod, i8mm, SVE) rather than baking a
# fixed -march into the binary at build time. Safe on any build host, still
# gets Orin-specific speedups for matmul-heavy CPU ops on nv1 at runtime.
# Considered GGML_CPU_ALL_VARIANTS (compiles a full CPU backend per ARM
# revision, picks the right one at load time) too, but it hard-requires
# GGML_BACKEND_DL, which itself hard-requires BUILD_SHARED_LIBS=ON --
# directly reintroducing the dynamic-linking bug class this Dockerfile
# deliberately closed off (see BUILD_SHARED_LIBS below). Our workload is
# mostly GPU-offloaded (-ngl 99) anyway, so KleidiAI's narrower, lower-risk
# win was the better trade here.

ARG BASE_IMAGE=ghcr.io/nvidia-ai-iot/llama_cpp:b8708-r36.4-tegra-aarch64-cu126-22.04@sha256:8fa5df9a76d3ddce89ade0ae67822afdfac27a5fe3a9e5eff7b6dfd72cd34f6b
FROM ${BASE_IMAGE}

ARG VERSION
ARG CHANNEL
# Orin's compute capability. Matches CUDA_ARCHITECTURES already set in the
# base image's env, restated here so the build doesn't depend on inheriting it.
ARG CUDA_ARCHITECTURES=87

RUN set -eux; \
    command -v git >/dev/null && command -v cmake >/dev/null; \
    apt-get update && apt-get install -y --no-install-recommends ccache && rm -rf /var/lib/apt/lists/*

# ccache note: the object cache lives in a BuildKit cache mount
# (--mount=type=cache), which is a *different* caching layer from this
# repo's Docker layer cache (cache-to/cache-from: type=gha in the CI
# workflow). Whether that mount's contents actually persist across separate
# GitHub Actions runner instances depends on the buildx/GHA-cache-export
# version's behavior for mount caches specifically, which isn't confirmed
# here. Worst case if it doesn't persist: ccache starts cold every build,
# identical to not having it at all -- not a regression, just a
# possibly-unrealized speedup.
RUN --mount=type=cache,target=/root/.ccache,sharing=locked \
    set -eux; \
    rm -rf /tmp/llama-cpp-src; \
    git clone --branch="${VERSION}" --depth=1 https://github.com/ggml-org/llama.cpp /tmp/llama-cpp-src; \
    cmake \
        -B /tmp/llama-cpp-src/build \
        -S /tmp/llama-cpp-src \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER_LAUNCHER=ccache \
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
        -DCMAKE_CUDA_COMPILER_LAUNCHER=ccache \
        -DGGML_NATIVE=OFF \
        -DGGML_CPU_KLEIDIAI=ON \
        -DGGML_CUDA=ON \
        -DGGML_CUDA_FA_ALL_QUANTS=ON \
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} \
        -DLLAMA_BUILD_SERVER=ON \
        -DLLAMA_BUILD_TESTS=OFF \
        -DLLAMA_BUILD_EXAMPLES=OFF \
        -DBUILD_SHARED_LIBS=OFF \
        -DLLAMA_BUILD_UI=OFF \
        -DLLAMA_USE_PREBUILT_UI=OFF; \
    cmake --build /tmp/llama-cpp-src/build --config Release --parallel "$(nproc)"; \
    cmake --install /tmp/llama-cpp-src/build --prefix /usr/local; \
    rm -rf /tmp/llama-cpp-src; \
    ccache -s

# Kept as its own layer, separate from the (expensive) build above: any
# future tweak to this check alone shouldn't invalidate the compile's cache
# entry. Deliberately non-executing — see the comment block above for why.
RUN test -x /usr/local/bin/llama-server

WORKDIR /workspace
