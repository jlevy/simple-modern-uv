---
type: is
id: is-01ktwdgnj0a4fc2bwwb1szxwkw
title: "Address PR #25 review findings (4 items)"
kind: task
status: closed
priority: 1
version: 2
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies: []
parent_id: is-01ktw5mdvsbjarg7wwd3ctjxhe
created_at: 2026-06-11T22:40:46.144Z
updated_at: 2026-06-11T22:43:19.352Z
closed_at: 2026-06-11T22:43:19.352Z
close_reason: "All four findings fixed and verified: commit-then-sync sequence (version 0.0.1.dev1 confirmed, CI guard added), gh hook auth check (tested: reports authenticated), pins (skills-ref@0.1.5, copier@9.15.1, checkout@v6.0.2), README answer-based license/publish flow."
---
P1: setup sequence syncs before first commit -> editable install stuck at 0.0.0 (fix order in SKILL.md, README, copier.yml message; align CI + add version assertion; FAQ note). P2: ensure-gh-cli.sh false-warns on keyring auth + dead doc link (fix both copies; upstream fix needed in get-tbd). P2: unpinned skills-ref@latest, uvx copier in AGENTS.md, floating checkout@v6 (pin all per stated policy). P3: README hand-edit license/publish paragraph contradicts new answers (replace with answer flow + customize.md link).
