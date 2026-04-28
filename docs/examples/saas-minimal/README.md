# Example: SaaS Minimal

This example shows how to use the AK-Cognitive-OS framework to build a B2B SaaS
product from scratch using the multi-persona workflow.

---

## What This Shows

End-to-end auth, dashboard layout, and CRUD for a fictional B2B SaaS called
Taskflow -- a team task management product. Each session in this example maps
to a real framework session with defined inputs, outputs, and persona handoffs.

---

## Stack

- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS v4
- Supabase (auth + database + RLS)
- Vercel (deployment)

---

## How to Use This Example

1. Copy `examples/saas-minimal/CLAUDE.md` to your own project root.
2. Run `scripts/bootstrap-project.sh <your_project_path>` to scaffold
   `tasks/` and `releases/` directories.
3. Fill in the remaining placeholder `[OWNER_NAME]` in your copied CLAUDE.md.
4. Open a Claude Code session from your project root and follow the Session
   Start Checklist in CLAUDE.md.

---

## Personas Used

- BA (Business Analyst) -- confirms business logic before any design or code
- UX -- user flow, wireframes, interaction rules
- Architect -- system design, task authoring, code review
- Junior Dev -- implementation
- QA -- acceptance criteria, test execution, QA_APPROVED / QA_REJECTED verdicts

---

## Session Roadmap

| Session | Focus |
|---|---|
| Session 1 | Auth + layout -- Supabase auth, protected routes, app shell |
| Session 2 | CRUD feature -- task creation, listing, status updates |
| Session 3 | QA + deploy -- full QA pass, Vercel deploy, end-to-end verification |
