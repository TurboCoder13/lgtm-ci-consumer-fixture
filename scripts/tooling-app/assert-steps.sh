#!/usr/bin/env bash
# Assert the tooling App steps of tooling-app.yml's called jobs (lgtm-ci #1622).
#
# Reads this run's jobs through the jobs API and checks the conclusion of each
# named step, that the app-pair job raised no "Token revocation failed"
# warning, and that its log carries the line "Token revoked".
# actions/create-github-app-token's post step concludes success both when it
# revokes and when it skips revocation (token not set, token expired,
# skip-token-revoke), so the step conclusion alone does not prove it; the
# "Token revoked" info line is written only after DELETE /installation/token
# returned. Writes a table to the job summary and fails when any check does
# not hold. Prints no token and no log: the log is saved to a private temp
# file, grepped for that one marker and deleted.
#
# Usage: scripts/tooling-app/assert-steps.sh
#
# Environment:
#   GH_TOKEN             github.token with actions: read, checks: read
#   GH_REPO              owner/repo of this fixture
#   RUN_ID               this run's id (github.run_id)
#   GITHUB_STEP_SUMMARY  job summary file (optional)
set -euo pipefail

: "${GH_REPO:?GH_REPO is required}"
: "${RUN_ID:?RUN_ID is required}"

# Expectations, one line per check, tab-separated:
#   job  <job-name prefix> <job conclusion>
#   step <job-name prefix> <step name> <step conclusion, or "absent">
#   no-warning <job-name prefix> <annotation message prefix>
#   log-line <job-name prefix> <exact log line, after the timestamp>
expectations() {
	local pair="app-pair / Tooling App pair" none="no-app / No tooling App"
	printf 'job\t%s\tsuccess\n' "$pair"
	printf 'step\t%s\tCheck tooling App credential\tsuccess\n' "$pair"
	printf 'step\t%s\tMint tooling App token\tsuccess\n' "$pair"
	printf 'step\t%s\tCheckout lgtm-ci tooling\tsuccess\n' "$pair"
	printf 'step\t%s\tCheckout and harden\tsuccess\n' "$pair"
	printf 'step\t%s\tPost Mint tooling App token\tsuccess\n' "$pair"
	printf 'no-warning\t%s\tToken revocation failed\n' "$pair"
	printf 'log-line\t%s\tToken revoked\n' "$pair"
	printf 'job\t%s\tsuccess\n' "$none"
	printf 'step\t%s\tCheck tooling App credential\tskipped\n' "$none"
	printf 'step\t%s\tMint tooling App token\tskipped\n' "$none"
	printf 'step\t%s\tCheckout lgtm-ci tooling\tsuccess\n' "$none"
	printf 'step\t%s\tCheckout and harden\tsuccess\n' "$none"
	printf 'step\t%s\tPost Mint tooling App token\tabsent\n' "$none"
}

summary() {
	[[ -z "${GITHUB_STEP_SUMMARY:-}" ]] || printf '%s\n' "$@" >>"$GITHUB_STEP_SUMMARY"
}

# Captured, not read from a process substitution, so a failed lookup fails
# the assertion instead of reading as "no jobs".
jobs_raw="$(gh api -X GET "repos/${GH_REPO}/actions/runs/${RUN_ID}/jobs?filter=latest&per_page=100")" || {
	echo "::error::cannot list the jobs of run ${RUN_ID}" >&2
	exit 1
}
# [{id, name, conclusion, steps: [{name, conclusion}]}]
jobs_json="$(jq -c '[.jobs[] | {id, name, conclusion: (.conclusion // ""),
	steps: [(.steps // [])[] | {name, conclusion: (.conclusion // "")}]}]' <<<"$jobs_raw")"

job_ids() {
	jq -r --arg p "$1" '.[] | select(.name | startswith($p)) | .id' <<<"$jobs_json"
}

# The job log goes to a private temp file, never to stdout or the summary.
log_file="$(mktemp)"
chmod 600 "$log_file"
trap 'rm -f "$log_file"' EXIT

# Whether job $1's log has a line that is exactly $2 after the optional
# "<ISO timestamp> " prefix the logs endpoint adds. Prints found, missing or
# unreadable; nothing of the log itself.
log_has_line() {
	local id="$1" line="$2"
	# Job logs carry terminal escape sequences, which gh api refuses to write
	# without this flag. The log only goes to the private file, never to output.
	if ! gh api --allow-escape-sequences "repos/${GH_REPO}/actions/jobs/${id}/logs" >"$log_file" 2>/dev/null; then
		echo "log unreadable"
		return
	fi
	# grep -c, not -q: -q exits at the first match and, under pipefail, the
	# SIGPIPE in sed would turn a match into a failure.
	local count
	count="$(tr -d '\r' <"$log_file" |
		sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:.]+Z //' |
		grep -cxF -e "$line" || true)"
	: >"$log_file"
	if ((${count:-0} > 0)); then
		echo "found"
	else
		echo "missing"
	fi
}

failures=0
rows=()
while IFS=$'\t' read -r kind a b c; do
	case "$kind" in
	job)
		label="job \`${a}*\`"
		want="$b"
		got="$(jq -r --arg p "$a" '[.[] | select(.name | startswith($p)) | .conclusion] | if length == 0 then "absent" else join(",") end' <<<"$jobs_json")"
		;;
	step)
		label="step \`${b}\` in \`${a}*\`"
		want="$c"
		got="$(jq -r --arg p "$a" --arg s "$b" '[.[] | select(.name | startswith($p)) | .steps[] | select(.name == $s) | .conclusion] | if length == 0 then "absent" else join(",") end' <<<"$jobs_json")"
		;;
	no-warning)
		label="no \`${b}\` annotation in \`${a}*\`"
		want="none"
		got="none"
		ids="$(job_ids "$a")"
		if [[ -z "$ids" ]]; then
			got="job absent"
		fi
		for id in $ids; do
			annotations="$(gh api -X GET "repos/${GH_REPO}/check-runs/${id}/annotations?per_page=100")" || {
				got="annotations unreadable"
				break
			}
			count="$(jq --arg m "$b" '[.[] | select((.message // "") | startswith($m))] | length' <<<"$annotations")"
			((count == 0)) || got="${count} found"
		done
		;;
	log-line)
		label="log line \`${b}\` in \`${a}*\`"
		want="found"
		got="job absent"
		ids="$(job_ids "$a")"
		for id in $ids; do
			got="$(log_has_line "$id" "$b")"
			[[ "$got" == "found" ]] || break
		done
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
		echo "::error title=tooling App assertion::${label}: expected '${want}', got '${got}'"
	fi
done < <(expectations)

summary "## Tooling App credential (lgtm-ci #1622)" "" \
	"| Check | Expected | Observed | |" "|---|---|---|---|" "${rows[@]}" "" \
	"<details><summary>Jobs and steps</summary>" "" '```json' "$(jq . <<<"$jobs_json")" '```' "</details>"

if ((failures)); then
	echo "${failures} tooling App check(s) failed" >&2
	exit 1
fi
echo "tooling App steps concluded as expected"
