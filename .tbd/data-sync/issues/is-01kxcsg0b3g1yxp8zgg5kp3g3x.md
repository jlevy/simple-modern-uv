---
type: is
id: is-01kxcsg0b3g1yxp8zgg5kp3g3x
title: Upgrade repository tbd bootstrap after the v0.4.0 template release
kind: chore
status: open
priority: 3
version: 1
labels:
  - tooling
  - follow-up
dependencies: []
created_at: 2026-07-13T03:49:21.889Z
updated_at: 2026-07-13T03:49:21.889Z
---
get-tbd 0.3.0 is old enough and its npm integrity was verified, but its v0.2.3-to-v0.3.0 source delta spans 142 files and introduces the f05/f06 config model, forkable docs, new docref/docmap formats, and broad regenerated .tbd/.agents/.claude/.codex artifacts. Keep that migration out of the focused template-currency release. After v0.4.0, resolve or incorporate smu-r17y so setup regeneration preserves the ensure-gh-cli auth fix, run the pinned 0.3.0 setup in a dedicated branch, review every generated artifact, and validate tbd status/doctor/sync plus repository CI. Re-evaluate the newest eligible get-tbd version at that later freeze; do not adopt a version younger than 14 days.
