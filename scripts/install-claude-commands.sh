#!/usr/bin/env bash
set -euo pipefail

[[ -n "${BASH_VERSION:-}" ]] || { echo "ERROR: Run with bash: bash scripts/install-claude-commands.sh"; exit 1; }

# install-claude-commands.sh
# Usage: install-claude-commands.sh [--backup] [--project [path]]
#
# Installs AK-Cognitive-OS persona, skill, and sub-persona commands into
# ~/.claude/commands/ (global) so they are available as /persona-name and
# /skill-name slash commands inside any Claude Code session.
#
# Pass --backup to save any existing commands with a timestamp suffix before
# overwriting.
#
# Pass --project [path] to install into [path]/.claude/commands/ instead
# (project-level). If --project is given without a path, installs into
# ./.claude/commands/ (current directory).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMMANDS_DIR="${HOME}/.claude/commands"

BACKUP=false
PROJECT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --backup)
      BACKUP=true
      shift
      ;;
    --project)
      PROJECT=true
      shift
      if [[ $# -gt 0 && "$1" != --* ]]; then
        COMMANDS_DIR="$1/.claude/commands"
        shift
      else
        COMMANDS_DIR="./.claude/commands"
      fi
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: install-claude-commands.sh [--backup] [--project [path]]"
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Backup existing commands if requested
# ---------------------------------------------------------------------------

if [[ "$BACKUP" == true ]]; then
  BACKUP_DIR="${HOME}/.claude/commands-backup"
  TIMESTAMP="$(date +%Y%m%dT%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  echo "Backing up existing commands to: $BACKUP_DIR"

  if compgen -G "${COMMANDS_DIR}/*.md" > /dev/null 2>&1; then
    for existing in "${COMMANDS_DIR}"/*.md; do
      base="$(basename "$existing" .md)"
      backup_path="${BACKUP_DIR}/${base}-${TIMESTAMP}.md"
      cp "$existing" "$backup_path"
      echo "  [backup] $existing --> $backup_path"
    done
  else
    echo "  [info] No existing .md files in $COMMANDS_DIR to back up."
  fi
  echo ""
fi

# ---------------------------------------------------------------------------
# Ensure destination directory exists
# ---------------------------------------------------------------------------

mkdir -p "$COMMANDS_DIR"

INSTALLED=0

# ---------------------------------------------------------------------------
# Install persona commands
# ---------------------------------------------------------------------------

PERSONAS_DIR="${FRAMEWORK_DIR}/personas"

if [[ -d "$PERSONAS_DIR" ]]; then
  echo "Installing persona commands..."
  for persona_dir in "${PERSONAS_DIR}"/*/; do
    persona_name="$(basename "$persona_dir")"

    # Skip the _template directory
    if [[ "$persona_name" == "_template" ]]; then
      continue
    fi

    src_file="${persona_dir}claude-command.md"
    dst_file="${COMMANDS_DIR}/${persona_name}.md"

    if [[ -f "$src_file" ]]; then
      cp "$src_file" "$dst_file"
      echo "  [installed] ${dst_file}"
      INSTALLED=$((INSTALLED + 1))
    else
      echo "  [warn] claude-command.md not found for persona '${persona_name}', skipping."
    fi
  done
  echo ""
else
  echo "ERROR: personas/ directory not found at: $PERSONAS_DIR"
  echo "Ensure this script is run from within the AK-Cognitive-OS repository."
  exit 1
fi

# ---------------------------------------------------------------------------
# Install skill commands
# ---------------------------------------------------------------------------

SKILLS_DIR="${FRAMEWORK_DIR}/skills"

if [[ -d "$SKILLS_DIR" ]]; then
  echo "Installing skill commands..."
  for skill_dir in "${SKILLS_DIR}"/*/; do
    skill_name="$(basename "$skill_dir")"

    # Skip the _template directory
    if [[ "$skill_name" == "_template" ]]; then
      continue
    fi

    src_file="${skill_dir}claude-command.md"
    dst_file="${COMMANDS_DIR}/${skill_name}.md"

    if [[ -f "$src_file" ]]; then
      cp "$src_file" "$dst_file"
      echo "  [installed] ${dst_file}"
      INSTALLED=$((INSTALLED + 1))
    else
      echo "  [warn] claude-command.md not found for skill '${skill_name}', skipping."
    fi
  done
  echo ""
else
  echo "ERROR: skills/ directory not found at: $SKILLS_DIR"
  echo "Ensure this script is run from within the AK-Cognitive-OS repository."
  exit 1
fi

# ---------------------------------------------------------------------------
# Install sub-persona commands
# ---------------------------------------------------------------------------

install_sub_personas() {
  local parent_name="$1"
  local sub_dir="${PERSONAS_DIR}/${parent_name}/sub-personas"

  if [[ ! -d "$sub_dir" ]]; then
    return
  fi

  echo "Installing ${parent_name} sub-persona commands..."
  for src_file in "${sub_dir}"/*.md; do
    [[ -f "$src_file" ]] || continue
    base="$(basename "$src_file" .md)"
    dst_file="${COMMANDS_DIR}/${parent_name}-${base}.md"
    cp "$src_file" "$dst_file"
    echo "  [installed] ${dst_file}"
    INSTALLED=$((INSTALLED + 1))
  done
  echo ""
}

install_sub_personas "researcher"
install_sub_personas "compliance"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo "Done. ${INSTALLED} command(s) installed to: ${COMMANDS_DIR}"
