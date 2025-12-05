# ABOUTME: Shell configuration module for Zsh with Oh My Zsh and Starship
# ABOUTME: Manages shell environment, aliases, plugins, and prompt configuration
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  # =============================================================================
  # ZSH SHELL CONFIGURATION (Story 04.1-001)
  # =============================================================================
  # Zsh as default shell with history and completion enabled
  # Reference: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable

  programs.zsh = {
    # Enable Zsh shell via Home Manager
    # This makes Zsh the default shell and configures it declaratively
    enable = true;

    # Enable command completion
    # Provides tab completion for commands, arguments, and file paths
    enableCompletion = true;

    # History configuration
    # Large history for better recall, ignore duplicates for cleaner history
    history = {
      # Store 50,000 commands in history (generous for power users)
      size = 50000;

      # History file location (default is ~/.zsh_history)
      path = "${config.home.homeDirectory}/.zsh_history";

      # Ignore duplicate commands (consecutive duplicates)
      ignoreDups = true;

      # Ignore commands starting with space (for sensitive commands)
      ignoreSpace = true;

      # Share history between terminal sessions
      # Commands appear in other terminals immediately
      share = true;

      # Save history incrementally (don't wait for shell exit)
      save = 50000;

      # Extended history format: timestamp and duration
      extended = true;
    };

    # Shell aliases
    # Nix system management aliases using scripts/update-system.sh
    # Modern CLI tool aliases added in Story 04.5-001, 04.5-002, 04.5-003
    shellAliases = {
      # =============================================================================
      # NIX SYSTEM MANAGEMENT (Story 04.5-001)
      # =============================================================================
      # Using scripts/update-system.sh wrapper for profile auto-detection
      nix-update = "bash ${config.home.homeDirectory}/Documents/nix-install/scripts/update-system.sh update";
      nix-rebuild = "bash ${config.home.homeDirectory}/Documents/nix-install/scripts/update-system.sh rebuild";
      nix-full = "bash ${config.home.homeDirectory}/Documents/nix-install/scripts/update-system.sh full";

      # Quick rebuild (auto-detect profile)
      rebuild = "bash ${config.home.homeDirectory}/Documents/nix-install/scripts/update-system.sh rebuild";

      # Update flake.lock and rebuild (convenience alias)
      update = "bash ${config.home.homeDirectory}/Documents/nix-install/scripts/update-system.sh update";

      # Nix garbage collection aliases
      gc = "nix-collect-garbage -d";  # Delete old generations
      cleanup = "nix-collect-garbage -d && nix-store --optimize";  # GC + optimize store

      # Health check (placeholder - will be implemented in Epic-06)
      health-check = "echo 'Health check script not yet implemented (Epic-06)'";

      # =============================================================================
      # GENERAL SHELL ALIASES (Story 04.5-002)
      # =============================================================================
      # Classic Unix convenience aliases
      ll = "ls -lah";    # Long listing with hidden files, human-readable sizes
      la = "ls -A";      # List all files except . and ..
      l = "ls -CF";      # Classify files (/, *, @) and columnar output

      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";

      # History search alias for convenience
      hist = "history 1";

      # =============================================================================
      # MODERN CLI TOOL ALIASES (Story 04.5-003)
      # =============================================================================
      # Replace legacy tools with modern alternatives while keeping originals accessible

      # grep → ripgrep (rg) - respects .gitignore, blazing fast, smart defaults
      grep = "rg";
      oldgrep = "command grep --color=auto";  # Original grep with color

      # cat → bat - syntax highlighting, git integration, line numbers
      cat = "bat";
      oldcat = "command cat";  # Original cat

      # find → fd - simpler syntax, respects .gitignore, parallel execution
      find = "fd";
      oldfind = "command find";  # Original find

      # ls → eza - icons, git status, tree view, better colors
      ls = "eza --icons --group-directories-first";
      oldls = "command ls --color=auto";  # Original ls (BSD ls on macOS)

      # Additional eza convenience aliases
      tree = "eza --tree --icons";  # Tree view with icons
      lt = "eza --tree --level=2 --icons";  # Tree view (2 levels)
      llt = "eza --tree --long --icons";  # Tree view with details

      # cd → zoxide (z) - frecency-based directory jumping
      # Note: Zoxide adds 'z' command automatically, these are just convenience aliases
      # Example: z docs → cd to most frequent/recent "docs" directory
      # No alias needed - zoxide init adds the 'z' command

      # =============================================================================
      # CONTAINER DEVELOPMENT ALIASES (Story 04.8-002)
      # =============================================================================
      # Docker → Podman compatibility layer
      # Podman is a daemonless, rootless container engine that's Docker CLI compatible

      # Docker compatibility aliases
      docker = "podman";                            # Use podman for all docker commands
      docker-compose = "podman-compose";            # Use podman-compose for compose

      # Container workflow shortcuts
      dps = "podman ps";                            # List running containers
      dpsa = "podman ps -a";                        # List all containers
      dim = "podman images";                        # List images
      dex = "podman exec -it";                      # Execute in container (interactive)
      dlogs = "podman logs -f";                     # Follow container logs
      dstop = "podman stop";                        # Stop container
      drm = "podman rm";                            # Remove container
      drmi = "podman rmi";                          # Remove image
      dprune = "podman system prune -af";           # Clean up everything (force)

      # Podman machine management
      pmstart = "podman machine start";             # Start Podman VM
      pmstop = "podman machine stop";               # Stop Podman VM
      pmstatus = "podman machine list";             # Show VM status

      # Quick container execution
      drun = "podman run --rm -it";                 # Run container (auto-remove, interactive)
      dalpine = "podman run --rm -it alpine sh";    # Quick Alpine shell

      # =============================================================================
      # PYTHON DEVELOPMENT ALIASES (Story 04.7-001, 04.7-002)
      # =============================================================================
      # uv-first workflow for Python project management

      # Project creation and management
      uvnew = "uv init";                           # Create new Python project
      uvrun = "uv run";                            # Run command in project environment
      uvsync = "uv sync";                          # Sync dependencies from pyproject.toml
      uvadd = "uv add";                            # Add dependency to project
      uvremove = "uv remove";                      # Remove dependency from project
      uvlock = "uv lock";                          # Update lock file
      uvtree = "uv tree";                          # Show dependency tree

      # Quick Python execution with uv
      py = "uv run python";                        # Run Python in project context
      ipy = "uv run python -i";                    # Interactive Python in project context

      # Linting and formatting (all via uv run for project context)
      lint = "ruff check .";                       # Fast linting with ruff
      lintfix = "ruff check . --fix";              # Auto-fix linting issues
      fmt = "ruff format .";                       # Format with ruff (faster than black)
      fmtcheck = "ruff format . --check";          # Check formatting without changes
      typecheck = "mypy .";                        # Static type checking
      sortimports = "isort .";                     # Sort imports

      # Combined quality checks
      qa = "ruff check . && ruff format . --check && mypy .";  # Full QA check
      fix = "ruff check . --fix && ruff format . && isort .";  # Auto-fix all

      # Virtual environment shortcuts (when not using uv)
      venv = "python -m venv .venv";               # Create virtual environment
      activate = "source .venv/bin/activate";      # Activate virtual environment
    };

    # =============================================================================
    # OH MY ZSH CONFIGURATION (Story 04.1-002)
    # =============================================================================
    # Oh My Zsh framework with essential plugins
    # Note: Theme is empty because Starship handles the prompt (Story 04.2-001)

    oh-my-zsh = {
      enable = true;

      # No theme - Starship prompt replaces Oh My Zsh themes
      # This prevents Oh My Zsh from setting any prompt styling
      theme = "";

      # Plugins for enhanced shell experience
      # git: Provides git aliases (gst, gco, gcm, gp, gl, etc.)
      # NOTE: fzf integration is handled by Home Manager's programs.fzf (not Oh My Zsh plugin)
      # NOTE: z plugin NOT included - zoxide (Story 04.5-003) provides superior frecency-based directory jumping
      # NOTE: zsh-autosuggestions installed separately via Nix (not bundled in Oh My Zsh)
      plugins = [
        "git"   # Git aliases and completions (gst=git status, gco=git checkout, etc.)
      ];
    };

    # zsh-autosuggestions plugin (installed via Nix, not Oh My Zsh)
    # Shows grayed-out command suggestions as you type based on history
    autosuggestion = {
      enable = true;
      # Highlight color for suggestions (subtle gray)
      highlight = "fg=#999999";
    };

    # Syntax highlighting for commands (red=invalid, green=valid)
    # Must be loaded after other plugins for proper highlighting
    syntaxHighlighting = {
      enable = true;
    };

    # =============================================================================
    # SHELL OPTIONS AND ENVIRONMENT (Story 04.1-003)
    # =============================================================================
    # Zsh options for optimal development workflow

    # Session environment variables
    # These are set at shell startup and persist across the session
    sessionVariables = {
      # CRITICAL: Disable Homebrew auto-updates
      # All updates controlled via `rebuild` command only (REQ-APP-010)
      HOMEBREW_NO_AUTO_UPDATE = "1";

      # Default editor for git commits, crontab, etc.
      # --wait flag keeps terminal attached until editor closes
      EDITOR = "zed --wait";
      VISUAL = "zed --wait";

      # Pager for man pages and git diffs
      PAGER = "less -R";

      # Less options for better viewing
      LESS = "-R -F -X";

      # Locale settings (UTF-8 for proper character handling)
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";

    };

    # Shell initialization code (runs after .zshrc setup)
    # Note: Renamed from deprecated 'initExtra' to 'initContent' (Home Manager 24.11+)
    initContent = ''
      # =============================================================================
      # ZSH OPTIONS (Story 04.1-003)
      # =============================================================================

      # Directory navigation
      setopt AUTO_PUSHD           # cd pushes old directory onto stack
      setopt PUSHD_IGNORE_DUPS    # Don't push duplicates onto stack
      setopt PUSHD_SILENT         # Don't print directory stack after pushd/popd
      setopt AUTO_CD              # Type directory name to cd into it

      # Globbing and pattern matching
      setopt EXTENDED_GLOB        # Extended glob patterns (#, ~, ^)
      setopt NULL_GLOB            # No error for patterns that match nothing
      setopt NO_CASE_GLOB         # Case-insensitive globbing

      # History behavior
      setopt HIST_VERIFY          # Show command before executing from history
      setopt HIST_REDUCE_BLANKS   # Remove unnecessary blanks from history

      # Shell behavior
      setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell
      setopt NO_BEEP              # Disable terminal beep
      setopt CORRECT              # Spell correction for commands

      # =============================================================================
      # PATH ADDITIONS (Story 04.1-003)
      # =============================================================================
      # Note: Nix and Homebrew paths are added automatically by nix-darwin
      # Only add additional paths here

      # Local user binaries (for pip install --user, etc.)
      export PATH="$HOME/.local/bin:$PATH"

      # Cargo (Rust) binaries if installed
      [[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

      # Go binaries if installed
      [[ -d "$HOME/go/bin" ]] && export PATH="$HOME/go/bin:$PATH"

      # =============================================================================
      # MODERN CLI TOOLS CONFIGURATION (Story 04.5-003)
      # =============================================================================

      # Zoxide initialization - smarter cd with frecency tracking
      # Adds 'z' command for jumping to frequently/recently used directories
      # Example: z docs → cd to most frequent/recent "docs" directory
      eval "$(zoxide init zsh)"

      # Bat (cat replacement) theme - use Catppuccin Mocha for dark mode
      # Matches our Stylix theme (Epic-05)
      export BAT_THEME="Catppuccin Mocha"

      # Bat pager settings - less with better defaults
      export BAT_PAGER="less -RF"

      # Eza (ls replacement) color configuration
      # Use vivid for LS_COLORS if available, otherwise fall back to default
      if command -v vivid &> /dev/null; then
        export LS_COLORS="$(vivid generate catppuccin-mocha)"
      fi
    '';

    # Note: Starship prompt will be configured in Story 04.2-001
  };

  # =============================================================================
  # FZF FUZZY FINDER (Story 04.3-001, enhanced in Story 04.5-003)
  # =============================================================================
  # FZF integration via Home Manager (preferred over Oh My Zsh plugin)
  # Provides: Ctrl+R (history), Ctrl+T (files), Alt+C (directories)
  # Enhanced with bat preview and fd search (Story 04.5-003)

  programs.fzf = {
    enable = true;

    # Enable shell integrations
    enableZshIntegration = true;

    # Default command for file finding (uses fd for speed)
    defaultCommand = "fd --type f --hidden --follow --exclude .git";

    # Default options for fzf appearance
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];

    # Ctrl+T: File finder options (Story 04.5-003: use bat for preview)
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    ];

    # Alt+C: Directory finder options (Story 04.5-003: use eza for preview)
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --level=2 --icons --color=always {}'"
    ];

    # Ctrl+R: History search options
    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };

  # =============================================================================
  # STARSHIP PROMPT (Story 04.2-001)
  # =============================================================================
  # Starship prompt replaces Oh My Zsh themes with a fast, customizable prompt
  # Configuration based on Powerlevel10k lean style (adapted from config/p10k.zsh)
  # Features: 2-line prompt, git status, Python version, cloud contexts, Nerd Font icons

  programs.starship = {
    enable = true;

    # Enable Zsh integration (adds eval "$(starship init zsh)" to .zshrc)
    enableZshIntegration = true;

    # Inline settings for key prompt configuration
    # Full configuration is in config/starship.toml but we define key settings here
    # for better integration with Home Manager and Nix store paths
    settings = {
      # Don't add blank lines between prompts
      add_newline = false;

      # 2-line prompt format: os, directory, git on line 1; prompt char on line 2
      format = ''
        $os$directory$git_branch$git_status
        $character
      '';

      # Right prompt with context info
      right_format = ''
        $status$cmd_duration$jobs$direnv$python$nodejs$ruby$golang$rust$kubernetes$terraform$aws$gcloud$azure$nix_shell$username$hostname
      '';

      # OS icon
      os = {
        disabled = false;
        style = "bold white";
        format = "[$symbol]($style) ";
        symbols = {
          Macos = "";
          Linux = "";
          Windows = "";
        };
      };

      # Directory (truncated, repo-aware)
      directory = {
        style = "bold cyan";
        format = "[$path]($style)[$read_only]($read_only_style) ";
        truncation_length = 3;
        truncate_to_repo = true;
        read_only = " ";
        read_only_style = "red";
      };

      # Git branch
      git_branch = {
        symbol = " ";
        style = "bold green";
        format = "[$symbol$branch]($style) ";
      };

      # Git status (compact format)
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bold yellow";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?\${count}";
        stashed = "$";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };

      # Prompt character
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      # Status (show on error)
      status = {
        disabled = false;
        style = "bold red";
        format = "[$symbol$status]($style) ";
        symbol = "✘";
      };

      # Command duration
      cmd_duration = {
        min_time = 2000;
        style = "bold yellow";
        format = "[$duration]($style) ";
      };

      # Background jobs
      jobs = {
        symbol = "✦";
        style = "bold blue";
        number_threshold = 1;
        format = "[$symbol$number]($style) ";
      };

      # Python (show version and venv)
      python = {
        symbol = " ";
        style = "bold yellow";
        format = "[\${symbol}\${pyenv_prefix}(\${version} )(\\(\${virtualenv}\\) )]($style)";
        pyenv_version_name = true;
        detect_extensions = ["py"];
        detect_files = [".python-version" "Pipfile" "pyproject.toml" "requirements.txt" "setup.py"];
      };

      # Node.js
      nodejs = {
        symbol = " ";
        style = "bold green";
        format = "[$symbol($version )]($style)";
        detect_files = ["package.json" ".node-version" ".nvmrc"];
      };

      # Ruby
      ruby = {
        symbol = " ";
        style = "bold red";
        format = "[$symbol($version )]($style)";
        detect_files = ["Gemfile" ".ruby-version"];
      };

      # Go
      golang = {
        symbol = " ";
        style = "bold cyan";
        format = "[$symbol($version )]($style)";
        detect_extensions = ["go"];
      };

      # Rust
      rust = {
        symbol = " ";
        style = "bold red";
        format = "[$symbol($version )]($style)";
        detect_extensions = ["rs"];
      };

      # AWS
      aws = {
        symbol = " ";
        style = "bold yellow";
        format = "[$symbol($profile )(\\(\${region}\\) )]($style)";
        disabled = false;
      };

      # Google Cloud
      gcloud = {
        symbol = "☁️ ";
        style = "bold blue";
        format = "[$symbol$account(@$domain)(\\($region\\))]($style) ";
        disabled = false;
      };

      # Azure
      azure = {
        symbol = "󰠅 ";
        style = "bold blue";
        format = "[$symbol($subscription)]($style) ";
        disabled = false;
      };

      # Kubernetes
      kubernetes = {
        symbol = "☸ ";
        style = "bold blue";
        format = "[$symbol$context( \\($namespace\\))]($style) ";
        disabled = false;
      };

      # Terraform
      terraform = {
        symbol = "💠 ";
        style = "bold purple";
        format = "[$symbol$workspace]($style) ";
        disabled = false;
      };

      # Direnv
      direnv = {
        symbol = "▶ ";
        style = "bold orange";
        format = "[$symbol$loaded/$allowed]($style) ";
        disabled = false;
      };

      # Nix shell
      nix_shell = {
        symbol = " ";
        style = "bold blue";
        format = "[$symbol$state( \\($name\\))]($style) ";
        disabled = false;
        impure_msg = "[impure](bold red)";
        pure_msg = "[pure](bold green)";
      };

      # Username (show only in SSH or as root)
      username = {
        show_always = false;
        style_user = "bold yellow";
        style_root = "bold red";
        format = "[$user]($style)";
        disabled = false;
      };

      # Hostname (show only in SSH)
      hostname = {
        ssh_only = true;
        style = "bold green";
        format = "[@$hostname]($style) ";
        disabled = false;
        trim_at = ".";
      };
    };
  };
}
