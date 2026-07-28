# Epic 10: Bootstrap Integrity & Security Hardening

## Epic Overview
**Epic ID**: Epic-10
**Description**: Close the findings of the 2026-07-28 full-repo architecture & security review (Fable 5). Restructure the bootstrap's phase 5 from "download ~40 unverified files from main HEAD" to "clone the repo at the pinned release tag" — eliminating both the confirmed install-breaking drift bug (missing `darwin/maintenance-system.nix` and `home-manager/modules/mlx-lm.nix` in the download list) and the unverified-content-run-as-root hole. Harden the remaining P0 security nits (root-shell interpolation, unpinned Nix installer download, world-readable Beszel key, SMB credential write race, silent SSH key overwrite, setup.sh temp handling) and clean up the P1 drift/CI gaps (stale Ollama model messaging, `scripts/**` absent from CI, dead gates, doc drift).
**Business Value**: A fresh curl-pipe install currently **fails flake evaluation** — the core promise of the repo (fresh MacBook → configured in <30 min) is broken. The restructure fixes it permanently: no manually-synced file list can drift again, and the executed configuration is tag-pinned end-to-end instead of trusting main HEAD. Security fixes remove local privilege-escalation and credential-exposure vectors on all 4 MacBooks.
**Success Metrics**:
- `NIX_INSTALL_CI=1 nix eval --impure` of all 3 `darwinConfigurations.*.system.drvPath` succeeds from a fresh `git clone --depth 1 --branch v<tag>` tree (the exact failure mode of the old download list)
- Zero references to the per-file download list remain in `lib/nix-darwin.sh`, docs, or CLAUDE.md constraint #5
- `make check` green; `bootstrap-dist.sh` reproduces byte-identically; `shasum -c SHA256SUMS` passes
- shellcheck + `bash -n` run in CI for every PR touching `scripts/**` or `setup.sh`

## Epic Scope
**Total Stories**: 12 | **Total Points**: 43 | **MVP Stories**: 8

## Features in This Epic

### Feature 10.1: Clone-First Bootstrap Restructure

#### Stories

##### Story 10.1-001: Replace phase-5 file downloads with a pinned-tag git clone
**User Story**: As FX bootstrapping a fresh MacBook, I want phase 5 to clone the repo at the release tag instead of downloading individual files so that the installed configuration is complete, integrity-checked, and immune to file-list drift
**Priority**: Must Have
**Story Points**: 8

**Acceptance Criteria**:
- **Given** a clean environment **When** `install_nix_darwin_phase` runs **Then** it performs `git clone --depth 1 --branch "${NIX_INSTALL_REF}" https://github.com/${GITHUB_OWNER}/${GITHUB_REPO_NAME}.git "${WORK_DIR}/repo"` instead of any per-file `curl`
- **Given** the clone succeeded **When** the first build runs **Then** `run_nix_darwin_build` executes `sudo nix run nix-darwin -- switch --flake "${WORK_DIR}/repo#${INSTALL_PROFILE}"` and the redundant git-init step (`lib/nix-darwin.sh:496-540`) is removed
- **Given** the three HTTPS oh-my-zsh submodules **When** phase 5 initializes submodules **Then** each is initialized per-path and a failure of the SSH-only `config/claude-code-config` submodule is tolerated (warning, not fatal — mirrors `lib/repo-clone.sh:149-166`)
- **Given** `user-config.nix` was generated in phase 2 **When** phase 5 prepares the clone **Then** it is copied into `${WORK_DIR}/repo` before the build

