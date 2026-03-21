# Guide 06 — Tooling Baseline

## Purpose

Opinionated, curated tooling recommendations for projects built with AK Cognitive OS.
These are defaults — not rules. The Architect overrides based on project intake answers
(`guides/00-project-intake.md`).

Each section includes: recommended default, when to deviate, and why the default was chosen.

---

## 1. App Stack

### Frontend

| Context | Recommendation | Why |
|---|---|---|
| Web app (default) | **Next.js** (App Router, TypeScript) | Full-stack, file-based routing, RSC, excellent DX |
| Highly interactive SPA | **Next.js + Zustand** | State management without Redux overhead |
| Mobile (cross-platform) | **React Native + Expo** | Largest ecosystem, shares logic with web |
| Mobile (iOS-only, performance-critical) | Swift / SwiftUI | Native performance, best Apple tooling |
| Pure marketing/content site | **Astro** | Static-first, ships zero JS by default |

**Default choice for most AI-powered web apps:** Next.js 14+ with App Router, TypeScript strict mode, Tailwind CSS v4.

### Backend / API

| Context | Recommendation | Why |
|---|---|---|
| Collocated with Next.js | **Next.js Route Handlers** | No separate service, one deploy |
| Standalone API | **FastAPI** (Python) | Async, automatic docs, native AI/ML ecosystem |
| High-throughput API | **Hono** (TypeScript, edge-native) | Extremely fast, runs on Cloudflare Workers |
| Webhooks / event processing | **FastAPI** or **BullMQ** worker | Reliable queue-backed processing |

**Trigger for standalone Python backend:** any session with RAG, embeddings, or LangChain/LangGraph.

### Language

- **TypeScript** (strict) for all frontend and Next.js backend code
- **Python 3.11+** for all AI/ML pipelines, RAG, and LangChain/LangGraph work
- No mixed runtimes in a single service — keep language boundaries clean

---

## 2. Data Stack

### Primary Database

| Context | Recommendation | Why |
|---|---|---|
| Default (most web apps) | **Supabase** (Postgres) | Managed Postgres + auth + storage + realtime in one |
| High-scale or multi-tenant | **PlanetScale** or **Neon** | Serverless Postgres, connection pooling built-in |
| Document-heavy (CMS, config) | **MongoDB Atlas** | Schema-flexible, good for unstructured data |
| Relational, self-hosted | **PostgreSQL** (direct) | Maximum control, runs anywhere |

**Default:** Supabase for v1. Migrate to managed Postgres if connection limits become an issue.

### Cache

| Context | Recommendation | Why |
|---|---|---|
| Default | **Redis** (Upstash for serverless) | Ubiquitous, supports pub/sub and queues too |
| Edge caching | **Cloudflare KV** | Zero-latency reads at the edge |
| Session storage | **Redis** | TTL-based eviction built in |

### Queue / Background Jobs

| Context | Recommendation | Why |
|---|---|---|
| Node.js workers | **BullMQ** (Redis-backed) | Battle-tested, retries, prioritisation, dashboards |
| Python workers | **Celery** (Redis/RabbitMQ) | Standard Python async task runner |
| Simple cron | **Vercel Cron** or **GitHub Actions schedule** | Zero infra for low-frequency jobs |
| Event streaming | **Kafka** (Confluent Cloud) | Only if event volume > 10k/sec or fan-out needed |

---

## 3. AI Stack

### LLM Provider

| Context | Recommendation | Why |
|---|---|---|
| Default (general use) | **Anthropic Claude** (claude-sonnet-4-6) | Best reasoning, large context, safety-aligned |
| Cost-sensitive high volume | **OpenRouter** (routes to cheapest capable model) | Normalised API, model fallback built in |
| Multimodal (image/audio/video) | **Google Gemini 2.0 Flash** | Best multimodal price/performance |
| Offline / data sovereignty | **Ollama** (local) + **Llama 3.3 70B** | No data leaves your infra |
| Coding tasks | **Claude** or **GPT-4o** | Both strong; Claude better for long context |

**SDK default:** Anthropic SDK (TypeScript or Python). For multi-provider, use **OpenRouter** or **LiteLLM**.

### Embeddings Model

| Context | Recommendation | Why |
|---|---|---|
| Default | **text-embedding-3-small** (OpenAI) | Fast, cheap, 1536 dimensions, excellent quality |
| Multilingual corpus | **multilingual-e5-large** | 100+ languages, strong cross-lingual retrieval |
| High-quality (cost not a concern) | **text-embedding-3-large** | Best retrieval quality, 3072 dimensions |
| Local / private | **nomic-embed-text** via Ollama | Free, runs locally, strong performance |

