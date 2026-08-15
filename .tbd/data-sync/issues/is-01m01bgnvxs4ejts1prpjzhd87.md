---
type: is
id: is-01m01bgnvxs4ejts1prpjzhd87
title: "PR #29 S1: guard gh run list commit support"
kind: task
status: closed
priority: 2
version: 2
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels:
  - pr-review
dependencies: []
parent_id: is-01m01bg0pby4hhtjcgy9xg31a8
created_at: 2026-08-15T00:00:30.589Z
updated_at: 2026-08-15T00:06:26.401Z
closed_at: 2026-08-15T00:06:26.401Z
close_reason: "Fixed: the release runbook now checks for gh run list --commit support before release work begins."
---
Make the release workflow fail early when the installed GitHub CLI lacks gh run list --commit support.
