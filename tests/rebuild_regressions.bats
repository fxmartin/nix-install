#!/usr/bin/env bats
# ABOUTME: Regression tests for rebuild blockers caused by upstream option churn
# ABOUTME: Guards local mitigations for nix-darwin docs and Home Manager fzf renames

setup() {
    DARWIN_CONFIG="${BATS_TEST_DIRNAME}/../darwin/configuration.nix"
    HOMEBREW_MODULE="${BATS_TEST_DIRNAME}/../darwin/homebrew.nix"
    SHELL_MODULE="${BATS_TEST_DIRNAME}/../home-manager/modules/shell.nix"
    BUILD_WORKFLOW="${BATS_TEST_DIRNAME}/../.github/workflows/build-bootstrap.yml"
    NIX_WORKFLOW="${BATS_TEST_DIRNAME}/../.github/workflows/nix-flake-check.yml"
    SCRIPTS_WORKFLOW="${BATS_TEST_DIRNAME}/../.github/workflows/scripts-ci.yml"
    MAKEFILE="${BATS_TEST_DIRNAME}/../Makefile"
    BUMP_VERSION_SCRIPT="${BATS_TEST_DIRNAME}/../scripts/bump-version.sh"
    PYTHON_MODULE="${BATS_TEST_DIRNAME}/../home-manager/modules/python.nix"
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

@test "bootstrap CI limits shellcheck to supported shell sources" {
    run rg -n 'run: shellcheck --severity=error bootstrap\.sh lib/\*\.sh' "$BUILD_WORKFLOW"
    [ "$status" -eq 0 ]

    run rg -n "scandir: ['\"]?\.['\"]?" "$BUILD_WORKFLOW"
    [ "$status" -eq 1 ]
}

@test "Nix CI checks out and watches CLAUDE.md, not the dead 'Claude' path" {
    run rg -n 'submodules: recursive' "$NIX_WORKFLOW"
    [ "$status" -eq 0 ]

    run rg -n -- "- 'CLAUDE.md'" "$NIX_WORKFLOW"
    [ "$status" -eq 0 ]

    run rg -n -- "- 'Claude'" "$NIX_WORKFLOW"
    [ "$status" -eq 1 ]
}

@test "scripts CI lints setup.sh and scripts/** on every touching PR" {
    run rg -n "^      - 'scripts/\*\*'" "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 0 ]

    run rg -n "^      - 'setup\.sh'" "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 0 ]

    run rg -n '^\s*pull_request:' "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 0 ]

    run rg -n 'shellcheck' "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 0 ]

    run rg -n 'bash -n' "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 0 ]
}

@test "scripts CI triggers on push and pull_request against main, plus manual dispatch" {
    run rg -n '^\s*push:' "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 0 ]

    run rg -n "^\s*branches: \[main\]" "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 0 ]
    [ "$(wc -l <<< "$output")" -eq 2 ]

    run rg -n '^\s*workflow_dispatch:' "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 0 ]
}

@test "scripts CI explicitly covers beszel-sensors since scripts/*.sh does not recurse" {
    run rg -c "scripts/beszel-sensors/\*\.sh" "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 0 ]
    [ "$output" -eq 2 ]
}

@test "scripts CI fails the job on syntax or shellcheck errors instead of swallowing them" {
    run rg -n 'exit 1' "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 0 ]

    run rg -n 'shellcheck --severity=warning .*\|\| true' "$SCRIPTS_WORKFLOW"
    [ "$status" -eq 1 ]
}

@test "make shellcheck covers setup.sh and beszel-sensors scripts" {
    run rg -n 'shellcheck --severity=warning .*\bsetup\.sh\b' "$MAKEFILE"
    [ "$status" -eq 0 ]

    run rg -n 'shellcheck --severity=warning .*scripts/beszel-sensors/\*\.sh' "$MAKEFILE"
    [ "$status" -eq 0 ]
}

@test "make shellcheck retains its original bootstrap, lib, scripts, and tests scope" {
    run rg -n 'shellcheck --severity=warning .*\bbootstrap\.sh\b' "$MAKEFILE"
    [ "$status" -eq 0 ]

    run rg -n 'shellcheck --severity=warning .*lib/\*\.sh' "$MAKEFILE"
    [ "$status" -eq 0 ]

    run rg -n 'shellcheck --severity=warning .*[^-]scripts/\*\.sh' "$MAKEFILE"
    [ "$status" -eq 0 ]

    run rg -n 'shellcheck --severity=warning .*tests/\*\.sh' "$MAKEFILE"
    [ "$status" -eq 0 ]
}

@test "make shellcheck actually passes over the current scripts/** and setup.sh tree" {
    cd "${BATS_TEST_DIRNAME}/.."
    run make shellcheck
    [ "$status" -eq 0 ]
}

@test "Nix evaluation uses the sanitized CI config in clean checkouts" {
    run rg -n '^\s*NIX_INSTALL_CI=1 nix flake show --impure' "$MAKEFILE"
    [ "$status" -eq 0 ]
}

@test "release checks enter the flake dev shell" {
    run rg -n '^\s*nix develop --command make check$' "$BUMP_VERSION_SCRIPT"
    [ "$status" -eq 0 ]

    run rg -n '^\s*make check$' "$BUMP_VERSION_SCRIPT"
    [ "$status" -eq 1 ]
}

@test "format check skips deleted tracked Nix files" {
    run rg -n 'test -f "\$\$file".*nixfmt --check "\$\$file"' "$MAKEFILE"
    [ "$status" -eq 0 ]
}

@test "nix-eval fails the build when any single profile fails to evaluate" {
    # Without an explicit exit, the shell for-loop returns the status of its LAST
    # iteration, so a broken Standard or Power profile passed both `make nix-eval`
    # and the Validate Nix Flake CI job as long as ai-assistant still evaluated.
    # Observed 2026-08-04: a type error in the Power profile evaluated to rc=0.
    run rg -n 'darwinConfigurations\.\$\$profile\.system\.drvPath.*\|\| exit 1' "$MAKEFILE"
    [ "$status" -eq 0 ]
}

@test "direnv Zsh hook uses the stable Home Manager profile path" {
    run rg -n 'enableZshIntegration = false;' "$PYTHON_MODULE"
    [ "$status" -eq 0 ]

    run rg -n 'config\.home\.profileDirectory}/bin/direnv.*hook zsh' "$PYTHON_MODULE"
    [ "$status" -eq 0 ]
}
