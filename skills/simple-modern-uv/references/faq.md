# FAQ: Common Problems

Failure modes seen in real setups and migrations, with fixes.
Check here before improvising.

## Build Fails: “This does not appear to be a Git project”

`uv-dynamic-versioning` reads the version from git.
The project must be a git repo with at least one commit before `uv build` (or any
build-backend invocation, including the editable install during `uv sync`) can resolve a
version. Fix:
`git init --initial-branch=main && git add . && git commit -m "Initial commit"`.

## Version Is 0.0.0, 0.1.devN, or Otherwise Wrong

No git tag yet: dynamic versioning derives the version from the latest `v*` tag.

- New project: tag `v0.1.0` when ready to release; dev versions before that are normal
  and harmless for CI.
- Migrated package already on PyPI at X.Y.Z: the first tag must be **greater** than
  X.Y.Z (e.g. `vX.Y.(Z+1)`), or the publish will be rejected as a duplicate/downgrade.
- Tag exists but ignored: tags must look like `v1.2.3`; also check CI uses
  `fetch-depth: 0` (the template’s workflows do) so tags are available.
- `importlib.metadata` still reports an old version after committing or tagging: the
  editable install’s metadata is captured at sync time and uv won’t refresh it on its
  own. Run `UV_CONFIG_FILE="$PWD/uv.toml" uv sync --reinstall-package <module>` (and sync
  only after the first commit on new projects).

## `uv sync` Fails on Python Version

The template requires Python 3.11+. `UV_CONFIG_FILE="$PWD/uv.toml" uv python install`
downloads a managed interpreter; pin one for the project with
`UV_CONFIG_FILE="$PWD/uv.toml" uv python pin 3.12` (writes `.python-version`). If uv
itself errors with “required-version”, upgrade uv: the template supports the reviewed uv
0.12 line (`>=0.12.0,<0.13`), matching its pinned CI toolchain.
Versions older than uv 0.9.17 may instead fail while parsing the relative duration
`"14 days"`, before they can report the project’s required version.
Treat that parse error the same way and upgrade uv first.

## Ruff Rewrites Python Blocks in Markdown

Ruff 0.16 and later include Markdown by default and can format Python code fences.
The template gives Flowmark ownership of Markdown and sets
`[tool.ruff] extend-exclude = ["*.md"]` so the tools do not compete.
Add that setting when updating a project that adopted Ruff separately or predates this
template policy.

## BasedPyright Erupts with Hundreds of Errors on Legacy Code

Expected on first run over older code.
Don’t rewrite the codebase to satisfy it, and don’t turn it off:

1. Start from the template’s `[tool.basedpyright]` block, which already relaxes the
   noisiest rules.
2. Temporarily disable the loudest remaining categories (uncomment the provided
   `report*` lines, e.g. `reportUnknownVariableType = false`), leaving a comment to
   ratchet later.
3. Existing mypy-style `# type: ignore` comments still work; prefer fixing real findings
   over suppressing them.

For an already-templated project that passes stricter checks, preserve its current
settings rather than copying new-project suppressions from a later template release.

## `make lint` Fails Right After a Template Update

A release can make a default *stricter*, by dropping a rule from the Ruff `ignore` list
or re-enabling a BasedPyright rule.
Those lines are rarely edited locally, so `copier update` applies them without conflict
and existing code starts failing.
Examples: Ruff `E402` (module-level import after code) and BasedPyright’s
`reportIgnoreCommentWithoutRule` (an unqualified `# pyright: ignore`).

These are real findings, not a bug in the update.
Fix them when they are few and the rule is one you want; otherwise reinstate that
specific `ignore` entry or `report*` setting in `pyproject.toml` with a comment saying
why. A targeted exemption is not a broad suppression.
The release notes’ `## Upgrading` section names the rule and the remedy.

## codespell Flags Names or Legacy Prose

Add exceptions in `pyproject.toml`: `[tool.codespell] ignore-words-list = "word1,word2"`
or `skip = "path1,path2"`.

## Conflicts During `copier update`

Copier writes `*.rej` files (or inline conflict markers) where the template and local
edits collide. Resolve each by hand, keeping the project’s intent; delete the `.rej`
files; re-run `make lint` and `make test`. A dirty working tree also blocks updates;
commit or stash first.

For a project several releases behind, trial a direct update to the desired target
first. An intermediate tag is a diagnostic tool, not a mandatory policy, unless the
template explicitly declares a staged migration for that version range.

## `publish.yml` Came Back or License Reverted After an Update

The project predates the `publish_to_pypi` and `package_license` questions and the
update filled them with defaults.
Re-run the update passing the project’s reality, e.g.
`uvx --exclude-newer "14 days" copier@9.17.0 update --data publish_to_pypi=false`, and
see “Reconciling New Questions on Update” in [customize.md](customize.md).

## Publish Workflow Fails with OIDC or Permission Errors

The one-time PyPI Trusted Publisher setup hasn’t been done for this repo (or the
workflow filename doesn’t match what PyPI was told).
Follow `docs/publishing.md` in the project; no API tokens are needed.

## Does the `pypi` Environment Require Manual Approval?

No. The environment name lets PyPI constrain authorization to jobs that declare it, but
GitHub adds no approval or tag restriction unless a maintainer configures those
protection rules. A solo or low-impact project can use the named environment without a
second approval.

A release-only workflow removes the ordinary manual-branch path, but anyone allowed to
create a matching release tag may still invoke it.
If not every repository writer should publish, use a tag ruleset to restrict creation
and updates of release-pattern tags to release maintainers, and/or require an
environment reviewer.
An environment rule that selects release tags rejects other refs but does not control
who can create a matching tag.

If an existing PyPI Trusted Publisher has a blank environment, the updated workflow
continues to publish but the publisher remains unconstrained.
Set its environment to `pypi` in the PyPI project settings to enforce the match.

## Lockfile Resolution Seems Stale or Refuses a Brand-New Release

The checked-in `uv.toml` sets a 14-day supply-chain cooling-off window, so releases
newer than that are deliberately invisible.
The Makefile and CI select that file with `UV_CONFIG_FILE`; CI also sets the equivalent
`UV_EXCLUDE_NEWER` value.
This is a feature; don’t remove the global gate to get a day-old package or let ambient
user settings change the lock.
Use the project’s standard commands when debugging resolution differences.
For a reviewed first-party or urgent release, add an absolute `exclude-newer-package`
cutoff for only that package to `uv.toml`, run
`UV_CONFIG_FILE="$PWD/uv.toml" uv lock --upgrade-package <package>`, inspect the
complete lock diff, and commit the configuration with the lock.
Remove the exception and relock after the release clears the normal window.

If the exception approves one package but the resolved lock also selects a recent
third-party dependency, constrain that dependency to the newest eligible release with
the package manager’s override mechanism.
Locking a graph makes the selection reproducible; it does not broaden the human
approval.

## Tests Pass Locally but CI Fails on a Python Version

The CI matrix runs 3.11–3.14. Most failures are version-specific syntax/stdlib use; run
the failing version locally with
`UV_CONFIG_FILE="$PWD/uv.toml" uv run --python 3.11 pytest`.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
