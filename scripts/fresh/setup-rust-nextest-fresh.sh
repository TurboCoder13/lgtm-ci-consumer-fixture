#!/usr/bin/env bash
# Positive probe for lgtm-ci #1096: run the tooling's own nextest installer on a
# runner whose cargo cache may already hold cargo-nextest at the pinned
# version. The cached copy is removed first so the download + committed-digest
# verification path runs for real (otherwise the installer's "already
# installed, skipping" shortcut hides it). Expected outcome: success, with
# `sha256 verified against committed CARGO_NEXTEST_SHA256_...` in the log.
set -euo pipefail
rm -f "${CARGO_HOME:-$HOME/.cargo}/bin/cargo-nextest" "${CARGO_HOME:-$HOME/.cargo}/bin/cargo-llvm-cov"
exec bash "${GITHUB_WORKSPACE}/.lgtm-ci-tooling/scripts/ci/testing/rust/setup-rust-nextest.sh"
