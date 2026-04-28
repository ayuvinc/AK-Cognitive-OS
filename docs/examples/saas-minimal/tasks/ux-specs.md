# tasks/ux-specs.md -- Taskflow

## Purpose

UX writes interaction specs here. Junior Dev builds exactly to these specs.
Cleared at end of sprint after tasks are archived.

---

## Session 1 — Auth + Layout

### Login Page (`/login`)

- Single card centered on screen, max-width 400px
- Fields: Email (type=email), Password (type=password)
- Primary CTA: "Sign in" button (full width)
- Secondary link: "Don't have an account? Sign up" below the button
- Error state: inline red text below the failing field ("Invalid email or password" — do not specify which field failed for security)
- Loading state: button shows spinner, is disabled during request
- Mobile (375px): card fills full width with 16px horizontal padding

### Sign-up Page (`/signup`)

- Same card layout as login
- Fields: Email, Password, Confirm Password
- Primary CTA: "Create account"
- On success: redirect to `/check-email` — do not auto-login (confirmation required)
- Error: password mismatch shown inline before submit

### Check Email Page (`/check-email`)

- Centered message: "Check your inbox — we sent a confirmation link to [email]"
- No actions except a "Resend email" link (Supabase resend, rate-limited to 1/min)

### App Shell — Authenticated Layout

- Persistent top navbar: Taskflow logo (left), user email (right), Sign out button (right)
- Left sidebar: 240px wide on desktop; icons + labels for Dashboard, Projects, Tasks
- Main content: fills remaining width with 24px padding
- Mobile (375px): sidebar collapses to bottom tab bar with icons only (no labels)

### Protected Route Behaviour

- Any `/dashboard/*` route visited without a valid session → redirect to `/login`
- `/login` or `/signup` visited with a valid session → redirect to `/dashboard`
- Redirect preserves the original URL as `?next=` param so user lands where they intended

## Accessibility Notes

- All form fields have visible labels (not placeholder-only)
- Focus states visible on all interactive elements
- Colour contrast meets WCAG AA minimum
