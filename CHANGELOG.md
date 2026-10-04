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

## [0.2.0] - 2026-10-04

### Added

- PR-gated summary, retry convergence helper, negative permission test (#2) (a1073e2)

### Changed

- add CHANGELOG.md required by reusable-release-version-pr (74cd525)
- record perms-negative startup_failure and retry-convergence results (0b7445e)
- **app-token-probe**: make the negative reach check use a private sibling (731fa8d)
- pin lgtm-ci to PR #1089 head fab929f1 (rebased on 96eb7a71) (3b59367)
- add App token probe and release version-PR / tamper-hook fixtures (#1074, #849)
  (21699ba)

## [0.1.0] - 2026-10-04

Baseline tag for the release-path fixtures.
