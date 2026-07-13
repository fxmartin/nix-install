#!/usr/bin/env bats
# ABOUTME: Regression tests for rebuild blockers caused by upstream option churn
# ABOUTME: Guards local mitigations for nix-darwin docs and Home Manager fzf renames

setup() {
    DARWIN_CONFIG="${BATS_TEST_DIRNAME}/../darwin/configuration.nix"
    HOMEBREW_MODULE="${BATS_TEST_DIRNAME}/../darwin/homebrew.nix"
    SHELL_MODULE="${BATS_TEST_DIRNAME}/../home-manager/modules/shell.nix"
}

@test "nix-darwin generated documentation is disabled" {
    run rg -n 'enable = false;|doc\.enable = false;|info\.enable = false;|man\.enable = false;' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]
    [[ "$output" == *"enable = false"* ]]
    [[ "$output" == *"doc.enable = false"* ]]
    [[ "$output" == *"info.enable = false"* ]]
    [[ "$output" == *"man.enable = false"* ]]
}

@test "nix-darwin uninstaller is disabled to avoid broken manual dependency" {
    run rg -n 'system\.tools\.darwin-uninstaller\.enable = false;' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]
}

@test "fzf widgets use current Home Manager option names" {
    run rg -n 'fileWidget = \{|changeDirWidget = \{|historyWidget\.options' "$SHELL_MODULE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"fileWidget"* ]]
    [[ "$output" == *"changeDirWidget"* ]]
    [[ "$output" == *"historyWidget.options"* ]]
}

@test "fzf widgets do not use renamed Home Manager option names" {
    run rg -n 'fileWidgetCommand|fileWidgetOptions|changeDirWidgetCommand|changeDirWidgetOptions|historyWidgetOptions' "$SHELL_MODULE"
    [ "$status" -eq 1 ]
}

@test "starship binary comes from Homebrew to avoid Darwin Rust linker failure" {
    run rg -n '"starship"[[:space:]]+# Starship prompt binary' "$HOMEBREW_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'package = pkgs\.writeShellScriptBin "starship"' "$SHELL_MODULE"
    [ "$status" -eq 0 ]

    run rg -n '/opt/homebrew/bin/starship' "$SHELL_MODULE"
    [ "$status" -eq 0 ]
}
