---
type: is
id: is-01ktvwpx9g3z91m828d4bste53
title: "Add CI to template repo: render smoke tests + skill validation"
kind: feature
status: open
priority: 1
version: 3
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies:
  - type: blocks
    target: is-01ktvwpxgwfkzkn5jpxpaenwtm
created_at: 2026-06-11T17:47:04.880Z
updated_at: 2026-06-11T20:00:26.064Z
---
Phase 3: ci.yml renders default + proprietary/no-publish variants; runs sync/lint-check/pytest/build on default render with UV_EXCLUDE_NEWER; update-path test (render at previous release tag, copier update --defaults to candidate, assert vanilla no-op + --data overrides honored); validates skill with skills-ref; make format-check. See spec D5 + D2 rule 4.
