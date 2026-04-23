---
name: roast
description: Use when the user wants a hard-nosed repository review focused on real bugs, risks, regressions, and maintainability problems rather than a generic code walkthrough.
metadata:
  short-description: Review the repo like a senior reviewer
---

# Roast

This is a Codex-native port of the Claude Code `roast` review workflow.

## Invocation

- `Use roast`
- `Use roast focus on security and shell scripts`
- `Use roast review the recent bootstrap changes`

Treat the user arguments as the review scope or emphasis. If no scope is provided, review the current repository state.

## Review Mode

Operate in a code-review mindset:

- Findings first
- Ordered by severity
- File and line references where possible
- Brief summary only after the findings

Prioritize:

- Breaking bugs and behavioral regressions
- Security issues
- Reliability and operational risks
- Missing validation and error handling
- Test gaps for important behavior
- Maintainability problems that will make future changes brittle

Do not spend time on low-value style commentary that automated tooling should handle.

## Investigation

Before writing the review:

1. Detect the stack from repo manifests and file types.
2. Read the highest-signal files for the requested scope.
3. Run narrow non-mutating checks if they materially improve the review.
4. Confirm whether tests or validation evidence exist for the risky areas you flag.

If the repo is large, bias toward the core app, scripts, and configuration that actually drive behavior.

## Output

Use this structure:

- Findings with severity, path, and concise explanation
- Open questions or assumptions if they materially affect the conclusions
- Short change summary or overall assessment only after the findings

If no findings are discovered, say that explicitly and call out residual risk or verification gaps.

## Guardrails

- Be specific and concrete.
- Prefer real impact over theoretical purity.
- Do not invent failures you did not substantiate from the code.
- Do not mutate files unless the surrounding user task explicitly asks for fixes.
