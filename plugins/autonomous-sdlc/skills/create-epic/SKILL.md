---
name: create-epic
description: Use when the user wants Codex to shape a new epic, turn it into actionable story structure, and update the repo’s story index.
metadata:
  short-description: Create epic and story scaffolding
---

# Create Epic

This is a Codex-native port of the Claude Code `create-epic` workflow.

## Invocation

- `Use create-epic 09 release automation`
- `Use create-epic 12`

Parse the user arguments as:

- Epic number: required
- Topic: optional shorthand for the epic theme

If the topic is thin, ask focused follow-up questions before generating files.

## Discovery

Gather enough information to write actionable stories, but do not over-interview.

Cover:

1. Problem or business need
2. Primary users or personas
3. Desired outcomes and success metrics
4. Core capabilities to deliver
5. Explicit non-goals
6. Important technical constraints or dependencies
7. Priority and urgency
8. Acceptance criteria expectations

Skip questions the repo already answers through existing story files or surrounding context.

## Generation

Create or update:

- `docs/stories/epic-{NN}-{kebab-name}.md` when the repo uses `docs/stories`
- otherwise the equivalent epic location already established by the repo
- `STORIES.md` or the existing story index file used by the repo

Generate:

- Epic overview
- Business value
- Success metrics
- Feature breakdown
- Well-scoped stories with INVEST-friendly boundaries
- Given/When/Then acceptance criteria
- Story points using the repo’s existing scale
- Dependencies and risk level

Match the numbering and formatting conventions already present in the repository.

## Output

After writing files, report:

- Epic name and ID
- Files created or updated
- Story count and total points
- Any assumptions made while filling gaps

## Guardrails

- Keep stories small enough to implement independently.
- Do not invent architecture decisions the user has not made unless needed to avoid a broken epic.
- Prefer the repo’s established epic/story format over the original Claude template when they differ.
