# ABOUTME: Guide for customizing and extending the nix-darwin configuration
# ABOUTME: Covers adding apps, modifying settings, and extending the system

# Customization Guide

How to add new applications, modify system settings, and extend your nix-darwin configuration.

**Important**: After any change, always run `rebuild` to apply it.

---

## Table of Contents

1. [Adding New Applications](#adding-new-applications)
2. [Modifying System Preferences](#modifying-system-preferences)
3. [Customizing Shell Environment](#customizing-shell-environment)
4. [Changing Theme or Fonts](#changing-theme-or-fonts)
5. [Common Customization Examples](#common-customization-examples)

---

## Adding New Applications

There are three methods to add applications, each suited for different types of software.

### Decision Guide: Which Method to Use?

| App Type | Method | Example Apps |
|----------|--------|--------------|
| CLI tools, dev tools | **Nix** | ripgrep, jq, htop, Python, Node.js |
| GUI applications | **Homebrew Cask** | Notion, Spotify, Slack, Discord |
| Mac App Store only | **mas** | Kindle, WhatsApp, Pages, Numbers |

**Priority order**: Nix → Homebrew → Mac App Store

- Use **Nix** when possible (better reproducibility, atomic updates)
- Use **Homebrew Cask** for GUI apps not in Nix
- Use **mas** only for apps exclusively on Mac App Store

---

### Method 1: Nix (CLI Tools and Dev Tools)

**When to use**: Command-line tools, programming languages, libraries, dev utilities.

**File to edit**: `darwin/configuration.nix`

#### Example: Adding ripgrep (fast grep alternative)

1. **Search for package** (optional, to confirm name):
   ```bash
   nix search nixpkgs#ripgrep
   ```

2. **Edit configuration**:
   ```nix
   # darwin/configuration.nix
   environment.systemPackages = with pkgs; [
     # ... existing packages
     ripgrep  # Add new package
   ];
   ```

3. **Apply changes**:
   ```bash
   rebuild
   ```

4. **Verify installation**:
   ```bash
   which rg           # Should show /nix/store/.../bin/rg
   rg --version       # Should show version info
   ```

#### More Nix Examples

```nix
environment.systemPackages = with pkgs; [
  # Text processing
  jq           # JSON processor
  yq           # YAML processor

  # System monitoring
  htop         # Interactive process viewer
  ncdu         # Disk usage analyzer

  # Development
  nodejs_20    # Node.js 20.x
  go           # Go programming language
  rustc        # Rust compiler

  # Networking
  curl         # HTTP client
  wget         # File downloader
  httpie       # Modern HTTP client
];
```

---

### Method 2: Homebrew Cask (GUI Applications)

**When to use**: Desktop applications, GUI tools, apps with frequent updates.

**File to edit**: `darwin/homebrew.nix`

#### Example: Adding Notion

1. **Search for cask** (optional, to confirm name):
   ```bash
   brew search notion
   ```

2. **Edit configuration**:
   ```nix
   # darwin/homebrew.nix
   homebrew.casks = [
     # ... existing casks
     "notion"  # Add new cask
   ];
   ```

3. **Apply changes**:
   ```bash
   rebuild
   ```

4. **Verify installation**:
   ```bash
   ls /Applications/Notion.app  # Should exist
   open -a Notion               # Launch app
   ```

#### More Homebrew Cask Examples

```nix
homebrew.casks = [
  # Productivity
  "notion"
  "obsidian"
  "todoist"

  # Communication
  "slack"
  "discord"
  "telegram"

  # Development
  "postman"
  "insomnia"
  "tableplus"

  # Media
  "spotify"
  "pocket-casts"

  # Utilities
  "rectangle"      # Window management
  "cleanmymac"
  "appcleaner"
];
```

---

### Method 3: Mac App Store (mas)

**When to use**: Apps only available through Mac App Store (no Homebrew cask).

**File to edit**: `darwin/homebrew.nix`

**Prerequisite**: Must be signed into Mac App Store and have previously "purchased" (even free) the app.

#### Example: Adding Pages

1. **Find App Store ID**:
   ```bash
   mas search Pages
   # Output: 409201541  Pages (14.0)
   ```

2. **Edit configuration**:
   ```nix
   # darwin/homebrew.nix
   homebrew.masApps = {
     # ... existing apps
     "Pages" = 409201541;  # Add new app
   };
   ```

3. **Apply changes**:
   ```bash
   rebuild
   ```

4. **Verify installation**:
   ```bash
   mas list | grep Pages
   ```

#### More Mac App Store Examples

```nix
homebrew.masApps = {
  # Apple Apps
  "Pages" = 409201541;
  "Numbers" = 409203825;
  "Keynote" = 409183694;

  # Utilities
  "The Unarchiver" = 425424353;
  "Amphetamine" = 937984704;

  # Development
  "Xcode" = 497799835;
};
```

**Note**: If `rebuild` fails with "not previously purchased", open App Store.app, search for the app, and click "Get" first.

---

## Modifying System Preferences

System preferences are managed in `darwin/macos-defaults.nix`.

### Dock Settings

```nix
# darwin/macos-defaults.nix
system.defaults.dock = {
  autohide = true;               # Auto-hide dock
  autohide-delay = 0.0;          # No delay before hiding
  autohide-time-modifier = 0.5;  # Animation speed
  show-recents = false;          # Don't show recent apps
  tilesize = 48;                 # Icon size (pixels)
  orientation = "bottom";        # Position: bottom, left, right
  minimize-to-application = true; # Minimize into app icon
  launchanim = false;            # Disable launch animation
};
```

### Finder Settings

```nix
system.defaults.finder = {
  AppleShowAllFiles = true;           # Show hidden files
  ShowPathbar = true;                 # Show path bar
  ShowStatusBar = true;               # Show status bar
  FXPreferredViewStyle = "Nlsv";      # List view by default
  FXDefaultSearchScope = "SCcf";      # Search current folder
  FXEnableExtensionChangeWarning = false;  # No extension warning
  _FXShowPosixPathInTitle = true;     # Full path in title
};
```

### Trackpad Settings

```nix
system.defaults.trackpad = {
  Clicking = true;                    # Tap to click
  TrackpadRightClick = true;          # Two-finger right click
  TrackpadThreeFingerDrag = true;     # Three-finger drag
};

system.defaults.NSGlobalDomain = {
  "com.apple.swipescrolldirection" = false;  # Natural scroll off
};
```

### Keyboard Settings

```nix
system.defaults.NSGlobalDomain = {
  KeyRepeat = 2;                      # Fast key repeat
  InitialKeyRepeat = 15;              # Short delay before repeat
  NSAutomaticCapitalizationEnabled = false;
  NSAutomaticDashSubstitutionEnabled = false;
  NSAutomaticPeriodSubstitutionEnabled = false;
  NSAutomaticQuoteSubstitutionEnabled = false;
  NSAutomaticSpellingCorrectionEnabled = false;
};
```

After changes, run `rebuild` and restart affected apps (or logout/login for some settings).

---

## Customizing Shell Environment

### Adding Shell Aliases

**File to edit**: `home-manager/modules/shell.nix`

```nix
programs.zsh.shellAliases = {
  # Git shortcuts
  glog = "git log --oneline --graph --decorate";
  gd = "git diff";
  gst = "git status";

  # Navigation
  proj = "cd ~/Projects";
  dots = "cd ~/Documents/nix-install";

  # System
  flush-dns = "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
  ports = "lsof -i -P -n | grep LISTEN";

  # Shortcuts
  please = "sudo";
  weather = "curl wttr.in";
};
```

### Adding Environment Variables

```nix
# home-manager/modules/shell.nix
home.sessionVariables = {
  EDITOR = "zed --wait";
  VISUAL = "zed --wait";
  MY_CUSTOM_VAR = "some-value";
};
```

### Adding Shell Functions

```nix
programs.zsh.initExtra = ''
  # Create directory and cd into it
  mkcd() {
    mkdir -p "$1" && cd "$1"
  }

  # Quick git commit with message
  gc() {
    git commit -m "$*"
  }

  # Extract any archive
  extract() {
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.gz)      gunzip "$1" ;;
      *)         echo "Unknown format: $1" ;;
    esac
  }
'';
```

---

## Changing Theme or Fonts

### Stylix Theme Configuration

**File to edit**: `darwin/stylix.nix` or `flake.nix`

```nix
# Change color scheme
stylix = {
  # Use different base16 theme
  base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  # Or: dracula, nord, solarized-dark, tokyo-night, etc.

  # Change polarity (light vs dark)
  polarity = "dark";  # or "light"
};
```

### Available Themes

Common base16 themes you can use:
- `catppuccin-mocha` (default dark)
- `catppuccin-latte` (default light)
- `gruvbox-dark-medium`
- `dracula`
- `nord`
- `solarized-dark`
- `tokyo-night`
- `one-dark`

### Changing Fonts

```nix
stylix.fonts = {
  monospace = {
    package = pkgs.jetbrains-mono;
    name = "JetBrains Mono";
  };

  # Or use a different font:
  # monospace = {
  #   package = pkgs.fira-code;
  #   name = "Fira Code";
  # };

  sizes = {
    terminal = 14;
    editor = 14;
  };
};
```

---

## Common Customization Examples

### Example 1: Add Development Stack

Add Node.js, pnpm, and related tools:

```nix
# darwin/configuration.nix
environment.systemPackages = with pkgs; [
  nodejs_20
  nodePackages.pnpm
  nodePackages.typescript
  nodePackages.prettier
];
```

### Example 2: Configure Dock Apps

Set specific apps to appear in Dock (requires manual setup after):

```nix
# darwin/macos-defaults.nix
system.defaults.dock = {
  persistent-apps = [
    "/Applications/Arc.app"
    "/Applications/Ghostty.app"
    "/Applications/Zed.app"
    "/System/Applications/Mail.app"
  ];
};
```

**Note**: This may require logout/login to take effect.

### Example 3: Add Startup Apps (LaunchAgents)

Run a script or app at login:

```nix
# darwin/configuration.nix
launchd.user.agents.my-startup-script = {
  serviceConfig = {
    ProgramArguments = [ "/bin/bash" "-c" "echo 'Hello' >> ~/startup.log" ];
    RunAtLoad = true;
  };
};
```

### Example 4: Profile-Specific Apps

Add apps only to Power profile:

```nix
# flake.nix - in darwinConfigurations.power
homebrew.casks = [
  # ... common casks
  "parallels"  # Power profile only
];
```

---

## After Making Changes

Always follow this workflow:

1. **Edit the configuration file**

2. **Rebuild to apply**:
   ```bash
   rebuild
   ```

3. **Test the change**:
   - For apps: verify they launch
   - For settings: check System Settings or run `defaults read`
   - For aliases: open new terminal and test

4. **If something breaks, rollback**:
   ```bash
   darwin-rebuild --rollback
   ```

5. **Commit your changes** (when satisfied):
   ```bash
   cd ~/Documents/nix-install
   git add -A
   git commit -m "Add [description of change]"
   git push
   ```

---

## Troubleshooting Customizations

### "Package not found"

```bash
# Search for correct package name
nix search nixpkgs#<partial-name>

# Example
nix search nixpkgs#node
```

### "Cask not found"

```bash
# Search Homebrew for cask name
brew search <name>

# Check exact cask name
brew info --cask <name>
```

### Settings not applied

Some settings require:
- **Finder**: `killall Finder`
- **Dock**: `killall Dock`
- **System-wide**: Logout and login
- **Some apps**: Restart the specific app

---

**See also**:
- [Troubleshooting Guide](./troubleshooting.md)
- [Post-Install Checklist](./post-install.md)
- [README](../README.md)
