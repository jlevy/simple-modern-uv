---
type: is
id: is-01kxcpvs7t756y74zpp43p2rwv
title: Refresh repository-only tbd bootstrap to eligible 0.3.0
kind: chore
status: open
priority: 2
version: 2
labels:
  - release
  - tooling
dependencies:
  - type: blocks
    target: is-01kxcpvsemz4ejphjmxxz142nn
parent_id: is-01kxcpt82850vqz6sckrv6z4tr
created_at: 2026-07-13T03:03:22.105Z
updated_at: 2026-07-13T03:03:36.215Z
---
The fetched repository bootstrap scripts still invoke get-tbd 0.2.3 while npm 0.3.0 is eligible (published 2026-06-15) and 0.4.0 is too fresh at the audit cutoff. Review the 0.2.3-to-0.3.0 package/source delta and run the setup flow explicitly with the frozen eligible version, never the ambient 0.4.0 CLI. Inspect all generated .tbd, .agents, .claude, and .codex diffs and keep this in a separate commit because it does not affect rendered projects. Preserve the existing ensure-gh-cli auth fix or coordinate with smu-r17y so regeneration does not reintroduce it. If 0.3.0 creates broad unrelated churn, document and defer it outside v0.4.0 instead of mixing it into the template change. Acceptance: either a reviewed focused 0.3.0 bootstrap update lands and passes repository checks, or the epic records a concrete defer rationale and follow-up bead; get-tbd 0.4.0 is not adopted before eligibility.
