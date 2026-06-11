---
type: is
id: is-01ktw5mdvsbjarg7wwd3ctjxhe
title: "Spec: agent skill and template modernization"
kind: epic
status: in_progress
priority: 1
version: 18
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
created_at: 2026-06-11T20:23:00.715Z
updated_at: 2026-06-11T23:08:37.731Z
---
Umbrella for making simple-modern-uv directly usable by AI coding agents: an installable skill with three flows (new/upgrade/update), license+publish template options, AGENTS.md output, uvtemplate removal, repo CI, and version currency. See spec for full design, the two-tier interview contract, and the D2 answer-schema evolution rules.

## Notes

In-repo work merged via PR #25 (2026-06-11). Remaining children are post-release follow-ups: retire uvtemplate after v0.3.0 ships and the skill is verified end-to-end; port the ensure-gh-cli.sh auth fix upstream into get-tbd. Release runbook: updating.md Steps 3-8 with NEW_TAG=v0.3.0; draft release notes are in the PR #25 body; run the skill activation smoke checks (updating.md) before tagging.
