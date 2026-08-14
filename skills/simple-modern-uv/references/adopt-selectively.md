# Adopting Selected simple-modern-uv Features

Use this workflow when the user wants specific practices without restructuring the whole
repository or enrolling it in Copier updates.
Preserve the project’s existing architecture and choose the smallest coherent set of
changes.

If the user instead wants the repository fully converted and updateable through Copier,
use `adopt-existing.md`.

## Feature Bundles and Dependencies

Treat each row as a coherent bundle.
Adapt filenames and commands to existing project conventions rather than assuming every
file must be copied verbatim.

| Feature | Reference pieces | Dependencies and boundaries |
| --- | --- | --- |
| Agent guidance | `AGENTS.md`; optional `CLAUDE.md` import | Preserve existing agent instructions and merge only durable commands and conventions |
| uv dependency management | `uv.toml`, `uv.lock`, PEP 621 dependencies and groups, install/upgrade Make targets | Does not require changing a working build backend, package layout, or versioning scheme |
| Linting and typing | `devtools/lint.py`, Ruff, codespell, BasedPyright settings and dev dependencies, lint Make targets | Adopt individual tools only when requested; translate existing ignores and avoid a repository-wide cleanup unrelated to the request |
| Tests | pytest dependencies and settings, `tests/`, test Make target | Preserve the existing test layout and plugins unless they conflict |
| GitHub Actions CI | pinned checkout/setup-uv actions, Python matrix, locked install, lint and test steps | Requires commands and lock policy that work locally; adapt rather than duplicate an existing workflow |
| Packaging and versions | Hatchling, uv-dynamic-versioning, locked build group, tag-derived versions | Material release-model change; require explicit user agreement before replacing another backend or version source |
| PyPI publishing | OIDC workflow and `docs/publishing.md` | Requires compatible packaging/versioning and explicit intent to publish; omit for private projects and unpublished apps |
| Developer docs | README links plus installation, development, and publishing guides | Merge useful sections; never replace substantive project documentation with template placeholders |
| Supply-chain policy | 14-day resolution cool-off, reviewed pins, checksums, full action SHAs, locked CI | Apply to the package runner and CI paths actually adopted by the project |
| Template lineage | `.copier-answers.yml` | **Never adopt ad hoc.** It is valid only after a deliberate full migration or fresh render |

## Workflow

1. Read repository instructions and inspect the working tree, package metadata,
   dependency files, tool configuration, CI, and the exact feature request.

2. State the inferred adoption level and map each relevant bundle to **adopt**,
   **adapt**, **preserve**, or **defer**. Ask once about any material choice, such as
   replacing a build backend, changing supported Python versions, or removing an
   established tool.

3. If upstream files are useful as a reference, render the pinned template into a
   temporary sibling directory.
   Do not render over the target repository.

   ```bash
   uvx --exclude-newer "14 days" copier@9.17.0 copy --defaults \
     --data package_name=<existing-package-name> \
     --data package_github_org=<existing-org> \
     gh:jlevy/simple-modern-uv ../<project>-smu-reference
   ```

4. Apply the smallest complete dependency closure.
   Merge configuration into existing files, retain project-specific settings, and avoid
   drive-by source formatting or type fixes.

5. Validate the selected feature locally.
   If CI changes, run the same install, lint, and test commands outside CI and parse the
   workflow YAML. If packaging changes, build both wheel and sdist.

6. Summarize adopted, adapted, preserved, deferred, and removed pieces.
   State explicitly that the project is selectively or core-toolchain aligned and is
   **not** Copier-managed.

## Moving to Full Adoption Later

Selective adoption is intentionally reversible.
A later full migration should render the then-current template, compare it with the
project, preserve the adaptations made here, and only then add `.copier-answers.yml`. Do
not manufacture template history from the files copied during selective adoption.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
