#!/usr/bin/env bash
# Fixture build-script for reusable-test-rust-build: the crate lives in rust/,
# the reusable builds from the repository root, so step into the crate and
# exec lgtm-ci's default workspace build script unchanged. lgtm-ci #1076.
set -euo pipefail
cd "$(dirname "$0")/../../rust"
exec bash "${GITHUB_WORKSPACE}/.lgtm-ci-tooling/scripts/ci/testing/rust/build-workspace.sh"
