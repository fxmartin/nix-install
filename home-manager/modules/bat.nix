# ABOUTME: bat (cat replacement) configuration with Catppuccin Mocha theme
# ABOUTME: Provides syntax highlighting and sensible defaults for file viewing
{
  config,
  pkgs,
  lib,
  ...
}: {
  # bat configuration via Home Manager
  programs.bat = {
    enable = true;

    config = {
      # Theme - Catppuccin Mocha (matches Stylix theme)
      # Note: bat uses built-in themes, we'll add Catppuccin
      theme = "Catppuccin Mocha";

      # Pager settings
      # Use less with options:
      # -R = process color escape sequences
      # -F = quit if output fits on one screen
      # -X = don't clear screen on exit
      pager = "less -RFX";

      # Style options (comma-separated)
      # full, auto, plain, changes, header, header-filename, header-filesize,
      # grid, rule, numbers, snip
      style = "numbers,changes,header,grid";

      # Line wrapping
      # "auto" = wrap based on terminal width
      # "never" = never wrap
      # "character" = wrap at character
      wrap = "auto";

      # Tab width (spaces)
      tabs = "4";

      # Show non-printable characters
      # Use --show-all to enable
      # show-all = true;

      # Color output
      # "auto" = color if stdout is terminal
      # "always" = always use color
      # "never" = never use color
      color = "auto";

      # Italic text (requires terminal support)
      italic-text = "always";

      # Map file extensions to languages
      # Useful for files without proper extensions
      map-syntax = [
        "*.ino:C++"
        ".ignore:Git Ignore"
        "*.envrc:Bash"
        "*.conf:INI"
        "*.nix:Nix"
      ];
    };

    # Extra packages for bat (syntax highlighting, etc.)
    extraPackages = with pkgs.bat-extras; [
      # batgrep - grep with bat output
      batgrep
      # batman - man pages with bat
      batman
      # batpipe - pipe any command through bat
      batpipe
      # batwatch - watch files with bat
      batwatch
      # batdiff - diff with bat syntax highlighting
      batdiff
      # prettybat - format and highlight code
      prettybat
    ];

    # Catppuccin Mocha theme for bat
    themes = {
      "Catppuccin Mocha" = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "d2bbee4f7e7d5bac63c054e4d8efa57a2571c0ee";
          sha256 = "sha256-x1yqPCWuoBSx/cI94eA+AWwhiSA42cLNUOFJl7qjhmw=";
        };
        file = "themes/Catppuccin Mocha.tmTheme";
      };
    };
  };

  # Activation script to verify bat configuration
  home.activation.verifyBat = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "bat: Configuration applied"
    echo "  - Theme: Catppuccin Mocha"
    echo "  - Style: numbers, changes, header, grid"
    echo "  - Tab width: 4 spaces"
    echo "  - Extras: batgrep, batman, batpipe, batwatch, batdiff, prettybat"
    echo "  - Run 'bat <file>' to view files with syntax highlighting"
    echo "  - Run 'bat --list-themes' to see available themes"
  '';
}
