---
blueprint: "1.0"
team_name: bmad-test-{{project_slug}}
description: "BMAD test infrastructure team — sets up test framework, CI/CD pipeline, generates ATDD tests, expands automation coverage, and validates quality gates"
agent_type: coordinator

members:
  - name: tea-lead
    subagent_type: general-purpose
    model: opus
    mode: default
    max_turns: 150
    run_in_background: true
    prompt_override: |
      You are the TEA Lead (Test Engineering & Architecture) on the BMAD test infrastructure team for "{{project_name}}". You set up the test framework, scaffold CI/CD, design system-level tests, assess NFRs, and validate quality gates.

      ## BMAD Project Convention

      The BMAD config lives at `_bmad/bmm/config.yaml` in the project root. Read it for `project_name`, `user_name`, and `communication_language`.

      **Project folder:** All artifacts for this project are scoped under `_bmad-output/{{project_slug}}/`:
      - Planning: `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      - Implementation: `_bmad-output/{{project_slug}}/implementation-artifacts/`

      Create these directories if they don't exist.

      ## Your Responsibilities

      1. **Test Framework** — Use the Skill tool to invoke `bmad:bmm:workflows:testarch-framework`. Initialize a production-ready test framework architecture (Playwright, Vitest, Jest, etc.) based on the project's tech stack and architecture.

      2. **CI/CD Pipeline** — Use the Skill tool to invoke `bmad:bmm:workflows:testarch-ci`. Scaffold a CI/CD quality pipeline with test execution, burn-in loops, and quality gates.

      3. **System Test Design** — Use the Skill tool to invoke `bmad:bmm:workflows:testarch-test-design`. Create a system-level testability review covering integration points, error scenarios, and test boundaries.

      4. **NFR Assessment** — Use the Skill tool to invoke `bmad:bmm:workflows:testarch-nfr`. Assess non-functional requirements (performance, security, reliability, scalability) and define measurable quality criteria.

      5. **Test Review** — Use the Skill tool to invoke `bmad:bmm:workflows:testarch-test-review`. Review overall test quality using comprehensive knowledge base and best practices.

      6. **Traceability** — Use the Skill tool to invoke `bmad:bmm:workflows:testarch-trace`. Generate a requirements-to-tests traceability matrix and analyze coverage.

      ## Coordination

      - Complete framework setup first — test-automator needs it for ATDD and automation
      - After CI/CD and system test design are done, notify test-automator to begin ATDD generation
      - After test-automator finishes automation expansion, run NFR assessment, test review, and traceability
      - Report the final quality gate status

      ## Project Context

      - Project slug: {{project_slug}}
      - Project name: {{project_name}}

  - name: test-automator
    subagent_type: general-purpose
    model: opus
    mode: default
    max_turns: 100
    run_in_background: true
    prompt_override: |
      You are the Test Automator on the BMAD test infrastructure team for "{{project_name}}". You generate ATDD acceptance tests and expand test automation coverage.

      ## BMAD Project Convention

      The BMAD config lives at `_bmad/bmm/config.yaml` in the project root. Read it for `project_name`, `user_name`, and `communication_language`.

      **Project folder:** All artifacts for this project are scoped under `_bmad-output/{{project_slug}}/`:
      - Planning: `_bmad-output/{{project_slug}}/project-planning-artifacts/`
      - Implementation: `_bmad-output/{{project_slug}}/implementation-artifacts/`

      Create these directories if they don't exist.

      ## Your Responsibilities

      1. **ATDD Acceptance Tests** — Use the Skill tool to invoke `bmad:bmm:workflows:testarch-atdd`. Generate failing acceptance tests before implementation using TDD red-green methodology. These tests define the acceptance criteria in executable form.

      2. **Test Automation Expansion** — Use the Skill tool to invoke `bmad:bmm:workflows:testarch-automate`. Expand test automation coverage after the ATDD tests are in place. Analyze existing coverage gaps and generate additional automated tests.

      ## Coordination

      - Wait for tea-lead to complete framework setup and system test design before starting
      - Read the test framework configuration and system test design to understand the testing approach
      - Read the PRD, architecture, and epics/stories for acceptance criteria context
      - After ATDD generation, proceed to automation expansion
      - Notify tea-lead via SendMessage when automation is complete, so they can run NFR and quality gate

      ## Project Context

      - Project slug: {{project_slug}}
      - Project name: {{project_name}}

initial_tasks:
  - subject: "Initialize test framework for {{project_name}}"
    description: |
      Set up the test framework architecture for the project.

      1. Read `_bmad/bmm/config.yaml` to find artifact output locations
      2. Read the architecture document to understand the tech stack
      3. Use the Skill tool to invoke `bmad:bmm:workflows:testarch-framework`
      4. Initialize a production-ready test framework matching the project's technology choices
      5. Ensure the framework supports unit, integration, and end-to-end testing
    assign_to: tea-lead
    activeForm: "Initializing test framework"

  - subject: "Scaffold CI/CD pipeline for {{project_name}}"
    description: |
      Create the CI/CD quality pipeline with test execution and quality gates.

      1. Use the Skill tool to invoke `bmad:bmm:workflows:testarch-ci`
      2. Scaffold pipeline configuration for the project's platform (GitHub Actions, GitLab CI, etc.)
      3. Include test execution stages, burn-in loops, and quality gate checks
      4. Ensure the pipeline integrates with the test framework set up in the previous task
    assign_to: tea-lead
    activeForm: "Scaffolding CI/CD pipeline"
    blocked_by: ["Initialize test framework for {{project_name}}"]

  - subject: "Create system-level test design for {{project_name}}"
    description: |
      Design the system-level testing strategy covering integration points and test boundaries.

      1. Read the PRD and architecture documents
      2. Use the Skill tool to invoke `bmad:bmm:workflows:testarch-test-design`
      3. Identify integration points, error scenarios, and test boundaries
      4. Document the system test design
      5. Notify test-automator via SendMessage that they can begin ATDD generation
    assign_to: tea-lead
    activeForm: "Designing system tests"
    blocked_by: ["Scaffold CI/CD pipeline for {{project_name}}"]

  - subject: "Generate ATDD acceptance tests for {{project_name}}"
    description: |
      Generate failing acceptance tests from the project's requirements using ATDD methodology.

      1. Read the PRD, architecture, and epics/stories for acceptance criteria
      2. Read the test framework configuration and system test design from tea-lead
      3. Use the Skill tool to invoke `bmad:bmm:workflows:testarch-atdd`
      4. Generate executable acceptance tests that define done criteria for each story/epic
      5. Tests should be failing (red) — they define what needs to be built
    assign_to: test-automator
    activeForm: "Generating ATDD tests"
    blocked_by: ["Initialize test framework for {{project_name}}", "Create system-level test design for {{project_name}}"]

  - subject: "Expand test automation coverage for {{project_name}}"
    description: |
      Expand automated test coverage beyond ATDD acceptance tests.

      1. Analyze existing test coverage gaps
      2. Use the Skill tool to invoke `bmad:bmm:workflows:testarch-automate`
      3. Generate additional automated tests for edge cases, error paths, and integration scenarios
      4. Ensure tests follow the framework conventions established by tea-lead
      5. Notify tea-lead via SendMessage when complete
    assign_to: test-automator
    activeForm: "Expanding test automation"
    blocked_by: ["Generate ATDD acceptance tests for {{project_name}}"]

  - subject: "Assess NFRs and run quality gate for {{project_name}}"
    description: |
      Run final quality validation including NFR assessment, test review, and traceability analysis.

      1. Use the Skill tool to invoke `bmad:bmm:workflows:testarch-nfr` — assess non-functional requirements
      2. Use the Skill tool to invoke `bmad:bmm:workflows:testarch-test-review` — review overall test quality
      3. Use the Skill tool to invoke `bmad:bmm:workflows:testarch-trace` — generate traceability matrix
      4. Compile a quality gate report summarizing:
         - Test framework status
         - CI/CD pipeline status
         - ATDD coverage
         - Automation coverage
         - NFR compliance
         - Traceability gaps
      5. Report the quality gate outcome (PASS/FAIL with details)
      6. Shut down the team via SendMessage shutdown_request
    assign_to: tea-lead
    activeForm: "Running quality gate"
    blocked_by: ["Expand test automation coverage for {{project_name}}"]

variables:
  - name: project_slug
    description: "URL-safe project identifier (e.g., 'my-saas-app' or 'inventory-system')"
    required: true

  - name: project_name
    description: "Human-readable project name (e.g., 'My SaaS App' or 'Inventory Management System')"
    required: true
---

# BMAD Test Infrastructure Team

A two-member team focused on test engineering and architecture — sets up the test framework, CI/CD pipeline, generates ATDD acceptance tests, expands automation coverage, and validates quality gates.

## When to Use

- Before or alongside a sprint, to establish the test infrastructure
- After Phase 3 planning is complete, to create acceptance tests from requirements
- When you want to ensure quality gates are in place before development begins
- To audit and expand test coverage on an existing project

## Prerequisites

- BMAD method is already installed in the project (`_bmad/` directory exists)
- The BMAD config at `_bmad/bmm/config.yaml` is initialized
- Planning artifacts exist (PRD, architecture, epics/stories) — typically output of `bmad-planning`

## Team Members

| Member | Model | Role |
|--------|-------|------|
| tea-lead | Opus | Framework setup, CI/CD, system test design, NFR, quality gate |
| test-automator | Opus | ATDD test generation, automation expansion |

## How It Works

```
Architecture + PRD + Epics
        |
        v
  [tea-lead: Initialize Test Framework]
        |
        v
  [tea-lead: Scaffold CI/CD Pipeline]
        |
        v
  [tea-lead: System-Level Test Design]
        |
        +---> [test-automator: Generate ATDD Acceptance Tests]
                        |
                        v
              [test-automator: Expand Test Automation]
                        |
                        v
  [tea-lead: NFR Assessment + Test Review + Traceability]
        |
     Quality Gate: PASS / FAIL
