# Repository Quality Review

**Reviewed:** 2026-07-13
**Scope:** Architecture, maintainability, security, reliability, testing, dependencies, and delivery readiness

## Executive summary

**Readiness: conditional go for the current owner-operated personal fleet; no-go for unattended or broader deployment until the high-priority security and delivery gaps are closed.**

The core design is sound: profiles are explicit, Nix inputs are locked, bootstrap logic is modular, shell code uses strict mode, operational tooling is unusually thorough, and the repository has real tests and CI. Nix evaluation succeeds for all three profiles, ShellCheck passes at warning severity, version/requirements integrity checks pass, and the parent repository's 1,229-commit history passes gitleaks.

The main weakness is that the controls around the implementation are less reliable than the implementation itself. Network services are deliberately exposed on every interface without an enforced authentication boundary, a root activation downloads a mutable binary without integrity verification, the full advertised test suite cannot be collected, formatting is not enforced, and local release metadata is 21 commits and 18 release commits ahead of the newest tag. Repository hygiene and stale documentation further reduce confidence.

## Critical issues

### P0 — Management services have an unsafe default network boundary

- `scripts/health-api.py:942-959` makes authentication optional, while `darwin/health-api.nix:20-43` never supplies `HEALTH_API_TOKEN`.
- `scripts/health-api.py:1025` binds the always-on service to `0.0.0.0`. `/metrics` includes top process names (`scripts/health-api.py:748-750`). Any reachable LAN or tailnet client can query it.
- Ollama also binds to `0.0.0.0` (`darwin/maintenance.nix:16-20`, `scripts/start-ollama.sh:44-45`). CORS origin settings restrict browsers, not arbitrary HTTP clients, and Ollama has no application authentication here.

**Recommendation:** default both services to `127.0.0.1`. If remote access is required, bind to a specific Tailscale address or proxy through Tailscale Serve with an explicit ACL. Make the health token mandatory for non-loopback binding and load it from a `0600` secret file. Add tests covering bind selection, missing-token refusal, valid/invalid tokens, and `/ping` policy.

### P0 — Mutable remote code enters trusted execution paths without verification

- `darwin/monitoring.nix:85-97` downloads `releases/latest` and pipes it directly into `tar` during system activation, without a pinned version or hash. Activation runs with system-level authority.
- `setup.sh:42-53,253-260,291,314-322` downloads and executes `bootstrap-dist.sh` from mutable `main` by default without a checksum or signature.
- GitHub Actions use floating references, including `ludeeus/action-shellcheck@master` and Determinate Systems actions at `@main`.

**Recommendation:** package Beszel as a pinned Nix derivation with a fixed hash. Publish bootstrap artifacts and SHA-256 checksums from immutable version tags, make tagged installation the default, and keep branch installation as an explicit development option. Pin every GitHub Action to a full commit SHA and automate update PRs with Dependabot or Renovate.

### P1 — The test count is high, but the suite is not a dependable gate

- `bats tests/*.bats` fails during discovery because `tests/bootstrap_ssh_test.bats:11` sources `bootstrap.sh`, which unconditionally executes `main` at `bootstrap.sh:342`.
- Three large suites hard-code `/Users/user/dev/nix-install` (`tests/bootstrap_nix.bats`, `tests/bootstrap_nix_config.bats`, and `tests/bootstrap_nix_darwin.bats`), so they are not portable.
- The repository contains 1,206 BATS tests, while `docs/development/tools-and-testing.md:21-37` documents 233.
- CI explicitly does not run BATS (`.github/workflows/build-bootstrap.yml:119-126`). The Nix workflow evaluates output names but does not build a profile or evaluate its system derivation (`.github/workflows/nix-flake-check.yml:54-74`).
- `make fmt-check` currently reports nearly every tracked Nix file as unformatted, and no workflow invokes that target.

**Recommendation:** add a source guard to `bootstrap.sh`, load individual `lib/*.sh` modules in unit tests, replace absolute paths with `BATS_TEST_DIRNAME`, and provision pinned helpers through one bootstrap/dev-shell command. Establish a small reliable PR suite before preserving the 1,206-test headline. Add a single `make check` entry point that runs formatting, ShellCheck, Python unit tests, focused BATS tests, generated-artifact drift, version checks, gitleaks, and Nix derivation evaluation. Run it in CI.

### P1 — Release state has drifted from version state

- `VERSION` and README report `1.9.10`, but the newest local tag is `v1.7.1`.
- HEAD is 21 commits beyond that tag and contains 18 `release(...)` commits. Because `.github/workflows/release.yml` only runs on tags, those version bumps did not exercise the release workflow in this clone's visible history.
- `setup.sh:52` and `flake.nix:4` still describe version `1.0.0`; `scripts/verify-version.sh:22-29` only checks README and CLAUDE metadata.

**Recommendation:** make one release command update all authoritative version fields, create the signed tag, and fail if the tag/release is missing. Prefer deriving displayed versions from `VERSION` during build. Either publish every intended release or stop creating release commits for versions that will not be tagged.

## Technical debt backlog

### P1 — Tracked local and ignored files blur the security boundary

- `user-config.nix` and `config/calibre/SECRETS.md` are tracked even though `.gitignore:10-25` identifies them as local/secret material.
- Thirty-two Playwright session logs/snapshots under `.playwright-mcp/` and unrelated downloaded transcripts are tracked.
- The initialized `config/claude-code-config` submodule contains an ignored SDLC log with 93 secret-pattern matches. Parent Git history is clean, but full working-tree scans and one focused BATS gate fail because scanner scope crosses into initialized submodule state.
- Calibre includes 134 tracked plugin files, including four binary ZIPs and vendored Python internals. The whole plugin path is excluded by `.gitleaks.toml:17-23`, making future real leaks there invisible to the main scanner.

