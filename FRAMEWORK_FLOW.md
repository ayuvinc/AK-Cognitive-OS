# AK Cognitive OS — Framework Flow

```mermaid
flowchart TD

    %% ─── SESSION LIFECYCLE ───────────────────────────────────────────────
    START([🟢 New Session]) --> SO["/session-open\nGenerates standup\nDone / Next / Blockers"]
    SO --> AK_REQ["👤 AK\nGives requirements"]

    %% ─── PRE-BUILD PHASE ─────────────────────────────────────────────────
    AK_REQ --> BA["/ba\nConfirms business logic\n→ ba-logic.md"]
    BA --> UX["/ux\nWireframes + interaction rules\n→ ux-specs.md"]
    UX --> ARCH["/architect\nDecomposes tasks\n→ todo.md PENDING"]
    ARCH --> AK_APPROVE{AK approves\ntask plan?}
    AK_APPROVE -- No → ARCH
    AK_APPROVE -- Yes --> QA_CRITERIA["/qa\nAdds acceptance criteria\nto each PENDING task"]

    %% ─── BUILD PHASE ─────────────────────────────────────────────────────
    QA_CRITERIA --> JD["/junior-dev\nBuilds task\nIN_PROGRESS → READY_FOR_QA"]
    JD --> CI["CI\nlint + build + tests"]
    CI -- Fail --> JD
    CI -- Pass --> ARCH_REVIEW["/architect\nCode review"]
    ARCH_REVIEW -- Return --> JD
    ARCH_REVIEW -- Approve --> UX_REVIEW["/ux\nUI review vs wireframe"]
    UX_REVIEW -- Revision needed --> JD
    UX_REVIEW -- Approved --> QA_RUN["/qa-run\nChecks each AC\npass / fail"]
    QA_RUN -- QA_REJECTED --> JD
    QA_RUN -- QA_APPROVED --> POST

    %% ─── POST-BUILD CHECKS ───────────────────────────────────────────────
    subgraph POST ["Post-Build Checks"]
        SS["/security-sweep\n8 security questions\nsignoff: true/false"]
        RG["/regression-guard\nTests + build + lint\n+ 2 policy checks\nlegacy_label: GREEN/BLOCKED"]
        RP["/review-packet\nAssembles Codex packet\npacket_ready: true/false"]
        SS --> RG --> RP
    end

    POST -- BLOCKED --> JD
    POST -- packet_ready true --> CODEX{Codex\nreview\nneeded?}
    CODEX -- No --> MERGE
    CODEX -- Yes --> CODEX_REVIEW["Codex\nReviews packet\nApprove / Return"]
    CODEX_REVIEW -- Return --> JD
    CODEX_REVIEW -- Approve --> MERGE

    %% ─── MERGE + CLOSE ───────────────────────────────────────────────────
    MERGE["Architect merges to main\nArchives task from todo.md"] --> SC["/session-close\nExtracts lessons\nWrites next-action.md"]
    SC --> END([🔴 Session End])

    %% ─── SUPPORT AGENTS (available any time) ─────────────────────────────
    subgraph SUPPORT ["Support Agents — invoke any time"]
        direction LR
        RES["/researcher\n+ 5 sub-personas\nlegal · business · policy\nnews · technical"]
        COMP["/compliance\n+ 4 sub-personas\ndata-privacy · data-security\npii-handler · phi-handler"]
        ALOG["/audit-log\nAppended after\nevery agent run"]
        LES["/lessons-extractor\nPulls lessons\nfrom session"]
    end

    AK_REQ -.->|research needed| RES
    ARCH -.->|research needed| RES
    ARCH_REVIEW -.->|compliance check| COMP
    JD -.->|log entry| ALOG
    SC -.-> LES

    %% ─── STYLES ──────────────────────────────────────────────────────────
    classDef persona fill:#4A90D9,color:#fff,stroke:#2C5F8A
    classDef skill fill:#7B68EE,color:#fff,stroke:#4B3BA8
    classDef decision fill:#F5A623,color:#fff,stroke:#C07800
    classDef support fill:#50C878,color:#fff,stroke:#2D7A45
    classDef terminal fill:#333,color:#fff,stroke:#000

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
| Blue | Personas (BA, UX, Architect, Junior Dev, QA) |
| Purple | Workflow skills (session-open, security-sweep, etc.) |
| Orange | Decision points |
| Green | Support agents (Researcher, Compliance, Audit Log) |
| Dark | Session start / end |

---

## Reading the Flow

1. **Session opens** → standup → AK gives requirements
2. **Pre-build**: BA confirms logic, UX draws wireframes, Architect breaks into tasks, QA adds acceptance criteria
3. **Build loop**: Junior Dev builds → CI → Architect reviews → UX checks UI → QA tests each AC
4. **Post-build**: Security sweep + regression guard + review packet (all must pass)
5. **Optional Codex review** for complex sprints
6. **Merge → session close** → lessons extracted → next-action.md written
7. **Support agents** (green) can be called at any point — researcher for questions, compliance for risk checks
