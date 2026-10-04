#!/usr/bin/env bash
# Retry-convergence check for lgtm-ci sibling calls (lgtm-ci #803, #717).
# Re-runs job `b` of a completed siblings.yml run and asserts that the run's
# artifact set is unchanged afterwards: same count, same names, no duplicates.
# upload-artifact in the reusable uses overwrite:true, so a re-run must land
# on the existing names instead of colliding or adding a second copy.
# Usage: scripts/rerun-sibling.sh [run-id]   (default: latest siblings run)
set -euo pipefail

repo="${GH_REPO:-TurboCoder13/lgtm-ci-consumer-fixture}"
run_id="${1:-}"
if [[ -z "$run_id" ]]; then
  run_id="$(gh run list -R "$repo" --workflow siblings.yml --status completed \
    -L 1 --json databaseId --jq '.[0].databaseId')"
  [[ -n "$run_id" ]] || { echo "no completed siblings run found" >&2; exit 2; }
fi
echo "run: https://github.com/$repo/actions/runs/$run_id"

artifacts() {
  gh api -X GET "repos/$repo/actions/runs/$run_id/artifacts" --paginate \
    --jq '.artifacts[] | select(.expired == false) | .name' | sort
}

before="$(artifacts)"
echo "artifacts before ($(wc -l <<<"$before" | tr -d ' ')):"
while IFS= read -r n; do echo "  $n"; done <<<"$before"

job_id="$(gh api -X GET "repos/$repo/actions/runs/$run_id/jobs" --paginate \
  --jq '.jobs[] | select(.name | startswith("b / ")) | select(.conclusion != "skipped") | .id' \
  | head -n1)"
[[ -n "$job_id" ]] || { echo "no runnable job under 'b /' in run $run_id" >&2; exit 2; }
echo "re-running job $job_id (b)"
gh run rerun "$run_id" -R "$repo" --job "$job_id"

for _ in $(seq 1 120); do
  sleep 10
  status="$(gh run view "$run_id" -R "$repo" --json status --jq .status)"
  [[ "$status" == "completed" ]] && break
done
conclusion="$(gh run view "$run_id" -R "$repo" --json status,conclusion --jq '"\(.status)/\(.conclusion)"')"
echo "after re-run: $conclusion"
[[ "$conclusion" == "completed/success" ]] || { echo "::error::re-run did not converge to success" >&2; exit 1; }

after="$(artifacts)"
echo "artifacts after ($(wc -l <<<"$after" | tr -d ' ')):"
while IFS= read -r n; do echo "  $n"; done <<<"$after"

dupes="$(uniq -d <<<"$after")"
if [[ -n "$dupes" ]]; then
  echo "::error::duplicate artifact names after re-run: $dupes" >&2
  exit 1
fi
if [[ "$before" != "$after" ]]; then
  echo "::error::artifact set changed across re-run" >&2
  diff <(echo "$before") <(echo "$after") || true
  exit 1
fi
echo "OK: artifact set unchanged across re-run of job b"
