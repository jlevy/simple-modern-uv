---
type: is
id: is-01ktw5n8st9wt374a388pn2h1f
title: Write references/faq.md (common migration problems)
kind: task
status: closed
priority: 2
version: 3
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies:
  - type: blocks
    target: is-01ktvwpx9g3z91m828d4bste53
parent_id: is-01ktw5mdvsbjarg7wwd3ctjxhe
created_at: 2026-06-11T20:23:28.314Z
updated_at: 2026-06-11T21:53:18.786Z
closed_at: 2026-06-11T21:53:18.785Z
close_reason: faq.md seeded with 10 real failure modes incl. git-tag versioning, basedpyright eruption, copier update conflicts, resurrected-publish.yml fix.
---
Troubleshooting layer for the upgrade flow. Seed: dynamic version resolving to 0.0.0 (no git tag; first tag must exceed published PyPI version), flat->src/ layout moves, requires-python floor conflicts, basedpyright erupting on legacy code (relaxed toggles, ratchet later; existing type: ignore still works), Poetry caret-spec conversion + poetry.lock/old-CI cleanup, codespell on legacy prose (ignore-words-list), uv sync Python-version failures (uv python install, .python-version). Grows from real reports. See spec D1.
