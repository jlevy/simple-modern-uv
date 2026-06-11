---
type: is
id: is-01ktvwpx9g3z91m828d4bste53
title: "Add CI to template repo: render smoke tests + skill validation"
kind: feature
status: closed
priority: 1
version: 6
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies:
  - type: blocks
    target: is-01ktvwpxgwfkzkn5jpxpaenwtm
parent_id: is-01ktw5mdvsbjarg7wwd3ctjxhe
created_at: 2026-06-11T17:47:04.880Z
updated_at: 2026-06-11T21:57:31.499Z
closed_at: 2026-06-11T21:57:31.498Z
close_reason: "ci.yml added: format-check, render-test matrix (default + no-publish-proprietary with output assertions + full sync/lint/test/build), update-path job (verified locally: v0.2.27 -> HEAD converges to fresh render with 0 conflicts; --data publish_to_pypi=false override removes publish.yml + adds Private classifier), skill-validate (skills-ref + link check, both pass locally)."
---
Phase 3: ci.yml renders default + proprietary/no-publish variants; runs sync/lint-check/pytest/build on default render with UV_EXCLUDE_NEWER; update-path test (render at previous release tag, copier update --defaults to candidate, assert vanilla no-op + --data overrides honored); validates skill with skills-ref; make format-check. See spec D5 + D2 rule 4.
