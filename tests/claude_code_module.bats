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

    run rg -n 'awk = pkgs.gawk;' "$module"
    [ "$status" -eq 0 ]

    run rg -n '\$\{awk\}/bin/awk' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'check_for_update_on_startup = false' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'exporter = \\"none\\"' "$module"
    [ "$status" -eq 0 ]
}

@test "codex activation does not redeploy removed GitHub MCP server" {
    module="${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"
    removed_server='git''nexus'

    run rg -n -i "$removed_server" "$module"
    [ "$status" -eq 1 ]
}

@test "codex activation checks Homebrew cask CLI path" {
    module="${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"

    run rg -n '/opt/homebrew/bin/codex' "$module"
    [ "$status" -eq 0 ]
}

@test "codex cleanup is deployed and exposed through the shell" {
    run rg -n -F '"codex-cleanup.sh"' \
        "${BATS_TEST_DIRNAME}/../darwin/configuration.nix"
    [ "$status" -eq 0 ]

    run rg -n -F 'codex-cleanup = "bash ${dotfilesPath}/scripts/codex-cleanup.sh";' \
        "${BATS_TEST_DIRNAME}/../home-manager/modules/shell.nix"
    [ "$status" -eq 0 ]
}

@test "disk cleanup analyze mode includes the guarded Codex report" {
    run rg -n -F '"${CODEX_CLEANUP}" --analyze' \
        "${BATS_TEST_DIRNAME}/../scripts/disk-cleanup.sh"
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

@test "opencode declares the local Ollama provider on the loopback endpoint" {
    module="${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"

    # Provider must speak the OpenAI-compatible API against Ollama's loopback bind
    run rg -n -F '@ai-sdk/openai-compatible' "$module"
    [ "$status" -eq 0 ]

    run rg -n -F 'http://127.0.0.1:11434/v1' "$module"
    [ "$status" -eq 0 ]

    # Every baseURL must route through the loopback constant asserted above —
    # a literal URL here would let a non-loopback endpoint slip in unnoticed.
    run bash -c "rg -n -o '\"baseURL\": \"http[^\"]*\"' '$module'"
    [ "$status" -eq 1 ]
}

@test "opencode defaults to the local coding model only on the Power profile" {
    module="${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"

    # Must point at the derived model (Modelfile-built), not the raw pull
    run rg -n -F 'qwen3.6-coding:opencode' "$module"
    [ "$status" -eq 0 ]

    # The default-model assignment must be gated behind the power profile
    run rg -n 'profileName == "power"' "$module"
    [ "$status" -eq 0 ]
}

@test "opencode pins Qwen3.6 sampling params instead of inheriting OpenCode's Qwen default" {
    module="${BATS_TEST_DIRNAME}/../home-manager/modules/claude-code.nix"

    # Absent explicit config OpenCode sends temperature 0.55 for Qwen models,
    # which would override the Modelfile's baked-in value.
    run rg -n 'localCodingTemperature = "0.6"' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'localCodingTopP = "0.95"' "$module"
    [ "$status" -eq 0 ]

    run rg -n 'localCodingContext = "48000"' "$module"
    [ "$status" -eq 0 ]
}

@test "coding Modelfile carries the params the OpenAI-compatible API cannot express" {
    modelfile="${BATS_TEST_DIRNAME}/../config/ollama/qwen3.6-coding.Modelfile"

    [ -f "$modelfile" ]

    # repeat_penalty must be 1.0 — Ollama defaults to 1.1, which penalises the
    # legitimate repetition source code is made of.
    run rg -n '^PARAMETER repeat_penalty 1.0$' "$modelfile"
    [ "$status" -eq 0 ]

    run rg -n '^PARAMETER top_k 20$' "$modelfile"
    [ "$status" -eq 0 ]

    run rg -n '^PARAMETER min_p 0.0$' "$modelfile"
    [ "$status" -eq 0 ]

    run rg -n '^PARAMETER num_ctx 48000$' "$modelfile"
    [ "$status" -eq 0 ]

    # Must build on the pulled base model, not a stale hardcoded tag
    run rg -n '^FROM qwen3.6:35b-a3b-coding-nvfp4$' "$modelfile"
    [ "$status" -eq 0 ]
}
