---
name: project-review
description: Use when the user wants a structured technical and business readiness review that results in a concise `REVIEW.md`.
metadata:
  short-description: Generate a structured project review
---

# Project Review

This is a Codex-native port of the Claude Code `project-review` workflow.

## Invocation

- `Use project-review`
- `Use project-review focus on release readiness`
- `Use project-review focus on maintainability and risk`

Treat the user arguments as optional emphasis for the review.

## Goal

Produce a review that executives can skim quickly and engineers can act on immediately.

The review should emphasize:

- architecture quality
- maintainability
- security and reliability risk
- deployment and operational readiness
- technical debt with business impact

## Workflow

1. Detect the project stack and key subsystems.
2. Read the highest-signal code, config, test, and CI files.
3. Run narrow non-mutating checks where they improve confidence.
4. Identify concrete findings across architecture, code quality, testing, dependencies, and delivery readiness.
5. Write `REVIEW.md` in a scannable format.

## `REVIEW.md` Structure

Include:

- Executive summary with go/no-go or readiness framing
- Critical issues
- Technical debt backlog
- Recommendations matrix with impact, effort, priority, and likely owner

Keep it actionable and specific. Prefer a short, high-signal report over exhaustive prose.

## Output

After writing the file, report:

- review file path
- top risks
- notable limitations in the review evidence

## Guardrails

- Focus on production readiness, not stylistic perfection.
- Use concrete repo evidence, not generic boilerplate.
- If an area was not verified, say so plainly.
