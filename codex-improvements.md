# Codex Repo Improvement Recommendations

## Summary

This repo is well structured for a personal Nix-Darwin fleet: clear flake profiles, modular bootstrap phases, docs, CI, and operational scripts. The highest-value improvements are to make scheduled agents reliable across profiles, tighten security around tracked personal/vendor data, and make CI fail on the checks it already attempts.

Verified during investigation:

- `bash -n setup.sh bootstrap.sh scripts/build-bootstrap.sh lib/*.sh scripts/*.sh` passes.
- `nix flake show --no-write-lock-file` evaluates.
- `nix eval .#darwinConfigurations --apply 'x: builtins.attrNames x' --no-write-lock-file` returns `ai-assistant`, `power`, and `standard`.
- ShellCheck currently reports real/noisy issues.
- BATS is not installed in the current environment.

## Priority Fixes

### Fix cross-profile maintenance script deployment

`weekly-digest`, `release-monitor`, and `disk-cleanup` are configured for all profiles in `darwin/maintenance.nix`, but their scripts are only synced inside the Power-profile activation block in `darwin/configuration.nix`.

Recommendation: move these common maintenance scripts into `COMMON_SCRIPTS`; keep only truly Power-only dependencies in the Power block.

### Harden secret and personal-config hygiene

The repo tracks `user-config.nix`, `config/calibre/SECRETS.md`, zipped plugin artifacts, and vendored plugin internals. `.gitignore` only ignores some generated Calibre secret files, while `.gitleaks.toml` explicitly allowlists `SECRETS.md` and the DeACSM plugin tree.

Recommendation: untrack machine-local config/secrets, keep templates/examples, and move large/vendor plugin payloads to a release asset, Git LFS, or documented local install step.

### Make CI enforcement real

ShellCheck is configured with `continue-on-error: true` in `.github/workflows/build-bootstrap.yml`, so regressions do not block merges.

Recommendation: add `# shellcheck shell=bash` to sourced libraries, suppress intentional globals centrally, then remove `continue-on-error`.

### Make generated bootstrap drift detectable

`scripts/build-bootstrap.sh` writes tracked `bootstrap-dist.sh`, but CI only builds and validates the artifact.

Recommendation: add a CI step that rebuilds `bootstrap-dist.sh` and fails if `git diff --exit-code bootstrap-dist.sh` is non-empty.

### Stabilize test setup

Several BATS tests load ignored helper clones, for example `tests/08-final-darwin-rebuild.bats`, while `.gitignore` ignores those helper directories.

Recommendation: vendor helpers as submodules, add a setup script, or rewrite tests to use plain BATS assertions so a fresh clone can run the suite.

## Cleanup Recommendations

- Reconcile README status claims: `README.md` says "2 MacBooks Running" and also says "Four MacBooks." Pick one source of truth or generate this status from config.
- Ignore local artifacts consistently: `.ruff_cache/`, `.DS_Store`, `result`, `scripts/__pycache__/`, and local Calibre secret files are present as ignored/untracked noise. Keep them ignored and consider adding a quick repo hygiene check in CI or a `check-clean` script.
- Reduce duplicated operational constants: Ollama model lists and health thresholds are mirrored between `flake.nix`, `scripts/health-api.py`, and `scripts/health-check.sh`. Generate the script constants from a small JSON/Nix source or add a CI consistency check.
- Avoid network downloads during activation where possible. The Beszel agent activation downloads the latest GitHub release at rebuild time in `darwin/monitoring.nix`. Prefer a pinned Nix derivation or versioned URL with hash so rebuilds stay reproducible.

## Test Plan

- Run `bash -n setup.sh bootstrap.sh scripts/build-bootstrap.sh lib/*.sh scripts/*.sh`.
- Run `shellcheck -S warning setup.sh bootstrap.sh lib/*.sh scripts/*.sh` and require a clean or intentionally suppressed result.
- Run `nix flake show --no-write-lock-file`.
- Run `nix eval .#darwinConfigurations --apply 'x: builtins.attrNames x' --no-write-lock-file`.
- After installing or provisioning BATS helpers, run `bats tests/*.bats`.
- On a non-Power profile, rebuild and verify `~/.local/bin/weekly-maintenance-digest.sh`, `release-monitor.sh`, and `disk-cleanup.sh` exist and the corresponding LaunchAgents no longer log "script not found."

## Assumptions

- Existing dirty worktree changes in `README.md`, `darwin/homebrew.nix`, and `config/claude-code-config` are user changes and should be preserved.
- The priority is reliability and maintainability for this personal Mac fleet, not turning the repo into a generic public distribution.
- Calibre plugin functionality should remain available, but sensitive or large third-party payloads should not be treated as normal source code.
