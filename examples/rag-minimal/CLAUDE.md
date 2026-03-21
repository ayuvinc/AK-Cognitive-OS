# CLAUDE.md -- DocAsk
# Upload PDF/Word documents, ask questions, get cited answers
# Stack: Next.js 14, FastAPI (Python), Supabase + pgvector, text-embedding-3-small, Claude claude-sonnet-4-6

---

## First Thing on Session Start

Ask: "I've read the CLAUDE.md. What role am I playing -- Architect, Junior
Developer, Business Analyst, UI/UX Designer, or QA?"

Read your Role Card (`.claude/commands/<role>.md`) and state it aloud before
touching any task.

---

## Commands

```bash
# Next.js frontend
npm run dev        # Local dev server (http://localhost:3000)
npm run build      # Production build (catches TS/compile errors)

# Python backend (run from /backend directory)
uvicorn main:app --reload   # FastAPI dev server (http://localhost:8000)
pytest                      # Python test suite
```

---

## The Team

**[OWNER_NAME] -- Product Manager (human, the boss).** Owns requirements,
priorities, and final approvals.

---

## Workflow

```
[OWNER] --> gives requirements
BA      --> confirms business logic (ba-logic.md)
UI/UX   --> user flow + wireframe + interaction rules (ux-specs.md)
Architect --> reads BA + UX outputs --> designs --> [OWNER] approval
Architect --> writes tasks to todo.md (PENDING) + creates feature branches
QA      --> adds acceptance criteria to each PENDING task
Junior Dev --> IN_PROGRESS --> builds to spec --> READY_FOR_QA
CI      --> lint + build + tests (must pass)
Architect --> code review --> approve or return to Junior Dev
UI/UX   --> reviews built UI against wireframe
QA      --> QA_APPROVED or QA_REJECTED
Architect --> archive --> merge to main --> present to [OWNER] --> write next-action.md
```

End of session: `tasks/todo.md` and `tasks/ba-logic.md` empty.

---

## SESSION STATE

Architect updates at every session open and close. Every persona reads first.

```
## SESSION STATE
Status:         CLOSED
Active task:    none
Active persona: none
Blocking issue: none
Last updated:   Session 0
```

---

## Plan Mode -- Mandatory Triggers

| Condition | Rule |
|---|---|
| Task touches more than 2 files | Mandatory |
| Task modifies types | Mandatory |
| New data model or schema change | Mandatory |
| Modifies shared services | Mandatory |
| No BA sign-off on business logic | Mandatory |
| Hotfix with uncertain scope | Mandatory |

---

## Definition of Done

- [ ] Code reviewed by Architect -- no `any`, correct patterns, no security issues
- [ ] Build passing, tests passing (both npm and pytest)
- [ ] Access control verified -- unauthenticated users cannot access protected data
- [ ] UI reviewed by UI/UX against wireframe
- [ ] Mobile layout checked at 375px
- [ ] Security model verified -- auth enforced, data boundaries correct, no secrets in code
- [ ] Observability verified -- errors logged, key actions traceable, no silent failures
- [ ] Edge cases tested: empty state, error state, unauthenticated access
- [ ] Task logged to `releases/session-N.md` before deletion
- [ ] No open BOUNDARY_FLAG entries

---

## Escalation Path

| Situation | Who handles it |
|---|---|
| Code bug | QA --> Junior Dev (QA_REJECTED) |
| Built UI doesn't match wireframe | UI/UX --> Junior Dev (REVISION_NEEDED) |
| Architectural flaw | QA --> Architect (written escalation) |
| Business logic question | Architect --> BA (ba-logic.md) |
| UX question | Architect --> UI/UX (ux-specs.md) |
| Scope/priority change | Any persona --> [OWNER] |

---

## Git Branching

- Branch name: `feature/TASK-XXX-short-description`
- Junior Dev creates branch before writing any code
- Commits to branch only, never to `main`
- Architect merges after QA_APPROVED; deletes branch after merge

