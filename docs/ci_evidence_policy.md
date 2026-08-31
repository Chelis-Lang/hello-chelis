# CI evidence policy

## 1 Fixed domain entrypoints

`scripts/ci/domain_lint.sh` and `scripts/ci/domain_nightly.sh` are consumer-owned CI infrastructure.
The lint traversal policy excludes only these exact files from generic Chelis lint.
The reusable workflows execute the files after authenticated toolchain setup.
No application file or directory receives this exclusion.
