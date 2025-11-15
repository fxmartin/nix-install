# ABOUTME: Epic-07 Feature 07.4 (Customization Guide) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 07.4

# Epic-07 Feature 07.4: Customization Guide

## Feature Overview

**Feature ID**: Feature 07.4
**Feature Name**: Customization Guide
**Epic**: Epic-07
**Status**: 🔄 In Progress

  ```markdown
  ## Common Customization Examples

  ### Add More Shell Aliases

  File: `home-manager/modules/aliases.nix`

  ```nix
  programs.zsh.shellAliases = {
    # Git shortcuts
    glog = "git log --oneline --graph --decorate";
    gd = "git diff";

    # Navigation
    proj = "cd ~/Projects";
    dots = "cd ~/Documents/nix-install";

    # System
    flush-dns = "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
  };
  ```

  ### Configure Dock Apps

  File: `darwin/macos-defaults.nix`

  ```nix
  system.defaults.dock = {
    autohide = true;              # Auto-hide dock
    show-recents = false;          # Don't show recent apps
    tilesize = 48;                 # Icon size (pixels)
    orientation = "bottom";        # Position: bottom, left, right
    minimize-to-application = true; # Minimize into app icon
  };
  ```

  ### Add Startup Apps (Login Items)

  File: `darwin/configuration.nix`

  ```nix
  system.startup.chime = false;  # Disable startup chime

  # For login items, use System Settings or:
  launchd.user.agents.my-startup-app = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/MyApp.app/Contents/MacOS/MyApp" ];
      RunAtLoad = true;
    };
  };
  ```

  ### Customize Finder Sidebar (Advanced)

  Manual setup required - automated sidebar customization is complex. To customize:

  1. Open Finder → Preferences → Sidebar
  2. Check/uncheck items manually
  3. For smart folders, create manually and add to sidebar

  Nix can configure some Finder settings, but full sidebar automation requires third-party tools like `mysides`.

  ## After Making Changes

  Always rebuild and test:

  ```bash
  rebuild
  # Test your changes
  # If broken, rollback:
  darwin-rebuild --rollback
  ```
  ```

**Definition of Done**:
- [ ] Examples section added to customization.md
- [ ] Multiple real-world examples provided
- [ ] Examples are copy-paste ready
- [ ] Explanations included
- [ ] File references clear
- [ ] Reviewed for safety and accuracy

**Dependencies**:
- Story 07.4-001 (Customization guide base)

**Risk Level**: Low
**Risk Mitigation**: N/A

---

## Epic Dependencies

### Dependencies on Other Epics
- **Epic-01 (Bootstrap)**: Bootstrap process to document
- **Epic-02 (Applications)**: Licensed apps to document
- **Epic-03 (System Config)**: System preferences to document
- **Epic-04 (Dev Environment)**: Shell and aliases to document
- **Epic-05 (Theming)**: Theming customization to document
