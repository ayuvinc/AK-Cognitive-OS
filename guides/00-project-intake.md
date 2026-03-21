# Guide 00 — Project Intake

## Purpose

Answer these questions before writing a single line of code or opening a Claude session.
The Architect and BA use these answers to set architecture constraints, compliance gates,
and the session roadmap in `CLAUDE.md`.

Run this once at project start. Revisit if scope changes significantly.

---

## 1. Product Type

**What are you building?**

| Option | Examples |
|---|---|
| Web app | SaaS dashboard, e-commerce, content platform |
| Mobile app | iOS/Android native or cross-platform |
| API / backend service | REST/GraphQL API, data pipeline, webhook service |
| Agentic system | Multi-agent workflow, autonomous task runner, AI assistant |
| Hybrid | Web app + agentic backend, mobile + API |

**Questions to answer:**
- Is there a user-facing frontend, or is this purely backend/API?
- Is this greenfield or extending an existing system?
- Will AI be a core feature (generative, chat, decision-making) or a utility (search, classification)?

---

## 2. Domain and Risk Level

**How sensitive is this domain?**

| Risk Level | Characteristics |
|---|---|
| Low | Public content, no personal data, no financial transactions |
| Medium | User accounts, non-sensitive personal data, standard authentication |
| High | Financial data, health/medical context, legal documents, children's data |
| Regulated | HIPAA (health), PCI-DSS (payment), GDPR/CCPA (EU/US privacy), FERPA (education) |

**Questions to answer:**
- Will users provide sensitive personal information?
- Does your jurisdiction require specific compliance (EU = GDPR, US health = HIPAA)?
- Are there industry regulations (financial services, healthcare, legal)?
- What happens if data is breached — financial penalty, reputational damage, legal liability?

→ High or Regulated: activate the Compliance persona before architecture design.

---

## 3. Core Features and Constraints

**What are the 3–5 must-have features for v1?**

Write them as user journeys, not technical specs:
- "User can sign up, log in, and reset their password"
- "User can upload a document and ask questions about it"
- "Admin can view all users and suspend accounts"

**Hard constraints to identify:**
- Features that absolutely cannot be cut for launch
- Features that are explicitly out of scope for v1
- Performance constraints (e.g. "must respond in under 2 seconds")
- Platform constraints (e.g. "must work on mobile Safari")
- Integration constraints (e.g. "must connect to existing Salesforce instance")

---

## 4. Data Types

**What data will your system store or process?**

| Data Type | Definition | Risk |
|---|---|---|
| PII | Name, email, phone, address, IP, device ID | GDPR/CCPA applies |
| PHI | Medical records, diagnoses, prescriptions, health metrics | HIPAA applies |
| Financial | Credit card numbers, bank accounts, transaction history | PCI-DSS applies |
| Biometric | Fingerprints, face data, voice prints | High sensitivity |
| Children's data | Data from users under 13 (US) or under 16 (EU) | COPPA/GDPR applies |
| Proprietary | Trade secrets, source code, internal documents | IP risk |
| Public | Open data, non-personal content | Low risk |

**Questions to answer:**
- What data does the user give you at signup?
- What data does the user create or upload during normal use?
- What data does your system generate (logs, analytics, AI outputs)?
- Who can see what? (user sees own data only, admin sees all, etc.)
- Where is data stored and in which country?

---

## 5. RAG and AI Memory Needs

**Does your product need Retrieval-Augmented Generation?**

RAG = AI answers questions by searching a knowledge base rather than relying on training data alone.
Use it when: the AI needs to answer questions about specific documents, proprietary data, or recent information.

**Questions to answer:**

| Question | Your Answer |
|---|---|
| Does the AI need to answer questions about specific content? | yes / no |
| What is the corpus? | user documents / company knowledge base / product catalogue / other |
| Approximate corpus size | < 1 MB / 1–100 MB / 100 MB–1 GB / > 1 GB |
| How often does the corpus update? | static / weekly / daily / real-time |
| Query volume (searches per day) | < 100 / 100–10k / > 10k |
| Acceptable retrieval latency | < 1s / 1–3s / best-effort |

→ See `guides/06-tooling-baseline.md` for RAG stack recommendations based on these answers.

---

## 6. Model Usage

**How will you use AI models?**

