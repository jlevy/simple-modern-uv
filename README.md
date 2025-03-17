# simple-modern-uv

[![As usual, XKCD has a comic for
this](https://imgs.xkcd.com/comics/python_environment.png)](https://xkcd.com/1987/)

(As usual, XKCD has a comic for this.
Approriately enough, the comic is out of date.)

- In the beginning, there was a hack called
  [`setup.py`](https://github.com/pypa/setuptools) for packaging (1990s–2000s) and it
  was not good

- … then came [`virtualenv`](https://github.com/pypa/virtualenv),
  [`pip`](https://github.com/pypa/pip), and `requirements.txt` for isolated environments
  (2008–2011). Yet confusion still reigned

- … and meanwhile, [`conda`](https://github.com/conda/conda),
  [`brew`](https://github.com/Homebrew/brew), and
  [`PyInstaller`](https://github.com/pyinstaller/pyinstaller) vied to rule the system
  installations (2010s).

- Years of dissatisfaction led to the spread of a new religion,
  [`pyproject.toml`](https://github.com/pypa/pyproject.toml).
  Adherents like [`poetry`](https://github.com/python-poetry/poetry) and
  [`pipx`](https://github.com/pypa/pipx) promised peace and prosperity (2020s) yet
  somehow, life felt mostly the same …

- But suddenly there was an invasion of AI robots.
  New rebel forces [`uv`](https://github.com/astral-sh/uv) and
  [`pixi`](https://github.com/prefix-dev/pixi) aligned with Rust gathered strength …

* * *

## What is This?

**simple-modern-uv** is a minimal, modern **Python project template** for new projects
(Python 3.10–3.13) based on **uv**. This template aims to be a good base for serious
work but also simple so it's an easy option for any small project, like an open source
library or tool.

I'm sharing this template, which I am using myself as I migrate from Poetry to uv.
I'd originally been a little hesitent to switch tooling too soon, but the advantages of
uv have become too numerous to ignore.
(See [simple-modern-poetry](https://github.com/jlevy/simple-modern-poetry) if you still
want to use Poetry.)

The accidents of history make it still surprisingly hard to learn best practices for
setting up Python projects and dependencies.
I've drawn some of it from [other templates](#alternatives) and wanted it to be modern
and "done right" but *absolutely as simple as possible*:

- [**uv**](https://github.com/astral-sh/uv) project setup and dev workflows.

- Simple [**GitHub Actions**](https://github.com/actions/setup-python) CI workflows,
  including (optional) **publishing to PyPI**.

- [**Dynamic versioning**](https://github.com/ninoseki/uv-dynamic-versioning/) so
  release and package publication is as simple as creating a tag/release on GitHub (no
  machinery needed to update/commit files every release).

- Standard, modern linting, formatting, and testing with
  [**ruff**](https://github.com/charliermarsh/ruff),
  [**mypy**](https://github.com/python/mypy),
  [**codespell**](https://github.com/codespell-project/codespell), and
  [**pytest**](https://github.com/pytest-dev/pytest).

- A **starter readme** with handy reminders on uv Python setup/installation and basic
  dev workflows using to save time for you and users or collaborators.

- The whole template is **only ~300 lines of code** so you can read it and change what
  you want.

It doesn't have lots of options or try to use every bell and whistle.
It just adds the above essentials.

Finally, the template is in [**copier**](https://github.com/copier-org/copier) format,
which (unlike with many templates) means you can
[pull future changes](#updating-your-project-template) to the this template back into
your project any time.

It should work whenever you want to use modern Python and uv with a build workflow in
GitHub.

## What This Template Does Not Include

This template **does not** handle:

- Using Docker

- Building websites or docs, e.g. with [mkdocs](https://github.com/mkdocs/mkdocs)

- Using [Conda](https://github.com/conda/conda) for dependencies (but note many deep
  learning libraries like PyTorch now support pip so this isn't as necessary as often as
  it used to be)

- Using a code repo or build system that isn't GitHub and GitHub Actions

- Boilerplate docs or project management of any kind, like issue templates, contributing
  guidelines, code of conduct, etc.

If you want them, just add these yourself.
:) Or see [below](#alternatives) for other templates.

## How to Use This Template

> [!NOTE]
> 
> By default this template uses MIT license.
> If you want a different license or are not publishing your project as open source,
> update `license` in pyproject.yaml and the LICENSE file.
> If desired, you may delete the `.github/workflows/publish.yml` file if you are not
> publishing to PyPI.

The template can be used in two ways.
Option 1 is quickest.
For more flexibility, consider Option 2.

### Option 1: GitHub Template

Just use
[**this template repository**](https://github.com/jlevy/simple-modern-uv-template),
which is the output of this template.

Go there and hit the "Use this template" button.
Once you have the code, search for **`_changeme_`** for all field names like project
name, author, etc. You may also want to change the license/copyright.

### Option 2: Use Copier

This template uses **copier**, which seems like the best tool nowadays for project
templates. Using copier is the recommended approach since it then lets you instantiate
the template variables, but it requires a few more commands.

> [!NOTE]
> 
> Copier has the cool feature to [update your project
> template](#updating-your-project-template) as this template improves in the future.

To create a new project repo with `copier`:

```shell
# Install copier via uv:
uvx install copier

# Clone this template:
copier copy gh:jlevy/simple-modern-uv your-project-name
# Then follow the instructions.
```

You can enter names for the project, description, etc., or just press enter and later
look for `_changeme_` in the code.

Once you have the template set up, you will need to check the code into Git for uv to
work. [Create a new GitHub
repo](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository)
and add your initial code:

```shell
cd PROJECT
git init
# Make license or other initial adjustments if needed.
git add .
git commit -m "Initial commit from simple-modern-uv."
# Create repo on GitHub.
git remote add origin git@github.com:OWNER/PROJECT.git  # or https://github.com/...
git branch -M main
git push -u origin main
```

## Getting Started on Your Project

In the template project itself, the
[**default readme**](https://github.com/jlevy/simple-modern-uv-template) and the file
[**development.md**](https://github.com/jlevy/simple-modern-uv-template) covers the
install and build workflows.

## Updating Your Project Template

If you use Option 2 or if you pick Option 1 and correctly fill in your
`.copier-answers.yml` file, you have the option to update your project with any future
updates to this template at any time.

If this file is updated with your project name etc., then you can
[update your project](https://copier.readthedocs.io/en/latest/updating/) to reflect any
changes to this template by running `copier update`.

## Alternatives

There are several other good uv templates, such as
[cookiecutter-uv](https://github.com/fpgmaas/cookiecutter-uv) and
[copier-uv](https://github.com/pawamoy/copier-uv) you may wish to consider.

This template takes a different more minimalist philosophy.
I found existing templates to have machinery or files you often don't need.
And it's hard to maintain a complex template repo.
This is intended instead to be a very simple template.
You can always add to it if you want.

[Poetry](https://python-poetry.org/docs/basic-usage/) is a good option for managing
dependencies and is not as new as uv and arguably more mature (it just hit version 2.0).
For [Conda](https://github.com/conda/conda) dependencies, also consider the newer
[pixi](https://github.com/prefix-dev/pixi/) package manager.

## Contributing

I'm new to uv, so please help me improve this!
Please use the Discussions thread with any feedback or suggestions.
PRs welcome on [this repository](https://github.com/jlevy/simple-modern-uv) (not on the
GitHub template repo, which mirrors this one).
