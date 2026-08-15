---
type: is
id: is-01m01bgncqn5pk2xr6r8tqtcwk
title: "PR #29 I5: retire UV_NO_CONFIG workarounds on update"
kind: task
status: closed
priority: 2
version: 2
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels:
  - pr-review
dependencies: []
parent_id: is-01m01bg0pby4hhtjcgy9xg31a8
created_at: 2026-08-15T00:00:30.102Z
updated_at: 2026-08-15T00:06:26.180Z
closed_at: 2026-08-15T00:06:26.179Z
close_reason: "Fixed: the template-update workflow now removes legacy UV_NO_CONFIG workarounds once uv.toml and explicit UV_CONFIG_FILE settings are present."
---
Tell updating agents to remove obsolete UV_NO_CONFIG workarounds after adopting the project uv.toml policy.
