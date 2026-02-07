#!/usr/bin/env bash
set -euo pipefail

# Blueprint Installer — installs the team blueprints framework into a target project.
#
# Usage:
#   ./install.sh <target-dir> --blueprint=newsletter
#   ./install.sh <target-dir> --blueprint=newsletter --blueprint=example-team
#   ./install.sh --list
#   ./install.sh <target-dir>                  # interactive blueprint selection

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_AGENTS_DIR="$SCRIPT_DIR/.claude/agents"
SOURCE_BLUEPRINTS_DIR="$SCRIPT_DIR/.claude/team-blueprints"

# ── Defaults ──────────────────────────────────────────────────────────────────
TARGET_DIR=""
BLUEPRINTS=()
LIST_MODE=false
NO_CLAUDE_MD=false
FORCE=false

# ── Parse arguments ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            LIST_MODE=true
            shift
            ;;
        --blueprint=*)
            BLUEPRINTS+=("${1#--blueprint=}")
            shift
            ;;
        --no-claude-md)
            NO_CLAUDE_MD=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            cat <<'USAGE'
Usage: install.sh [OPTIONS] <target-dir>

Install the team blueprints framework into a target project.

Arguments:
  <target-dir>            Target project directory

Options:
  --blueprint=<name>      Install a specific blueprint (repeatable)
  --list                  List available blueprints and exit
  --no-claude-md          Skip CLAUDE.md setup
  --force                 Overwrite existing files without prompting
  -h, --help              Show this help message

Examples:
  ./install.sh --list
  ./install.sh ../my-project --blueprint=newsletter
  ./install.sh ../my-project --blueprint=newsletter --blueprint=example-team
  ./install.sh ../my-project                    # interactive selection
USAGE
            exit 0
            ;;
        -*)
            echo "Error: Unknown option '$1'" >&2
            echo "Run './install.sh --help' for usage." >&2
            exit 1
            ;;
        *)
            if [[ -z "$TARGET_DIR" ]]; then
                TARGET_DIR="$1"
            else
                echo "Error: Unexpected argument '$1' (target directory already set to '$TARGET_DIR')" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# ── List available blueprints ────────────────────────────────────────────────
list_blueprints() {
    echo "Available blueprints:"
    echo ""
    for bp_dir in "$SOURCE_BLUEPRINTS_DIR"/*/; do
        [[ -d "$bp_dir" ]] || continue
        local bp_file="$bp_dir/blueprint.md"
        [[ -f "$bp_file" ]] || continue
        local name
        name="$(basename "$bp_dir")"
        local description=""
        # Extract description from YAML frontmatter
        description="$(sed -n '/^---$/,/^---$/{ /^description:/{ s/^description: *"*//; s/"*$//; p; } }' "$bp_file")"
        printf "  %-20s %s\n" "$name" "$description"
    done
    echo ""
}

# ── List mode ────────────────────────────────────────────────────────────────
if $LIST_MODE; then
    list_blueprints
    exit 0
fi

# ── Validate target directory ────────────────────────────────────────────────
if [[ -z "$TARGET_DIR" ]]; then
    echo "Error: No target directory specified." >&2
    echo "Run './install.sh --help' for usage." >&2
    exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Target directory '$TARGET_DIR' does not exist." >&2
    exit 1
fi

# Prevent installing into self
if [[ "$TARGET_DIR" == "$SCRIPT_DIR" ]]; then
    echo "Error: Target directory is the same as the source directory." >&2
    exit 1
fi

