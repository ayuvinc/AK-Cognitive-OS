# Session 1 — DocAsk
# File Upload + Storage
# Date: 2024-01-15

## What Was Built

| Task | Title | Status |
|---|---|---|
| TASK-001 | File upload API — accept PDF/Word, validate type/size, store in Supabase Storage | QA_APPROVED |
| TASK-002 | Documents table — Supabase table with RLS, status field tracking upload lifecycle | QA_APPROVED |
| TASK-003 | Upload UI — drag-and-drop component, progress indicator, error states | QA_APPROVED |

---

## Files Changed

- `backend/main.py` — FastAPI app entry point
- `backend/routers/upload.py` — POST /upload endpoint with MIME + size validation
- `backend/db.py` — Supabase client (service role)
- `supabase/migrations/001_documents_table.sql` — documents table + RLS + pgvector extension
- `app/upload/page.tsx` — upload page with drag-and-drop zone
- `components/UploadZone.tsx` — upload component with progress + error states
- `components/DocumentList.tsx` — document list with status polling
- `lib/supabase.ts` — Supabase browser client
- `types/index.ts` — Document, DocumentStatus types

---

## Acceptance Criteria Results

| Criterion | Result |
|---|---|
| POST /upload rejects non-PDF/DOCX with HTTP 422 | PASS |
| Files > 10 MB rejected with HTTP 413 before writing to storage | PASS |
| Accepted files stored under user_id scoped path in Supabase Storage | PASS |
| Endpoint returns storage object key and document_id | PASS |
| Documents table with correct columns, RLS enabled | PASS |
| Row inserted with status=uploaded on successful upload | PASS |
| Drag-over state visually distinct from idle state | PASS |
| Progress indicator visible from submission to response | PASS |
| All 3 error states handled with clear user messages | PASS |

---

## Security Sign-off

- Storage paths scoped to `{user_id}/{document_id}` — cross-user access impossible by design
- MIME validation uses python-magic (content inspection), not Content-Type header
- RLS enabled on documents table — users can only access their own rows
- pgvector extension enabled (required for Session 2 embedding pipeline)

---

## Lessons Added This Session

- MIME validation must be server-side with content inspection, not Content-Type header trust
- Supabase Storage path scoping must be enforced server-side, not client-controlled
- Status polling interval (5s) should be a named constant, not a magic number

---

## Next Session

Session 2 — Embedding Pipeline (chunking, embedding, pgvector storage, status updates)
Persona: Architect → confirm chunk size and overlap with BA before Junior Dev starts
