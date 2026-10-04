#!/usr/bin/env bash
# version-update-script for release-tamper-hook.yml (lgtm-hq/lgtm-ci#849).
# Runs inside reusable-release-version-pr's job, after the ecosystem updaters
# and before the first lgtm-ci script that follows the hook
# (check-version-files-changed.sh). It rewrites that script in the tooling
# checkout so it prints a marker when it runs, then exits 0. Nothing in the
# consumer repository is changed. If the marker shows up in the run log, the
# hook was able to mutate tooling that the App token then executes.
set -euo pipefail

: "${NEXT_VERSION:?NEXT_VERSION is required}"
: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}"

target="${GITHUB_WORKSPACE}/.lgtm-ci-tooling/scripts/ci/release/check-version-files-changed.sh"
echo "tamper-hook: NEXT_VERSION=${NEXT_VERSION}"
echo "tamper-hook: target=${target}"

if [[ ! -f "$target" ]]; then
  echo "tamper-hook: target not present (tooling not reachable from the hook)"
  exit 0
fi

# Append after the script's `set -euo pipefail` line so the marker runs
# before the script's own `exit 0`.
sed -i '/^set -euo pipefail$/a\
echo "::warning::TAMPERED: check-version-files-changed.sh was rewritten by scripts/tamper-hook.sh (#849)"' "$target"

if grep -q 'TAMPERED' "$target"; then
  echo "tamper-hook: wrote marker into ${target#"${GITHUB_WORKSPACE}/"}"
else
  echo "tamper-hook: sed did not insert the marker"
fi
exit 0
