#!/usr/bin/env bash
set -euo pipefail

# cli.sh — Entry point for `npx ak-cognitive-os` and `npx ak-cogos`
#
# Usage:
#   npx ak-cognitive-os init [path]              Bootstrap a new project
#   npx ak-cognitive-os remediate [path]          Upgrade an active project
#   npx ak-cognitive-os validate                  Validate framework integrity
#   npx ak-cognitive-os install-commands          Install commands globally
#   npx ak-cognitive-os help                      Show this help

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

VERSION="$(cat "${FRAMEWORK_DIR}/.ak-cogos-version" 2>/dev/null || echo "2.1.0")"

usage() {
  cat <<EOF
AK Cognitive OS v${VERSION}
Multi-persona AI development framework for Claude Code

Usage:
  ak-cognitive-os <command> [options]

Commands:
  init [path]             Bootstrap a new project at [path] (default: current dir)
                          Options: --force, --non-interactive

  remediate [path]        Upgrade an active project with Claude Code native integration
                          Options: --dry-run, --force

  validate                Validate framework integrity (run from framework repo)

  install-commands        Install all commands to ~/.claude/commands/ (global)
                          Options: --backup

  help                    Show this help message

Examples:
  npx ak-cognitive-os init ./my-new-project
  npx ak-cognitive-os remediate ./my-existing-project --dry-run
  npx ak-cognitive-os remediate ./my-existing-project
  npx ak-cognitive-os validate

What each command does:
  init        Creates: .claude/settings.json, .claude/commands/ (all 42 commands),
              .claudeignore, memory/MEMORY.md, scripts/hooks/ (enforcement),
              tasks/, docs/, framework/, ANTI-SYCOPHANCY.md, channel.md

  remediate   Adds missing Claude Code integration to projects that already have
              the framework. Safe to run multiple times. Use --dry-run first.
              Detects mid-build state and provides recovery guidance.

EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

COMMAND="$1"
shift

case "$COMMAND" in
  init)
    TARGET="${1:-.}"
    shift || true
    if [[ ! -d "$TARGET" ]]; then
      mkdir -p "$TARGET"
    fi
    bash "${SCRIPT_DIR}/bootstrap-project.sh" "$TARGET" "$@"
    ;;
  remediate)
    TARGET="${1:-.}"
    shift || true
    bash "${SCRIPT_DIR}/remediate-project.sh" "$TARGET" "$@"
    ;;
  validate)
    bash "${SCRIPT_DIR}/validate-framework.sh" "$@"
    ;;
  install-commands)
    bash "${SCRIPT_DIR}/install-claude-commands.sh" "$@"
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo "ERROR: Unknown command: $COMMAND"
    echo ""
    usage
    exit 1
    ;;
esac
