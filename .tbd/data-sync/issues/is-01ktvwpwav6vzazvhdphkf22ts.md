---
type: is
id: is-01ktvwpwav6vzazvhdphkf22ts
title: Add package_license and publish_to_pypi copier options
kind: feature
status: open
priority: 1
version: 4
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies:
  - type: blocks
    target: is-01ktvwpx9g3z91m828d4bste53
parent_id: is-01ktw5mdvsbjarg7wwd3ctjxhe
created_at: 2026-06-11T17:47:03.899Z
updated_at: 2026-06-11T20:23:45.501Z
---
Phase 2: package_license choice and publish_to_pypi bool gating publish.yml, docs/publishing.md, Private :: Do Not Upload classifier, badges. Must follow D2 answer-schema evolution rules: behavior-preserving defaults (MIT + publish=true = today's output, so vanilla copier update --defaults is a no-op), old answer files stay valid, release-notes callout. Also sharpen copier.yml package_name guidance to recommend kebab-case. See spec D2.
