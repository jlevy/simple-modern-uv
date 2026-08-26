# Research: v0.6.0 Supply-Chain Manifest

**Frozen:** 2026-08-25T17:11:47Z (candidate commit `c9f954e`)

**Eligibility cutoff:** 2026-08-11T17:11:47Z (14 days)

**Status:** Frozen for the v0.6.0 candidate

## Scope and Decision Rule

This manifest freezes a publishing- and migration-hardening cycle: the release workflow
splits into unprivileged validation, a locked build-only job, and a minimal OIDC
publisher; the generated project gains an explicit sdist allowlist and stricter
fresh-project lint and type defaults; and direct-to-target Copier updates become the
documented default.

A version is eligible only when its first non-yanked artifact was published on or before
the cutoff, its canonical source and intervening release notes are reviewable, and known
advisories have been assessed.
The candidate is numbered v0.6.0 because the rendered publish workflow changes shape and
the generated project’s lint and type defaults change behavior for existing projects; no
template question is added or changed.

Generated-project Python dependency floors are unchanged this cycle.
The only moving Python input is the pinned uv toolchain; the remaining changes are
workflow structure, packaging metadata, tool configuration, and documentation.

## Frozen Python and Tool Candidates

| Component | Prior declaration | Frozen decision | Published (UTC) | Source and rationale |
| --- | --- | --- | --- | --- |
| uv | 0.12.0 | **Update to [0.12.3](https://github.com/astral-sh/uv/releases/tag/0.12.3)** | 2026-08-07T16:32:18Z | Newest eligible official Astral release at the cutoff; no generated-project migration. The template’s `required-version = ">=0.12.0,<0.13"` is unchanged |
| Copier | 9.17.0 | Keep 9.17.0 | 2026-07-13 | Unchanged from v0.5.0 |
| Flowmark | 0.3.2 | Keep 0.3.2 | 2026-07-15 | Unchanged from v0.5.0 |
| Generated-project dev dependencies | v0.5.0 floors | Keep all floors | — | No floor moves this cycle; lock resolution still applies the cool-off and `--locked` CI verifies the recorded policy |
| Hatchling / uv-dynamic-versioning | 1.31.0 / 0.14.0 | Keep both | — | Build backend pins unchanged; the `build` dependency group still mirrors `[build-system].requires` |

The reviewed uv 0.12.3 `uv-x86_64-unknown-linux-gnu` SHA-256 is
`600cf9a742aca00d292673b16b5acffaa7b8c269a364ad0c2e79498dcb1fe101`, checked against the
official `uv-x86_64-unknown-linux-gnu.tar.gz.sha256` published with the release; that
value is the `checksum:` input passed to setup-uv in generated CI, generated
`publish.yml`, and this repository’s own CI. The PyPI source distribution for uv 0.12.3
is `1eb3fea456aea47489d92e10451c9129b7dd9fd8854c4eb17020ba68489d5d9a`. Python remains
3.11 through 3.14.

## Frozen GitHub Actions

Every tag below was resolved to its commit with `git ls-remote` at the freeze and
matches the pin recorded in the workflows.

| Action | Frozen version | Full commit | Change this cycle | Decision |
| --- | --- | --- | --- | --- |
| `actions/checkout` | v7.0.1 | `3d3c42e5aac5ba805825da76410c181273ba90b1` | Unchanged | Carried from v0.5.0; the tag is not immutable, so the full-SHA pin is the control |
| `astral-sh/setup-uv` | v9.0.0 | `c771a70e6277c0a99b617c7a806ffedaca235ff9` | Unchanged | Carried from v0.5.0; caching stays disabled in the privileged release workflow |
| `actions/upload-artifact` | v7.0.1 | `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | **Newly pinned** | Required by the build/publish split, which hands distributions between jobs |
| `actions/download-artifact` | v8.0.1 | `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c` | **Newly pinned** | Same-run download only; it authenticates with the Actions runtime token, not `GITHUB_TOKEN` |

## Release-Age Exceptions

Both exceptions are first-party packages requested for this cycle, and neither is a
template input or a generated-project dependency: they are repository- and
downstream-validation tooling only.
The global 14-day gate stays in force.

| Package | Version | Published (UTC) | Registry integrity | Role |
| --- | --- | --- | --- | --- |
| npm `get-tbd` | 0.8.0 | 2026-08-23T04:51:35Z | `sha512-6i19hRD2o/F5BPpksejvkS7NzefZ6iQmIRR4C38Gp+6SGAemK0WyksdkXetuBjXepO888lS5Xcn8PcIMXQYwSQ==`, provenance present | This repository’s own issue tracking and agent integration (`.tbd/`, format f08) |
| npm `tryscript` | 0.2.1 | 2026-08-22T19:45:24Z | Recorded downstream, not re-checked here | Session testing in the downstream migration validation, not in this repository |

No uv exception was needed: 0.12.3 clears the window on its own, so `uv.toml` carries
only the commented `exclude-newer-package` example, not an active override.
When an exception is needed, record it as an absolute package-scoped cutoff in `uv.toml`
and resolve only that package with
`UV_CONFIG_FILE="$PWD/uv.toml" uv lock --upgrade-package <name>`.

## Explicit Deferrals

The following releases were younger than the cutoff or otherwise excluded:

- uv 0.12.4 (2026-08-13T21:13:42Z) and 0.12.5 (2026-08-14T19:55:51Z), both after the
  cutoff
- `astral-sh/setup-uv` v10.0.0 and v10.0.1, deferred since v0.5.0 and still not adopted
- PEP 740 attestations, which would mean replacing `uv publish` with
  `pypa/gh-action-pypi-publish`. This is the next control that materially strengthens
  the pipeline, because it binds the artifact to the workflow that produced it.
  It is deferred rather than declined, and needs a reviewed full-SHA pin for that action

## Pipeline Decisions and Validation Gates

The release workflow splits into three jobs.
`validate` and `build` each hold only `contents: read`; `publish` holds only
`id-token: write`, declares `environment: pypi`, and performs no checkout.
`workflow_dispatch` is removed, so the workflow runs only on a published GitHub Release.

What that boundary does and does not buy is recorded in `docs/publishing.md`: `publish`
uploads whatever `build` produced.
Anyone who can execute code in `build` — a compromised entry in the `build` dependency
group, a build hook — still controls the published artifact; they cannot exfiltrate a
credential that publishes other projects.
Credential isolation, same-run artifact integrity, provenance, and code trust are
separate properties.

Two assumptions ride on the zero-scope publisher, and a real release is a bad place to
discover them: that setup-uv installs an exactly pinned uv without a GitHub API call,
and that a same-run artifact download works without `actions: read`. Reading setup-uv
v9.0.0 confirms the first (an exact version short-circuits version resolution, and the
download is served from the Astral mirror).
The repository’s `publish-preflight` CI job now exercises both under `permissions: {}`,
which is strictly tighter than the rendered job.

The `publish` job prints `sha256sum dist/*` before upload, so a release can be matched
against the file hashes PyPI shows for it.
Distribution artifacts are retained for 7 days, so re-running a failed `publish` the
next day still finds them.

Validation for this cycle:

1. Default, private/no-publish, and no-license renders have the expected file, license,
   classifier, and workflow shapes, and their rendered Markdown passes `format-check`.
2. The rendered `publish.yml` is checked structurally, against parsed YAML rather than
   line counts: job list and gating order, per-job permissions, the `pypi` environment,
   the absence of any trigger other than a published release, and the absence of a
   checkout in `publish`.
3. The default render installs, lints, type-checks, tests, and builds, and its sdist
   excludes `.github/`, agent integrations, `AGENTS.md`, `CLAUDE.md`, and `uv.lock`.
4. A build-group-only environment (`uv sync --locked --only-group build`) builds both a
   wheel and an sdist, which is what catches `[build-system].requires` drifting from the
   `build` group.
5. Direct updates from the previous release, v0.4.0, and v0.2.20 converge to a fresh
   render of the candidate, and a customized fixture preserves local docs and lint
   policy across the long-range update.
6. The customized fixture also carries code that the tightened defaults now reject (a
   module-level import after code, an unqualified `# pyright: ignore`). CI asserts that
   the update makes `make lint` fail, naming those rules, and that fixing the flagged
   code clears it, so the break is deliberate rather than discovered downstream.
7. `publish-preflight` installs the pinned uv and downloads a same-run artifact under
   `permissions: {}`, which is what the rendered publish job depends on.

Downstream migration evidence for this candidate is recorded in the candidate PR and in
the downstream repository; it is not restated here.

Candidate acceptance requires every template-repository CI job to pass before merge, and
the downstream repository remains the release gate when it is reachable.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
