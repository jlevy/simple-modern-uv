---
type: is
id: is-01m01bgmd54dwx43w7wjyfpn1c
title: "PR #29 I2: explain old uv duration parse errors"
kind: task
status: closed
priority: 2
version: 2
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels:
  - pr-review
dependencies: []
parent_id: is-01m01bg0pby4hhtjcgy9xg31a8
created_at: 2026-08-15T00:00:29.092Z
updated_at: 2026-08-15T00:06:25.478Z
closed_at: 2026-08-15T00:06:25.477Z
close_reason: "Fixed: FAQ now explains that uv before 0.9.17 can reject the 14 days duration before required-version is reported."
---
Document that uv versions before friendly duration support can fail while parsing 14 days before they can emit the required-version message.
