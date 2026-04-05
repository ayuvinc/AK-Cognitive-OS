## What this changes

<!-- One paragraph: what you changed and why -->

## Type of change

- [ ] Bug fix
- [ ] New command / persona / skill
- [ ] Validator or hook improvement
- [ ] Governance or documentation update
- [ ] Script (bootstrap / remediation / validation)
- [ ] Breaking change (requires remediate-project.sh update)

## Validation

- [ ] `bash scripts/validate-framework.sh` — PASS
- [ ] `python3 validators/runner.py .` — PASS
- [ ] Smoke test: `bash scripts/bootstrap-project.sh /tmp/smoke --non-interactive && bash scripts/remediate-project.sh /tmp/smoke --dry-run`
- [ ] `CHANGELOG.md` updated

## Files changed

<!-- List the key files and what changed in each -->

## Impact on existing projects

<!-- Does this require re-running remediate-project.sh on existing projects?
     Will it break anything on projects that haven't been updated? -->

## Checklist

- [ ] Change is focused — no unrelated churn
- [ ] BOUNDARY_FLAG behavior preserved or strengthened
- [ ] Output envelope contract intact
- [ ] Docs updated to match new behavior
- [ ] No hardcoded paths, secrets, or user-specific assumptions
