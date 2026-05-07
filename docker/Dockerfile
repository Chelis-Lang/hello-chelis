# hello-chelis: Ubuntu 24.04 with the chelis v0.6.1 toolchain and all
# extant shells (chelis-std, coral, nautilus, octant) pre-installed.
#
# Build:
#   docker compose -f docker/docker-compose.yml build
#
# Run an interactive shell at /workspace:
#   docker compose -f docker/docker-compose.yml run --rm hello-chelis
#
# This image is x86_64-only (the v0.6.1 release ships a darwin-arm64 tarball
# too, but we standardize on the linux-x86_64 binary inside the container).

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/opt/chelis/bin:/usr/local/bin:/usr/bin:/bin

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
        xxd \
    && rm -rf /var/lib/apt/lists/*

# --- Chelis compiler v0.6.1 ----------------------------------------------------
# Tarball + sha256 pulled from the GitHub Release. SHA256 is locked in at image
# build time; if it doesn't match, the build fails and we don't run unverified
# binaries.
ARG CHELIS_VERSION=0.6.1
ARG CHELIS_TARBALL=chelis-v0.6.1-linux-x86_64.tar.gz
ARG CHELIS_SHA256=ce9debf59b5dc7724222a2a037f7fabeeb79cfd6f0d6afc784c80d25165573ea

RUN curl -fsSL -o /tmp/${CHELIS_TARBALL} \
        https://github.com/Chelis-Lang/chelis/releases/download/v${CHELIS_VERSION}/${CHELIS_TARBALL} \
    && echo "${CHELIS_SHA256}  /tmp/${CHELIS_TARBALL}" | sha256sum -c - \
    && mkdir -p /opt/chelis \
    && tar -xzf /tmp/${CHELIS_TARBALL} -C /opt/chelis --strip-components=1 \
    && rm /tmp/${CHELIS_TARBALL} \
    && /opt/chelis/bin/chelis --version

# --- Shells -------------------------------------------------------------------
# The reef GitHub-Releases install path (`chelis reef install --from-github`)
# is the canonical mechanism; we fall back to a local clone + `reef pack` when
# it isn't available. install_shells.py handles both.
COPY scripts/install_shells.py /tmp/install_shells.py
RUN python3 /tmp/install_shells.py --system && rm /tmp/install_shells.py

# --- Workspace ---------------------------------------------------------------
WORKDIR /workspace
COPY . /workspace

# Sanity check: the std bundle must be importable.
RUN echo 'module Smoke' > /tmp/smoke.ch \
    && echo 'def main() -> tensor[n, f32] = add(to_tensor([1.0, 2.0]), to_tensor([3.0, 4.0]))' >> /tmp/smoke.ch \
    && chelis check /tmp/smoke.ch \
    && rm /tmp/smoke.ch

CMD ["/bin/bash"]
