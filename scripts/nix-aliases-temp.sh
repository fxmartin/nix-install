#!/usr/bin/env bash
# ABOUTME: Temporary Nix system management aliases
# ABOUTME: Add to ~/.zshrc until Epic-04 enables Home Manager shell configuration
#
# Usage:
#   echo "source ~/Documents/nix-install/scripts/nix-aliases-temp.sh" >> ~/.zshrc
#   source ~/.zshrc

# Nix system management aliases
alias nix-update='bash ~/Documents/nix-install/scripts/update-system.sh update'
alias nix-rebuild='bash ~/Documents/nix-install/scripts/update-system.sh rebuild'
alias nix-full='bash ~/Documents/nix-install/scripts/update-system.sh full'

# Quick rebuild shortcut (auto-detects profile)
alias rebuild='bash ~/Documents/nix-install/scripts/update-system.sh rebuild'

echo "✓ Nix system management aliases loaded"
echo "  - nix-update: Update flake.lock only"
echo "  - nix-rebuild: Rebuild system (auto-detect profile)"
echo "  - nix-full: Update + rebuild"
echo "  - rebuild: Quick rebuild shortcut"
