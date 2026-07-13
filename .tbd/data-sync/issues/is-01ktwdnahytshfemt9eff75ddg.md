---
type: is
id: is-01ktwdnahytshfemt9eff75ddg
title: "Upstream: ensure-gh-cli.sh auth check fix belongs in get-tbd"
kind: chore
status: open
priority: 2
version: 2
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies:
  - type: blocks
    target: is-01kxcsg0b3g1yxp8zgg5kp3g3x
parent_id: is-01ktw5mdvsbjarg7wwd3ctjxhe
created_at: 2026-06-11T22:43:18.718Z
updated_at: 2026-07-13T03:49:27.913Z
---
The gh auth check fix (trust gh auth status over GH_TOKEN presence; drop repo-specific doc link) is patched in this repo's generated copies but the script is a tbd setup artifact; the next tbd setup --auto would regenerate it. Port the fix into get-tbd so it ships in the next release. External repo.
