# tasks/todo.md -- DocAsk

## SESSION STATE

```
Status:         CLOSED
Active task:    none
Active persona: none
Blocking issue: none
Last updated:   Session 0
```

---

## Active Tasks

<!-- Architect moves tasks here from Backlog when a session opens -->

---

## Backlog

### TASK-001

**Title:** File upload API -- accept PDF/Word, validate type/size, store in Supabase Storage

**Status:** PENDING

**Acceptance Criteria:**
- FastAPI `POST /upload` endpoint accepts only `application/pdf` and
  `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
  (DOCX); any other MIME type returns HTTP 422 with a human-readable error
- Files larger than 10 MB are rejected before writing to Supabase Storage;
  response is HTTP 413 with a message stating the limit
- Accepted files are stored in Supabase Storage under a path scoped to the
  authenticated user's `user_id`; the endpoint returns the Supabase Storage
  object key and a generated `document_id`

**Assigned to:** Junior Dev

---

### TASK-002

**Title:** Documents table -- Supabase table with RLS, status field tracking upload lifecycle

**Status:** PENDING

**Acceptance Criteria:**
- A `documents` table exists in Supabase with columns: `id` (uuid, primary
  key), `filename` (text), `status` (text, constrained to
  `uploaded | processing | ready | failed`), `user_id` (uuid, references
  auth.users), `created_at` (timestamptz, default now())
- RLS is enabled on the `documents` table; users can select and update only
  rows where `user_id` matches their authenticated `uid`; service role key
  can bypass RLS for backend processing
- A row is inserted with `status = uploaded` immediately after a successful
  file upload; the `document_id` in the upload response matches the inserted
  row's `id`

**Assigned to:** Junior Dev

---

### TASK-003

**Title:** Upload UI -- drag-and-drop component, progress indicator, error states

**Status:** PENDING

**Acceptance Criteria:**
- A drag-and-drop upload zone accepts files dropped from the desktop or
  selected via a file picker; it visually distinguishes drag-over state from
  idle state
- An upload progress indicator is visible from the moment the file is
  submitted until the API returns a response; on success the document appears
  in the document list with `status: uploaded`
- Three error states are handled and surfaced to the user with a clear
  message: file type not allowed, file too large (>10 MB), and network/API
  error; errors do not leave the UI in a broken state

**Assigned to:** Junior Dev

---

## Archive

<!-- Completed tasks moved here by Architect at session close -->
