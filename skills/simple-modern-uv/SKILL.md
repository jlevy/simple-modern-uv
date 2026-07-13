---
name: simple-modern-uv
description: >-
  Set up, modernize, or update Python projects using the simple-modern-uv template:
  uv, ruff, BasedPyright, pytest, GitHub Actions CI, and tag-driven PyPI publishing.
  Use when starting a new Python project or package; when modernizing, upgrading, or
  migrating an existing Python package to uv (from Poetry, setuptools, pip,
  requirements.txt, or PDM); or when updating a project already built from
  simple-modern-uv to the latest template.
license: MIT
compatibility: Requires git and uv (https://docs.astral.sh/uv/); network access to GitHub
metadata:
  author: jlevy (github.com/jlevy)
  source: https://github.com/jlevy/simple-modern-uv
allowed-tools: Bash(uvx:*), Bash(uv:*), Bash(git:*), Bash(make:*), Bash(gh:*), Read, Write, Edit
---
# simple-modern-uv: Modern Python Project Setup

[simple-modern-uv](https://github.com/jlevy/simple-modern-uv) is a minimal, modern
Python project template: **uv** for everything package-related, **ruff** for
lint/format, **BasedPyright** for type checking, **pytest**, GitHub Actions CI, and
tag-driven publishing to PyPI with dynamic versioning (the git tag is the version).
It is a [Copier](https://copier.readthedocs.io) template, so projects can pull future
template improvements at any time with `copier update`.

There are three workflows.
Pick by situation:

1. **New project**: create a project from scratch.
2. **Upgrade existing project**: convert any existing Python package to this template’s
   structure and tooling.
   See [references/adopt-existing.md](references/adopt-existing.md).
3. **Update templated project**: the project has a `.copier-answers.yml` from this
   template; pull the latest template changes.

For all workflows: when something fails, check [references/faq.md](references/faq.md)
before improvising. For post-setup customization (license change, private/unpublished
package, entry points), see [references/customize.md](references/customize.md).

If this file was fetched from a URL rather than installed as a folder, fetch the
reference files from the **same ref**: replace `SKILL.md` in the URL you used with
`references/<name>.md` (don’t mix a pinned `SKILL.md` with references from `main`).

## The Interview: What to Ask the User (and What Not to Ask)

Every workflow uses the same answer set (the template’s questions in
[copier.yml](https://github.com/jlevy/simple-modern-uv/blob/main/copier.yml)). **Infer
everything you can, then ask the user to confirm once, in a single batched message.**
Never ask one question at a time, and never ask about things listed under “conventions”
below.

**Essentials** (confirm these; they are the user’s decisions):

| Answer key | Meaning | Notes |
| --- | --- | --- |
| `package_name` | PyPI package and GitHub repo name | Normalize to **kebab-case** (`acme-widgets`); show the user the name you derived |
| `package_module` | Python module name | Derived automatically as **snake_case** (`acme_widgets`); show it, don’t ask |
| `package_description` | One-line description |  |
| `package_license` | `MIT` (default), `Apache-2.0`, `BSD-3-Clause`, `AGPL-3.0-or-later`, `Proprietary`, or `None` (decide later) | Always surface, naming the default |
| `publish_to_pypi` | `true` (default) or `false` | Always surface; `false` for private packages and apps |

For `package_author_name`, `package_author_email`, and `package_github_org`, **infer**
values from `git config user.name` and `user.email` and the repo’s remote or
`gh auth status`, and include them in the confirmation summary rather than asking.

**Conventions** (apply silently; mention in your final summary; deviate only if the user
explicitly asks): `src/` layout; first version is the git tag `v0.1.0` for a new project
(for upgrades of published packages, the next version above what’s on PyPI); Python
3.11+; line length 100; the template’s tool choices.
These are never questions.

## Workflow 1: New Project

1. Run the interview (above).
   Then render, replacing the answer values:

   ```bash
   uvx --exclude-newer "14 days" copier@9.16.0 copy --defaults \
     --data package_name=acme-widgets \
     --data "package_description=One-line description" \
     --data "package_author_name=Jane Doe" \
     --data package_author_email=jane@example.com \
     --data package_github_org=acme \
     --data package_license=MIT \
     --data publish_to_pypi=true \
     gh:jlevy/simple-modern-uv acme-widgets
   ```

   (Omit `--data` keys that should take defaults.
   `package_module` derives automatically from `package_name`.)

2. Initialize git, commit, then install.
   Sync only after the first commit: dynamic versioning reads git, and syncing first
   leaves the editable install’s version at `0.0.0`.

   ```bash
   cd acme-widgets
   git init --initial-branch=main
   git add . && git commit -m "Initial commit from simple-modern-uv."
   make install
   git add uv.lock && git commit -m "Add uv.lock."
   ```

3. **Verify**: `make lint` and `make test` must pass.
   Fix anything that doesn’t before declaring success.

4. Offer next steps (don’t just stop): create the GitHub repo and push (an empty repo
   with no README, license, or .gitignore; the template provides them); fill in
   `README.md`; if publishing, `docs/publishing.md` covers the one-time PyPI Trusted
   Publisher setup; tag `v0.1.0` when ready to release.

## Workflow 2: Upgrade an Existing Project

Follow [references/adopt-existing.md](references/adopt-existing.md).
In brief: run the interview with answers **inferred from the repo itself**
(pyproject/setup.py metadata, LICENSE file, git remote, PyPI presence), render the
template into a sibling temp directory with those answers, merge the template’s
structure into the project (preserving its dependencies, metadata, and code), translate
old tool configs to uv equivalents, write `.copier-answers.yml` so future updates work,
and verify with `make install`, lint, and tests.
Land everything on a branch as one reviewable change.

## Workflow 3: Update a Templated Project

Requires a clean working tree and the project’s `.copier-answers.yml`.

1. If the template has questions the project has never answered (keys present in the
   template’s `copier.yml` but missing from the project’s `.copier-answers.yml`), first
   check the project’s actual state and pass matching `--data` so defaults can’t revert
   hand customizations (see “Reconciling New Questions on Update” in
   [references/customize.md](references/customize.md)).

2. ```bash
   uvx --exclude-newer "14 days" copier@9.16.0 update --defaults --skip-answered
   ```

3. Resolve any `*.rej` files or inline conflict markers, re-run `make lint` and
   `make test`, then summarize what the template update changed (check the
   [release notes](https://github.com/jlevy/simple-modern-uv/releases)).

## Verification Gate (All Workflows)

Before reporting success: `make install`, `make lint`, and `make test` all pass, and for
publishable packages `make build` produces a wheel with a sensible version (requires at
least one git commit; see the FAQ if the version looks wrong).
Report what you ran and the results.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
