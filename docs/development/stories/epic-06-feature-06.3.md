# ABOUTME: Epic-06 Feature 06.3 (System Monitoring Tools) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 06.3

# Epic-06 Feature 06.3: System Monitoring Tools

## Feature Overview

**Feature ID**: Feature 06.3
**Feature Name**: System Monitoring Tools
**Epic**: Epic-06
**Status**: 🔄 In Progress

- **When** I run `btop`
- **Then** it shows interactive system monitor
- **And** displays CPU usage per core
- **And** displays memory usage (RAM and swap)
- **And** displays disk I/O
- **And** displays network traffic
- **And** displays running processes
- **And** theme matches Catppuccin (if configurable)

**Additional Requirements**:
- btop via Nix (not Homebrew)
- Interactive: Real-time updates
- Themed: Catppuccin colors if possible
- Keybindings: Standard btop controls

**Technical Notes**:
- btop already installed in Epic-02, Story 02.4-006
- btop config: ~/.config/btop/btop.conf
- May use Stylix for theming or manual config:
  ```nix
  xdg.configFile."btop/btop.conf".text = ''
    color_theme = "catppuccin-mocha"
    # ... other btop settings
  '';
  ```
- Verify: Run `btop`, check display and theme
- Test: Navigate with arrow keys, check process list

**Definition of Done**:
- [ ] btop accessible via command
- [ ] Shows CPU, memory, disk, network, processes
- [ ] Theme is Catppuccin (if configurable)
- [ ] Interactive controls work
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.4-006 (btop installed)
- Epic-05 (Stylix theming, optional)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 06.3-002: iStat Menus Menubar Monitor
**User Story**: As FX, I want iStat Menus installed and configured so that I can see system stats in the menubar at a glance

**Priority**: Must Have
**Story Points**: 5
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch iStat Menus
- **Then** it prompts for license activation
- **And** after activation, menubar icons appear
- **And** I can see CPU usage in menubar
- **And** I can see memory usage in menubar
- **And** I can see network traffic in menubar (optional)
- **And** auto-update is disabled
- **And** app is marked as requiring license activation

**Additional Requirements**:
- iStat Menus via Homebrew Cask (from Epic-02)
- Licensed app: Requires activation
- Menubar stats: CPU, memory, network, disk (configurable)
- Auto-update disabled

**Technical Notes**:
- iStat Menus already installed in Epic-02, Story 02.4-006
- License: Trial or paid license required (document in licensed-apps.md)
- Auto-update: Preferences → General → Disable auto-update
- Configuration: User chooses which stats to display
- Document in licensed-apps.md activation process

**Definition of Done**:
- [ ] iStat Menus installed (from Epic-02)
- [ ] License activation documented
- [ ] Menubar icons appear after activation
- [ ] Auto-update disable documented
- [ ] Marked as licensed app
- [ ] Tested in VM (license prompt visible)

**Dependencies**:
- Epic-02, Story 02.4-006 (iStat Menus installed)
- Epic-07, Story 07.2-001 (Licensed apps documentation)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

##### Story 06.3-003: macmon GUI Monitor
**User Story**: As FX, I want macmon installed so that I have a GUI monitoring tool alternative

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I launch macmon
- **Then** it opens and shows system monitoring dashboard
- **And** displays CPU, memory, disk, network stats
- **And** provides detailed graphs and metrics
- **And** app is accessible from Spotlight/Raycast

**Additional Requirements**:
- macmon via Homebrew Cask (from Epic-02)
- GUI dashboard: Visual monitoring
- Detailed metrics: More info than menubar icons
- Free app: No license required

**Technical Notes**:
- macmon already installed in Epic-02, Story 02.4-006
- Verify: Launch macmon from /Applications
- Test: Check dashboard displays stats correctly
- Compare with btop and iStat Menus (three monitoring options)

**Definition of Done**:
- [ ] macmon installed (from Epic-02)
- [ ] Launches successfully
- [ ] Dashboard shows system stats
- [ ] Provides detailed metrics
- [ ] Tested in VM

**Dependencies**:
- Epic-02, Story 02.4-006 (macmon installed)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

### Feature 06.4: Health Check Command
**Feature Description**: Create health-check script to validate system state
**User Value**: Quick diagnosis of system health with actionable feedback
**Story Count**: 2
**Story Points**: 9
**Priority**: High
**Complexity**: Medium

#### Stories in This Feature

##### Story 06.4-001: Health Check Script Implementation
**User Story**: As FX, I want a `health-check` command that validates my system so that I can quickly diagnose issues

**Priority**: Must Have
**Story Points**: 8
**Sprint**: Sprint 8

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** I run `health-check`
- **Then** it checks Nix daemon status
- **And** checks Homebrew health (`brew doctor`)
- **And** checks disk space on /nix and home
- **And** checks FileVault status
- **And** checks firewall status
- **And** checks generation count
- **And** displays clear ✅/⚠️/❌ status for each check
- **And** provides actionable recommendations for issues

**Additional Requirements**:
- Comprehensive checks: Nix, Homebrew, security, disk, generations
- Clear output: Status symbols and descriptions
- Actionable: Tells user how to fix issues
- Fast: Completes in <10 seconds

**Technical Notes**:
- Create scripts/health-check.sh:
  ```bash
  #!/bin/bash

  echo "=== System Health Check ==="

  # Nix daemon
  if pgrep -x nix-daemon > /dev/null; then
    echo "✅ Nix daemon running"
  else
    echo "❌ Nix daemon not running"
  fi

  # Homebrew
  if brew doctor &>/dev/null; then
    echo "✅ Homebrew healthy"
  else
    echo "⚠️  Homebrew issues detected, run 'brew doctor'"
  fi

  # Disk space
  DISK_FREE=$(df -h /nix | tail -1 | awk '{print $4}')
  echo "💾 Disk free on /nix: $DISK_FREE"
