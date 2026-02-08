# /teams — List Available Team Blueprints

Search for all team blueprints in both project-level and global locations, then display a summary of each one.

## Instructions

1. Use `Glob` to find blueprints in both locations:
   - `.claude/team-blueprints/*/blueprint.md` (project-level)
   - `~/.claude/team-blueprints/*/blueprint.md` (global/shared)
   - Also check for legacy flat files: `.claude/team-blueprints/*.md` and `~/.claude/team-blueprints/*.md`

2. For each blueprint found, `Read` the file and extract the YAML frontmatter (between the `---` delimiters). Parse these fields:
   - `team_name`
   - `description`
   - `members[]` — extract each member's `name`, `subagent_type`, and `model`
   - `variables[]` — extract each variable's `name`, `required`, and `default`

3. Display the results in this format:

```
## Team Blueprints

### {team_name}
{description}

**Members**: {member1} ({model}), {member2} ({model}), ...
**Variables**: {var1} (required), {var2} (default: "{default_value}"), ...
**Location**: project | global

---
```

4. After listing all blueprints, show a usage hint:
```
Launch a team: "Launch the {team-name} team"
```

5. If no blueprints are found in either location, display:
```
No team blueprints found.

Create one in .claude/team-blueprints/{team-name}/blueprint.md
or see CLAUDE.md for the blueprint format reference.
```
