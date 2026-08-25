---
type: is
id: is-01m0wydjcxee8z9x2f2c9ct2s9
title: "Upstream: make tbd fallback dependency resolution reproducible"
kind: chore
status: open
priority: 2
version: 1
labels:
  - tooling
  - upstream
dependencies: []
created_at: 2026-08-25T17:10:21.339Z
updated_at: 2026-08-25T17:10:21.339Z
---
The 2026-08-25 get-tbd 0.8.0 upgrade was a user-requested first-party cool-off exception. Its managed npx fallback pins get-tbd itself but resolves an unlocked transitive graph; the audit selected third-party ansi-regex 6.3.0 inside the 14-day window. The local global install constrains ansi-regex to eligible 6.2.2, but fresh fallback executions cannot preserve that decision. Update get-tbd packaging or its fallback launcher so a package-scoped direct exception does not float unrelated transitives, and document a verifiable upgrade procedure.