---

## Project Overview

DocAsk is a document question-answering product. Users upload PDF or Word
documents; the system chunks, embeds, and stores them in a vector database.
Users then ask natural-language questions and receive answers with citations
pointing to the exact document passages used. Core user journeys:

1. User uploads a document; status progresses from uploaded --> processing --> ready
2. User asks a question; system retrieves top-5 relevant chunks and generates
   a cited answer using Claude claude-sonnet-4-6
3. User sees the answer with inline citations linking back to source chunks

---

## Tech Stack

- Frontend: Next.js 14, App Router, TypeScript (strict), Tailwind CSS v4
- Backend: FastAPI (Python 3.11+), Pydantic, SQLAlchemy
- Database: Supabase (PostgreSQL + pgvector extension)
- File Storage: Supabase Storage
- Embeddings: OpenAI text-embedding-3-small (1536 dimensions)
- Answer generation: Claude claude-sonnet-4-6 via Anthropic Python SDK
- Testing: Vitest (Next.js), pytest (Python)

---

## Architecture Rules

- Embedding pipeline runs in Python only -- never in TypeScript
- Next.js calls FastAPI via internal API (`/api/query` proxies to FastAPI)
- pgvector holds all embeddings; do not store embeddings anywhere else
- Chunking logic lives in Python only, never in TypeScript
- All file type validation happens in the FastAPI upload endpoint before
  any file is written to Supabase Storage
- Next.js must not import Anthropic SDK directly; all AI calls go through FastAPI
- RLS enabled on all Supabase tables
- No raw SQL outside `lib/db.ts` (Next.js) and `backend/db.py` (Python)

---

## Environment Variables

```
# Next.js (.env.local)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
FASTAPI_INTERNAL_URL=http://localhost:8000

# Python backend (.env)
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
```

Never commit `.env.local` or `.env`.

---

## Domain Types

```typescript
// types/index.ts (Next.js)

type DocumentStatus = "uploaded" | "processing" | "ready" | "failed";

interface Document {
  id: string;
  filename: string;
  status: DocumentStatus;
  user_id: string;
  created_at: string;
}

interface Query {
  id: string;
  question: string;
  answer: string;
  chunks_used: string[];  // array of Chunk ids
  user_id: string;
  created_at: string;
}
```

```python
# backend/models.py (Python / Pydantic)

class Chunk(BaseModel):
    id: str
    document_id: str
    content: str
    embedding: list[float]   # 1536 dimensions from text-embedding-3-small
    metadata: dict           # page number, char offset, source filename
```

---

## RAG Configuration

```
chunk_size:       512 tokens
chunk_overlap:    10% (approximately 51 tokens)
retrieval_top_k:  5
embedding_model:  text-embedding-3-small
answer_model:     claude-sonnet-4-6
similarity_metric: cosine
```

---

## Session Roadmap

| Session | Focus | Status |
|---|---|---|
| 1 | File upload + storage -- upload API, Supabase Storage, documents table | Pending |
| 2 | Embed pipeline -- chunking, embedding, pgvector storage, status updates | Pending |
| 3 | Query interface -- FastAPI query endpoint, answer generation, citation UI | Pending |
| 4 | Eval + hardening -- corpus evaluation, error handling, rate limits, QA pass | Pending |

---

## Session Start Checklist

- [ ] Read SESSION STATE above -- must be OPEN
- [ ] Read Role Card (`.claude/commands/<role>.md`), state it aloud
- [ ] Read `tasks/next-action.md` -- confirm expected persona
- [ ] Run standup (done / next / blockers)
- [ ] Read last 10 entries of `tasks/lessons.md`
- [ ] Resolve open BOUNDARY_FLAGs (Architect only)

---

## Audit Log

Path override for this project (set to your audit log file path):

```
audit_log: [AUDIT_LOG_PATH]
```

Agents resolve `[AUDIT_LOG_PATH]` from this CLAUDE.md field at runtime.