**Recommendation:** untrack machine-local files and browser/tool artifacts, audit their history once, and add explicit ignore rules. Keep only sanitized templates in Git. Store third-party Calibre ZIPs as versioned release assets or fetch them with pinned hashes; avoid a blanket secret-scan exemption when narrower fingerprints or paths will work. Make repository scans operate on parent-repo tracked files, and scan the submodule in its own CI.

### P2 — Reproducibility claims exceed the actual reproducibility boundary

- Nix dependencies are locked, but Homebrew taps are mutable (`darwin/homebrew.nix:6-11`), formulas/casks are not version-locked, MAS applications are externally versioned, Ollama model tags are mutable, and Beszel currently uses `latest`.
- README language such as “same config = same versions” and “zero drift” should therefore be read as configuration convergence, not byte-for-byte package reproducibility.

**Recommendation:** document a precise boundary: Nix packages are pinned; Homebrew/MAS/vendor assets converge to the version available at controlled update time. Pin the few operationally critical non-Nix components and record deployed versions in health output or a generated fleet manifest.

### P2 — High-complexity operational modules need focused seams

- `scripts/health-api.py` is 1,035 lines, about 774 code lines, and complexity 178; only eight Python unit tests cover selected parsing/cache behavior.
- Thresholds and model inventories are manually mirrored across `health-api.py`, `health-check.sh`, `ollama-lru.sh`, and Nix modules.
- Several completed modules retain stale “STUB” and “Epic-XX will add” comments, while progress docs still describe version 1.0-era state.

**Recommendation:** keep the zero-dependency runtime but split pure probes/parsers, cache orchestration, and HTTP serving into testable modules. Add handler/auth, timeout, concurrency, and degraded-command tests. Generate shared operational constants from one checked data source or add a consistency test. Remove stale scaffolding comments when touching each module.

### P2 — The repository carries too much historical material in the primary path

The first-party tree contains roughly 45,700 Markdown lines, including extensive completed story records and activity history. This makes current operational truth harder to find and contributes to contradictory counts and status claims.

**Recommendation:** keep README focused on install, update, rollback, and recovery. Move completed story detail and historical activity to `docs/archive/` or GitHub project/releases, and generate current status from `VERSION` plus one story index. Remove tracked `.playwright-mcp/`, `downloads/`, and superseded improvement notes after preserving anything genuinely useful.

## Recommendations matrix

| Recommendation | Impact | Effort | Priority | Likely owner |
|---|---:|---:|---:|---|
| Bind health API and Ollama locally; enforce remote-access ACL/auth | Very high | Medium | P0 | Platform/security |
| Pin Beszel, bootstrap artifacts, and GitHub Actions with integrity checks | Very high | Medium | P0 | Platform/security |
| Repair portable BATS loading and create one reliable `make check` gate | High | Medium | P1 | Test/platform |
| Enforce Nix formatting and evaluate/build system derivations in CI | High | Medium | P1 | Platform |
| Reconcile `1.9.10` with tags/releases and centralize version metadata | High | Low | P1 | Release owner |
| Untrack local config/tool logs; narrow scanner exclusions | High | Low-medium | P1 | Repository owner |
| Define and document the real reproducibility boundary | Medium | Low | P2 | Architecture/docs |
| Add focused health API security/error/concurrency tests, then split seams | Medium | Medium | P2 | Platform |
| Archive completed planning/history and generate current status | Medium | Medium | P2 | Product/docs |

## Suggested execution order

1. **Security boundary (1–2 days):** loopback defaults, Tailscale ACL/proxy, mandatory token for remote health access, pinned Beszel, pinned Actions.
2. **Trustworthy gate (2–4 days):** repair BATS loading/paths, format the Nix baseline once, add `make check`, run the focused suite on macOS CI, make lock drift fatal.
3. **Release and install integrity (1–2 days):** reconcile tags, centralize versions, publish immutable bootstrap plus checksum, install from a tag by default.
4. **Repository cleanup (1–2 days):** untrack ignored/local artifacts, narrow gitleaks allowlists, move vendor payloads, refresh test/docs counts.
5. **Maintainability (incremental):** add health API boundary tests, extract pure seams, consolidate mirrored constants, archive completed planning material.

## Evidence and limitations

Verified locally:

- `bash -n` and ShellCheck at warning severity: pass.
- `nix flake show` and profile-name evaluation: pass for `ai-assistant`, `power`, and `standard`.
- Python health API unit tests: 8/8 pass.
- Focused modern BATS selection: 69 pass, 1 fails because an initialized submodule's ignored local log is included in a full-tree gitleaks test.
- Full BATS invocation: cannot collect because sourcing `bootstrap.sh` executes the installer.
- `make fmt-check`: fails across nearly all Nix files.
- Version and requirements-integrity checks: pass within their current limited scope.
- Parent-repository gitleaks history scan: no leaks across 1,229 commits. Full initialized working tree: 94 matches, 93 in one ignored submodule log and one synthetic test fixture.
- Generated bootstrap drift is already enforced in CI; an older recommendation in `codex-improvements.md` is obsolete.

Not verified:

- A full `darwin-rebuild` or clean-machine bootstrap was not run because it mutates the host.
- Homebrew/MAS application installation, launchd behavior, Tailscale ACLs, and rollback were not exercised.
- Remote GitHub release state was not fetched; tag findings reflect the local clone.
- Existing worktree changes in Nix modules, the submodule, and tests were preserved and reviewed as context only.
