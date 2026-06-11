---
type: is
id: is-01ktvwpwav6vzazvhdphkf22ts
title: Add package_license and publish_to_pypi copier options
kind: feature
status: closed
priority: 1
version: 6
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies:
  - type: blocks
    target: is-01ktvwpx9g3z91m828d4bste53
parent_id: is-01ktw5mdvsbjarg7wwd3ctjxhe
created_at: 2026-06-11T17:47:03.899Z
updated_at: 2026-06-11T21:46:09.299Z
closed_at: 2026-06-11T21:46:09.289Z
close_reason: "Implemented: package_license (MIT/Apache-2.0/BSD-3-Clause/Proprietary) + publish_to_pypi options with conditional LICENSE/publish.yml/publishing.md, Private classifier, kebab-case guidance. Verified: all 4 license renders correct; default render byte-identical to pre-change output (D2 rule 1); formatter-stable Jinja whitespace control; both variants pass sync/lint/test."
---
Phase 2: package_license choice and publish_to_pypi bool gating publish.yml, docs/publishing.md, Private :: Do Not Upload classifier, badges. Must follow D2 answer-schema evolution rules: behavior-preserving defaults (MIT + publish=true = today's output, so vanilla copier update --defaults is a no-op), old answer files stay valid, release-notes callout. Also sharpen copier.yml package_name guidance to recommend kebab-case. See spec D2.