**Technical Notes**: Xcode CLI tools (phase 3) guarantee `/usr/bin/git` exists. Delete `darwin_files`/home-manager/scripts download arrays including the cosmetic 10-entry summary list at `lib/nix-darwin.sh:411-420`. `NIX_INSTALL_REF` defaults to `main` inside lib for dev use. Phases 7/8 (SSH clone to permanent location, final rebuild) are unchanged.

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing (source-text bats suites `package_manager_boundaries.bats`, `retired_icloud_sync.bats`, `retired_vscode.bats` updated for the new function)
- [ ] Documentation updated (CLAUDE.md constraint #5 removed, `lib/README.md`, architecture docs)

**Dependencies**: None
**Risk Level**: High

##### Story 10.1-002: Pin the bootstrap ref end-to-end from setup.sh
**User Story**: As FX, I want setup.sh to export the release tag as the clone ref so that the whole install chain (setup.sh → bootstrap-dist.sh → cloned config) runs from one immutable version
**Priority**: Must Have
**Story Points**: 2

**Acceptance Criteria**:
- **Given** a default install **When** setup.sh launches bootstrap **Then** it exports `NIX_INSTALL_REF="v${SETUP_VERSION}"`
- **Given** the `NIX_INSTALL_BRANCH` developer override is set **When** setup.sh launches bootstrap **Then** `NIX_INSTALL_REF` follows the override, preserving current dev workflow

**Technical Notes**: `SETUP_VERSION` already exists at `setup.sh:51`. Document in setup.sh header that the released path is tag-pinned only from the *next* release onward.

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: 10.1-001
**Risk Level**: Low

##### Story 10.1-003: Regenerate bootstrap-dist.sh and SHA256SUMS; smoke-test the cloned tree
**User Story**: As FX, I want the standalone installer and checksums rebuilt and the cloned tree eval-tested so that the release artifacts match the restructured source
**Priority**: Must Have
**Story Points**: 3

**Acceptance Criteria**:
- **Given** the restructure is complete **When** `scripts/build-bootstrap.sh` and `scripts/generate-checksums.sh` run **Then** `make check-generated` passes and `shasum -c SHA256SUMS` succeeds
- **Given** a scratch `git clone --depth 1 --branch <current tag>` with the CI fixture user-config **When** `NIX_INSTALL_CI=1 nix eval --impure` evaluates all 3 profiles' `system.drvPath` **Then** evaluation succeeds — proving the drift class (missing `maintenance-system.nix`, `mlx-lm.nix`) is closed

**Technical Notes**: This is the verification that would have caught the current breakage. No version bump in this epic — FX releases via `make release-patch` after his own validation.

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: 10.1-001, 10.1-002
**Risk Level**: Medium

### Feature 10.2: Bootstrap Security Hardening (P0)

#### Stories

##### Story 10.2-001: Eliminate root-shell interpolation in Nix cache configuration
**User Story**: As FX, I want `sudo bash -c` invocations to stop interpolating unvalidated variables so that a hostile environment variable cannot execute arbitrary commands as root
**Priority**: Must Have
**Story Points**: 3

**Acceptance Criteria**:
- **Given** `NIX_CONF_PATH` contains a single quote or any character outside `^/[A-Za-z0-9._/-]+$` **When** `configure_nix_phase` runs **Then** it aborts with a validation error before any `sudo` call
- **Given** a valid path **When** the four `sudo bash -c "$(declare -f …)"` calls at `lib/nix-install.sh:635-650` run **Then** the path and `USER` are passed as positional arguments, never string-interpolated into the root shell

**Technical Notes**: `sudo bash -c '…; fn "$1" "$2"' _ "$nix_conf_path" "$USER"` pattern.

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: None
**Risk Level**: Medium

##### Story 10.2-002: Harden the Nix installer download
**User Story**: As FX, I want the upstream Nix installer fetched with strict TLS, failure detection, and an unpredictable path so that a failed or tampered download can never be executed as root
**Priority**: Must Have
**Story Points**: 2

**Acceptance Criteria**:
- **Given** nixos.org returns an HTTP error **When** the installer is downloaded (`lib/nix-install.sh:47-52`) **Then** `curl --proto '=https' --tlsv1.2 -fsSL` fails the phase instead of writing the error body to disk
- **Given** the download succeeds **When** the installer is stored **Then** it lands in a `mktemp`-created path (not fixed `/tmp/nix-installer.sh`), is executed, and is removed afterwards
- **Given** any failure **When** stderr is produced **Then** it is no longer suppressed with `2>/dev/null`

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: None
**Risk Level**: Low

##### Story 10.2-003: Back up existing SSH keys before regeneration
**User Story**: As FX re-running bootstrap on a machine with an existing `~/.ssh/id_ed25519`, I want the old keypair backed up before a new one is generated so that I never silently lose a private key
**Priority**: Must Have
**Story Points**: 2

**Acceptance Criteria**:
- **Given** `~/.ssh/id_ed25519` exists **When** `generate_ssh_key` runs (`lib/ssh-github.sh:149`) **Then** both key and `.pub` are copied to `id_ed25519.backup.<timestamp>` (mode 600) before `ssh-keygen` runs
- **Given** the backup happens **When** the user is informed **Then** the existing message at `lib/ssh-github.sh:454` ("existing key will be backed up") is finally true

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: None
**Risk Level**: Low

##### Story 10.2-004: Fix setup.sh temp-dir handling and verify the config template
**User Story**: As FX running the curl-pipe installer, I want setup.sh to use unpredictable temp paths with guaranteed cleanup and to checksum-verify everything it downloads so that a local attacker cannot race or plant files
**Priority**: Must Have
**Story Points**: 3

**Acceptance Criteria**:
- **Given** setup.sh starts **When** the temp dir is created **Then** it uses `mktemp -d /tmp/nix-install-setup.XXXXXX` (replacing PID-predictable `$$` at `setup.sh:48`) and a `trap … EXIT` removes it on every exit path
- **Given** `user-config.template.nix` is downloaded (`setup.sh:318`) **When** it is used **Then** it has been verified against its existing `SHA256SUMS` entry, like bootstrap-dist.sh
- **Given** the default (no-branch) invocation **When** help/error text prints URLs (`setup.sh:410-422`) **Then** no double-slash `nix-install//setup.sh` artifacts appear

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: None
**Risk Level**: Low

### Feature 10.3: Service & Credential Hardening (P0)

#### Stories

##### Story 10.3-001: Protect the Beszel agent key and tighten resident-agent umasks
**User Story**: As FX, I want the Beszel hub key unreadable by other local users and consistent umasks on network-listening agents so that credentials and logs are not world-readable
**Priority**: Must Have
**Story Points**: 2

**Acceptance Criteria**:
- **Given** activation writes `~/.config/beszel/beszel-agent.env` (`darwin/monitoring.nix:79-103`) **When** the file is created by root **Then** it is written under `umask 077` and explicitly `chmod 600` before content lands
- **Given** the three resident agents `beszel-agent`, `health-api`, `privacy-filter` **When** their launchd plists are generated **Then** each carries `Umask = 77` like the other 12 agents

**Technical Notes**: Beszel listens on 45876 on all interfaces (tailnet-reachable) — key confidentiality is the compensating control. Binding/monitoring consolidation is deferred to a later epic.

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing (extend `tests/network_security.bats`)
- [ ] Documentation updated

**Dependencies**: None
**Risk Level**: Low

##### Story 10.3-002: Close the SMB credential write race and fix URL-encoding
**User Story**: As FX on the Power profile, I want `/etc/auto_smb` created with restrictive permissions from the first byte and passwords fully URL-encoded so that the NAS credential is never momentarily world-readable or corrupted
**Priority**: Must Have
**Story Points**: 2

**Acceptance Criteria**:
- **Given** activation writes the credentialed `/etc/auto_smb` (`darwin/smb-automount.nix:83-99`) **When** the file is created **Then** it is written under `umask 077` (mode set before content, not chmod-after)
- **Given** a password containing `%`, space, `+`, or `;` **When** it is URL-encoded **Then** `%` is encoded first and all four characters are handled in addition to the existing `@ : / # ? &` set
- **Given** the no-password variant **When** it is written **Then** the write ordering is consistent (644 remains acceptable — no secret present)

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: None
**Risk Level**: Low

### Feature 10.4: Drift & CI Cleanup (P1)

#### Stories

##### Story 10.4-001: Correct stale Ollama model messaging in bootstrap output
**User Story**: As FX finishing an install, I want the summary and rebuild phases to name the models actually defined in flake.nix so that post-install verification instructions are trustworthy
**Priority**: Should Have
**Story Points**: 2

**Acceptance Criteria**:
- **Given** `lib/summary.sh:193` and `lib/darwin-rebuild.sh:261` **When** they print expected models **Then** they list the current per-profile set from `flake.nix:116-153` (ministral-3:14b / gemma4:e4b / gemma4:26b / nomic-embed-text) instead of the retired `gpt-oss:20b, qwen2.5-coder:32b, llama3.1:70b, deepseek-r1:32b`
- **Given** the fix **When** `bootstrap-dist.sh` is regenerated **Then** the stale strings no longer appear anywhere in it

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: 10.1-003 (single dist regeneration at the end)
**Risk Level**: Low

##### Story 10.4-002: Put scripts/** under CI and fix workflow path filters
**User Story**: As FX, I want every PR touching shell scripts to get shellcheck and syntax checks so that script regressions can't merge silently
**Priority**: Should Have
**Story Points**: 3

**Acceptance Criteria**:
- **Given** a PR touching only `scripts/**` or `setup.sh` **When** CI runs **Then** `shellcheck` and `bash -n` execute over those files (extend `build-bootstrap.yml` or add a light `scripts-ci` job)
- **Given** `.github/workflows/nix-flake-check.yml:14,25` **When** paths are evaluated **Then** the dead `'Claude'` entry is corrected to `'CLAUDE.md'`
- **Given** `Makefile:31` **When** `make shellcheck` runs **Then** `setup.sh` and `scripts/beszel-sensors/*.sh` are included in scope

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: None
**Risk Level**: Low

##### Story 10.4-003: Flake validation completeness and dead activation-script removal
**User Story**: As FX editing user-config.nix, I want missing required fields to produce the friendly validation error, and I want activation scripts that can never execute removed so that the config is honest about what it does
**Priority**: Should Have
**Story Points**: 3

**Acceptance Criteria**:
- **Given** a user-config missing `notificationEmail` **When** the flake evaluates **Then** the `validateConfig` message lists it (added to `requiredAttrs`, `flake.nix:73-79`) instead of a raw attribute-missing error
- **Given** the never-executed custom activation scripts `xcodeCheck` (`darwin/configuration.nix:242-251`) and `disableHomebrewOllamaService` (`darwin/maintenance.nix:595-605`) **When** the cleanup lands **Then** both are removed (nix-darwin only runs known script names — a pitfall this repo documents 3×)
- **Given** the removal **When** all 3 profiles are evaluated **Then** `make nix-eval` passes

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: None
**Risk Level**: Low

##### Story 10.4-004: Remove the dead requirements-integrity gate and fix doc drift
**User Story**: As FX, I want permanently-red dead gates deleted and headline doc numbers corrected so that the repo's self-description matches reality
**Priority**: Should Have
**Story Points**: 3

**Acceptance Criteria**:
- **Given** `scripts/verify-requirements-integrity.sh` (invoked by nothing, hash permanently mismatched) **When** the cleanup lands **Then** the script, `requirements-integrity.json`, and the reference at `docs/REQUIREMENTS.md:1779` are removed
- **Given** README/docs drift **When** corrected **Then**: `README.md:485` test counts reflect reality (1,282 cases / 37 bats files, 167 in the active gate), `docs/architecture.md` LaunchAgent count/table includes `vitals-sampler`, `virt-vm-orphan-watch`, `privacy-filter`, `README.md:445` names the actual `beszel-sensors/{power,temp,temp_gpu}.sh`, and the 8 stale `mlgruby-repo-for-reference` references (repo not present) are removed or marked historical
- **Given** the changes **When** `docs-lint` CI runs **Then** no broken links are introduced

**Definition of Done**:
- [ ] Code implemented and peer reviewed
- [ ] Tests written and passing
- [ ] Documentation updated

**Dependencies**: None
**Risk Level**: Low

## Out of Scope (deferred — documented in the 2026-07-28 review)
- Phase C simplifications: nix-darwin built-in `nix.gc.automatic`/`nix.optimise.automatic` replacing 3 custom services, `mkScheduledAgent` generalization, ssh/mosh + claude-code.nix symlink dedup, removal of the 9 echo-only verify activation blocks
- Monitoring-stack consolidation (health-api vs Beszel vs vitals-sampler)
- Determinate Nix installer adoption
- Shared logging library across `scripts/`
- Real end-to-end reinstall test (FX-owned, per repo testing policy)
