# AK Cognitive OS — Framework Flow

```mermaid
flowchart TD

    START([New Session]) --> SO["/session-open\nGenerates standup\nDone / Next / Blockers"]
    SO --> PLAN_CHECK{"Planning docs\nconfirmed?"}

    PLAN_CHECK -->|No - greenfield| DISCOVERY["Discovery Conversation\n8 questions → summarize → confirm"]
    PLAN_CHECK -->|No - mid-build| RECOVERY["Recovery Conversation\n7 questions + code inspection\n→ current-state.md"]
    PLAN_CHECK -->|Yes| AK_REQ

    DISCOVERY --> PROB_SCOPE["Confirm\nproblem-definition.md\nscope-brief.md"]
    RECOVERY --> CURRENT_STATE["Generate\ncurrent-state.md\nBackfill planning docs"]
    PROB_SCOPE --> HLD_CONV["HLD Conversation\n→ confirm hld.md"]
    CURRENT_STATE --> HLD_CONV
    HLD_CONV --> LLD_CONV["LLD for first features\n→ docs/lld/<feature>.md"]
    LLD_CONV --> AK_REQ["AK gives requirements"]

    AK_REQ --> BA["/ba\nConfirms business logic\nwrites ba-logic.md"]
    BA --> UX["/ux\nWireframes + interaction rules\nwrites ux-specs.md"]
    UX --> ARCH["/architect\nDecomposes tasks\nwrites todo.md PENDING"]
    ARCH --> AK_APPROVE{AK approves\ntask plan?}
    AK_APPROVE -->|No| ARCH
    AK_APPROVE -->|Yes| QA_CRITERIA["/qa\nAdds acceptance criteria\nto each PENDING task"]

    QA_CRITERIA --> JD["/junior-dev\nBuilds task\nIN_PROGRESS to READY_FOR_QA"]
    JD --> CI["CI\nlint + build + tests"]
    CI -->|Fail| JD
    CI -->|Pass| ARCH_REVIEW["/architect\nCode review"]
    ARCH_REVIEW -->|Return| JD
    ARCH_REVIEW -->|Approve| UX_REVIEW["/ux\nUI review vs wireframe"]
    UX_REVIEW -->|Revision needed| JD
    UX_REVIEW -->|Approved| QA_RUN["/qa-run\nChecks each AC\npass / fail"]
    QA_RUN -->|QA REJECTED| JD
    QA_RUN -->|QA APPROVED| POST

    subgraph POST ["Post-Build Checks"]
        SS["/security-sweep\n8 security questions\nsignoff: true or false"]
        RG["/regression-guard\ntests + build + lint\n2 policy checks\nGREEN or BLOCKED"]
        RP["/review-packet\nAssembles Codex packet\npacket_ready: true or false"]
        SS --> RG --> RP
    end

    POST -->|BLOCKED| JD
    POST -->|packet ready| CODEX{Codex review\nneeded?}
    CODEX -->|No| MERGE
    CODEX -->|Yes| CODEX_REVIEW["Codex\nReviews packet"]
    CODEX_REVIEW -->|Return| JD
    CODEX_REVIEW -->|Approve| MERGE

    MERGE["Architect merges to main\nArchives task"] --> SC["/session-close\nExtracts lessons\nWrites next-action.md"]
    SC --> END([Session End])

    subgraph SUPPORT ["Support Agents - invoke any time"]
        RES["/researcher\n5 sub-personas\nlegal, business, policy, news, technical"]
        COMP["/compliance\n4 sub-personas\ndata-privacy, data-security, pii, phi"]
        ALOG["/audit-log\nAppended after every agent run"]
        LES["/lessons-extractor\nPulls lessons from session"]
    end

    AK_REQ -.->|research needed| RES
    ARCH -.->|research needed| RES
    ARCH_REVIEW -.->|compliance check| COMP
    JD -.->|log entry| ALOG
    SC -.-> LES

    classDef persona fill:#4A90D9,color:#fff,stroke:#2C5F8A
    classDef skill fill:#7B68EE,color:#fff,stroke:#4B3BA8
    classDef decision fill:#F5A623,color:#fff,stroke:#C07800
    classDef support fill:#50C878,color:#fff,stroke:#2D7A45
    classDef terminal fill:#333,color:#fff,stroke:#000

    classDef planning fill:#E8A0BF,color:#fff,stroke:#B8608F
    class DISCOVERY,RECOVERY,PROB_SCOPE,CURRENT_STATE,HLD_CONV,LLD_CONV planning
    class PLAN_CHECK decision
    class BA,UX,ARCH,ARCH_REVIEW,UX_REVIEW,QA_CRITERIA,QA_RUN,JD persona
    class SO,SS,RG,RP,SC skill
    class AK_APPROVE,CI,CODEX decision
    class RES,COMP,ALOG,LES support
    class START,END terminal
```

---

## Colour Key

| Colour | Meaning |
|--------|---------|
| Pink | Planning stages (discovery, recovery, HLD, LLD) |
| Blue | Personas (BA, UX, Architect, Junior Dev, QA) |
| Purple | Workflow skills (session-open, security-sweep, etc.) |
| Orange | Decision points |
| Green | Support agents (Researcher, Compliance, Audit Log) |
| Dark | Session start / end |

---

## Reading the Flow

1. **Session opens** → standup → check planning docs
2. **Planning** (if needed): Discovery/recovery conversation → confirm problem-definition, scope-brief, HLD → create LLD for first features
3. **Pre-build**: BA confirms logic, UX draws wireframes, Architect breaks into tasks, QA adds acceptance criteria
3. **Build loop**: Junior Dev builds → CI → Architect reviews → UX checks UI → QA tests each AC
4. **Post-build**: Security sweep + regression guard + review packet (all must pass)
5. **Optional Codex review** for complex sprints
6. **Merge → session close** → lessons extracted → next-action.md written
7. **Support agents** (green) can be called at any point — researcher for questions, compliance for risk checks
