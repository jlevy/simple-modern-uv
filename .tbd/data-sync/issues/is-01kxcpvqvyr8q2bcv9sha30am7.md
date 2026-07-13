---
type: is
id: is-01kxcpvqvyr8q2bcv9sha30am7
title: Freeze the v0.4.0 eligible update manifest
kind: task
status: open
priority: 1
version: 6
labels:
  - release
  - supply-chain
dependencies:
  - type: blocks
    target: is-01kxcpvr3qsagvyc7q3me5r4an
  - type: blocks
    target: is-01kxcpvragdw05p0m1scqj1587
  - type: blocks
    target: is-01kxcpvrjc5vagwygp4vrhf550
  - type: blocks
    target: is-01kxcpvrss0krpd1f9xbpjk1sa
  - type: blocks
    target: is-01kxcpvs7t756y74zpp43p2rwv
parent_id: is-01kxcpt82850vqz6sckrv6z4tr
created_at: 2026-07-13T03:03:20.701Z
updated_at: 2026-07-13T03:03:34.295Z
---
Start the release branch from the fetched origin/main tip, not the stale local main. At implementation start, record one exact UTC audit time and its 14-day cutoff, recalculate the newest stable eligible version for every direct Python dependency, build backend, uv, Copier, Flowmark, npm-executed tool, tbd bootstrap, and GitHub Action, then freeze that manifest for the release. For every changed item, verify canonical upstream ownership, release notes and source delta, release age, non-yanked status, artifact hashes or attestations where available, immutable release or commit SHA status, and OSV/GitHub advisory results. Record unchanged and explicitly deferred items too. No item younger than 14 days may enter the branch without a user-approved emergency exception. Acceptance: a reviewable manifest/commit records versions, dates, sources, provenance status, advisory result, and include/defer rationale; later beads use exactly the frozen set.
