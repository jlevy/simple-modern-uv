---
type: is
id: is-01m0wwg9b7yn7bgfy10m76t907
title: Upgrade tbd integration to 0.8.0 and f08
kind: chore
status: closed
priority: 2
version: 3
labels: []
dependencies: []
parent_id: is-01m0wwfed4bz9kk0xdver2ewyw
created_at: 2026-08-25T16:36:53.211Z
updated_at: 2026-08-25T17:13:52.381Z
closed_at: 2026-08-25T17:13:52.380Z
close_reason: Repository integration upgraded to get-tbd 0.8.0/f08 and tbd doctor passes. The generator-clean auth diagnostic follow-up remains tracked by smu-r17y; reproducible fallback dependency resolution is tracked by smu-ifum.
resolution: null
duplicate_of: null
---
Refresh all managed tbd surfaces and validate the f08 migration.

## Notes

tbd 0.8.0 is a user-requested first-party exception to the normal cool-off. The audited 68-package global graph initially selected too-recent ansi-regex 6.3.0; it is constrained to eligible 6.2.2. tbd doctor is healthy. The generated gh helper still required the existing repo-specific auth fix tracked by smu-r17y.
