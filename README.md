# Claude Code Agent Teams Blueprints

*By [Chris Lannon](https://github.com/flywinger)*

Reusable, portable team configurations for [Claude Code](https://claude.ai/code) multi-agent workflows.

## The Problem

Claude Code's agent teams are powerful — you can spin up multiple Claude instances that coordinate through shared task lists and message passing. But when the session ends, **the team is gone**. The configuration, the roles you defined, the task structure, the prompts you refined — all of it evaporates. Next time you want the same team, you start from scratch: re-describe each role, re-explain the workflow, re-specify the dependencies. And if you want that same team in a different project? You're doing it all over again.

## The Solution

Team Blueprints let you **save a team configuration once and launch it anywhere, any time**. A blueprint captures everything — members, models, roles, tasks, dependencies, and parameterized variables — in a portable Markdown file. Launch a three-person newsletter team with one command. Capture a team that worked well and reuse it next week. Install blueprints into other projects with a single script.

```
> Launch the newsletter team

Topic? "AI agents in software development"
Audience? "startup founders"

Spawning researcher... done
Spawning writer... done
Spawning designer... done
3 tasks created, team is running.
```

---

## What's In the Box

- **Blueprints** — team composition, roles, tasks, and variables defined in portable Markdown with YAML frontmatter
- **`team-launcher`** agent — reads a blueprint and spins up the full team automatically
- **`team-capture`** agent — snapshots a running team back into a blueprint for reuse
- **`/teams`** slash command — lists all available blueprints with members, variables, and location
- **`install.sh`** — installs the framework + selected blueprints into any project

Define it once, launch it repeatedly — with different inputs, in different projects.

---

## Prerequisites

### 1. Claude Code CLI

Install Claude Code:

```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash

# Windows PowerShell
irm https://claude.ai/install.ps1 | iex

# Homebrew
brew install --cask claude-code
```

Then authenticate:

```bash
claude
# Follow the OAuth prompt to log in with your Claude account
```

You need an active billing plan: **Claude Pro**, **Max**, **Teams**, or **Enterprise**. Any plan that supports Claude Code works.

### 2. Enable Agent Teams

Agent teams are an **experimental feature** and disabled by default. You must opt in.

**Option A — Settings file** (recommended, persistent):

Create or edit `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**Option B — Environment variable** (per-session):

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

### 3. System Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | macOS 13+, Ubuntu 20.04+, Debian 10+, Windows 10 1809+ (WSL 2 recommended) |
| **RAM** | 4 GB+ (each teammate uses its own context window) |
| **tmux** (optional) | For split-pane display mode. Install via `brew install tmux` or your package manager. Without it, teammates run in-process in your main terminal. |

---

## Getting Started

### Quick Start — Use in This Project

Clone the repo and start Claude Code:

```bash
git clone https://github.com/flywinger/cc-teams-blueprints.git
cd cc-teams-blueprints
claude
```

Then tell Claude:

```
/teams
```

This lists all available blueprints with their members, variables, and location. To launch one:

```
Launch the newsletter team
```

Claude will invoke the `team-launcher` agent, prompt you for variables (topic, audience, tone), and spawn the full team.

### Install Into Another Project

Use the installer to copy the framework and selected blueprints into any project:

```bash
# See what's available
./install.sh --list

# Install a specific blueprint
./install.sh ~/my-project --blueprint=newsletter

# Install multiple blueprints
./install.sh ~/my-project --blueprint=newsletter --blueprint=example-team

# Or use make
make install TARGET=~/my-project BLUEPRINT=newsletter
```

This copies:
- **Agent definitions** (`team-launcher.md`, `team-capture.md`) into `<target>/.claude/agents/`
- **Blueprint directories** (including templates) into `<target>/.claude/team-blueprints/`
- **CLAUDE.md instructions** so Claude Code knows how to use the framework

Then `cd` into your project, start `claude`, and launch teams from there.

### Installer Options

```
./install.sh [OPTIONS] <target-dir>

Options:
  --blueprint=<name>      Blueprint to install (repeatable)
  --list                  List available blueprints and exit
  --no-claude-md          Skip CLAUDE.md setup
  --force                 Overwrite existing files without prompting
  -h, --help              Show help
```

The installer is idempotent — running it again skips files that already exist (unless you pass `--force`).

---

## Included Blueprints

### `newsletter`

A three-member team that produces a polished HTML email newsletter.

| Member | Model | Role |
|--------|-------|------|
| `researcher` | Sonnet | Finds compelling angles, facts, and data on the topic |
| `writer` | Sonnet | Crafts engaging, scannable newsletter content |
| `designer` | Sonnet | Builds a responsive HTML email from an included template |

**Variables**: `topic` (required), `audience` (required), `tone` (default: "professional but approachable")

**Output**: `./newsletter.html` — a self-contained HTML file ready for email distribution.

Includes an HTML email template (`templates/newsletter-template.html`) with a full design system, mobile-responsive styles, and email-client-compatible markup.

### `example-team`

A two-member research-and-write team (proof of concept).

| Member | Model | Role |
|--------|-------|------|
| `researcher` | Haiku | Gathers information and saves structured notes |
| `writer` | Sonnet | Synthesizes research into a cohesive report |

**Variables**: `topic` (required), `output_format` (default: "markdown")

---

## How It Works

### Architecture

```
.claude/
├── agents/
│   ├── team-launcher.md      # Reads blueprints, creates teams
│   └── team-capture.md       # Captures running teams as blueprints
├── commands/
│   └── teams.md              # /teams slash command — lists available blueprints
└── team-blueprints/
    ├── newsletter/
    │   ├── blueprint.md       # Team definition (YAML frontmatter + docs)
    │   └── templates/         # Reusable assets for the team
    └── example-team/
        └── blueprint.md
```

- **Agents** (`.claude/agents/`) define _what an agent is_ — its persona, tools, and behavior. These are reusable across blueprints.
- **Blueprints** (`.claude/team-blueprints/`) define _what a team is_ — members, tasks, dependencies, and variables. Each blueprint is a directory containing a `blueprint.md` and optional assets.

### Lifecycle

1. **Launch** — Tell Claude to launch a blueprint. The `team-launcher` agent parses the blueprint, prompts for variables, creates the team, spawns members, and assigns initial tasks.
2. **Work** — Teammates work through their task list. Tasks can have dependencies (`blocked_by`), so work flows in the right order. Teammates coordinate via messages and the shared task list.
3. **Capture** (optional) — After a successful run, the `team-capture` agent can snapshot the team's configuration back into a blueprint, including debrief notes from teammates.
4. **Iterate** — Edit the blueprint, adjust variables, and relaunch.

### Graceful Degradation

The launcher handles failures at every level:

1. **TeamCreate fails** — Falls back to spawning agents as standalone subagents (no coordination, but work still gets done).
2. **Custom agent type fails** — Falls back to `general-purpose` with the agent definition injected as prompt context.
3. **Blueprint YAML is broken** — Reports specific parsing errors so you can fix them.

Even if all automation fails, blueprints are human-readable Markdown. You can always follow one manually.

---

## Blueprint Format

Blueprints are Markdown files with YAML frontmatter:

```yaml
---
blueprint: "1.0"
team_name: my-team
description: "What this team does"
agent_type: coordinator

members:
  - name: researcher
    subagent_type: general-purpose    # Built-in type or .claude/agents/ name
    model: sonnet                     # sonnet, haiku, or opus
    mode: default                     # Permission mode
    max_turns: 40                     # Max agent turns
    run_in_background: true
    prompt_override: "Extra context for this member"

initial_tasks:
  - subject: "Research {{topic}}"
    description: "Detailed instructions..."
    assign_to: researcher
    activeForm: "Researching {{topic}}"
  - subject: "Write report on {{topic}}"
    description: "Detailed instructions..."
    assign_to: writer
    activeForm: "Writing report"
    blocked_by: ["Research {{topic}}"]     # Waits for research to finish

variables:
  - name: topic
    description: "The topic to research"
    required: true
  - name: output_format
    description: "Output format"
    required: false
    default: "markdown"
---

# Documentation below the frontmatter
Explain when to use this team, what it produces, how to customize it, etc.
```

### Key Details

- **`subagent_type`** can be a built-in type (`general-purpose`, `Explore`, `Plan`, `Bash`) or a custom agent defined in `.claude/agents/`.
- **`blocked_by`** uses task subject strings (not IDs) to define dependencies between tasks.
- **`variables`** use `{{variable_name}}` placeholder syntax. They're replaced throughout the blueprint at launch time.
- **`prompt_override`** injects extra context into a member without changing its underlying agent definition.
- **Templates** go in a `templates/` subdirectory alongside `blueprint.md`. Members reference them by relative path.

---

## Creating Your Own Blueprint

1. Create a directory: `.claude/team-blueprints/my-team/`
2. Add `blueprint.md` with the YAML frontmatter format above
3. Define members — who's on the team, what model they use, and their role via `prompt_override`
4. Define initial tasks — what work starts immediately, in what order (use `blocked_by` for sequencing)
5. Add variables for anything that changes between runs
6. Optionally add `templates/` for reusable assets
7. Test: tell Claude to `Launch the my-team team`

Or capture an existing team: after running a successful ad-hoc team, tell Claude to `Save this team as a blueprint` and the `team-capture` agent will generate the blueprint for you.

---

## Makefile Targets

```bash
make help                          # Show available targets
make list                          # List available blueprints
make install TARGET=../my-project BLUEPRINT=newsletter
make install TARGET=../my-project BLUEPRINT="newsletter example-team"
make install TARGET=../my-project BLUEPRINT=newsletter FORCE=1
make install TARGET=../my-project BLUEPRINT=newsletter NO_CLAUDE_MD=1
```

---

## Limitations

These are current limitations of Claude Code agent teams (not this project specifically):

- **One team per session** — you can't run multiple teams simultaneously in one Claude Code session
- **No nested teams** — teammates can't spawn their own sub-teams
- **No session resumption** for in-process teammates (split-pane mode with tmux works)
- **Higher token usage** — each teammate uses its own context window, so costs scale with team size
- **Experimental feature** — agent teams are still experimental and behavior may change

---

## Author

**Chris Lannon** — [GitHub](https://github.com/flywinger)

---

## License

MIT — see [LICENSE](LICENSE) for details.
