# Research: uv Changes Relevant to This Template

**Last updated:** 2026-08-14

**Author:** Joshua Levy (with agent assistance)

**Status:** Maintained (review at each dependency-update cycle; see
[updating.md](../../../updating.md))

## Overview

This template was created in March 2025, when uv was on 0.6.x. This living doc tracks
uv’s evolution since then, focused on what matters to the template: defaults, build
backends, publishing, supply-chain features, and anything that would change the
template’s recommendations.
At the v0.5.0 dependency freeze (2026-08-14T18:59:05Z), the latest uv was **0.12.4**.
The template pins **0.12.0**, the newest version clearing the exact 14-day supply-chain
cutoff. Version 0.12.1 missed the cutoff by 44 minutes, so it remains deferred with the
newer patches. See the [release manifest](research-v0.5.0-supply-chain-manifest.md) for
dates and provenance.

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
- **0.11.x (Mar–Jul 2026)**: TLS moved to OS-native verification (`--native-tls`
  deprecated in favor of `--system-certs`). **`uv audit`** (preview; announced
  2026-06-08): scans `uv.lock` against the OSV database, with
  `--ignore`/`--ignore-until-fixed`. Opt-in **malware checks** on `uv add`/`uv sync` via
  `UV_MALWARE_CHECK=1` (0.11.16+). **`uv check`** (0.11.18, preview): runs Astral’s ty
  type checker. Python 3.15 betas are available in managed downloads; 3.15 final is
  expected around October 2026. **0.11.25 and 0.11.28 harden archive handling** against
  parser differentials.
  Versions 0.11.29–0.11.33 add JSON output to `uv tree`, improve frozen-sync and
  `exclude-newer` performance, add `uv lock --refresh`, tighten path and credential
  handling, and extend the preview audit/malware/type-checking commands.
- **0.12.x (Jul 2026–present)**: existing projects keep their build backend, while newly
  initialized packages use `uv_build`. The resolver now prefers stable releases and
  falls back to prereleases only when necessary.
  Hash directives, archive and wheel paths, `pylock.toml`, project paths, and publish
  filenames receive stricter validation; MD5-only hash checking is rejected.
  `uv run path/to/script.py` discovers the project relative to the script, and Python
  upgrade/reinstall flags and dependency-group names are validated more consistently.
  These changes do not require a template migration, but they strengthen its existing
  locked build and publish paths.

(Compiled from the official
[uv changelog](https://github.com/astral-sh/uv/blob/main/CHANGELOG.md) and
[Astral blog](https://astral.sh/blog/); re-verify both sources when updating this
document.)

## Decisions and Action Items for the Template

1. **Stay on hatchling with uv-dynamic-versioning** (decision).
   `uv_build` is uv’s default backend and production-stable, but it is deliberately
   minimal: no plugin mechanism, so no dynamic versioning from git tags, which is core
   to this template’s release model.
   Revisit if uv grows native dynamic versioning.
   The build backends are exact-pinned and mirrored in a locked `build` dependency
   group; release builds use `--no-build-isolation` so `uv.lock` covers the build graph.
2. **Keep resolution policy in a checked-in `uv.toml`** (adopted):
   `required-version = ">=0.9"` fails fast on versions that predate relative-duration
   cutoffs, and `exclude-newer = "14 days"` supplies the safe default.
   The Makefile and CI set `UV_CONFIG_FILE=uv.toml` so uv uses this file exclusively
   instead of merging user- or system-level settings into `uv.lock`, matching uv’s
   documented
   [configuration-file precedence](https://docs.astral.sh/uv/configuration/files/).
3. **Watch `uv audit` and malware checking**: `uv audit` is old enough to use as an
   additional release-time check, but remains preview functionality in 0.12.0. Do not
   make a preview command part of generated-project CI until it stabilizes.
   Continue watching the opt-in malware-check settings for the same reason.
4. **Keep `devtools/lint.py` over `uv format`/`uv check`** (decision).
   One command runs codespell, ruff check, ruff format, and basedpyright together, which
   neither uv command covers; `uv check` is also ty-based and preview (see the
   [type-checker research doc](research-python-type-checkers.md)).
5. **Python 3.15**: add to the CI matrix and classifiers when final (~Oct 2026).
6. **uv pin currency**: bump the pinned uv in `template/.github/workflows/*` at each
   update cycle to the newest version clearing the 14-day cool-off (0.12.0 at the v0.5.0
   freeze). Update the setup-uv action and official platform checksum in the same
   reviewed change.
7. **Use `uv sync --locked` in CI and publishing** (adopted).
   `--locked` installs from `uv.lock` and fails when `pyproject.toml` would change it.
   `--frozen` skips that freshness check, so it can hide an uncommitted lockfile update
   and is not the right verification contract for committed project metadata.
   Selecting the project-owned `uv.toml` exclusively also makes the check portable
   across machines with different user-level uv settings.

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
