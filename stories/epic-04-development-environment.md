# Epic 04: Development Environment & Shell Configuration

## Epic Overview
**Epic ID**: Epic-04
**Epic Description**: Complete shell and development environment setup including Zsh with Oh My Zsh, Starship prompt, FZF integration, Ghostty terminal configuration, useful shell aliases, Git configuration with LFS, Python 3.12 with uv and dev tools, Podman container environment, and editor configuration (Zed and VSCode). Creates a polished, efficient development workflow with consistent theming and fast startup times.
**Business Value**: Provides FX with a complete, optimized development environment for Python development, containerized applications, and version control workflows
**User Impact**: Terminal, shell, and editors are fast, beautiful, and productive from day one with zero manual configuration
**Success Metrics**:
- Shell startup time <500ms
- All dev tools (Python, Podman, Git) functional and accessible
- Aliases and shortcuts work in fresh terminal
- Zed and Ghostty themed consistently with Catppuccin
- FZF keybindings operational (Ctrl+R, Ctrl+T, Alt+C)

## Epic Scope
**Total Stories**: 18
**Total Story Points**: 97
**MVP Stories**: 18 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 4-5 (Week 4)

## Features in This Epic


> **Note**: Detailed story implementations have been moved to feature-specific files in `docs/development/stories/` for better maintainability. See links below.

### Feature 04.1: Zsh and Oh My Zsh Configuration
**Feature Description**: Configure Zsh with Oh My Zsh framework and plugins
**Story Count**: 3 | **Story Points**: 17 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-04-feature-04.1.md)**

### Feature 04.2: Starship Prompt Configuration
**Feature Description**: Configure Starship cross-shell prompt
**Story Count**: 1 | **Story Points**: 3 | **Priority**: Medium | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-04-feature-04.2.md)**

### Feature 04.3: FZF Fuzzy Finder Integration
**Feature Description**: Integrate FZF for command history, file search, and directory navigation
**Story Count**: 1 | **Story Points**: 3 | **Priority**: Medium | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-04-feature-04.3.md)**

### Feature 04.4: Ghostty Terminal Configuration
**Feature Description**: Configure Ghostty terminal emulator with Catppuccin theme
**Story Count**: 1 | **Story Points**: 3 | **Priority**: High | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-04-feature-04.4.md)**

### Feature 04.5: Shell Aliases and Functions
**Feature Description**: Configure shell aliases and custom functions
**Story Count**: 3 | **Story Points**: 11 | **Priority**: Medium | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-04-feature-04.5.md)**

### Feature 04.6: Git Configuration
**Feature Description**: Configure Git with FX's identity, aliases, and preferences
**Story Count**: 4 | **Story Points**: 17 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-04-feature-04.6.md)**

### Feature 04.7: Python Development Environment
**Feature Description**: Configure Python 3.12 and uv package manager
**Story Count**: 2 | **Story Points**: 8 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-04-feature-04.7.md)**

### Feature 04.8: Container Development Environment
**Feature Description**: Configure Podman container environment
**Story Count**: 2 | **Story Points**: 8 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-04-feature-04.8.md)**

### Feature 04.9: Editor Configuration
**Feature Description**: Configure editors (Zed, VSCode) via Home Manager
**Story Count**: 2 | **Story Points**: 8 | **Priority**: Medium | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-04-feature-04.9.md)**

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: All shell/dev environment depends on nix-darwin and Home Manager
- **Epic-02 (Applications)**: Requires Python, Podman, Git, Zed, VSCode, Ghostty installed
- **Epic-05 (Theming)**: Stylix theming for Zed, Ghostty, and visual consistency
- **Epic-06 (Maintenance)**: health-check alias references Epic-06 scripts
- **Epic-07 (Documentation)**: Editor extensions and customization documentation

### Stories This Epic Enables
- Epic-05, Story 05.1-001: Stylix theming applies to shell and editors configured here
- Epic-06, Story 06.4-001: Health check uses aliases defined here
- Epic-07, Story 07.4-001: Customization guide documents shell and editor config

### Stories This Epic Blocks
- None (development environment is foundational but doesn't block other epics)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 5 | 04.1-001 to 04.8-002 | 82 | Shell, prompt, FZF, aliases, Git, Python, Podman |
| Sprint 6 | 04.9-001 to 04.9-003 | 15 | Editor configuration and documentation |

### Delivery Milestones
- **Milestone 1**: End Sprint 5 - Shell and dev tools fully configured
- **Milestone 2**: End Sprint 6 - Editors themed and documented
- **Epic Complete**: Week 4 - Complete development environment tested in VM and hardware

### Risk Assessment
**Medium Risk Items**:
- Story 04.8-001 (Podman machine init): May require manual initialization, complex to automate
  - Mitigation: Document manual steps, provide troubleshooting, test in VM thoroughly

**Low Risk Items**:
- Most stories use proven Home Manager patterns with low failure risk

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 18 (0%)
- **Story Points Completed**: 0 of 97 (0%)
- **MVP Stories Completed**: 0 of 18 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 5 | 82 | 0 | 0/15 | Not Started |
| Sprint 6 | 15 | 0 | 0/3 | Not Started |

## Epic Acceptance Criteria
- [ ] All MVP stories (18/18) completed and accepted
- [ ] Shell startup time <500ms
- [ ] All dev tools (Python, Podman, Git) functional
- [ ] Aliases work in fresh terminal (rebuild, update, gc, cleanup, ll, etc.)
- [ ] Zed and Ghostty themed consistently with Catppuccin
- [ ] FZF keybindings operational (Ctrl+R, Ctrl+T, Alt+C)
- [ ] Git config includes user info, LFS, SSH
- [ ] Python and uv ready for project work
- [ ] Podman machine initialized and running
- [ ] Editors (Zed, VSCode) configured and themed
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
