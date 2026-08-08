#!/usr/bin/env bats
# ABOUTME: Guards canonical ownership of packages shared across configuration layers
# ABOUTME: Prevents duplicate binaries from returning through Nix, Home Manager, and Homebrew

setup() {
    DARWIN_CONFIG="${BATS_TEST_DIRNAME}/../darwin/configuration.nix"
    HOMEBREW_CONFIG="${BATS_TEST_DIRNAME}/../darwin/homebrew.nix"
    HOME_CONFIG="${BATS_TEST_DIRNAME}/../home-manager/home.nix"
    GIT_CONFIG="${BATS_TEST_DIRNAME}/../home-manager/modules/git.nix"
    HOME_MANAGER_DIR="${BATS_TEST_DIRNAME}/../home-manager"
    BOOTSTRAP_PHASE5="${BATS_TEST_DIRNAME}/../lib/nix-darwin.sh"
    HOME_MANAGER_MODULES="${BATS_TEST_DIRNAME}/../home-manager/modules"
}

@test "Home Manager owned tools are absent from system packages" {
    for package_name in fzf bat btop; do
        run rg -n "^[[:space:]]+${package_name}[[:space:]]*(#.*)?$" "$DARWIN_CONFIG"
        [ "$status" -eq 1 ]
    done
}

@test "Home Manager configures Git without installing Git or Git LFS" {
    run rg -n '^[[:space:]]+package = null;' "$GIT_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n '^[[:space:]]+lfs\.package = null;' "$GIT_CONFIG"
    [ "$status" -eq 0 ]
}

@test "oMLX is installed from the notarized DMG, never Homebrew" {
    OMLX_MODULE="${BATS_TEST_DIRNAME}/../darwin/omlx.nix"

    [ -f "$OMLX_MODULE" ]

    # The Homebrew formula lives in an untrusted third-party tap whose trust
    # state (~/.homebrew/trust.json) cannot be declared, so a fresh machine
    # would fail at `brew bundle`. The notarized DMG carries an Apple-verified
    # Developer ID instead, and its checksum is pinned here.
    run rg -n '"omlx"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]

    run rg -n 'jundot' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]

    # The download must be pinned by checksum and verified before install
    run rg -n 'omlxSha256' "$OMLX_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'spctl' "$OMLX_MODULE"
    [ "$status" -eq 0 ]
}

@test "oMLX model directory is repointed at the shared local model root" {
    OMLX_MODULE="${BATS_TEST_DIRNAME}/../darwin/omlx.nix"

    # The OMLX_MODEL_DIR env var never reaches the menubar app — launchd does
    # not source /etc/zshenv — so activation must patch ~/.omlx/settings.json,
    # the app's authoritative config, to the shared root instead.
    run rg -n 'model_dir' "$OMLX_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'models/mlx' "$OMLX_MODULE"
    [ "$status" -eq 0 ]
}

@test "llama.cpp is owned only by Homebrew" {
    # nixpkgs also ships llama-cpp; declaring both would put two `llama-server`
    # binaries on PATH. Homebrew wins here because it tracks the project far
    # more closely (10250 vs 10133 at time of writing) and llama.cpp moves fast.
    run rg -n '"llama\.cpp"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n '^[[:space:]]+llama-cpp([[:space:]]|#)' "$DARWIN_CONFIG"
    [ "$status" -eq 1 ]
}

@test "GitHub CLI is owned only by Homebrew" {
    run rg -n '"gh"[[:space:]]+# GitHub CLI' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'programs\.gh|modules/github\.nix' "$HOME_CONFIG" "$HOME_MANAGER_DIR/modules"
    [ "$status" -eq 1 ]

    [ ! -e "${HOME_MANAGER_MODULES}/github.nix" ]
}

@test "phase 5 installs the whole repository instead of a curated file list" {
    # A per-file download list silently omits every module added after it was
    # last edited. The pinned clone cannot drift that way.
    run rg -n 'git clone --depth 1 --branch' "$BOOTSTRAP_PHASE5"
    [ "$status" -eq 0 ]

    run rg -n 'curl .*-o ' "$BOOTSTRAP_PHASE5"
    [ "$status" -eq 1 ]
}

@test "SDLC controller dependency is installed through Homebrew" {
    run rg -n '"osv-scanner"[[:space:]]+# OSV Scanner' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]
}

@test "skhd uses the current asmvik Homebrew tap" {
    run rg -n '"asmvik/formulae"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n '"asmvik/formulae/skhd"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'koekeishiya/formulae' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]
}

@test "Homebrew Starship bridge remains explicit" {
    run rg -n '"starship"[[:space:]]+# Starship prompt binary' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'exec /opt/homebrew/bin/starship' "$HOME_MANAGER_DIR/modules/shell.nix"
    [ "$status" -eq 0 ]
}
