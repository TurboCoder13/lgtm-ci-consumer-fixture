#!/usr/bin/env bats
# Reject false security passes from outages, fail-open agents and unrelated drops.
setup() {
	source "$BATS_TEST_DIRNAME/probe.sh"
	events="$BATS_TEST_TMPDIR/events.txt"
	cat >"$events" <<'LOG'
Sun, 25 Oct 2026 20:00:00 GMT:ip address dropped: 93.184.215.14
Sun, 25 Oct 2026 20:00:00 GMT:endpoint called ip address:port 93.184.215.14:443, domain: , pid: 1234, process: curl, status:
LOG
}

@test "accept exact denied curl destination with live agent" {
	run negative_verdict 7 93.184.215.14 1234 active "$events"
	[ "$status" -eq 0 ]
	[ "$output" = CONFIRMED_BLOCK ]
}

@test "reject a successful connection despite old drop evidence" {
	run negative_verdict 0 93.184.215.14 1234 active "$events"
	[ "$status" -eq 1 ]
}

@test "reject generic DNS failure" {
	run negative_verdict 6 93.184.215.14 1234 active "$events"
	[ "$status" -eq 1 ]
}

@test "reject curl failure when hardener is inactive" {
	run negative_verdict 7 93.184.215.14 1234 failed "$events"
	[ "$status" -eq 1 ]
}

@test "reject a drop for another address" {
	run negative_verdict 7 93.184.215.15 1234 active "$events"
	[ "$status" -eq 1 ]
}

@test "reject another process at the same destination" {
	run negative_verdict 7 93.184.215.14 9999 active "$events"
	[ "$status" -eq 1 ]
}

@test "reject missing local drop even when curl failed" {
	sed '/ip address dropped:/d' "$events" >"$events.tmp"
	mv "$events.tmp" "$events"
	run negative_verdict 7 93.184.215.14 1234 active "$events"
	[ "$status" -eq 1 ]
}

@test "reject malformed destination rather than interpret it as a pattern" {
	run negative_verdict 7 '.*' 1234 active "$events"
	[ "$status" -eq 1 ]
}

@test "accept agent versions without a trailing status field" {
	sed 's/, status:$//' "$events" >"$events.tmp"
	mv "$events.tmp" "$events"
	run negative_verdict 7 93.184.215.14 1234 active "$events"
	[ "$status" -eq 0 ]
}
