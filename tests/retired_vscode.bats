#!/usr/bin/env bats
# ABOUTME: Guards retirement of Visual Studio Code from the managed application stack
# ABOUTME: Keeps Zed and shared language servers while preventing VS Code redeployment

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    HOMEBREW_CONFIG="${REPO_ROOT}/darwin/homebrew.nix"
    HOME_CONFIG="${REPO_ROOT}/home-manager/home.nix"
    BOOTSTRAP_FETCHER="${REPO_ROOT}/lib/nix-darwin.sh"
}

@test "Homebrew no longer installs Visual Studio Code" {
    run rg -n '"visual-studio-code"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]
}

@test "Home Manager no longer imports the VS Code module" {
    run rg -n 'modules/vscode\.nix' "$HOME_CONFIG" "$BOOTSTRAP_FETCHER"
    [ "$status" -eq 1 ]
}

@test "retired VS Code implementation files are absent" {
    [ ! -e "${REPO_ROOT}/home-manager/modules/vscode.nix" ]
    [ ! -e "${REPO_ROOT}/config/vscode/settings.json" ]
    [ ! -e "${REPO_ROOT}/docs/apps/dev/vscode.md" ]
}

@test "current application documentation no longer advertises VS Code" {
    run rg -n -i 'visual studio code|vscode|VS Code' \
        "${REPO_ROOT}/README.md" \
        "${REPO_ROOT}/CLAUDE.md" \
        "${REPO_ROOT}/docs/REQUIREMENTS.md" \
        "${REPO_ROOT}/docs/apps/README.md"
    [ "$status" -eq 1 ]
}
