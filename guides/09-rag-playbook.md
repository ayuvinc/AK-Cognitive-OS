# Guide 09 -- RAG Playbook
# AK Cognitive OS
# Last reviewed: 2026-03-21

RAG stands for Retrieval-Augmented Generation. Instead of asking an AI to answer from
memory, you store your documents in a searchable index and retrieve the most relevant
chunks before asking the AI to answer. The AI answers using real retrieved content,
not guesswork. This guide covers when to use RAG, how to set it up, and what can go wrong.

---

## When to Use RAG

Use this decision tree to determine whether RAG is the right tool.

```
Does the AI need to answer questions about specific documents or domain knowledge?
|
+-- NO  --> Do not use RAG. Standard prompting is sufficient.
|
+-- YES --> Is the document set larger than fits in a single prompt context window?
            |
            +-- NO, it fits --> Consider simple context injection instead of full RAG.
            |                   Only add RAG if the document set will grow.
            |
            +-- YES, too large --> Does the answer require combining information
                                   from multiple documents?
                                   |
                                   +-- NO, one doc at a time --> RAG with single-doc
                                   |                             retrieval is fine.
                                   |
                                   +-- YES, multi-doc synthesis --> RAG with
                                                                    re-ranking + fusion.
                                                                    Consider LangGraph
                                                                    for complex chains.
```

RAG is the right choice when:
- You have more than ~20 pages of reference material
- The document set will grow over time (policies, knowledge bases, legal docs)
- Users need to query across many documents (e-discovery, enterprise search)
- You need citations -- RAG retrieval gives you source attribution

RAG is NOT needed when:
- The AI only needs to follow instructions (prompting is sufficient)
- You have fewer than 5-10 short documents (just inject them into context)
- The task is code generation with no domain documents to reference

---

## Ingestion Defaults

| Document Type       | Preprocessing Step                          | Notes                                    |
|---------------------|---------------------------------------------|------------------------------------------|
| PDF (text-based)    | Extract text with pdfplumber or PyMuPDF     | Preserve section headers                 |
| PDF (scanned)       | OCR first (Tesseract or AWS Textract)       | Quality depends on scan quality          |
| Word (.docx)        | Extract with python-docx                   | Preserve headings as metadata            |
| HTML / web page     | Strip tags, preserve structure             | Remove nav, footer, boilerplate          |
| Markdown            | Minimal processing, split on headers       | Headers are natural chunk boundaries     |
| Plain text          | Minimal processing                         | Split on paragraphs or fixed size        |
| CSV / structured    | Convert rows to natural language sentences | Or use SQL/structured retrieval instead  |
| Audio / video       | Transcribe first (Whisper)                 | Treat transcript as plain text after     |

General rule: clean and normalise before embedding. Garbage in, garbage out.
Remove boilerplate (page numbers, repeated headers, legal footers) before chunking.

---

## Chunking Defaults

Chunk size controls how much text each stored unit contains. Overlap prevents
a key sentence from being split across two chunks and lost.

| Document Type              | Chunk Size (tokens) | Overlap (tokens) | Notes                          |
|----------------------------|---------------------|------------------|--------------------------------|
| General prose (policies)   | 512                 | 64               | Good general-purpose default   |
| Legal documents            | 256                 | 64               | Precise citations need small chunks |
| Technical documentation    | 512                 | 128              | Code + prose mixed content     |
| Long-form reports          | 1024                | 128              | Wider context for narrative docs |
| FAQ / Q&A pairs            | Keep Q+A together   | 0                | Split on Q&A boundary, not size |
| Code files                 | Split on function   | 0                | Semantic split beats fixed size |

Rule of thumb: if retrieval is missing context that should be obvious, increase
chunk size. If retrieval is returning too much irrelevant content, decrease chunk size.
Always test with 10-20 real queries before locking in chunk settings.

---

## Embedding Choices

Embeddings convert text chunks into vectors (lists of numbers) that encode meaning.
Similar meaning = vectors close together in space. This is what makes search work.

| Model                      | Provider    | Dimensions | Best For                          | Cost        |
|----------------------------|-------------|------------|-----------------------------------|-------------|
| text-embedding-3-small     | OpenAI      | 1536       | General purpose, low cost         | Low         |
| text-embedding-3-large     | OpenAI      | 3072       | Higher accuracy, larger docs      | Medium      |
| embed-english-v3.0         | Cohere      | 1024       | English-only, strong retrieval    | Low-Medium  |
| embed-multilingual-v3.0    | Cohere      | 1024       | Multi-language document sets      | Low-Medium  |
| all-MiniLM-L6-v2           | HuggingFace | 384        | Self-hosted, fast, offline-capable | Free        |
| bge-large-en-v1.5          | HuggingFace | 1024       | High quality open source          | Free        |

Default recommendation: text-embedding-3-small for most projects (cost-effective,
well-supported, simple API). Upgrade to text-embedding-3-large if retrieval quality
is insufficient after testing.

Important: always use the same model for ingestion and querying. If you embed your
documents with model A and query with model B, the vectors are incompatible.

---

## Vector DB Choices

The vector database stores your embeddings and serves similarity search queries.

