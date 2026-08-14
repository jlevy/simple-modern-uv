---
type: is
id: is-01ktw5mdvsbjarg7wwd3ctjxhe
title: "Spec: agent skill and template modernization"
kind: epic
status: in_progress
priority: 1
version: 21
spec_path: docs/project/specs/active/plan-2026-06-11-agent-skill-and-modernization.md
labels: []
dependencies: []
child_order_hints:
  - is-01ktvwpvva6q89nba153t6g77b
  - is-01ktvwpw34avpgqc4rp4x48d0z
  - is-01ktvwpwav6vzazvhdphkf22ts
  - is-01ktvwpx9g3z91m828d4bste53
  - is-01ktvwpwjp0qdfgckaxk55fcvf
  - is-01ktvwpwta76b0zbrc6d334mnr
  - is-01ktvwpxgwfkzkn5jpxpaenwtm
  - is-01ktvwpx1zk1jxk9edwrtbayvb
  - is-01ktvwpxr8fzshynb4hwzk4xbd
  - is-01ktw5n89v033k8ymvs6e7z4xe
  - is-01ktw5n8hs0zvw91kjkzymgvzv
  - is-01ktw5n8st9wt374a388pn2h1f
  - is-01ktwbrpk0knshs4svakdk4a48
  - is-01ktwdgnj0a4fc2bwwb1szxwkw
  - is-01ktwdnahytshfemt9eff75ddg
  - is-01m00t7pv8w57wvxw0cze48gat
  - is-01m00x9vsnznk31rk0bw8z388c
created_at: 2026-06-11T20:23:00.715Z
updated_at: 2026-08-14T19:52:07.220Z
---
Umbrella for making simple-modern-uv directly usable by AI coding agents: an installable skill with three flows (new/upgrade/update), license+publish template options, AGENTS.md output, uvtemplate removal, repo CI, and version currency. See spec for full design, the two-tier interview contract, and the D2 answer-schema evolution rules.

## Notes

v0.3.0 RELEASED 2026-06-12 (tag on be2f938, https://github.com/jlevy/simple-modern-uv/releases/tag/v0.3.0). Gate: this repo's CI green on the release commit + local render verification + full-matrix validation on jlevy/test-smu-1 during review (downstream repo not reachable from this session). Remaining post-release: (1) downstream export + tag recording in simple-modern-uv-template (updating.md Steps 4-6, 8) from an environment with access; (2) skill activation smoke checks in target agents; (3) verify npx skills add end-to-end; (4) retire uvtemplate (smu-h0yd); (5) upstream gh-hook fix in get-tbd (smu-r17y). PR #26 documents the agent release path.
