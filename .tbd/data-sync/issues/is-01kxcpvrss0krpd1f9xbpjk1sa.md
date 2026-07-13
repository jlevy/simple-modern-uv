---
type: is
id: is-01kxcpvrss0krpd1f9xbpjk1sa
title: Enforce the cool-off on upgrade and executable-tool paths
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
created_at: 2026-07-13T03:03:21.656Z
updated_at: 2026-07-13T03:03:35.844Z
---
Close the gap between the documented 14-day policy and commands developers actually run. Make the generated Makefile upgrade path and documented uv add/lock/sync upgrade examples enforce UV_EXCLUDE_NEWER=14 days by safe default while retaining an explicit, documented override. Ensure pinned uvx Copier/Flowmark execution paths cannot silently resolve too-fresh transitive dependencies where the command is under repository control. Run npm skill validation with lifecycle scripts disabled if skills-ref does not require them. Review whether isolated uv build dependencies are reproduced from the lockfile; if not, add the smallest supported constraint or locked-build control without pinning downstream libraries unnecessarily. Add a vulnerability/advisory check to the release validation using existing uv audit if stable enough, otherwise a pinned eligible auditor or direct OSV check. Acceptance: normal install/upgrade/build/validation paths match the policy, lockfiles and hashes remain authoritative, and exceptions require an explicit opt-out rather than accidental omission.
