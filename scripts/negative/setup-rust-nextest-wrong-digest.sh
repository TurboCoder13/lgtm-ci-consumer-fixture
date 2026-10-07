#!/usr/bin/env bash
# Negative probe for lgtm-ci #1096: run the tooling's own nextest installer with
# a deliberately wrong committed digest for the x86_64 Linux release archive.
# Expected outcome: the installer prints `::error title=digest mismatch::` and
# exits non-zero before anything lands in $CARGO_HOME/bin.
#
# The reusable restores ~/.cargo/bin from the Actions cache first; a cached
# cargo-nextest at the pinned version would take the installer's
# "already installed, skipping" shortcut and never reach the digest gate, so
# the probe removes any cached copy before handing over.
set -euo pipefail
rm -f "${CARGO_HOME:-$HOME/.cargo}/bin/cargo-nextest" "${CARGO_HOME:-$HOME/.cargo}/bin/cargo-llvm-cov"
export CARGO_NEXTEST_SHA256_X86_64_UNKNOWN_LINUX_GNU="0000000000000000000000000000000000000000000000000000000000000000"
exec bash "${GITHUB_WORKSPACE}/.lgtm-ci-tooling/scripts/ci/testing/rust/setup-rust-nextest.sh"
