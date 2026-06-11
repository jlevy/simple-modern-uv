---
type: is
id: is-01ktw5n89v033k8ymvs6e7z4xe
title: Write references/adopt-existing.md (upgrade migration checklist)
kind: task
status: closed
priority: 1
version: 3
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies:
  - type: blocks
    target: is-01ktvwpx9g3z91m828d4bste53
parent_id: is-01ktw5mdvsbjarg7wwd3ctjxhe
created_at: 2026-06-11T20:23:27.803Z
updated_at: 2026-06-11T21:53:18.222Z
closed_at: 2026-06-11T21:53:18.222Z
close_reason: "adopt-existing.md: inference table, render-beside, merge checklist, Poetry/setuptools/mypy translations, versioning finish."
---
Flow 2 procedure: render template into temp dir with confirmed answers, then merge deliberately. Per-source translations: setuptools/pip, Poetry (caret specs -> PEP 621, tool.poetry.scripts -> project.scripts, dev deps -> dependency-groups), PDM/hatch; mypy -> basedpyright config. Preserve project deps/metadata; bring over devtools/, workflows, Makefile, docs stubs, AGENTS.md; write .copier-answers.yml with _commit so Flow 3 works; remove superseded files (poetry.lock, old CI). Surface the published-package Python-floor exception. Verification gate. See spec Flow 2 + D1.
