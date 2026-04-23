---
name: plan-release-update
description: Use when the user wants Codex to read a release-monitor issue and produce an implementation plan for the update or migration work.
metadata:
  short-description: Plan implementation for a release issue
---

# Plan Release Update

This is a Codex-native port of the Claude Code `plan-release-update` workflow.

## Invocation

- `Use plan-release-update 123`

Parse the user arguments as a GitHub issue number.

## Workflow

1. Read the issue with `gh issue view`.
2. Determine the issue type from labels and title:
   - security update
   - breaking change
   - new feature
   - notable routine update
   - model or profile-specific enhancement
3. Inspect the relevant repo files to assess impact:
   - `flake.nix`
   - Homebrew or darwin config
   - `home-manager/modules/`
   - `scripts/`
4. Produce an implementation plan covering:
   - issue summary
   - priority
   - impact analysis
   - numbered implementation steps
   - likely files to modify
   - testing strategy
   - rollback plan

## Output

Respond with a concise, implementation-ready plan. If the issue does not contain enough information, say what is missing instead of guessing.

## Guardrails

- Keep the plan grounded in this repository’s actual update paths.
- Distinguish security urgency from routine maintenance.
- Prefer repo-local evidence over generic upgrade advice.
