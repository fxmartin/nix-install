# ABOUTME: btop system monitor configuration
# ABOUTME: Theming handled by Stylix (stylix.targets.btop.enable = true)
{
  config,
  pkgs,
  lib,
  ...
}: {
  # btop configuration via Home Manager
  # Theme is automatically applied by Stylix from the system Catppuccin Mocha palette
  programs.btop = {
    enable = true;

    settings = {
      # Theme is managed by Stylix - it generates the theme from system colors
      # Do NOT set color_theme here - Stylix handles it

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
      graph_symbol_cpu = "default";

      # Shown graph style for memory
      graph_symbol_mem = "default";

      # Shown graph style for network
      graph_symbol_net = "default";

      # Shown graph style for processes
      graph_symbol_proc = "default";

      # Time format (24h)
      clock_format = "%X";

      # Background update (update while unfocused)
      background_update = true;

      # Update time in milliseconds (2000 = 2 seconds, balanced)
      update_ms = 2000;

      # Process sorting
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

      # Show temperatures
      show_cpu_freq = true;

      # Draw a clock at top of screen
      draw_clock = "%X";

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

      # Logging level
      log_level = "WARNING";
    };
  };

  # Activation script to verify btop configuration
  home.activation.verifyBtop = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "btop: Configuration applied"
    echo "  - Theme: Managed by Stylix (Catppuccin Mocha)"
    echo "  - Update interval: 2 seconds"
    echo "  - Graph style: braille (high detail)"
    echo "  - Run 'btop' to launch system monitor"
  '';
}
