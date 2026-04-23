# ABOUTME: Epic and story progress tracking for the nix-install project
# ABOUTME: Contains epic overview table and current project status

## Epic Overview Progress Table

| Epic ID | Epic Name | Stories | Points | Complete | Status |
|---------|-----------|---------|--------|----------|--------|
| **Epic-01** | Bootstrap & Installation System | 19 | 113 | 100% | ✅ Complete |
| **Epic-02** | Application Installation | 25 | 118 | 100% | ✅ Complete |
| **Epic-03** | System Configuration | 14 | 76 | 100% | ✅ Complete |
| **Epic-04** | Development Environment | 18 | 97 | 100% | ✅ Complete |
| **Epic-05** | Theming & Visual Consistency | 7 | 36 | 100% | ✅ Complete |
| **Epic-06** | Maintenance & Monitoring | 18 | 97 | 100% | ✅ Complete |
| **Epic-07** | Documentation & User Experience | 8 | 34 | 100% | ✅ Complete |
| **Epic-08** | Resource Optimization & Deep Telemetry | 23 | 118 | 96% | 🟢 22/23 Shipped |
| **NFR** | Non-Functional Requirements | 15 | 79 | 87% | 🟢 Nearly Complete |
| **TOTAL** | **All Epics** | **147** | **768** | **98.0%** | 🟢 **v1.0.0 + Epic-08** |

## Project Status

- **Version**: 1.0.0 (released 2025-12-07) + Epic-08 post-v1.0 enhancement (2026-04-21/22)
- **Total Scope**: 147 stories, 768 story points
- **Completed**: 144 stories (98.0%), 758 points (98.7%)
- **Current Phase**: Epic-08 validation (08.3-008 mactop retirement) + ongoing NFR monitoring

### Milestones

| Date | Milestone |
|------|-----------|
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
| Epic-08 | 08.3-008 Retire mactop habit | 1 | P1 | Acceptance-only validation (one day mactop-free) |
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

### Development Effort (as of 2026-04-22)

| Metric | Value |
|--------|-------|
| Total commits | 735 (+218 since v1.0.0) |
| GitHub issues | Epic-08 issues #236–#258 + follow-up fixes #269–#285 |
| Active development days | ~20 (v1.0.0 arc) + 2 days (Epic-08 arc) |
| Project timespan | 2025-11-08 to 2026-04-22 |
| **Estimated active hours** | **~78h (v1.0.0) + ~18h (Epic-08) = ~96h** |
| Issue completion rate | 83.3% (v1.0.0) / 96% (Epic-08) |

## Story Details

For detailed story information, see the epic files:

- [Epic-01: Bootstrap & Installation](stories/epic-01-bootstrap.md)
- [Epic-02: Application Installation](stories/epic-02-*.md)
- [Epic-03: System Configuration](stories/epic-03-*.md)
- [Epic-04: Development Environment](stories/epic-04-*.md)
- [Epic-05: Theming](stories/epic-05-*.md)
- [Epic-06: Maintenance](stories/epic-06-*.md)
- [Epic-07: Documentation](stories/epic-07-*.md)
- [NFR: Non-Functional Requirements](stories/non-functional-requirements.md)

## Change History

For detailed change history, see [CHANGELOG.md](../../CHANGELOG.md).