### Vector Database

| Context | Recommendation | Why |
|---|---|---|
| Default (managed, simple) | **Pinecone** | Fully managed, serverless tier, fast queries |
| Already using Supabase | **pgvector** (Supabase extension) | Zero extra service, Postgres-native |
| Open source, self-hosted | **Qdrant** | Best self-hosted DX, Rust-based, fast |
| Large-scale (> 100M vectors) | **Weaviate** or **Milvus** | Purpose-built for billion-scale |

**Default for v1:** pgvector if using Supabase (no new service). Pinecone if vector search is the core feature.

---

## 4. RAG Pipeline

### Architecture Decision Tree

```
Corpus size < 10 MB and static?
  → Simple: embed at deploy time, store in pgvector, query at runtime

Corpus size 10 MB–1 GB or updates weekly?
  → Managed: ingest pipeline (scheduled), chunked storage in vector DB, hybrid search

Corpus > 1 GB or real-time updates?
  → Full pipeline: streaming ingest, chunk + embed workers, BullMQ/Celery, Kafka events
```

### Ingest

| Tool | Use case |
|---|---|
| **LangChain document loaders** | PDFs, Word, HTML, Notion, Google Drive, S3 |
| **Unstructured.io** | Complex PDFs, scanned docs, tables, images |
| **Firecrawl** | Web scraping for RAG corpus |
| **Custom parser** | Structured data (JSON, CSV, database exports) |

### Chunking Strategy

| Document type | Strategy |
|---|---|
| Prose (articles, reports) | Recursive text splitter, 512–1024 tokens, 10–20% overlap |
| Code | Language-aware splitter (LangChain CodeSplitter) |
| Tables / structured data | Row-by-row or section-by-section, preserve headers |
| Long legal/technical docs | Hierarchical: section summary + full text chunks |

### Retrieval Strategy

| Context | Strategy |
|---|---|
| Default | Semantic search (cosine similarity on embeddings) |
| Keyword-heavy queries | Hybrid: BM25 + semantic, re-ranked with cross-encoder |
| Multi-document reasoning | Multi-query retrieval + MMR (maximum marginal relevance) |
| High-precision requirements | Re-rank with **Cohere Rerank** or **cross-encoder/ms-marco** |

### Eval

| Tool | Purpose |
|---|---|
| **Ragas** | RAG-specific: faithfulness, answer relevance, context precision |
| **LangSmith** | Tracing, dataset management, human eval workflows |
| **MTEB benchmark** | Embedding model selection for your domain |
| Custom golden set | 50–100 hand-crafted Q&A pairs from your actual corpus |

---

## 5. Infrastructure

### Cloud Provider

| Context | Recommendation | Why |
|---|---|---|
| Default (serverless, fast deploy) | **Vercel** (frontend) + **Railway** (backend/workers) | Zero-config deploy, preview URLs, managed infra |
| AI-heavy workloads (GPU) | **Modal** or **RunPod** | Serverless GPUs, pay-per-second |
| Enterprise / full control | **AWS** (ECS + RDS + ElastiCache) | Most services, most control, most complexity |
| Cost-optimised at scale | **Hetzner** + **Coolify** (self-hosted PaaS) | 5–10x cheaper than AWS for same compute |

### Containers

| Context | Recommendation |
|---|---|
| Development | Docker + Docker Compose |
| Production (serverless) | No containers needed — Vercel/Railway handle it |
| Production (custom infra) | Docker + ECS Fargate or Kubernetes (k3s for small scale) |

### CI/CD

| Tool | Use case |
|---|---|
| **GitHub Actions** | Default — lint, test, build, deploy on every push |
| **Vercel Deploy** | Automatic preview URLs on PR, prod deploy on main merge |
| **Railway Deploy** | Automatic deploy from GitHub, zero config |

**Minimum CI pipeline:** lint → type-check → unit tests → build. Block merge on failure.

---

## 6. Observability and Incident Tooling

### Logging

| Tool | Use case |
|---|---|
| **Axiom** | Structured logs, fast queries, generous free tier |
| **Datadog** | Full observability suite (logs + metrics + traces) — enterprise |
| **Vercel Log Drains** | Pipe Vercel logs to your preferred destination |
| **Pino** (Node.js) | Structured JSON logging library — fast, low overhead |

