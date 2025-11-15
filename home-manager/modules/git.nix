# ABOUTME: Git configuration via Home Manager programs.git module
# ABOUTME: Provides declarative Git configuration with user info from user-config.nix

{
  config,
  lib,
  pkgs,
  userConfig,
  fullName,
  email,
  githubUsername,
  ...
}:

{
  # Git Configuration (Story 02.4-007)
  # User info from user-config.nix (fullName, email, githubUsername)
  # Git and Git LFS installed via darwin/configuration.nix systemPackages
  #
  # Why this approach:
  # - User info centralized in user-config.nix (single source of truth)
  # - Git LFS enabled globally for all repositories
  # - Sensible defaults for modern Git workflows
  # - GitHub-optimized settings (SSH by default)
  #
  # Configuration includes:
  # - User identity (name, email)
  # - Git LFS support
  # - Default branch name (main)
  # - Core settings (editor, autocrlf, etc.)
  # - Diff and merge tools
  # - GitHub integration settings

  programs.git = {
    enable = true;

    # User Identity (from user-config.nix)
    userName = fullName;              # e.g., "François Martin"
    userEmail = email;                # e.g., "fx@example.com"

    # Git LFS Configuration
    lfs = {
      enable = true;                  # Enable Git Large File Storage
      # LFS will be initialized globally on first darwin-rebuild
    };

    # Core Git Settings
    extraConfig = {
      # Default branch name
      init = {
        defaultBranch = "main";       # Use 'main' instead of 'master'
      };

      # Core settings
      core = {
        editor = "vim";                # Default editor for commit messages
        autocrlf = "input";            # LF line endings (macOS/Linux style)
        whitespace = "trailing-space,space-before-tab";
      };

      # Pull behavior
      pull = {
        rebase = false;                # Merge by default (not rebase)
      };

      # Push behavior
      push = {
        default = "simple";            # Push current branch to upstream
        autoSetupRemote = true;        # Automatically set up remote tracking
      };

      # GitHub settings
      github = {
        user = githubUsername;         # GitHub username from user-config.nix
      };

      # Diff and merge tools
      diff = {
        tool = "vimdiff";
      };

      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";       # Show common ancestor in conflicts
      };

      # Credential helper (use macOS Keychain)
      credential = {
        helper = "osxkeychain";        # macOS Keychain integration
      };

      # Color output
      color = {
        ui = "auto";                   # Enable colors in terminal
      };

      # Alias shortcuts (optional, can be customized)
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "log --graph --oneline --all";
      };
    };

    # Git ignore patterns (global)
    ignores = [
      # macOS
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"

      # Thumbnails
      "Thumbs.db"

      # Editor artifacts
      "*~"
      "*.swp"
      "*.swo"
      ".vscode/"
      ".idea/"

      # Nix
      "result"
      "result-*"

      # Build artifacts
      "*.o"
      "*.pyc"
      "__pycache__/"
      "node_modules/"
      "dist/"
      "build/"
    ];
  };

  # Post-installation verification message
  # This runs after Home Manager activation
  home.activation.gitConfigVerify = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v git > /dev/null 2>&1; then
      echo ""
      echo "✓ Git configuration applied:"
      echo "  - User: ${fullName} <${email}>"
      echo "  - GitHub: ${githubUsername}"
      echo "  - Git LFS: Enabled"
      echo "  - Default branch: main"
      echo ""
      echo "Verify configuration:"
      echo "  → git config user.name"
      echo "  → git config user.email"
      echo "  → git lfs version"
      echo ""
    fi
  '';
}
