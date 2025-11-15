# Epic 03: System Configuration

## Epic Overview
**Epic ID**: Epic-03
**Epic Description**: Automated configuration of macOS system preferences and settings using nix-darwin's `system.defaults` module and `defaults write` commands. Covers Finder preferences, security settings, trackpad/input configuration, display/appearance, keyboard/text settings, and Dock customization to match the Mac-setup repository preferences exactly.
**Business Value**: Eliminates 30+ minutes of manual system preference clicking, ensures consistency across all machines, prevents forgotten security settings
**User Impact**: FX gets a fully configured macOS system with all preferences set automatically during bootstrap, matching familiar Mac-setup configuration
**Success Metrics**:
- All system preferences automated (>90% coverage)
- Zero manual System Preferences clicks required (except FileVault confirmation)
- Settings identical across same-profile machines
- Settings persist across macOS updates and rebuilds

## Epic Scope
**Total Stories**: 12
**Total Story Points**: 68
**MVP Stories**: 12 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 3 (Week 3)

## Features in This Epic


> **Note**: Detailed story implementations have been moved to feature-specific files in `docs/development/stories/` for better maintainability. See links below.

### Feature 03.1: Finder Configuration
**Feature Description**: Configure Finder preferences (sidebar, view options, search defaults)
**Story Count**: 4 | **Story Points**: 19 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-03-feature-03.1.md)**

### Feature 03.2: Security Configuration
**Feature Description**: Configure macOS security settings (Gatekeeper, FileVault, Firewall)
**Story Count**: 4 | **Story Points**: 16 | **Priority**: High | **Complexity**: High
👉 **[View detailed implementation](../docs/development/stories/epic-03-feature-03.2.md)**

### Feature 03.3: Trackpad and Input Configuration
**Feature Description**: Configure trackpad gestures and input device preferences
**Story Count**: 3 | **Story Points**: 11 | **Priority**: Medium | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-03-feature-03.3.md)**

### Feature 03.4: Display and Appearance
**Feature Description**: Configure display settings and menu bar
**Story Count**: 3 | **Story Points**: 11 | **Priority**: Medium | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-03-feature-03.4.md)**

### Feature 03.5: Keyboard and Text Input
**Feature Description**: Configure keyboard shortcuts and text input preferences
**Story Count**: 2 | **Story Points**: 8 | **Priority**: Low | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-03-feature-03.5.md)**

### Feature 03.6: Dock Configuration
**Feature Description**: Configure Dock appearance and behavior
**Story Count**: 1 | **Story Points**: 3 | **Priority**: Medium | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-03-feature-03.6.md)**

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: All system configuration depends on nix-darwin installed
- **Epic-05 (Theming)**: Display appearance settings interact with Stylix theming
- **Epic-06 (Maintenance)**: FileVault and security settings verified in health-check
- **Epic-07 (Documentation)**: Finder sidebar customization documented, FileVault instructions

### Stories This Epic Enables
- Epic-05, Story 05.1-001: Display appearance settings support Stylix auto-switching
- Epic-06, Story 06.4-001: Health check validates security settings (FileVault, firewall)
- Epic-07, Story 07.4-001: Customization guide documents manual steps (sidebar, Dock apps)

### Stories This Epic Blocks
- None (system configuration is independent)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 4 | 03.1-001 to 03.6-001 | 68 | All macOS system preferences automated |

### Delivery Milestones
- **Milestone 1**: End Sprint 4 - All system preferences configured
- **Epic Complete**: Week 3 - Settings verified on both profiles in VM and hardware

### Risk Assessment
**Medium Risk Items**:
- Story 03.2-002 (FileVault): Cannot automate, requires clear user prompt and documentation
  - Mitigation: Clear instructions, health-check validation, document recovery key storage
- Story 03.3-001 (Three-finger drag): Accessibility feature, may require additional settings or manual step
  - Mitigation: Test on physical hardware, provide manual instructions if automation fails

**Low Risk Items**:
- Most other stories use standard system.defaults module with low failure risk

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 12 (0%)
- **Story Points Completed**: 0 of 68 (0%)
- **MVP Stories Completed**: 0 of 12 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 4 | 68 | 0 | 0/12 | Not Started |

## Epic Acceptance Criteria
- [ ] All MVP stories (12/12) completed and accepted
- [ ] All system preferences automated (>90% coverage)
- [ ] Zero manual System Settings clicks required (except FileVault and manual customizations)
- [ ] Settings identical across same-profile machines
- [ ] Settings persist across macOS updates and rebuilds
- [ ] FileVault prompt clear and actionable
- [ ] Three-finger drag works on physical hardware
- [ ] Keyboard optimized for coding (no auto-corrections)
- [ ] Security settings enforced (firewall, screen lock, Touch ID sudo)
- [ ] VM testing successful
- [ ] Physical hardware testing successful

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
