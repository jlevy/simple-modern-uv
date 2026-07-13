# Upgrading an Existing Project to simple-modern-uv

Convert an existing Python package (setuptools/pip, Poetry, PDM, hatch, or plain
scripts) to the simple-modern-uv structure.
The approach: render the template next to the project, then merge it in deliberately;
never blindly overwrite.
Work on a branch and land the whole migration as one reviewable change.

Out of scope (stop and tell the user): C extensions or custom build steps, conda
environments, monorepos/workspaces with multiple packages.
These need decisions a checklist shouldn’t make.

## Step 1: Infer the Interview Answers from the Repo

| Answer | Where to look |
| --- | --- |
| `package_name` | `[project] name`, `setup.py name=`, `[tool.poetry] name`, or the repo name |
| `package_description` | `[project] description` or `setup.py description=` |
| `package_author_name` / `email` | `[project] authors`, `[tool.poetry] authors`, or git log |
| `package_github_org` | `git remote get-url origin` |
| `package_license` | `LICENSE` file contents and `license` field/classifiers; map to MIT, Apache-2.0, BSD-3-Clause, or AGPL-3.0-or-later; no license found maps to None; else Proprietary |
| `publish_to_pypi` | `true` if the package is on PyPI (`uv pip index` or check pypi.org) or clearly intended for it; `false` for apps/private code (a `Private :: Do Not Upload` classifier is a definitive no) |

Confirm the essentials with the user in one batched message (per the interview contract
in SKILL.md), flagging anything that will change.
One decision that must be surfaced if it applies: if the project currently supports
Python older than 3.11 **and** is published, adopting the template raises
`requires-python` to `>=3.11`. Dropping versions for existing users is the user’s call,
not yours.

## Step 2: Render the Template Beside the Project

```bash
cd ..
uvx --exclude-newer "14 days" copier@9.16.0 copy --defaults \
  --data package_name=<name> ... \
  gh:jlevy/simple-modern-uv <project>-template-render
```

Use the render as the source of truth for structure; you will copy from it into the real
project.

## Step 3: Merge Structure into the Project

Copy from the render, adapting as you go:

- **`pyproject.toml`**: start from the rendered one and port the project’s reality into
  it: `dependencies`, extras, entry points, tool configs that should survive (translate
  as below). Keep the rendered `[build-system]` (hatchling with uv-dynamic-versioning),
  `[tool.uv]`, `[tool.ruff]`, `[tool.basedpyright]`, `[tool.pytest.ini_options]`
  sections.
- **Code layout**: move code to `src/<module>/` (the convention; if the user insists on
  a flat layout, adjust `packages` and `testpaths` instead).
  Ensure `py.typed` exists in the package.
  Tests go in `tests/`.
- **Copy verbatim**: `devtools/lint.py`, `Makefile`, `.gitignore` (merge with existing
  entries), `.github/workflows/ci.yml` (and `publish.yml` if publishing),
  `docs/installation.md`, `docs/development.md`.
- **Agent instruction files**: copy `AGENTS.md` and `CLAUDE.md` from the render if the
  project has neither.
  If the project already has an `AGENTS.md`, keep its content and fold in the template’s
  build/test commands.
  If it already has a `CLAUDE.md`, don’t overwrite it; add the `@AGENTS.md` import line
  at the top so Claude Code picks up the shared conventions.
- **`.copier-answers.yml`**: copy from the render.
  This is what makes future `copier update` work; without it the project is orphaned
  from the template.
- **Delete superseded files** (after their content is ported): `setup.py`, `setup.cfg`,
  `requirements*.txt`, `poetry.lock`, `pdm.lock`, `Pipfile*`, old
  `tox.ini`/`.flake8`/`mypy.ini`/`.pylintrc`, old CI workflows that the template’s CI
  replaces.

## Per-Source Translations

**Poetry**:

- Caret/tilde specs → PEP 621 ranges: `^1.2.3` → `>=1.2.3,<2.0.0`; `~1.2.3` →
  `>=1.2.3,<1.3.0`. Prefer simple `>=` floors where the project doesn’t actually need
  upper bounds.
- `[tool.poetry.dependencies]` → `[project] dependencies` (drop the `python` entry;
  that’s `requires-python`).
- `[tool.poetry.group.dev.dependencies]` (or `dev-dependencies`) →
  `[dependency-groups] dev`.
- `[tool.poetry.scripts]` → `[project.scripts]`.
- `[tool.poetry] version` → delete; the version now comes from git tags
  (`dynamic = ["version"]`).
- `packages = [{include = "pkg", from = "src"}]` → hatch’s
  `[tool.hatch.build.targets.wheel] packages = ["src/pkg"]` (already in the rendered
  file).

**setuptools/pip**:

- `setup.py`/`setup.cfg` metadata → `[project]` table.
  `install_requires` → `dependencies`; `extras_require` →
  `[project.optional-dependencies]`; `entry_points["console_scripts"]` →
  `[project.scripts]`.
- `requirements.txt` → runtime deps to `dependencies`; `requirements-dev.txt` →
  `[dependency-groups] dev`. Drop exact `==` pins unless genuinely required; `uv.lock`
  provides reproducibility.

**mypy → BasedPyright**: drop `mypy.ini`/`[tool.mypy]`; the rendered
`[tool.basedpyright]` block is the starting point.
Existing `# type: ignore` comments still work.
If legacy code produces a wall of errors, see the FAQ: relax first, ratchet later.

**Other linters (flake8, isort, black, pylint)**: delete their configs; ruff covers them
(`I` rules replace isort, the formatter replaces black).

## Step 4: Lock, Verify, Iterate

```bash
make install               # creates uv.lock; commit it
make lint                  # codespell + ruff + basedpyright
make test
make build                 # only if publishing
```

Fix failures using [faq.md](faq.md).
Lint/type errors in legacy code are normal on first run: auto-fix what `make lint`
fixes, relax basedpyright rules where the noise is unhelpful (leave a comment), and
don’t rewrite working code just to satisfy a rule.

## Step 5: Versioning and Finish

- Dynamic versioning needs a tag: if the package is on PyPI at version X.Y.Z, tag the
  merge commit `vX.Y.(Z+1)` (or the next minor) **after** merging; an unpublished
  project starts at `v0.1.0`. Until a tag exists, builds get a dev version: fine for CI,
  wrong for release.
- Commit everything (including `uv.lock` and `.copier-answers.yml`) on the branch and
  summarize: what moved, what was translated, what was deleted, anything the user should
  review by hand (license, classifiers, CI triggers).

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
