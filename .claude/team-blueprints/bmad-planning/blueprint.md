---
blueprint: "1.0"
team_name: bmad-planning-{{project_slug}}
description: "BMAD Phase 1-3 planning team — takes a project from idea through research, product brief, PRD, UX design, architecture, epics/stories, and implementation readiness gate"
agent_type: coordinator

members:
  - name: pm-lead
    subagent_type: general-purpose
    model: opus
    mode: default
    max_turns: 200
    run_in_background: true
    prompt_override: |
      You are the PM Lead orchestrating BMAD Phase 1-3 planning for "{{project_name}}". You own the PRD, epics/stories, and readiness gate. You coordinate all planning agents and ensure artifacts flow correctly between phases.

      ## BMAD Project Convention

      The BMAD config lives at `_bmad/bmm/config.yaml` in the project root. Read it for `project_name`, `user_name`, and `communication_language`.

      **Project folder:** All artifacts for this project are scoped under `_bmad-output/{{project_slug}}/`:
      - Planning: `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      - Implementation: `_bmad-output/{{project_slug}}/implementation-artifacts/`

      Create these directories if they don't exist.

      ## Your Responsibilities

      1. **Create PRD** — Use the Skill tool to invoke `bmad:bmm:workflows:create-prd`. This is an 11-step collaborative workflow. Use the project description and product brief (from analyst) as input. Save artifacts to `_bmad-output/{{project_slug}}/project-planning-artifacts/`.

      2. **Create Epics & Stories** — After UX and architecture are complete, use the Skill tool to invoke `bmad:bmm:workflows:create-epics-and-stories`. This transforms PRD requirements and architecture decisions into epics with prioritized stories.

      3. **Readiness Gate** — Use the Skill tool to invoke `bmad:bmm:workflows:check-implementation-readiness`. This validates that PRD, architecture, and epics/stories are complete and consistent. The gate must PASS before the project moves to Phase 4 (sprint).

      ## Coordination

      - Wait for the analyst to complete research and product brief before starting the PRD
      - After you finish the PRD, notify both ux-designer and architect so they can start in parallel
      - Wait for BOTH UX design and architecture to complete before creating epics/stories
      - After epics/stories are done, run the readiness gate
      - Report the gate outcome to the user — PASS means the project is ready for `bmad-parallel-sprint`

      ## Project Context

      - Project slug: {{project_slug}}
      - Project name: {{project_name}}
      - Project description: {{project_description}}

  - name: analyst
    subagent_type: general-purpose
    model: opus
    mode: default
    max_turns: 100
    run_in_background: true
    prompt_override: |
      You are the Research Analyst on the BMAD planning team for "{{project_name}}". You conduct research and create the product brief that feeds into the PRD.

      ## BMAD Project Convention

      The BMAD config lives at `_bmad/bmm/config.yaml` in the project root. Read it for `project_name`, `user_name`, and `communication_language`.

      **Project folder:** All artifacts for this project are scoped under `_bmad-output/{{project_slug}}/`:
      - Planning: `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      - Implementation: `_bmad-output/{{project_slug}}/implementation-artifacts/`

      Create these directories if they don't exist.

      ## Your Responsibilities

      1. **Research** — Use the Skill tool to invoke `bmad:bmm:workflows:research`. Conduct comprehensive research across multiple domains using current knowledge and web search. Cover market landscape, competitive analysis, technical feasibility, user needs, and industry trends relevant to the project.

      2. **Product Brief** — Use the Skill tool to invoke `bmad:bmm:workflows:create-product-brief`. Create a comprehensive product brief through collaborative step-by-step discovery. Use the research findings and project description as input.

      Save all artifacts to `_bmad-output/{{project_slug}}/project-planning-artifacts/`.

      ## Coordination

      - Complete research first, then create the product brief
      - When the product brief is done, notify pm-lead via SendMessage so they can begin the PRD
      - Include key findings and recommendations in your notification

      ## Project Context

      - Project slug: {{project_slug}}
      - Project name: {{project_name}}
      - Project description: {{project_description}}

  - name: ux-designer
    subagent_type: general-purpose
    model: opus
    mode: default
    max_turns: 100
    run_in_background: true
    prompt_override: |
      You are the UX Designer on the BMAD planning team for "{{project_name}}". You create the UX design specification based on the PRD.

      ## BMAD Project Convention

      The BMAD config lives at `_bmad/bmm/config.yaml` in the project root. Read it for `project_name`, `user_name`, and `communication_language`.

      **Project folder:** All artifacts for this project are scoped under `_bmad-output/{{project_slug}}/`:
      - Planning: `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      - Implementation: `_bmad-output/{{project_slug}}/implementation-artifacts/`

      Create these directories if they don't exist.

      ## Your Responsibilities

      1. **UX Design** — Use the Skill tool to invoke `bmad:bmm:workflows:create-ux-design`. This is a 14-step collaborative workflow that covers user personas, information architecture, user flows, wireframes, interaction patterns, accessibility, and design specifications. Use the PRD as your primary input.

      Save all artifacts to `_bmad-output/{{project_slug}}/project-planning-artifacts/`.

      ## Coordination

      - Wait for pm-lead to notify you that the PRD is ready before starting
      - Read the PRD thoroughly before beginning UX design
      - When UX design is complete, notify pm-lead via SendMessage
      - You work in parallel with the architect — no dependency between you

      ## Project Context

      - Project slug: {{project_slug}}
      - Project name: {{project_name}}
      - Project description: {{project_description}}

  - name: architect
    subagent_type: general-purpose
    model: opus
    mode: default
    max_turns: 100
    run_in_background: true
    prompt_override: |
      You are the Architect on the BMAD planning team for "{{project_name}}". You create the architecture decisions document based on the PRD.

      ## BMAD Project Convention

      The BMAD config lives at `_bmad/bmm/config.yaml` in the project root. Read it for `project_name`, `user_name`, and `communication_language`.

      **Project folder:** All artifacts for this project are scoped under `_bmad-output/{{project_slug}}/`:
      - Planning: `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      - Implementation: `_bmad-output/{{project_slug}}/implementation-artifacts/`

      Create these directories if they don't exist.

      ## Your Responsibilities

      1. **Architecture** — Use the Skill tool to invoke `bmad:bmm:workflows:create-architecture`. This is an 8-step collaborative workflow covering technology selection, system design, API design, data models, infrastructure, security, scalability, and deployment strategy. Use the PRD as your primary input.

      Save all artifacts to `_bmad-output/{{project_slug}}/project-planning-artifacts/`.

      ## Coordination

      - Wait for pm-lead to notify you that the PRD is ready before starting
      - Read the PRD thoroughly before beginning architecture design
      - When architecture is complete, notify pm-lead via SendMessage
      - You work in parallel with the ux-designer — no dependency between you

      ## Project Context

      - Project slug: {{project_slug}}
      - Project name: {{project_name}}
      - Project description: {{project_description}}

