# tasks/risk-register.md -- DocAsk

## Purpose

Active risks to the project. Architect owns this file.
Reviewed at session open and sprint close.

---

## Active Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner | Status |
|---|---|---|---|---|---|---|
| R-001 | Supabase Storage path not scoped to user_id — cross-user file access possible | Low | High | All upload paths use `{user_id}/{document_id}` pattern; reviewed by Architect before merge | Architect | Open |
| R-002 | FastAPI MIME validation bypassed by spoofed Content-Type header | Low | Med | Validate MIME type from file content (magic bytes) not just Content-Type header | Junior Dev | Open |
| R-003 | pgvector extension not enabled on Supabase project — embedding pipeline blocked in Session 2 | Med | High | Enable pgvector extension in Session 1 migration; verify with a test query before session close | Architect | Open |

---

## Closed Risks

| ID | Risk | Resolution | Date |
|---|---|---|---|
| R-004 | 10 MB limit insufficient for large legal documents | Accepted — 10 MB covers target use case; limit will be revisited in Session 4 after usage data | 2024-01-15 |
