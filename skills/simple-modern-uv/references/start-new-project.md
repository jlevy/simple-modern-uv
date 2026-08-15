# Starting a New Project

Create a new, fully template-managed Python project.

## Gather and Confirm the Answers

Use the interview contract in [SKILL.md](../SKILL.md).
Infer author name, email, and GitHub organization from git and GitHub state, then
confirm the package name, derived module, description, license, publishing choice, and
inferred identity in one message.

## Render the Project

Replace the example values and omit keys that should keep their defaults:

```bash
uvx --exclude-newer "14 days" copier@9.17.0 copy --defaults \
  --data package_name=acme-widgets \
  --data "package_description=One-line description" \
  --data "package_author_name=Jane Doe" \
  --data package_author_email=jane@example.com \
  --data package_github_org=acme \
  --data package_license=MIT \
  --data publish_to_pypi=true \
  gh:jlevy/simple-modern-uv acme-widgets
```

`package_module` derives automatically from `package_name`.

## Initialize and Install

Commit before the first sync so dynamic versioning sees a real git history instead of
installing the editable project as version `0.0.0`:

```bash
cd acme-widgets
git init --initial-branch=main
git add .
git commit -m "Initial commit from simple-modern-uv."
make install
git add uv.lock
git commit -m "Add uv.lock."
```

## Verify and Hand Off

Run `make lint` and `make test`. For a publishable package, also run `make build` and
confirm the wheel has a sensible development version.

Offer the next useful steps: fill in `README.md`, create and push to an empty GitHub
repository, configure the PyPI Trusted Publisher if applicable, and tag `v0.1.0` when
the first release is ready.
Report the result as full template-managed adoption.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
