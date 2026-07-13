---
type: is
id: is-01kxcpvr3qsagvyc7q3me5r4an
title: Update uv and Copier pins across template, CI, and skill
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
created_at: 2026-07-13T03:03:20.950Z
updated_at: 2026-07-13T03:03:35.292Z
---
Apply the frozen eligible uv and Copier versions consistently. Audit snapshot candidates are uv 0.11.25 (from 0.11.17) and Copier 9.16.0 (from 9.15.1). Update root CI UV_VERSION and setup-uv inputs, generated CI and publish workflow uv pins, COPIER_SPEC, AGENTS.md smoke commands, and every simple-modern-uv skill/reference command. Review the full upstream delta, not only the last patch: uv 0.11.25 includes tar parser hardening; Copier 9.16.0 changes remote template caching/worktrees and preservation of template-managed gitignored files, so both fresh copy and update behavior require explicit validation. Keep required-version >=0.9 unless a reviewed feature requires a higher compatibility floor. Acceptance: no stale executable uv/Copier pins remain, all occurrences agree, and targeted copy/update smoke tests pass under the cool-off.
