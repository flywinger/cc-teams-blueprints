---
blueprint: "1.0"
team_name: newsletter
description: "A three-member team that researches a topic, writes newsletter content, and produces a polished HTML newsletter"
agent_type: coordinator

members:
  - name: researcher
    subagent_type: general-purpose
    model: sonnet
    mode: default
    max_turns: 40
    run_in_background: true
    prompt_override: "You are a newsletter research specialist. Your job is to research {{topic}} for a newsletter targeting {{audience}}. Find compelling angles, key facts, recent developments, expert quotes, and interesting data points. Organize your findings into clear sections that a writer can turn into engaging newsletter content. Save your research notes to the scratchpad directory."

  - name: writer
    subagent_type: general-purpose
    model: sonnet
    mode: default
    max_turns: 40
    run_in_background: true
    prompt_override: "You are an experienced newsletter writer. Your tone should be {{tone}}. Write for an audience of {{audience}}. Craft engaging, scannable content with strong headlines, concise paragraphs, and clear takeaways. Newsletter content should feel personal and valuable — not like a dry report. Save your draft content to the scratchpad directory."

  - name: designer
    subagent_type: general-purpose
    model: sonnet
    mode: default
    max_turns: 50
    run_in_background: true
    prompt_override: "You are a web designer with extensive newsletter design experience. You specialize in creating clean, responsive HTML email newsletters that render well across all major email clients (Gmail, Outlook, Apple Mail). IMPORTANT: Use the HTML template at .claude/team-blueprints/newsletter/templates/newsletter-template.html as your base. The template contains the full design system (color scheme, typography, layout, mobile styles) with commented-out repeatable blocks for sections, stats tables, quick hits, and takeaways. Uncomment and populate the blocks you need with the written content. Do not redesign from scratch — use the template's existing styles and structure. The final output must be a single self-contained HTML file."

initial_tasks:
  - subject: "Research {{topic}}"
    description: "Research {{topic}} for a newsletter targeting {{audience}}. Find compelling angles, recent developments, key facts and statistics, expert perspectives, and interesting data points. Organize findings into 3-5 clear thematic sections that a writer can use to craft newsletter content. Save structured research notes to the scratchpad directory."
    assign_to: researcher
    activeForm: "Researching {{topic}}"

  - subject: "Write newsletter content on {{topic}}"
    description: "Using the research notes, write newsletter content on {{topic}} for {{audience}}. The tone should be {{tone}}. Structure the newsletter with: a compelling subject line, a brief intro/hook, 3-5 content sections with headlines, key takeaways or action items, and a closing. Write in a way that is scannable and engaging. Save the draft content (in markdown) to the scratchpad directory."
    assign_to: writer
    activeForm: "Writing newsletter content"
    blocked_by: ["Research {{topic}}"]

  - subject: "Design and build HTML newsletter"
    description: "Take the written newsletter content and produce a polished, responsive HTML email newsletter. IMPORTANT: Start from the HTML template at .claude/team-blueprints/newsletter/templates/newsletter-template.html. The template has the full design system with commented-out repeatable blocks (sections, stats table, quick hits, takeaways). Uncomment the blocks you need and populate them with the written content. Replace all {{PLACEHOLDER}} values. Do not redesign from scratch. Save the final HTML to ./newsletter.html in the project directory."
    assign_to: designer
    activeForm: "Building HTML newsletter"
    blocked_by: ["Write newsletter content on {{topic}}"]

  - subject: "Review and finalize newsletter"
    description: "Review the final HTML newsletter for design quality, content accuracy, responsive behavior, and email client compatibility. Fix any issues with rendering, typography, spacing, or content flow. Ensure the HTML is clean and self-contained. Save the final version to ./newsletter.html."
    assign_to: designer
    activeForm: "Reviewing and finalizing newsletter"
    blocked_by: ["Design and build HTML newsletter"]

variables:
  - name: topic
    description: "The newsletter topic (e.g. 'AI agents in software development')"
    required: true

  - name: audience
    description: "The target audience (e.g. 'startup founders', 'marketing professionals')"
    required: true

  - name: tone
    description: "The writing tone and style (e.g. 'professional but approachable', 'casual and witty')"
    required: true
    default: "professional but approachable"
---

# Newsletter Team

A three-member team that produces a polished HTML email newsletter on any topic.

## When to Use

- You need a complete, ready-to-send HTML newsletter
- The topic requires research before writing
- You want a professionally designed, email-client-compatible result

## Workflow

1. **Researcher** investigates the topic, finding compelling angles, facts, and data
2. **Writer** crafts engaging newsletter content from the research
3. **Designer** builds a responsive HTML email newsletter from the written content
4. **Designer** reviews and polishes the final output

## Output

The final newsletter is saved to `./newsletter.html` — a self-contained HTML file ready for email distribution.

## Template

The designer uses the HTML template at `.claude/team-blueprints/newsletter/templates/newsletter-template.html`. The template includes:

- Full email-client-compatible design system (colors, typography, layout, mobile styles)
- Commented-out repeatable blocks: content sections, quick hits, stats tables, key takeaways
- Placeholder syntax (`{{PLACEHOLDER}}`) for all dynamic content
- Navy/blue color scheme with Georgia serif + Arial sans-serif typography

To customize the design, edit the template directly. The designer will use it as-is.

## Customization

- Adjust `tone` to match your brand voice
- Edit the HTML template to change colors, fonts, or layout
- Change member models to `opus` for higher quality or `haiku` for speed
- Add an `editor` member between writer and designer for an extra review pass
