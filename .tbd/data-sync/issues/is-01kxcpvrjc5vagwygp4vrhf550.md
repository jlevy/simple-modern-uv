---
type: is
id: is-01kxcpvrjc5vagwygp4vrhf550
title: Pin and harden GitHub Actions workflows
kind: task
status: closed
priority: 1
version: 5
labels:
  - release
  - supply-chain
dependencies:
  - type: blocks
    target: is-01kxcpvs0v5dszzegmqwyr4v23
  - type: blocks
    target: is-01kxcpvsemz4ejphjmxxz142nn
parent_id: is-01kxcpt82850vqz6sckrv6z4tr
created_at: 2026-07-13T03:03:21.419Z
updated_at: 2026-07-13T03:39:47.641Z
closed_at: 2026-07-13T03:39:47.640Z
close_reason: Pinned checkout v7.0.0 and setup-uv v8.2.0 to reviewed full SHAs, disabled credential persistence, supplied the official uv 0.11.25 Linux checksum, and validated rendered YAML in commit cb665bf.
---
Update every root and generated CI/publish workflow to the frozen eligible actions. Audit snapshot candidates: actions/checkout v7.0.0 at commit 9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 and astral-sh/setup-uv v8.2.0 at commit fac544c07dec837d0ccb6301d7b5580bf5edae39. Pin uses entries to full commit SHAs with version comments; checkout v7.0.0 is not an immutable GitHub release, so its mutable tag is not an adequate supply-chain pin. Confirm checkout v7 Node 24 compatibility with GitHub-hosted runners and review its fork-checkout protection. Add persist-credentials: false to checkouts that never push. Preserve least-privilege contents:read and the publish job OIDC permissions. Verify setup-uv still validates the selected uv artifact/checksum. Acceptance: all active actions are full-SHA pinned, workflow permissions and credential handling are reviewed, and root plus rendered workflows pass.
