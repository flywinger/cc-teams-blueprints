# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Reusable, portable team configurations for Claude Code multi-agent workflows. A blueprint captures team composition (members, models, roles, tasks, dependencies, variables) in a Markdown file with YAML frontmatter. The `team-launcher` agent reads a blueprint and spins up the full team; the `team-capture` agent snapshots a running team back into a blueprint.

**Prerequisite**: Agent teams require `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (set in `~/.claude/settings.json` or as an env var).

## Commands

```bash
# List available blueprints
./install.sh --list
make list

# Install framework + blueprints into another project
./install.sh ~/my-project --blueprint=newsletter
./install.sh ~/my-project --blueprint=newsletter --blueprint=example-team
make install TARGET=~/my-project BLUEPRINT=newsletter

# Install flags
./install.sh ~/my-project --force          # Overwrite existing files
./install.sh ~/my-project --no-claude-md   # Skip CLAUDE.md setup
```

Within a Claude Code session:

### a) Launch a team from a blueprint
- **Launch a team**: `Launch the newsletter team` (invokes `team-launcher` agent)
- **List blueprints**: `/teams` slash command or `What team blueprints are available?`

### b) Create a team ad-hoc, then capture it
Build a team interactively in Claude Code using the built-in tools:

1. **Create the team** — `TeamCreate` sets up a team with a shared task list.
2. **Create tasks** — `TaskCreate` defines work items with descriptions and dependencies.
3. **Spawn members** — `Task` tool with `team_name` and `name` parameters launches agents that join the team.
4. **Assign work** — `TaskUpdate` with `owner` assigns tasks to members; `SendMessage` coordinates.
5. **Iterate** — the team works, you monitor, adjust tasks, and resolve blockers.
6. **Capture it** — when the workflow is dialed in, save it for reuse:
   `Save this team as a blueprint` (invokes `team-capture` agent)

## Architecture

```
.claude/
├── agents/
│   ├── team-launcher.md      # Orchestrator: parses blueprint → TeamCreate → spawn members → create tasks
│   └── team-capture.md       # Inspector: reads running team config/tasks → generates blueprint
├── team-blueprints/
│   └── {team-name}/
│       ├── blueprint.md      # YAML frontmatter (members, tasks, variables) + markdown docs
│       └── templates/        # Optional reusable assets (HTML, markdown, etc.)
├── commands/
│   └── teams.md              # /teams slash command
└── CLAUDE.md
```

- **Agents** define behavior (persona, tools, model). Reusable across blueprints.
- **Blueprints** define team composition. Each is a directory with a `blueprint.md` and optional `templates/`.
- Blueprints live in `.claude/team-blueprints/` (project-level) or `~/.claude/team-blueprints/` (global).
- The installer (`install.sh`) copies agents + selected blueprints + CLAUDE.md instructions into a target project. It is idempotent.

### Launcher Workflow

1. Find and parse blueprint → 2. Resolve `{{variable}}` placeholders via user prompts → 3. Collision-check team name → 4. `TeamCreate` (falls back to standalone subagents) → 5. Spawn members (falls back to `general-purpose` if custom type fails) → 6. Create tasks with `blocked_by` dependencies → 7. Status report

### Blueprint Format

```yaml
---
blueprint: "1.0"
team_name: my-team
description: "What this team does"
agent_type: coordinator

members:
  - name: member-name
    subagent_type: general-purpose    # Built-in type OR .claude/agents/ name
    model: sonnet                     # sonnet | haiku | opus
    mode: default
    max_turns: 50
    run_in_background: true
    prompt_override: ""               # Extra context injected at spawn

initial_tasks:
  - subject: "Task title"
    description: "What to do"
    assign_to: member-name
    activeForm: "Doing the thing"
    blocked_by: ["Other task"]        # References task subjects, not IDs

variables:
  - name: my_var
    description: "What it's for"
    required: true
    default: "value"                  # {{my_var}} replaced throughout blueprint
---
```

### Graceful Degradation

1. **TeamCreate fails** → standalone subagents (no coordination, work still gets done)
2. **Custom subagent_type fails** → `general-purpose` with agent definition injected as prompt
3. **YAML parsing fails** → specific error reported to user
