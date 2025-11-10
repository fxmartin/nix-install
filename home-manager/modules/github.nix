# ABOUTME: GitHub CLI configuration via Home Manager programs.gh module
# ABOUTME: Provides gh package installation and declarative configuration for GitHub operations

{ ... }:

{
  # GitHub CLI (gh) - Declarative installation and configuration
  # Reference: mlgruby-repo-for-reference/home-manager/modules/github.nix
  # Used by Story 01.6-002 for automated SSH key upload
  programs.gh = {
    enable = true;

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
