#!/usr/bin/env bash
# Probe one negative-by-design fixture workflow from outside (lgtm-ci #1083).
#
# A run that fails by design is red on the Actions page, and a job that calls a
# reusable workflow cannot take `continue-on-error`, so the verdict cannot live
# inside the negative workflow itself. This script dispatches the negative on
# the probe's own ref, waits for it, and asserts it failed the way it is
# designed to: the run conclusion AND the job-level evidence (which job failed,
# which one passed, which annotation it raised). The probe is green exactly
# when the negative failed as designed, and red when it unexpectedly passed or
# failed for another reason.
#
# On a pass the negative run is deleted (its evidence is copied into the
# probe's job summary and the JSON written to PROBE_EVIDENCE first), so the
# Actions page shows the green probe instead of an expected red run. On any
# other outcome the negative run is kept for inspection.
#
# Usage: scripts/negative/probe.sh <negative-workflow.yml>
#
# Environment:
#   GH_TOKEN               github.token with actions: write, checks: read
#   GH_REPO                owner/repo of this fixture
#   PROBE_REF              ref to dispatch the negative on (github.ref_name)
#   PROBE_TIMEOUT_SECONDS  wait bound for the negative run, default 1080 (fits the canary's 25 min window)
#   PROBE_POLL_SECONDS     poll interval, default 15
#   KEEP_NEGATIVE_RUN      "true" keeps the negative run after a pass
#   PROBE_EVIDENCE         evidence JSON path, default negative-evidence.json
#   GITHUB_STEP_SUMMARY    job summary file (optional)
set -euo pipefail

negative="${1:?usage: scripts/negative/probe.sh <negative-workflow.yml>}"
negative="${negative##*/}"
: "${GH_REPO:?GH_REPO is required}"
: "${PROBE_REF:?PROBE_REF is required}"
PROBE_TIMEOUT_SECONDS="${PROBE_TIMEOUT_SECONDS:-1080}"
PROBE_POLL_SECONDS="${PROBE_POLL_SECONDS:-15}"
KEEP_NEGATIVE_RUN="${KEEP_NEGATIVE_RUN:-false}"
PROBE_EVIDENCE="${PROBE_EVIDENCE:-negative-evidence.json}"

# Expectations, one line per check:
#   conclusion <run conclusion>
#   jobs <exact job count>
#   job <job-name prefix> <job conclusion> [annotation title the job must raise]
# Fields are tab-separated.
expectations() {
	case "$1" in
	perms-negative.yml)
		# GitHub rejects the under-permissioned call at parse time: no job is
		# ever created. A run with jobs means the documented minimum is wrong.
		printf 'conclusion\tstartup_failure\n'
		printf 'jobs\t0\n'
		;;
	playwright-negative.yml)
		# The e2e job is red by design; the verdict job proves the failure-path
		# artifact still carries the HTML report (#804).
		printf 'conclusion\tfailure\n'
		printf 'job\te2e-failing / Playwright E2E\tfailure\n'
		printf 'job\tVerify failure-path HTML report artifact\tsuccess\n'
		;;
	verify-negative.yml)
		# Each wrong committed digest must be refused by the digest gate (#1096),
		# not fail for an unrelated reason.
		printf 'conclusion\tfailure\n'
		printf 'job\trust-wrong-digest / NEGATIVE nextest wrong digest\tfailure\tdigest mismatch\n'
		printf 'job\tosv-wrong-digest / NEGATIVE osv-scanner wrong digest\tfailure\tdigest mismatch\n'
		;;
	*)
		echo "::error::no expectations for '$1'" >&2
		return 1
		;;
	esac
}

summary() {
	[[ -z "${GITHUB_STEP_SUMMARY:-}" ]] || printf '%s\n' "$@" >>"$GITHUB_STEP_SUMMARY"
}

# Fail before dispatching when the negative has no expectations.
expected="$(expectations "$negative")"

run_id="$(gh api -X POST "repos/${GH_REPO}/actions/workflows/${negative}/dispatches" \
	-f ref="$PROBE_REF" -F return_run_details=true --jq .workflow_run_id)"
[[ "$run_id" =~ ^[0-9]+$ ]] || { echo "::error::dispatch of ${negative} returned no run id: '${run_id}'" >&2; exit 1; }
echo "dispatched ${negative} on ${PROBE_REF}: run ${run_id}"

deadline=$((SECONDS + PROBE_TIMEOUT_SECONDS))
while :; do
	run_json="$(gh api -X GET "repos/${GH_REPO}/actions/runs/${run_id}" 2>/dev/null)" || run_json=""
	[[ -n "$run_json" && "$(jq -r .status <<<"$run_json")" == "completed" ]] && break
	if ((SECONDS >= deadline)); then
		echo "::error::${negative} run ${run_id} did not complete within ${PROBE_TIMEOUT_SECONDS}s; kept for inspection" >&2
		exit 1
	fi
	sleep "$PROBE_POLL_SECONDS"
