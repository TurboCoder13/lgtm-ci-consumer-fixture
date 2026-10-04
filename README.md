# lgtm-ci consumer fixture

A deliberately external consumer of [lgtm-hq/lgtm-ci](https://github.com/lgtm-hq/lgtm-ci).
It lives outside the `lgtm-hq` org so nothing resolves by coincidence, calls
reusable workflows only through `uses: lgtm-hq/lgtm-ci/.github/workflows/<file>.yml@<sha>`,
passes **no `tooling-ref`**, and contains **no copied lgtm-ci actions or scripts**
(`scripts/check-no-vendoring.sh`). Tracked by lgtm-hq/lgtm-ci#1074.

| Workflow | Triggers | Proves |
|---|---|---|
| `python.yml` | push, PR, dispatch | Python path at an exact SHA with no `tooling-ref` (#995). On `pull_request` the test-summary comment is enabled, so the PR-gated publish job and fork guard run |
| `node-bun.yml` | push, PR, dispatch | Node path with bun; tooling source present next to caller source; lockfiles untouched. PR path publishes the test summary |
| `node-npm.yml` | push, dispatch | Node path with npm (#1077) |
| `rust.yml` | push, dispatch | Rust path; only the Rust toolchain installed; consumer ships `.config/nextest.toml` |
| `siblings.yml` | push, dispatch | Two calls in one run produce distinct artifact names (#752); target of the retry check below |
| `retry.yml` | push, dispatch | Lone reusable call for re-running without a sibling (#803/#717) |
| `egress.yml` | push, dispatch | Explicit allowlist denies a probe to `example.com`; preset-only job documents #913 |
| `perms.yml` | push, dispatch | Documented-minimum caller permissions (`contents: read`, `pull-requests: write`) parse and run (#735/#736) |
| `perms-negative.yml` | dispatch only | **Negative:** `contents: read` alone. Expected `startup_failure` at parse time; observed: see [Permission negative test](#permission-negative-test) |
| `actions-direct.yml` | push, dispatch | Direct `uses: lgtm-hq/lgtm-ci/.github/actions/run-*@sha` path (#1075) |

## Pinning to a candidate

```sh
scripts/pin.sh <lgtm-ci-sha>   # rewrites every uses: line and prints the result
```

Commit and push to `main`, or dispatch each workflow by hand. Every workflow
runs on `workflow_dispatch`; all but `perms-negative.yml` also run on push to
`main`, and `python.yml` / `node-bun.yml` run on pull requests to `main`.

## Retry convergence

A workflow cannot re-run its own jobs, so convergence is checked from outside:

```sh
scripts/rerun-sibling.sh [run-id]   # default: latest completed siblings run
```

The helper snapshots the run's artifact names, re-runs job `b` with
`gh run rerun <run-id> --job <job-id>`, waits for the run to complete, and
asserts that the artifact names are still unique and the set is unchanged.
The reusable uploads with `overwrite: true`, so a re-run must replace its own
artifacts rather than collide with or duplicate them.

## Permission negative test

`perms-negative.yml` calls `reusable-test-python.yml` with `contents: read`
only. The reusable's publish job declares `pull-requests: write`, which GitHub
should reject at parse time as a permission the caller never granted.

| Dispatch | Expected | Observed |
|---|---|---|
| pending | `startup_failure` | pending |

## Baseline

The first run against lgtm-ci `main` is expected to fail; the run URLs are
recorded on lgtm-hq/lgtm-ci#1074 so that later fixes have a before/after.