| Database    | Hosted Option    | Self-Hosted | Best For                            | Notes                          |
|-------------|------------------|-------------|-------------------------------------|--------------------------------|
| Pinecone    | Yes (managed)    | No          | Production, fully managed           | Easiest to start with          |
| Supabase    | Yes (pgvector)   | Yes         | Projects already on Supabase        | Already in AK stack            |
| Weaviate    | Yes              | Yes         | Complex schema + metadata filtering | Good for structured docs       |
| Qdrant      | Yes              | Yes         | High performance, open source       | Good for large doc sets        |
| Chroma      | No               | Yes         | Local dev and prototyping           | Not production-ready at scale  |
| FAISS       | No               | Yes         | Offline / air-gapped                | No persistence by default      |

Default recommendation: if you are already on Supabase (as in akcoach), use pgvector
(Supabase's built-in vector extension). It adds RAG to an existing project with minimal
new infrastructure. For a greenfield RAG project, use Pinecone for managed simplicity
or Qdrant for open-source production use.

---

## Retrieval Strategy

How you retrieve chunks affects answer quality as much as how you store them.

| Strategy              | When to Use                                           | Trade-off                          |
|-----------------------|-------------------------------------------------------|------------------------------------|
| Top-K similarity      | Simple Q&A over a single topic area                   | Fast, but may miss edge cases      |
| Hybrid (BM25 + vector)| When exact keyword matches matter (legal terms, names)| Better recall, slightly more setup |
| Re-ranking            | When top-K returns irrelevant results                 | Higher quality, adds latency       |
| Maximal Marginal Relevance (MMR) | When top results are too similar to each other | More diverse retrieval        |
| Multi-query retrieval | When one question has multiple valid phrasings        | Better coverage, more LLM calls    |
| Parent-child chunking | When small chunks retrieve well but need more context | Best of both worlds, more complex  |

Default recommendation: start with top-K similarity (K=5). If users report missing
answers that should be in the documents, add hybrid search (BM25 + vector). Only add
re-ranking if hybrid search is still insufficient -- re-ranking adds cost and latency.

---

## Eval Checklist

Run this checklist before declaring a RAG system ready for users.

- [ ] Test with 20+ real queries that represent actual user questions
- [ ] Verify at least 80% of queries retrieve the correct source chunk in top 5 results
- [ ] Verify the LLM's answer is grounded in the retrieved chunk (no hallucinated facts)
- [ ] Test edge cases: questions where the answer is not in the documents
      (the system should say "I don't know", not hallucinate an answer)
- [ ] Test with adversarial queries: questions designed to confuse the retriever
- [ ] Verify chunk size is right: retrieved chunks have enough context to answer
- [ ] Verify citations are correct: if the system cites sources, verify they are accurate
- [ ] Run a latency check: retrieval + generation must complete in acceptable time
      (under 5 seconds for most applications)

---

## RAG Failure Cases

| Failure                        | Symptom                                            | Mitigation                                        |
|--------------------------------|----------------------------------------------------|---------------------------------------------------|
| Chunk fragmentation            | Answer is split across chunk boundary; retrieval returns half the answer | Increase chunk size or add overlap |
| Missing metadata               | Retrieval returns correct text but from wrong time period or source | Add date and source fields to chunk metadata, filter on them |
| Embedding mismatch             | Retrieval returns unrelated chunks for clear queries | Verify same embedding model used for ingest and query |
| Hallucination despite retrieval| LLM ignores retrieved context and answers from memory | Add explicit instruction: "Answer only from the provided context. If not found, say so." |
| Stale index                    | Documents updated in source but not re-embedded; users get outdated answers | Implement incremental re-indexing on document update |
| Context window overflow        | K is set too high; retrieved chunks exceed LLM context limit | Reduce K, use re-ranking to keep only most relevant, or use chunking strategy with smaller chunks |

---

## Minimum Viable RAG Stack

For a new project that needs RAG quickly and reliably, use this stack.

| Layer          | Tool                        | Why                                               |
|----------------|-----------------------------|---------------------------------------------------|
| Document loading | LangChain document loaders | Handles PDF, DOCX, HTML, plain text out of the box |
| Chunking       | LangChain text splitter     | Configurable chunk size and overlap               |
| Embedding      | OpenAI text-embedding-3-small | Simple API, reliable quality, well-documented   |
| Vector store   | Supabase pgvector (if on Supabase) or Qdrant | Existing infrastructure or open-source production option |
| Retrieval      | Top-K similarity search (K=5) | Simple starting point, easy to tune             |
| Generation     | OpenAI GPT-4o or Claude via OpenRouter | Strong instruction following for grounded answers |
| Orchestration  | LangChain (TypeScript) for simple chains; LangGraph (Python) for multi-step reasoning | Match to project stack |

This stack can be built and tested in a single sprint. Start here and only add
complexity (re-ranking, hybrid search, multi-query) after you have validated that
the basic retrieval quality is insufficient for your use case.

For e-discovery or document-heavy multi-step reasoning (recursive summarisation,
cross-document synthesis), graduate from LangChain to LangGraph. See the roadmap
for when to introduce Python + LangGraph in the AK Cognitive OS build sequence.
