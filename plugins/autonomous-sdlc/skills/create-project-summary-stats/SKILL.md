---
name: create-project-summary-stats
description: Use when the user wants a dated project metrics snapshot assembled from repository, test, git, and GitHub signals.
metadata:
  short-description: Create a dated project metrics snapshot
---

# Create Project Summary Stats

This is a Codex-native port of the Claude Code `create-project-summary-stats` workflow.

## Invocation

- `Use create-project-summary-stats`
- `Use create-project-summary-stats focus on testing and activity`

Treat the user arguments as optional emphasis for which metrics to highlight.

## Goal

Create a condensed dated report named `PROJECT-STATS.<YYYY-MM-DD>.md` that is scannable in under 30 seconds.

## Workflow

1. Obtain today’s date from the shell with `date +%Y-%m-%d`.
2. Collect high-signal repo metrics:
   - line counts and language breakdown with `scc`
   - file and test counts
   - git activity where available
   - GitHub issues and PR signals with `gh` when authenticated
   - dependency and test health indicators where practical
3. Use fallbacks when tools or credentials are missing:
   - git data instead of GitHub metrics
   - test-file analysis instead of numeric coverage
4. Synthesize the metrics into a short snapshot report and write the dated file.

## Output File

The report should include:

- Executive summary
- Codebase metrics
- Testing metrics
- Dependency health notes
- Activity and collaboration signals
- Up to 3 actionable recommendations

Do not overwrite prior dated reports.

## Guardrails

- Prefer measured metrics over estimated ones.
- If a metric is unavailable, omit it and note the limitation.
- Keep the final file concise and decision-oriented.
