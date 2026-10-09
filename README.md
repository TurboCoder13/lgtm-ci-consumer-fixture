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
| `siblings.yml` | push, dispatch | Two calls in one run produce distinct `python-results-*` names (#752) — but see the coverage caveat under [Retry convergence](#retry-convergence); target of the retry check below |
| `retry.yml` | push, dispatch | Lone reusable call for re-running without a sibling (#803/#717) |
| `egress.yml` | push, dispatch | Explicit allowlist denies a probe to `example.com`; preset-only job documents #913 |
| `perms.yml` | push, dispatch | Documented-minimum caller permissions (`contents: read`, `pull-requests: write`) parse and run (#735/#736) |
| `perms-negative.yml` | dispatch only (by its probe) | **Negative:** `contents: read` alone. Expected `startup_failure` at parse time; observed: see [Permission negative test](#permission-negative-test) |
| `readonly-node.yml` | push, dispatch | Generated read-only variant `reusable-test-node-run.yml` (lgtm-ci #1081) called with `actions: read` + `contents: read` only (no `pull-requests: write`): the run starting proves its union is read-only; the `check` job asserts the tests ran (`passed`, `tests-total > 0`). One `readonly-<family>.yml` per variant, so each is its own canary gate |
| `perms-negative-node.yml` | dispatch only | **Negative:** the Node facade `reusable-test-node.yml` with the same two read scopes and `publish-test-summary: true`. Expected `startup_failure` at parse time, before any job or publish step (lgtm-ci #1081) |
| `readonly-shell.yml` | push, dispatch | Generated read-only variant `reusable-test-shell-run.yml` (lgtm-ci #1081) on the `shell/` BATS project with `actions: read` + `contents: read` only; the `check` job asserts the tests ran |
| `perms-negative-shell.yml` | dispatch only | **Negative:** the shell facade `reusable-test-shell.yml` with the same two read scopes and `publish-test-summary: true`. Expected `startup_failure` at parse time (lgtm-ci #1081) |
| `readonly-rust.yml` | push, dispatch | Generated read-only variant `reusable-rust-test-run.yml` (lgtm-ci #1081) on the `rust/` project with `actions: read` + `contents: read` only; the `check` job asserts the tests ran |
| `perms-negative-rust.yml` | dispatch only | **Negative:** the Rust facade `reusable-rust-test.yml` with the same two read scopes and `publish-test-summary: true`. Expected `startup_failure` at parse time (lgtm-ci #1081) |
| `readonly-docker.yml` | push, dispatch | Read-only Docker entry `reusable-docker-multiplatform-validate.yml` (lgtm-ci #1081) with `contents: read` only: native amd64 + arm64 builds, smoke test, Trivy; asserts both `docker-trivy-sarif-<slug>` artifacts |
| `docker-facade-validate.yml` | push, dispatch | Facade `reusable-docker-multiplatform.yml` with `push: false`: validate path plus the facade's SARIF upload; asserts both `trivy-<slug>` code-scanning analyses |
| `docker-publish.yml` | push, dispatch | Facade with `push: true` and keyless Cosign to this repository's GHCR package `fixture-image`; asserts the published index lists both platforms |
| `docker-orchestrator.yml` | push, dispatch | `reusable-docker.yml` with `runner-map`: classify picks the split path through the facade into the validate file (three levels of nesting) |
| `docker-scan-failure.yml` | dispatch only (by its probe) | **Negative:** facade with `scan-exit-code: "1"` on the outdated `docker/Dockerfile.vulnerable`; builds fail, the verify job asserts the SARIF still reached code scanning |
| `docker-scan-failure-probe.yml` | dispatch only | Dispatches `docker-scan-failure.yml` and asserts it failed as designed (see [Negative probes](#negative-probes)) |
| `perms-negative-docker.yml` | dispatch only | **Negative:** facade with `push: true` and only `contents: read`. Expected `startup_failure` at parse time, before any push (lgtm-ci #1081) |
| `recover.yml` | push, dispatch | Release recovery end to end (lgtm-ci #1081): the run is its own source run (attested file, a non-prerelease release missing it); the read-only `reusable-release-recover-plan.yml` must report `github-release` missing, a facade dry run must publish nothing, the facade live run must upload the asset; the run deletes its release and tag |
| `perms-negative-recover.yml` | dispatch only | **Negative:** the recover facade with `dry-run: false` and only the plan's read scopes. Expected `startup_failure` at parse time (lgtm-ci #1081) |
| `actions-direct.yml` | push, dispatch | Direct `uses: lgtm-hq/lgtm-ci/.github/actions/run-*@sha` path (#1075) |
| `app-token-probe.yml` | dispatch only | Reach of a GitHub App token minted as the release reusables do (`owner` only, no `repositories:`): single-repo install sees exactly one repo; scoped variant works; sibling repo refused (#849) |
| `release-version-pr.yml` | dispatch only | `reusable-release-version-pr` from outside the org: App token, python ecosystem under `python/`, opens a version PR (closed by hand). See [Release paths](#release-paths) |
| `release-tamper-hook.yml` | dispatch only | **Negative-by-design:** `version-update-script` rewrites the next lgtm-ci script in the tooling checkout. Expected to succeed on today's lgtm-ci, must fail after #849 |
| `release-benign-hook.yml` | dispatch only | Well-behaved `version-update-script` (#849): edits `HOOK_RELEASE_INFO.txt` from `NEXT_VERSION` and `release-metadata.json`, asserts no token and read-only tooling; the edit must reach the version PR |
| `sbom-release-upload.yml` | dispatch only | `reusable-sbom-release-upload.yml` against a disposable prerelease `vfixture-<run_id>` (#935): asserts the SBOM assets are attached via `gh api -X GET`, then deletes the release and tag. See [SBOM release upload](#sbom-release-upload) |
| `python-private-dep.yml` | dispatch only | **Negative-by-design on pre-#1021 lgtm-ci:** `python-private-dep/` has a git dependency on the private sibling `trader-service` in group `engine` (never installed) and a deliberately stale `uv.lock` (version bumped without `uv lock`). No secret passed. Plain `uv sync` re-resolves and dies on `could not read Username for 'https://github.com'`; `uv sync --frozen` (lgtm-ci #1021) installs the lock verbatim and passes |
| `coverage-lcov.yml` | push, PR, dispatch | Line-only LCOV (vitest `lcovonly` with FN/BR records stripped) uploaded as `node-lcov-coverage` and fed to `reusable-coverage.yml` with default inputs (#1078). Baseline main `7362363d` failed with `Conversion failed: cannot convert from lcov to json`; since `c74c9c36` the LCOV is kept as-is and branches/functions render `n/a` |
| `playwright.yml` | push, dispatch | `reusable-test-e2e-playwright.yml` with `package-manager: bun` on the `playwright/` project, then `verify-report` lists the run's artifacts via `gh api -X GET` and asserts `playwright-report/index.html` is inside the downloaded artifact (#804). Baseline main `c74c9c36`: green but **0 artifacts**, `--reporter=html --reporter=json`, `[[: 950.264: syntax error`; since `65db5132` (PR #1104) the artifact holds HTML + JSON + JUnit on every run (`upload-report-when: always`). Appends `azure.archive.ubuntu.com:80 storage.googleapis.com:443` to the `playwright` preset (#1103) |
| `playwright-negative.yml` | dispatch only (by its probe) | **Negative-by-design:** project `chromium-failing` always fails; the verdict is `verify-report`, which asserts the failure-path artifact contains `index.html`. Baseline: artifact held only `playwright-results.json`; since #1104 the HTML report is present |
| `verify-negative.yml` | dispatch only (by its probe) | **Negative-by-design:** wrong committed digests for cargo-nextest and osv-scanner injected through the reusables' caller-script inputs; both jobs must be refused with a `digest mismatch` annotation (#1096) |
| `perms-negative-probe.yml`, `playwright-negative-probe.yml`, `verify-negative-probe.yml` | dispatch only | Dispatch their negative on the same ref and assert it failed **as designed**; green when it did, red when it passed or failed for another reason. See [Negative probes](#negative-probes) |

## Pinning to a candidate

```sh
scripts/pin.sh <lgtm-ci-sha>   # rewrites every uses: line and prints the result
```

Commit and push to `main`, or dispatch each workflow by hand. Every workflow
runs on `workflow_dispatch`; the push-path workflows also run on push to
`main`, and `python.yml` / `node-bun.yml` run on pull requests to `main`.
Dispatch a negative through its `*-probe.yml`, not directly, so an expected
failure does not stay red.

## Negative probes

A negative-by-design run is red on the Actions page even when it proves what
it should. It cannot be turned green from inside: a job that calls a reusable
workflow does not accept `continue-on-error`, so a failed call fails the run,
and `perms-negative.yml` is rejected at parse time (`startup_failure`), before
any job of its own could look at the result. Each negative therefore has a
probe, `<name>-probe.yml`, which calls the shared `negative-probe.yml`:
`scripts/negative/probe.sh` dispatches the negative on the probe's ref (the
dispatch API returns the run id), waits for it, and checks:

| Negative | Run conclusion | Job evidence |
|---|---|---|
| `perms-negative.yml` | `startup_failure` | zero jobs created |
| `playwright-negative.yml` | `failure` | `e2e-failing / Playwright E2E …` failed; `Verify failure-path HTML report artifact` succeeded |
| `verify-negative.yml` | `failure` | both `NEGATIVE … wrong digest` jobs failed **and** raised the `digest mismatch` annotation |

When every check holds, the probe writes the negative's jobs and annotations
to its job summary and the `negative-evidence` artifact, **deletes the red
negative run**, and is green. Any other outcome (the negative passed, failed
for a different reason, or never completed) fails the probe and keeps the
negative run for inspection. Dispatch a probe with `keep-negative-run: true`
to keep the negative run after a pass.

The external canary in lgtm-ci dispatches the probes, not the negatives: the
negatives appear in its table as `via_probe`, and each probe is reported
against an expected `success`.

First run (fixture branch `probe-test`, lgtm-ci `v0.76.0` `2134b700`,
2026-10-08): `perms-negative-probe`
[37836376566](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37836376566),
`playwright-negative-probe`
[37836381452](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37836381452)
and `verify-negative-probe`
[37836386618](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37836386618)
all green; each negative concluded as expected and its run was deleted.

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

First result (siblings run
[37212911361](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37212911361),
lgtm-ci `87e1bf19`): three artifacts before and after, run back to `success`.
Two caveats observed while doing it:

- `gh run rerun --job` on a reusable-call job re-ran **every** job in the run
  (all jobs show `attempt=2`), not just `b`. Convergence still holds, but the
  check is "whole run re-runs onto the same names", not "one sibling re-runs".
- Both siblings set `upload-coverage: true` and both upload the flat name
  `python-coverage`; `b`'s overwrite silently replaces `a`'s coverage. The
  `siblings.yml` duplicate check cannot see this because the API returns one
  artifact per name. Only `python-results-<version>` is actually distinct
  across siblings. Reported on lgtm-hq/lgtm-ci#1074 for #752.

## Permission negative test

`perms-negative.yml` calls `reusable-test-python.yml` with `contents: read`
only. The reusable's publish job declares `pull-requests: write`, which GitHub
should reject at parse time as a permission the caller never granted.

| Dispatch | Expected | Observed |
|---|---|---|
| [37213536090](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37213536090) (lgtm-ci `87e1bf19`, 2026-10-04) | `startup_failure` | `startup_failure`, zero jobs created — "This run likely failed because of a workflow file issue" |

The documented minimum in lgtm-ci is therefore accurate: dropping
`pull-requests: write` is rejected before any job runs, not silently at the
publish step.

## Release paths

`release-version-pr.yml`, `release-tamper-hook.yml` and
`release-benign-hook.yml` call `reusable-release-version-pr.yml`;
`app-token-probe.yml` mints the same kind of token directly. All four need
the GitHub App:

- **App:** `lgtm-ci-fixture-release` (PR author `lgtm-ci-fixture-release[bot]`),
  owned by the fixture owner, installed on **this repository only**
  (single-repo install, not the whole account).
- **Permissions:** Contents, Pull requests, Issues, Workflows — read & write.
- **Secrets:** `RELEASE_APP_ID` and `RELEASE_APP_PRIVATE_KEY`, set on this
  repository and forwarded to the reusable exactly as in the lgtm-ci examples.
- **Tag:** `v0.1.0` on `4003cf6` is the baseline; the bump is computed from
  conventional commits after it, so dispatches produce a `v0.2.0` PR until a
  real `feat:`/`fix:` lands after that tag.

`release-version-pr.yml`, `release-benign-hook.yml` and (before #849)
`release-tamper-hook.yml` **open a real version PR** in this repository (branch `release/v<next>`, label `fixture`).
The PR is closed and its branch deleted by hand straight after each dispatch;
nothing is ever merged or tagged from these runs. Close the previous PR
before dispatching again — the reusable skips when a version PR already
exists.

`release-tamper-hook.yml` is the #849 probe: `scripts/tamper-hook.sh` runs as
the `version-update-script` and rewrites `check-version-files-changed.sh` in
the `.lgtm-ci-tooling` checkout so it prints `::warning::TAMPERED`. On
today's lgtm-ci the hook shares a job — filesystem and App token — with the
tooling that follows it, so the marker is expected to appear; after #849 the
run must fail before any PR, branch or commit is created.

`release-benign-hook.yml` is the positive counterpart: `scripts/benign-hook.sh`
rewrites the tracked `HOOK_RELEASE_INFO.txt` from `NEXT_VERSION` and the
read-only `release-metadata.json` that lgtm-ci writes for the hook, and fails
itself if a token is in its environment or the tooling checkout is writable.
After #849 the file's edit must appear in the version PR, carried from the
`version-update-hook` job to `Create Version PR` as a diff artifact.

Results (lgtm-ci `fab929f1`, 2026-10-04):

| Dispatch | Workflow | Expected | Observed |
|---|---|---|---|
| [37214083123](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37214083123) | `app-token-probe.yml` | 3 jobs green; un-scoped token sees 1 repo | 3/3 green. Un-scoped token: `total_count=1`, only this repo. Scoped: same. Private sibling `trader-service`: `HTTP 404`; public sibling `git-replay`: `admin=false push=false pull=false` |
| [37214105430](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37214105430) | `release-version-pr.yml` | version PR opened by the App | **failed** at `Update CHANGELOG.md`: `CHANGELOG.md not found` — the reusable requires an existing CHANGELOG.md and the docs do not say so. Added one |
| [37214200965](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37214200965) | `release-version-pr.yml` | version PR opened by the App | [PR #3](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/pull/3) `chore(release): version 0.2.0` by the App, signed commit (`verified=true`), `python/pyproject.toml` + `python/uv.lock` (tomlkit fallback, `uv` absent) + CHANGELOG. Closed, branch deleted |
| [37214295869](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37214295869) | `release-tamper-hook.yml` | `TAMPERED` marker in the run log (today) | marker printed by `Check for version file changes`; run green; [PR #4](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/pull/4) opened anyway. Closed, branch deleted. Confirms #849 |

Results (lgtm-ci PR [#1097](https://github.com/lgtm-hq/lgtm-ci/pull/1097) head `87da5a5c`, 2026-10-05) — after #849:

| Dispatch | Workflow | Expected | Observed |
|---|---|---|---|
| [37289624656](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37289624656) (baseline, `main` `269b3702`) | `release-tamper-hook.yml` | marker, PR opened | marker printed, green, PR #5 opened. Closed, branch deleted |
| [37292937536](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37292937536) | `release-tamper-hook.yml` | **fail** before any mutation, no marker | `Run version update hook` **failed** (`sed: couldn't open temporary file …/.lgtm-ci-tooling/…: Permission denied`, hook exit 4); `Create Version PR` skipped; no marker, no PR, no branch |
| [37292941503](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37292941503) | `app-token-probe.yml` | 3 jobs green | 3/3 green; scoped variant works |
| [37293093443](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37293093443) | `release-version-pr.yml` | version PR opened; hook jobs skipped | [PR #6](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/pull/6) by the App (`CHANGELOG.md`, `python/pyproject.toml`, `python/uv.lock`); `Prepare`/`Run version update hook` skipped. Closed, branch deleted |
| [37293206639](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37293206639) | `release-benign-hook.yml` | hook edit reaches the PR via the artifact | `Prepare` wrote `release-metadata.json` (`latest_release: null` — no GitHub Release here, only the tag); hook ran with no token, changed 1 file; `Create Version PR` applied it; [PR #7](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/pull/7) carries `HOOK_RELEASE_INFO.txt` (`next_version=0.2.0`). Closed, branch deleted |

After merge, lgtm-ci `main` `26f42909`: tamper 37323204811 fails in the hook job (no marker, no PR); `release-version-pr.yml` 37323359644 opens PR #13 (closed). Head `2339aa8a` (decoder follow-up): tamper 37311669342 fails in the hook job, benign 37311853949 opens PR #12 with `HOOK_RELEASE_INFO.txt` (closed). Head `c8a647e4` (2026-10-05): tamper
[37302193493](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37302193493)
fails in `Run version update hook`, no marker, no PR; benign
[37302323143](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37302323143)
opens [PR #11](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/pull/11)
with `HOOK_RELEASE_INFO.txt` through artifacts
`release-version-pr-{metadata,hook-changes}-v-4c94485e` (closed, branch
deleted). Intermediate heads `ca7589df` and `940ae9fa` gave the same shape
(runs 37294468681/37294473759 and 37298519065/37298749674; PRs #8, #10 closed).

The first probe dispatch
([37213943269](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37213943269))
failed its negative job because it read a *public* sibling repo, which any
token can do (`permissions` all false). The job now uses a private sibling.

## SBOM release upload

`sbom-release-upload.yml` is the #935 probe. `prepare` uploads two
SBOM-shaped files as the `sbom` workflow artifact (the shape
`reusable-sbom.yml` leaves behind in `release-assets` mode) and creates
prerelease `vfixture-<run_id>` on the dispatched commit with `github.token`,
the token the reusable itself uploads with. `upload` calls
`reusable-sbom-release-upload.yml` with that tag. `verify` reads the asset
list with `gh api -X GET /repos/{owner}/{repo}/releases/tags/<tag>`, requires
both files, and deletes the release and tag whatever the outcome. No App
token is involved: the reusable uses `github.token`, and a release created
with it is enough for a `gh release upload` to the same repository.

Before #935 the `upload` job fails with `failed to run git: fatal: not a git
repository`: it checks out lgtm-ci tooling only, never this repository, and
set no `GH_REPO`, so `gh` had nowhere to upload to.

Results (2026-10-06):

| Dispatch | lgtm-ci pin | Expected | Observed |
|---|---|---|---|
| [37442408445](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37442408445) | `main` `97e1d795` (baseline) | upload fails, no assets | `failed to run git: fatal: not a git repository`; `assets on vfixture-37442408445: <none>`; release and tag deleted |
| [37444408745](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37444408745) | PR [#1100](https://github.com/lgtm-hq/lgtm-ci/pull/1100) head `7eab3cb0` | both assets attached | `Uploaded 2 SBOM file(s)`; assets `fixture.cdx.json`, `fixture.spdx.json`; all three jobs green; release and tag deleted |
| [37449477752](https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/actions/runs/37449477752) | `main` `7362363d` (after merge) | both assets attached | same shape: 2 files uploaded, both assets present, release and tag deleted |

## Baseline

The first run against lgtm-ci `main` is expected to fail; the run URLs are
recorded on lgtm-hq/lgtm-ci#1074 so that later fixes have a before/after.
