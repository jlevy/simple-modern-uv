# Minimal Python Project Template for VS Code

This is a minimal, modern Python project template for new projects, optimized for VS Code. It's based on [uv](https://docs.astral.sh/uv/) and is designed to be a simple, straightforward starting point for any project.

## Features

- **`uv` for lightning-fast project and dependency management.**
- **`ruff` for linting and formatting.**
- **`basedpyright` for type checking.**
- **`pytest` for testing.**
- **VS Code settings (`.vscode/settings.json`) are included for a seamless, out-of-the-box experience with auto-formatting and linting.**
- **GitHub Copilot instructions (`.github/copilot-instructions.md`) are provided to guide the AI.**

## How to Use

This template uses [Copier](https://github.com/copier-org/copier). To create a new project:

```shell
# Install Copier if you don't have it
uv tool install copier

# Create a new project from the template
copier copy gh:ElModdy/simple-modern-uv YOUR_NEW_PROJECT_NAME
```

Copier will prompt you for the project name, description, and other details.

Once the project is created, navigate into the directory and run:

```shell
make install
```

This will set up the virtual environment and install all dependencies.
