# tasks/risk-register.md -- Taskflow

## Purpose

Active risks to the project. Architect owns this file.
Reviewed at session open and sprint close.

---

## Active Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner | Status |
|---|---|---|---|---|---|---|
| R-001 | Supabase RLS misconfiguration allows user A to read user B's data | Low | High | RLS policies reviewed by Architect before merge; QA tests cross-user access explicitly | Architect | Open |
| R-002 | Email confirmation flow breaks on Supabase free tier rate limits during demo | Med | Med | Test with real email in staging before Session 4 deploy | Junior Dev | Open |

---

## Closed Risks

| ID | Risk | Resolution | Date |
|---|---|---|---|
| R-003 | Next.js middleware version incompatibility with Supabase auth helpers | Resolved — using proxy.ts pattern confirmed compatible with Next.js 14 | 2024-01-15 |
