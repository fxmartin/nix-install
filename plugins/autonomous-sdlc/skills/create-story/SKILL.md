---
name: create-story
description: Use when the user wants Codex to add one or more new stories to an existing epic from an epic number and story description, including cases where either parameter is missing and Codex must ask for it. The workflow confirms the target epic by reading the requested epic and checking all epics, clarifies requirements, then updates the epic story file and story index using the repo's established story format.
---

# Create Story

This is a Codex-native companion to the `create-epic` workflow for adding stories to an existing epic.

## Invocation

Examples:

- `Use create-story 12 add crash recovery for mission queue`
- `Use create-story EPIC-18 skill health check dashboard`
- `Use create-story add OAuth expiry alerts`

Parse the user arguments as:

- Epic number: required.
- Story description: required.

If either parameter is missing, ask for the missing value before editing files. If both are missing, ask for both in one concise message.

## Discovery

Before asking detailed product questions or writing files:

1. Read `STORIES.md` or the repo's equivalent story index.
2. List all existing epic files in the story directory.
3. Read the requested epic file.
4. Check neighboring or similarly named epics to confirm the new story belongs in the requested epic.
5. If the requested epic looks wrong, explain the likely better target and ask for confirmation before proceeding.

Use repository evidence over the user's shorthand. Completed epics can still receive follow-up stories, but explicitly confirm that the user intends to reopen or extend a completed epic.

## Clarifying Questions

Ask enough questions to make the story implementation-ready, but do not over-interview. Skip any question already answered by the epic, existing stories, or the user's description.

Cover:

1. User or operator goal
2. Business value or operational outcome
3. Scope boundaries and explicit non-goals
4. Expected behavior and important edge cases
5. Data, API, UI, security, or runtime constraints
6. Dependencies on other epics, shipped systems, or external services
7. Acceptance criteria expectations
8. Priority, MVP status, story points, and risk

If the description naturally splits into multiple independently deliverable outcomes, say so and propose the story split. Ask for confirmation unless the user already requested multiple stories.

## Generation

Create or update the requested epic file. Match the repository's existing conventions exactly:

- Epic filename pattern, usually `docs/stories/epic-{NN}-{kebab-name}.md`
- Feature table structure
- Story ID scheme, usually `{epic}.{feature}-NNN`
- Story heading format
- User story wording
- Priority, story points, dependencies, and risk fields
- Given/When/Then acceptance criteria
- Technical notes and Definition of Done checklist style

When adding stories:

1. Place each story under the most relevant existing feature when possible.
2. Create a new feature section only when the story does not fit an existing feature.
3. Choose the next story number without renumbering existing stories.
4. Keep stories INVEST-friendly and independently implementable.
5. Add acceptance criteria that are testable and specific.
6. Include security, privacy, or operational constraints when relevant to the epic.
7. Update epic totals, feature tables, story counts, point totals, MVP counts, status, or summary text only when the new story changes them.
8. Update `STORIES.md` or the repo's equivalent index when story count, point total, status, priority, or summary changes.

Prefer one well-scoped story over a bundle. Split into multiple stories when one request spans distinct user workflows, risky implementation layers, or separate verification surfaces.

## Output

After writing files, report:

- Target epic and why it was confirmed as the right one
- Story IDs and titles created
- Files updated
- Story count and point total changes
- Assumptions made
- Verification performed, or why verification was not applicable

## Guardrails

- Do not add implementation code; this skill only updates story planning artifacts.
- Do not invent major architecture decisions while writing stories. Capture uncertain decisions as open questions or technical notes.
- Do not renumber existing stories.
- Do not edit production data or deployment configuration.
- Keep unrelated roadmap cleanup out of the diff; mention drift separately if found.