done

# Jobs with their annotations: [{name, conclusion, annotations: [{level, title, message}]}]
# The listing is captured (not read from a process substitution) so a failed
# lookup aborts the probe instead of reading as "no jobs", which would
# satisfy the perms-negative expectation and delete the run.
job_rows="$(gh api -X GET "repos/${GH_REPO}/actions/runs/${run_id}/jobs?per_page=100" \
	--jq '.jobs[] | [.id, .name, (.conclusion // "")] | @tsv')" || {
	echo "::error::cannot list the jobs of ${negative} run ${run_id}; kept for inspection" >&2
	exit 1
}
jobs_json="[]"
while IFS=$'\t' read -r job_id job_name job_conclusion; do
	[[ -n "$job_id" ]] || continue
	annotations="$(gh api -X GET "repos/${GH_REPO}/check-runs/${job_id}/annotations?per_page=100" \
		--jq '[.[] | {level: .annotation_level, title: (.title // ""), message}]')"
	jobs_json="$(jq --arg n "$job_name" --arg c "$job_conclusion" --argjson a "$annotations" \
		'. + [{name: $n, conclusion: $c, annotations: $a}]' <<<"$jobs_json")"
done <<<"$job_rows"

# Evaluate every expectation; collect a result row per check.
failures=0
rows=()
while IFS=$'\t' read -r kind a b c; do
	case "$kind" in
	conclusion)
		got="$(jq -r '.conclusion // ""' <<<"$run_json")"
		want="$a"
		label="run conclusion"
		;;
	jobs)
		got="$(jq length <<<"$jobs_json")"
		want="$a"
		label="job count"
		;;
	job)
		label="job \`${a}*\`"
		want="$b"
		got="$(jq -r --arg p "$a" '[.[] | select(.name | startswith($p)) | .conclusion] | if length == 0 then "absent" else join(",") end' <<<"$jobs_json")"
		if [[ -n "$c" && "$got" == "$want" ]]; then
			label+=" raises \`${c}\`"
			want="${b}+${c}"
			if jq -e --arg p "$a" --arg t "$c" '[.[] | select(.name | startswith($p)) | .annotations[] | select(.title == $t)] | length > 0' <<<"$jobs_json" >/dev/null; then
				got="$want"
			else
				got="${b}, no \`${c}\` annotation"
			fi
		fi
		;;
	*)
		continue
		;;
	esac
	if [[ "$got" == "$want" ]]; then
		rows+=("| ${label} | \`${want}\` | \`${got}\` | ✅ |")
	else
		rows+=("| ${label} | \`${want}\` | \`${got}\` | ❌ |")
		failures=$((failures + 1))
		echo "::error title=negative probe::${negative}: ${label} expected '${want}', got '${got}'"
	fi
done <<<"$expected"

run_url="$(jq -r .html_url <<<"$run_json")"
verdict="pass"
((failures == 0)) || verdict="fail"
jq -n --arg w "$negative" --arg v "$verdict" --argjson run "$run_json" --argjson jobs "$jobs_json" \
	'{negative: $w, verdict: $v, run_id: $run.id, run_url: $run.html_url, head_sha: $run.head_sha,
	  head_branch: $run.head_branch, conclusion: $run.conclusion, jobs: $jobs}' >"$PROBE_EVIDENCE"

summary "## Negative probe: \`${negative}\`" "" \
	"Negative run [${run_id}](${run_url}) on \`$(jq -r .head_branch <<<"$run_json")\` at \`$(jq -r .head_sha <<<"$run_json")\`." "" \
	"| Check | Expected | Observed | |" "|---|---|---|---|" "${rows[@]}" "" \
	"<details><summary>Negative run jobs and annotations</summary>" "" '```json' "$(jq . <<<"$jobs_json")" '```' "</details>"

if ((failures)); then
	summary "" "❌ ${negative} did not fail as designed; run ${run_id} is kept."
	exit 1
fi

if [[ "$KEEP_NEGATIVE_RUN" == "true" ]]; then
	summary "" "✅ ${negative} failed as designed; run ${run_id} kept (keep-negative-run)."
elif gh api -X DELETE "repos/${GH_REPO}/actions/runs/${run_id}" >/dev/null; then
	summary "" "✅ ${negative} failed as designed; run ${run_id} deleted (evidence above and in the artifact)."
else
	echo "::warning title=negative probe::could not delete ${negative} run ${run_id}"
	summary "" "✅ ${negative} failed as designed; deleting run ${run_id} failed, so it stays red on the Actions page."
fi
echo "${negative} failed as designed (run ${run_id})"
