#!/usr/bin/env bash
# Fixture package-script for reusable-build-rust-binaries: run lgtm-ci's
# default packaging script inside rust/ (cargo metadata and target/ are
# there), then move the archives and the SHA256SUMS manifest to the
# repository root where the reusable's attest and upload steps look.
# lgtm-ci #1076.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
(cd "${root}/rust" && bash "${GITHUB_WORKSPACE}/.lgtm-ci-tooling/scripts/ci/release/package-rust-binary.sh")
shopt -s nullglob
mv "${root}"/rust/*.tar.gz "${root}"/rust/*.zip "${root}/rust/SHA256SUMS-${TARGET}" "${root}/"
ls -1 "${root}"/*.tar.gz "${root}"/*.zip "${root}"/SHA256SUMS-* 2>/dev/null
