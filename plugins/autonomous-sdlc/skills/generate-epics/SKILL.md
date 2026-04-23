---
name: generate-epics
description: Use when the user wants Codex to turn `REQUIREMENTS.md` into modular epics, user stories, and supporting story index files.
metadata:
  short-description: Generate epics and stories from requirements
---

# Generate Epics

This is a Codex-native port of the Claude Code `generate-epics` workflow.

## Invocation

- `Use generate-epics`
- `Use generate-epics docs/REQUIREMENTS.md`
- `Use generate-epics REQUIREMENTS.md`

Parse the user arguments as an optional requirements file path. If omitted, prefer `docs/REQUIREMENTS.md` and then `REQUIREMENTS.md`.

## Inputs

Before generating anything:

1. Locate and read the requirements document.
2. Inspect existing story files, if any, to match the repo’s current numbering and formatting conventions.
3. Determine the canonical story output location:
   - prefer `docs/stories/` when present or when the repo already uses it
   - otherwise follow the story structure already established in the repository

If no requirements file exists, stop and ask the user for the source document instead of inventing one.

## Generation Goals

Transform the requirements into:

- A story overview file such as `STORIES.md` or the repo’s established equivalent
- Individual epic files named `epic-XX-[name].md`
- A non-functional requirements story file when the requirements call for cross-cutting concerns

The output should:

- break work into coherent epics
- generate INVEST-friendly stories
- use `As a ... I want ... so that ...` story format
- use Given/When/Then acceptance criteria
- assign realistic story points using the repo’s existing scale
- make dependencies and MVP scope explicit

## Workflow

1. Analyze the requirements for product goals, personas, workflows, constraints, and success criteria.
2. Group work into sensible epic boundaries such as product functionality, admin/operations, integrations, infrastructure, and quality.
3. Generate or update the overview story index with:
   - epic navigation
   - persona summary if present in the requirements
   - project metrics and MVP framing where useful
4. Generate individual epic files with:
   - epic overview
   - business value
   - success metrics
   - feature breakdown
   - detailed stories
   - dependencies and risk
5. Generate non-functional requirement stories when they materially affect delivery.
6. Validate cross-references, numbering, and internal consistency.

## Output

After writing files, report:

- requirements source used
- files created or updated
- epic count
- approximate story count and total points
- notable assumptions or gaps inherited from the requirements

## Guardrails

- Match existing repo story conventions before introducing a new format.
- Do not update `CLAUDE.md` or other assistant-specific docs unless the user explicitly asks.
- Prefer actionable, implementable stories over exhaustive documentation.
- If the requirements are weak or ambiguous, call that out in the output rather than fabricating certainty.
