# hello-chelis: Ubuntu 24.04 with the Chelis v0.6.1 toolchain and all
# extant shells (chelis-std, coral, nautilus, octant) pre-installed.
#
# Build:
#   docker compose -f docker/docker-compose.yml build
#
# Run an interactive shell at /workspace:
#   docker compose -f docker/docker-compose.yml run --rm hello-chelis
#
# In CI on real GitHub Actions, switch to the `--from-github` install
# path with a GITHUB_TOKEN and the prebuilt v0.6.1 release tarball
# (https://github.com/Chelis-Lang/chelis/releases/tag/v0.6.1). The
# canonical-org shells are private during pre-launch, which is why this
# Dockerfile builds chelis from source via a checkout of the public
# Chelis-Lang/chelis repo at the v0.6.1 tag.

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
        -y --default-toolchain stable --profile minimal --component rustfmt clippy

# --- Chelis compiler v0.6.1 from source ------------------------------------
ARG CHELIS_TAG=v0.6.1
RUN git clone --depth 1 --branch ${CHELIS_TAG} \
        https://github.com/Chelis-Lang/chelis.git /tmp/chelis-src \
    && cd /tmp/chelis-src \
    && cargo build --release --bin chelis \
    && cp target/release/chelis /usr/local/bin/chelis \
    && chelis --version

# --- chelis-std into the local registry from the monorepo ------------------
RUN chelis reef install --from-monorepo /tmp/chelis-src

# --- Build + publish coral, nautilus, octant -------------------------------
# Each shell is its own repo at a pinned tag. We clone, `chelis reef build`
# (which auto-fetches transitive deps from the local registry), then
# `chelis reef publish` to make it available to dependents.
ARG CORAL_TAG=v0.6.1
ARG NAUTILUS_TAG=v0.6.1
ARG OCTANT_TAG=v0.4.2

RUN git clone --depth 1 --branch ${NAUTILUS_TAG} \
        https://github.com/Chelis-Lang/nautilus.git /tmp/nautilus \
    && cd /tmp/nautilus \
    && chelis reef build \
    && chelis reef publish

RUN git clone --depth 1 --branch ${CORAL_TAG} \
        https://github.com/Chelis-Lang/coral.git /tmp/coral \
    && cd /tmp/coral \
    && chelis reef build \
    && chelis reef publish

RUN ln -sf /tmp/chelis-src /tmp/chelis \
    && git clone --depth 1 --branch ${OCTANT_TAG} \
        https://github.com/Chelis-Lang/octant.git /tmp/octant \
    && cd /tmp/octant \
    && cargo build --release --bin octant \
    && cp target/release/octant /usr/local/bin/octant \
    && chelis reef build \
    && chelis reef publish

# --- Workspace -------------------------------------------------------------
WORKDIR /workspace
COPY . /workspace

# Sanity check: the project must check clean against v0.6.1.
RUN chelis check src/basics/hellotensor.ch

CMD ["/bin/bash"]
