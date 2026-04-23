---
name: check-releases
description: Use when the user wants Codex to run the repo’s release-monitor workflow and summarize dependency, security, and upgrade signals.
metadata:
  short-description: Run and summarize release monitoring
---

# Check Releases

This is a Codex-native port of the Claude Code `check-releases` workflow.

## Invocation

- `Use check-releases`
- `Use check-releases focus on security updates`

Treat the user arguments as optional emphasis for the summary.

## Workflow

1. Prefer the repository’s existing release-monitor scripts over ad hoc lookups.
2. Run the narrowest useful workflow:
   - `scripts/release-monitor.sh` when available and appropriate
   - or the underlying `fetch-release-notes.sh` and `analyze-releases.sh` steps if that is easier to inspect or recover from
3. Summarize findings into:
   - critical updates
   - breaking changes
   - new features worth evaluating
   - routine updates
   - prioritized recommendations

## Evidence Sources

Use and cite local outputs when available:

- release-monitor logs
- release notes JSON
- analysis JSON
- repo scripts and config that determine update behavior

## Guardrails

- Do not fabricate upstream information if the scripts fail or network access is unavailable.
- Clearly separate measured script output from interpretation.
- If the workflow requires network or elevated permissions, request them instead of silently skipping important steps.
