---
type: is
id: is-01kxcpvsemz4ejphjmxxz142nn
title: Run complete fresh-render and v0.3.0 update validation
kind: task
status: open
priority: 1
version: 2
labels:
  - release
  - validation
dependencies:
  - type: blocks
    target: is-01kxcpvsnc8vns1bvazrqd4ssv
parent_id: is-01kxcpt82850vqz6sckrv6z4tr
created_at: 2026-07-13T03:03:22.323Z
updated_at: 2026-07-13T03:03:36.407Z
---
Validate the assembled candidate end to end. Run make format-check; render default, no-publish/proprietary, and no-license variants with the frozen Copier; initialize git and generate uv.lock under the cool-off; inspect the lock and advisory results; run uv sync, devtools/lint.py --check, pytest, and uv build. Exercise Python 3.11, 3.12, 3.13, and 3.14 through CI. Render from v0.3.0 and run copier update to the candidate, assert no rejects, verify convergence with a fresh render apart from Copier bookkeeping, and verify explicit newer-question overrides. Validate skill structure/links and smoke-test skill activation if skill text changed. Acceptance: all local checks and every root CI job pass with no suppressed or unexplained failures, and artifacts contain the intended pins and hardening settings.
