---
type: is
id: is-01m01cvxdzy61gkc7gry11sbx3
title: Fix rendered Markdown canonical formatting for v0.5.0
kind: bug
status: closed
priority: 1
version: 2
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels:
  - release-blocker
dependencies: []
parent_id: is-01m01avy1m3gcswt9ssp6kf3v1
created_at: 2026-08-15T00:24:07.344Z
updated_at: 2026-08-15T00:29:07.762Z
closed_at: 2026-08-15T00:29:07.761Z
close_reason: "Fixed in PR #30: rendered AGENTS and development docs are Flowmark-canonical, every render variant checks rendered Markdown, local default/private/no-license validation passed, and exact main CI is green at 019733b."
---
The downstream v0.5.0 gate found that Jinja substitution makes rendered AGENTS.md and docs/development.md fail Flowmark even though their sources pass. Stabilize the prose and add rendered-doc CI coverage.
