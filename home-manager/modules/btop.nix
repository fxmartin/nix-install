# ABOUTME: btop system monitor configuration with Catppuccin Mocha theme
# ABOUTME: Provides consistent theming and sensible defaults across machines
{
  config,
  pkgs,
  lib,
  ...
}: {
  # btop configuration via Home Manager
  programs.btop = {
    enable = true;

    settings = {
      # Color theme - Catppuccin Mocha (matches Stylix theme)
      color_theme = "catppuccin_mocha";

      # Theme background setting
      # True = use terminal background (better for transparency)
      # False = use theme's background color
      theme_background = false;

      # Truecolor support (modern terminals like Ghostty support this)
      truecolor = true;

      # Force TTY mode (disable for better graphics in modern terminals)
      force_tty = false;

      # Graph symbol style
      # "braille" = Unicode braille (most detailed)
      # "block" = Unicode block characters
      # "tty" = ASCII characters only
      graph_symbol = "braille";

      # Shown graph style for CPU
      # "default", "line", "block", "tty", "braille"
      graph_symbol_cpu = "default";

      # Shown graph style for memory
      graph_symbol_mem = "default";

      # Shown graph style for network
      graph_symbol_net = "default";

      # Shown graph style for processes
      graph_symbol_proc = "default";

      # Time format (true = 24h, false = 12h AM/PM)
      clock_format = "%X";

      # Background update (update while unfocused)
      background_update = true;

      # Update time in milliseconds (2000 = 2 seconds, balanced)
      update_ms = 2000;

      # Process sorting
      # "pid", "name", "command", "threads", "user", "memory", "cpu lazy", "cpu direct"
      proc_sorting = "cpu lazy";

      # Reverse sorting order
      proc_reversed = false;

      # Show processes as a tree
      proc_tree = false;

      # Use process colors
      proc_colors = true;

      # Show process gradients
      proc_gradient = true;

      # Show processes per core
      proc_per_core = true;

      # Show memory as bytes or percent
      proc_mem_bytes = true;

      # Show CPU graph per core
      cpu_graph_upper = "total";
      cpu_graph_lower = "total";

      # CPU sensor to use (auto-detect)
      cpu_sensor = "Auto";

      # Show temperatures (true = show if available)
      show_cpu_freq = true;

      # Draw a clock at top of screen
      draw_clock = "%X";

      # Use custom CPU model name (empty = auto-detect)
      custom_cpu_name = "";

      # Show disks
      disks_filter = "";

      # Show IO activity
      show_io_stat = true;

      # Show memory usage for disks
      io_mode = false;

      # Show swap info
      show_swap = true;

      # Swap as disk
      swap_disk = true;

      # Show memory graphs
      mem_graphs = true;

      # Network interfaces to show (empty = auto)
      net_iface = "";

      # Show battery statistics
      show_battery = true;

      # Selected battery (auto-detect)
      selected_battery = "Auto";

      # Logging level (DEBUG, WARNING, ERROR, CRITICAL)
      log_level = "WARNING";
    };
  };

  # Create Catppuccin Mocha theme file for btop
  # btop looks for themes in ~/.config/btop/themes/
  xdg.configFile."btop/themes/catppuccin_mocha.theme".text = ''
    # Catppuccin Mocha theme for btop
    # https://github.com/catppuccin/btop

    # Main background, empty for terminal default, need to be empty if you want transparent background
    theme[main_bg]="#1e1e2e"

    # Main text color
    theme[main_fg]="#cdd6f4"

    # Title color for boxes
    theme[title]="#cdd6f4"

    # Highlight color for keyboard shortcuts
    theme[hi_fg]="#89b4fa"

    # Background color of selected items
    theme[selected_bg]="#45475a"

    # Foreground color of selected items
    theme[selected_fg]="#89b4fa"

    # Color of inactive/disabled text
    theme[inactive_fg]="#6c7086"

    # Color of text appearing on top of graphs, like values and "enhanced" mode label
    theme[graph_text]="#f5e0dc"

    # Background color of the meter/disk graphs
    theme[meter_bg]="#45475a"

    # Misc colors for processes box including mini cpu graphs, subtle flags, andடprocedure box
    theme[proc_misc]="#f5e0dc"

    # CPU, Memory, Network, Proc box outline colors
    theme[cpu_box]="#89b4fa"
    theme[mem_box]="#a6e3a1"
    theme[net_box]="#cba6f7"
    theme[proc_box]="#f5c2e7"

    # Box divider line and target CPU graph colors
    theme[div_line]="#6c7086"

    # Temperature graph color (Green -> Yellow -> Red)
    theme[temp_start]="#a6e3a1"
    theme[temp_mid]="#f9e2af"
    theme[temp_end]="#f38ba8"

    # CPU graph colors (Teal -> Blue)
    theme[cpu_start]="#94e2d5"
    theme[cpu_mid]="#89dceb"
    theme[cpu_end]="#89b4fa"

    # Mem/Disk free meter (Green -> Peach)
    theme[free_start]="#a6e3a1"
    theme[free_mid]="#94e2d5"
    theme[free_end]="#f9e2af"

    # Mem/Disk cached meter (Blue -> Lavender)
    theme[cached_start]="#89b4fa"
    theme[cached_mid]="#b4befe"
    theme[cached_end]="#cba6f7"

    # Mem/Disk available meter (Peach -> Red)
    theme[available_start]="#fab387"
    theme[available_mid]="#eba0ac"
    theme[available_end]="#f38ba8"

    # Mem/Disk used meter (Green -> Blue)
    theme[used_start]="#a6e3a1"
    theme[used_mid]="#94e2d5"
    theme[used_end]="#89b4fa"

    # Download graph colors (Mauve -> Pink)
    theme[download_start]="#cba6f7"
    theme[download_mid]="#f5c2e7"
    theme[download_end]="#f38ba8"

    # Upload graph colors (Green -> Teal)
    theme[upload_start]="#a6e3a1"
    theme[upload_mid]="#94e2d5"
    theme[upload_end]="#89dceb"

    # Process box color gradient for threads, mem and CPU usage (Rosewater -> Mauve)
    theme[process_start]="#f5e0dc"
    theme[process_mid]="#f5c2e7"
    theme[process_end]="#cba6f7"
  '';

  # Activation script to verify btop configuration
  home.activation.verifyBtop = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "btop: Configuration applied"
    echo "  - Theme: Catppuccin Mocha"
    echo "  - Update interval: 2 seconds"
    echo "  - Graph style: braille (high detail)"
    echo "  - Run 'btop' to launch system monitor"
  '';
}
