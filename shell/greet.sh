#!/usr/bin/env bash
# Fixture subject for the lgtm-ci shell test path (lgtm-ci #1081).
greet() {
	printf 'hello, %s\n' "${1:-world}"
}
