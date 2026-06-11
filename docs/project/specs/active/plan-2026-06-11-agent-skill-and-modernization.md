# Feature: Agent Skill and Template Modernization

**Date:** 2026-06-11 (last updated 2026-06-11)

**Author:** Joshua Levy (with agent assistance)

**Status:** Draft

## Overview

Make simple-modern-uv directly usable by AI coding agents.
The centerpiece is a single installable **agent skill** that any of the standard skill
channels can deliver into any agent environment, letting a user say one sentence
("upgrade this repo to modern uv best practices") and have the agent do the rest: create
a new project from the template, convert an existing Python package to follow the
template, or pull the latest template updates into an already-templated project —
including customizations like changing the license or making the package private and
unpublished.

Alongside the skill, modernize the template itself: re-introduce agent instructions
(`AGENTS.md`, now a stable cross-agent standard), add first-class template options for
the two customizations agents most need (license and publish-to-PyPI), demote the
interactive `uvtemplate` path, add CI to this repo so template changes are validated on
every PR, and refresh tool versions.
A summary of uv’s evolution since this template was created (March 2025) is in
[Appendix A](#appendix-a-uv-changes-since-march-2025) with the resulting action items.

## Goals

- **One-paste install**: a user can paste a single command or prompt into any agent
  environment (Claude Code, Codex, Cursor, Gemini CLI, …) and get a working
  simple-modern-uv skill.
- **Three workflows in one skill**: new project, adopt an existing (non-template) Python
  package, and update an already-templated project — all fully non-interactive, driven
  by the agent.
- **First-class customization**: license selection and published/private packaging are
  template options (not post-render hand edits), so `copier update` stays coherent.
- **Validated template**: this repo gets CI that renders the template and runs the full
  lint/test/build cycle, plus skill validation, on every PR.
- **Currency**: uv pin, dependency floors, and the basedpyright research doc are
  refreshed; uv changes since the template’s creation are summarized with action items.

## Non-Goals

- No new CLI tool and no MCP server.
  Copier already supports the non-interactive operation agents need
  (`copier copy --defaults --data k=v`, verified against this template); a wrapper CLI
  would duplicate it.
- No self-installing machinery (no managed `AGENTS.md` blocks, no hooks, no format
  versioning). The skill is a plain folder of Markdown — “L1” on the integration ladder
  in `tbd guidelines cli-agent-skill-patterns`.
- No expansion of template scope (still no Docker, docs sites, monorepos, or non-GitHub
  CI).
- Migration tooling for exotic legacy setups (conda, setup.py with C extensions) — the
  adopt workflow targets the common cases (setuptools/pip, Poetry, PDM, hatch).

## Background

Three things changed since this template was built (March 2025):

1. **Agents do the interactive part now.** The `uvx uvtemplate` interactive walkthrough
   (questionary prompts) made sense for humans at a terminal; today the typical user
   asks an agent, and the agent needs non-interactive, scriptable steps.
   Copier itself provides those (`--defaults`, `--data`, `--vcs-ref`), so the
   interactive wrapper is no longer the right front door.

2. **Skills and AGENTS.md became open standards.** Agent Skills (`SKILL.md`) is an open
   standard (agentskills.io, created by Anthropic, implemented by 20+ agents), and
   `AGENTS.md` is stewarded by the Linux Foundation’s Agentic AI Foundation and read
   natively by Codex, Cursor, Copilot, Gemini CLI, and others.
   This template removed its agent rules in early 2025 because the formats were
   churning; that reason no longer holds.
   Distribution also standardized: `npx skills add owner/repo` (Vercel’s skills.sh, the
   de facto cross-agent installer) installs any `skills/<name>/SKILL.md` from a public
   GitHub repo into 50+ agents, and GitHub-scraping indexers list such repos
   automatically.

3. **The template’s own guidance is now upstream knowledge.** tbd’s
   `python-modern-guidelines` cites simple-modern-uv as the reference model for Python
   releasing. The skill closes the loop: the template becomes directly executable
   knowledge for any agent, not just prose.

A verification note: rendering this template fully non-interactively was tested locally
(`uvx copier@9.15.1 copy --defaults --data package_name=… --data …`) and produces a
complete project including the derived `package_module`. The agent path needs no new
tooling.

## Design

### D1. One agent skill at `skills/simple-modern-uv/SKILL.md`

A single skill folder, committed at the repo root in the universal discovery location:

```
skills/
└── simple-modern-uv/
    ├── SKILL.md              # routing layer: workflows, commands, when to use
    └── references/
        ├── adopt-existing.md # checklist: convert an existing package to the template
        └── customize.md      # license, private/unpublished, other post-render tweaks
```

Design rules (per `tbd guidelines cli-agent-skill-patterns`):

- **Frontmatter**: standard fields only (`name`, `description`, `license`,
  `compatibility`, `metadata`) plus `allowed-tools` for portability across agents.
  `name: simple-modern-uv` (must match the directory name).
  The `description` follows the two-part rule — what it does plus explicit triggers
  ("Use when creating a new Python project, modernizing or migrating an existing Python
  package to uv, converting from Poetry/setuptools/pip, or updating a project built from
  simple-modern-uv").
- **Route, don’t restate**: the skill names each workflow and the exact command that
  reaches it. `copier.yml` remains the single source of truth for template questions; the
  skill points at `uvx copier@<pinned> copy --help` and the template’s own docs rather
  than transcribing them.
  Body stays well under 500 lines; bulky checklists live in `references/`, one level
  deep.
- **Pinned invocations**: every command in the skill pins versions
  (`uvx copier@<X.Y.Z> copy gh:jlevy/simple-modern-uv …`), per the supply-chain rule
  that unpinned `uvx`/`npx` re-resolves to latest and bypasses any cool-off window.
- **Self-contained when fetched raw**: the skill works when installed as a folder
  (relative `references/` links) and also names the raw GitHub URLs, so a user can
  bootstrap by pasting a prompt that points at the raw `SKILL.md` with no installer at
  all.

The three workflows the skill routes:

1. **New project**:
   `uvx copier@<ver> copy --defaults --data package_name=… --data … gh:jlevy/simple-modern-uv <dir>`,
   then the git init/commit/push steps the template already prints, then customization
   (D2 options or `references/customize.md`). The agent gathers the answers from the
   user’s request (or asks once), instead of an interactive prompt session.
2. **Adopt an existing package** (the biggest win): guided by
   `references/adopt-existing.md`. The approach is agent-native: render the template
   into a sibling temp directory with answers matching the existing project, then merge
   deliberately — adopt the template’s `pyproject.toml` structure (preserving the
   project’s dependencies and metadata), bring over `devtools/lint.py`, workflows,
   `Makefile`, docs stubs, and `.copier-answers.yml` (recording `_commit` so future
   `copier update` works), translate Poetry/setuptools/PDM config to uv equivalents,
   then run `uv sync`, lint, and tests to verify.
   The checklist enumerates the per-source translations (Poetry dep specs → PEP 621,
   `tool.poetry.scripts` → `project.scripts`, dev deps → `dependency-groups`, etc.)
   and the verification gate.
3. **Update a templated project**: `uvx copier@<ver> update --defaults --vcs-ref=<tag>`
   in a clean working tree, resolve any conflict markers, re-run lint/tests.
   Works for projects created by any of the historical paths, since all record
   `.copier-answers.yml`.

Customization (license change, private/no-publish, app-vs-library) is reachable from all
three workflows via `references/customize.md` plus the D2 template options.

### D2. Template options for license and publishing

Two new copier questions (and only these two, preserving minimalism):

- `package_license`: choice — `MIT` (default), `Apache-2.0`, `BSD-3-Clause`,
  `Proprietary (not open source)`. Drives the `LICENSE` file content and the `license`
  field/classifiers in `pyproject.toml`.
- `publish_to_pypi`: bool, default true.
  When false: `.github/workflows/publish.yml` and `docs/publishing.md` are excluded from
  the render, `pyproject.toml` gets the `Private :: Do Not Upload` classifier
  (uncommented), and PyPI-specific README/badge content is omitted.

Rationale: these must be template options rather than skill-guided post-render edits
because `copier update` re-renders excluded-by-hand files — a deleted `publish.yml`
would resurface on the next update.
Conditional rendering keeps updates coherent.
Both questions have safe defaults so existing projects and `--defaults` renders are
unaffected; on `copier update`, existing projects keep current behavior without
re-answering.

### D3. `AGENTS.md` in the template output

The template ships a concise `AGENTS.md` (~40–60 lines) in generated projects: uv
workflow commands (`uv sync --all-extras`, `make lint`, `make test`, `uv run pytest`),
src-layout conventions, lint/type-check expectations, and pointers into
`docs/development.md`. A short note covers the `CLAUDE.md` symlink pattern for Claude
Code users (which doesn’t auto-read `AGENTS.md`), without shipping a `CLAUDE.md` —
symlinks in templates behave poorly across platforms.
Unconditional (deletable), like the other starter docs.
This reverses the early-2025 removal of agent rules, justified by the format’s
standardization (see Background).

### D4. Demote and deprecate `uvtemplate`

The README’s “How to Use This Template” becomes agent-first:

- **Option 1 (new): use your agent.** A copy-paste block:
  `npx skills add jlevy/simple-modern-uv` followed by a one-line prompt, plus a
  no-installer variant (paste a prompt pointing at the raw `SKILL.md` URL).
- **Option 2: copier by hand** (unchanged, for humans who want the terminal).
- **Option 3: GitHub template repo** (unchanged).
- `uvx uvtemplate` moves to a short “legacy interactive option” mention.
  The uvtemplate package itself gets a deprecation note in its own repo (separate,
  out-of-scope task tracked as a follow-up) — it keeps working, but this repo stops
  featuring it, and all tooling consolidates here.
  No non-interactive revamp of uvtemplate: copier already is the non-interactive engine,
  and a second wrapper would be permanent duplicate surface area.

### D5. CI for this repo (render smoke test + skill validation)

This repo currently has no CI; validation is manual via the downstream
`simple-modern-uv-template` repo (release gate, per `updating.md`). Add a `ci.yml` to
this repo that on every push/PR:

1. Renders the template with `copier copy --defaults` (plus a second render with
   non-default options: proprietary license, `publish_to_pypi=false`) into temp dirs.
2. In the default render: `uv sync --all-extras`,
   `uv run python devtools/lint.py --check`, `uv run pytest`, `uv build` (with
   `UV_EXCLUDE_NEWER` set, matching template CI).
3. Validates the skill: `npx skills-ref validate skills/simple-modern-uv` plus a check
   that every `references/` file and relative link resolves.
4. Runs `make format-check` so doc formatting is enforced.

The downstream repo remains the release gate for tagged releases; this CI makes PRs
self-validating. `updating.md` is updated to reflect the new split.

### D6. Version currency

- Bump the uv pin in `template/.github/workflows/ci.yml` and `publish.yml` from 0.11.12
  to the newest version that clears the 14-day cool-off at implementation time (0.11.x
  series; 0.11.20 was released 2026-06-10 and is too fresh as of this writing).
- Review dev-dependency floors (`ruff`, `basedpyright`, `pytest`, etc.)
  the same way — floors are `>=`, so this is routine; the cool-off applies to what CI
  resolves, via `UV_EXCLUDE_NEWER`.
- Check `astral-sh/setup-uv` for a newer immutable tag.
- Appendix A’s action items capture anything structural uv has added that the template
  should adopt or explicitly decline.

### D7. basedpyright stays; refresh the research doc

Per `docs/project/research/research-python-type-checkers.md` (updated 2026-06-01),
BasedPyright remains the default: it inherits Pyright’s ~98% typing-spec conformance
while ty is still beta and materially behind.
Work here is a light refresh: re-check conformance numbers and ty/Pyrefly status, bump
the basedpyright floor past 1.39.x as the cool-off allows, and re-review the
commented-out rule toggles in `pyproject.toml.jinja` against current basedpyright
defaults. No checker switch.

## Implementation Plan

### Phase 1: The skill and its docs

- [ ] Write `skills/simple-modern-uv/SKILL.md` (frontmatter per D1; three workflows;
  route-don’t-restate)
- [ ] Write `references/adopt-existing.md` (render-and-merge checklist with per-source
  translations: setuptools/pip, Poetry, PDM/hatch; verification gate)
- [ ] Write `references/customize.md` (license, private/unpublished, entry points,
  app-vs-library notes)
- [ ] Test activation per the guideline: positive/negative prompts, explicit invocation,
  and a real end-to-end run of each workflow in a scratch repo
- [ ] README: new agent-first “Option 1” with the paste-able install block and prompt;
  demote uvtemplate to a legacy mention (D4)

### Phase 2: Template changes

- [ ] Add `package_license` and `publish_to_pypi` copier questions; conditional
  `LICENSE`, `publish.yml`, `docs/publishing.md`, classifier and README content (D2)
- [ ] Add `AGENTS.md` to the template output (D3)
- [ ] Bump uv pin, dependency floors, and `setup-uv` tag per cool-off (D6)
- [ ] Refresh basedpyright config comments and the type-checker research doc (D7)
- [ ] Validate via the downstream repo flow in `updating.md`

### Phase 3: Repo CI and maintenance docs

- [ ] Add `.github/workflows/ci.yml` to this repo: default + non-default renders,
  lint/test/build on the render, skill validation, `make format-check` (D5)
- [ ] Update `updating.md`: PR validation now automatic; downstream repo remains the
  release gate; add the skill to the release checklist
- [ ] Add the uv-changes research doc (`docs/project/research/research-uv-changes.md`)
  as a living doc seeded from Appendix A
- [ ] Follow-up (outside this repo): deprecation note on jlevy/uvtemplate

## Testing Strategy

- **Template renders**: CI renders both the default and the proprietary/no-publish
  variants and runs the full `sync → lint --check → pytest → build` cycle on the default
  render (Phase 3 makes this automatic; until then, run manually as in `updating.md`
  Step 5).
- **Skill validation**: `npx skills-ref validate` in CI; link/reference resolution
  check.
- **Skill behavior**: manual end-to-end runs of all three workflows with a real agent
  (new project; adopt a small Poetry project; `copier update` on the downstream repo),
  plus activation testing (should-trigger and should-not-trigger prompts).
- **Release gate unchanged**: downstream `simple-modern-uv-template` CI must pass before
  any release tag, per `updating.md`.

## Rollout Plan

1. Land Phases 1–3 on this repo (skill is immediately installable from `main` once
   merged — `npx skills add` tracks the repo).
2. Run the `updating.md` release flow: export to the downstream repo, wait for CI, then
   tag a release.
3. After the release: verify `npx skills add jlevy/simple-modern-uv` end-to-end from a
   clean environment, then add the deprecation note to uvtemplate.
4. Optional later: submit to the Anthropic community plugin marketplace
   (`clau.de/plugin-directory-submission`) for reviewed, security-screened
   discoverability inside Claude Code.
   Not required for any of the install paths above; decide after the skill has
   stabilized.

## Open Questions

- **uvtemplate end state**: this plan demotes it to a legacy mention and adds a
  deprecation note upstream, keeping the package functional.
  Full archival of the uvtemplate repo is the author’s call once the skill has proven
  itself.
- **Claude plugin marketplace**: ship `.claude-plugin/marketplace.json` now, or wait?
  Recommendation: wait — repo-local installs and `npx skills add` need no manifest, and
  the community-marketplace submission (rollout step 4) is the higher-trust channel if
  we want in-Claude discovery later.
- **Skill name**: `simple-modern-uv` (matches repo, required to match its directory).
  Alternative trigger-richer names (e.g. `modern-python-project`) were considered; the
  description carries the triggers, so the repo-matching name wins for recognizability.

## Appendix A: uv Changes Since March 2025

When this template was created (March 2025), uv was on 0.6.x. As of 2026-06-11 the
latest is **0.11.20** (released 2026-06-10). Notable changes by series, focused on what
matters to this template (compiled from release notes and the Astral blog; to be
maintained as a living doc in `docs/project/research/research-uv-changes.md` per Phase
3):

- **0.6.x (Feb–Apr 2025)**: `uv publish` stabilized out of preview (the template’s
  publish flow rests on this).
  Lockfile gained a `revision` field.
  Stricter validation of extras/groups.
- **0.7.x (Apr–Jul 2025)**: `uv version` redesigned to read/bump the *project* version
  (`uv self version` for uv itself); `--bump major/minor/patch` added.
  Auth failures (401/403) now halt index search.
  **`uv_build` declared stable** (0.7.19): a fast, pure-Python-only build backend.
- **0.8.x (Jul–Oct 2025)**: **`uv_build` became the default backend for
  `uv init --package`/`--lib`** (hatchling remains fully supported).
  `uv python install` installs versioned executables (`python3.13`) onto PATH by
  default. **`uv format` introduced** (preview; delegates to a pinned Ruff).
- **0.9.x (Oct 2025–Feb 2026)**: default Python bumped to **3.14** (3.14.0 final, Oct
  2025); free-threaded 3.14+ usable without opt-in.
- **0.10.x (Feb–Mar 2026)**: `uv python upgrade`, `uv add --bounds`, and
  `uv workspace list/dir` stabilized.
  `uv venv` requires `--clear` to overwrite.
  `uv format` moved to Ruff 0.15 / 2026 style.
- **0.11.x (Mar 2026–now)**: TLS moved to OS-native verification (`--native-tls`
  deprecated for `--system-certs`). **`uv audit`** (preview; announced 2026-06-08):
  scans `uv.lock` against the OSV database, with `--ignore`/`--ignore-until-fixed`.
  Opt-in **malware checks** on `uv add`/`uv sync` via `UV_MALWARE_CHECK=1` (0.11.16+).
  **`uv check`** (0.11.18, preview): runs Astral’s ty type checker.
  Python 3.15.0b2 in managed downloads; 3.15 final expected ~Oct 2026.

Caveats: docs.astral.sh blocked automated fetching during research, so a few details
(exact `uv audit` introduction version, full `[tool.uv]` option inventory) should be
re-verified against the changelog during implementation.

### Action items for this template

1. **Stay on hatchling + uv-dynamic-versioning** (decision, documented in the research
   doc): `uv_build` is now uv’s default backend and production-stable, but it is
   deliberately minimal — no plugin mechanism, so no dynamic versioning from git tags,
   which is core to this template’s release model.
   Revisit if uv ever grows native dynamic versioning.
2. **Add `[tool.uv] required-version`** (e.g. `>=0.11`) to
   `template/pyproject.toml.jinja` so contributors and CI fail fast on incompatible uv
   versions. (Folds into Phase 2 / D6.)
3. **Watch `uv audit` and `UV_MALWARE_CHECK`**: both are preview and brand-new (audit
   announced three days ago — inside the cool-off window).
   Add a note to the template’s supply-chain docs now; adopt in template CI once stable.
   (Folds into Phase 3 docs; CI adoption is a future release.)
4. **Keep `devtools/lint.py` over `uv format`/`uv check`**: one command still runs
   codespell + ruff check + ruff format + basedpyright together, which neither uv
   command covers; `uv check` is also ty-based and preview (see D7). Mention both in
   `docs/development.md` as aliases people may encounter.
5. **Refresh `docs/installation.md`** for current `uv python install` behavior
   (versioned executables on PATH since 0.8.0). (Folds into Phase 2.)
6. **Python 3.15**: add to the CI matrix and classifiers when final (~Oct 2026) — a
   future routine update, noted in `updating.md`’s checklist.
7. **Bump the pinned uv** in template workflows from 0.11.12 to the newest 0.11.x
   clearing the 14-day cool-off at implementation time (D6).

## References

- `tbd guidelines cli-agent-skill-patterns` — skill/CLI integration patterns (the
  integration ladder, route-don’t-restate, publishing channels)
- `tbd guidelines python-modern-guidelines` — Python/uv project conventions (cites this
  template for releasing)
- `tbd guidelines supply-chain-hardening` — pinning and cool-off policy
- Agent Skills standard: https://agentskills.io (spec: /specification)
- AGENTS.md standard: https://agents.md
- skills installer: https://github.com/vercel-labs/skills (skills.sh)
- Anthropic skills examples and marketplace: https://github.com/anthropics/skills
- Copier docs (non-interactive: `--defaults`, `--data`, `--vcs-ref`; updates):
  https://copier.readthedocs.io
- Type-checker research: `docs/project/research/research-python-type-checkers.md`
- Template maintenance flow: `updating.md`

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
