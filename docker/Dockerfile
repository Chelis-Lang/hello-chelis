# syntax=docker/dockerfile:1.7

# hello-chelis: Ubuntu 24.04 with the released Chelis toolchain and the
# shell packages the corpus depends on, all installed from GitHub release
# assets (nothing is compiled from source).
#
# Build:
#   export GITHUB_TOKEN=$(gh auth token)
#   docker compose -f docker/docker-compose.yml build
#
# Run an interactive shell at /workspace:
#   docker compose -f docker/docker-compose.yml run --rm hello-chelis
#
# The GitHub token is passed as a BuildKit secret and used only to
# authenticate the release-asset downloads; it is not stored in the image.
#
# The image is linux/amd64 only: Chelis publishes Linux binaries for x86_64.
# docker-compose.yml pins that platform; with plain `docker build`, pass
# `--platform linux/amd64`.

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
        jq \
    && rm -rf /var/lib/apt/lists/*

# --- Helper for GitHub release assets -------------------------------------
COPY <<'EOF' /usr/local/bin/download-github-release-asset
#!/usr/bin/env bash
set -euo pipefail

repo="$1"
tag="$2"
asset="$3"
out="$4"
token="${GITHUB_TOKEN:-}"
auth_args=()
sent="without a token"
if [[ -n "$token" ]]; then
  auth_args=(-H "Authorization: Bearer ${token}")
  sent="with GITHUB_TOKEN"
fi

# Read the HTTP status rather than let `curl -f` stop with a bare
# "curl: (22) ... 404", so a failed lookup says what GitHub answered.
release="$(mktemp)"
trap 'rm -f "$release"' EXIT
status="$(curl -sSL "${auth_args[@]}" -o "$release" -w '%{http_code}' \
  "https://api.github.com/repos/${repo}/releases/tags/${tag}")"
if [[ "$status" != 200 ]]; then
  echo "cannot read release ${repo}@${tag}: GitHub returned HTTP ${status} to a request sent ${sent}." >&2
  case "$status" in
    401) echo "GitHub rejected the token; refresh it with: export GITHUB_TOKEN=\$(gh auth token)" >&2 ;;
    403 | 429) echo "GitHub may be rate-limiting the request; a GITHUB_TOKEN raises the limit." >&2 ;;
    404) echo "GitHub answers 404 both for a release that does not exist and for a private repository the request cannot read." >&2 ;;
  esac
  exit 1
fi
url="$(jq -r --arg name "$asset" '.assets[] | select(.name == $name) | .url' "$release")"
if [[ -z "$url" || "$url" == "null" ]]; then
  echo "release asset not found: ${repo}@${tag} ${asset}" >&2
  exit 1
fi
curl -fL "${auth_args[@]}" -H "Accept: application/octet-stream" "$url" -o "$out"
EOF
RUN chmod +x /usr/local/bin/download-github-release-asset

# --- Chelis compiler from release tarball ---------------------------------
ARG CHELIS_VERSION=0.19.0
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
ARG CORAL_VERSION=0.7.46
ARG NAUTILUS_VERSION=0.7.49

RUN --mount=type=secret,id=github_token \
    token="$(cat /run/secrets/github_token 2>/dev/null || true)" \
    && export GITHUB_TOKEN="$token" \
    && chelis reef install --from-github "Chelis-Lang/coral@v${CORAL_VERSION}" \
    && chelis reef install --from-github "Chelis-Lang/nautilus@v${NAUTILUS_VERSION}"

# --- Python harness (uv-managed interpreter and environment) --------------
# The pytest harness under tests/ runs from a uv environment outside the
# workspace, so a bind-mounted checkout never gets a root-owned .venv.
COPY --from=ghcr.io/astral-sh/uv:0.9 /uv /uvx /usr/local/bin/
ENV UV_PYTHON_PREFERENCE=only-managed \
    UV_PROJECT_ENVIRONMENT=/opt/hello-chelis-venv

# --- Workspace -------------------------------------------------------------
WORKDIR /workspace
COPY . /workspace
RUN uv sync --frozen --group test

# Sanity check: the project must check clean against the pinned Chelis, AND the
# C backend must be able to lower a non-trivial program (grad over a
# concrete tensor reduction) and run it. The verifier is built from /tmp
# because verify/ is not a declared package source root.
RUN chelis check src/basics/hellotensor.ch \
    && cp verify/grad_quadratic.ch /tmp/grad_quadratic.ch \
    && chelis build /tmp/grad_quadratic.ch --output /tmp/v_grad \
    && cd /tmp/v_grad \
    && gcc -O2 -fopenmp grad_quadratic.c -L. -lchelis_runtime \
        -lopenblas -lm -lpthread -ldl -o grad_quadratic \
    && ./grad_quadratic > /tmp/grad_quadratic.out \
    && diff /tmp/grad_quadratic.out /workspace/verify/expected/grad_quadratic.txt

CMD ["/bin/bash"]
