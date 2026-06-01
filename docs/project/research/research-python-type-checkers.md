# Research: Python Type Checkers for simple-modern-uv

**Last updated:** 2026-06-01

**Author:** Joshua Levy (with agent assistance)

**Status:** Maintained

## Overview

The `simple-modern-uv` README recommends
[BasedPyright](https://github.com/detachhead/basedpyright) for type checking and
discusses Mypy, BasedMypy, and Pyright along the way.
That recommendation was based on hands-on experience trying the available checkers, but
the landscape has moved: Astral’s [ty](https://github.com/astral-sh/ty) has gained
traction, and Meta’s [Pyrefly](https://pyrefly.org/) reached 1.0.

This doc collects the current state of the major Python type checkers, looks for an
*objective* way to compare how much of the type system each one actually supports, and
checks whether the README’s recommendation still holds.
The motivating decision: should the template switch its default type checker, and if
not, what would need to change for us to revisit?

The short answer: **BasedPyright remains the right default for the template today.** ty
is fast and improving but is still in beta and materially behind on typing-spec
coverage. This matches the README’s existing claim and the author’s prior experience.

## Questions to Answer

1. What is the current state (maturity, speed, editor support, license) of each major
   type checker: Mypy, BasedMypy, Pyright, BasedPyright, ty, and Pyrefly?
2. Is there an objective, repeatable way to measure how many type-system features /
   checks each checker supports?
3. Does ty still have materially less coverage than BasedPyright, as the README claims?
4. What would have to change for the template to switch its default to ty?

## Scope

- **Included:** Static type checkers usable on general Python projects, focused on
  type-system coverage, maturity, speed, editor/LSP support, and license.
- **Excluded:** Runtime type enforcement (e.g. `typeguard`, `beartype`), linters that
  are not type checkers (Ruff, Flake8), and IDE-only heuristics.
  Speed numbers are summarized from published benchmarks rather than re-measured here.

## Findings

### The objective measure: the official typing conformance suite

The most objective, vendor-neutral measure is the
[Python typing conformance test suite](https://github.com/python/typing/tree/main/conformance),
maintained in the `python/typing` repository.
It validates checkers against the official
[typing specification](https://typing.readthedocs.io/en/latest/spec/) rather than any
one tool’s behavior, so “the reference implementation passes” is not the bar — the
*written spec* is.

How it works:

- Tests are grouped into **21 categories** that mirror the spec: annotations, generics,
  qualifiers, protocols, overloads, type narrowing, dataclasses, TypedDicts, tuples,
  named tuples, and more.
- Each test file marks expected errors with special comments (`# E` for a required
  error, `# E?` for an allowed-but-optional error).
- Each test is scored **Pass** (fully spec-compliant), **Partial** (compliant except in
  documented areas), or **Unsupported** (feature not implemented).
- Official results currently cover six checkers: **mypy, pyright, pyrefly, ty,
  pycroscope, and zuban.**

Two caveats that matter when reading any headline percentage:

- **“Pass” is strict.** A checker that mostly handles a feature but misses an edge case
  scores Partial, not Pass.
  Different blog posts aggregate “Pass only” vs “Pass + Partial” differently, which is
  why reported numbers vary by source.
- **Conformance ≠ usefulness.** The suite measures spec coverage, not real-world
  ergonomics, false-positive rate, or how strict the *default* configuration is.
  A low score on a beta tool often reflects deliberately-not-yet-implemented features,
  not bugs.

### Approximate conformance scores (early–mid 2026)

These are full-`Pass` rates on the conformance suite, drawn from the official results
and secondary analyses.
Treat them as a moving snapshot — the suite and the tools both change frequently — and
as approximate rather than exact.

| Checker | Approx. full-Pass conformance | Notes |
| --- | --- | --- |
| Pyright | ~98% | Highest of any checker; the de facto leader. |
| BasedPyright | ~98% (inherits Pyright) | Not scored separately; rebases on Pyright frequently. |
| Pyrefly | ~90%+ (at v1.0.0, May 2026) | Climbed quickly after its stable release. |
| Zuban | ~69% full Pass (Aug 2025 analysis) | Newer; strong for its age. |
| mypy | ~57–58% | Reference-era implementation; lower than its reputation suggests. |
| ty | ~53% (beta) | Deliberately filling in features; rising over time. |

Sources differ on exact figures and dates, so the ranking matters more than the
decimals. The stable point across sources: **Pyright/BasedPyright lead; ty and mypy
trail; Pyrefly has closed much of the gap.**

### Per-checker state

- **Mypy** — The original and still-common checker, the closest thing to a reference
  implementation historically.
  Mature and widely integrated, but slower than the Rust checkers and, perhaps
  surprisingly, only mid-pack on strict spec conformance (~57–58%). Microsoft’s Mypy
  VSCode extension is licensed only for use in VSCode, which is a problem for VSCode
  forks like Cursor and Windsurf.

- **BasedMypy** — A community fork of Mypy that adds stricter defaults and extra
  features on top of Mypy’s engine.
  Inherits Mypy’s speed profile and ecosystem.

- **Pyright** — Microsoft’s checker, written in TypeScript.
  The conformance leader (~98%) and fast relative to Mypy.
  Its first-party editor experience ships as **Pylance**, which is proprietary and
  restricted to official VSCode, again an issue for forks.

- **BasedPyright** — A community fork of Pyright that tracks upstream closely (frequent
  rebases, roughly biweekly releases) and adds stricter defaults plus Pylance-style LSP
  features under an open-source license.
  It inherits Pyright’s ~98% conformance, works in Cursor and other VSCode forks, and is
  the most mature non-Microsoft, non-Astral option.
  **This is the template’s current choice.**

- **ty** — Astral’s checker (makers of uv and Ruff), written in Rust.
  Extremely fast — published benchmarks put it ~10–60x faster than Mypy or Pyright
  without caching — with fine-grained incremental analysis and a full language server
  (VSCode, PyCharm, Neovim, and more).
  It entered [beta in December 2025](https://astral.sh/blog/ty) and is on `0.0.x`
  versioning, so its API and diagnostics can change between releases.
  Astral itself flags that users should “expect to encounter bugs, missing features, and
  fatal errors.” Conformance (~53%) is the lowest of the mature/near-mature group,
  reflecting features still being implemented.
  The roadmap to stable is stability/bug-fixes, completing the long tail of typing-spec
  features, and first-class support for libraries like Pydantic and Django.

- **Pyrefly** — Meta’s Rust checker, the successor to its internal Pyre.
  Reached [1.0.0 in May 2026](https://pyrefly.org/), is in the same 10–50x-faster speed
  class as ty, and already scores 90%+ on conformance — notably ahead of ty and Mypy.
  Worth watching as a second fast, well-funded option alongside ty.

## Key Insights

- **The README’s claim still holds.** ty trails BasedPyright on the one vendor-neutral
  coverage metric we have (~53% vs ~98% full Pass), corroborating the author’s
  experience that ty “didn’t have nearly the same coverage.”
  It is no longer fair to call ty immature in tooling — the language server and editor
  story is strong — but its *type system coverage* is genuinely behind.

- **Speed is not the deciding factor for this template.** ty and Pyrefly win decisively
  on speed, but a minimal template’s bottleneck is correctness and low false-positive
  noise during CI, not checker wall-clock time on a tiny codebase.
  Coverage and maturity dominate the decision here.

- **License/editor compatibility quietly matters.** Part of why BasedPyright beats raw
  Pyright for this template is that Pyright’s best editor experience (Pylance) is
  restricted to official VSCode, while BasedPyright’s LSP works in Cursor/Windsurf.
  ty and Pyrefly both ship permissively-licensed language servers, which removes this
  friction if either later wins on coverage.

- **The field is converging fast.** Two Rust checkers (ty, Pyrefly) and one more (Zuban)
  all appeared or matured within about a year.
  Pyrefly’s jump to 90%+ shows a beta checker can close the conformance gap quickly, so
  this recommendation should be re-checked periodically, not treated as settled.

## Comparison Matrix

| Criterion | Mypy | BasedMypy | Pyright | BasedPyright | ty | Pyrefly |
| --- | --- | --- | --- | --- | --- | --- |
| Maintainer | python/community | community fork | Microsoft | community fork | Astral | Meta |
| Language | Python | Python | TypeScript | TypeScript | Rust | Rust |
| Maturity | mature | mature | mature | mature | beta (`0.0.x`) | stable (1.0, May 2026) |
| Conformance (full Pass) | ~57–58% | inherits Mypy | ~98% | ~98% (inherits Pyright) | ~53% | ~90%+ |
| Speed | baseline | baseline | faster than Mypy | ≈ Pyright | 10–60x faster | 10–50x faster |
| Language server | MS extension | via Mypy | Pylance | open LSP | open LSP | open LSP |
| Works in VSCode forks | restricted | restricted | restricted (Pylance) | yes | yes | yes |
| Strict-by-default extras | `--strict` | yes | configurable | yes (adds rules) | growing | configurable |

## Options Considered

### Option A: Keep BasedPyright (recommended)

**Description:** No change.
BasedPyright stays the template default.

**Pros:**
- Highest practical coverage (~98%, inherited from Pyright).
- Mature, actively maintained, predictable.
- Open-source LSP that works across VSCode and its forks (Cursor, Windsurf).
- Stricter defaults than raw Pyright, which suits a “done right” template.

**Cons:**
- Slower than the Rust checkers (irrelevant at template scale, relevant on large code).
- Not from the Astral toolchain, so it is a separate tool from uv/Ruff.

### Option B: Switch to ty

**Description:** Adopt Astral’s ty as the default, consolidating on the Astral
toolchain.

**Pros:**
- Dramatically faster; excellent incremental analysis and editor support.
- Natural fit with uv and Ruff, which the template already uses.
- Improving rapidly under active, well-resourced development.

**Cons:**
- Beta, `0.0.x`: APIs and diagnostics can change between releases.
- Lowest coverage of the near-mature group (~53%); misses spec features the template’s
  users may rely on.
- Astral explicitly warns to expect bugs and missing features.

### Eliminated Options

- **Mypy / BasedMypy:** Eliminated as the default for the same reasons the README
  already gives — the Microsoft Mypy extension is restricted to official VSCode, and
  Mypy’s conformance is mid-pack.
  Still a fine choice for teams already standardized on it.
- **Pyright (raw):** Eliminated in favor of BasedPyright, which adds open LSP features
  and stricter defaults while inheriting Pyright’s coverage.
- **Pyrefly / Zuban:** Not eliminated on merit — Pyrefly in particular is promising —
  but out of scope as a *default* today.
  Revisit alongside ty.

## Recommendations

- **Keep BasedPyright as the template default.** It leads on the objective coverage
  metric and is mature, and the speed advantage of the alternatives does not matter at
  template scale.
- **Keep the README’s ty note** recommending ty as a fast, promising alternative, with
  the explicit caveat that it is beta and behind on coverage.
  That note is accurate as of this research.
- **Re-evaluate when ty (or Pyrefly) reaches comparable conformance.** Concretely,
  revisit if ty exits beta (stable, non-`0.0.x`) *and* its full-Pass conformance is
  within a few points of Pyright/BasedPyright, or if Pyrefly’s 90%+ holds and its
  ecosystem matures.

## Next Steps

- [ ] Re-check conformance numbers at the next dependency-update cycle (see
  `updating.md`).
- [ ] If ty exits beta, render the template with ty and compare false
  positives/negatives on the stub project plus a real downstream project.

## Methodology

Research conducted 2026-06-01 via web search and source review.
The primary, authoritative source is the official `python/typing` conformance suite and
its results; secondary sources (vendor blogs, independent comparisons) were used for
speed benchmarks and dates and are flagged as such.
Several third-party pages could not be fetched directly (HTTP 403); their figures were
taken from search-result summaries and cross-checked against the official suite where
possible. Exact conformance percentages drift as the suite and tools evolve, so figures
are reported as approximate with dates; the *ranking* is more stable than the decimals.

## References

- [Python typing conformance suite (python/typing)](https://github.com/python/typing/tree/main/conformance)
  — official, authoritative
- [Python typing specification](https://typing.readthedocs.io/en/latest/spec/) —
  official
- [ty repository](https://github.com/astral-sh/ty) — vendor (Astral)
- [ty: an extremely fast Python type checker (Astral blog)](https://astral.sh/blog/ty) —
  vendor
- [BasedPyright](https://github.com/detachhead/basedpyright) — project
- [Pyright](https://github.com/microsoft/pyright) — vendor (Microsoft)
- [Pyrefly](https://pyrefly.org/) and
  [Pyrefly conformance comparison](https://pyrefly.org/blog/typing-conformance-comparison/)
  — vendor (Meta)
- [How do Mypy, Pyright, and ty compare? (pydevtools)](https://pydevtools.com/handbook/explanation/how-do-mypy-pyright-and-ty-compare/)
  — independent
- [How Well Do New Python Type Checkers Conform? (sinon.github.io)](https://sinon.github.io/future-python-type-checkers/)
  — independent
- [ty vs mypy vs pyright (danilchenko.dev)](https://www.danilchenko.dev/posts/ty-vs-mypy-vs-pyright/)
  — independent
- [Python type checker ty now in beta (InfoWorld)](https://www.infoworld.com/article/4108979/python-type-checker-ty-now-in-beta.html)
  — press

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
