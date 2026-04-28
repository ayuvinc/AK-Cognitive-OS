# tasks/ba-logic.md -- Taskflow

## Purpose

BA writes confirmed business logic decisions here.
Architect reads before designing. Junior Dev reads before building.
Cleared at end of sprint after tasks are archived.

---

## Active Decisions

## Auth — Sign-up and Email Confirmation
decision: Email confirmation is required before a user can access the dashboard. Unconfirmed users are redirected to a "check your email" page.
rationale: Prevents throwaway accounts and ensures a valid email for team invite notifications.
constraints: Supabase handles confirmation emails; no custom email service in Session 1.
confirmed_by: BA | Architect
date: 2024-01-15

## Auth — Single Role in Session 1
decision: All users have the same role in Session 1. Role-based access (admin / member) is deferred to Session 3.
rationale: Scope control — team roles require invite flow which is a separate sprint.
constraints: The `users` table must not enforce role columns in Session 1 to avoid migration cost later.
confirmed_by: BA | Architect
date: 2024-01-15

## App Layout — Navigation Scope
decision: Navigation in Session 1 includes only: Dashboard, Projects, Tasks. Settings and Profile are stubs (links render but pages are empty).
rationale: Avoids building pages that will change when roles are introduced in Session 3.
constraints: Stub pages must not throw 404 — render an empty state with a "coming soon" message.
confirmed_by: BA
date: 2024-01-15
