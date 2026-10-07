#!/usr/bin/env bash
# Fixture build-script for reusable-build-rust-binaries: the crate lives in
# rust/, the reusable builds from the repository root, so step into the crate
# and exec lgtm-ci's default build script unchanged (TARGET, PACKAGES, BUILDER
# and USE_CROSS arrive in the environment). lgtm-ci #1076.
set -euo pipefail
cd "$(dirname "$0")/../../rust"
exec bash "${GITHUB_WORKSPACE}/.lgtm-ci-tooling/scripts/ci/release/build-rust-binary.sh"
