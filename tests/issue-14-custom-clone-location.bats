# ABOUTME: Test suite for Issue #14 - Configurable repository clone location via NIX_INSTALL_DIR
# ABOUTME: Tests environment variable override for custom clone paths

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

#############################################################################
# NIX_INSTALL_DIR ENVIRONMENT VARIABLE TESTS
#############################################################################
# Note: These tests spawn subshells to avoid readonly variable conflicts

@test "REPO_CLONE_DIR: uses default ~/Documents/nix-install when NIX_INSTALL_DIR not set" {
    # Test in subshell to avoid readonly variable conflicts
    run bash -c 'unset NIX_INSTALL_DIR; source ./bootstrap.sh; echo "$REPO_CLONE_DIR"'
    assert_success
    assert_output "${HOME}/Documents/nix-install"
}

@test "REPO_CLONE_DIR: respects NIX_INSTALL_DIR=~/nix-install" {
    run bash -c 'export NIX_INSTALL_DIR="${HOME}/nix-install"; source ./bootstrap.sh; echo "$REPO_CLONE_DIR"'
    assert_success
    assert_output "${HOME}/nix-install"
}

@test "REPO_CLONE_DIR: respects NIX_INSTALL_DIR=~/.nix-install (hidden directory)" {
    run bash -c 'export NIX_INSTALL_DIR="${HOME}/.nix-install"; source ./bootstrap.sh; echo "$REPO_CLONE_DIR"'
    assert_success
    assert_output "${HOME}/.nix-install"
}

@test "REPO_CLONE_DIR: respects NIX_INSTALL_DIR=~/.config/nix-install (XDG path)" {
    run bash -c 'export NIX_INSTALL_DIR="${HOME}/.config/nix-install"; source ./bootstrap.sh; echo "$REPO_CLONE_DIR"'
    assert_success
    assert_output "${HOME}/.config/nix-install"
}

@test "REPO_CLONE_DIR: handles absolute path with NIX_INSTALL_DIR" {
    run bash -c 'export NIX_INSTALL_DIR="/opt/nix-install"; source ./bootstrap.sh; echo "$REPO_CLONE_DIR"'
    assert_success
    assert_output "/opt/nix-install"
}

#############################################################################
# DOTFILES PATH DERIVATION TESTS
#############################################################################

@test "dotfiles_path derivation: Documents/nix-install from default REPO_CLONE_DIR" {
    # Test the bash parameter expansion logic
    run bash -c 'REPO_CLONE_DIR="${HOME}/Documents/nix-install"; echo "${REPO_CLONE_DIR#${HOME}/}"'
    assert_success
    assert_output "Documents/nix-install"
}

@test "dotfiles_path derivation: nix-install from ~/nix-install" {
    run bash -c 'REPO_CLONE_DIR="${HOME}/nix-install"; echo "${REPO_CLONE_DIR#${HOME}/}"'
    assert_success
    assert_output "nix-install"
}

@test "dotfiles_path derivation: .nix-install from ~/.nix-install" {
    run bash -c 'REPO_CLONE_DIR="${HOME}/.nix-install"; echo "${REPO_CLONE_DIR#${HOME}/}"'
    assert_success
    assert_output ".nix-install"
}

@test "dotfiles_path derivation: .config/nix-install from ~/.config/nix-install" {
    run bash -c 'REPO_CLONE_DIR="${HOME}/.config/nix-install"; echo "${REPO_CLONE_DIR#${HOME}/}"'
    assert_success
    assert_output ".config/nix-install"
}

@test "dotfiles_path derivation: handles absolute path outside HOME" {
    # When path is outside HOME, the substitution doesn't work and we get the full path
    run bash -c 'REPO_CLONE_DIR="/opt/nix-install"; echo "${REPO_CLONE_DIR#${HOME}/}"'
    assert_success
    assert_output "/opt/nix-install"
}

#############################################################################
# INTEGRATION TESTS
#############################################################################

@test "Integration: NIX_INSTALL_DIR affects both REPO_CLONE_DIR and dotfiles_path consistently" {
    run bash -c 'export NIX_INSTALL_DIR="${HOME}/my-custom-nix"; source ./bootstrap.sh; DOTFILES="${REPO_CLONE_DIR#${HOME}/}"; echo "$REPO_CLONE_DIR|$DOTFILES"'
    assert_success
    assert_output "${HOME}/my-custom-nix|my-custom-nix"
}

@test "Integration: default path maintains backward compatibility" {
    run bash -c 'unset NIX_INSTALL_DIR; source ./bootstrap.sh; DOTFILES="${REPO_CLONE_DIR#${HOME}/}"; echo "$REPO_CLONE_DIR|$DOTFILES"'
    assert_success
    assert_output "${HOME}/Documents/nix-install|Documents/nix-install"
}

#############################################################################
# EDGE CASE TESTS
#############################################################################

@test "Edge case: NIX_INSTALL_DIR with trailing slash is handled correctly" {
    # Note: bash parameter expansion doesn't automatically strip trailing slashes
    # This documents current behavior - may want to improve in future
    run bash -c 'export NIX_INSTALL_DIR="${HOME}/nix-install/"; source ./bootstrap.sh; echo "$REPO_CLONE_DIR"'
    assert_success
    assert_output "${HOME}/nix-install/"
}

@test "Edge case: empty NIX_INSTALL_DIR falls back to default" {
    # Empty string should trigger default fallback via :- operator
    run bash -c 'export NIX_INSTALL_DIR=""; source ./bootstrap.sh; echo "$REPO_CLONE_DIR"'
    assert_success
    assert_output "${HOME}/Documents/nix-install"
}

@test "Edge case: NIX_INSTALL_DIR with spaces (documented limitation)" {
    # Note: Paths with spaces require careful quoting throughout bootstrap
    # This test documents the expected behavior
    run bash -c 'export NIX_INSTALL_DIR="${HOME}/My Nix Install"; source ./bootstrap.sh; echo "$REPO_CLONE_DIR"'
    assert_success
    assert_output "${HOME}/My Nix Install"
}
