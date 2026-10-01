# hello-chelis: Ubuntu 24.04 with the released Chelis toolchain and
# the extant shell releases pre-installed.
#
# Build:
#   docker compose -f docker/docker-compose.yml build
#
# Run an interactive shell at /workspace:
#   docker compose -f docker/docker-compose.yml run --rm hello-chelis
#
# Canonical-org repos are private during pre-launch. CI passes a
# GitHub token as a BuildKit secret so this image can consume release
# assets directly rather than cloning and compiling source repos.

# syntax=docker/dockerfile:1.7

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/usr/local/bin:/usr/bin:/bin

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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

# --- Helper for private GitHub release assets -----------------------------
COPY <<'EOF' /usr/local/bin/download-github-release-asset
#!/usr/bin/env bash
set -euo pipefail

repo="$1"
tag="$2"
asset="$3"
out="$4"
token="${GITHUB_TOKEN:-}"
auth_args=()
if [[ -n "$token" ]]; then
  auth_args=(-H "Authorization: Bearer ${token}")
fi

api="$(curl -fsSL "${auth_args[@]}" "https://api.github.com/repos/${repo}/releases/tags/${tag}")"
url="$(jq -r --arg name "$asset" '.assets[] | select(.name == $name) | .url' <<<"$api")"
if [[ -z "$url" || "$url" == "null" ]]; then
  echo "release asset not found: ${repo}@${tag} ${asset}" >&2
  exit 1
fi
curl -fL "${auth_args[@]}" -H "Accept: application/octet-stream" "$url" -o "$out"
EOF
RUN chmod +x /usr/local/bin/download-github-release-asset

# --- Chelis compiler from release tarball ---------------------------------
ARG CHELIS_VERSION=0.18.12
RUN --mount=type=secret,id=github_token \
    token="$(cat /run/secrets/github_token 2>/dev/null || true)" \
    && export GITHUB_TOKEN="$token" \
    && asset="chelis-v${CHELIS_VERSION}-linux-x86_64.tar.gz" \
    && download-github-release-asset Chelis-Lang/chelis "v${CHELIS_VERSION}" "$asset" "/tmp/${asset}" \
    && mkdir -p /tmp/chelis-toolchain \
    && tar -xzf "/tmp/${asset}" -C /tmp/chelis-toolchain --strip-components=1 \
    && cp /tmp/chelis-toolchain/bin/chelis /usr/local/bin/chelis \
    && cp /tmp/chelis-toolchain/lib/libchelis_runtime.a /usr/local/lib/libchelis_runtime.a \
    && mkdir -p /usr/local/include \
    && cp /tmp/chelis-toolchain/include/*.h /usr/local/include/ \
    && chelis --version

# --- Install shell releases into Reef registry ----------------------------
ARG CORAL_VERSION=0.7.43
ARG NAUTILUS_VERSION=0.7.46
ARG OCTANT_VERSION=0.13.1
ARG C_EARCHIN_VERSION=0.3.5

RUN --mount=type=secret,id=github_token \
    token="$(cat /run/secrets/github_token 2>/dev/null || true)" \
    && export GITHUB_TOKEN="$token" \
    && chelis reef install --from-github "Chelis-Lang/coral@v${CORAL_VERSION}" \
    && chelis reef install --from-github "Chelis-Lang/nautilus@v${NAUTILUS_VERSION}" \
    && chelis reef install --from-github "Chelis-Lang/octant@v${OCTANT_VERSION}" \
    && chelis reef install --from-github "Chelis-Lang/c-earchin@v${C_EARCHIN_VERSION}"

# --- Octant CLI from release tarball --------------------------------------
RUN --mount=type=secret,id=github_token \
    token="$(cat /run/secrets/github_token 2>/dev/null || true)" \
    && export GITHUB_TOKEN="$token" \
    && asset="octant-v${OCTANT_VERSION}-linux-x86_64.tar.gz" \
    && download-github-release-asset Chelis-Lang/octant "v${OCTANT_VERSION}" "$asset" "/tmp/${asset}" \
    && mkdir -p /tmp/octant-toolchain \
    && tar -xzf "/tmp/${asset}" -C /tmp/octant-toolchain --strip-components=1 \
    && cp /tmp/octant-toolchain/bin/octant /usr/local/bin/octant \
    && octant version

# --- Workspace -------------------------------------------------------------
WORKDIR /workspace
COPY . /workspace

# Sanity check: the project must check clean against the pinned Chelis, AND the
# C backend must be able to lower a non-trivial program (grad over a
# concrete tensor reduction) and run it. Build the standalone verifier outside
# the Reef root while chelis#2379 blocks the whole-package Black-Scholes Greeks.
RUN chelis check src/basics/hellotensor.ch \
    && cp verify/grad_quadratic.ch /tmp/grad_quadratic.ch \
    && chelis build /tmp/grad_quadratic.ch --output /tmp/v_grad \
    && cd /tmp/v_grad \
    && gcc -O2 -fopenmp grad_quadratic.c -L. -lchelis_runtime \
        -lopenblas -lm -lpthread -ldl -o grad_quadratic \
    && ./grad_quadratic > /tmp/grad_quadratic.out \
    && diff /tmp/grad_quadratic.out /workspace/verify/expected/grad_quadratic.txt

CMD ["/bin/bash"]
