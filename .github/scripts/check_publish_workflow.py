"""Assert the shape of a rendered `publish.yml`.

The publishing workflow's security properties are structural: which job may request
the PyPI credential, what else that job can do, and how the workflow can be triggered.
Check them against parsed YAML rather than by counting matching lines, so a comment
that mentions a permission cannot break the check and a permission in the wrong job
cannot satisfy it.

Usage: check_publish_workflow.py PATH_TO_RENDERED_PUBLISH_YML
"""

import sys

import yaml

JOBS = ["validate", "build", "publish"]

failures: list[str] = []


def check(condition: object, message: str) -> None:
    if not condition:
        failures.append(message)


def main(path: str) -> int:
    with open(path) as f:
        workflow = yaml.safe_load(f)

    # YAML 1.1 parses a bare `on` key as the boolean True.
    on = workflow.get("on", workflow.get(True)) or {}
    check(list(on) == ["release"], f"expected only a `release` trigger, got {list(on)}")
    check(
        on.get("release", {}).get("types") == ["published"],
        "the release trigger must be restricted to `types: [published]`",
    )

    jobs = workflow.get("jobs", {})
    check(list(jobs) == JOBS, f"expected jobs {JOBS}, got {list(jobs)}")
    if list(jobs) != JOBS:
        return report()

    # Lint and tests gate the release: a release tag can point at a commit that never
    # went through PR CI, so `validate` is the only place that checks it.
    check(jobs["build"].get("needs") == "validate", "`build` must run after `validate`")
    check(jobs["publish"].get("needs") == "build", "`publish` must run after `build`")

    # Declaring `permissions` at all sets every unlisted scope to `none`, so these
    # equality checks are what keep the credential in one job and nothing else with it.
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
            jobs[name].get("environment") is None,
            f"`{name}` must not declare the `pypi` environment",
        )

    # The credential-holding job runs no repository code: with no checkout, nothing
    # from the tree (or a build hook) executes alongside the token.
    for name, job in jobs.items():
        checkouts = [
            step
            for step in job.get("steps", [])
            if step.get("uses", "").startswith("actions/checkout@")
        ]
        expected = 0 if name == "publish" else 1
        check(
            len(checkouts) == expected,
            f"`{name}` must have {expected} checkout step(s), got {len(checkouts)}",
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
