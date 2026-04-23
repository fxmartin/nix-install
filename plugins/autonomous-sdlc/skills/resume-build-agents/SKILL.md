---
name: resume-build-agents
description: Use when the user wants controlled story implementation with explicit agent coordination, one story or epic slice at a time.
metadata:
  short-description: Controlled story execution with Codex
---

# Resume Build Agents

This is a Codex-native port of the Claude Code `resume-build-agents` workflow.

## Invocation

- `Use resume-build-agents next`
- `Use resume-build-agents epic-03`
- `Use resume-build-agents 03.2-001`

Parse the user arguments as a target story ID, epic identifier, epic name, or `next`.

## Goal

This skill is the controlled counterpart to `build-stories`.

Use it when the user wants:

- one story at a time instead of a full autonomous batch
- visible coordination over which slices are delegated
- a tighter implementation loop before PR or merge work

## Preflight

Before making changes:

1. Confirm the repository has story files such as `STORIES.md`, `docs/stories/`, or the repo’s established equivalent.
2. Run `git status --porcelain` and stop on a dirty worktree unless the user explicitly accepts working from that state.
3. Confirm the current branch with `git branch --show-current`.
4. Check `gh auth status` if the workflow may create or update PRs.

## Workflow

1. Resolve the target story or epic scope from the story files.
2. Read the relevant story definition and acceptance criteria.
3. Assess the tech stack and determine the implementation slices involved: backend, frontend, shell, QA, docs, infra.
4. Work sequentially in the main agent by default.
5. Only spawn workers when the user explicitly asks for parallel agents, subagents, or delegation.
6. Implement with TDD discipline when the story is cleanly testable.
7. Run narrow verification first, then broaden if the change touches shared behavior.
8. If requested by the surrounding task, prepare branch, commit, PR, and review steps in the main agent.

## Delegation Rules

When delegation is explicitly authorized:

- The main agent owns story interpretation, git state, integration, and GitHub operations.
- Workers get disjoint file ownership.
- Workers do not create PRs, push branches, or merge changes.
- Always end with a main-agent review pass before completion.

## Output

Always report:

- Story or epic worked on
- Relevant acceptance criteria covered
- Files changed
- Tests and checks run
- Remaining work, blockers, or PR status

## Guardrails

- Prefer the smallest diff that meaningfully advances the story.
- Do not skip unresolved acceptance criteria silently.
- Keep the story files as the source of truth for scope.
