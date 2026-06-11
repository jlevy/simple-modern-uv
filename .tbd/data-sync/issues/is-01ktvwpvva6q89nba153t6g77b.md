---
type: is
id: is-01ktvwpvva6q89nba153t6g77b
title: Write skills/simple-modern-uv/SKILL.md (interview contract + 3 flows)
kind: feature
status: open
priority: 1
version: 7
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies:
  - type: blocks
    target: is-01ktvwpw34avpgqc4rp4x48d0z
  - type: blocks
    target: is-01ktvwpx9g3z91m828d4bste53
parent_id: is-01ktw5mdvsbjarg7wwd3ctjxhe
created_at: 2026-06-11T17:47:03.402Z
updated_at: 2026-06-11T20:23:11.413Z
---
Phase 1 core: the routing skill. Standard frontmatter (name=simple-modern-uv, two-part description, license, allowed-tools). Body carries the two-tier interview contract (essentials: kebab-case package/PyPI/repo name + derived snake_case module shown, description, license default MIT, publish default yes; conventions applied silently: src/ layout, v0.1.0 tag, 3.11+ floor) and routes the three flows. Route-don't-restate: point at uvx copier --help and template docs, pinned uvx copier@<ver> invocations, names raw GitHub URLs for zero-install. Body <500 lines; bulk in references/. See spec User Flows + D1.
