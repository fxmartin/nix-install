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
  #
  # IMPORTANT (Hotfix #11 - Issue #18):
  # programs.gh.settings has been REMOVED to fix bootstrap GitHub CLI authentication.
  #
  # Problem: When programs.gh.settings is defined, Home Manager creates
  #          ~/.config/gh/config.yml as a READ-ONLY symlink to /nix/store.
  #          This prevents `gh auth login` from writing authentication tokens,
  #          causing bootstrap Phase 6 to fail with "permission denied".
  #
  # Solution: Remove settings block, let GitHub CLI manage its own config.
  #          Users can configure gh settings after first authentication:
  #            gh config set git_protocol ssh
  #            gh config set editor vim
  #
  # Trade-off: Loses declarative control of gh settings, but enables
  #           successful bootstrap and normal GitHub CLI workflow.
  #
  programs.gh = {
    enable = true; # Keep enabled for package management only
    # settings = {...}; ← REMOVED (Hotfix #11 - Issue #18)
  };
}
