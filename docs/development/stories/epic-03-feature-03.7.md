# ABOUTME: Epic-03 Feature 03.7 (Time Machine Backup Configuration) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 03.7

# Epic-03 Feature 03.7: Time Machine Backup Configuration

## Feature Overview

**Feature ID**: Feature 03.7
**Feature Name**: Time Machine Backup Configuration
**Epic**: Epic-03
**Status**: 📝 Not Started

**Feature Description**: Automate Time Machine backup configuration with intelligent exclusions and user-prompted destination setup
**User Value**: Automated backup system configuration saves time and ensures critical paths are excluded from backups
**Story Count**: 2
**Story Points**: 8
**Priority**: Should Have (P1)
**Complexity**: Medium

#### Stories in This Feature

##### Story 03.7-001: Time Machine Preferences & Exclusions
**User Story**: As FX, I want Time Machine configured with intelligent exclusions (Nix store, caches, temp directories) and security preferences so that backups are efficient and don't waste disk space on reproducible content

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** darwin-rebuild completes successfully
- **When** Time Machine is configured
- **Then** the following paths are excluded from backups:
  - `/nix` (Nix store - fully reproducible)
  - `~/.Trash` (user trash)
  - `~/Library/Caches` (application caches)
  - `~/Downloads` (user downloads - usually temporary)
  - `/private/var/folders` (system temporary files)
- **And** Time Machine does not prompt to use new external disks as backup volumes
- **And** Time Machine appears in the menu bar for quick access
- **And** exclusions persist across system rebuilds
- **And** auto-backup is enabled if a destination was configured

**Additional Requirements**:
- Exclusion list should be configurable via Nix for user customization
- System preferences set via `defaults` commands
- Menu bar visibility controlled via system defaults
- Backup destination (if configured) persists in user-config.nix

**Technical Notes**:
- Add to darwin/macos-defaults.nix with system.activationScripts:
  ```nix
  system.activationScripts.configureTimeMachine = {
    text = ''
      echo "Configuring Time Machine preferences..."

      # Don't prompt to use new hard drives as backup volume
      /usr/bin/defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

      # Show Time Machine in menu bar
      /usr/bin/defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.TimeMachine" -bool true

      # Add standard exclusions (safe to run multiple times)
      /usr/bin/sudo /usr/bin/tmutil addexclusion -p /nix 2>/dev/null || true
      /usr/bin/sudo /usr/bin/tmutil addexclusion -p ~/.Trash 2>/dev/null || true
      /usr/bin/sudo /usr/bin/tmutil addexclusion -p ~/Library/Caches 2>/dev/null || true
      /usr/bin/sudo /usr/bin/tmutil addexclusion -p ~/Downloads 2>/dev/null || true
      /usr/bin/sudo /usr/bin/tmutil addexclusion -p /private/var/folders 2>/dev/null || true

      echo "✅ Time Machine exclusions configured"
    '';
  };
  ```
- Consider adding user-configurable exclusion list in user-config.nix:
  ```nix
  timeMachine = {
    additionalExclusions = [
      # User can add custom paths here
    ];
  };
  ```
- Verify: Check excluded paths with `tmutil isexcluded <path>`
- Note: Backup destination setup is handled in Story 03.7-002

**Definition of Done**:
- [ ] Exclusions implemented in macos-defaults.nix activation script
- [ ] Standard exclusions applied (/nix, caches, trash, downloads, temp)
- [ ] Time Machine menu bar icon visible
- [ ] New disk prompt disabled
- [ ] Exclusions verified with `tmutil isexcluded`
- [ ] Settings persist after rebuild
- [ ] User can add custom exclusions via config
- [ ] Tested in VM

**Dependencies**:
- Epic-01, Story 01.5-001 (nix-darwin installed)
- Epic-01, Story 01.1-001 (User configuration prompts - for destination)

