# Updating This Template

This doc covers the full cycle for keeping the
[simple-modern-uv](https://github.com/jlevy/simple-modern-uv) template’s dependencies
and tools up to date, then verifying the changes end-to-end.

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

Release rule: the downstream repo is the release gate when it is reachable.
Push the template candidate, export it into `jlevy/simple-modern-uv-template`, and wait
for downstream CI to pass before creating a GitHub release for this template.
The commands below assume the downstream repo is cloned next to this repo as
`../simple-modern-uv-template`.

**Releasing without downstream access** (for example, an agent session scoped to this
repo only): this repo’s CI on the candidate commit is the gate — all jobs must be green
— plus a local render verification (Step 5 run against a fresh render).
Create the release on that basis, then complete the downstream export and tag recording
(Steps 4–6 and 8) as post-release verification from an environment with access.
If downstream then fails, fix forward with a patch release.

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
- **The project-level uv policy**: keep `tool.uv.exclude-newer = "14 days"` so direct uv
  commands cannot silently omit the cool-off
- Review `docs/project/research/research-uv-changes.md` for new uv features the template
  should adopt or explicitly decline
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
   `skills/simple-modern-uv/references/customize.md`).
4. **CI guards the update path**: the `update-path` job renders the previous release and
   updates to the candidate, asserting convergence with a fresh render and that `--data`
   overrides are honored.
5. **Call it out in release notes**, naming the new keys and their defaults.

Then auto-format all docs so formatting stays consistent (CI’s `format-check` job
enforces this):

```shell
make format        # auto-format all Markdown docs, including *.md.jinja templates
make format-check  # check-only, to confirm nothing is left unformatted
```

This runs the pinned `uvx flowmark-rs@0.3.1 --auto` from the top-level `Makefile`, which
also applies the 14-day resolver gate by default.

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
uvx --exclude-newer "14 days" copier@9.16.0 update --defaults \
  --vcs-ref "$TEMPLATE_COMMIT"
git diff --stat
```

If the downstream repo ever needs a fresh render instead of an update, instantiate with
the standard defaults:

```shell
uvx --exclude-newer "14 days" copier@9.16.0 copy --defaults \
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
uvx --exclude-newer "14 days" uv@0.11.25 audit --locked \
  --preview-features audit-command
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

Once CI passes downstream (and this repo’s own CI is green on the candidate commit),
create a GitHub release on the template repo.

Pick the version by what changed:

- **Minor** (`v0.4.0`): new or changed template questions, new files or dependency
  groups in the render, or other feature-level changes.
  Per the answer-schema policy above, the release notes must name any new question keys
  and their defaults.
- **Patch** (`v0.3.1`): routine dependency and tool-version bumps, doc fixes, and
  changes that leave the render’s shape alone.

Review the changes and author the release notes as a file first (the gitignored `tmp/`
directory is the convention; a file keeps the shell out of the way, since notes
routinely contain backticks and `$`):

```shell
# From the template repo:
cd ../simple-modern-uv

LAST_TAG=$(gh release list --repo jlevy/simple-modern-uv --limit 1 --json tagName -q '.[0].tagName')
NEW_TAG="v0.X.Y"

git log "${LAST_TAG}..HEAD" --oneline
git diff --stat "${LAST_TAG}..HEAD"

# Write tmp/release-notes-${NEW_TAG}.md, then:
gh release create "$NEW_TAG" \
  --repo jlevy/simple-modern-uv \
  --target "$TEMPLATE_COMMIT" \
  --title "$NEW_TAG" \
  --notes-file "tmp/release-notes-${NEW_TAG}.md"
```

Structure the notes per `tbd guidelines release-notes-guidelines` (or the same format
the template’s own `docs/publishing.md` describes): a one-paragraph summary of the
release’s theme, `### New Features` / `### Improvements` sections, an upgrading note for
existing projects, new question keys with their defaults (per the answer-schema policy),
a statement of what validation backed the release, and the
`compare/${LAST_TAG}...${NEW_TAG}` link.

Afterwards, verify the release: the tag points at `$TEMPLATE_COMMIT`
(`gh release view "$NEW_TAG" --json tagName,targetCommitish,isDraft`) and a fresh
`uvx --exclude-newer "14 days" copier@9.16.0 copy gh:jlevy/simple-modern-uv` records the
new tag as `_commit` in `.copier-answers.yml`.

## Step 8: Record the Release Tag Downstream

The pre-release downstream commit validates an exact template commit.
After the release exists, update the downstream repo once more from the release tag so
`.copier-answers.yml` records the public template version.
This should either be a no-op or only change `_commit`.

```shell
cd ../simple-modern-uv-template
uvx --exclude-newer "14 days" copier@9.16.0 update --defaults \
  --vcs-ref "$NEW_TAG"
git diff -- .copier-answers.yml

git add -A
git commit -m "Record simple-modern-uv template ${NEW_TAG}."  # skip if no diff
git push origin main
```

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