initial_tasks:
  - subject: "Conduct research for {{project_name}}"
    description: |
      Conduct comprehensive research for the project using the BMAD research workflow.

      1. Read `_bmad/bmm/config.yaml` to find artifact output locations
      2. Use the Skill tool to invoke `bmad:bmm:workflows:research`
      3. Cover: market landscape, competitive analysis, technical feasibility, user needs, industry trends
      4. Save research artifacts to `_bmad-output/{{project_slug}}/project-planning-artifacts/`

      Project description: {{project_description}}
    assign_to: analyst
    activeForm: "Conducting research"

  - subject: "Create product brief for {{project_name}}"
    description: |
      Create a comprehensive product brief using the BMAD product brief workflow.

      1. Read the research artifacts produced in the previous task
      2. Use the Skill tool to invoke `bmad:bmm:workflows:create-product-brief`
      3. Save the product brief to `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      4. Notify pm-lead via SendMessage when complete, summarizing key findings

      Project description: {{project_description}}
    assign_to: analyst
    activeForm: "Creating product brief"
    blocked_by: ["Conduct research for {{project_name}}"]

  - subject: "Create PRD for {{project_name}}"
    description: |
      Create a comprehensive Product Requirements Document using the BMAD PRD workflow.

      1. Read `_bmad/bmm/config.yaml` to find artifact output locations
      2. Read the product brief created by the analyst
      3. Use the Skill tool to invoke `bmad:bmm:workflows:create-prd`
      4. Save the PRD to `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      5. Notify ux-designer AND architect via SendMessage that the PRD is ready, so they can start their work in parallel

      Project description: {{project_description}}
    assign_to: pm-lead
    activeForm: "Creating PRD"
    blocked_by: ["Create product brief for {{project_name}}"]

  - subject: "Create UX design for {{project_name}}"
    description: |
      Create the UX design specification using the BMAD UX design workflow.

      1. Read `_bmad/bmm/config.yaml` to find artifact output locations
      2. Read the PRD created by pm-lead
      3. Use the Skill tool to invoke `bmad:bmm:workflows:create-ux-design`
      4. This is a 14-step workflow covering personas, IA, flows, wireframes, interaction patterns, accessibility
      5. Save UX artifacts to `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      6. Notify pm-lead via SendMessage when complete
    assign_to: ux-designer
    activeForm: "Creating UX design"
    blocked_by: ["Create PRD for {{project_name}}"]

  - subject: "Create architecture for {{project_name}}"
    description: |
      Create the architecture decisions document using the BMAD architecture workflow.

      1. Read `_bmad/bmm/config.yaml` to find artifact output locations
      2. Read the PRD created by pm-lead
      3. Use the Skill tool to invoke `bmad:bmm:workflows:create-architecture`
      4. This is an 8-step workflow covering tech selection, system design, APIs, data models, infra, security
      5. Save architecture artifacts to `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      6. Notify pm-lead via SendMessage when complete
    assign_to: architect
    activeForm: "Creating architecture"
    blocked_by: ["Create PRD for {{project_name}}"]

  - subject: "Create epics and stories for {{project_name}}"
    description: |
      Transform PRD requirements and architecture decisions into epics with prioritized stories.

      1. Read the PRD, UX design, and architecture documents
      2. Use the Skill tool to invoke `bmad:bmm:workflows:create-epics-and-stories`
      3. Save epics and stories to `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      4. Ensure stories have clear acceptance criteria, task breakdowns, and dependency notes
    assign_to: pm-lead
    activeForm: "Creating epics and stories"
    blocked_by: ["Create UX design for {{project_name}}", "Create architecture for {{project_name}}"]

  - subject: "Run implementation readiness gate for {{project_name}}"
    description: |
      Run the BMAD readiness gate to validate that all planning artifacts are complete and consistent.

      1. Use the Skill tool to invoke `bmad:bmm:workflows:check-implementation-readiness`
      2. This validates PRD, architecture, and epics/stories for completeness and consistency
      3. If the gate PASSES: report to the user that the project is ready for Phase 4 (`bmad-parallel-sprint`)
      4. If the gate FAILS: report specific issues and coordinate fixes with the appropriate team member
      5. Shut down all team members via SendMessage shutdown_request after the gate check completes
    assign_to: pm-lead
    activeForm: "Running readiness gate"
    blocked_by: ["Create epics and stories for {{project_name}}"]

variables:
  - name: project_slug
    description: "URL-safe project identifier (e.g., 'my-saas-app' or 'inventory-system')"
    required: true

  - name: project_name
    description: "Human-readable project name (e.g., 'My SaaS App' or 'Inventory Management System')"
    required: true

  - name: project_description
    description: "Brief description of the project — what it does, who it's for, and key goals"
    required: true
---

# BMAD Planning Team (Phase 1-3)

A four-member team that takes a project from idea through research, product brief, PRD, UX design, architecture, epics/stories, and implementation readiness validation.

## When to Use

- You have a new project idea and want to produce implementation-ready planning artifacts
- You want to go through the full BMAD planning lifecycle (Phases 1-3) before coding
- You need research, PRD, UX design, architecture, and epics/stories generated collaboratively
- The output feeds directly into `bmad-parallel-sprint` for Phase 4 implementation

## Prerequisites

- BMAD method is already installed in the project (`_bmad/` directory exists)
- The BMAD config at `_bmad/bmm/config.yaml` is initialized

## Team Members

| Member | Model | Role |
|--------|-------|------|
| pm-lead | Opus | PRD, epics/stories, readiness gate, orchestration |
| analyst | Opus | Research, product brief |
| ux-designer | Opus | UX design specification (14-step workflow) |
| architect | Opus | Architecture decisions document (8-step workflow) |

## How It Works

```
Project Idea + Description
        |
        v
  [analyst: Research]
        |
        v
  [analyst: Product Brief]
        |
        v
  [pm-lead: PRD (11 steps)]
        |
        +---> [ux-designer: UX Design (14 steps)]   (PARALLEL)
        |
        +---> [architect: Architecture (8 steps)]    (PARALLEL)
        |                |
        +----------------+
        |
        v
  [pm-lead: Epics & Stories]
        |
        v
  [pm-lead: Readiness Gate Check]
        |
     PASS = ready for bmad-parallel-sprint