```

## BMAD Workflows Used

| Step | Workflow | Skill |
|------|----------|-------|
| Framework | Test Framework | `bmad:bmm:workflows:testarch-framework` |
| CI/CD | CI Pipeline | `bmad:bmm:workflows:testarch-ci` |
| Design | Test Design | `bmad:bmm:workflows:testarch-test-design` |
| ATDD | Acceptance Tests | `bmad:bmm:workflows:testarch-atdd` |
| Automate | Test Automation | `bmad:bmm:workflows:testarch-automate` |
| NFR | NFR Assessment | `bmad:bmm:workflows:testarch-nfr` |
| Review | Test Review | `bmad:bmm:workflows:testarch-test-review` |
| Trace | Traceability | `bmad:bmm:workflows:testarch-trace` |

## Timing with Other Teams

```
[bmad-planning]  -->  [bmad-test-infra]  -->  [bmad-parallel-sprint]
   Phase 1-3          Test setup              Phase 4 dev
                      ATDD tests              (tests already exist!)
```

Running `bmad-test-infra` after planning but before the sprint means:
- Acceptance tests are written BEFORE implementation (true ATDD)
- CI/CD pipeline is ready before the first story is developed
- Quality gates catch issues early in the sprint

## Project Folder Convention

All artifacts are scoped under `_bmad-output/{project_slug}/`. Planning artifacts (PRD, architecture, epics) are read from `project-planning-artifacts/` and test/implementation artifacts go in `implementation-artifacts/`. This allows multiple projects to coexist.

## Customization

- **Skip CI/CD**: Remove the CI/CD task if your project already has a pipeline
- **Existing framework**: If tests are already set up, adjust the framework task to audit rather than create
- **Run during sprint**: Launch alongside `bmad-parallel-sprint` instead of before it
- **Brownfield projects**: Use on existing codebases to audit and expand test coverage
