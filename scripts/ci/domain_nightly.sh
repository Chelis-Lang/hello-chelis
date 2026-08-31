#!/usr/bin/env bash
set -euo pipefail

case "${GITHUB_RUN_ATTEMPT:-}" in
  1|2) exit 23 ;;
  3) exit 0 ;;
  *) exit 31 ;;
esac
