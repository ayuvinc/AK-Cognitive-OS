# Example: RAG Minimal

This example shows how to use the AK-Cognitive-OS framework to build a
retrieval-augmented generation (RAG) product -- document upload and
question answering -- using a hybrid Next.js + Python architecture.

---

## What This Shows

End-to-end document upload, embedding pipeline, and question answering for a
fictional product called DocAsk. Users upload PDF or Word documents; DocAsk
chunks, embeds, and stores them; users then ask questions and receive cited
answers grounded in the uploaded documents.

---

## Stack

- Next.js 14 (frontend, App Router)
- FastAPI (Python backend -- embedding pipeline + query API)
- Supabase + pgvector (document storage, vector embeddings)
- text-embedding-3-small (OpenAI embedding model)
- Claude claude-sonnet-4-6 via Anthropic SDK (answer generation)

---

## How to Use This Example

1. Copy `examples/rag-minimal/CLAUDE.md` to your own project root.
2. Run `scripts/bootstrap-project.sh <your_project_path>` to scaffold
   `tasks/` and `releases/` directories.
3. Fill in the remaining placeholder `[OWNER_NAME]` in your copied CLAUDE.md.
4. Open a Claude Code session from your project root and follow the Session
   Start Checklist in CLAUDE.md.
5. Note: this example requires two running processes -- `npm run dev` for
   Next.js and `uvicorn main:app --reload` for the FastAPI backend.

---

## Personas Used

- BA (Business Analyst) -- defines upload constraints, file type rules,
  query behaviour, and free vs paid plan limits
- Architect -- designs chunking strategy, API surface between Next.js and
  FastAPI, vector schema
- Junior Dev -- implements upload API, embed pipeline, query interface
- QA -- verifies retrieval accuracy, citation quality, error states
- Researcher -- evaluates RAG corpus quality; measures retrieval precision
  and recall on a test document set

---

## Session Roadmap

| Session | Focus |
|---|---|
| Session 1 | File upload + storage -- upload API, Supabase Storage, documents table |
| Session 2 | Embed pipeline -- chunking, text-embedding-3-small, pgvector storage |
| Session 3 | Query interface + eval -- FastAPI query endpoint, citation UI, corpus evaluation |