# ── Interactive selection if no blueprints specified ─────────────────────────
if [[ ${#BLUEPRINTS[@]} -eq 0 ]]; then
    echo "No blueprints specified."
    echo ""
    list_blueprints

    # Collect available names
    available=()
    for bp_dir in "$SOURCE_BLUEPRINTS_DIR"/*/; do
        [[ -d "$bp_dir" ]] || continue
        [[ -f "$bp_dir/blueprint.md" ]] || continue
        available+=("$(basename "$bp_dir")")
    done

    if [[ ${#available[@]} -eq 0 ]]; then
        echo "No blueprints found in $SOURCE_BLUEPRINTS_DIR" >&2
        exit 1
    fi

    echo "Enter blueprint names to install (space-separated), or 'all' for everything:"
    read -r selection

    if [[ "$selection" == "all" ]]; then
        BLUEPRINTS=("${available[@]}")
    else
        read -ra BLUEPRINTS <<< "$selection"
    fi

    if [[ ${#BLUEPRINTS[@]} -eq 0 ]]; then
        echo "No blueprints selected. Exiting." >&2
        exit 1
    fi
fi

# ── Validate selected blueprints ────────────────────────────────────────────
for bp in "${BLUEPRINTS[@]}"; do
    if [[ ! -d "$SOURCE_BLUEPRINTS_DIR/$bp" ]] || [[ ! -f "$SOURCE_BLUEPRINTS_DIR/$bp/blueprint.md" ]]; then
        echo "Error: Blueprint '$bp' not found." >&2
        echo ""
        list_blueprints
        exit 1
    fi
done

# ── Helper: copy file with overwrite logic ───────────────────────────────────
copy_file() {
    local src="$1" dst="$2" label="$3"
    if [[ -f "$dst" ]] && ! $FORCE; then
        echo "  SKIP  $label (already exists, use --force to overwrite)"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  COPY  $label"
}

# ── Helper: copy directory with overwrite logic ─────────────────────────────
copy_dir() {
    local src="$1" dst="$2" label="$3"
    if [[ -d "$dst" ]] && ! $FORCE; then
        echo "  SKIP  $label (already exists, use --force to overwrite)"
        return
    fi
    mkdir -p "$dst"
    cp -r "$src"/. "$dst"/
    echo "  COPY  $label"
}

# ── Install ──────────────────────────────────────────────────────────────────
echo "Installing team blueprints framework into $TARGET_DIR"
echo ""

installed_agents=()
installed_blueprints=()

# 1. Copy framework agents
echo "Agents:"
for agent in team-launcher.md team-capture.md; do
    copy_file "$SOURCE_AGENTS_DIR/$agent" "$TARGET_DIR/.claude/agents/$agent" ".claude/agents/$agent"
    installed_agents+=("$agent")
done
echo ""

# 2. Copy selected blueprints
echo "Blueprints:"
for bp in "${BLUEPRINTS[@]}"; do
    copy_dir "$SOURCE_BLUEPRINTS_DIR/$bp" "$TARGET_DIR/.claude/team-blueprints/$bp" ".claude/team-blueprints/$bp/"
    installed_blueprints+=("$bp")
done
echo ""

# 3. Handle CLAUDE.md
if ! $NO_CLAUDE_MD; then
    echo "CLAUDE.md:"
    target_claude_md="$TARGET_DIR/.claude/CLAUDE.md"

    FRAMEWORK_SECTION='# Team Blueprints Framework

This project uses **persistent team blueprints** — reusable configurations that define multi-agent team compositions for Claude Code.

## Quick Start

### Launch a team from a blueprint
```
Launch the research-and-write team
```
This invokes the `team-launcher` agent, which reads the blueprint, prompts for variables, and spawns the full team.

### Capture a running team as a blueprint
```
Save this team as a blueprint
```
This invokes the `team-capture` agent, which inspects the running team and saves its configuration for reuse.

### List available blueprints
```
What team blueprints are available?
```
Blueprints are stored in `.claude/team-blueprints/` (project) and `~/.claude/team-blueprints/` (global).

---

## Blueprint Format Reference

Blueprints are Markdown files with YAML frontmatter:

```yaml
---
blueprint: "1.0"
team_name: my-team                    # Used as the TeamCreate name
description: "What this team does"    # Team description
agent_type: coordinator               # Team lead type

members:
  - name: member-name                 # Display name (used for task assignment)
    subagent_type: general-purpose    # Built-in type OR .claude/agents/ name
    model: sonnet                     # Model: sonnet, haiku, opus
    mode: default                     # Permission mode
    max_turns: 50                     # Max agent turns
    run_in_background: true           # Run as background agent
    prompt_override: ""               # Extra context injected at spawn

initial_tasks:
  - subject: "Task title"            # Task subject line
    description: "What to do"        # Detailed task description
    assign_to: member-name           # Owner (matches a member name)
    activeForm: "Doing the thing"    # Present-tense progress label
    blocked_by: ["Other task"]       # Dependencies (by subject string)

variables:
  - name: my_var                     # Variable name
    description: "What it'"'"'s for"     # Shown when prompting user
    required: true                   # Must be provided before launch
    default: "value"                 # Default if not provided
---
```

### Key Details

- **`subagent_type`** can be a built-in type (`general-purpose`, `Explore`, `Plan`, `Bash`) or a custom agent name from `.claude/agents/`.
- **`blocked_by`** uses task subject strings, not IDs (IDs are generated at runtime).
- **`variables`** use `{{variable_name}}` placeholder syntax throughout the blueprint.
- **`prompt_override`** adds context without changing the underlying agent definition.'

    if [[ ! -f "$target_claude_md" ]]; then
        mkdir -p "$(dirname "$target_claude_md")"
        printf '%s\n' "$FRAMEWORK_SECTION" > "$target_claude_md"
        echo "  CREATE .claude/CLAUDE.md"
    elif ! grep -q '# Team Blueprints Framework' "$target_claude_md"; then
        printf '\n\n%s\n' "$FRAMEWORK_SECTION" >> "$target_claude_md"
        echo "  APPEND .claude/CLAUDE.md (added Team Blueprints Framework section)"
    else
        echo "  SKIP   .claude/CLAUDE.md (Team Blueprints Framework section already present)"
    fi
    echo ""
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo "Done! Installed into $TARGET_DIR:"
echo "  Agents:     ${installed_agents[*]}"
echo "  Blueprints: ${installed_blueprints[*]}"
if ! $NO_CLAUDE_MD; then
    echo "  CLAUDE.md:  configured"
fi
