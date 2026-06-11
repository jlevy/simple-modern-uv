# FAQ: Common Problems

Failure modes seen in real setups and migrations, with fixes.
Check here before improvising.

## Build fails: “This does not appear to be a Git project”

`uv-dynamic-versioning` reads the version from git.
The project must be a git repo with at least one commit before `uv build` (or any
build-backend invocation, including the editable install during `uv sync`) can resolve a
version. Fix:
`git init --initial-branch=main && git add . && git commit -m "Initial commit"`.

## Version is 0.0.0, 0.1.devN, or otherwise wrong

No git tag yet — dynamic versioning derives the version from the latest `v*` tag.

- New project: tag `v0.1.0` when ready to release; dev versions before that are normal
  and harmless for CI.
- Migrated package already on PyPI at X.Y.Z: the first tag must be **greater** than
  X.Y.Z (e.g. `vX.Y.(Z+1)`), or the publish will be rejected as a duplicate/downgrade.
- Tag exists but ignored: tags must look like `v1.2.3`; also check CI uses
  `fetch-depth: 0` (the template’s workflows do) so tags are available.

## `uv sync` fails on Python version

The template requires Python 3.11+. `uv python install` downloads a managed interpreter;
pin one for the project with `uv python pin 3.12` (writes `.python-version`). If uv
itself errors with “required-version”, upgrade uv: the template requires uv >= 0.9.

## BasedPyright erupts with hundreds of errors on legacy code

Expected on first run over older code.
Don’t rewrite the codebase to satisfy it, and don’t turn it off:

1. Start from the template’s `[tool.basedpyright]` block, which already relaxes the
   noisiest rules.
2. Temporarily disable the loudest remaining categories (uncomment the provided
   `report*` lines, e.g. `reportUnknownVariableType = false`), leaving a comment to
   ratchet later.
3. Existing mypy-style `# type: ignore` comments still work; prefer fixing real findings
   over suppressing them.

## codespell flags names or legacy prose

Add exceptions in `pyproject.toml`: `[tool.codespell] ignore-words-list = "word1,word2"`
or `skip = "path1,path2"`.

## Conflicts during `copier update`

Copier writes `*.rej` files (or inline conflict markers) where the template and local
edits collide. Resolve each by hand, keeping the project’s intent; delete the `.rej`
files; re-run `make lint` and `make test`. A dirty working tree also blocks updates —
commit or stash first.

## `publish.yml` came back / license reverted after an update

The project predates the `publish_to_pypi` / `package_license` questions and the update
filled them with defaults.
Re-run the update passing the project’s reality, e.g.
`uvx copier@9.15.1 update --data publish_to_pypi=false`, and see “Reconciling new
questions” in [customize.md](customize.md).

## Publish workflow fails with OIDC/permission errors

The one-time PyPI Trusted Publisher setup hasn’t been done for this repo (or the
workflow filename doesn’t match what PyPI was told).
Follow `docs/publishing.md` in the project; no API tokens are needed.

## Lockfile resolution seems stale or refuses a brand-new release

`UV_EXCLUDE_NEWER` (set in the template’s CI) enforces a 14-day supply-chain cooling-off
window, so releases newer than that are deliberately invisible.
This is a feature; don’t remove it to get a day-old package.
Locally, leave the variable unset for normal work, or set it to match CI when debugging
resolution differences.

## Tests pass locally but CI fails on a Python version

The CI matrix runs 3.11–3.14. Most failures are version-specific syntax/stdlib use; run
the failing version locally with `uv run --python 3.11 pytest`.
