#!/usr/bin/env bash
# Negative probe for lgtm-ci #1096: run the tooling's own osv-scanner installer
# with a deliberately wrong committed digest for the linux_amd64 binary.
# Expected outcome: the installer prints `::error title=digest mismatch::` and
# exits non-zero; nothing is placed on PATH.
set -euo pipefail
export OSV_SCANNER_SHA256_LINUX_AMD64="0000000000000000000000000000000000000000000000000000000000000000"
exec bash "${GITHUB_WORKSPACE}/.lgtm-ci-tooling/scripts/ci/security/install-osv-scanner.sh" "$@"