**Risk Level**: Low
**Risk Mitigation**:
- Exclusions are additive (safe to run multiple times with `|| true`)
- User data paths excluded are standard temp/cache locations
- Nix store exclusion is safe (fully reproducible via flake.lock)

---

##### Story 03.7-002: Time Machine Destination Setup Prompt
**User Story**: As FX, I want the bootstrap script to prompt me for a Time Machine backup destination during installation so that backups are automatically enabled if I have an external drive connected

**Priority**: Should Have
**Story Points**: 3
**Sprint**: Sprint 5

**Acceptance Criteria**:
- **Given** bootstrap.sh is running (Phase 2: User Configuration)
- **When** the script prompts for Time Machine destination
- **Then** I can optionally provide a path to an external drive or network volume
- **And** if I provide a destination, it is saved to user-config.nix
- **And** if I skip (press Enter), Time Machine is left unconfigured for manual setup later
- **And** if a destination is configured, `tmutil setdestination` is run during darwin-rebuild
- **And** if configured, Time Machine auto-backup is enabled

**Additional Requirements**:
- Prompt should be optional (user can skip by pressing Enter)
- Validate destination path exists if provided
- Support both local volumes (`/Volumes/BackupDrive`) and network paths
- Display current connected volumes to help user choose
- Enable auto-backup only if destination is successfully set

**Technical Notes**:
- Add to bootstrap.sh Phase 2 (User Configuration Prompts):
  ```bash
  # Time Machine backup destination (optional)
  echo ""
  echo "=== Time Machine Backup Configuration ==="
  echo "Available volumes:"
  ls -1 /Volumes/ 2>/dev/null | grep -v "Macintosh HD" || echo "  (No external volumes detected)"
  echo ""
  echo "Enter Time Machine backup destination (optional):"
  echo "  Examples: /Volumes/BackupDrive, afp://server/share"
  echo "  Press Enter to skip and configure manually later"
  read -r tm_destination

  # Validate if provided
  if [[ -n "$tm_destination" ]]; then
    if [[ -d "$tm_destination" ]] || [[ "$tm_destination" =~ ^(afp|smb):// ]]; then
      echo "  ✅ Destination: $tm_destination"
    else
      echo "  ⚠️  Warning: Path does not exist. You can update this later in user-config.nix"
    fi
  else
    tm_destination=""
    echo "  Skipped - configure manually later if needed"
  fi
  ```
- Add to user-config.nix template:
  ```nix
  timeMachine = {
    destination = "${tm_destination}";  # Empty string if not configured
  };
  ```
- Add to darwin/macos-defaults.nix (conditional on destination being set):
  ```nix
  system.activationScripts.setTimeMachineDestination = lib.mkIf (config.timeMachine.destination != "") {
    text = ''
      echo "Setting Time Machine destination..."
      /usr/bin/sudo /usr/bin/tmutil setdestination "${config.timeMachine.destination}"
      /usr/bin/sudo /usr/bin/tmutil enable
      echo "✅ Time Machine enabled with destination: ${config.timeMachine.destination}"
    '';
  };
  ```
- Verify: Check with `tmutil destinationinfo` and `tmutil status`

**Definition of Done**:
- [ ] Bootstrap Phase 2 prompts for TM destination
- [ ] Available volumes displayed to user
- [ ] User can skip by pressing Enter
- [ ] Destination validation implemented (path exists or network URL)
- [ ] Destination saved to user-config.nix
- [ ] Activation script sets destination if configured
- [ ] Auto-backup enabled if destination set
- [ ] Empty destination skips TM setup (for manual config later)
- [ ] Tested in VM with and without external drive

**Dependencies**:
- Epic-01, Story 01.1-001 (User configuration prompts)
- Epic-01, Story 01.2-001 (user-config.nix template)
- Story 03.7-001 (Time Machine exclusions must be set first)

