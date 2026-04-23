---
name: brainstorm
description: Use when the user wants interview-driven product discovery that results in a concrete `REQUIREMENTS.md` instead of vague notes.
metadata:
  short-description: Turn an idea into requirements
---

# Brainstorm

This is a Codex-native port of the Claude Code `brainstorm` workflow.

## Invocation

- `Use brainstorm internal release-monitoring dashboard for our Mac fleet`
- `Use brainstorm`

Treat the user arguments as the seed idea. If `PROJECT-SEED.md` exists, use it as bootstrap context and avoid re-asking what is already known.

## Discovery

Conduct a focused product interview. Ask only the next most useful question, not a wall of prompts.

Drive toward:

- Problem statement
- Users and personas
- Core workflows
- Constraints and assumptions
- Success metrics
- Scope boundaries
- Risks or open questions

If `PROJECT-SEED.md` exists, use it to skip objective, stack, and architecture basics and spend the questioning budget on product and workflow clarity.

Stop when the spec is actionable. Do not keep interviewing once the requirements are decision-ready.

## Output

Generate `REQUIREMENTS.md` with:

- Problem and goals
- Target users
- Functional requirements
- Non-functional requirements
- Constraints and dependencies
- Success metrics
- Risks and open questions
- Recommended next steps

Write it in a direct, implementation-friendly style rather than PRD fluff.

## Integration

If the repository already contains `CLAUDE.md`, `AGENTS.md`, or similar workflow docs, use them as context but do not rewrite them unless the user explicitly asks.

If the surrounding task includes repository setup work, this skill should hand off cleanly to `create-epic` or other planning/build workflows.

## Guardrails

- Optimize for clarity and decision quality.
- Avoid filler sections that do not change implementation.
- Do not commit or push anything unless the user explicitly asks for Git operations.
