# Security Policy

## Supported Version

| Version | Supported |
|---------|-----------|
| 3.0.x (current) | Yes |
| 2.2.x | Security fixes only |
| < 2.2 | No |

The current supported version is **v3.0.0** on `main`.

---

## Reporting a Vulnerability

**Do not open a public GitHub issue for unpatched vulnerabilities.**

Report security issues privately to the repository maintainer:

- **GitHub:** Open a [private security advisory](https://github.com/ayuvinc/AK-Cognitive-OS/security/advisories/new)
- **Email:** Contact via the profile linked on the repository

Include in your report:
- Affected file paths or framework components
- Impact and likely exploitability
- Steps to reproduce or proof of concept
- Suggested remediation, if available

---

## Scope

Security reports are especially relevant for:

| Component | Risk area |
|---|---|
| `scripts/hooks/*.sh` | Shell injection, path traversal, bypass of enforcement gates |
| `scripts/bootstrap-project.sh` | Unvalidated path arguments, unsafe writes |
| `scripts/remediate-project.sh` | Overwriting project files outside intended scope |
| `.claude/settings.json` template | Permission grants that are too broad |
| `mcp-servers/*.py` | MCP server trust boundary issues |
| `validators/*.py` | Logic bypass in enforcement validators |
| `scripts/hooks/guard-git-push.sh` | Gate bypass patterns (QA, governance, security) |

---

## What This Framework Does and Does Not Guarantee

AK Cognitive OS provides **process controls and local automation**. It does not by itself guarantee:

- Application-level product security for downstream projects
- Regulatory compliance certification (HIPAA, GDPR, etc.)
- Secure deployment of projects built with the framework
- Safety of custom modifications made by downstream users
- Protection against a Claude Code session compromised at the host level

Hooks and validators enforce **framework process rules** — they are not a substitute for application security review, penetration testing, or compliance audits.

---

## Known Limitations

- **`guard-git-push.sh`** requires `ACTIVE_PERSONA=architect` in the shell environment. Claude Code's skill loader does not propagate this automatically. Workaround documented in `tasks/lessons.md`.
- **`guard-planning-artifacts.sh`** only applies to Standard and High-Risk tier projects. MVP projects are exempt by design.
- Hook enforcement only applies inside Claude Code sessions. Direct file edits outside Claude Code bypass hook checks — this is defense-in-depth by design.

---

## Handling Expectations

The maintainer will:

1. Acknowledge receipt within **5 business days**
2. Triage and assess impact within **14 days**
3. Decide to: patch immediately, issue a mitigation note, or defer with rationale
4. Notify the reporter before public disclosure

Please avoid public disclosure until the maintainer confirms the issue is resolved or safe to disclose.

---

## Security in Downstream Projects

If you use this framework in a project, you are responsible for:

- Reviewing hook scripts before enabling them (`scripts/hooks/`)
- Setting the correct `Tier:` in `CLAUDE.md` (Standard or High-Risk for sensitive projects)
- Running `python3 validators/runner.py` regularly to catch framework drift
- Not committing `settings.local.json` or any credentials to version control
- Auditing `mcp-servers/` before exposing them in any networked context
