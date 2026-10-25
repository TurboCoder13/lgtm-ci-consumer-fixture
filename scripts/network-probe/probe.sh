#!/usr/bin/env bash
# Fixture-owned diagnostics for lgtm-hq/lgtm-ci#1203; never change network policy.
set -euo pipefail

probe_dir() {
	printf '%s/ci1203' "${RUNNER_TEMP:?RUNNER_TEMP is required}"
}

agent_events() {
	sudo -n cat /home/agent/agent.log 2>/dev/null |
		grep -E 'domain resolved:|ip address dropped:|endpoint called ip address:port|domain not allowed:|Initialized|Reverted changes|Error resolving' || true
}

snapshot() {
	local stage="$1" out
	out="$(probe_dir)/${stage}.txt"
	{
		date -u -Is
		printf 'stage=%s sha=%s run=%s attempt=%s arch=%s image=%s version=%s\n' \
			"$stage" "$GITHUB_SHA" "$GITHUB_RUN_ID" "$GITHUB_RUN_ATTEMPT" \
			"$RUNNER_ARCH" "${ImageOS:-unknown}" "${ImageVersion:-unknown}"
		sha256sum "${BASH_SOURCE[0]}"
		uname -a
		readlink -f /etc/resolv.conf
		stat -Lc '%d:%i %n' /etc/resolv.conf
		cat /etc/resolv.conf
		timeout 10 resolvectl status || true
		local file
		for file in /etc/systemd/resolved.conf /etc/systemd/resolved.conf.d/*.conf \
			/run/systemd/resolve/resolv.conf /run/systemd/resolve/stub-resolv.conf; do
			if [[ -f "$file" ]]; then
				printf '\nFILE %s\n' "$file"
				grep -E '^([[:space:]]*(DNS|FallbackDNS|Domains|DNSStubListener|DNSOverTLS|DNSSEC)=|nameserver |search )' "$file" || true
			fi
		done
		sudo -n ss -lunpt || true
		ip route show
		local unit
		for unit in systemd-resolved egress-dns-resolver egress-outbound-proxy hosted-compute-agent agent; do
			systemctl show "$unit" -p LoadState -p ActiveState -p ExecMainPID || true
		done
		sudo -n sha256sum /home/agent/agent 2>/dev/null || true
		sudo -n iptables-save || true
		sudo -n ip6tables-save || true
		agent_events
	} >"$out" 2>&1
	cat "$out"
}

prepare() {
	local out
	out="$(probe_dir)"
	mkdir -p "$out"
	snapshot before
	# Passive only: no DNS lookups before the real checkout and artifact tests.
	# GitHub pre-downloads this SHA-pinned helper with the other actions.
	if command -v tcpdump >/dev/null; then
		# Bounded DNS text only, no HTTP payload, pcap, environment or credentials.
		sudo -n timeout 420 tcpdump -i any -l -nn -tttt -vv \
			'(udp port 53 or tcp port 53) and (net 127.0.0.0/8 or host 168.63.129.16)' 2>&1 |
			grep --line-buffered -E 'github\.com|githubapp\.com|githubusercontent\.com|blob\.core\.windows\.net|example\.com|tcpdump:|packets captured|packets received|packets dropped' \
				>"$out/dns-wire.txt" &
		printf '%s\n' "$!" >"$out/capture.pid"
	else
		printf 'tcpdump unavailable; DNS packet evidence incomplete\n' >"$out/dns-wire.txt"
	fi
}

# A generic curl failure is NOT an enforcement pass. Require fresh evidence
# that the exact curl process and selected destination were locally rejected.
negative_verdict() {
	local result="$1" address="$2" pid="$3" active="$4" events="$5"
	if [[ "$address" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] &&
		[[ "$pid" =~ ^[0-9]+$ ]] && [[ "$active" == active ]] &&
		[[ "$result" == 7 || "$result" == 28 ]] &&
		grep -Fqx "ip address dropped: $address" <(sed -E 's/^.*GMT://' "$events") &&
		grep -F "endpoint called ip address:port $address:443, domain: " "$events" |
		grep -Eq "pid: $pid, process: curl(,|$)"; then
		printf 'CONFIRMED_BLOCK\n'
	else
		printf 'UNCONFIRMED\n'
		return 1
	fi
}

negative() {
	local out address before pid result=0 active verdict
	out="$(probe_dir)"
	# Active control runs AFTER checkout/roundtrip: do not prime their DNS cache.
	address="$(getent ahostsv4 example.com | awk 'NR == 1 { print $1 }')" || true
	if [[ ! "$address" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
		printf 'UNCONFIRMED: example.com did not resolve\n' >"$out/negative.txt"
		cat "$out/negative.txt"
		return 1
	fi
	before="$(agent_events | wc -l)"
	curl --noproxy '*' --connect-timeout 5 --max-time 10 --retry 0 \
		--resolve "example.com:443:$address" --silent --show-error \
		--output /dev/null --write-out '%{json}\n' https://example.com/ \
		>"$out/negative-curl.txt" 2>"$out/negative-curl-stderr.txt" &
	pid="$!"
	wait "$pid" || result="$?"
	# Allow the agent's event writer to flush, without retrying the request.
	sleep 3
	agent_events | tail -n "+$((before + 1))" >"$out/negative-agent.txt"
	active="$(systemctl is-active agent.service)" || true
	verdict="$(negative_verdict "$result" "$address" "$pid" "$active" "$out/negative-agent.txt")" || true
	printf 'verdict=%s curl_rc=%s address=%s pid=%s agent=%s\n' \
		"$verdict" "$result" "$address" "$pid" "$active" | tee "$out/negative.txt"
	[[ "$verdict" == CONFIRMED_BLOCK ]]
}

payload() {
	printf '%s %s %s\n' "$GITHUB_RUN_ID" "$GITHUB_RUN_ATTEMPT" "$RUNNER_ARCH" >"$(probe_dir)/payload.txt"
}

roundtrip() {
	cmp "$(probe_dir)/payload.txt" "$RUNNER_TEMP/ci1203-roundtrip/payload.txt"
	printf 'ROUNDTRIP_OK\n' | tee "$(probe_dir)/roundtrip.txt"
}

finish() {
	local out host resolver
	out="$(probe_dir)"
	snapshot final
	# Label these as active measurements: they can alter cache state.
	{
		printf 'ACTIVE_DNS_COMPARISONS_BEGIN\n'
		for host in github.com api.github.com; do
			timeout 10 getent ahostsv4 "$host" || true
			timeout 10 resolvectl query "$host" || true
			if command -v dig >/dev/null; then
				for resolver in 127.0.0.1 127.0.0.53 127.0.0.100; do
					dig +time=2 +tries=1 "@$resolver" "$host" A || true
				done
			fi
		done
		printf 'ACTIVE_DNS_COMPARISONS_END\n'
	} >"$out/active-dns.txt" 2>&1
	cat "$out/active-dns.txt"
	# Freeze a copy before checksumming: the independently bounded capture may
	# still be writing its .live file. Never signal a possibly reused PID.
	if [[ -f "$out/dns-wire.live" ]]; then
		cp "$out/dns-wire.live" "$out/dns-wire.txt"
	fi
	# Snapshots and console output survive failed artifact publication.
	[[ ! -f "$out/dns-wire.txt" ]] || cat "$out/dns-wire.txt"
	(cd "$out" && sha256sum ./*.txt >SHA256SUMS)
	cat "$out/SHA256SUMS"
	printf 'TERMINAL_STEP_REACHED (external API confirmation still required)\n'
}

main() {
	case "${PROBE_MODE:-}" in
	prepare) prepare ;;
	snapshot) snapshot hardened ;;
	payload) payload ;;
	roundtrip) roundtrip ;;
	negative) negative ;;
	finish) finish ;;
	*)
		printf 'Unknown PROBE_MODE\n' >&2
		return 2
		;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main "$@"
fi
