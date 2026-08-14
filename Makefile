# Makefile for maintaining the simple-modern-uv template repo itself.
#
# Note: this is NOT the Makefile that ships to generated projects. That one is
# template/Makefile (rendered downstream). This Makefile is only for working on
# the template repo, mainly keeping the docs auto-formatted.

.DEFAULT_GOAL := format

# Safe default for every uv/uvx resolution invoked through this Makefile.
UV_EXCLUDE_NEWER ?= 14 days
export UV_EXCLUDE_NEWER

# Pinned for reproducibility and supply-chain hygiene (see updating.md).
FLOWMARK := uvx flowmark-rs@0.3.2

# Format all Markdown docs, including *.md.jinja templates. Excluded paths
# (tool-managed dirs, attic/) live in .flowmarkignore.
FLOWMARK_ARGS := --auto --extend-include '*.md.jinja'

.PHONY: format format-check

# Auto-format docs in place.
format:
	$(FLOWMARK) $(FLOWMARK_ARGS) --inplace --nobackup .

# Check-only, matching format but non-mutating (for verifying before a release).
format-check:
	$(FLOWMARK) $(FLOWMARK_ARGS) --check .
