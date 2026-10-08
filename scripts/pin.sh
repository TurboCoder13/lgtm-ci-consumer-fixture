#!/usr/bin/env bash
# Re-pin every lgtm-ci reference (reusable workflows and direct composite
# actions) to one exact SHA.
# Usage: scripts/pin.sh <40-hex-sha>
set -euo pipefail
sha="${1:?usage: scripts/pin.sh <sha>}"
[[ "$sha" =~ ^[0-9a-f]{40}$ ]] || { echo "not a full SHA: $sha" >&2; exit 2; }
cd "$(dirname "$0")/.."
ref_re='lgtm-hq/lgtm-ci/\.github/(workflows/[A-Za-z0-9._-]+\.yml|actions/[A-Za-z0-9._-]+)@'
for f in .github/workflows/*.yml; do
  sed -i.bak -E "s#(${ref_re})[0-9a-f]{40}#\1${sha}#g" "$f"
  # Direct tooling checkouts (actions/checkout of lgtm-hq/lgtm-ci) carry the
  # pin on a `ref:` line tagged with this comment.
  sed -i.bak -E "s|(ref: )[0-9a-f]{40}( # lgtm-ci-pin)|\1${sha}\2|g" "$f"
  rm -f "$f.bak"
done
echo "pinned to $sha:"
grep -rhoE "${ref_re}[0-9a-f]{40}" .github/workflows | sort -u
