# hello-chelis: Ubuntu 24.04 with the Chelis v0.7.0 toolchain and all
# extant shells (chelis-std, coral, nautilus, octant) pre-installed.
#
# Build:
#   docker compose -f docker/docker-compose.yml build
#
# Run an interactive shell at /workspace:
#   docker compose -f docker/docker-compose.yml run --rm hello-chelis
#
# In CI on real GitHub Actions, switch to the `--from-github` install
# path with a GITHUB_TOKEN and the prebuilt v0.7.0 release tarball
# (https://github.com/Chelis-Lang/chelis/releases/tag/v0.7.0). The
# canonical-org shells are private during pre-launch, which is why this
# Dockerfile builds chelis from source via a checkout of the public
# Chelis-Lang/chelis repo at the v0.7.0 tag.

# syntax=docker/dockerfile:1.7

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/usr/local/bin:/usr/bin:/bin:/root/.cargo/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gcc \
        g++ \
        make \
        libopenblas-dev \
        libgomp1 \
        valgrind \
        git \
        python3 \
        python3-pip \
        python3-venv \
        jq \
    && rm -rf /var/lib/apt/lists/*

# --- Rust toolchain (needed because we build chelis from source) ----------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
        -y --default-toolchain stable --profile minimal \
        --component rustfmt --component clippy

# --- Chelis compiler v0.7.0 from source ------------------------------------
ARG CHELIS_TAG=v0.7.0
RUN --mount=type=secret,id=github_token \
    token="$(cat /run/secrets/github_token 2>/dev/null || true)" \
    && if [ -n "$token" ]; then \
        git clone --depth 1 --branch ${CHELIS_TAG} \
          "https://x-access-token:${token}@github.com/Chelis-Lang/chelis.git" /tmp/chelis-src; \
      else \
        git clone --depth 1 --branch ${CHELIS_TAG} \
          https://github.com/Chelis-Lang/chelis.git /tmp/chelis-src; \
      fi \
    && cd /tmp/chelis-src \
    && cargo build --release --bin chelis \
    && cp target/release/chelis /usr/local/bin/chelis \
    && cp target/release/deps/libchelis_runtime-*.a /usr/local/lib/libchelis_runtime.a \
    && chelis --version

# --- chelis-std into the local registry from the monorepo ------------------
RUN chelis reef install --from-monorepo /tmp/chelis-src

# --- Build + publish coral, nautilus, octant -------------------------------
# Each shell is its own repo at a pinned tag. We clone, `chelis reef build`
# (which auto-fetches transitive deps from the local registry), then
# `chelis reef publish` to make it available to dependents.
ARG CORAL_TAG=v0.7.0
ARG NAUTILUS_TAG=v0.7.0
ARG OCTANT_TAG=v0.4.3

RUN --mount=type=secret,id=github_token \
    token="$(cat /run/secrets/github_token 2>/dev/null || true)" \
    && if [ -n "$token" ]; then \
        git clone --depth 1 --branch ${NAUTILUS_TAG} \
          "https://x-access-token:${token}@github.com/Chelis-Lang/nautilus.git" /tmp/nautilus; \
      else \
        git clone --depth 1 --branch ${NAUTILUS_TAG} \
          https://github.com/Chelis-Lang/nautilus.git /tmp/nautilus; \
      fi \
    && cd /tmp/nautilus \
    && chelis reef build \
    && chelis reef publish

RUN --mount=type=secret,id=github_token \
    token="$(cat /run/secrets/github_token 2>/dev/null || true)" \
    && if [ -n "$token" ]; then \
        git clone --depth 1 --branch ${CORAL_TAG} \
          "https://x-access-token:${token}@github.com/Chelis-Lang/coral.git" /tmp/coral; \
      else \
        git clone --depth 1 --branch ${CORAL_TAG} \
          https://github.com/Chelis-Lang/coral.git /tmp/coral; \
      fi \
    && cd /tmp/coral \
    && chelis reef build \
    && chelis reef publish

RUN --mount=type=secret,id=github_token \
    ln -sf /tmp/chelis-src /tmp/chelis \
    && token="$(cat /run/secrets/github_token 2>/dev/null || true)" \
    && if [ -n "$token" ]; then \
        git clone --depth 1 --branch ${OCTANT_TAG} \
          "https://x-access-token:${token}@github.com/Chelis-Lang/octant.git" /tmp/octant; \
      else \
        git clone --depth 1 --branch ${OCTANT_TAG} \
          https://github.com/Chelis-Lang/octant.git /tmp/octant; \
      fi \
    && cd /tmp/octant \
    && cargo build --release --bin octant \
    && cp target/release/octant /usr/local/bin/octant \
    && chelis reef build \
    && chelis reef publish

# --- Workspace -------------------------------------------------------------
WORKDIR /workspace
COPY . /workspace

# Sanity check: the project must check clean against v0.7.0, AND the
# C backend must be able to lower a non-trivial program (grad over a
# tensor reduction) and run it.
RUN chelis check src/basics/hellotensor.ch \
    && cp verify/grad_works.ch /tmp/grad_works.ch \
    && chelis build /tmp/grad_works.ch --output /tmp/v_grad \
    && cd /tmp/v_grad \
    && gcc -O2 -fopenmp grad_works.c -L. -lchelis_runtime \
        -lopenblas -lm -lpthread -ldl -o grad_works \
    && diff <(./grad_works) /workspace/verify/expected/grad_works.txt

CMD ["/bin/bash"]
