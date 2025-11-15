# Epic 02: Application Installation

## Epic Overview
**Epic ID**: Epic-02
**Epic Description**: Comprehensive installation and configuration of all applications across both Standard and Power profiles using Nix, Homebrew Casks, and Mac App Store (mas). Implements profile-based differentiation (Parallels and Ollama models for Power only), ensures all GUI apps are properly themed, and disables auto-updates to enforce controlled update philosophy where only `rebuild` and `update` commands manage app versions.
**Business Value**: Provides complete application ecosystem for development, productivity, and communication workflows with zero manual installation
**User Impact**: FX gets all required tools installed automatically, correctly themed, and ready to use within the bootstrap process
**Success Metrics**:
- All 47+ apps installed successfully on Standard profile
- All 51+ apps installed successfully on Power profile (includes Parallels and extra Ollama models)
- 100% of apps launch without errors
- Auto-updates disabled for all apps that support it
- Licensed apps documented with clear activation instructions
- Email accounts (1 Gmail, 4 Gandi.net) configured and functional in macOS Mail.app

## Epic Scope
**Total Stories**: 25
**Total Story Points**: 118
**Completed Stories**: 9 (36.0%)
**Completed Points**: 47 (39.8%)
**MVP Stories**: 25 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 2-3 (Week 2-3)

## Features in This Epic


> **Note**: Detailed story implementations have been moved to feature-specific files in `docs/development/stories/` for better maintainability. See links below.

### Feature 02.1: AI & LLM Tools Installation ✅ COMPLETE
**Feature Description**: Install and configure AI/LLM applications and models
**Story Count**: 4 (4/4 complete) | **Story Points**: 16 (16/16 complete) | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-02-feature-02.1.md)**

### Feature 02.2: Development Environment Applications 🔄 In Progress (5/6)
**Feature Description**: Install Zed, VSCode, Ghostty, Python, Podman, and Claude Code CLI with MCP servers
**Story Count**: 6 (5/6 complete) | **Story Points**: 39 (31/39 complete) | **Priority**: High | **Complexity**: High
👉 **[View detailed implementation](../docs/development/stories/epic-02-feature-02.2.md)**

### Feature 02.3: Browsers
**Feature Description**: Install web browsers (Brave, Arc, Firefox, Safari configuration)
**Story Count**: 2 | **Story Points**: 8 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-02-feature-02.3.md)**

### Feature 02.4: Productivity & Utilities
**Feature Description**: Install productivity apps (Raycast, Dropbox, 1Password, etc.)
**Story Count**: 7 | **Story Points**: 31 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-02-feature-02.4.md)**

### Feature 02.5: Communication Tools
**Feature Description**: Install communication apps (Zoom, Webex, Slack, Teams, WhatsApp)
**Story Count**: 1 | **Story Points**: 3 | **Priority**: Medium | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-02-feature-02.5.md)**

### Feature 02.6: Media & Creative Tools
**Feature Description**: Install media and creative tools (QuickTime, Preview)
**Story Count**: 1 | **Story Points**: 2 | **Priority**: Medium | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-02-feature-02.6.md)**

### Feature 02.7: Security & VPN
**Feature Description**: Install security and VPN tools (Proton VPN)
**Story Count**: 1 | **Story Points**: 3 | **Priority**: Medium | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-02-feature-02.7.md)**

### Feature 02.8: Profile-Specific Applications
**Feature Description**: Install profile-specific apps (Parallels for Power profile)
**Story Count**: 1 | **Story Points**: 5 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-02-feature-02.8.md)**

### Feature 02.9: Office 365 (Homebrew Cask Installation)
**Feature Description**: Install Office 365 via Homebrew Cask with license activation
**Story Count**: 1 | **Story Points**: 3 | **Priority**: High | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-02-feature-02.9.md)**

### Feature 02.10: Email Account Configuration
**Feature Description**: Configure email accounts in macOS Mail.app (5 accounts: 1 Gmail, 4 Gandi.net)
**Story Count**: 1 | **Story Points**: 5 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-02-feature-02.10.md)**

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: All application installation depends on bootstrap completing (Nix, nix-darwin, Homebrew installed)
- **Epic-05 (Theming)**: Zed and Ghostty theming depends on Stylix configuration
- **Epic-07 (Documentation)**: Licensed app activation guide needed for post-install

