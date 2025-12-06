# Epic 06: Maintenance & Monitoring

## Epic Overview
**Epic ID**: Epic-06
**Epic Description**: Automated system maintenance including daily garbage collection, Nix store optimization, system monitoring tools installation and configuration, health check commands to validate system state, and email notifications for issues and weekly digests. Ensures the Nix-based system stays healthy, clean, and performant over time with minimal manual intervention.
**Business Value**: Prevents disk bloat from old Nix generations, maintains optimal system performance, provides visibility into system health, proactive notification of issues
**User Impact**: FX gets automated cleanup, easy monitoring, and email alerts without manual maintenance tasks
**Success Metrics**:
- Automated GC runs daily and removes old generations
- Disk space recovered via store optimization
- Health check command reports system status accurately
- Monitoring tools (btop, iStat Menus, macmon) functional
- Email notifications sent when maintenance fails or issues detected
- Weekly digest email summarizes maintenance activity

## Epic Scope
**Total Stories**: 13
**Total Story Points**: 71
**MVP Stories**: 10 (77% of epic - Features 06.1-06.4)
**Priority Level**: Must Have
**Target Release**: Phase 7 (Week 5)

## Features in This Epic


> **Note**: Detailed story implementations have been moved to feature-specific files in `docs/development/stories/` for better maintainability. See links below.

### Feature 06.1: Automated Garbage Collection
**Feature Description**: Implement automated Nix store garbage collection
**Story Count**: 4 | **Story Points**: 19 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-06-feature-06.1.md)**

### Feature 06.2: Store Optimization
**Feature Description**: Implement Nix store optimization and deduplication
**Story Count**: 3 | **Story Points**: 11 | **Priority**: Medium | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-06-feature-06.2.md)**

### Feature 06.3: System Monitoring Tools
**Feature Description**: Install and configure system monitoring tools (gotop, macmon)
**Story Count**: 4 | **Story Points**: 16 | **Priority**: Medium | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-06-feature-06.3.md)**

### Feature 06.4: Health Check Command
**Feature Description**: Create health check command for system validation
**Story Count**: 2 | **Story Points**: 8 | **Priority**: Medium | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-06-feature-06.4.md)**

### Feature 06.5: Email Notification System
**Feature Description**: Email notifications for maintenance failures and weekly digest summaries
**Story Count**: 3 | **Story Points**: 16 | **Priority**: Should Have (P1) | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-06-feature-06.5.md)**

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: Requires nix-darwin installed for launchd agents
- **Epic-02 (Applications)**: Requires btop, iStat Menus, macmon installed
- **Epic-03 (System Config)**: FileVault and firewall checks reference security settings
- **Epic-04 (Dev Environment)**: gc, cleanup, health-check aliases defined
- **Epic-07 (Documentation)**: Licensed apps documentation for iStat Menus

### Stories This Epic Enables
- Epic-07, Story 07.2-001: iStat Menus activation documented
- Epic-07, Story 07.3-001: Health check command usage in troubleshooting

### Stories This Epic Blocks
- None (maintenance is enhancement, not blocker)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 8 | 06.1-001 to 06.4-002 | 55 | Automated maintenance, monitoring tools, health checks |
| Sprint 9 | 06.5-001 to 06.5-003 | 16 | Email notification system |

### Delivery Milestones
- **Milestone 1**: End Sprint 8 - Automated GC and optimization running, monitoring tools configured
- **Milestone 2**: End Sprint 9 - Email notifications functional, weekly digest operational
- **Epic Complete**: Week 6 - All features verified, email notifications tested

### Risk Assessment
**Low Risk Items**:
- All stories use standard nix-darwin patterns and proven tools

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 13 (0%)
- **Story Points Completed**: 0 of 71 (0%)
- **MVP Stories Completed**: 0 of 10 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 8 | 55 | 0 | 0/10 | Not Started |
| Sprint 9 | 16 | 0 | 0/3 | Not Started |

## Epic Acceptance Criteria
- [ ] All MVP stories (10/10) completed and accepted
- [ ] GC LaunchAgent runs daily at 3 AM
- [ ] Store optimization LaunchAgent runs daily at 3:30 AM
- [ ] Manual gc and cleanup aliases work
- [ ] btop, iStat Menus, macmon installed and functional
- [ ] health-check command validates system state
- [ ] All checks in health-check work correctly
- [ ] Actionable recommendations provided for issues
- [ ] VM testing successful
- [ ] Physical hardware testing successful (verify launchd jobs run overnight)

### P1 Acceptance Criteria (Feature 06.5)
- [ ] msmtp configured with Gandi SMTP
- [ ] Credentials stored securely in macOS Keychain
- [ ] Email sent when maintenance jobs fail
- [ ] Weekly digest email sent Sunday 8 AM
- [ ] Manual `weekly-digest` alias works
- [ ] No passwords stored in config files (verified)

## Story Validation Checklist

### Quality Assurance for Each Story
- [ ] Follows proper user story format ("As [persona], I want [functionality] so that [benefit]")
- [ ] Has clear, testable acceptance criteria (Given/When/Then format)
- [ ] Includes all necessary context and constraints
- [ ] Sized appropriately for single sprint
- [ ] Dependencies clearly identified
- [ ] Business value articulated
- [ ] Persona alignment verified (FX as primary user)
- [ ] Technical feasibility confirmed

### Epic Health Metrics
- **Story Readiness**: 100% of stories meet definition of ready
- **Dependency Coverage**: All dependencies identified and managed
- **Estimation Confidence**: High confidence in story point estimates
- **Acceptance Criteria Quality**: Clear, testable, and complete criteria for all stories
