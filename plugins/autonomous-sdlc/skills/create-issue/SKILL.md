---
name: create-issue
description: Use when the user wants Codex to investigate a defect report, check for duplicates, and create a high-signal GitHub issue with `gh`.
metadata:
  short-description: Investigate and file GitHub issues
---

# Create Issue

This is a Codex-native port of the Claude Code `create-issue` workflow.

## Invocation

- `Use create-issue login page returns 500 after submitting valid credentials`
- `Use create-issue mobile layout overlaps on the settings page in Safari`

Treat the user arguments as the defect description to investigate.

## GitHub CLI Execution

All GitHub CLI commands in this workflow must run through Batch or another
non-sandboxed execution path that preserves the user's authenticated `gh`
session.

Rules:

- Do not run `gh` commands through the default sandboxed shell path if that
  path is unauthenticated in this environment.
- Run `gh auth status`, `gh issue list`, and `gh issue create` through Batch.
- If Batch or the authenticated non-sandbox path is unavailable, stop and
  report that GitHub operations cannot be completed safely from this session.

## Preflight

Before creating anything:

1. Run `gh auth status` through Batch and stop with a clear error if GitHub CLI is unavailable or unauthenticated.
2. Confirm the current branch with `git branch --show-current`.
3. Read enough repo context to understand the project shape:
   - `package.json`, `pyproject.toml`, `Cargo.toml`, `Makefile`, or other obvious manifests
   - recent commits with `git log --oneline -5`
4. Search the codebase with `rg` for the most relevant keywords from the defect description.

If the defect description is too vague to produce a useful issue, ask targeted clarifying questions instead of filing low-signal noise.

## Investigation

Classify the report:

- Severity: `critical`, `high`, `medium`, or `low`
- Category: `bug`, `performance`, `ux`, `security`, `api`, `database`, `frontend`, `backend`, or `documentation`
- Likely affected components and files

Check for duplicate or related issues with `gh issue list --state all --search ... --limit 5` through Batch.

Keep the investigation proportional: enough evidence to make the issue actionable, not a full root-cause analysis.

## Issue Content

Generate:

- A concise title under 80 characters
- A structured body with:
  - `## Description`
  - `## Steps to Reproduce`
  - `## Expected Result`
  - `## Actual Result`
  - `## Technical Context`
  - `## Potentially Relevant Files`
  - `## Recent Changes`
  - `## Similar Issues`
  - `## Issue Metadata`
- A label set capped at 5 labels and restricted to labels that plausibly exist in the repo

Before creation, present:

- Investigation summary
- Similar issues found
- Issue preview with title, labels, and the key body sections

## Creation

Create the issue with `gh issue create` through Batch only after the preview is ready.

After creation, report:

- Issue number and URL
- Final title and labels used
- Any immediate next action if the severity is `high` or `critical`

## Guardrails

- Use `rg`, not `grep`, for repo searches.
- Do not claim reproduction steps were executed unless they actually were.
- Do not invent files, labels, stack details, or recent regressions.
- If repo context is sparse, say so directly in the issue rather than faking certainty.