```

## BMAD Workflows Used

| Phase | Workflow | Skill |
|-------|----------|-------|
| 1 - Analysis | Research | `bmad:bmm:workflows:research` |
| 1 - Analysis | Product Brief | `bmad:bmm:workflows:create-product-brief` |
| 2 - Planning | PRD | `bmad:bmm:workflows:create-prd` |
| 3 - Solutioning | UX Design | `bmad:bmm:workflows:create-ux-design` |
| 3 - Solutioning | Architecture | `bmad:bmm:workflows:create-architecture` |
| 3 - Solutioning | Epics & Stories | `bmad:bmm:workflows:create-epics-and-stories` |
| Gate | Readiness Check | `bmad:bmm:workflows:check-implementation-readiness` |

## Customization

- **Skip research**: If you already have research or a product brief, remove the analyst member and first two tasks, and adjust the PRD task to remove its `blocked_by`
- **Skip UX**: For backend-only projects, remove ux-designer and update the epics task to only depend on architecture
- **Add sprint planning**: After the readiness gate passes, chain into `bmad-parallel-sprint` for Phase 4

## Project Folder Convention

Each project gets its own artifact directory under `_bmad-output/{project_slug}/`:

```
_bmad-output/
└── my-project/
    ├── project-planning-artifacts/   (PRD, architecture, UX, briefs, epics)
    └── implementation-artifacts/     (sprint-status, story files)
```

This allows multiple projects to coexist without artifact conflicts.

## Output Artifacts

All artifacts are saved to `_bmad-output/{project_slug}/project-planning-artifacts/`:

- Research findings
- Product brief
- Product Requirements Document (PRD)
- UX design specification
- Architecture decisions document
- Epics with prioritized stories
- Readiness gate validation report
