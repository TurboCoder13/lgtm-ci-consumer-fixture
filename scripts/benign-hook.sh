#!/usr/bin/env bash
# version-update-script for release-benign-hook.yml (lgtm-hq/lgtm-ci#849).
# The well-behaved counterpart of tamper-hook.sh: edits one tracked file in
# this repository using NEXT_VERSION and the read-only release-metadata.json
# that lgtm-ci hands the hook, and asserts the sandbox it runs in — no token
# in the environment, tooling checkout not writable. After #849 the edit must
# land in the version PR through the diff artifact; the hook itself never
# runs next to the App token.
set -euo pipefail

: "${NEXT_VERSION:?NEXT_VERSION is required}"
: "${RELEASE_METADATA_PATH:?RELEASE_METADATA_PATH is required}"

if [[ -n "${GH_TOKEN:-}" || -n "${GITHUB_TOKEN:-}" ]]; then
  echo "::error::benign-hook: a token is present in the hook environment"
  exit 1
fi

latest_tag="$(jq -r '.latest_release.tag // "none"' "$RELEASE_METADATA_PATH")"
container="$(jq -r '.container.digest // "none"' "$RELEASE_METADATA_PATH")"
echo "benign-hook: NEXT_VERSION=${NEXT_VERSION} latest_release=${latest_tag} container=${container}"

tooling="${GITHUB_WORKSPACE:-.}/.lgtm-ci-tooling"
if [[ -d "$tooling" ]] && touch "$tooling/.benign-hook-probe" 2>/dev/null; then
  rm -f "$tooling/.benign-hook-probe"
  echo "::error::benign-hook: tooling checkout is writable from the hook"
  exit 1
fi

cat >HOOK_RELEASE_INFO.txt <<EOF
next_version=${NEXT_VERSION}
latest_release=${latest_tag}
container_digest=${container}
EOF
echo "benign-hook: wrote HOOK_RELEASE_INFO.txt"
