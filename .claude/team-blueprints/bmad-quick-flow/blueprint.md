---
blueprint: "1.0"
team_name: bmad-quick-{{feature_slug}}
description: "BMAD quick-flow team — rapid spec-to-ship pipeline for small features and bug fixes with tech spec, implementation, and adversarial code review"
agent_type: coordinator

members:
  - name: barry
    subagent_type: general-purpose
    model: opus
    mode: default
    max_turns: 150
    run_in_background: true
    prompt_override: |
      You are Barry, the Quick Flow Solo Dev on a BMAD quick-flow team for "{{feature_name}}". You create tech specs and implement features rapidly.

      ## BMAD Project Convention

      The BMAD config lives at `_bmad/bmm/config.yaml` in the project root. Read it for `project_name`, `user_name`, and `communication_language`.

      **Project folder:** All artifacts for this project are scoped under `_bmad-output/{{project_slug}}/`:
      - Planning: `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      - Implementation: `_bmad-output/{{project_slug}}/implementation-artifacts/`

      Create these directories if they don't exist.

      ## Your Responsibilities

      1. **Tech Spec** — Use the Skill tool to invoke `bmad:bmm:workflows:create-tech-spec`. This is a conversational spec engineering workflow — ask questions, investigate code, produce a focused technical specification. Save the spec to `_bmad-output/{{project_slug}}/project-planning-artifacts/`.

      2. **Implementation** — Use the Skill tool to invoke `bmad:bmm:workflows:quick-dev`. This is the BMAD quick-dev workflow for flexible development — execute the tech spec you just created. Follow red-green-refactor discipline:
         - RED: Write failing test first
         - GREEN: Implement minimal code to make test pass
         - REFACTOR: Clean up while keeping tests green

      ## Coordination

      - Create the tech spec first, then implement
      - After implementation is complete, notify reviewer via SendMessage with:
        - Summary of what was implemented
        - List of files changed
        - Test results
        - Path to the tech spec for review context
      - If the reviewer requests changes, address them and re-notify when done

      ## Feature Context

      - Feature slug: {{feature_slug}}
      - Feature name: {{feature_name}}
      - Feature description: {{feature_description}}

  - name: reviewer
    subagent_type: general-purpose
    model: opus
    mode: default
    max_turns: 75
    run_in_background: true
    prompt_override: |
      You are the Code Reviewer on a BMAD quick-flow team for "{{feature_name}}". You provide ADVERSARIAL code review in fresh context.

      ## BMAD Project Convention

      The BMAD config lives at `_bmad/bmm/config.yaml` in the project root. Read it for `project_name`, `user_name`, and `communication_language`.

      **Project folder:** All artifacts for this project are scoped under `_bmad-output/{{project_slug}}/`:
      - Planning: `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      - Implementation: `_bmad-output/{{project_slug}}/implementation-artifacts/`

      Create these directories if they don't exist.

      ## Your Responsibilities

      1. **Code Review** — Use the Skill tool to invoke `bmad:bmm:workflows:code-review`. Perform an adversarial senior developer code review that finds 3-10 substantive issues. Review against:
         - The tech spec (read it for requirements context)
         - OWASP Top 10 security vulnerabilities
         - Performance issues and resource leaks
         - Error handling adequacy
         - Test coverage and quality
         - Project coding conventions (from project-context.md if it exists)

      ## Review Outcomes

      - **APPROVE**: All requirements met, code quality acceptable, tests pass. Report to barry and notify the team lead.
      - **CHANGES REQUESTED**: Specific action items listed. Send to barry via SendMessage with clear remediation steps.

      ## Coordination

      - Wait for barry to notify you that implementation is complete
      - Read the tech spec first to understand what was supposed to be built
      - Read ALL changed files
      - Run the full test suite
      - If you request changes, wait for barry to re-submit, then re-review
      - After final approval, report the outcome

      ## Feature Context

      - Feature slug: {{feature_slug}}
      - Feature name: {{feature_name}}
      - Feature description: {{feature_description}}

