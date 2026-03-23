# tasks/lessons.md -- Taskflow

## Purpose

Lessons learned during build. Proposed by Lessons Extractor, approved by AK.
Read the last 10 entries at every session open.

---

## Lessons

[2024-01-15] — Architect: Always confirm whether email confirmation is required before designing auth flow — it changes the redirect chain significantly.

[2024-01-15] — Junior Dev: Supabase RLS policies must be tested with a non-service-role client in dev; service role bypasses RLS silently and gives false confidence.

[2024-01-15] — QA: Acceptance criteria for auth redirects must specify the exact URL (e.g. `/dashboard`) not just "redirected to dashboard" — ambiguity caused a QA_REJECTED cycle.

[2024-01-15] — Architect: Stub pages for unbuilt routes must be decided in BA logic first, not inferred by Junior Dev — avoids scope creep during implementation.
