# Research: v0.4.0 Supply-Chain Manifest

**Frozen:** 2026-07-13T03:27:33Z

**Eligibility cutoff:** 2026-06-29T03:27:33Z (14 days)

**Status:** Frozen for the v0.4.0 release

## Scope and Decision Rule

This manifest freezes the dependency and executable-tool candidates for v0.4.0.
Implementation must not chase releases published after the freeze.
A version is eligible only when its first non-yanked artifact was published on or before
the cutoff, its canonical source and release notes are reviewable, and no known advisory
blocks it.

The audit covers the template inputs, generated-project development and build
dependencies, repository-only tools, and active GitHub Actions.
It does not approve transitive packages by implication; the rendered `uv.lock` diff is
reviewed separately.

## Frozen Python and Tool Candidates

| Component | Current declaration | Frozen decision | Published (UTC) | Source and rationale |
| --- | --- | --- | --- | --- |
| uv | 0.11.17 | **Update to [0.11.25](https://github.com/astral-sh/uv/releases/tag/0.11.25)** | 2026-06-27 | Official Astral release; includes tar parser-differential hardening and attested GitHub release assets |
| Copier | 9.15.1 | **Update to [9.16.0](https://github.com/copier-org/copier/releases/tag/v9.16.0)** | 2026-06-23 | Official Copier release; remote-cache/worktree and gitignored-file update behavior needs copy/update validation |
| Flowmark | 0.3.1 | Keep 0.3.1 | 2026-05-30 | Canonical `jlevy/flowmark-rs`; already latest |
| pytest | >=9.0.3 | **Raise to [>=9.1.1](https://github.com/pytest-dev/pytest/releases/tag/9.1.1)** | 2026-06-19 | Official pytest release; PyPI provenance present |
| pytest-sugar | >=1.1.1 | Keep >=1.1.1 | 2025-08-23 | Already latest |
| Ruff | >=0.15.15 | **Raise to [>=0.15.20](https://github.com/astral-sh/ruff/releases/tag/0.15.20)** | 2026-06-25 | Official Astral release with attested GitHub release assets |
| codespell | >=2.4.2 | Keep >=2.4.2 | 2026-03-05 | Already latest |
| Rich | >=15.0.0 | Keep >=15.0.0 | 2026-04-12 | Already latest |
| basedpyright | >=1.39.6 | **Raise to [>=1.39.9](https://github.com/DetachHead/basedpyright/releases/tag/v1.39.9)** | 2026-06-27 | Canonical DetachHead release; immutable GitHub release |
| funlog | >=0.2.1 | Keep >=0.2.1 | 2025-03-28 | Canonical `jlevy/funlog`; already latest |
| Hatchling | unbounded build requirement | **Pin 1.30.1** | 2026-06-02 | Official PyPA backend; 1.31.0 is too fresh |
| uv-dynamic-versioning | unbounded build requirement | **Pin 0.14.0** | 2026-03-22 | Canonical ninoseki project; already latest |
| skills-ref | 0.1.5 | Keep 0.1.5 | 2025-12-27 | Exact npm package and integrity are pinned; already latest |
| get-tbd | 0.2.3 | Evaluate 0.3.0 separately | 2026-06-15 | Repository-only bootstrap; npm integrity verified before execution |

The Python compatibility matrix remains 3.11 through 3.14. Python 3.15 is pre-release
and is not added to classifiers or CI.

## Frozen GitHub Actions

| Action | Frozen version | Full commit | Release state | Decision |
| --- | --- | --- | --- | --- |
| `actions/checkout` | [v7.0.0](https://github.com/actions/checkout/releases/tag/v7.0.0) | `9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0` | Not immutable | Pin the full commit SHA; verify Node 24 runner compatibility and disable persisted credentials |
| `astral-sh/setup-uv` | [v8.2.0](https://github.com/astral-sh/setup-uv/releases/tag/v8.2.0) | `fac544c07dec837d0ccb6301d7b5580bf5edae39` | Immutable | Pin the full commit SHA and continue pinning the uv version independently |

Full commit pins are used for both actions so workflow review has one consistent rule.
The generated publish workflow retains only `contents: read` and `id-token: write`; CI
workflows retain `contents: read`.

`uv build` does not consume `uv.lock` for its isolated build environment.
The template therefore declares exact reviewed build-system versions, mirrors them in a
`build` dependency group, syncs that group from `uv.lock`, and builds with
`--no-build-isolation`. This makes the locked environment, rather than a second resolver
run, authoritative for release artifacts.

## Provenance and Advisory Results

- OSV batch queries returned no advisories for the frozen direct versions of uv, Copier,
  pytest, Ruff, basedpyright, skills-ref, or get-tbd.
- PyPI provenance was present for the Copier 9.16.0 and pytest 9.1.1 source
  distributions. PyPI did not expose provenance for the audited uv, Ruff, or basedpyright
  source distributions.
  uv and Ruff publish GitHub artifact attestations; basedpyright provides an immutable
  GitHub release and PyPI SHA-256 digests.
- The npm registry integrity values were recorded before any execution:
  `skills-ref@0.1.5` is
  `sha512-C2vyZbUQqt3PXA9vcdUmJ0lwbH9jK19C9fwQjl/ICPy2e5bzV3CaropViakJCv+HLt/9zsgjZ/NLJ5xEri0jSA==`;
  `get-tbd@0.3.0` is
  `sha512-2N6MB1nSKIJK0Frnw+y4k8tiYNItNF0P7Ne4TaOyz1Mp6NTWTNqRooqYsHxwdyKLhU2FVM/TJek/NGT97joo4w==`.
- These direct checks do not replace inspection of the generated `uv.lock`, artifact
  hashes, or an advisory scan of the complete resolved graph.

## Explicit Deferrals

The following releases were younger than the cutoff and are excluded without exception:

- uv 0.11.26 through 0.11.28
- Ruff 0.15.21
- setup-uv v8.3.1 and v8.3.2
- Hatchling 1.31.0
- get-tbd 0.4.0

`uv audit` remains preview functionality in this uv series.
It may be used as an additional release-time check, but this release does not make a
preview command a generated-project CI contract.

## Validation Gates

1. Inspect all direct and transitive changes in a freshly rendered `uv.lock`.
2. Reject yanked, post-cutoff, unexpected-source, or unexplained packages.
3. Run advisory checks for the complete lock graph.
4. Exercise fresh copy and v0.3.0-to-candidate update paths with Copier 9.16.0.
5. Run lint, type checking, tests, and builds on Python 3.11 through 3.14.
6. Require template-repository CI and the long-lived downstream release gate to pass.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
