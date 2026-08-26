"""Assert the structure of a rendered `publish.yml`.

The publishing workflow's security properties live in its shape, not in its text:
which job may request the PyPI credential, what else that job is allowed to do, and
how it can be triggered. Parse the YAML and assert that structure directly, so the
checks say what they mean and cannot be satisfied (or broken) by a comment that
happens to mention a permission.

Usage: check_publish_workflow.py PATH_TO_RENDERED_PUBLISH_YML
"""

from __future__ import annotations

import sys
from typing import Any

import yaml

SHA_LENGTH = 40
EXPECTED_JOBS = ["validate", "build", "publish"]

failures: list[str] = []


def check(condition: bool, message: str) -> None:
    if not condition:
        failures.append(message)


def triggers(workflow: dict[str, Any]) -> dict[str, Any]:
    # YAML 1.1 parses a bare `on` key as the boolean True.
    raw = workflow.get("on", workflow.get(True))
    return raw if isinstance(raw, dict) else {}


def needs(job: dict[str, Any]) -> list[str]:
    raw = job.get("needs", [])
    return [raw] if isinstance(raw, str) else list(raw)


def uses_steps(job: dict[str, Any]) -> list[str]:
    return [step["uses"] for step in job.get("steps", []) if "uses" in step]


def main(path: str) -> int:
    with open(path) as f:
        workflow = yaml.safe_load(f)

    on = triggers(workflow)
    check(list(on) == ["release"], f"expected only a `release` trigger, got {list(on)}")
    check(
        on.get("release", {}).get("types") == ["published"],
        "the release trigger must be restricted to `types: [published]`",
    )
    check(
        "workflow_dispatch" not in on,
        "`workflow_dispatch` would reintroduce a manual branch-based publish path",
    )

    jobs = workflow.get("jobs", {})
    check(list(jobs) == EXPECTED_JOBS, f"expected jobs {EXPECTED_JOBS}, got {list(jobs)}")
    if list(jobs) != EXPECTED_JOBS:
        return report()

    check(needs(jobs["build"]) == ["validate"], "`build` must run after `validate`")
    check(needs(jobs["publish"]) == ["build"], "`publish` must run after `build`")

    # Only the final job may hold the OIDC credential, and it may hold nothing else:
    # declaring `permissions` at all sets every unlisted scope to `none`.
    check(
        jobs["publish"].get("permissions") == {"id-token": "write"},
        f"`publish` permissions must be exactly {{'id-token': 'write'}}, "
        f"got {jobs['publish'].get('permissions')!r}",
    )
    check(
        jobs["publish"].get("environment") == "pypi",
        "`publish` must declare `environment: pypi` so PyPI can constrain the "
        "Trusted Publisher to this job",
    )
    for name in ["validate", "build"]:
        check(
            jobs[name].get("permissions") == {"contents": "read"},
            f"`{name}` permissions must be exactly {{'contents': 'read'}}, "
            f"got {jobs[name].get('permissions')!r}",
        )
        check(
            "id-token" not in (jobs[name].get("permissions") or {}),
            f"`{name}` must not be able to request the publishing credential",
        )
        check(
            jobs[name].get("environment") is None,
            f"`{name}` must not declare the `pypi` environment",
        )

    # The credential-holding job runs no repository code: no checkout, so nothing
    # from the tree (or a build hook) executes alongside the token.
    checkouts = {
        name: [u for u in uses_steps(job) if u.startswith("actions/checkout@")]
        for name, job in jobs.items()
    }
    check(
        not checkouts["publish"],
        "`publish` must not check out the repository",
    )
    for name in ["validate", "build"]:
        check(
            len(checkouts[name]) == 1,
            f"`{name}` must check out the repository exactly once, "
            f"got {len(checkouts[name])}",
        )
        for step in jobs[name].get("steps", []):
            if step.get("uses", "").startswith("actions/checkout@"):
                check(
                    step.get("with", {}).get("persist-credentials") is False,
                    f"`{name}` checkout must set `persist-credentials: false`",
                )

    # Every action is pinned to a full commit SHA; a tag is not necessarily immutable.
    for name, job in jobs.items():
        for used in uses_steps(job):
            _, _, ref = used.partition("@")
            check(
                len(ref) == SHA_LENGTH and all(c in "0123456789abcdef" for c in ref),
                f"`{name}` uses {used}, which is not pinned to a full commit SHA",
            )

    return report()


def report() -> int:
    if failures:
        print("publish.yml structure check FAILED:")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print("publish.yml structure check passed.")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: check_publish_workflow.py PATH_TO_RENDERED_PUBLISH_YML")
    sys.exit(main(sys.argv[1]))
