# Updating This Template

This doc covers the full process for keeping the
[simple-modern-uv](https://github.com/jlevy/simple-modern-uv) template's dependencies
and tools up to date, then propagating those changes to downstream projects.

There are two repos involved:

- **Template repo** (`jlevy/simple-modern-uv`): The Copier template source. All version
  changes start here.
- **Downstream project(s)**: Projects created from the template (e.g.
  [`jlevy/simple-modern-uv-template`](https://github.com/jlevy/simple-modern-uv-template)).
  These pull updates via `copier update`.

## Step 1: Check Latest Versions

From the template repo, check what's current:

```shell
# Check latest versions of each dev dependency on PyPI:
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

## Step 5: Verify Downstream

After the copier update, confirm everything works:

```shell
uv sync --upgrade
uv run python devtools/lint.py
uv run pytest
uv build
```

## Step 6: Push Downstream and Confirm CI

```shell
git add -A
git commit -m "Update from simple-modern-uv template vX.Y.Z."
git push origin main
```

Then check that CI passes on GitHub. If there are failures, fix them, and iterate from
Step 2.
