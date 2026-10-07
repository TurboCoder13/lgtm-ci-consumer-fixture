# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.2.0] - 2026-10-07

### Added

- Playwright fixture for lgtm-hq/lgtm-ci#804 (baseline at lgtm-ci main c74c9c36)
  (395ba51)
- PR-gated summary, retry convergence helper, negative permission test (#2) (a1073e2)

### Changed

- record release-path and App token probe results (ba49d26)
- add CHANGELOG.md required by reusable-release-version-pr (74cd525)
- record perms-negative startup_failure and retry-convergence results (0b7445e)
- **1086/1092/1093**: pin lgtm-ci 89e402d8 (review follow-ups) (b8cd975)
- **1086/1092/1093**: after — pin lgtm-ci 7f23c340, fixed examples/nextest-ci.toml
  verbatim, no CHANGELOG.md, no PyPI allowlist (47bee4f)
- **1093**: baseline — CHANGELOG.md restored, still no PyPI allowlist (lgtm-ci main
  65db5132) (392060e)
- **1086/1092/1093**: baseline — verbatim examples/nextest-ci.toml, no CHANGELOG.md, no
  PyPI allowlist (lgtm-ci main 65db5132) (c84b5e6)
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

[Unreleased]: https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/TurboCoder13/lgtm-ci-consumer-fixture/compare/v0.1.0...v0.2.0
