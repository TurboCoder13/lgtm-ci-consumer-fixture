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

## [0.2.0] - 2026-11-11

### Added

- Playwright fixture for lgtm-hq/lgtm-ci#804 (baseline at lgtm-ci main c74c9c36)
  (395ba51)
- PR-gated summary, retry convergence helper, negative permission test (#2) (a1073e2)

### Changed

- negative probes keep expected failures off the Actions page (lgtm-ci #1083) (ca1747f)
- record release-path and App token probe results (ba49d26)
- add CHANGELOG.md required by reusable-release-version-pr (74cd525)
- record perms-negative startup_failure and retry-convergence results (0b7445e)
- **canary**: pin release-benign-hook to lgtm-ci 0f913b0a (lgtm-hq/lgtm-ci#1448)
  (249a8c8)
- prove reusable-all-checks-gate and reusable-required-check from outside the org (#69)
  (bb97e33)
- **docker**: grant actions: read on callers of the SARIF-uploading reusables (#68)
  (7da09ba)
- **deps**: update pnpm to v12.16.1 (#43) (2bd6878)
- **deps**: update vitest monorepo to v5.1.0 (#61) (84ec466)
- **deps**: update dependency uuid to v14 (#50) (099db61)
- **deps**: update dependency @lhci/cli to ^0.16.0 (#65) (6773bf6)
- restore block egress policy (lgtm-ci#1207) (#55) (d1013b1)
- **deps**: update step-security/harden-runner action to v2.22.3 (#46) (d75795f)
- mitigate consumer canary egress hangs (#47) (fc4b58f)
- **deps**: update dependency ubuntu to v26 (#34) (e8830f8)
- **deps**: update lgtm-hq/lgtm-ci action to v0.78.0 (#29) (d879ee1)
- run actionlint over every workflow and allow ubuntu-26.04 labels (#40) (ab45208)
- **deps**: update step-security/harden-runner action to v2.22.2 (#39) (ab046e7)
- **deps**: update pnpm to v12.14.0 (#38) (56234eb)
- **deps**: update vitest monorepo to v5.0.5 (#37) (2944873)
- **deps**: update vitest monorepo to v5 (#36) (a5abd9e)
- **deps**: update pnpm to v12 (#35) (1f31751)
- **deps**: update actions/checkout action to v7 (#33) (dc9f269)
- **deps**: update step-security/harden-runner action to v2.22.1 (#32) (7f6cc49)
- **deps**: update astral-sh/setup-uv action to v10.3.0 (#28) (f18121d)
- **deps**: update alpine docker tag to v3.24 (#27) (68c1940)
- **deps**: update pnpm to v10.34.7 (#25) (fa276eb)
- **deps**: update actions/checkout action to v6.1.0 (#26) (dfb9200)
- **deps**: update actions/upload-artifact action to v7.0.2 (#24) (74b45c1)
- **deps**: update actions/download-artifact action to v8.0.2 (#22) (922921c)
- Add renovate.json (#1) (77bbfdf)
- re-pin every lgtm-ci reference to lgtm-ci v0.77.0 (eae062ce) (b4309eb)
- SARIF checks count only their own workflow's analyses (lgtm-ci #1150 review) (f634827)
- keep the lgtm-ci-pin marker out of the recover.yml comment (5844f59)
- release recovery end to end and recover facade negative (lgtm-ci #1081 merged as
  65f3fe15) (0396e53)
- docker-scan-failure probe expects both legs' failures (lgtm-ci #1081) (37e9d91)
- Docker multi-platform validate entry, facade paths, orchestrator, scan-failure probe
  and negative (lgtm-ci #1081 merged as 5479e741) (7b1964c)
- read-only Rust variant and Rust facade negative (lgtm-ci #1081 merged as 00a4db8b)
  (31c0ac3)
- fix the vuln-suppression pin to b69f3e5b (40-hex) (572fa7c)
- fix the vuln-suppression pin (typo in 6b12f5b; lgtm-ci b69f3e5b) (1170837)
- per-ref vuln-suppression cleanup group (lgtm-ci #1134 merged as b69f3e5b) (6b12f5b)
- read-only shell variant and shell facade negative (lgtm-ci #1081 merged as 52423571)
  (4897548)
- one read-only workflow per variant (readonly-node.yml); re-pin the #1081 Node
  workflows to lgtm-ci main 16aa956b (#1137 merged) (5c5f220)
- per-ref sbom-release-upload concurrency (lgtm-ci #1134) (7d04e11)
- read-only variant and Node facade negative (lgtm-ci #1081 merged as bdb2807f)
  (8194bf3)
- drop the #1103 egress append from the Playwright workflows so the bare preset is under
  test; re-pin every lgtm-ci reference to lgtm-ci main 249fc90b (#1130 merged) (fefea84)
- give the sibling calls distinct artifact-prefix values (be5135c)
- 3-run lighthouse audit asserting the representative report is scored (lgtm-ci #1088);
  re-pin every lgtm-ci reference to lgtm-ci main 0e866571 (#1131 merged) (e86e0c0)
- negative probe fails closed when the jobs lookup fails; fit the canary window
  (0488e5f)
- probe the negative-by-design workflows from outside (lgtm-ci #1083) (33caf8b)
- re-pin every lgtm-ci reference to lgtm-ci v0.76.0 (2134b700) (d8cc1b1)
- re-pin every lgtm-ci reference to lgtm-ci main 5185136b (#1125 merged: results.v1
  contract) (62509f9)
- re-pin every lgtm-ci reference to PR #1080 head 6e620635 (JUnit root/duration read
  without early-closing pipes) (6bdc6e8)
- re-pin every lgtm-ci reference to PR #1080 head f78a813e (kcov-safe strict-shell
  tests; no runner change) (454718e)
- re-pin every lgtm-ci reference (incl. the direct tooling checkout) to PR #1080 head
  0b7d990e; pin.sh learns the '# lgtm-ci-pin' ref marker (2a5354e)
- build-python-direct enforces the on-default-branch preflight only on main and tags
  (lgtm-ci 1074 canary branches) (9cf3692)
- **results-contract**: sparse-checkout the tooling the way the reusables do (schemas/,
  scripts/ci/) (e2c202e)
- re-pin every lgtm-ci reference to PR #1080 head cc4cd678 (rust results.v1 EXIT_CODE
  precedence fix) (d6c6a84)
- re-pin every lgtm-ci reference to PR #1080 head d0284c46; add results-contract.yml
  (validates every runner's results/**/results.json against schemas/results.v1.json,
  baseline-impossible on pre-#1080 main) (73f257e)
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

- **ci**: adopt corrected Python hardener graph (#62) (b308a87)
- **ci**: recover remaining LCOV coverage caller (#59) (339daa2)
- **ci**: finish failing caller recovery on released graph (#58) (dbef2da)
- **ci**: adopt released nested hardener recovery (#57) (04a9212)
- **lighthouse**: complete npm optional peer lock closure (#53) (d6d1526)
- **lint**: restore baseline while preserving negative probes (#48) (ee6c0a3)
- **playwright**: also append storage.googleapis.com:443 (cdn.playwright.dev redirect,
  lgtm-hq/lgtm-ci#1103) (fd2a7c6)
- **playwright**: append azure.archive.ubuntu.com:80 to the playwright preset
  (lgtm-hq/lgtm-ci#1103) (52f949b)

## [0.1.0] - 2026-10-04

Baseline tag for the release-path fixtures.
