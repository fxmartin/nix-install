---
name: coverage
description: Use when the user wants Codex to assess test coverage, close meaningful gaps, and raise confidence with targeted tests and verification.
metadata:
  short-description: Improve test coverage pragmatically
---

# Coverage

This is a Codex-native port of the Claude Code `coverage` workflow.

## Invocation

- `Use coverage`
- `Use coverage for bootstrap scripts`
- `Use coverage focus on lib/preflight.sh and related tests`

Treat the user arguments as the coverage scope. If none are provided, assess the repo’s main test surface and target the highest-value gaps first.

## Goal

Increase confidence, not vanity metrics.

Prioritize:

- Business-critical logic
- Failure paths and input validation
- Regressions that are cheap to lock down with tests
- Shared utilities with high blast radius

Do not chase 100% coverage mechanically if the remaining gaps are low-value or structurally impractical.

## Workflow

1. Detect the test framework and current test commands.
2. Run the narrowest useful existing tests first to establish baseline behavior.
3. Identify uncovered or weakly-tested paths in the requested scope.
4. Add or update tests for meaningful gaps.
5. Fix small test issues that block the coverage work.
6. Re-run the relevant tests and report what improved.

Use the repo’s existing testing conventions. In this repository, prefer BATS for shell workflow coverage unless the surrounding area already uses a different framework.

## Output

Report:

- Baseline test status
- Tests added or updated
- Coverage gaps closed
- Remaining high-value gaps
- Exact verification run

If coverage tooling is unavailable, rely on targeted gap analysis and explicit test additions rather than pretending to have numeric coverage.

## Guardrails

- Write tests before implementation changes when the bug or gap is cleanly testable.
- Keep tests readable and behavior-focused.
- Avoid broad refactors unrelated to the coverage objective.
- Never claim a metric you did not measure.
