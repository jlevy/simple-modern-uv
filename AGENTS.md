# Project Instructions for AI Agents

This file provides instructions and context for AI coding agents working on this
project.

<!-- BEGIN TBD INTEGRATION format=f04 surface=agents-md -->
## tbd

This repository uses **tbd** for git-native issue tracking (beads), spec-driven
planning, and on-demand engineering guidelines.
As the agent, you operate tbd on the user’s behalf — translate their requests into tbd
actions rather than telling them to run commands.

- Run `tbd prime` to load current project state and the full tbd workflow.
- Run `tbd skill` for the complete reusable tbd skill instructions.
- Run `tbd shortcut --list` and `tbd guidelines --list` for on-demand resources.
- Track all work as beads: `tbd create`, `tbd ready`, `tbd close`, and `tbd sync`.

<!-- END TBD INTEGRATION -->

## Build and Test

This is a [Copier](https://copier.readthedocs.io) template repo, not a Python project
itself; there is no `pyproject.toml` to sync at the root.
Validation means rendering the template and exercising the render:

```bash
# Auto-format all Markdown docs (including *.md.jinja); check-only variant for CI:
make format
make format-check

# Render the template non-interactively (smoke test):
SMOKE_DIR=$(mktemp -d)
uvx --exclude-newer "14 days" copier@9.17.0 copy --defaults --vcs-ref=HEAD \
  --data package_name=smoke-test \
  --data package_github_org=testorg . "$SMOKE_DIR"

# Dynamic versioning needs an initial commit before installation:
cd "$SMOKE_DIR"
git init --initial-branch=main
git add .
git -c user.name=Smoke -c user.email=smoke@example.com \
  commit -m "Initial commit"
make install
make lint-check
make test
```

## Architecture Overview

- `template/`: the Copier template source that ships to generated projects (`*.jinja`
  files are rendered; everything else copies as-is).
  The `template/Makefile` and `template/devtools/lint.py` are what downstream projects
  use, not this repo.
- `copier.yml`: template questions and validation; the single source of truth for
  template variables.
- [`skills/simple-modern-uv/`](skills/simple-modern-uv/): the portable agent workflow
  bundle. Its [`SKILL.md`](skills/simple-modern-uv/SKILL.md) is the concise router; the
  one-level `references/` files own the new, selective, migration, and update
  procedures. Keep README discovery and generated agent guidance aligned with these
  routes.
- [`updating.md`](updating.md): the full maintenance and release flow (downstream
  `jlevy/simple-modern-uv-template` repo is the release gate).
- [`docs/project/`](docs/project/README.md): maintainer research, frozen release
  evidence, and implementation records.

## Conventions and Patterns

- Follow the [supply-chain rules](updating.md#supply-chain-hygiene): 14-day cooling-off
  before adopting new releases, pinned tool versions, and `UV_EXCLUDE_NEWER` in
  workflows.
- Markdown is formatted with flowmark via `make format`; run it before committing doc
  changes.
- Docs follow common-doc-guidelines (see footer comments in each doc).

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
