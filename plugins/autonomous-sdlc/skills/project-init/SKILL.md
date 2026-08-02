---
name: project-init
description: Use when the user wants a lightweight new-project bootstrap that creates repo scaffolding, an isolated-dev TOML baseline, a pinned SDLC harness, and a `PROJECT-SEED.md` for follow-on planning.
metadata:
  short-description: Bootstrap a repo for isolated development
---

# Project Init

This is a Codex-native port of the Claude Code `project-init` workflow.

## Invocation

- `Use project-init release-monitor`
- `Use project-init release-monitor --no-isolated-dev`
- `Use project-init`

Treat the exact `--no-isolated-dev` flag as an explicit opt-out and remove it
before parsing the remaining arguments as the proposed project name. Reject
unknown flags. If the name is omitted, derive it from the current directory and
confirm only if the inferred name is ambiguous or risky.

## GitHub CLI Execution

All GitHub CLI commands in this workflow must run through Batch or another
non-sandboxed execution path that preserves the user's authenticated `gh`
session.

Rules:

- Do not run `gh` commands through the default sandboxed shell path if that
  path is unauthenticated in this environment.
- Run `gh auth status` and `gh repo create` through Batch.
- If Batch or the authenticated non-sandbox path is unavailable, stop and
  report that GitHub operations cannot be completed safely from this session.

## Preflight

Before mutating anything:

1. Inspect the current directory contents.
2. Check whether `.git/` already exists.
3. Verify `git` is available.
4. Verify `gh auth status` through Batch before any GitHub repo creation.

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
5. Any additional bootstrap constraint, including explicitly known development commands or ports

Do not spend the interview budget on detailed product requirements, testing policy, or deployment design. That belongs in `brainstorm`.

## Bootstrap

When the environment and intent are clear, initialize the minimum useful scaffold:

- `git init` if appropriate
- stack-appropriate `.gitignore`
- `.isolated-dev.toml` and its local-override ignore rule unless explicitly opted out
- `.sdlc-harness.yaml` pinned to the locally configured agent harness
- lightweight `PROJECT-SEED.md`
- lightweight project guidance file if the user asked for it
- GitHub repo creation with `gh repo create` through Batch only if requested or clearly implied by the task

Keep generated artifacts minimal and editable.

## Isolated Development Scaffold

Unless the user passed `--no-isolated-dev`:

1. Add `.isolated-dev.local.toml` to `.gitignore`. Never create or commit the
   local override file.
2. Create this portable `.isolated-dev.toml` baseline:

   ```toml
   version = 1
   base_image = "local/isolated-dev-base:1"

   [resources]
   cpus = 4
   memory_gb = 8
   ```

3. Add `packages`, `[[ports]]`, `[commands.<name>]`, or `[secrets]` only when
   the user explicitly supplied those values during discovery. Never guess an
   executable command or port, and never put a secret value in either TOML
   file. Secret declarations may contain only environment variable names or
   project-relative file references.
4. Do not overwrite an existing isolated-dev configuration. If `isolated-dev`
   is available, run the read-only `isolated-dev status .` check after creating
   the scaffold. Fix configuration errors; report missing host prerequisites as
   unverified without blocking the repository bootstrap.

## SDLC Harness Pin

Create `.sdlc-harness.yaml` so agent routing remains stable across controller
reinstalls and different developer machines. Resolve the configured harness
with `sdlc doctor --json`; accept only `claude`, `codex`, or `qwen`, and fall
back to `claude` when the controller is unavailable or its output is invalid.

Write only the repository default:

```yaml
# Agent harness for this repo. Precedence: --harness flag > this file >
# installed registry default > built-in claude. See `sdlc doctor`.
harness:
  default: <resolved-harness>
```

Do not copy the installed harness registry or add per-role routing during
project initialization. Do not overwrite an existing harness file; report the
existing selection instead.

## Output

Report:

- Files created
- Whether git was initialized
- Whether a remote repo was created
- Whether isolated-dev was configured, opted out, or could not be validated
- Which SDLC harness was pinned or already configured
- Recommended next step, typically `Use brainstorm ...`

## Guardrails

- Do not overwrite meaningful existing files.
- Do not create remotes or push commits unless the user asked for that outcome.
- Do not write inline secrets or create `.isolated-dev.local.toml`.
- Prefer a minimal seed that makes follow-on planning easier over a heavy starter template.
