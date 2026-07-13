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
  own. Run `uv sync --reinstall-package <module>` (and sync only after the first commit
  on new projects).

## `uv sync` Fails on Python Version

The template requires Python 3.11+. `uv python install` downloads a managed interpreter;
pin one for the project with `uv python pin 3.12` (writes `.python-version`). If uv
itself errors with “required-version”, upgrade uv: the template requires uv >= 0.9.

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

## codespell Flags Names or Legacy Prose

Add exceptions in `pyproject.toml`: `[tool.codespell] ignore-words-list = "word1,word2"`
or `skip = "path1,path2"`.

## Conflicts During `copier update`

Copier writes `*.rej` files (or inline conflict markers) where the template and local
edits collide. Resolve each by hand, keeping the project’s intent; delete the `.rej`
files; re-run `make lint` and `make test`. A dirty working tree also blocks updates;
commit or stash first.

## `publish.yml` Came Back or License Reverted After an Update

The project predates the `publish_to_pypi` and `package_license` questions and the
update filled them with defaults.
Re-run the update passing the project’s reality, e.g.
`uvx --exclude-newer "14 days" copier@9.16.0 update --data publish_to_pypi=false`, and
see “Reconciling New Questions on Update” in [customize.md](customize.md).

## Publish Workflow Fails with OIDC or Permission Errors

The one-time PyPI Trusted Publisher setup hasn’t been done for this repo (or the
workflow filename doesn’t match what PyPI was told).
Follow `docs/publishing.md` in the project; no API tokens are needed.

## Lockfile Resolution Seems Stale or Refuses a Brand-New Release

`UV_EXCLUDE_NEWER` (set in the template’s CI) enforces a 14-day supply-chain cooling-off
window, so releases newer than that are deliberately invisible.
This is a feature; don’t remove it to get a day-old package.
Locally, leave the variable unset for normal work, or set it to match CI when debugging
resolution differences.

## Tests Pass Locally but CI Fails on a Python Version

The CI matrix runs 3.11–3.14. Most failures are version-specific syntax/stdlib use; run
the failing version locally with `uv run --python 3.11 pytest`.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
