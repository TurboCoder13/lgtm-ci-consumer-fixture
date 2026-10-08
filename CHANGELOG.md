# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

`reusable-release-version-pr` requires this file to exist (`update-changelog.sh`
exits 1 otherwise); the fixture's first release dispatch failed without it.

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.2.0] - 2026-10-08

### Added

- Playwright fixture for lgtm-hq/lgtm-ci#804 (baseline at lgtm-ci main c74c9c36)
  (395ba51)
- PR-gated summary, retry convergence helper, negative permission test (#2) (a1073e2)

### Changed

- record release-path and App token probe results (ba49d26)
- add CHANGELOG.md required by reusable-release-version-pr (74cd525)
- record perms-negative startup_failure and retry-convergence results (0b7445e)
- pin every lgtm-ci reference to ea934b166217e13f0b2a56e62b724d8649c02061 (4b21c44)
- re-pin to lgtm-ci main ea934b16 (PR #1114 merged: caller-permissions validator,
  examples at v0.75.3) (06b0b21)
- re-pin every lgtm-ci reference to PR #1119 head 475206c9 (lgtm-ci #1076) (1420fc6)
- re-pin every lgtm-ci reference to PR #1119 head 2b917e9d; sibling rust-build legs
  carry distinct concurrency-scope (lgtm-ci #1076) (fb3374d)
- pin rust-release-build to lgtm-ci 535a7344 (validate-runner-policy metadata fix only)
  for the Windows build-step baseline (lgtm-ci #1076) (847ecdb)
- rust-build siblings and dispatch-only rust release build + windows-latest exe smoke,
  pinned to lgtm-ci main 696e3f77 (baseline for lgtm-ci #1076) (aacf5d9)
- re-pin #1096 probes to lgtm-ci main 696e3f77 (after merge of #1113) (a067ec3)
- lint-clean the Python test (docstrings, nosec on the pytest assert) so the verbatim
  lgtm-ci starter's quality job can pass (8fec1b7)
- dispatch-only fresh-install probe for digest-verified nextest + llvm-cov (lgtm-ci
  #1096) (84418ac)
- starter-python.yml copied verbatim from lgtm-ci examples/ci-python.yml at v0.75.3
  (31750eca), only working-directory: python added (lgtm-ci #808/#736) (0edc8eb)
- re-pin #1096 probes to lgtm-ci PR #1113 head c433bd30 (e559ba4)
- clear cached cargo-nextest before the wrong-digest probe (lgtm-ci #1096) (248e352)
- digest-verified installs probe for lgtm-ci #1096 (pinned to PR #1113 head b5af4b6e)
  (9bfa273)
- pin python.yml and python-private-dep.yml to lgtm-ci main b3db5e7d (PR #1112 merged;
  previous re-pin missed the files) (bdda380)
- re-pin python.yml and python-private-dep.yml to lgtm-ci main b3db5e7d (PR #1112
  merged) (e39334e)
- re-pin python.yml and python-private-dep.yml to lgtm-ci PR #1112 head 7acbc5fc
  (49999ec)
- re-pin python.yml and python-private-dep.yml to lgtm-ci PR #1112 head ac5ed8b0
  (29088b8)
- re-pin python.yml and python-private-dep.yml to lgtm-ci PR #1112 head 1a488690
  (e3b4269)
- python-private-dep probe for lgtm-ci #1021 (pinned to main 2cbba297) (ecbd4b8)
- re-pin build-python-direct.yml to lgtm-ci PR #1107 head 3bbe6b71 (a682ed9)
- re-pin build-python-direct.yml to lgtm-ci PR #1107 head b300d671 (bb4daa0)
- re-pin build-python-direct.yml to lgtm-ci PR #1107 head 857d7ef1 (e9a8a53)
- re-pin build-python-direct.yml to lgtm-ci PR #1107 head e48546dd (e35fd1e)
- re-pin build-python-direct.yml to lgtm-ci PR #1107 head 69c53f66 (1837cd9)
- build-python-direct.yml reproduces the tag-event checkout shape on branch runs
  (lgtm-ci #1087 baseline at main b272bf2b) (aec38c8)
- build-python-direct.yml, shallow checkout + direct build-python-package (lgtm-ci #1087
  baseline at main b272bf2b) (4ce8cf3)
- pin lgtm-ci to main 65db5132 (PR #1104 merged); record #804 Playwright fixtures in
  README (bc04eb9)
- pin lgtm-ci to 043fbcb6 (lgtm-hq/lgtm-ci#1104); playwright.yml uploads the report on
  green runs (5f195c4)
- pin lgtm-ci to 5bc08375 (lgtm-hq/lgtm-ci#1104); playwright.yml uploads the report on
  green runs (e14c598)
- pin lgtm-ci to 70db69c9 (lgtm-hq/lgtm-ci#1104); playwright.yml uploads the report on
  green runs (992926c)
- pin lgtm-ci to f59310d4 (lgtm-hq/lgtm-ci#1104); playwright.yml uploads the report on
  green runs (e22ac02)
- record #1078 after-merge result (lgtm-ci main c74c9c36) (c40999d)
- pin lgtm-ci to main c74c9c36 (PR #1101 merged) (d378136)
- pin lgtm-ci to main 467ebf03 (PR #1102 merged) (4b8b4d8)
- pin lgtm-ci to #1077 head 480e6db7 (43b2fce)
- pin lgtm-ci to #1077 head 667881ef (3212350)
- pin lgtm-ci to #1077 head 3c08c9af (1f450b0)
- pin lgtm-ci to #1077 head 72f48e36 (160e920)
- pin lgtm-ci to #1077 head a35aef15 (ad7bbe7)
- pin lgtm-ci to #1077 head bd3f2da2 (bun x --no-install, review fixes) (2fd6958)
- pin lgtm-ci to #1077 head 2885e0e7 (lighthouse report resolution, review fixes)
  (d5bc047)
- pin lgtm-ci to #1077 head ff998142 (pnpm package_json_file fix) (8fe0aed)
- pin lgtm-ci to #1077 head b375440b; add node-pnpm.yml, lighthouse subproject,
  clean-tree assertions (2e9f0e2)
- add coverage-lcov.yml: line-only LCOV through reusable-coverage (#1078 baseline at
  main 7362363d) (2755a64)
- record #935 after-merge result (lgtm-ci main 7362363d) (76f7a6c)
- pin lgtm-ci to main 7362363d (PR #1100 merged) (883c6ec)
- record #935 results (baseline main 97e1d795, PR #1100 head 7eab3cb0) (8397b19)
- pin lgtm-ci to PR #935-fix head 7eab3cb0 (b98c8ac)
- add sbom-release-upload fixture for lgtm-ci#935 (pinned to main 97e1d795 for the
  baseline) (742ac94)
- record #849 after-merge results (lgtm-ci main 26f42909) (78ae969)
- pin lgtm-ci to main 26f42909 (PR #1097 merged) (00c4342)
- record #849 results for lgtm-ci PR #1097 head 2339aa8a (f55de29)
- pin lgtm-ci to PR #1097 head 2339aa8a (31e2231)
- record #849 results for lgtm-ci PR #1097 head c8a647e4 (ffe5fc2)
- pin lgtm-ci to PR #1097 head c8a647e4 (1151009)
- pin lgtm-ci to PR #1097 head 940ae9fa (11c33ce)
- pin lgtm-ci to PR #1097 head ca7589df (214b2fc)
- record #849 after-fix results (lgtm-ci PR #1097 head 87da5a5c) (cd50d96)
- pin lgtm-ci to PR #1097 head 87da5a5c; add release-benign-hook.yml (#849 positive
  path) (53d8d63)
- pin lgtm-ci to main 269b3702 (PR #1094 merged) (f7f2aeb)
- pin lgtm-ci to PR #1094 head 16893be1 (b7e48b9)
- pin lgtm-ci to PR #1089 head 1c2238dc (19af381)
- pin lgtm-ci to PR #1089 head 15a9bc2e (da8703b)
- pin lgtm-ci to PR #1089 head 3c42a87e (6575d51)
- pin lgtm-ci to PR #1089 head 8937a3e1 (a019a0d)
- pin lgtm-ci to PR #1089 head 3aab4bfd (75520b2)
- pin lgtm-ci to PR #1089 head 27a9a8c8 (53a00ef)
- **egress**: pin egress.yml to lgtm-ci #1094 head 5e455002 (round-2 probe) (3b7b20e)
- **egress**: pin egress.yml to lgtm-ci #913 head 0db0533c (after-fix probe) (37d8cef)
- **egress**: add #913 preset probes (pypi allowed / github-tooling denied), pin
  egress.yml to lgtm-ci main 31750eca for baseline (b1dee7f)
- **app-token-probe**: make the negative reach check use a private sibling (731fa8d)
- pin lgtm-ci to PR #1089 head fab929f1 (rebased on 96eb7a71) (3b59367)
- add App token probe and release version-PR / tamper-hook fixtures (#1074, #849)
  (21699ba)

### Fixed

- **playwright**: also append storage.googleapis.com:443 (cdn.playwright.dev redirect,
  lgtm-hq/lgtm-ci#1103) (fd2a7c6)
- **playwright**: append azure.archive.ubuntu.com:80 to the playwright preset
  (lgtm-hq/lgtm-ci#1103) (52f949b)

## [0.1.0] - 2026-10-04

Baseline tag for the release-path fixtures.