**Risk Level**: Medium
**Risk Mitigation**:
- Validation prevents invalid paths from being configured
- User can skip and configure manually later
- Empty destination gracefully skips TM setup
- Network paths (AFP/SMB) are validated by URL pattern only
- User can update destination in user-config.nix after bootstrap

---

## Feature Implementation Notes

### Testing Strategy
1. **VM Testing** (FX performs manually):
   - Test with no external volumes (skip prompt)
   - Test with external disk connected (provide path)
   - Verify exclusions applied: `tmutil isexcluded /nix`
   - Verify destination set: `tmutil destinationinfo`
   - Verify auto-backup enabled: `tmutil status`
   - Verify menu bar icon appears

2. **Hardware Testing** (FX performs manually):
   - MacBook Pro M3 Max with external SSD
   - MacBook Air with network backup (if using NAS)
   - Verify backups complete successfully
   - Verify excluded paths are not backed up

### User Documentation Required
- Quick-start guide: Section on Time Machine configuration
- Troubleshooting: Common TM setup issues
- Customization guide: How to add custom exclusions

### Post-Implementation Validation
- [ ] Exclusions reduce backup size by ~20-50GB (Nix store + caches)
- [ ] First backup completes without errors
- [ ] Subsequent incremental backups work correctly
- [ ] User can manually add/remove exclusions via config

---

## Related Requirements from docs/REQUIREMENTS.md

**Requirement ID**: REQ-SYS-007 (Time Machine Backup Configuration)
**Priority**: P1 (Should Have)
**Rationale**: Automated backup configuration ensures data protection without manual setup

**Acceptance Criteria from Requirements**:
- ✅ Time Machine auto-backup enabled (if destination configured)
- ✅ Intelligent exclusions (/nix, caches, temp files)
- ✅ Menu bar access for quick status
- ✅ User prompted for destination during bootstrap
- ✅ Configuration reproducible across rebuilds

---

## Epic-03 Integration

This feature adds 2 stories (8 points) to Epic-03:
- **Previous Epic-03 Total**: 12 stories, 68 points
- **New Epic-03 Total**: 14 stories, 76 points

**Updated Epic-03 Feature List**:
- Feature 03.1: Finder Configuration (3 stories, 18 points)
- Feature 03.2: Security & Privacy Settings (2 stories, 13 points)
- Feature 03.3: Trackpad & Mouse (2 stories, 8 points)
- Feature 03.4: Display & Energy (2 stories, 11 points)
- Feature 03.5: Keyboard & Input (2 stories, 10 points)
- Feature 03.6: Dock Configuration (1 story, 8 points)
- **Feature 03.7: Time Machine Backup Configuration (2 stories, 8 points)** ← NEW

---

## Sprint Assignment

**Recommended Sprint**: Sprint 5 (Week 3-4)
**Rationale**:
- Depends on Epic-01 completion (bootstrap + user prompts)
- Natural fit with other system configuration stories in Epic-03
- Should be implemented after core system preferences (Finder, security, etc.)
- Can run in parallel with Epic-02 (Application Installation)

**Sprint 5 Scope**:
- Epic-03 remaining stories (Finder, Security, Trackpad, Display, Keyboard, Dock)
- Feature 03.7 (Time Machine) fits naturally into this sprint
- Estimated Sprint 5 total: 25-30 points

---

## Change Log

| Date | Change | Rationale | Approved By |
|------|--------|-----------|-------------|
| 2025-11-16 | Created Feature 03.7 (Time Machine) | User requested Time Machine automation | FX |
| 2025-11-16 | Added 2 stories (8 points) to Epic-03 | Time Machine configuration + bootstrap prompt | FX |

---

**Status**: 📝 Ready for implementation
**Next Steps**:
1. Update STORIES.md to reflect new Epic-03 totals (14 stories, 76 points)
2. Update docs/development/progress.md with Feature 03.7
3. Add to Sprint 5 backlog
4. Implement after Epic-01 completion and during Epic-03 sprint
