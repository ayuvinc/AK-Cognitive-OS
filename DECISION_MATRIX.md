# Decision Matrix -- AK Cognitive OS

Before using this matrix, answer the intake questions in your sprint brief. Those answers --
specifically your target platform, expected user volume, budget tier, team size, and data
sensitivity -- are the inputs that make this matrix useful. Without those answers you are guessing.
Work through each section top to bottom, pick one option per section, and record your choices in
the sprint brief. If you are genuinely unsure between two options in a section, pick the one in
the Notes column that says "default" and revisit after your first working version is live.

---

## Section 1: Frontend Stack

| Option                    | Best for                                | Budget       | Complexity | Notes                                                                 |
|---------------------------|-----------------------------------------|--------------|------------|-----------------------------------------------------------------------|
| Next.js (default)         | Full-stack web apps, SEO, dashboards    | Any          | Medium     | Default for this framework. App Router + Route Handlers in one repo.  |
| React + Vite (SPA)        | Single-page apps, no SSR needed         | Low-Medium   | Low        | Simpler than Next.js. Good if SEO is not a requirement.               |
| Astro (content/marketing) | Marketing sites, blogs, docs            | Low          | Low        | Ships minimal JS. Best performance for mostly-static content.         |
| React Native + Expo       | iOS + Android from one codebase         | Medium       | Medium     | Use when mobile is the primary surface, not a secondary add-on.       |
| SwiftUI (iOS native)      | iOS-only apps requiring native UX       | Medium-High  | High       | Best performance and native feel on iOS. Requires macOS + Xcode.      |

---

## Section 2: Backend / API

| Option                    | Best for                                        | Language   | Notes                                                                        |
|---------------------------|-------------------------------------------------|------------|------------------------------------------------------------------------------|
| Next.js Route Handlers    | Full-stack apps already using Next.js           | TypeScript | Default. Co-located with frontend. No separate server to deploy.             |
| FastAPI                   | AI/ML workloads, Python data pipelines, RAG     | Python     | Best choice when backend logic is Python-heavy (embeddings, LLM calls).      |
| Hono                      | Edge-deployed APIs, Cloudflare Workers          | TypeScript | Extremely lightweight. Use when cold-start latency on edge matters.          |
| Express                   | Simple REST APIs, existing Node.js codebases    | JavaScript | Mature and well-documented. More boilerplate than Hono for new projects.     |
| Django                    | Large Python apps, admin-heavy tools, CMS       | Python     | Batteries-included. Good when you need a built-in admin panel quickly.       |

---

## Section 3: Primary Database

| Option                  | Type            | Best for                                       | Managed | Free tier             |
|-------------------------|-----------------|------------------------------------------------|---------|-----------------------|
| Supabase (Postgres)     | Relational      | Full-stack apps, auth + DB in one service      | Yes     | Yes (generous)        |
| PlanetScale             | Relational      | High-scale MySQL, branching workflow           | Yes     | Yes (limited)         |
| Neon                    | Relational      | Serverless Postgres, auto-pause on idle        | Yes     | Yes                   |
| MongoDB Atlas           | Document (NoSQL)| Flexible schema, unstructured or nested data   | Yes     | Yes (512 MB)          |
| PostgreSQL direct       | Relational      | Full control, self-hosted or VPS               | No      | No (infra cost only)  |

---

## Section 4: Vector Database

| Option              | Hosting       | Best for                                        | Free tier    | Max scale              |
|---------------------|---------------|-------------------------------------------------|--------------|------------------------|
| pgvector/Supabase   | Managed cloud | Projects already on Supabase, low-medium scale  | Yes          | Tens of millions rows  |
| Pinecone            | Managed cloud | Production RAG at scale, low-latency search     | Yes (1 index)| Hundreds of millions   |
| Qdrant              | Self-hosted   | Full control, on-prem or private cloud          | No           | Unlimited (infra bound)|
| Weaviate            | Managed/self  | Multimodal search, hybrid keyword + vector      | Yes (cloud)  | Large scale            |
| Chroma (local only) | Local         | Local dev and prototyping only                  | Yes          | Not for production     |

---

## Section 5: LLM Provider

| Option               | Best for                                          | Cost tier    | Context window | Notes                                                             |
|----------------------|---------------------------------------------------|--------------|----------------|-------------------------------------------------------------------|
| Anthropic Claude     | Reasoning, long documents, instruction-following  | Medium-High  | Up to 200K     | Default for this framework. Best for complex multi-step tasks.    |
| OpenAI GPT-4o        | General purpose, broad ecosystem, tool calling    | Medium-High  | 128K           | Largest third-party ecosystem. Strong function-calling support.   |
| Google Gemini Flash  | High-volume, cost-sensitive inference             | Low          | 1M             | Best cost-per-token at scale. Weaker at strict instruction follow.|
| Ollama (local)       | Data privacy, offline, no API cost                | Free         | Model dependent| Runs on your hardware. Quality depends on local model chosen.     |
| OpenRouter           | Model routing, fallback, multi-provider access    | Varies       | Varies         | Single API key routes to any model. Good for model experimentation.|

---

## Section 6: Hosted vs Local AI

| Factor              | Hosted                                      | Local                                                |
|---------------------|---------------------------------------------|------------------------------------------------------|
| Data privacy        | Data leaves your machine to provider servers| Data stays fully on your hardware                    |
| Cost at low volume  | Low (pay per token, no infra cost)          | Higher upfront (hardware or GPU rental)              |
| Cost at high volume | Can become expensive at scale               | Near-zero marginal cost once hardware is paid for    |
| Setup complexity    | Minimal (API key + HTTP call)               | High (model download, runtime setup, hardware config)|
| Offline support     | No (requires internet connection)           | Yes (runs without internet)                          |
| Model selection     | Wide (access to frontier models)            | Limited (open-weight models only)                    |
| HIPAA compliance    | Depends on provider BAA availability        | Possible with proper infra controls                  |

---

## Section 7: Operating Mode

| Situation                                                               | Mode          | Why                                                                               |
|-------------------------------------------------------------------------|---------------|-----------------------------------------------------------------------------------|
| Active development sprint with code generation needed                   | COMBINED      | Claude plans, Codex generates -- best output for production code                  |
| Planning or architecture sprint, no code needed yet                     | SOLO_CLAUDE   | No Codex session required until the plan is locked                                |
| Documentation sprint (writing guides, glossary, release notes)          | SOLO_CLAUDE   | Claude handles all writing; no code generation involved                           |
| Codex task is fully defined and prompt is complete                      | SOLO_CODEX    | Skip live Claude involvement when the brief is airtight                           |
| Research sprint (evaluating tools, comparing options)                   | SOLO_CLAUDE   | Researcher persona + Claude is sufficient; no code to generate                    |
| Codex access is unavailable (quota exceeded, outage)                    | SOLO_CLAUDE   | Continue planning and documentation work without blocking the sprint              |
| Sprint has an S0 finding that requires human decision                   | SOLO_CLAUDE   | Resolve the finding with Claude before re-engaging Codex                          |
| First sprint on a new project (setup and scaffolding)                   | COMBINED      | Both agents needed to configure the project structure correctly                   |
| Bug fix sprint where the root cause is already known                    | SOLO_CODEX    | Prompt is well-defined; no planning needed from Claude mid-session                |
| Sprint involves regulated data (HIPAA, financial, PII)                  | COMBINED      | Compliance persona must review before Codex generates any data-handling code      |
| Retrospective or lessons-learned session                                | SOLO_CLAUDE   | Reflection and documentation work; no new code is produced                        |
