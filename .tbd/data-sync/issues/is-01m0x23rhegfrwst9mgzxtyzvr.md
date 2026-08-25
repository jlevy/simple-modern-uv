---
type: is
id: is-01m0x23rhegfrwst9mgzxtyzvr
title: "Upstream: make supply-chain cool-off policy threat-model based"
kind: chore
status: open
priority: 2
version: 2
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies: []
parent_id: is-01ktw5mdvsbjarg7wwd3ctjxhe
created_at: 2026-08-25T18:14:54.241Z
updated_at: 2026-08-25T18:33:27.155Z
---
Follow up in jlevy/supply-chain-hardening and its tbd-managed copy: describe 14 days as a balanced default against newly compromised or broken releases rather than an absolute trust rule; replace unsupported or categorical claims; document persistent uv exclude-newer-package cutoffs and explicit UV_CONFIG_FILE selection so locked CI matches approved first-party or urgent exceptions and user config cannot contaminate the lock; qualify first-party-code advice for security-sensitive or complex components; state audit and attestation limits; and distinguish release-only invocation from actual tag or reviewer authority. Link the Repren migration review and PR #31 threat-model findings.
