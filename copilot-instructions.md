# Repository Architecture

This repository maintains a Copier project template.

- `reference/` is the canonical, fully rendered example project.
- `template/` contains Copier/Jinja source files used to generate projects.
- `scripts/build_template.py` generates or synchronizes `template/` from `reference/`.
- Template-specific substitutions use `.jinja` files and the `{{ package_module }}` directory placeholder.
- `copier.yml` defines Copier questions and defaults.

## Editing Rules

- Make behavioral changes in `reference/` first.
- Run `uv run python scripts/build_template.py` after changing generated template content.
- Do not manually edit generated files in `template/` unless the file is intentionally template-only.
- Keep `reference/` and `template/` aligned after regeneration.

## Validation

- Run `uv run python scripts/build_template.py` to regenerate the template.
- Run the relevant checks described in `README.md` or `docs/DEVELOPMENT.md`.
- When changing Copier behavior, generate a temporary project with Copier and validate its tests.
