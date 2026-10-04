#!/usr/bin/env bash
# The fixture must not contain copied lgtm-ci actions or scripts; the point is
# to prove remote resolution. Fails if any lgtm-ci-internal path exists here.
set -euo pipefail
cd "$(dirname "$0")/.."
bad=0
for p in .github/actions scripts/ci .lgtm-ci-tooling; do
  if [[ -e "$p" ]]; then
    echo "::error::vendored lgtm-ci path present: $p"
    bad=1
  fi
done
exit "$bad"
