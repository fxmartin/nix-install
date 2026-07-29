# ABOUTME: Epic and story progress tracking for the nix-install project
# ABOUTME: Contains epic overview table and current project status

## Epic Overview Progress Table

| Epic ID | Epic Name | Stories | Points | Complete | Status |
|---------|-----------|---------|--------|----------|--------|
| **Epic-01** | Bootstrap & Installation System | 19 | 113 | 100% | ✅ Complete |
| **Epic-02** | Application Installation | 25 | 118 | 100% | ✅ Complete |
| **Epic-03** | System Configuration | 14 | 76 | 100% | ✅ Complete |
| **Epic-04** | Development Environment | 19 | 105 | 100% | ✅ Complete |
| **Epic-05** | Theming & Visual Consistency | 7 | 36 | 100% | ✅ Complete |
| **Epic-06** | Maintenance & Monitoring | 18 | 97 | 100% | ✅ Complete |
| **Epic-07** | Documentation & User Experience | 8 | 34 | 100% | ✅ Complete |
| **Epic-08** | Resource Optimization & Deep Telemetry | 23 | 118 | 96% | 🟢 22/23 Shipped |
| **Epic-09** | Local PII Redaction (MLX Privacy Filter) | 8 committed | TBD | 88% | 🟢 7/8 Shipped |
| **Epic-10** | Bootstrap Integrity & Security Hardening | 13 | 38 | 100% | ✅ Complete |
| **NFR** | Non-Functional Requirements | 15 | 79 | 87% | 🟢 Nearly Complete |
| **TOTAL** | **All Epics** | **169** | **814** | **98.2%** | 🟢 **Epic-10 shipped, unreleased** |

