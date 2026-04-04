# Contributing

Thanks for contributing to AK Cognitive OS.

## Before You Change Anything

Read these first:

- [README.md](README.md)
- [QUICKSTART.md](QUICKSTART.md)
- [CLAUDE.md](CLAUDE.md)
- [SECURITY.md](SECURITY.md)

## Contribution Types

Good contributions include:

- framework bug fixes
- persona or skill contract improvements
- validator and harness coverage improvements
- documentation corrections
- bootstrap, remediation, and packaging fixes

Open an issue first for large changes to architecture, governance, safety policy, or command semantics.

## Workflow

1. Branch from `main`.
2. Keep the change focused.
3. Update docs when behavior changes.
4. Run validation before opening a PR.
5. Include a concise technical summary in the PR.

## Required Validation

Run:

```bash
bash scripts/validate-framework.sh
```

Run additional checks when relevant:

```bash
python3 validators/runner.py
bash scripts/bootstrap-project.sh /tmp/ak-cogos-smoke --non-interactive
bash scripts/remediate-project.sh /tmp/ak-cogos-smoke --dry-run
```

## Quality Rules

- Keep persona and skill files aligned with schema requirements.
- Do not remove or weaken `BOUNDARY_FLAG` behavior without explicit justification.
- Preserve the output-envelope contract in agent files.
- Keep docs consistent with shipped behavior.
- Do not claim compliance, security, or QA guarantees that are not mechanically enforced.
- Keep bootstrap and remediation flows idempotent where practical.

## Pull Request Checklist

- [ ] Change is scoped and explained clearly
- [ ] `bash scripts/validate-framework.sh` passes
- [ ] Related docs were updated
- [ ] No broken file references or command paths were introduced
- [ ] Hook, plugin, or packaging changes were verified carefully
- [ ] No unrelated churn was included

## Commit Guidance

- Prefer small, reviewable commits.
- Use commit messages that describe the actual behavior change.
- Avoid mixing framework refactors, content churn, and unrelated cleanup.

## Security and Sensitive Issues

Do not disclose vulnerabilities publicly before the maintainer has had a chance to assess them. Follow [SECURITY.md](SECURITY.md).
