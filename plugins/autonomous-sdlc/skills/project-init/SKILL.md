---
name: project-init
description: Use when the user wants a lightweight new-project bootstrap that creates repo scaffolding and a `PROJECT-SEED.md` for follow-on planning.
metadata:
  short-description: Bootstrap a repo for planning
---

# Project Init

This is a Codex-native port of the Claude Code `project-init` workflow.

## Invocation

- `Use project-init release-monitor`
- `Use project-init`

Parse the user arguments as the proposed project name. If omitted, derive the name from the current directory and confirm only if the inferred name is ambiguous or risky.

## Preflight

Before mutating anything:

1. Inspect the current directory contents.
2. Check whether `.git/` already exists.
3. Verify `git` is available.
4. Verify `gh auth status` before any GitHub repo creation.

Stop and explain the conflict if:

- the directory is already an initialized repo
- the directory contains meaningful existing project files that make bootstrap unsafe
- GitHub authentication is missing for a workflow that needs remote creation

## Discovery

Gather only the minimum viable seed data:

1. Project objective
2. Tech stack
3. Architecture style
4. Repo visibility if a GitHub repo will be created
5. Any additional bootstrap constraint

Do not spend the interview budget on detailed product requirements, testing policy, or deployment design. That belongs in `brainstorm`.

## Bootstrap

When the environment and intent are clear, initialize the minimum useful scaffold:

- `git init` if appropriate
- stack-appropriate `.gitignore`
- lightweight `PROJECT-SEED.md`
- lightweight project guidance file if the user asked for it
- GitHub repo creation with `gh repo create` only if requested or clearly implied by the task

Keep generated artifacts minimal and editable.

## Output

Report:

- Files created
- Whether git was initialized
- Whether a remote repo was created
- Recommended next step, typically `Use brainstorm ...`

## Guardrails

- Do not overwrite meaningful existing files.
- Do not create remotes or push commits unless the user asked for that outcome.
- Prefer a minimal seed that makes follow-on planning easier over a heavy starter template.
