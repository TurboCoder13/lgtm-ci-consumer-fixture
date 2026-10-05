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

## [0.2.0] - 2026-10-05

### Added

- PR-gated summary, retry convergence helper, negative permission test (#2) (a1073e2)

### Changed

- record release-path and App token probe results (ba49d26)
- add CHANGELOG.md required by reusable-release-version-pr (74cd525)
- record perms-negative startup_failure and retry-convergence results (0b7445e)
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

## [0.1.0] - 2026-10-04

Baseline tag for the release-path fixtures.
