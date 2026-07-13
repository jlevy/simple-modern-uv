---
type: is
id: is-01kxcpvs0v5dszzegmqwyr4v23
title: Refresh uv research and release-maintenance guidance
kind: task
status: closed
priority: 2
version: 4
labels:
  - release
  - documentation
dependencies:
  - type: blocks
    target: is-01kxcpvsemz4ejphjmxxz142nn
parent_id: is-01kxcpt82850vqz6sckrv6z4tr
created_at: 2026-07-13T03:03:21.882Z
updated_at: 2026-07-13T03:51:39.308Z
closed_at: 2026-07-13T03:51:39.308Z
close_reason: Updated the uv research, reproducible eligibility inventory, action/checksum rules, safe release commands, and v0.4.0 guidance in commit 87ef50f.
---
Update docs/project/research/research-uv-changes.md and updating.md after final implementation decisions. Record the frozen latest/eligible uv data and relevant 0.11.18-0.11.25 changes, especially uv audit status, malware checks, tar-handling security hardening, lock/build behavior, and any explicit non-adoption. Replace the inaccurate blanket claim that exact GitHub Action version tags are immutable with commit-SHA or verified immutable-release guidance. Improve the version-check recipe so it identifies the newest stable release older than the exact 14-day cutoff rather than merely printing latest. Document unchanged/deferred versions and the no-Python-3.15 decision. Format all Markdown with make format and verify with make format-check. Acceptance: maintenance instructions can reproduce this release audit and do not overstate any supply-chain guarantee.
