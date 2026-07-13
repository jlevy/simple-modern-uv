# Customizing a simple-modern-uv Project

Common customizations after (or during) setup.
Where a customization maps to a template question, prefer answering the question over
hand-editing: hand edits to template-managed files can be reverted by a later
`copier update` (see “Reconciling New Questions on Update” below).

## Changing the License

Preferred: set the `package_license` answer (`MIT`, `Apache-2.0`, `BSD-3-Clause`,
`AGPL-3.0-or-later`, `Proprietary`, or `None` to decide later) when rendering, or
re-answer it later with:

```bash
uvx --exclude-newer "14 days" copier@9.16.0 update --data package_license=Apache-2.0
```

This updates the `LICENSE` file and the `license` field in `pyproject.toml` together,
and records the answer in `.copier-answers.yml`. `None` renders no `LICENSE` file and no
`license` field; re-answer the question when the project picks one.
For a license outside the template’s choices: pick `Proprietary` (so the template stops
managing it), then replace `LICENSE` and set `license` in `pyproject.toml` to the
correct SPDX identifier yourself.

## Private or Unpublished Packages

Set `publish_to_pypi=false` (at render time, or via
`copier update --data publish_to_pypi=false`). This removes
`.github/workflows/publish.yml` and `docs/publishing.md`, and adds the
`Private :: Do Not Upload` classifier so PyPI rejects an accidental upload.
Everything else (CI, lint, tests, versioning) keeps working.
To start publishing later, flip the answer back the same way, then do the one-time
Trusted Publisher setup in `docs/publishing.md`.

## Reconciling New Questions on Update

When the template adds questions over time, a project that predates them has no recorded
answer, and `copier update --defaults` fills in the default, which can contradict hand
edits made before the question existed.
Before updating an older project, check its actual state and pass explicit `--data`:

- Hand-replaced license?
  Pass the matching `package_license` (or `Proprietary` for anything custom).
- Deleted `publish.yml` by hand, or has the `Private :: Do Not Upload` classifier?
  Pass `publish_to_pypi=false`.

Rule of thumb: defaults describe a fresh project, not yours; anywhere the project
visibly deviates from a fresh render, make the answer explicit.

## Apps and CLIs (vs. Libraries)

- Entry points live in `[project.scripts]`: `mycli = "my_module.cli:main"`; then
  `uv run mycli` works and installs expose the command.
- An app that’s not a library usually wants `publish_to_pypi=false`; it still gets the
  full dev workflow.
- For a long-lived service, consider pinning the Python version with a `.python-version`
  file (uv reads it automatically).

## Other Common Tweaks

- **Line length**: `[tool.ruff] line-length` in `pyproject.toml` (default 100; black
  uses 88).
- **Stricter/looser type checking**: toggle the commented `report*` settings in
  `[tool.basedpyright]`; the template ships a pragmatic middle ground.
- **More ruff rules**: uncomment entries in `[tool.ruff.lint] select` (e.g. `"D"` for
  docstring rules, `"SIM"` for simplifications).
- **OS matrix in CI**: edit `os:` in `.github/workflows/ci.yml`
  (`["ubuntu-latest", "macos-latest", "windows-latest"]`).
- **Spell-check exceptions**: `[tool.codespell] ignore-words-list`.

After any customization, re-run `make lint` and `make test`.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
