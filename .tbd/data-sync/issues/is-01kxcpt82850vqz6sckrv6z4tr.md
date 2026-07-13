---
type: is
id: is-01kxcpt82850vqz6sckrv6z4tr
title: "Release v0.4.0: focused template currency and supply-chain refresh"
kind: epic
status: closed
priority: 1
version: 13
labels:
  - release
  - supply-chain
dependencies: []
child_order_hints:
  - is-01kxcpvqvyr8q2bcv9sha30am7
  - is-01kxcpvr3qsagvyc7q3me5r4an
  - is-01kxcpvragdw05p0m1scqj1587
  - is-01kxcpvrjc5vagwygp4vrhf550
  - is-01kxcpvrss0krpd1f9xbpjk1sa
  - is-01kxcpvs0v5dszzegmqwyr4v23
  - is-01kxcpvs7t756y74zpp43p2rwv
  - is-01kxcpvsemz4ejphjmxxz142nn
  - is-01kxcpvsnc8vns1bvazrqd4ssv
  - is-01kxcrak9hg5ddp17pfd8e187t
created_at: 2026-07-13T03:02:31.751Z
updated_at: 2026-07-13T04:11:05.136Z
closed_at: 2026-07-13T04:11:05.135Z
close_reason: Completed the focused v0.4.0 template refresh, supply-chain review, validation, downstream gate, release, and final tag recording.
---
Prepare a focused v0.4.0 minor release from the fetched origin/main baseline (7cfdb33 at audit time) so newly rendered projects use current, eligible tooling and safer defaults. Freeze candidates once at implementation start using an exact UTC timestamp and reject any release younger than 14 days; do not chase releases published after that freeze. Audit snapshot at 2026-07-13T02:58Z, cutoff 2026-06-29T02:58Z: uv 0.11.25, Copier 9.16.0, pytest 9.1.1, Ruff 0.15.20, basedpyright 1.39.9, actions/checkout v7.0.0, and astral-sh/setup-uv v8.2.0 are eligible. Flowmark 0.3.1, pytest-sugar 1.1.1, codespell 2.4.2, Rich 15.0.0, funlog 0.2.1, uv-dynamic-versioning 0.14.0, skills-ref 0.1.5, and the Python 3.11-3.14 matrix are already current. Explicitly exclude too-fresh uv 0.11.26-0.11.28, Ruff 0.15.21, setup-uv v8.3.x, hatchling 1.31.0, and get-tbd 0.4.0 unless a later implementation-start freeze makes them eligible and they pass the same review. Scope is version currency, directly related hardening, validation, and release documentation; no template redesign or tool migration. Completion requires clean fresh renders, v0.3.0 update-path compatibility, full CI, downstream release-gate validation, and a published v0.4.0 release.
