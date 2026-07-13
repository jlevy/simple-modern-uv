---
type: is
id: is-01kxcpvragdw05p0m1scqj1587
title: Raise eligible generated-project dependency floors
kind: task
status: open
priority: 1
version: 3
labels:
  - release
  - dependencies
dependencies:
  - type: blocks
    target: is-01kxcpvs0v5dszzegmqwyr4v23
  - type: blocks
    target: is-01kxcpvsemz4ejphjmxxz142nn
parent_id: is-01kxcpt82850vqz6sckrv6z4tr
created_at: 2026-07-13T03:03:21.168Z
updated_at: 2026-07-13T03:03:35.478Z
---
Update template/pyproject.toml.jinja to the frozen eligible lower bounds. Audit snapshot candidates are pytest 9.1.1 (from 9.0.3), Ruff 0.15.20 (from 0.15.15), and basedpyright 1.39.9 (from 1.39.6). Leave pytest-sugar 1.1.1, codespell 2.4.2, Rich 15.0.0, and funlog 0.2.1 unchanged because they are already current. Review all intervening release notes and resulting diagnostics; regenerate a render lockfile under UV_EXCLUDE_NEWER, inspect the full direct/transitive lock diff, confirm no yanked or too-fresh artifacts, and make only compatibility fixes required by lint/type/test results. Acceptance: a fresh render resolves at or above the new floors without crossing the frozen cutoff and passes lint, type checking, tests, and build.
