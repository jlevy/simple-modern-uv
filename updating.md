# Updating This Template

This doc covers the full cycle for keeping the
[simple-modern-uv](https://github.com/jlevy/simple-modern-uv) template's dependencies
and tools up to date, then verifying the changes end-to-end.

There are two repos involved:

- **Template repo** (`jlevy/simple-modern-uv`): The Copier template source. All version
  changes start here. This repo does not have CI, so testing is done via a downstream
  project.
- **Downstream project(s)**: Projects created from the template (e.g.
  [`jlevy/simple-modern-uv-template`](https://github.com/jlevy/simple-modern-uv-template)).
  These pull updates via `copier update` and have CI configured to run linting and tests
  across the Python version matrix.

## Step 1: Check Latest Versions

From the template repo, check what's current on PyPI:

```shell
# Check latest versions of each dev dependency:
for pkg in ruff basedpyright pytest pytest-sugar codespell rich funlog; do
  echo "$pkg: $(curl -s https://pypi.org/pypi/$pkg/json | python3 -c "import sys,json; print(json.load(sys.stdin)['info']['version'])")"
done

# Check latest uv version:
curl -s https://pypi.org/pypi/uv/json | python3 -c "import sys,json; print('uv:', json.load(sys.stdin)['info']['version'])"
```

Also check for new major versions of GitHub Actions:
- `actions/checkout` — <https://github.com/actions/checkout/releases>
- `astral-sh/setup-uv` — <https://github.com/astral-sh/setup-uv/releases>

And check if new Python versions should be added to the test matrix.

## Step 2: Update the Template Files

In the template repo, update these files as needed:

- **Dev dependency version pins** in `template/pyproject.toml.jinja`
- **uv version** in `template/.github/workflows/ci.yml` and `publish.yml`
  (the `version:` field under `astral-sh/setup-uv`)
- **GitHub Actions versions** (e.g. `actions/checkout@v6`) in the same workflow files
- **Python version matrix** in `template/.github/workflows/ci.yml` and the
  corresponding classifiers in `template/pyproject.toml.jinja`

## Step 3: Commit, Tag, and Push the Template

Copier requires a new Git tag to recognize an update. Increment the version from the
last tag (check with `git tag -l | sort -V | tail -1`):

```shell
git add -A
git commit -m "Update dependencies and tool versions."
git tag v0.X.Y
git push origin main --tags
```

## Step 4: Update a Downstream Project

In a downstream project (e.g. `simple-modern-uv-template`), pull the template update.
The working tree must be clean before running `copier update`:

```shell
# Ensure clean working tree:
git stash --include-untracked  # if needed

# Pull template changes:
copier update --defaults

# Restore stash if needed:
git stash pop
```

## Step 5: Verify Locally

After the copier update, confirm everything works locally:

```shell
uv sync --upgrade
uv run python devtools/lint.py
uv run pytest
uv build
```

## Step 6: Push Downstream and Confirm CI

Commit and push the downstream project:

```shell
git add -A
git commit -m "Update from simple-modern-uv template vX.Y.Z."
git push origin main
```

Then check that **CI passes on GitHub** — this runs the full lint and test suite across
all Python versions in the matrix (e.g. 3.11, 3.12, 3.13, 3.14) on the stub test file
and template code. This is the real end-to-end validation that the template works.

If CI fails, fix issues in the template repo and repeat from Step 2.

## Step 7: Create a Release on the Template Repo

Once CI passes downstream, create a GitHub release on the template repo. The template
repo doesn't have its own CI, so the downstream CI run serves as the verification.

```shell
# From the template repo:
gh release create v0.X.Y --title "v0.X.Y" --notes "$(cat <<'EOF'
## What's Changed

- **Updated dev dependencies**: ruff X.Y.Z, basedpyright X.Y.Z, etc.
- **Updated uv** to X.Y.Z in CI workflows
- Any other changes

**Full Changelog**: https://github.com/jlevy/simple-modern-uv/compare/vPREVIOUS...v0.X.Y
EOF
)"
```

This makes the release visible to users and provides clear release notes on what was
updated.
