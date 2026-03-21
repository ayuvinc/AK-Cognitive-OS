# Contributing

Thanks for contributing to AK Cognitive OS.

## Workflow

1. Create a branch from `main`.
2. Make focused changes.
3. Run local validation:
   - `scripts/validate-framework.sh`
4. Open a pull request with:
   - scope summary
   - files changed
   - validation output

## Quality Rules

- Keep persona/skill contracts aligned with schemas.
- Do not remove `BOUNDARY_FLAG` behavior.
- Preserve output envelope fields in all agent files.
- Keep docs consistent with actual repository structure.

## Pull Request Checklist

- [ ] Contract validation passes
- [ ] No broken internal guide links
- [ ] README/QUICKSTART updated if behavior changed
- [ ] No unrelated file churn
