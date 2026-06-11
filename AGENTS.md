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

## Build & Test

This is a [Copier](https://copier.readthedocs.io) template repo, not a Python project
itself; there is no `pyproject.toml` to sync at the root.
Validation means rendering the template and exercising the render:

```bash
# Auto-format all Markdown docs (including *.md.jinja); check-only variant for CI:
make format
make format-check

# Render the template non-interactively (smoke test):
uvx copier copy --defaults --vcs-ref=HEAD --data package_name=smoke-test \
  --data package_github_org=testorg . /tmp/smoke-test
# Then inside the render: uv sync --all-extras && uv run python devtools/lint.py --check && uv run pytest
```

## Architecture Overview

- `template/`: the Copier template source that ships to generated projects (`*.jinja`
  files are rendered; everything else copies as-is).
  The `template/Makefile` and `template/devtools/lint.py` are what downstream projects
  use, not this repo.
- `copier.yml`: template questions and validation; the single source of truth for
  template variables.
- `updating.md`: the full maintenance and release flow (downstream
  `jlevy/simple-modern-uv-template` repo is the release gate).
- `docs/project/`: research docs and plan specs for this repo.

## Conventions & Patterns

- Follow the supply-chain rules in `updating.md`: 14-day cooling-off before adopting new
  releases, pinned tool versions, `UV_EXCLUDE_NEWER` in workflows.
- Markdown is formatted with flowmark via `make format`; run it before committing doc
  changes.
- Docs follow common-doc-guidelines (see footer comments in each doc).
