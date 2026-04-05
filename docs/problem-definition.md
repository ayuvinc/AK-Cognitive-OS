---
Status: confirmed
Source: user-confirmed
Last confirmed with user: 2026-04-05
Owner: AK
Open questions: 0
---

# Problem Definition

## Primary User

AK — a software product manager and solo developer who uses Claude Code as a primary development environment. Technically fluent, builds across multiple domains (pharma, clinical workflows, consumer apps), and needs AI assistance that behaves like a disciplined engineering team rather than a generic chat assistant.

## User Pain / Problem

Claude Code (and LLM agents generally) produce inconsistent, unauditable output when operating without structured role constraints. A single Claude session will switch between product manager, architect, and developer reasoning within minutes — producing decisions that conflict with each other and cannot be traced. There is no enforcement layer: Claude will skip planning, ignore business logic gates, and merge to main without QA if not constrained.

## Current Workaround

AK manually re-states role instructions at the start of every session and corrects drift mid-session. This is slow (5–10 minutes of preamble per session), brittle (forgotten on context reset), and produces no audit trail.

## Why Current State Fails

- Role boundaries collapse within a single session when context shifts
- No enforcement: Claude cannot be held to a constraint it stated earlier without external hooks
- No audit trail: decisions cannot be traced back to a persona or requirement
- No handoff structure: switching between architect and developer reasoning produces contradictions that are invisible until QA or production

## Success Outcome

A developer running a Claude Code session on any project scaffolded from AK-Cognitive-OS can open a session, activate the correct persona, execute a full BA → UX → Architect → Dev → QA cycle, and close with a complete audit trail — without manually re-stating role constraints or correcting persona drift.

## Non-Goals

- Not a general-purpose AI framework (no inference layer, no model hosting)
- Not a project management tool (no sprint planning UI, no Gantt charts)
- Not a code generator (generates tasks and scaffolding, not feature implementation code)
- Not a multi-user system (single developer + Claude Code, no team collaboration layer)
