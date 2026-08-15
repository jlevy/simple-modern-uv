# Updating This Template

Use this process to keep the
[simple-modern-uv](https://github.com/jlevy/simple-modern-uv) template’s dependencies
and tools up to date, then verify the changes end-to-end.

There are two repos involved:

- **Template repo** (`jlevy/simple-modern-uv`): The Copier template source.
  All version changes start here.
  This repo’s own CI (`.github/workflows/ci.yml`) makes PRs self-validating: it renders
  the template (default and non-default options), runs the full lint/test/build cycle on
  the render, runs the update-path test from the previous release tag, and validates the
  agent skill (`skills/simple-modern-uv/`).
- **Downstream project(s)**: Projects created from the template (e.g.
  [`jlevy/simple-modern-uv-template`](https://github.com/jlevy/simple-modern-uv-template)).
  These pull updates via `copier update` and have CI configured to run linting and tests
  across the Python version matrix.
  The downstream repo remains the **release gate** (full matrix, real `copier update`
  against a long-lived project).

## Release Sequence

A normal release has five stages:

1. **Finish the candidate PR:** Resolve known release blockers, freeze the dependency
   evidence, and require every template-repo CI job to pass.
2. **Merge and identify the candidate:** Merge the PR into `main`, record its exact
   merge commit as `TEMPLATE_COMMIT`, and require that commit’s `main` CI run to pass.
3. **Pass the downstream gate:** Update `jlevy/simple-modern-uv-template` from that
   exact commit, verify it locally, merge the downstream validation PR, and require its
   full Python matrix to pass.
4. **Publish the template release:** Create a GitHub Release targeting
   `TEMPLATE_COMMIT`. GitHub creates the version tag as part of this action; do not
   create or push a bare tag separately.
5. **Record the public tag downstream:** Update the downstream project from the new tag
   and merge the resulting `.copier-answers.yml` bookkeeping change.

The downstream project is the release gate when it is reachable.
A merge followed immediately by a tag skips that gate, the reviewed release notes, and
verification that the public tag reproduces the validated commit.

The commands below assume the downstream repo is cloned next to this repo as
`../simple-modern-uv-template`. They also require a GitHub CLI release whose
`gh run list` command supports `--commit`. Check that capability before starting:

```shell
gh run list --help | grep -q -- '--commit'
```

### Releasing Without Downstream Access

When the downstream repo is not reachable, this repo’s CI on the candidate commit is the
gate—all jobs must be green—plus a local render verification (Step 5 run against a fresh
render). Create the release on that basis, then complete the downstream export and tag
recording (Steps 4–6 and 8) as post-release verification from an environment with
access. If downstream then fails, fix forward with a patch release.

## Step 1: Check Latest Versions

Take one timestamped inventory, calculate the exact cutoff, and freeze it for the
release. Do not keep chasing releases while implementing.
This standard-library script prints both the latest stable numeric release and the
newest non-yanked release that is eligible at the cutoff:

```shell
python3 - <<'PY'
import datetime as dt
import json
import re
import urllib.request

packages = [
    "uv", "copier", "flowmark-rs", "pytest", "pytest-sugar", "ruff",
    "codespell", "rich", "basedpyright", "funlog", "hatchling",
    "uv-dynamic-versioning",
]
now = dt.datetime.now(dt.timezone.utc)
cutoff = now - dt.timedelta(days=14)
stable = re.compile(r"^[0-9]+(?:\.[0-9]+)*$")
print(f"audit={now.isoformat()} cutoff={cutoff.isoformat()}")

for package in packages:
    url = f"https://pypi.org/pypi/{package}/json"
    with urllib.request.urlopen(url, timeout=30) as response:
        data = json.load(response)
    releases = []
    for version, files in data["releases"].items():
        if not stable.fullmatch(version):
            continue
        timestamps = [
            dt.datetime.fromisoformat(
                file["upload_time_iso_8601"].replace("Z", "+00:00")
            )
            for file in files
            if not file.get("yanked")
        ]
        if timestamps:
            key = tuple(map(int, version.split(".")))
            releases.append((key, version, min(timestamps)))
    latest = max(releases)
    eligible = max(release for release in releases if release[2] <= cutoff)
    print(
        f"{package:24} eligible={eligible[1]:12} {eligible[2].isoformat()} "
        f"latest={latest[1]:12} {latest[2].isoformat()}"
    )

for package in ["skills", "skills-ref", "get-tbd"]:
    url = f"https://registry.npmjs.org/{package}"
    with urllib.request.urlopen(url, timeout=30) as response:
        data = json.load(response)
    releases = []
    for version, metadata in data["versions"].items():
        if not stable.fullmatch(version):
            continue
        published = dt.datetime.fromisoformat(
            data["time"][version].replace("Z", "+00:00")
        )
        key = tuple(map(int, version.split(".")))
        releases.append((key, version, published, metadata))
    latest = max(releases)
    eligible = max(release for release in releases if release[2] <= cutoff)
    distribution = eligible[3]["dist"]
    print(
        f"npm:{package:20} eligible={eligible[1]:12} {eligible[2].isoformat()} "
        f"latest={latest[1]:12} integrity={distribution['integrity']} "
        f"provenance={bool(distribution.get('attestations'))}"
    )
PY
```

The npm section inventories the executable tools (`skills`, `skills-ref`, and `get-tbd`)
with registry timestamps, integrity, and provenance metadata.
Also verify each canonical repository.
Apply the same cutoff to direct and transitive packages and disable lifecycle scripts.

Check GitHub Action releases and their tag targets:

- `actions/checkout`: <https://github.com/actions/checkout/releases>
- `astral-sh/setup-uv`: <https://github.com/astral-sh/setup-uv/releases>

Pin every active action to its full commit SHA and keep the reviewed version in a
comment.
An exact version tag is not necessarily immutable: checkout v7.0.0, for example,
was published as a non-immutable release.
For setup-uv, inspect whether the selected uv version is in the action’s built-in
checksum table; when it is not, pass the official platform checksum through the action’s
`checksum` input. Review major-action runtime requirements too: checkout v7 uses Node 24
and requires Actions Runner v2.327.1 or newer.
GitHub-hosted runners satisfy this; self-hosted runners must be upgraded before adopting
it.

And check if new Python versions should be added to the test matrix.

### Supply Chain Hygiene

These practices follow
[supply-chain-hardening](https://github.com/jlevy/supply-chain-hardening), the
recommended guide for this template; see it for the full rationale and per-ecosystem
recipes.

Follow a **cooling-off period**: do not adopt any release published within the last 14
days. Fresh releases are the most likely to be yanked, to carry regressions, or (rarely)
to be a compromised/typosquatted artifact that hasn’t yet been caught.
Prefer the latest version that is both at least 14 days old and has had subsequent patch
releases without being yanked.
Generated `pyproject.toml`, CI, the generated Makefile, and the repository Makefile
enforce a 14-day cool-off window (the pinned uv accepts the relative duration
`"14 days"` directly).
Keep the project setting as the primary safe default for direct uv commands; environment
variables remain explicit per-invocation overrides.

For every changed item, verify the canonical repository and maintainer, inspect all
intervening release notes and source changes, record registry hashes or attestations,
confirm the release is not yanked, and query OSV or the relevant advisory database.
Then inspect the entire rendered lockfile diff; a clean direct-package query does not
approve changed transitive packages.

Only add or upgrade dependencies you can vet upstream (active maintenance, reputable
source, clear changelog).
Avoid introducing new dependencies when a small amount of first-party code will do.

## Step 2: Update the Template Files

In the template repo, update these files as needed:

- **Dev dependency lower bounds** in `template/pyproject.toml.jinja` (these are `>=`
  floors, not exact pins; CI enforces the cool-off via `UV_EXCLUDE_NEWER`)
- **Build backend pins** in both `[build-system].requires` and the locked `build`
  dependency group. Keep the generated non-isolated build path in sync so release
  artifacts use the lockfile-resolved graph
- **uv version** in `template/.github/workflows/ci.yml` and `publish.yml` (the
  `version:` field under `astral-sh/setup-uv`), and the matching `UV_VERSION` in this
  repo’s own `.github/workflows/ci.yml`. Update the official platform checksum beside
  every pin
- **GitHub Action full commit SHAs** and version comments in the same workflow files and
  in this repo’s own `.github/workflows/ci.yml`; keep `persist-credentials: false` where
  no later step pushes
- **Python version matrix** in `template/.github/workflows/ci.yml` and the corresponding
  classifiers in `template/pyproject.toml.jinja`
- **The agent skill** (`skills/simple-modern-uv/`): keep the pinned `uvx copier@X.Y.Z`
  invocations current (subject to the same cool-off), and update the FAQ/checklists if
  this cycle changed behavior they describe
- **Executable npm tools** in the README and CI: pin exact versions, preserve the frozen
  `before` cutoff, disable lifecycle scripts, and record registry integrity/provenance
- **Safe-default Makefile paths**: keep the 14-day default on install, upgrade, format,
  and build commands, while preserving an explicit per-invocation override
- **The project-level uv policy**: keep `exclude-newer = "14 days"` in `uv.toml` and
  select that file explicitly in the Makefile and CI, so direct standard workflows keep
  the cool-off without merging ambient user settings into `uv.lock`
- Review the [uv changes research](docs/project/research/research-uv-changes.md) for new
  uv features the template should adopt or explicitly decline
- Record the complete frozen decision in a release-specific supply-chain manifest under
  `docs/project/research/`

### Changing Template Questions (Answer-Schema Evolution)

Standing policy whenever a question is added to or changed in `copier.yml`, so existing
projects keep updating cleanly:

1. **Behavior-preserving defaults**: a new question’s default must reproduce exactly
   what the template generated before the question existed, so a vanilla
   `copier update --defaults` is a no-op.
2. **Old answer files stay valid**: never require manual edits to `.copier-answers.yml`;
   `--defaults --skip-answered` fills new keys.
3. **Hand customizations are reconciled by the skill**, not by defaults: the skill’s
   update workflow inspects project state and passes explicit `--data` (see
   [customize.md](skills/simple-modern-uv/references/customize.md)).
4. **CI guards the update path**: the `update-path` job renders the previous release and
   updates to the candidate, asserting convergence with a fresh render and that `--data`
   overrides are honored.
5. **Call it out in release notes**, naming the new keys and their defaults.

The update-path job guarantees the single jump from the most recent release to the
candidate. For a project more than one release behind, update one release tag at a time
and validate each hop; a direct multi-release jump is best-effort rather than covered by
this gate.

Then auto-format all docs so formatting stays consistent (CI’s `format-check` job
enforces this):

```shell
make format        # auto-format all Markdown docs, including *.md.jinja templates
make format-check  # check-only, to confirm nothing is left unformatted
```

This runs the pinned `uvx flowmark-rs@0.3.2 --auto` from the top-level `Makefile`, which
also applies the 14-day resolver gate by default.

## Step 3: Merge the Template Candidate

Choose the release version before downstream validation:

- **Minor** (`v0.5.0`): new or changed template questions, new files or dependency
  groups in the render, or other feature-level changes.
  Per the answer-schema policy above, the release notes must name any new question keys
  and their defaults.
- **Patch** (`v0.4.1`): routine dependency and tool-version bumps, documentation fixes,
  and changes that leave the render’s shape unchanged.

Resolve every known release blocker and finish review on the candidate PR. Mark it ready
for review, require its CI to pass, and merge it into `main`. Do not create the release
or tag yet: downstream must validate the exact merge commit first.

```shell
CURRENT_BRANCH=$(git branch --show-current)
PR_NUMBER=$(gh pr view "$CURRENT_BRANCH" --repo jlevy/simple-modern-uv \
  --json number -q '.number')
NEW_TAG="v0.X.Y"
LAST_TAG=$(gh release list --repo jlevy/simple-modern-uv --limit 1 \
  --json tagName -q '.[0].tagName')

if [ "$(gh pr view "$PR_NUMBER" --repo jlevy/simple-modern-uv \
  --json isDraft -q '.isDraft')" = "true" ]; then
  gh pr ready "$PR_NUMBER" --repo jlevy/simple-modern-uv
fi
gh pr checks "$PR_NUMBER" --repo jlevy/simple-modern-uv --watch
gh pr merge "$PR_NUMBER" --repo jlevy/simple-modern-uv --merge

TEMPLATE_COMMIT=$(gh pr view "$PR_NUMBER" --repo jlevy/simple-modern-uv \
  --json mergeCommit -q '.mergeCommit.oid')
git fetch origin main --tags
test "$(git rev-parse origin/main)" = "$TEMPLATE_COMMIT"

SOURCE_RUN_ID=$(gh run list \
  --repo jlevy/simple-modern-uv \
  --workflow CI \
  --branch main \
  --event push \
  --commit "$TEMPLATE_COMMIT" \
  --json databaseId \
  -q '.[0].databaseId')
test -n "$SOURCE_RUN_ID"
gh run watch --repo jlevy/simple-modern-uv \
  "$SOURCE_RUN_ID" --exit-status
```

The final assertion stops the release if `main` moved after the candidate merged.
Review the additional commits and select a new candidate rather than releasing an
unvalidated tip.
If GitHub has not queued the `main` run when `SOURCE_RUN_ID` is queried,
wait for it to appear and repeat the query.

## Step 4: Export the Candidate to the Downstream Repo

In the downstream repo, update from the pushed candidate commit.
The working tree must be clean before running `copier update`.

```shell
cd ../simple-modern-uv-template
git switch main
git pull --ff-only origin main
test -z "$(git status --porcelain)"
DOWNSTREAM_BRANCH="validate-${NEW_TAG}-template"
git switch -c "$DOWNSTREAM_BRANCH"

# Export the exact template candidate. This uses the _src_path already recorded in
# .copier-answers.yml, currently gh:jlevy/simple-modern-uv.
uvx --exclude-newer "14 days" copier@9.17.0 update --defaults \
  --vcs-ref "$TEMPLATE_COMMIT"
git diff --stat
```

If the downstream repo ever needs a fresh render instead of an update, instantiate with
the standard defaults:

```shell
uvx --exclude-newer "14 days" copier@9.17.0 copy --defaults \
  --vcs-ref "$TEMPLATE_COMMIT" gh:jlevy/simple-modern-uv .
```

## Step 5: Verify Locally

After the copier update, confirm everything works locally.
Use the same 14-day supply-chain cool-off the GitHub workflows set.

```shell
make install
make lint-check
make test
make build
uvx --exclude-newer "14 days" uv@0.12.0 audit --locked \
  --preview-features audit-command
```

## Step 6: Push Downstream and Confirm CI

Commit the downstream candidate on its own branch, open a PR, and wait for GitHub
Actions to finish before merging it.

```shell
git add -A
git commit -m "Validate simple-modern-uv template ${TEMPLATE_COMMIT:0:7}."
git push -u origin "$DOWNSTREAM_BRANCH"

DOWNSTREAM_PR=$(gh pr create \
  --repo jlevy/simple-modern-uv-template \
  --base main \
  --head "$DOWNSTREAM_BRANCH" \
  --title "chore: validate ${NEW_TAG} template candidate" \
  --body "Validates simple-modern-uv commit ${TEMPLATE_COMMIT} before release.")
gh pr checks "$DOWNSTREAM_PR" --watch
gh pr merge "$DOWNSTREAM_PR" --merge --delete-branch

DOWNSTREAM_COMMIT=$(gh pr view "$DOWNSTREAM_PR" \
  --repo jlevy/simple-modern-uv-template \
  --json mergeCommit -q '.mergeCommit.oid')
RUN_ID=$(gh run list \
  --repo jlevy/simple-modern-uv-template \
  --workflow CI \
  --branch main \
  --event push \
  --commit "$DOWNSTREAM_COMMIT" \
  --json databaseId \
  -q '.[0].databaseId')
test -n "$RUN_ID"
gh run watch --repo jlevy/simple-modern-uv-template "$RUN_ID" --exit-status
```

If GitHub has not queued the `main` run when `RUN_ID` is queried, wait for it to appear
and repeat the query.
The release gate is the successful `main` run for `DOWNSTREAM_COMMIT`, not only the PR’s
pre-merge checks.

Then check that **CI passes on GitHub**: this runs the full lint and test suite across
all Python versions in the matrix (e.g. 3.11, 3.12, 3.13, 3.14) on the stub test file
and template code. This is the real end-to-end validation that the template works.

If CI fails, fix issues in the template repo and repeat from Step 2.

### Skill Activation Checks

Before releasing changes that touch `skills/simple-modern-uv/`, smoke-test activation in
at least one target agent (CI validates structure and links, not activation):

- A new-project prompt ("start a new Python project called X") activates the skill
- A migration prompt ("convert this Poetry project to uv") activates the skill
- An unrelated Python prompt ("debug this stack trace") does *not* activate it
- Explicit invocation (`/simple-modern-uv` or the agent’s equivalent) loads cleanly

## Step 7: Create a Release on the Template Repo

Once CI passes downstream and this repo’s own CI is green on `TEMPLATE_COMMIT`, create a
GitHub Release on the template repo.
This command creates the version tag; do not run a separate `git tag` or
`git push --tags` first.

Review the changes and author the release notes as a file first (the gitignored `tmp/`
directory is the convention; a file keeps the shell out of the way, since notes
routinely contain backticks and `$`):

```shell
# From the template repo:
cd ../simple-modern-uv

git log "${LAST_TAG}..${TEMPLATE_COMMIT}" --oneline
git diff --stat "${LAST_TAG}..${TEMPLATE_COMMIT}"

# Write tmp/release-notes-${NEW_TAG}.md, then:
gh release create "$NEW_TAG" \
  --repo jlevy/simple-modern-uv \
  --target "$TEMPLATE_COMMIT" \
  --title "$NEW_TAG" \
  --notes-file "tmp/release-notes-${NEW_TAG}.md"
```

Structure the notes per `tbd guidelines release-notes-guidelines`: a concise summary,
then `## What's Changed` with only the applicable `### Features`, `### Fixes`,
`### Guidelines and content`, and `### Documentation` sections.
Add `## Upgrading` when existing projects need action.
Name new question keys and defaults under upgrading, state what validation backed the
release, and end with a `**Full commit history**` link to
`compare/${LAST_TAG}...${NEW_TAG}`.

Afterwards, verify the release and tag target, then confirm a fresh render records the
new tag as `_commit` in `.copier-answers.yml`:

```shell
gh release view "$NEW_TAG" --repo jlevy/simple-modern-uv \
  --json tagName,targetCommitish,isDraft
git fetch origin tag "$NEW_TAG"
test "$(git rev-list -n 1 "$NEW_TAG")" = "$TEMPLATE_COMMIT"
RELEASE_CHECK_DIR=$(mktemp -d)
uvx --exclude-newer "14 days" copier@9.17.0 copy --defaults \
  --vcs-ref "$NEW_TAG" gh:jlevy/simple-modern-uv "$RELEASE_CHECK_DIR"
grep -q "^_commit: ${NEW_TAG}$" \
  "$RELEASE_CHECK_DIR/.copier-answers.yml"
```

## Step 8: Record the Release Tag Downstream

The pre-release downstream commit validates an exact template commit.
After the release exists, update the downstream repo once more from the release tag so
`.copier-answers.yml` records the public template version.
This should either be a no-op or only change `_commit`.

```shell
cd ../simple-modern-uv-template
git switch main
git pull --ff-only origin main
RECORD_BRANCH="record-${NEW_TAG}-template"
git switch -c "$RECORD_BRANCH"
uvx --exclude-newer "14 days" copier@9.17.0 update --defaults \
  --vcs-ref "$NEW_TAG"
git diff -- .copier-answers.yml

git add -A
git commit -m "Record simple-modern-uv template ${NEW_TAG}."
git push -u origin "$RECORD_BRANCH"

RECORD_PR=$(gh pr create \
  --repo jlevy/simple-modern-uv-template \
  --base main \
  --head "$RECORD_BRANCH" \
  --title "chore: record simple-modern-uv template ${NEW_TAG}" \
  --body "Records the public ${NEW_TAG} template tag after release validation.")
gh pr checks "$RECORD_PR" --watch
gh pr merge "$RECORD_PR" --merge --delete-branch

RECORD_COMMIT=$(gh pr view "$RECORD_PR" \
  --repo jlevy/simple-modern-uv-template \
  --json mergeCommit -q '.mergeCommit.oid')
RECORD_RUN_ID=$(gh run list \
  --repo jlevy/simple-modern-uv-template \
  --workflow CI \
  --branch main \
  --event push \
  --commit "$RECORD_COMMIT" \
  --json databaseId \
  -q '.[0].databaseId')
test -n "$RECORD_RUN_ID"
gh run watch --repo jlevy/simple-modern-uv-template \
  "$RECORD_RUN_ID" --exit-status
```

If the tagged update produces no diff, skip the commit and second downstream PR. If
GitHub has not yet queued the final `main` run, wait for it to appear and repeat the
`RECORD_RUN_ID` query.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
