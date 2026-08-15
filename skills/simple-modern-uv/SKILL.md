---
name: simple-modern-uv
description: >-
  Start, selectively modernize, fully migrate, or update Python projects using
  simple-modern-uv practices: uv, ruff, BasedPyright, pytest, GitHub Actions CI, and
  tag-driven PyPI publishing. Use when creating a Python project; adding selected
  tooling or repository practices to an existing project; migrating from Poetry,
  setuptools, pip, requirements.txt, PDM, or hatch; or updating a project already
  managed by the simple-modern-uv Copier template.
license: MIT
compatibility: Requires git and uv (https://docs.astral.sh/uv/); network access to GitHub
metadata:
  author: jlevy (github.com/jlevy)
  source: https://github.com/jlevy/simple-modern-uv
---
# simple-modern-uv: Modern Python Project Setup

[simple-modern-uv](https://github.com/jlevy/simple-modern-uv) is a minimal, modern
Python project template: **uv** for package management, **ruff** for linting and
formatting, **BasedPyright** for type checking, **pytest**, GitHub Actions CI, and
tag-driven publishing to PyPI. It is a [Copier](https://copier.readthedocs.io) template,
so fully managed projects can pull future template improvements with `copier update`.

## Route the Request

Choose one workflow and load its reference before editing:

| User goal | Workflow |
| --- | --- |
| Start a project from scratch | [Start a new project](references/start-new-project.md) |
| Add one or more practices without restructuring everything | [Adopt selected features](references/adopt-selectively.md) |
| Convert an existing package to the template’s structure and update path | [Upgrade an existing project](references/adopt-existing.md) |
| Pull upstream changes into a project with `.copier-answers.yml` | [Update a template-managed project](references/update-templated-project.md) |

Use [references/customize.md](references/customize.md) for license, publishing, apps,
and common policy changes.
When something fails, consult [references/faq.md](references/faq.md) before improvising.

If this file was fetched from a URL rather than installed as a folder, fetch the
selected reference and any shared reference it names from the **same Git ref**. Never
mix a pinned `SKILL.md` with references from `main`.

## Choose the Lowest Useful Adoption Level

These are working modes, not certifications:

| Level | Result |
| --- | --- |
| **Selective** | Adopt only named feature bundles. Preserve the current build backend, layout, release model, and equivalent tools unless the user asks to change them. Do not add `.copier-answers.yml`. |
| **Core toolchain** | Adopt uv dependency management, lockfile policy, lint/type/test commands, CI, and agent guidance. Preserve packaging, versioning, or layout where changing them has no stated benefit. This is not Copier-managed unless the user chooses full migration. |
| **Full template-managed** | Render or migrate to the template structure, record `.copier-answers.yml`, and use Copier for future updates. Explicitly document any deliberate deviations. |

Choose the lowest level that satisfies the request.
A named feature request is selective by default.
“Upgrade/migrate this project to simple-modern-uv” means full migration unless
repository constraints make a lower level safer; surface that change of scope before
acting.

## Inspect Before Acting

For an existing repository, inspect its instructions and working tree first.
Then map:

- project metadata, dependencies, Python support, package layout, and build backend
- current lockfiles, environment manager, linting, typing, tests, and CI
- versioning, release, publishing, license, private-index, and platform constraints
- existing `AGENTS.md`, `CLAUDE.md`, `.copier-answers.yml`, and local modifications

Preserve user work and established behavior.
Work on a branch, and never overwrite an existing configuration merely because the
template has a different default.

## Interview Contract

New projects and full migrations use the template questions in
[`copier.yml`](https://github.com/jlevy/simple-modern-uv/blob/main/copier.yml).
Infer everything possible, then ask the user to confirm material choices once in one
batched message.

| Answer key | Meaning | Notes |
| --- | --- | --- |
| `package_name` | PyPI package and GitHub repo name | Normalize to **kebab-case** and show the derived name |
| `package_module` | Python module name | Derive **snake_case** from the package name; show it, do not ask |
| `package_description` | One-line description | Infer from existing metadata when possible |
| `package_license` | MIT, Apache-2.0, BSD-3-Clause, AGPL-3.0-or-later, Proprietary, or None | Always surface, naming MIT as the new-project default |
| `publish_to_pypi` | `true` or `false` | Always surface; use `false` for private packages and unpublished apps |

Infer author name, author email, and GitHub organization from project metadata, git, the
remote, and authenticated GitHub state.
Include the inferred values in the confirmation summary rather than asking separately.

For new projects, apply the template conventions: `src/` layout, Python 3.11+, line
length 100, and tag-derived versions beginning with `v0.1.0`. For published migrations,
the next tag must exceed the published version.
For selective and core adoption, preserve existing choices unless the requested feature
requires a change; ask only about those material conflicts.

Always surface changes to supported Python versions, package layout, build backend,
versioning, license, publishing, or CI provider.
These are project decisions, not incidental implementation details.

## Shared Execution Contract

- Use the repository’s reviewed, pinned Copier command and 14-day dependency cool-off.
- Render the template to a temporary sibling directory when a reference implementation
  is useful. Compare and adapt; do not blindly copy over an existing project.
- Adopt each feature’s complete dependency closure.
  For example, a locked CI workflow also needs compatible project metadata, `uv.toml`,
  `uv.lock`, and commands.
- Keep equivalent existing tooling when replacement is outside the requested scope.
- Add `.copier-answers.yml` only for a deliberate full migration.
  Selective copying does not create honest Copier lineage and must not pretend that it
  does.
- Keep changes reviewable and report conflicts or deliberate deviations explicitly.

## Verification and Handoff

Verify every touched path.
Full and core adoption normally require `make install`, `make lint`, and `make test`;
publishable projects also require `make build`. Selective adoption runs the smallest
commands that prove the selected features and their failure paths.
Validate workflow syntax and preserve existing tests whenever CI changes.

Before reporting success, summarize five categories:

- **Adopted**: template practices used as designed
- **Adapted**: practices adjusted to preserve project constraints
- **Preserved**: existing choices or equivalent tools intentionally retained
- **Deferred**: relevant practices intentionally left for later
- **Removed**: superseded files or tooling, if any

Also state whether the result is selective, core, or full template-managed; list the
validation commands and outcomes; and name any decision that still belongs to the user.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
