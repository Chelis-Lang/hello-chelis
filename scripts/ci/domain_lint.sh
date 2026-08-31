#!/usr/bin/env bash
set -euo pipefail

case "${GITHUB_RUN_ATTEMPT:-}" in
  1) exit 0 ;;
  *) exit 23 ;;
esac
