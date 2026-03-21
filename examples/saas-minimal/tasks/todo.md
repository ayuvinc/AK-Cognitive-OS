# tasks/todo.md -- Taskflow

## SESSION STATE

```
Status:         CLOSED
Active task:    none
Active persona: none
Blocking issue: none
Last updated:   Session 0
```

---

## Active Tasks

<!-- Architect moves tasks here from Backlog when a session opens -->

---

## Backlog

### TASK-001

**Title:** Set up Supabase project, configure auth, create users table with RLS

**Status:** PENDING

**Acceptance Criteria:**
- Supabase project is created; `NEXT_PUBLIC_SUPABASE_URL` and
  `NEXT_PUBLIC_SUPABASE_ANON_KEY` are documented in `.env.local.example`
- Email + password auth is enabled in the Supabase dashboard; a test user
  can sign up and receive a confirmation email
- A `users` table exists with `id` (uuid, references auth.users), `email`
  (text), `created_at` (timestamptz); RLS is enabled with a policy that
  allows users to read only their own row

**Assigned to:** Junior Dev

---

### TASK-002

**Title:** Build app layout -- navbar, sidebar, protected route wrapper

**Status:** PENDING

**Acceptance Criteria:**
- A persistent navbar renders the Taskflow logo and a sign-out button on all
  authenticated pages
- A sidebar renders navigation links (Dashboard, Projects, Tasks) and
  collapses correctly at 375px viewport width
- Unauthenticated users who visit any `/dashboard/*` route are redirected to
  `/login`; authenticated users who visit `/login` are redirected to
  `/dashboard`

**Assigned to:** Junior Dev

---

### TASK-003

**Title:** Deploy to Vercel, configure environment variables, verify auth flow end-to-end

**Status:** PENDING

**Acceptance Criteria:**
- The Next.js app deploys successfully to Vercel with zero build errors; the
  production URL is documented in `releases/session-1.md`
- All required environment variables (`NEXT_PUBLIC_SUPABASE_URL`,
  `NEXT_PUBLIC_SUPABASE_ANON_KEY`) are set in the Vercel project dashboard
  and the production app can reach Supabase without errors
- A full sign-up --> email confirm --> sign-in --> dashboard --> sign-out
  flow completes without errors on the production Vercel URL

**Assigned to:** Junior Dev

---

## Archive

<!-- Completed tasks moved here by Architect at session close -->
