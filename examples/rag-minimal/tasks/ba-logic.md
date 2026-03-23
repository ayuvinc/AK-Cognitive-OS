# tasks/ba-logic.md -- DocAsk

## Purpose

BA writes confirmed business logic decisions here.
Architect reads before designing. Junior Dev reads before building.
Cleared at end of sprint after tasks are archived.

---

## Active Decisions

## File Upload — Accepted Formats
decision: Session 1 accepts PDF and DOCX only. No image files, no plain text, no spreadsheets.
rationale: PDF and DOCX cover 95%+ of business document use cases. Expanding formats requires additional parsing libraries — deferred to Session 4.
constraints: MIME type validation happens at the FastAPI endpoint before any file is written to storage.
confirmed_by: BA | Architect
date: 2024-01-15

## File Upload — Size Limit
decision: 10 MB hard limit per file. Files exceeding this limit are rejected before writing to Supabase Storage.
rationale: Prevents runaway storage costs and embedding pipeline overload during early sessions.
constraints: Limit validated in FastAPI (HTTP 413 response). Frontend also validates before sending to avoid wasted network request.
confirmed_by: BA | Architect
date: 2024-01-15

## Document Status — Lifecycle
decision: Document status progresses: `uploaded → processing → ready → failed`. Status is visible to the user in the document list. No retry button in Session 1 — failed documents must be re-uploaded.
rationale: Retry logic adds complexity; deferred until Session 4 hardening sprint.
constraints: Status field is constrained to exactly these 4 values in the Supabase schema.
confirmed_by: BA
date: 2024-01-15

## Auth — Session 1 Scope
decision: Auth is required but minimal. Supabase email + password. No team sharing — documents are private to the uploading user.
rationale: Multi-user document sharing requires access control design that belongs in a later session.
constraints: All Supabase Storage paths are scoped to `user_id/{document_id}` — cross-user access is impossible by path design.
confirmed_by: BA | Architect
date: 2024-01-15
