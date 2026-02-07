# Team Blueprints Framework

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

## Directory Structure

```
.claude/
├── agents/
│   ├── team-launcher.md          # Reads blueprints → creates teams
│   └── team-capture.md           # Reads running teams → saves blueprints
├── team-blueprints/
│   ├── example-team/
│   │   └── blueprint.md          # Proof-of-concept blueprint
│   └── newsletter/
│       ├── blueprint.md          # Newsletter team blueprint
│       └── templates/
│           └── newsletter-template.html  # Reusable HTML email template
└── CLAUDE.md                     # This file
```

- **Agent definitions** (`.claude/agents/*.md`): Define WHAT each agent IS — persona, tools, model.
- **Team blueprints** (`.claude/team-blueprints/{name}/`): Each team is a directory containing:
  - `blueprint.md` (required) — the team definition with YAML frontmatter
  - `templates/` (optional) — reusable templates and assets for the team's workflow
- Agents are reusable building blocks. The same agent can appear in multiple blueprints.

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
    description: "What it's for"     # Shown when prompting user
    required: true                   # Must be provided before launch
    default: "value"                 # Default if not provided
---

# Human-readable documentation below the frontmatter
```

### Key Details

- **`subagent_type`** can be a built-in type (`general-purpose`, `Explore`, `Plan`, `Bash`) or a custom agent name from `.claude/agents/`.
- **`blocked_by`** uses task subject strings, not IDs (IDs are generated at runtime).
- **`variables`** use `{{variable_name}}` placeholder syntax throughout the blueprint.
- **`prompt_override`** adds context without changing the underlying agent definition.

---

## Lifecycle

```
1. Define agents        →  .claude/agents/*.md
2. Define blueprint     →  .claude/team-blueprints/{name}/blueprint.md
3. Launch team          →  team-launcher reads blueprint, creates team
4. Team works           →  Standard TeamCreate/Task/SendMessage workflow
5. Capture team         →  team-capture saves team as blueprint
6. Iterate              →  Edit blueprint, re-launch with improvements
7. Share globally       →  Copy blueprint to ~/.claude/team-blueprints/
```

---

## Graceful Degradation

The launcher handles failures at every level:

1. **TeamCreate fails**: Falls back to spawning agents as standalone subagents (no team coordination, but work still gets done).
2. **Custom subagent_type fails**: Falls back to `general-purpose` with the agent's definition injected as prompt context.
3. **Blueprint format is broken**: Reports specific YAML parsing errors so you can fix them.

Even if automation breaks entirely, blueprints are human-readable Markdown — you can always manually follow the blueprint to assemble a team.

---

## Creating a New Blueprint

1. Create a directory in `.claude/team-blueprints/{team-name}/`.
2. Add a `blueprint.md` file with the YAML frontmatter format above.
3. Define your members — who's on the team and what tools/model they use.
4. Define initial tasks — what work should start immediately, and in what order.
5. Add variables for anything that changes between runs (topics, file paths, etc.).
6. Optionally add a `templates/` subdirectory for reusable assets (HTML templates, markdown templates, etc.).
7. Test with: `Launch the {team-name} team`

Or capture an existing team: after running a successful ad-hoc team, use `team-capture` to save its configuration as a blueprint for next time.