### Stories This Epic Enables
- Epic-04, Story 04.X-XXX: Development workflow stories (depends on dev tools installed)
- Epic-05, Story 05.1-XXX: Theming stories (Zed and Ghostty theming)
- Epic-07, Story 07.2-001: Licensed apps documentation

### Stories This Epic Blocks
- Epic-04 development workflow stories (needs Python, Podman, Git installed)
- Epic-06 health check stories (needs btop, monitoring tools)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 3 | 02.1-001 to 02.4-007 | 93 | AI tools, dev environment (inc. Claude Code + MCP), browsers, productivity apps, utilities |
| Sprint 4 | 02.5-001 to 02.10-001 | 33 | Communication tools, media apps, security, Parallels, Office 365, email accounts |

### Delivery Milestones
- **Milestone 1**: End Sprint 3 - Core apps installed (AI, dev tools, browsers, productivity)
- **Milestone 2**: End Sprint 4 - All apps installed, licensed apps documented
- **Epic Complete**: Week 3 - All apps functional, both profiles tested

### Risk Assessment
**High Risk Items**:
- Story 02.1-004 (Power Ollama models): Large downloads (80GB), network-dependent, long duration
  - Mitigation: Progress indicators, retry logic, document expected time
- Story 02.2-005 (Podman): Machine initialization may fail or require manual intervention
  - Mitigation: Clear documentation, troubleshooting steps, health check validation

**Medium Risk Items**:
- Story 02.8-001 (Parallels): Profile-specific installation must work correctly, license required
  - Mitigation: Test both profiles in VM, document license activation clearly

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 9 of 25 (36.0%)
- **Story Points Completed**: 47 of 118 (39.8%)
- **MVP Stories Completed**: 9 of 25 (36.0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 3 | 85 | 47 | 9/17 | In Progress |
| Sprint 4 | 33 | 0 | 0/8 | Not Started |

### Recently Completed Stories
- ✅ **Story 02.1-001**: Claude Desktop and AI Chat Apps (3 points) - VM tested 2025-11-12
- ✅ **Story 02.1-002**: Ollama Desktop App Installation (3 points) - VM tested 2025-11-12
- ✅ **Story 02.1-003**: Standard Profile Ollama Model (2 points) - VM tested 2025-11-12
- ✅ **Story 02.1-004**: Power Profile Additional Ollama Models (8 points) - VM tested 2025-11-12
- ✅ **Story 02.2-001**: Zed Editor Installation and Configuration (12 points) - VM tested 2025-11-12
- ✅ **Story 02.2-002**: VSCode with Auto Dark Mode (3 points) - VM tested 2025-11-12
- ✅ **Story 02.2-003**: Ghostty Terminal Installation (5 points) - VM tested 2025-11-12
- ✅ **Story 02.2-004**: Python and Development Tools (5 points) - VM tested 2025-11-12
- ✅ **Story 02.2-005**: Podman and Container Tools (6 points) - VM tested 2025-11-15

## Epic Acceptance Criteria
- [ ] All MVP stories (25/25) completed and accepted
- [ ] All apps launch successfully on both profiles
- [ ] Profile differentiation verified (Parallels and Ollama models on Power only)
- [ ] Auto-updates disabled for all apps that support it
- [ ] Licensed apps documented with activation instructions
- [ ] All dev tools functional (Python, Podman, Git, editors, Claude Code CLI)
- [ ] Claude Code CLI with MCP servers (Context7, GitHub) configured and functional
- [ ] Browsers installed and configured
- [ ] Communication tools working
- [ ] Media apps functional
- [ ] Monitoring tools installed and reporting
- [ ] Email accounts configured in macOS Mail.app (5 accounts: 1 Gmail, 4 Gandi.net)
- [ ] Email accounts functional after credential entry
- [ ] VM testing successful for both profiles
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
