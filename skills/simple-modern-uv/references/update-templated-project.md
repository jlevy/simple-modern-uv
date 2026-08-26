# Updating a Template-Managed Project

Use this workflow only when the project contains `.copier-answers.yml` from
simple-modern-uv. If it does not, choose selective adoption or full migration instead of
inventing template lineage.

## Inspect Before Updating

Require a clean working tree and work on a branch.
Read `.copier-answers.yml`, inspect the project’s actual license and publishing state,
and compare its answer keys with the current `copier.yml`.

Write down the project decisions an update must preserve:

- supported Python versions and operating systems
- package layout, build backend, dependencies, and entry points
- version/tag convention, default branch, and publishing destination
- generated-document sources and extra test suites
- lint selections, ignore lists, type-checker strictness, and local quality gates
- non-Python package managers, zero-install tools, and their lockfiles
- repository policy in `AGENTS.md`, `CLAUDE.md`, and equivalent instruction files

When the template has questions the project has never answered, pass explicit `--data`
values matching the project’s existing behavior.
Defaults describe a fresh project and must not silently re-license a package or restore
a deliberately removed publish workflow.
See [customize.md](customize.md) for the reconciliation rules.

## Choose the Target

Update directly from the recorded `_commit` to the reviewed target release by default.
Copier reconstructs the old template render, calculates the project’s local changes, and
reapplies them to the target; version-gated migrations can cover the complete old-
to-new range. Walking every intervening release multiplies obsolete conflicts without
improving that model.

Use an intermediate tag only when the template declares a staged migration requirement
for that range or when a direct trial needs a diagnostic checkpoint.
For a long-range update or a heavily customized project, trial the direct update in an
isolated clone or worktree first and inspect its final conflict set before changing the
working branch.

## Apply the Update

```bash
uvx --exclude-newer "14 days" copier@9.17.0 update --defaults --skip-answered
```

Add reviewed `--data key=value` arguments for missing answers or intentional changes.
Use `--vcs-ref TAG` for the selected release and `--pretend` first when you need to
confirm target selection without changing files.

Inspect the complete diff.
Resolve every `*.rej` file and conflict marker against the preservation inventory,
classifying each template change as adopted, adapted, preserved, deferred, or removed.
Treat instruction files as protected policy surfaces and merge applicable upstream
guidance into local rules rather than replacing them wholesale.
Do not add broad Ruff or BasedPyright suppressions merely because a newer template uses
different fresh-project defaults; widen an established project’s exemptions only for a
concrete finding. A template release can also tighten a default, by dropping a Ruff
`ignore` entry or re-enabling a BasedPyright rule.
Those lines are rarely edited locally, so the update applies them without conflict and
the project’s existing code fails `make lint` on the next run.
Treat the new findings as findings: fix them, or reinstate that specific exemption with
a recorded reason.
Do not disable a broader rule set to clear them, and do not revert the
whole hunk without deciding rule by rule.
Check the template release notes, but treat the actual rendered diff as the change under
review.
Once the update supplies `uv.toml` and explicit `UV_CONFIG_FILE` settings, remove
any legacy `UV_NO_CONFIG` environment variables or command wrappers.
Those workarounds disable the project policy that now owns the required uv version and
cooling-off window.

If the update adds `environment: pypi` to an existing publish workflow, report the
matching external configuration step.
A PyPI Trusted Publisher with a blank environment continues to accept the workflow but
remains unconstrained; set its environment to `pypi` in the project’s PyPI publishing
settings to enforce the boundary.
Required reviewers or selected-tag restrictions are optional GitHub environment
protections, not consequences of the name alone.
Also inspect the repository’s authority model: a release-only trigger removes the
ordinary manual-branch path, but anyone allowed to create a matching release tag may
still invoke it. If some writers should not publish, add a tag ruleset that restricts
creation and updates of release-pattern tags to release maintainers, and/or require an
environment reviewer.
A selected-tag environment rule filters refs but does not control who creates a matching
tag.

If one approved uv package is exempt from the cool-off, keep the global gate and record
an absolute `exclude-newer-package` cutoff in `uv.toml` just after the approved
release’s last artifact upload.
Resolve only that package with
`UV_CONFIG_FILE="$PWD/uv.toml" uv lock --upgrade-package package-name`, inspect the
complete lockfile diff, and commit the policy with the lock so `--locked` CI sees the
same resolution settings.
Remove the override and relock after the release clears the normal window.
For another ecosystem without a package-scoped age gate, audit publication dates for the
entire resolved graph and constrain unrelated recent transitives with its native
override mechanism. An exception for one first-party package is not an exception for its
dependencies.

## Verify and Report

Run `make install`, `make lint-check`, and `make test`; for publishable projects, also
run `make build`. Validate changed workflow YAML, inspect wheel and source-distribution
contents, and confirm `.copier-answers.yml` records the intended template revision and
answers.

Report upstream changes adopted unchanged, local adaptations retained, relevant features
deferred, and superseded files removed.
The result remains full template-managed even when documented project-specific
deviations are preserved.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
