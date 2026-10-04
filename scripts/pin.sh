#!/usr/bin/env bash
# Re-pin every lgtm-ci reusable-workflow reference to one exact SHA.
# Usage: scripts/pin.sh <40-hex-sha>
set -euo pipefail
sha="${1:?usage: scripts/pin.sh <sha>}"
[[ "$sha" =~ ^[0-9a-f]{40}$ ]] || { echo "not a full SHA: $sha" >&2; exit 2; }
cd "$(dirname "$0")/.."
for f in .github/workflows/*.yml; do
  sed -i.bak -E "s#(lgtm-hq/lgtm-ci/\.github/workflows/[A-Za-z0-9._-]+\.yml@)[0-9a-f]{40}#\1${sha}#g" "$f"
  rm -f "$f.bak"
done
echo "pinned to $sha:"
grep -rhoE "lgtm-hq/lgtm-ci/\.github/workflows/[A-Za-z0-9._-]+\.yml@[0-9a-f]{40}" .github/workflows | sort -u
