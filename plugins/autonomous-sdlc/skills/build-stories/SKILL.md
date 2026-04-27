---
name: build-stories
description: Use when the user asks Codex to discover, plan, or execute story-based SDLC work from STORIES.md or epic files. Supports dry-run queue generation, sequential story builds, and opt-in parallel worker orchestration with main-agent-owned Git/PR/progress integration.
metadata:
  short-description: Build story queues with Codex
---

# Build Stories

This is a Codex-native port of the Claude Code `build-stories` workflow.

The core rule is:

> Parallel agents produce isolated candidate changes; the main Codex agent owns integration, Git state, PR lifecycle, shared progress, and merges.

## Invocation

- Sequential/default: `Use build-stories all --auto --limit=5`
- Dry run: `Use build-stories epic-01 --dry-run`
- Parallel opt-in: `Use build-stories epic-01 --limit=2 with parallel agents`

Only use subagents when the user explicitly says `parallel agents`, `subagents`, `delegate`, or equivalent. Without that explicit permission, run sequentially in the main agent.

## Arguments

Parse free-form arguments from the user:

- Scope: `all`, `resume`, `epic-NN`, or a case-insensitive epic name. Default: `all`.
- Flags: `--dry-run`, `--auto`, `--limit=N`, `--sequential`, `--skip-preflight`, `--skip-coverage`, `--coverage-threshold=N`, `--e2e-gate=block|warn|off`, `--skip-e2e`.

## GitHub CLI Execution

All GitHub CLI commands in this workflow must run through Batch or another
non-sandboxed execution path that preserves the user's authenticated `gh`
session.

Rules:

- Do not run `gh` commands through the default sandboxed shell path if that
  path is unauthenticated in this environment.
- Run `gh auth status` and every PR or issue operation through Batch.
- If Batch or the authenticated non-sandbox path is unavailable, stop and
  report that GitHub operations cannot be completed safely from this session.

## Preflight

Before mutating anything:

1. Run `git status --porcelain` and block on a dirty worktree unless the user explicitly confirms working with the dirty state.
2. Confirm current branch with `git branch --show-current`.
3. Check `gh auth status` through Batch before any GitHub issue/PR operation.
4. Run the detected test command unless `--skip-preflight` is present.

Detect tests in this order:

1. `package.json` with `scripts.test` -> `npm test`
2. `pyproject.toml` and pytest available -> `uv run pytest`
3. `Makefile` with `test` target -> `make test`
4. BATS files -> `bats tests/*.bats` or `bats test/*.bats`

## Discovery

Use `scripts/discover-stories.py` from this plugin to parse story files and produce a queue:

```bash
python3 plugins/autonomous-sdlc/scripts/discover-stories.py all --dry-run
```

The script emits a display table and a single-line `QUEUE_JSON:` record. Parse that JSON to drive the workflow. For detailed parsing semantics, read only the needed files in `references/`:

- `story-parser.md`
- `story-validation.md`
- `dependency-resolver.md`
- `batch-progress.md`

## Sequential Mode

For each queued story:

1. Mark it `IN_PROGRESS` with `scripts/update-build-progress.py`.
2. Implement the story in the main workspace.
3. Run tests and coverage gate unless skipped.
4. Run review checks.
5. Create branch/commit/PR if requested by the surrounding task.
6. Merge sequentially only after gates pass.
7. Mark DoD complete and update `.build-progress.md`.

Use the reference prompts as guidance when needed:

- `coverage-gate-prompt.md`
- `bugfix-agent-prompt.md`
- `merge-update-prompt.md`
- `summary-prompt.md`
- `e2e-gate.md`

## Parallel Mode

Parallel mode is opt-in and must be driven by the main agent.

Main agent responsibilities:

- Compute dependency cohorts.
- Create non-overlapping worker assignments.
- Spawn workers only after explicit user authorization.
- Integrate worker results one at a time.
- Own all `git`, Batch-executed `gh`, PR, merge, DoD, and progress-file operations.

Worker responsibilities:

- Work on exactly one story or validation slice.
- Write only within the explicit file/module scope assigned.
- Do not push branches.
- Do not create or merge PRs.
- Do not write `.build-progress.md`.
- Return a final contract:

```text
STORY_ID: ...
STATUS: COMPLETE | PARTIAL | FAILED
CHANGED_FILES: ...
TESTS_RUN: ...
RISKS: ...
INTEGRATION_NOTES: ...
```

External isolation rules:

- Unique ports for dev servers.
- Unique test DB/schema/container/project names.
- Worker-specific temp dirs under `/tmp`.
- Main agent alone writes shared files and talks to GitHub.

## Progress Notifications

Use `scripts/codex-sdlc-bridge.sh` as the standard progress API for this
workflow. The bridge logs every call and forwards to cmux only when
`CMUX_SOCKET_PATH` and `~/.claude/hooks/cmux-bridge.sh` are available, so these
calls are safe outside cmux.

Use exactly two status keys throughout the run:

- `phase`: macro phase (`Preflight`, `Discovery`, `Building`, `Summarizing`, `Complete`)
- `current`: current story, cohort, or verification step

Emit these updates from the main Codex agent:

```bash
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status phase "Preflight" --icon shield --color "#007AFF"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 0.0 --label "Preflight"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh log info "Preflight started" --source build-stories

./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status phase "Discovery" --icon search --color "#007AFF"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 0.1 --label "Discovering stories"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh log info "Story discovery started" --source build-stories

./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status phase "Building" --icon hammer --color "#FF9500"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 0.2 --label "Story 0/[TOTAL]"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh log info "Build started: [TOTAL] stories" --source build-stories
```

For each story, update `current`, progress, and the ledger:

```bash
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status current "[ID] [STEP]" --icon hammer --color "#FF9500"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress [FRACTION] --label "Story [N]/[TOTAL]: [ID]"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh log info "[ID] [STEP] started" --source build-stories
```

Use `[FRACTION] = 0.2 + (0.7 * [N] / [TOTAL])`, capped at `0.9`, while
building stories. On failure, log the failed step and keep the progress label
on the failing story. On completion:

```bash
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh clear current
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh status phase "Complete" --icon sparkle --color "#34C759"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh progress 1.0 --label "Done: [COMPLETED]/[TOTAL]"
./plugins/autonomous-sdlc/scripts/codex-sdlc-bridge.sh log success "Build finished: [COMPLETED] done, [FAILED] failed, [SKIPPED] skipped" --source build-stories
```

Workers must not update shared progress state. In parallel mode, only the main
agent emits aggregate cohort/stage progress after integrating worker results.

## Do Not Migrate

Do not read or port Claude runtime/session state from `~/.claude/tasks`, `projects`, `sessions`, `todos`, or telemetry. Repo-managed `config/claude-code-config` is the migration source of truth.
