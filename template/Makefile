# Makefile for easy development workflows.
# See docs/development.md for docs.
# Note GitHub Actions call uv directly, not this Makefile.

.DEFAULT_GOAL := default

# Safe default for every dependency resolution invoked through this Makefile.
UV_EXCLUDE_NEWER ?= 14 days
export UV_EXCLUDE_NEWER

.PHONY: default install lint lint-check test upgrade build clean

default: install lint test

install:
	uv sync --all-extras --all-groups

lint:
	uv run python devtools/lint.py

# Check-only lint, matching CI (does not modify files).
lint-check:
	uv run python devtools/lint.py --check

test:
	uv run pytest

upgrade:
	uv sync --upgrade --all-extras --all-groups

build: install
	uv build --no-build-isolation

clean:
	-rm -rf dist/
	-rm -rf *.egg-info/
	-rm -rf .pytest_cache/
	-rm -rf .ruff_cache/
	-rm -rf .mypy_cache/
	-rm -rf .venv/
	-find . -type d -name "__pycache__" -exec rm -rf {} +