Epic-09 counts only Feature 09.1 (the committed foundation). Features 09.2/09.3/09.4
add 11 proposed stories that are unestimated and pending a scope decision — see
[#303](https://github.com/fxmartin/nix-install/issues/303). Epic-09 carries no points,
so it is excluded from the points column of the total.

## Project Status

- **Version**: 2.0.33 released; `main` carries 24 unreleased commits (all of Epic-10) awaiting a `v2.1.0` tag
- **Total Scope**: 169 stories, 814 story points (Epic-09 unestimated)
- **Completed**: 166 stories (98.2%), 810 points (99.5%)
- **Current Phase**: cut the Epic-10 release; then decide Epic-09 Features 09.2/09.3/09.4 scope

### Milestones

| Date | Milestone |
|------|-----------|
| 2026-07-28 | 🎉 **Epic-10 Bootstrap Integrity & Security Hardening** - 13/13 stories; clone-first tag-pinned bootstrap fixes the broken fresh install, all P0 security findings closed (SDLC run `a7493b3d`) |
| 2026-05-07 | 🎉 **Epic-09 Feature 09.1** - MLX Privacy Filter daemon on `127.0.0.1:7790` with `redact` / `redact-clip`, merged to `main` (7/8 stories) |
| 2026-04-22 | 🎉 **Epic-08 SketchyBar Deep Telemetry** - `/metrics` aggregator, per-cluster CPU, GPU+ANE, power/temp, vitals popup (Sprint 13) |
| 2026-04-21 | 🎉 **Epic-08 Memory & Observability** - Ollama pressure guard, swap alerting, top-5 processes, Beszel custom sensors (Sprints 12 & 14) |
| 2026-04-21 | 🎉 **Epic-08 Disk Optimization** - System GC daemon, HF/browser/Docker pruning, pre-rebuild guard, growth telemetry (Sprint 11) |
| 2026-01-15 | 🎉 **MacBook Pro M1 (2021) Deployed** - AI-Assistant profile, second machine running |
| 2025-12-07 | 🎉 **Epic-01 Complete** - Story 01.1-004 Modular Bootstrap Architecture implemented |
| 2025-12-07 | 🎉 **v1.0.0 Released** - MacBook Pro M3 Max running Power profile |
| 2025-12-06 | Epic-07 Documentation Complete |
| 2025-12-06 | Epic-06 Maintenance & Monitoring Complete |
| 2025-12-06 | Epic-05 Theming Complete |
| 2025-12-05 | Epic-04 Development Environment Complete |
| 2025-12-05 | Epic-03 System Configuration Complete |
| 2025-11-17 | Epic-02 Application Installation Complete |
| 2025-11-11 | Epic-01 Bootstrap Functional |

### Remaining Work

| Epic | Story | Points | Priority | Notes |
|------|-------|--------|----------|-------|
| Release | Tag `v2.1.0` for Epic-10 | — | P0 | 24 unreleased commits on `main`; `make bump-minor` → `release-tag` → `smoke-test-clone` |
| Epic-09 | 09.1-008 Verify daemon on first Mac | — | P1 | Confirm `OPENMED_PII_MODEL` name + `/pii/deidentify` schema ([#302](https://github.com/fxmartin/nix-install/issues/302)) |
| Epic-09 | Features 09.2 / 09.3 / 09.4 | — | P2 | 11 proposed stories — promote or drop ([#303](https://github.com/fxmartin/nix-install/issues/303)) |
| Epic-08 | 08.3-008 Retire mactop habit | 1 | P1 | Acceptance-only validation (one day mactop-free) |
| Epic-08 | 4 optional enhancements | 21 | P2 | [#286](https://github.com/fxmartin/nix-install/issues/286) (blocked upstream), [#287](https://github.com/fxmartin/nix-install/issues/287), [#288](https://github.com/fxmartin/nix-install/issues/288), [#289](https://github.com/fxmartin/nix-install/issues/289) |
| Epic-06 | ~45 release-monitor bumps | — | P2 | Mostly mechanical; 3 breaking (#296, #311, #339) and Chrome 150 security (#330) need judgement |
| NFR | 1-week auto-update verification | 5 | P1 | Monitoring period |
| NFR | MacBook Air M4 cross-machine test | 3 | P0 | Phase 11, not yet deployed |

### Performance Metrics (MacBook Pro M3 Max)

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Shell startup | <500ms | 259ms | ✅ |
| Rebuild time | <5min | 14s | ✅ |
| Bootstrap (clean) | <30min | ~25min | ✅ |
| `/metrics` p95 latency (post Epic-08 Sprint 14) | <2s | sub-second (macmon on background thread) | ✅ |
| System generation count (Power, post 08.1-001) | <20 | <20 after first Sunday 04:00 cycle | ✅ |
| Ollama keep-alive (Power) | profile-tuned | 5m / `OLLAMA_MAX_LOADED_MODELS=1` | ✅ |

### Development Effort (as of 2026-07-29)

| Metric | Value |
|--------|-------|
| Total commits | 932 (+415 since v1.0.0) |
| GitHub issues | Epic-08 #236–#258 + fixes #269–#285; Epic-09 #302–#303; Epic-10 #388–#400 |
| Active development days | ~20 (v1.0.0 arc) + 2 (Epic-08) + Epic-09/Epic-10 not yet estimated |
| Project timespan | 2025-11-08 to 2026-07-29 |
| **Estimated active hours** | **~96h through Epic-08; Epic-09/Epic-10 not yet estimated** |
| Issue completion rate | 83.3% (v1.0.0) / 96% (Epic-08) / 100% (Epic-10) |

Hours for the Epic-09 and Epic-10 arcs still need a pass with
`/project:update-estimated-time-spent`.

## Story Details

For detailed story information, see the epic files:

Paths are relative to the repo root.

- [Epic-01: Bootstrap & Installation](../../stories/epic-01-bootstrap-installation.md)
- [Epic-02: Application Installation](../../stories/epic-02-application-installation.md)
- [Epic-03: System Configuration](../../stories/epic-03-system-configuration.md)
- [Epic-04: Development Environment](../../stories/epic-04-development-environment.md)
- [Epic-05: Theming](../../stories/epic-05-theming-visual-consistency.md)
- [Epic-06: Maintenance](../../stories/epic-06-maintenance-monitoring.md)
- [Epic-07: Documentation](../../stories/epic-07-documentation-user-experience.md)
- [Epic-08: Resource Optimization](../../stories/epic-08-resource-optimization.md)
- Epic-09: Local PII Redaction — no story file yet (Story 09.4-001); scope lives in [#303](https://github.com/fxmartin/nix-install/issues/303)
- [Epic-10: Bootstrap Integrity & Security](../../stories/epic-10-bootstrap-integrity-security.md)
- [NFR: Non-Functional Requirements](../../stories/non-functional-requirements.md)

## Change History

For detailed change history, see [CHANGELOG.md](../../CHANGELOG.md).
