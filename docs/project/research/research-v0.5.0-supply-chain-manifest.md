# Research: v0.5.0 Supply-Chain Manifest

**Frozen:** 2026-08-14T18:59:05Z

**Eligibility cutoff:** 2026-07-31T18:59:05Z (14 days)

**Status:** Frozen for the v0.5.0 candidate

## Scope and Decision Rule

This manifest freezes a focused uv and pipeline currency update.
Implementation does not chase releases published after the freeze.
A version is eligible only when its first non-yanked artifact was published on or before
the cutoff, its canonical source and intervening release notes are reviewable, and known
advisories have been assessed.
The candidate is numbered v0.5.0 because the portable lock policy adds `uv.toml` to the
rendered project; no template question or application-facing package behavior changes.

The audit covers template inputs, generated-project development and build dependencies,
repository-only executable tools, active GitHub Actions, and their relevant source
deltas. The generated project retains `exclude-newer = "14 days"` in a checked-in
`uv.toml` and commits `uv.lock`; direct-package checks do not approve changed transitive
packages by implication.

## Frozen Python and Tool Candidates

| Component | Prior declaration | Frozen decision | Published (UTC) | Source and rationale |
| --- | --- | --- | --- | --- |
| uv | 0.11.25 | **Update to [0.12.0](https://github.com/astral-sh/uv/releases/tag/0.12.0)** | 2026-07-28 | Newest eligible official Astral release; security and validation hardening with no generated-project migration |
| Copier | 9.16.0 | **Update to [9.17.0](https://github.com/copier-org/copier/releases/tag/v9.17.0)** | 2026-07-13 | Fixes an encoded-URL trust bypass; fresh-copy and update-path tests are required |
| Flowmark | 0.3.1 | **Update to [0.3.2](https://github.com/jlevy/flowmark-rs/releases/tag/v0.3.2)** | 2026-07-15 | Current eligible canonical release; formatter behavior is covered by `make format-check` |
| pytest | >=9.1.1 | Keep >=9.1.1 | 2026-06-19 | Already latest |
| pytest-sugar | >=1.1.1 | Keep >=1.1.1 | 2025-08-23 | Already latest |
| Ruff | >=0.15.20 | **Raise to [>=0.16.1](https://github.com/astral-sh/ruff/releases/tag/0.16.1)** | 2026-07-30 | New default rules and Markdown formatting reviewed; explicit template rule selection isolates the lint default, with render linting as the compatibility gate |
| codespell | >=2.4.2 | **Raise to [>=2.4.3](https://github.com/codespell-project/codespell/releases/tag/v2.4.3)** | 2026-07-15 | Packaging fix, new ignore controls, and dictionary maintenance |
| Rich | >=15.0.0 | Keep >=15.0.0 | 2026-04-12 | Already latest |
| basedpyright | >=1.39.9 | Keep >=1.39.9 | 2026-06-27 | 1.39.10 is after the cutoff |
| funlog | >=0.2.1 | Keep >=0.2.1 | 2025-03-28 | Already latest |
| Hatchling | 1.30.1 | **Pin [1.31.0](https://github.com/pypa/hatch/releases/tag/hatchling-v1.31.0)** | 2026-07-08 | Prevents non-Python shared scripts from being truncated during wheel construction |
| uv-dynamic-versioning | 0.14.0 | Keep 0.14.0 | 2026-03-22 | Already latest; Hatchling remains necessary for tag-driven versions |
| skills installer | 1.5.13 | **Update to [1.5.18](https://github.com/vercel-labs/skills/releases/tag/v1.5.18)** | 2026-07-16 | Includes unsafe-transport, shell-spawn, private-repository, and install-layout fixes while retaining Node >=18 support |
| skills-ref | 0.1.5 | Keep 0.1.5 | 2025-12-27 | Already latest |
| get-tbd | 0.2.3 bootstrap | Defer eligible 0.4.2 | 2026-07-30 | Repository-agent migration is separately tracked by `smu-i8xh` and is outside this focused template refresh |

The newest eligible skills release is 1.5.21, but 1.5.19 raised its runtime floor from
Node 18 to Node 22.20. Version 1.5.18 captures the preceding security and correctness
fixes without narrowing the documented agent compatibility.
Python remains 3.11 through 3.14; Python 3.15 is still prerelease.

## Frozen GitHub Actions

| Action | Frozen version | Full commit | Release state | Decision |
| --- | --- | --- | --- | --- |
| `actions/checkout` | [v7.0.1](https://github.com/actions/checkout/releases/tag/v7.0.1) | `3d3c42e5aac5ba805825da76410c181273ba90b1` | Not immutable | Full-SHA pin protects the non-immutable tag; patch adds safer PR-input, branch-whitespace, and Git-config value handling |
| `astral-sh/setup-uv` | [v9.0.0](https://github.com/astral-sh/setup-uv/releases/tag/v9.0.0) | `c771a70e6277c0a99b617c7a806ffedaca235ff9` | Immutable | Adopt the reviewed major release and make its cache-retention choice explicit |

setup-uv v9 changes `prune-cache` from true to false.
Generated CI explicitly keeps the new behavior because retaining downloaded wheels
reduces repeated PyPI traffic.
The privileged release workflow instead disables shared caching: its job is infrequent,
and eliminating cache restore/save reduces cache-poisoning exposure.
Repository jobs that do not benefit materially from a shared uv cache also disable it.

setup-uv v9’s built-in checksum table ends before uv 0.12.0. Linux workflows therefore
provide the official `uv-x86_64-unknown-linux-gnu` SHA-256 directly:
`eaf842262aa1c418d8ecc5605f02ee1ebfd369124fa48548e85f9481a47831a9`. The downloaded
release archive matched that checksum, and its GitHub artifact attestation verified
against `astral-sh/uv`.

## Provenance and Advisory Results

- OSV queries returned no advisories for any selected direct Python or npm version.
- The selected Copier and Hatchling distributions publish PyPI provenance.
  uv and Ruff publish GitHub artifact attestations; both selected Linux archives passed
  their official SHA-256 checks and `gh attestation verify`.
- Reviewed PyPI source-distribution SHA-256 values include uv 0.12.0
  (`80ba22cae467c6f47d2157ec2b840c032cac709b85ab1300ac4dcfeb29986462`), Copier 9.17.0
  (`d966b043a15c74595f7904a6af89f3291135682f8313c4b71ef368811ed554f2`), Flowmark 0.3.2
  (`d7d05b06ad2cef2b123cafe8b05e2545d29f474d455a26ab824fcdf0b5b557e2`), Ruff 0.16.1
  (`fedad7c801dabd3fb9741d76aca39246e6ddd9ca446a015875207bf19f1e6bc7`), codespell 2.4.3
  (`cbe085e331227b37bb86ef8bddd08dc768c704ee9a07ca869852c093fa2793e2`), and Hatchling
  1.31.0 (`6b48ad4068a482ed7239b3a8215bc55b47aad3345d58dfc94e553c5d2d46211b`).
- The reviewed npm registry integrity for `skills@1.5.18` is
  `sha512-WwQuqIhmS2nrn1H3HAbE2tGe7e2npc1cwMcucMKqmkBdqzm7nxzcZBTqXiHjUKhpalQLE/nNPtEdcx3QYX4TTw==`;
  npm provenance is present.
  The existing `skills-ref@0.1.5` integrity remains recorded in the v0.4.0 manifest.
- `npm audit --omit=dev` reports five high-severity dependency families in setup-uv
  v9.0.0’s bundled production graph.
  The same families are present in the prior v8.2.0 pin and still appear in v10.0.1;
  there is no eligible action release that removes them.
  They concern glob, XML, and HTTP-library behaviors rather than a known setup-uv
  exploit. Full-SHA pinning, trusted workflow inputs, disabled publish caching, and
  continued upstream tracking bound the exposure without taking a same-day major release
  exception.

## Explicit Deferrals

The following releases were younger than the cutoff and are excluded without exception:

- uv 0.12.1 through 0.12.4; 0.12.1 missed the cutoff by about 44 minutes
- Copier 9.17.1, Ruff 0.16.2 and 0.16.3, basedpyright 1.39.10, and Hatchling 1.32.0
- setup-uv v10.0.0 and v10.0.1

No preview uv command becomes a generated CI dependency.
`uv audit`, `uv check`, and `uv format` continue as release-time or watch-list
capabilities. The project keeps Hatchling rather than moving to `uv_build`, because its
tag-derived dynamic versioning is part of the template’s release model.

## Pipeline Decisions and Validation Gates

Generated CI and publishing change from `uv sync --frozen` to `uv sync --locked`.
`--locked` still installs from the committed lock but also fails when project metadata
would make that lock stale; `--frozen` intentionally skips this validation.

uv merges project-, user-, and system-level configuration by default, including mapping
settings such as `exclude-newer-package`, and records resolution settings in `uv.lock`.
A lock created with this machine’s intentional first-party exceptions therefore failed
`--locked` on a clean runner even though the dependency metadata was current.
The template moves its uv settings to `uv.toml`; the Makefile and workflows select that
file with `UV_CONFIG_FILE`, which official uv semantics define as exclusive of
discovered user and system configuration.
Project-specific indexes and resolution settings remain supported by checking them into
`uv.toml`.

Local validation produced these outcomes:

1. The v0.4.0 and candidate locks each contain 25 packages.
   Hatchling 1.30.1 to 1.31.0 is the only resolved-version change; the Ruff and
   codespell floor changes already matched the versions selected by the frozen v0.4.0
   graph.
2. `uv audit --locked` reports no known vulnerabilities or adverse project statuses in
   the 24 third-party packages.
3. Fresh default, no-publish/proprietary, and no-license renders have the expected file,
   license, classifier, and workflow shapes.
4. The Python 3.12 default render installs, passes codespell/Ruff/BasedPyright and
   pytest, and builds its sdist and wheel through the locked non-isolated Hatchling
   path.
5. `uv sync --locked` rejects an intentionally stale `pyproject.toml` with the expected
   lockfile-update error.
6. A lock produced with an explicitly selected `uv.toml` passes `--locked` under both
   this machine’s user configuration and an empty user configuration; neither ambient
   configuration appears in the lock.
7. A Copier 9.17.0 update from v0.4.0 has no rejects, converges with a fresh candidate
   render, and honors an explicit `publish_to_pypi=false` override.

Candidate acceptance requires every template-repository CI job, including the full
Python 3.11–3.14 matrix, to pass before merge.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
