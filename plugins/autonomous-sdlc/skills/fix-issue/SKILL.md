---
name: fix-issue
description: Use when the user wants Codex to resolve a GitHub issue end to end, sequentially by default, with optional parallel workers only when the user explicitly authorizes delegation.
metadata:
  short-description: Investigate and fix GitHub issues
---

# Fix Issue

This is a Codex-native port of the Claude Code `fix-issue` workflow.

The core rule is:

> The main Codex agent owns repo state, implementation decisions, verification, Git operations, and GitHub operations. Subagents are optional and only used when the user explicitly asks for parallel agents, subagents, or delegation.

## Invocation

- `Use fix-issue 42`
- `Use fix-issue https://github.com/owner/repo/issues/42`
- `Use fix-issue next --limit=2`
- `Use fix-issue all --sequential`
- `Use fix-issue 42 with parallel agents`

## Arguments

Parse free-form arguments from the user:

- Target: issue number, issue URL, `next`, or `all`
- Flags: `--skip-preflight`, `--skip-coverage`, `--coverage-threshold=N`, `--e2e-gate=block|warn|off`, `--skip-e2e`, `--limit=N`, `--sequential`

Defaults:

- Single-issue targets run sequentially in the main agent.
- Batch targets (`next --limit=N`, `all`) also run sequentially unless the user explicitly asks for parallel workers.
- `--skip-e2e` means `--e2e-gate=off`.

## Progress Notifications

Use `scripts/codex-sdlc-bridge.sh` as the standard progress API for this
workflow. The bridge logs every call and forwards to cmux only when
`CMUX_SOCKET_PATH` and `~/.claude/hooks/cmux-bridge.sh` are available, so these
calls are safe outside cmux.

Emit deterministic progress from the main Codex agent at phase boundaries:

```bash
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status fix-issue "Validating issue" --icon hammer --color "#007AFF"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 0.1 --label "Phase 1: Validate"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh log info "Fix issue started: #[ISSUE_NUMBER]" --source fix-issue

./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status fix-issue "Fetching issue" --icon hammer --color "#007AFF"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 0.2 --label "Phase 2: Fetch issue"

./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status fix-issue "Investigating" --icon search --color "#007AFF"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 0.35 --label "Phase 3: Investigate"

./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status fix-issue "Building fix" --icon hammer --color "#FF9500"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 0.55 --label "Phase 4: Build"

./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status fix-issue "Verifying" --icon flask --color "#FF9500"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 0.7 --label "Phase 5: Verify"

./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status fix-issue "Reviewing" --icon magnifier --color "#FF9500"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 0.85 --label "Phase 6: Review"
```

On bugfix loops or verification failures, emit a warning or error log with the
failed gate:

```bash
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh log warning "Gate failure: [STEP] -- [SUMMARY]" --source fix-issue
```

On completion:

```bash
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 1.0 --label "Complete"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status fix-issue "Complete" --icon sparkle --color "#34C759"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh log success "Fix complete: #[ISSUE_NUMBER] -- [ISSUE_TITLE]" --source fix-issue
```

On abort or unrecoverable failure, leave the progress bar at the current phase,
set the status to failed, and log the blocker:

```bash
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status fix-issue "Failed" --icon x.circle --color "#FF3B30"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh log error "Fix failed: #[ISSUE_NUMBER] -- [SUMMARY]" --source fix-issue
```

## GitHub CLI Execution

All GitHub CLI commands in this workflow must run through Batch or another
non-sandboxed execution path that preserves the user's authenticated `gh`
session.

Rules:

- Do not run `gh` commands through the default sandboxed shell path if that
  path is unauthenticated in this environment.
- Run `gh auth status`, `gh issue view`, and any PR or issue mutation through Batch.
- If Batch or the authenticated non-sandbox path is unavailable, stop and
  report that GitHub operations cannot be completed safely from this session.

## Preflight

Before making changes:

1. Run `gh auth status` through Batch before any GitHub issue or PR action.
2. Run `git status --porcelain` and stop on a dirty worktree unless the user has explicitly accepted working from that state.
3. Confirm the current branch with `git branch --show-current`.
4. If the workflow needs current remote issue or PR state, refresh with the narrowest useful `git fetch` or Batch-executed `gh` query.
5. Run the detected baseline test command unless `--skip-preflight` is present.

Detect tests in this order:

1. `package.json` with `scripts.test` -> `npm test`
2. `pyproject.toml` and pytest available -> `uv run pytest`
3. `Makefile` with `test` target -> `make test`
4. BATS files -> `bats tests/*.bats` or `bats test/*.bats`

If baseline tests fail before any issue work starts, stop and report that the default branch is already red.

## Issue Resolution Flow

For each target issue:

1. Fetch issue metadata with `gh issue view` through Batch.
2. Stop if the issue is closed, explicitly marked `wontfix`, or clearly assigned to someone else.
3. Investigate the problem directly in the codebase:
   - identify likely root cause
   - identify files to change
   - decide the smallest viable fix
4. Implement the fix in the main workspace.
5. Run the narrowest useful verification first, then broaden if the change touches shared behavior.
6. If requested by the surrounding task, prepare branch, commit, PR, and merge steps in the main agent.
7. Summarize outcome, verification, and residual risks.

Do not preserve Claude-specific orchestration constraints such as "never read source files directly." Codex should read the code it needs to fix the issue well.

## Parallel Workers

Only use subagents when the user explicitly says `parallel agents`, `subagents`, `delegate`, or equivalent.

When delegation is authorized:

- The main agent still owns `git`, Batch-executed `gh`, integration, and merge actions.
- Each worker must have a disjoint file or module scope.
- Workers must not push branches, create PRs, merge changes, or edit shared progress files.
- Use workers for bounded implementation or validation slices, not for the critical-path decision making that the main agent needs immediately.

Worker return contract:

```text
ISSUE_NUMBER: ...
STATUS: COMPLETE | PARTIAL | FAILED
CHANGED_FILES: ...
TESTS_RUN: ...
RISKS: ...
INTEGRATION_NOTES: ...
```

## Batch Mode

`next --limit=N` and `all` are supported, but the default Codex behavior is pragmatic:

- process issues one at a time unless explicit delegation is requested
- re-check repo state between issues
- stop on blocking repo-state problems instead of trying to automate around them

Do not port Claude-only worktree batch orchestration, Telegram hooks, or Claude session/task state. Use the Codex bridge above for cmux-compatible sidebar updates.

## Guardrails

- Prefer the smallest reasonable diff that closes the issue.
- Write or update tests first when the bug is cleanly testable.
- Never fake verification; report exactly what ran and what did not.
- Do not revert unrelated user changes.
- Keep review-quality reporting: root cause, fix summary, tests run, and residual risk.
