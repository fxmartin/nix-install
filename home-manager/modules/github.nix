# ABOUTME: GitHub CLI configuration via Home Manager programs.gh module
# ABOUTME: Provides declarative configuration for GitHub operations

{ ... }:

{
  # GitHub CLI (gh) - Declarative configuration
  # NOTE: gh INSTALLATION moved to darwin/homebrew.nix (Story 01.6-002 fix)
  #       Reason: Homebrew makes gh available immediately after darwin-rebuild
  #               Home Manager installation requires shell reload for PATH update
  #               Bootstrap Phase 6 needs gh available in same shell session
  # Reference: mlgruby-repo-for-reference/home-manager/modules/github.nix
  programs.gh = {
    enable = true; # Still enable for configuration management

    settings = {
      # Use SSH protocol for GitHub operations (git clone, push, pull)
      # This aligns with our SSH key authentication strategy
      git_protocol = "ssh";

      # Default editor for gh pr create, gh issue create, etc.
      # Will be updated to match user's preferred editor in Epic-04
      editor = "vim";
    };
  };
}
