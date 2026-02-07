---
blueprint: "1.0"
team_name: research-and-write
description: "A two-member team that researches a topic and produces a written report"
agent_type: coordinator

members:
  - name: researcher
    subagent_type: general-purpose
    model: haiku
    mode: default
    max_turns: 30
    run_in_background: true
    prompt_override: "Focus on finding accurate, well-sourced information. Summarize findings clearly with key facts, statistics, and notable perspectives. Save research notes to the scratchpad directory."

  - name: writer
    subagent_type: general-purpose
    model: sonnet
    mode: default
    max_turns: 40
    run_in_background: true
    prompt_override: "Write clear, well-structured content based on the research provided. Use the {{output_format}} format. Aim for thoroughness while remaining accessible to a general audience."

initial_tasks:
  - subject: "Research {{topic}}"
    description: "Conduct thorough research on {{topic}}. Gather key facts, statistics, notable perspectives, and relevant context. Save structured research notes that the writer can reference. Focus on accuracy and breadth of coverage."
    assign_to: researcher
    activeForm: "Researching {{topic}}"

  - subject: "Write report on {{topic}}"
    description: "Using the research notes, write a comprehensive report on {{topic}} in {{output_format}} format. The report should include an introduction, key findings organized by theme, analysis, and a conclusion. Ensure all claims are supported by the research."
    assign_to: writer
    activeForm: "Writing report on {{topic}}"
    blocked_by: ["Research {{topic}}"]

  - subject: "Review and finalize report"
    description: "Review the completed report for accuracy, completeness, and clarity. Cross-reference against the original research notes. Fix any errors, fill gaps, and polish the final output. Save the final report to the project directory."
    assign_to: writer
    activeForm: "Reviewing and finalizing report"
    blocked_by: ["Write report on {{topic}}"]

variables:
  - name: topic
    description: "The topic to research and write about"
    required: true

  - name: output_format
    description: "Output format for the report"
    required: false
    default: "markdown"
---

# Research & Write Team

A simple two-member team for researching a topic and producing a written report.

## When to Use

- You need a structured report on a topic
- The topic requires research before writing (not just opinion/creative writing)
- You want research and writing handled as separate, sequential phases

## Workflow

1. **Researcher** gathers information on the specified topic, saving structured notes
2. **Writer** synthesizes the research into a cohesive report in the requested format
3. **Writer** reviews and polishes the final output

## Customization

- Change `output_format` to `pdf`, `html`, or any other format the writer agent can produce
- Adjust `max_turns` if the topic requires more or less depth
- Add a third member (e.g., `editor`) for an additional review pass

## History

- **2025-01-01**: Initial blueprint created as proof-of-concept for the team blueprints framework.