initial_tasks:
  - subject: "Create tech spec for {{feature_name}}"
    description: |
      Create a focused technical specification for the feature using the BMAD tech spec workflow.

      1. Read `_bmad/bmm/config.yaml` to find artifact output locations
      2. Use the Skill tool to invoke `bmad:bmm:workflows:create-tech-spec`
      3. Investigate the existing codebase to understand the current state
      4. Produce a tech spec covering: scope, approach, files to modify/create, test strategy
      5. Save the tech spec to `_bmad-output/{{project_slug}}/project-planning-artifacts/`

      Feature description: {{feature_description}}
    assign_to: barry
    activeForm: "Creating tech spec"

  - subject: "Implement {{feature_name}}"
    description: |
      Implement the feature following the tech spec using the BMAD quick-dev workflow.

      1. Read the tech spec created in the previous task
      2. Use the Skill tool to invoke `bmad:bmm:workflows:quick-dev`
      3. Follow red-green-refactor: write failing tests first, implement, refactor
      4. Run the full test suite and ensure all tests pass
      5. Notify reviewer via SendMessage with:
         - Summary of changes
         - List of files changed
         - Test results
         - Path to the tech spec
    assign_to: barry
    activeForm: "Implementing feature"
    blocked_by: ["Create tech spec for {{feature_name}}"]

  - subject: "Code review {{feature_name}}"
    description: |
      Perform adversarial code review of the implementation.

      1. Read the tech spec to understand requirements
      2. Use the Skill tool to invoke `bmad:bmm:workflows:code-review`
      3. Review all changed files against the tech spec, security best practices, and project conventions
      4. Run the full test suite
      5. Determine outcome: APPROVE or CHANGES REQUESTED
      6. If APPROVE: report final outcome
      7. If CHANGES REQUESTED: send specific action items to barry, wait for fixes, re-review
      8. After final approval, shut down the team via SendMessage shutdown_request
    assign_to: reviewer
    activeForm: "Reviewing code"
    blocked_by: ["Implement {{feature_name}}"]

variables:
  - name: project_slug
    description: "URL-safe project identifier — scopes output to _bmad-output/{project_slug}/"
    required: true

  - name: feature_slug
    description: "URL-safe feature identifier (e.g., 'add-logout-button' or 'fix-auth-redirect')"
    required: true

  - name: feature_name
    description: "Human-readable feature name (e.g., 'Add Logout Button' or 'Fix Auth Redirect Bug')"
    required: true

  - name: feature_description
    description: "Brief description of the feature or bug fix — what needs to happen and why"
    required: true
---

# BMAD Quick Flow Team

A two-member team for rapid spec-to-ship development of small features and bug fixes.

## When to Use

- Small features that don't warrant full BMAD Phase 1-3 planning
- Bug fixes that need a spec and review but not epics/stories
- Isolated changes that affect a limited number of files
- Quick prototypes or proofs of concept that still need quality review

## Prerequisites

- BMAD method is already installed in the project (`_bmad/` directory exists)
- The BMAD config at `_bmad/bmm/config.yaml` is initialized
- The project has an existing codebase to work in

## Team Members

| Member | Model | Role |
|--------|-------|------|
| barry | Opus | Tech spec creation + implementation (quick-dev) |
| reviewer | Opus | Adversarial code review |

## How It Works

```
Feature Description
        |
        v
  [barry: Create Tech Spec]
        |
        v
  [barry: Implement (quick-dev)]
        |
        v
  [reviewer: Code Review]
        |
     APPROVE  or  CHANGES REQUESTED
        |              |
     Done        [barry: Fix] --> [reviewer: Re-review]
```

## BMAD Workflows Used

| Step | Workflow | Skill |
|------|----------|-------|
| Spec | Tech Spec | `bmad:bmm:workflows:create-tech-spec` |
| Build | Quick Dev | `bmad:bmm:workflows:quick-dev` |
| Review | Code Review | `bmad:bmm:workflows:code-review` |

## Customization

- **Skip spec**: For trivial bug fixes, remove the tech spec task and update `blocked_by` on the implementation task
- **Faster review**: Change reviewer model to `sonnet` for simpler changes
- **Multiple features**: Launch multiple quick-flow teams in parallel for independent features

## Project Folder Convention

Artifacts are scoped under `_bmad-output/{project_slug}/project-planning-artifacts/` to support multiple projects. The `project_slug` variable is required at launch time.

## Comparison with Full Sprint

| | Quick Flow | Parallel Sprint |
|---|---|---|
| Team size | 2 | 5 |
| Planning | Tech spec only | Full PRD + architecture |
| Scope | Single feature/fix | Multiple epics + stories |
| Isolation | Same branch | Git worktrees |
| Best for | Small changes | Large feature sets |
