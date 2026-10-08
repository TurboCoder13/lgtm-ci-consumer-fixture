#!/usr/bin/env bats
# Minimal BATS suite for the read-only shell variant (lgtm-ci #1081).

setup() {
	# shellcheck source=../../greet.sh
	source "${BATS_TEST_DIRNAME}/../../greet.sh"
}

@test "greet: defaults to world" {
	run greet
	[ "$status" -eq 0 ]
	[ "$output" = "hello, world" ]
}

@test "greet: uses the given name" {
	run greet fixture
	[ "$output" = "hello, fixture" ]
}
