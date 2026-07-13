---
type: is
id: is-01kxcpvsnc8vns1bvazrqd4ssv
title: Pass the downstream gate and publish v0.4.0
kind: task
status: closed
priority: 1
version: 3
labels:
  - release
dependencies: []
parent_id: is-01kxcpt82850vqz6sckrv6z4tr
created_at: 2026-07-13T03:03:22.538Z
updated_at: 2026-07-13T04:11:04.964Z
closed_at: 2026-07-13T04:11:04.963Z
close_reason: Released v0.4.0 from vetted commit 69266fb after template and downstream gates passed; downstream main now records v0.4.0.
---
Complete the release only after candidate validation. Export/update the long-lived jlevy/simple-modern-uv-template downstream project, review its Copier and uv.lock diffs, run local lint/test/build with the cool-off, push the downstream validation commit, and wait for the full Python matrix CI to finish successfully. Prepare release notes that list version updates, action SHA/hardening changes, safe-default supply-chain behavior, unchanged/deferred too-fresh releases, and any compatibility impact; no template question schema changes are expected. Confirm the template repo candidate CI is green, create and verify the v0.4.0 GitHub release/tag, then record the released tag in downstream .copier-answers.yml as documented. Acceptance: downstream and template CI are green, v0.4.0 is published from the reviewed commit, and post-release state is synchronized.
