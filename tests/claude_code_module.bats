#!/usr/bin/env bats
# ABOUTME: Regression tests for Claude Code / Codex Home Manager activation behavior
# ABOUTME: Guards Codex plugin marketplace registration so home-local plugins become available

@test "claude-code activation registers the home-local Codex marketplace" {
    run rg -n -F 'plugin marketplace add "${config.home.homeDirectory}"' \
        "${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"
    [ "$status" -eq 0 ]
}

@test "claude-code activation still writes the home-local Codex marketplace manifest" {
    module="${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"

    run rg -n -F 'CODEX_AGENTS_DIR="${config.home.homeDirectory}/.agents/plugins"' "$module"
    [ "$status" -eq 0 ]

    run rg -n -F 'CODEX_MARKETPLACE="$CODEX_AGENTS_DIR/marketplace.json"' \
        "${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"
    [ "$status" -eq 0 ]
}

@test "claude-code activation marks autonomous-sdlc installed by default" {
    run rg -n '"installation": "INSTALLED_BY_DEFAULT"' \
        "${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"
    [ "$status" -eq 0 ]
}

@test "claude settings disable updater telemetry surveys and push notifications" {
    settings="${BATS_TEST_DIRNAME}/../config/claude-code-config/settings.json"

    run jq -e '
        .agentPushNotifEnabled == false
        and .feedbackSurveyRate == 0
        and .env.DISABLE_AUTOUPDATER == "1"
        and .env.CLAUDE_CODE_ENABLE_TELEMETRY == "0"
        and .env.CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY == "1"
        and .env.OTEL_METRICS_EXPORTER == "none"
        and .env.OTEL_TRACES_EXPORTER == "none"
        and .env.OTEL_LOGS_EXPORTER == "none"
    ' "$settings"
    [ "$status" -eq 0 ]
}

@test "shell exports Claude telemetry and updater off-switches" {
    module="${BATS_TEST_DIRNAME}/../home-manager/modules/shell.nix"

    run rg -n 'DISABLE_AUTOUPDATER = "1";' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'CLAUDE_CODE_ENABLE_TELEMETRY = "0";' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'OTEL_METRICS_EXPORTER = "none";' "$module"
    [ "$status" -eq 0 ]
}

@test "codex activation disables update checks and telemetry exporter" {
    module="${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"

    run rg -n 'check_for_update_on_startup = false' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'exporter = \\"none\\"' "$module"
    [ "$status" -eq 0 ]
}

@test "qwen activation disables update telemetry prompt logging and usage stats" {
    module="${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"

    run rg -n 'general.enableAutoUpdate = false' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'privacy.usageStatisticsEnabled = false' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'telemetry.enabled = false' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'telemetry.logPrompts = false' "$module"
    [ "$status" -eq 0 ]
}

@test "opencode activation disables update checks and sharing" {
    module="${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"

    run rg -n 'autoupdate = false' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'share = "disabled"' "$module"
    [ "$status" -eq 0 ]
}
