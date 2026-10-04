# lgtm-ci consumer fixture

A deliberately external consumer of [lgtm-hq/lgtm-ci](https://github.com/lgtm-hq/lgtm-ci).
It lives outside the `lgtm-hq` org so nothing resolves by coincidence, calls
reusable workflows only through `uses: lgtm-hq/lgtm-ci/.github/workflows/<file>.yml@<sha>`,
passes **no `tooling-ref`**, and contains **no copied lgtm-ci actions or scripts**
(`scripts/check-no-vendoring.sh`). Tracked by lgtm-hq/lgtm-ci#1074.

| Workflow | Proves |
|---|---|
| `python.yml` | Python path at an exact SHA with no `tooling-ref` (#995, nested action resolution) |
| `node-bun.yml` / `node-npm.yml` | Node path per package manager; tooling source present next to caller source; lockfiles untouched (#1077) |
| `rust.yml` | Rust path; only the Rust toolchain installed |
| `siblings.yml` | Two calls in one run produce distinct artifact names (#752) |
| `egress.yml` | Explicit allowlist denies a probe to `example.com`; preset-only job documents #913 and is expected to fail until it lands |
| `perms.yml` | Documented-minimum caller permissions parse and run (#735/#736) |

## Pinning to a candidate

```sh
scripts/pin.sh <lgtm-ci-sha>   # rewrites every uses: line and prints the result
```

Commit and push to `main`, or dispatch each workflow by hand. Every workflow
runs on `workflow_dispatch` and on push to `main`.

## Baseline

The first run against lgtm-ci `main` is expected to fail; the run URLs are
recorded on lgtm-hq/lgtm-ci#1074 so that later fixes have a before/after.
