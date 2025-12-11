# Fix GitHub Issue

Fetch, analyze, and fix GitHub issue #$ARGUMENTS.

## Phase 1: Issue Intelligence

Use the GitHub MCP to retrieve full issue context:
- Fetch issue #$ARGUMENTS including title, body, labels, and comments
- Identify the repository from the current working directory (parse .git/config or use `gh repo view`)
- Extract any linked PRs, related issues, or cross-references

Summarize:
1. **Problem Statement**: What's actually broken/needed (1-2 sentences max)
2. **Acceptance Criteria**: What "done" looks like
3. **Scope Signals**: Labels, milestone, assignees that hint at priority/complexity

## Phase 2: Codebase Reconnaissance

Before proposing anything:
- Search the codebase for files/functions referenced in the issue
- Identify the likely affected modules and their dependencies
- Check for existing tests covering the affected area
- Look for similar past fixes (git log --grep or related closed issues)

## Phase 3: Fix Plan

Present a structured plan BEFORE writing any code:
```
### Proposed Fix
**Root Cause**: [your diagnosis]
**Approach**: [strategy in 1-2 sentences]

**Files to Modify**:
- `path/to/file.py` — [what changes]
- `path/to/another.py` — [what changes]

**New Files** (if any):
- `path/to/new.py` — [purpose]

**Tests**:
- [ ] Update existing: [which]
- [ ] Add new: [describe coverage]

**Risk Assessment**: Low / Medium / High + rationale
```

**STOP and wait for user approval before proceeding.**

## Phase 4: Implementation

Once approved:
1. Create a feature branch: `fix/issue-$ARGUMENTS-[short-description]`
2. Implement changes incrementally, committing logical units
3. Run existing tests to catch regressions
4. Add/update tests for the fix
5. Run linting/formatting per project conventions

## Phase 5: Verification & Wrap-up

- Confirm all tests pass
- Summarize changes made with file-by-file diff overview
- Draft a commit message following conventional commits: `fix(scope): description (#$ARGUMENTS)`
- Optionally: draft PR description linking the issue

---

**Guardrails**:
- Never push directly to main/master
- If issue is unclear or underspecified, ask clarifying questions before Phase 3
- If fix requires changes outside stated scope, flag it and get approval