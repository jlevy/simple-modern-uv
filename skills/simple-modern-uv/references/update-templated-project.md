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
concrete finding.
Check the template release notes, but treat the actual rendered diff as
the change under review.
Once the update supplies `uv.toml` and explicit `UV_CONFIG_FILE` settings, remove any
legacy `UV_NO_CONFIG` environment variables or command wrappers.
Those workarounds disable the project policy that now owns the required uv version and
cooling-off window.

If one approved package is exempt from the cool-off, audit publication dates for the
entire resolved graph afterward.
Constrain unrelated recent transitive packages with the ecosystem’s native override
mechanism; an exception for one first-party package is not an exception for its
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
