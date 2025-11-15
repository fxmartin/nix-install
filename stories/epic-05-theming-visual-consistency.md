# Epic 05: Theming & Visual Consistency

## Epic Overview
**Epic ID**: Epic-05
**Epic Description**: System-wide theming using Stylix to ensure visual consistency across Ghostty terminal, Zed editor, shell, and other supported applications. Implements Catppuccin color scheme (Latte for light mode, Mocha for dark mode) with automatic switching based on macOS system appearance, JetBrains Mono Nerd Font with ligatures across all tools, and cohesive visual experience when switching between terminal and editor.
**Business Value**: Creates a polished, professional appearance with zero manual theme configuration
**User Impact**: Beautiful, consistent interface across all development tools that adapts to ambient lighting automatically
**Success Metrics**:
- Visual consistency: Same Catppuccin theme across Ghostty and Zed
- Font consistency: JetBrains Mono in terminal and editors
- Auto-switching: Theme changes with macOS system appearance
- Ligature support: Programming ligatures render correctly

## Epic Scope
**Total Stories**: 8
**Total Story Points**: 42
**MVP Stories**: 8 (100% of epic)
**Priority Level**: Must Have
**Target Release**: Phase 6 (Week 5)

## Features in This Epic


> **Note**: Detailed story implementations have been moved to feature-specific files in `docs/development/stories/` for better maintainability. See links below.

### Feature 05.1: Stylix System Configuration
**Feature Description**: Configure Stylix for system-wide theming with Catppuccin
**Story Count**: 3 | **Story Points**: 13 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-05-feature-05.1.md)**

### Feature 05.2: Font Configuration
**Feature Description**: Configure JetBrains Mono Nerd Font system-wide
**Story Count**: 2 | **Story Points**: 8 | **Priority**: High | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-05-feature-05.2.md)**

### Feature 05.3: Application-Specific Theming
**Feature Description**: Configure app-specific theming for Ghostty and Zed
**Story Count**: 3 | **Story Points**: 11 | **Priority**: High | **Complexity**: Medium
👉 **[View detailed implementation](../docs/development/stories/epic-05-feature-05.3.md)**

### Feature 05.4: Theme Verification and Testing
**Feature Description**: Verify theme consistency across all applications
**Story Count**: 1 | **Story Points**: 3 | **Priority**: Medium | **Complexity**: Low
👉 **[View detailed implementation](../docs/development/stories/epic-05-feature-05.4.md)**

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: Requires nix-darwin and Home Manager installed
- **Epic-02 (Applications)**: Requires Ghostty, Zed installed
- **Epic-03 (System Config)**: Auto appearance setting in macOS
- **Epic-04 (Dev Environment)**: Ghostty and Zed configs defined

### Stories This Epic Enables
- Epic-04, Story 04.4-001: Ghostty config integrated with theming
- Epic-04, Story 04.9-001: Zed theming via Stylix
- Epic-07 (Documentation): Theme customization documented

### Stories This Epic Blocks
- None (theming is enhancement, not blocker)

## Epic Delivery Planning

### Sprint Breakdown
| Sprint | Stories | Story Points | Sprint Goal |
|--------|---------|--------------|-------------|
| Sprint 7 | 05.1-001 to 05.4-002 | 42 | Complete Stylix theming with Catppuccin and JetBrains Mono |

### Delivery Milestones
- **Milestone 1**: End Sprint 7 - Stylix configured, all apps themed
- **Epic Complete**: Week 5 - Visual consistency verified, auto-switching tested

### Risk Assessment
**Medium Risk Items**:
- Story 05.1-001 (Stylix installation): macOS/nix-darwin support may vary
  - Mitigation: Check Stylix docs, fallback to manual theming if needed
- Story 05.1-002 (Auto light/dark): Stylix may not support macOS appearance detection
  - Mitigation: Manual scripts or configs if auto-detection unavailable
- Story 05.3-002 (Zed theming): Stylix may not support Zed natively
  - Mitigation: Manual Catppuccin theme installation in Zed

**Low Risk Items**:
- Font installation and configuration (proven Nix patterns)
- Visual testing (manual verification)

## Epic Progress Tracking

### Completion Status
- **Stories Completed**: 0 of 8 (0%)
- **Story Points Completed**: 0 of 42 (0%)
- **MVP Stories Completed**: 0 of 8 (0%)

### Sprint Progress
| Sprint | Planned Points | Completed Points | Stories Done | Status |
|--------|----------------|------------------|--------------|--------|
| Sprint 7 | 42 | 0 | 0/8 | Not Started |

## Epic Acceptance Criteria
- [ ] All MVP stories (8/8) completed and accepted
- [ ] Stylix configured with Catppuccin base16 scheme
- [ ] JetBrains Mono Nerd Font installed and applied
- [ ] Ghostty themed with Catppuccin (Latte/Mocha)
- [ ] Zed themed with Catppuccin (Latte/Mocha)
- [ ] Visual consistency verified (colors and fonts match)
- [ ] Auto light/dark mode switching works
- [ ] Ligatures render correctly in terminal and editor
- [ ] Both light and dark themes are readable and professional
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
- **Estimation Confidence**: Medium-high confidence (Stylix macOS support is unknown)
- **Acceptance Criteria Quality**: Clear, testable, and complete criteria for all stories
