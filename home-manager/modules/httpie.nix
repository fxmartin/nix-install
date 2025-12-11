# ABOUTME: HTTPie configuration with sensible defaults
# ABOUTME: Modern HTTP client with developer-friendly defaults
{
  config,
  pkgs,
  lib,
  ...
}: {
  # httpie is already installed via darwin/configuration.nix
  # This module provides configuration via ~/.config/httpie/config.json

  # HTTPie configuration
  xdg.configFile."httpie/config.json".text = builtins.toJSON {
    # Default options applied to every request
    default_options = [
      # Pretty print output (colors + formatting)
      "--pretty=all"

      # Use colors
      "--style=monokai"

      # Follow redirects
      "--follow"

      # Show both request headers and body in verbose mode
      # (not enabled by default, use -v to see)
    ];

    # Implicit content type (when no Content-Type header is set)
    # "json" = application/json (default for HTTPie)
    # "form" = application/x-www-form-urlencoded
    implicit_content_type = "json";
  };

  # Activation script to verify HTTPie configuration
  home.activation.verifyHttpie = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "HTTPie: Configuration applied"
    echo "  - Config: ~/.config/httpie/config.json"
    echo "  - Style: monokai (dark theme)"
    echo "  - Pretty print: enabled"
    echo "  - Follow redirects: enabled"
    echo "  - Default content type: JSON"
    echo ""
    echo "  Usage examples:"
    echo "    http GET https://api.example.com/users"
    echo "    http POST https://api.example.com/users name=John"
    echo "    http PUT https://api.example.com/users/1 name=Jane"
    echo "    http DELETE https://api.example.com/users/1"
    echo "    http -v GET https://api.example.com/  # verbose mode"
  '';
}
