# tasks/lessons.md -- DocAsk

## Purpose

Lessons learned during build. Proposed by Lessons Extractor, approved by AK.
Read the last 10 entries at every session open.

---

## Lessons

[2024-01-15] — Architect: MIME type validation must happen server-side (FastAPI) even if the frontend validates first — clients can spoof Content-Type headers.

[2024-01-15] — Junior Dev: Supabase Storage path scoping to `user_id/` must be set in the upload endpoint, not inferred by the client — client-controlled paths are a security risk.

[2024-01-15] — QA: Acceptance criteria for file size limits must specify where validation happens (frontend, backend, or both) — "files larger than 10MB are rejected" is ambiguous without this.

[2024-01-15] — Architect: Document status polling interval (5 seconds) should be defined in BA logic, not chosen by Junior Dev — affects user experience and Supabase read costs.
