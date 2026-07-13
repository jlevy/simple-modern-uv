# Research: uv Changes Relevant to This Template

**Last updated:** 2026-07-12

**Author:** Joshua Levy (with agent assistance)

**Status:** Maintained (review at each dependency-update cycle; see `updating.md`)

## Overview

This template was created in March 2025, when uv was on 0.6.x. This living doc tracks
uv’s evolution since then, focused on what matters to the template: defaults, build
backends, publishing, supply-chain features, and anything that would change the
template’s recommendations.
At the v0.4.0 dependency freeze (2026-07-13T03:27:33Z), the latest uv was **0.11.28**.
The template pins **0.11.25**, the newest version clearing the exact 14-day supply-chain
cutoff. See the [release manifest](research-v0.4.0-supply-chain-manifest.md) for dates
and provenance.

## Timeline of Notable Changes

- **0.6.x (Feb–Apr 2025)**: `uv publish` stabilized out of preview (the template’s
  publish flow rests on this).
  Lockfile gained a `revision` field.
  Stricter validation of extras and dependency groups.
- **0.7.x (Apr–Jul 2025)**: `uv version` redesigned to read/bump the *project* version
  (`uv self version` shows uv’s own); `--bump major/minor/patch` added.
  Auth failures (401/403) now halt index search.
  **`uv_build` declared stable** (0.7.19): a fast build backend, pure-Python only.
- **0.8.x (Jul–Oct 2025)**: **`uv_build` became the default backend for
  `uv init --package`/`--lib`** (hatchling remains fully supported).
  `uv python install` installs versioned executables (`python3.13`) onto PATH by
  default. **`uv format` introduced** (preview; delegates to a pinned Ruff).
- **0.9.x (Oct 2025–Feb 2026)**: default Python bumped to **3.14** (3.14.0 final, Oct
  2025); free-threaded 3.14+ usable without opt-in.
  `UV_EXCLUDE_NEWER` accepts relative durations like `"14 days"` (the template’s CI
  relies on this; hence `required-version = ">=0.9"`).
- **0.10.x (Feb–Mar 2026)**: `uv python upgrade`, `uv add --bounds`, and
  `uv workspace list/dir` stabilized.
  `uv venv` requires `--clear` to overwrite.
  `uv format` moved to Ruff 0.15 and the 2026 style.
- **0.11.x (Mar 2026–now)**: TLS moved to OS-native verification (`--native-tls`
  deprecated in favor of `--system-certs`). **`uv audit`** (preview; announced
  2026-06-08): scans `uv.lock` against the OSV database, with
  `--ignore`/`--ignore-until-fixed`. Opt-in **malware checks** on `uv add`/`uv sync` via
  `UV_MALWARE_CHECK=1` (0.11.16+). **`uv check`** (0.11.18, preview): runs Astral’s ty
  type checker. Python 3.15 betas are available in managed downloads; 3.15 final is
  expected around October 2026. **0.11.25 hardens tar handling** against parser
  differentials and rejects malformed or ambiguous source distributions that older uv
  versions could accept.

(Compiled from uv release notes and the Astral blog; re-verify details against the
[changelog](https://github.com/astral-sh/uv/blob/main/CHANGELOG.md) when updating this
doc.)

## Decisions and Action Items for the Template

1. **Stay on hatchling with uv-dynamic-versioning** (decision).
   `uv_build` is uv’s default backend and production-stable, but it is deliberately
   minimal: no plugin mechanism, so no dynamic versioning from git tags, which is core
   to this template’s release model.
   Revisit if uv grows native dynamic versioning.
   The build backends are exact-pinned and mirrored in a locked `build` dependency
   group; release builds use `--no-build-isolation` so `uv.lock` covers the build graph.
2. **`[tool.uv] required-version = ">=0.9"`** (adopted): fails fast on uv versions that
   predate relative-duration `UV_EXCLUDE_NEWER`.
3. **Watch `uv audit` and `UV_MALWARE_CHECK`**: `uv audit` is old enough to use as an
   additional release-time check, but remains preview functionality in 0.11.25. Do not
   make a preview command part of generated-project CI until it stabilizes.
   Continue watching the opt-in malware check for the same reason.
4. **Keep `devtools/lint.py` over `uv format`/`uv check`** (decision).
   One command runs codespell, ruff check, ruff format, and basedpyright together, which
   neither uv command covers; `uv check` is also ty-based and preview (see the
   [type-checker research doc](research-python-type-checkers.md)).
5. **Python 3.15**: add to the CI matrix and classifiers when final (~Oct 2026).
6. **uv pin currency**: bump the pinned uv in `template/.github/workflows/*` at each
   update cycle to the newest version clearing the 14-day cool-off (0.11.25 at the
   v0.4.0 freeze). Update the setup-uv action and official platform checksum in the same
   reviewed change.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