| Option | When to use |
|---|---|
| Hosted API (OpenAI, Anthropic, Google) | Default — no infra overhead, pay-per-token |
| Local / self-hosted (Ollama, vLLM) | Data sovereignty requirements, offline use, cost at scale |
| Hybrid | Sensitive data stays local, general queries go to hosted |

**Questions to answer:**
- Can data leave your infrastructure to a third-party AI provider?
- Are there data residency requirements (data must stay in EU, etc.)?
- What is the expected token volume per month? (Cost estimate needed?)
- Do you need fine-tuned or domain-specific models, or is a general model sufficient?
- Do you need multimodal (images, audio, video)?

---

## 7. Scale Targets

**What does "working at scale" mean for this product?**

| Dimension | Starter | Growth | Scale |
|---|---|---|---|
| Concurrent users | < 100 | 100–10k | > 10k |
| Requests per second | < 10 | 10–1000 | > 1000 |
| Data volume | < 1 GB | 1–100 GB | > 100 GB |
| Uptime requirement | Best effort | 99% | 99.9%+ |
| Latency (p95) | < 3s | < 1s | < 500ms |

**Questions to answer:**
- What is the realistic number of users at launch vs. 6 months vs. 1 year?
- Are there peak traffic patterns (e.g. business hours only, campaign spikes)?
- What is the cost of downtime — inconvenient, or business-critical?
- Is global availability needed or is one region sufficient for v1?

---

## 8. Compliance and Security Requirements

**What must be true about your security posture at launch?**

Minimum baseline (every project):
- [ ] Secrets in environment variables, never in code
- [ ] Authentication on every protected route
- [ ] HTTPS enforced
- [ ] Dependencies scanned for known vulnerabilities
- [ ] No PII in logs

Additional requirements (check all that apply):
- [ ] GDPR compliance (EU users or EU data)
- [ ] CCPA compliance (California users)
- [ ] HIPAA compliance (health data, US)
- [ ] PCI-DSS compliance (payment card data)
- [ ] SOC 2 Type II (enterprise B2B customers may require this)
- [ ] Penetration testing before launch
- [ ] Data encryption at rest
- [ ] Audit log required (who did what, when)
- [ ] Right to deletion / data export (GDPR subject rights)
- [ ] SSO / SAML required (enterprise customers)

→ Any checked box = activate Compliance persona before architecture is finalised.

---

## 9. Team and Budget

**Who is building this and with what resources?**

| Question | Answer |
|---|---|
| Who is writing the code? | Solo founder / small team / agency / AI-assisted solo |
| AI coding tools available? | Claude Code, Codex, Cursor, GitHub Copilot |
| Monthly infra budget for v1 | < $50 / $50–200 / $200–1000 / > $1000 |
| Monthly AI API budget | < $50 / $50–500 / > $500 |
| Total runway to launch | < 1 month / 1–3 months / 3–6 months / > 6 months |

**Answers affect:**
- Infrastructure choices (managed services vs self-hosted)
- AI model selection (cost per token matters at scale)
- Scope decisions (fewer features, faster launch)

---

## 10. Delivery Timeline and Success Criteria

**When does v1 ship and how do you know it worked?**

| Item | Answer |
|---|---|
| Target launch date | |
| Hard deadline? | yes / no / soft target |
| Definition of "launched" | deployed to production / first paying customer / public URL live |
| v1 success metric | N users / $N revenue / N tasks completed / other |
| Post-launch: what does v2 look like? | |

**Questions to answer:**
- What is the minimum feature set that makes this worth launching?
- What would cause you to delay launch?
- Who is the first user / customer you are building for specifically?
- How will you measure whether the product is working for them?

---

## Intake Summary Template

Fill this in after answering the above. Paste into `CLAUDE.md` under Project Overview.

```
Product type:       [web app / mobile / API / agentic / hybrid]
Risk level:         [low / medium / high / regulated]
Regulated by:       [GDPR / HIPAA / PCI / none]
Core features:      [3–5 bullet points]
Data types:         [PII / PHI / payment / proprietary / public]
RAG needed:         [yes / no] — corpus: [size] — update freq: [static/daily/real-time]
Model usage:        [hosted / local / hybrid] — provider: [name]
Scale target:       [users at launch] — uptime: [%]
Launch target:      [date or sprint count]
Success metric:     [measurable outcome]
Compliance gates:   [list or none]
```
