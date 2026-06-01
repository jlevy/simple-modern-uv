# Updating This Template

This doc covers the full cycle for keeping the
[simple-modern-uv](https://github.com/jlevy/simple-modern-uv) template’s dependencies
and tools up to date, then verifying the changes end-to-end.

There are two repos involved:

- **Template repo** (`jlevy/simple-modern-uv`): The Copier template source.
  All version changes start here.
  This repo does not have CI, so testing is done via a downstream project.
- **Downstream project(s)**: Projects created from the template (e.g.
  [`jlevy/simple-modern-uv-template`](https://github.com/jlevy/simple-modern-uv-template)).
  These pull updates via `copier update` and have CI configured to run linting and tests
  across the Python version matrix.

Release rule: the downstream repo is the release gate.
Push the template candidate, export it into `jlevy/simple-modern-uv-template`, and wait
for downstream CI to pass before creating a GitHub release for this template.
The commands below assume the downstream repo is cloned next to this repo as
`../simple-modern-uv-template`.

## Step 1: Check Latest Versions

From the template repo, check what’s current on PyPI:

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

Note `astral-sh/setup-uv` is pinned to a full, immutable version tag (e.g. `@v8.1.0`)
rather than a floating major tag.
As of v8, Astral stopped publishing floating `@v8`/`@v8.1` tags in favor of immutable
releases, which is a supply-chain improvement (a pinned tag can’t be silently
re-pointed). The cost is that patch updates no longer arrive automatically, so bump the
exact version here when updating.
Apply the cooling-off check below to the action version too.

And check if new Python versions should be added to the test matrix.

### Supply Chain Hygiene

These practices follow
[supply-chain-hardening](https://github.com/jlevy/supply-chain-hardening), the
recommended guide for this template — see it for the full rationale and per-ecosystem
recipes.

Follow a **cooling-off period**: do not adopt any release published within the last 14
days. Fresh releases are the most likely to be yanked, to carry regressions, or (rarely)
to be a compromised/typosquatted artifact that hasn’t yet been caught.
Prefer the latest version that is both at least 14 days old and has had subsequent patch
releases without being yanked.
The CI and publish workflows enforce this by setting `UV_EXCLUDE_NEWER` to a 14-day
cool-off window (the pinned uv accepts the relative duration `"14 days"` directly).

Concretely, for each package, check the upload date before pinning:

```shell
# Show the latest version and its upload date for a package:
curl -s https://pypi.org/pypi/PACKAGE/json | python3 -c "import sys,json; d=json.load(sys.stdin); v=d['info']['version']; print(v, d['releases'][v][0]['upload_time_iso_8601'])"
```

Only add or upgrade dependencies you can vet upstream (active maintenance, reputable
source, clear changelog).
Avoid introducing new dependencies when a small amount of first-party code will do.

## Step 2: Update the Template Files

In the template repo, update these files as needed:

- **Dev dependency lower bounds** in `template/pyproject.toml.jinja` (these are `>=`
  floors, not exact pins; CI enforces the cool-off via `UV_EXCLUDE_NEWER`)
- **uv version** in `template/.github/workflows/ci.yml` and `publish.yml` (the
  `version:` field under `astral-sh/setup-uv`)
- **GitHub Actions versions** (e.g. `actions/checkout@v6`) in the same workflow files
- **Python version matrix** in `template/.github/workflows/ci.yml` and the corresponding
  classifiers in `template/pyproject.toml.jinja`

Then auto-format all docs so formatting stays consistent (this repo has no CI to enforce
it):

```shell
make format        # auto-format all Markdown docs, including *.md.jinja templates
make format-check  # check-only, to confirm nothing is left unformatted
```

This runs the pinned `uvx flowmark-rs@0.3.1 --auto` from the top-level `Makefile`.

## Step 3: Commit and Push the Template Candidate

Commit the template changes and push `main`, but do not create the release yet.
The downstream repo needs to export the exact candidate commit first.

```shell
git add -A
git commit -m "Update dependencies and tool versions."
git push origin main

# Record the exact commit that downstream CI will validate:
TEMPLATE_COMMIT=$(git rev-parse HEAD)
```

## Step 4: Export the Candidate to the Downstream Repo

In the downstream repo, update from the pushed candidate commit.
The working tree must be clean before running `copier update`.

```shell
cd ../simple-modern-uv-template
git status --short

# Export the exact template candidate. This uses the _src_path already recorded in
# .copier-answers.yml, currently gh:jlevy/simple-modern-uv.
copier update --defaults --vcs-ref "$TEMPLATE_COMMIT"
git diff --stat
```

If the downstream repo ever needs a fresh render instead of an update, instantiate with
the standard defaults:

```shell
copier copy --defaults --vcs-ref "$TEMPLATE_COMMIT" gh:jlevy/simple-modern-uv .
```

## Step 5: Verify Locally

After the copier update, confirm everything works locally.
Use the same 14-day supply-chain cool-off the GitHub workflows set.

```shell
export UV_EXCLUDE_NEWER="14 days"

uv sync --all-extras
uv run python devtools/lint.py --check
uv run pytest
uv build
```

## Step 6: Push Downstream and Confirm CI

Commit and push the downstream project, then wait for GitHub Actions to finish.

```shell
git add -A
git commit -m "Validate simple-modern-uv template ${TEMPLATE_COMMIT:0:7}."
git push origin main

RUN_ID=$(gh run list \
  --repo jlevy/simple-modern-uv-template \
  --workflow CI \
  --branch main \
  --event push \
  --json databaseId \
  -q '.[0].databaseId')

gh run watch --repo jlevy/simple-modern-uv-template "$RUN_ID" --exit-status
```

Then check that **CI passes on GitHub** — this runs the full lint and test suite across
all Python versions in the matrix (e.g. 3.11, 3.12, 3.13, 3.14) on the stub test file
and template code. This is the real end-to-end validation that the template works.

If CI fails, fix issues in the template repo and repeat from Step 2.

## Step 7: Create a Release on the Template Repo

Once CI passes downstream, create a GitHub release on the template repo.
The template repo doesn’t have its own CI, so the downstream CI run serves as the
verification.

```shell
# From the template repo:
cd ../simple-modern-uv

LAST_TAG=$(gh release list --repo jlevy/simple-modern-uv --limit 1 --json tagName -q '.[0].tagName')
NEW_TAG="v0.X.Y"

git log "${LAST_TAG}..HEAD" --oneline
git diff --stat "${LAST_TAG}..HEAD"

gh release create "$NEW_TAG" \
  --repo jlevy/simple-modern-uv \
  --target "$TEMPLATE_COMMIT" \
  --title "$NEW_TAG" \
  --notes "$(cat <<EOF
## What's Changed

- **Updated dev dependencies**: ruff X.Y.Z, basedpyright X.Y.Z, etc.
- **Updated uv** to X.Y.Z in CI workflows
- Any other changes

**Downstream validation**: jlevy/simple-modern-uv-template CI passed for ${TEMPLATE_COMMIT:0:7}

**Full Changelog**: https://github.com/jlevy/simple-modern-uv/compare/${LAST_TAG}...${NEW_TAG}
EOF
)"
```

This makes the release visible to users and provides clear release notes on what was
updated.

## Step 8: Record the Release Tag Downstream

The pre-release downstream commit validates an exact template commit.
After the release exists, update the downstream repo once more from the release tag so
`.copier-answers.yml` records the public template version.
This should either be a no-op or only change `_commit`.

```shell
cd ../simple-modern-uv-template
copier update --defaults --vcs-ref "$NEW_TAG"
git diff -- .copier-answers.yml

git add -A
git commit -m "Record simple-modern-uv template ${NEW_TAG}."  # skip if no diff
git push origin main
```
