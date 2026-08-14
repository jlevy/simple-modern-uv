# Updating a Template-Managed Project

Use this workflow only when the project contains `.copier-answers.yml` from
simple-modern-uv. If it does not, choose selective adoption or full migration instead of
inventing template lineage.

## Inspect Before Updating

Require a clean working tree and work on a branch.
Read `.copier-answers.yml`, inspect the project’s actual license and publishing state,
and compare its answer keys with the current `copier.yml`.

When the template has questions the project has never answered, pass explicit `--data`
values matching the project’s existing behavior.
Defaults describe a fresh project and must not silently re-license a package or restore
a deliberately removed publish workflow.
See [customize.md](customize.md) for the reconciliation rules.

## Apply the Update

```bash
uvx --exclude-newer "14 days" copier@9.17.0 update --defaults --skip-answered
```

Add reviewed `--data key=value` arguments for missing answers or intentional changes.
Use a specific `--vcs-ref` when the user requests a pinned template release.

Inspect the complete diff.
Resolve every `*.rej` file and conflict marker while preserving the project’s intent.
Check the template release notes, but treat the actual rendered diff as the change under
review.

## Verify and Report

Run `make install`, `make lint`, and `make test`; for publishable projects, also run
`make build`. Validate any changed workflow YAML and confirm `.copier-answers.yml`
records the intended template revision and answers.

Report upstream changes adopted unchanged, local adaptations retained, relevant features
deferred, and superseded files removed.
The result remains full template-managed even when documented project-specific
deviations are preserved.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
