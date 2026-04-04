# Security Policy

## Supported Version

The current supported repository version is `v2.1.0` on `main`.

## Reporting a Vulnerability

Please report security issues privately to the repository maintainer. Do not open a public issue for an unpatched vulnerability.

Include:

- affected file paths or framework components
- impact and likely exploitability
- reproduction steps or proof of concept
- suggested remediation, if available

## Scope

Security reports are especially relevant for:

- Claude Code hooks in `scripts/hooks/`
- bootstrap and remediation scripts
- plugin and packaging metadata
- permission profiles in `.claude/settings.json`
- framework behavior that could cause unsafe file writes, disclosure, or release bypass

## Out of Scope

The framework provides process controls and local automation. It does not by itself guarantee:

- application-level product security
- regulatory compliance certification
- secure deployment of downstream projects
- safety of custom modifications made by downstream users

## Handling Expectations

The maintainer will triage reports and decide whether to:

- patch immediately
- issue a mitigation note
- defer with documented rationale

Please avoid public disclosure until the maintainer confirms the issue is resolved or safe to disclose.