### Error Tracking

| Tool | Use case |
|---|---|
| **Sentry** | Default — errors, performance, session replay, alerts |
| **Highlight.io** | Open source alternative to Sentry, includes session replay |

### Metrics and Uptime

| Tool | Use case |
|---|---|
| **Grafana Cloud** | Dashboards, alerting, metrics — free tier available |
| **Better Uptime** or **Checkly** | Synthetic monitoring, uptime alerts, status pages |

### LLM Observability

| Tool | Use case |
|---|---|
| **LangSmith** | Traces every LLM call — inputs, outputs, latency, cost |
| **Helicone** | LLM proxy with built-in logging, cost tracking, caching |
| **Braintrust** | Eval + tracing combined — good for RAG pipelines |

**Rule:** never ship an AI feature without LLM observability. Silent failures and prompt regressions are invisible without it.

---

## 7. Security Tooling

### Secrets Management

| Tool | Use case |
|---|---|
| **Vercel Environment Variables** | Default for Vercel-hosted projects |
| **Doppler** | Secrets synced across environments, team access control |
| **AWS Secrets Manager** | Enterprise, fine-grained IAM, rotation |
| **1Password Secrets Automation** | Team-first, integrates with CI/CD |

**Rule:** no secrets in `.env.local` committed to git. Use `.gitignore` + environment variable injection.

### IAM and Access Control

| Tool | Use case |
|---|---|
| **Supabase RLS** (Row Level Security) | DB-level access control, enforced server-side |
| **Clerk** | Auth + RBAC, org management, SSO — excellent DX |
| **Auth.js** (NextAuth) | Open source, flexible, self-hosted option |
| **AWS IAM** | Cloud resource access control for AWS deployments |

### Dependency Scanning

| Tool | Use case |
|---|---|
| **GitHub Dependabot** | Default — auto-PRs for dependency updates and CVEs |
| **Snyk** | Deeper scanning, container and IaC scanning |
| **Socket.dev** | Supply chain attack detection for npm packages |

### SAST / Code Scanning

| Tool | Use case |
|---|---|
| **GitHub Code Scanning** (CodeQL) | Free for public repos, good for private too |
| **Semgrep** | Custom rules, fast, CI-native |
| `/security-sweep` skill | In-session security review before sprint close |

---

## 8. Testing Stack

### Unit and Integration Tests

| Language | Tool | Why |
|---|---|---|
| TypeScript / Next.js | **Vitest** | Fast, Vite-native, jest-compatible API |
| Python | **pytest** | Standard, excellent plugin ecosystem |
| API testing | **Supertest** (Node) or **httpx** (Python) | Test routes without a browser |

### End-to-End Tests

| Tool | Use case |
|---|---|
| **Playwright** | Default — multi-browser, fast, excellent DX |
| **Cypress** | Alternative — good for component testing too |

### AI / LLM Eval Harness

| Tool | Use case |
|---|---|
| **Ragas** | RAG-specific eval metrics |
| **LangSmith datasets** | Regression tests for prompts and chains |
| **Braintrust** | Eval + tracing in one |
| Custom golden set | Hand-crafted expected outputs for critical paths |

**Rule:** every prompt used in production needs at least one regression test in the eval harness.
Prompt changes are code changes — they need the same review and test gate.

### Test Coverage Targets (v1 baseline)

| Layer | Minimum coverage |
|---|---|
| Business logic (pure functions) | 80% |
| API routes | All happy paths + auth failure |
| UI components | Critical user journeys only (Playwright e2e) |
| AI outputs | Golden set pass rate ≥ 90% |

---

## Tooling Selection Cheatsheet

Answer intake questions → pick your stack:

| Intake answer | Tooling implication |
|---|---|
| Web app, small team | Next.js + Supabase + Vercel + Sentry + GitHub Actions |
| RAG needed | Add pgvector or Pinecone + LangChain + LangSmith + Ragas |
| Python AI backend | FastAPI + Celery + Redis + Modal (GPU if needed) |
| HIPAA/GDPR regulated | Supabase (data residency) + Doppler + Sentry + audit log |
| > 10k users | Add Redis cache + BullMQ + Grafana + uptime monitoring |
| Enterprise B2B | Clerk (SSO) + SOC 2 tooling + Datadog |
| Offline / data sovereignty | Ollama + Qdrant + self-hosted Coolify on Hetzner |
