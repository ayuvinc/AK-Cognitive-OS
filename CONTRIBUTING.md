# Contributing to AK Cognitive OS

Thanks for contributing. This framework is used in production projects — changes to personas, hooks, governance docs, and validators affect live delivery workflows.

---

## Read First

- [README.md](README.md) — what the framework is and how it works
- [QUICKSTART.md](QUICKSTART.md) — setup walkthrough
- [framework/governance/change-policy.md](framework/governance/change-policy.md) — how the framework evolves
- [framework/governance/role-design-rules.md](framework/governance/role-design-rules.md) — when to add a new command vs extend an existing one
- [SECURITY.md](SECURITY.md) — security scope and reporting

---

## What Makes a Good Contribution

| Type | Examples |
|---|---|
| Bug fix | Hook logic error, validator false positive/negative, schema gap |
| Contract improvement | Stronger CAN/CANNOT rules, better BOUNDARY_FLAG coverage |
| Validator coverage | New check in an existing validator, new validator for an uncovered area |
| Documentation | Correcting a guide, adding a worked example, fixing stale references |
| Script hardening | `bootstrap-project.sh`, `remediate-project.sh` edge cases |
| New guide | Practical how-to for a real workflow not yet covered |

Open an issue first for:
- New commands or personas
- Changes to the 20-command set (additions or retirements)
- Changes to governance policies (lifecycle, stage gates, tiers)
- Changes to hook enforcement logic
- Schema changes that break backward compatibility

---

## Framework Architecture

v3.0 enforcement runs in three layers — changes to any layer can affect the others:

```
Layer 1 — Hooks (scripts/hooks/ → .claude/settings.json)
  Runtime enforcement. Changes here affect all projects on next remediation.

Layer 2 — Commands (.claude/commands/ sourced from personas/ and skills/)
  Role contracts. Changes here propagate to projects via remediate-project.sh.

Layer 3 — Governance (framework/governance/)
  Policy layer. Referenced at runtime by commands and CLAUDE.md.
```

When changing Layer 1 (hooks), also verify:
- `project-template/.claude/settings.json` is consistent
- `validate-framework.sh` still passes

When changing Layer 2 (commands), also verify:
- The persona or skill source file matches the deployed command
- `BOUNDARY_FLAG` declarations are preserved
- Output envelope fields are correct

When changing Layer 3 (governance), also verify:
- `validators/governance.py` check list is still consistent
- Any cross-references in other governance docs are updated

---

## Required Checks Before Opening a PR

```bash
# 1. Framework structural validation (must pass)
bash scripts/validate-framework.sh

# 2. Python validator suite against the source repo
python3 validators/runner.py .

# 3. Smoke test — bootstrap a fresh project (no errors expected)
bash scripts/bootstrap-project.sh /tmp/ak-cogos-smoke-test --non-interactive

# 4. Smoke test — dry-run remediation against that project
bash scripts/remediate-project.sh /tmp/ak-cogos-smoke-test --dry-run

# 5. Clean up
rm -rf /tmp/ak-cogos-smoke-test
```

---

## Quality Rules

- Do not remove or weaken `BOUNDARY_FLAG` behavior without explicit justification.
- Preserve the output envelope contract in all agent files (12 required fields).
- Do not claim compliance, security, or QA guarantees that are not mechanically enforced.
- Keep `bootstrap-project.sh` and `remediate-project.sh` idempotent — running them twice must produce the same result.
- Hook scripts must exit 0 to allow, exit 2 to block. Exit 1 is not a valid hook response.
- All new validators must be auto-discoverable by `validators/runner.py`.
- Keep `CHANGELOG.md` updated when shipping changes.

---

## Adding a New Command

Before adding a command, check `framework/governance/role-design-rules.md`. New commands require:

1. Source files under `personas/<name>/` or `skills/<name>/`:
   - `claude-command.md` — the command contract
   - `codex-prompt.md` — Codex-facing version
   - `schema.md` — output schema
   - `SKILL.md` — skill card
2. Add to the explicit `DEPLOY_COMMANDS` list in `scripts/remediate-project.sh`
3. Add to `scripts/bootstrap-project.sh` deploy logic
4. Update `framework/governance/role-taxonomy.md`
5. Update `README.md` command list
6. Update `CHANGELOG.md`
7. `validate-framework.sh` must still pass

---

## PR Checklist

- [ ] Change is scoped and described clearly in the PR body
- [ ] `bash scripts/validate-framework.sh` passes
- [ ] `python3 validators/runner.py .` passes
- [ ] Related docs updated (guides, governance, README if applicable)
- [ ] `CHANGELOG.md` updated under `[Unreleased]`
- [ ] No broken file references or command paths introduced
- [ ] Hook or packaging changes verified with smoke tests
- [ ] No unrelated churn included

---

## Commit Style

- Use imperative mood: `fix`, `add`, `update`, `remove`
- Reference the affected component: `fix(guard-git-push): handle missing ACTIVE_PERSONA gracefully`
- Keep commits focused — one logical change per commit
- Avoid mixing framework refactors and content updates

---

## Security and Sensitive Issues

Do not disclose vulnerabilities publicly before the maintainer has assessed them. Follow [SECURITY.md](SECURITY.md).
