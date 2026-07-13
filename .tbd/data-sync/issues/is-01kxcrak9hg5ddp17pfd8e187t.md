---
type: is
id: is-01kxcrak9hg5ddp17pfd8e187t
title: Declare reviewed build-backend floors and verify locked builds
kind: task
status: open
priority: 1
version: 3
labels:
  - release
  - supply-chain
dependencies:
  - type: blocks
    target: is-01kxcpvs0v5dszzegmqwyr4v23
  - type: blocks
    target: is-01kxcpvsemz4ejphjmxxz142nn
parent_id: is-01kxcpt82850vqz6sckrv6z4tr
created_at: 2026-07-13T03:28:56.112Z
updated_at: 2026-07-13T03:29:00.594Z
---
Discovered during manifest review: template build-system requirements are unbounded even though release builds execute them in isolation. Add the smallest reviewed eligible floors, currently hatchling>=1.30.1 and uv-dynamic-versioning>=0.14.0, after confirming Python 3.11-3.14 compatibility. Verify how uv 0.11.25 records build requirements in uv.lock and whether uv build consumes the locked selection; add the smallest supported locked/constraint control if isolated builds can silently select a different backend. Do not adopt too-fresh Hatchling 1.31.0. Acceptance: the declared backend capability floor is explicit, fresh and update renders lock/build reproducibly under the cutoff, and downstream package metadata remains standards-compliant.
