#!/usr/bin/env bats
# ABOUTME: Tests shared nix-darwin system packages available across all profiles
# ABOUTME: Guards common developer tooling that should not be profile-specific

setup() {
    DARWIN_CONFIG="${BATS_TEST_DIRNAME}/../darwin/configuration.nix"
    HOMEBREW_CONFIG="${BATS_TEST_DIRNAME}/../darwin/homebrew.nix"
}

@test "pkgconf remains declarative for native extension builds" {
    run rg -n '"pkgconf"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]
}

common_package_lines() {
    local package_name="$1"

    awk -v package_name="$package_name" '
        /lib\.optionals/ {
            in_profile_specific_block = 1
        }
        in_profile_specific_block && /^[[:space:]]*\][[:space:]]*$/ {
            in_profile_specific_block = 0
            next
        }
        !in_profile_specific_block && $0 ~ "^[[:space:]]*" package_name "([[:space:]]|#)" {
            print
        }
    ' "$DARWIN_CONFIG"
}

@test "bats is installed in shared system packages for every profile" {
    run common_package_lines bats
    [ "$status" -eq 0 ]
    [[ "$output" == *"bats"* ]]
}

@test "Bun is installed in shared system packages for every profile" {
    run common_package_lines bun
    [ "$status" -eq 0 ]
    [[ "$output" == *"bun"* ]]
}

@test "Xcode ships via mas only on the Power profile" {
    run bash -c "sed -n '/optionalAttrs (profileName == \"power\")/,/}/p' '$HOMEBREW_CONFIG' | rg '\"Xcode\" = 497799835'"
    [ "$status" -eq 0 ]

    run bash -c "sed -n '/masApps = /,/optionalAttrs/p' '$HOMEBREW_CONFIG' | rg '\"Xcode\"'"
    [ "$status" -eq 1 ]
}

@test "local model stores share one root on every profile" {
    # llama.cpp (GGUF) and oMLX (MLX safetensors) hold different artefacts, so a
    # shared root saves no disk - it exists so one retention rule and one digest
    # line can cover all local model storage. Ollama cannot join: its models are
    # content-addressed blobs in ~/.ollama/models, not a plain directory.
    run rg -n 'LLAMA_CACHE' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]

    run rg -n 'OMLX_MODEL_DIR' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]

    # Both must sit under the same parent so disk-cleanup can sweep one path
    run rg -n 'localModelRoot' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]

    # llama.cpp ships on every profile (homebrew.nix base brews), so the cache
    # vars must not be Power-gated or the other Macs grow an invisible default
    # cache the digest never sees. Only JAVA_HOME stays behind the Power gate.
    run rg -n 'environment\.variables = lib\.mkIf' "$DARWIN_CONFIG"
    [ "$status" -eq 1 ]

    run bash -c "rg -A3 'optionalAttrs isPowerProfile' '$DARWIN_CONFIG' | rg 'JAVA_HOME'"
    [ "$status" -eq 0 ]
}

@test "weekly digest reports the local model root and legacy model-shelf store" {
    digest="${BATS_TEST_DIRNAME}/../scripts/weekly-maintenance-digest.sh"

    # The shared root exists so "one digest line can cover all local model
    # storage" — without these consumers the promise is empty.
    run rg -n '"local_models"' "$digest"
    [ "$status" -eq 0 ]

    run rg -n '"model_shelf"' "$digest"
    [ "$status" -eq 0 ]
}

@test "start-ollama.sh points Ollama at the external model directory" {
    script="${BATS_TEST_DIRNAME}/../scripts/start-ollama.sh"

    # The script's whole purpose is keeping weights off the internal disk; if
    # OLLAMA_MODELS is not exported, ollama serve silently uses ~/.ollama/models
    # and the mounted-volume checks are theater.
    run rg -n 'OLLAMA_MODELS=.*MODEL_DIR' "$script"
    [ "$status" -eq 0 ]

    # And it must survive into the launchd-submitted environment. Match the
    # submit line's OLLAMA_MODELS='...' directly (single-quoted, unlike the
    # export) — piping rg context lines breaks under max-columns truncation.
    run rg "OLLAMA_MODELS='" "$script"
    [ "$status" -eq 0 ]
}

@test "disk-cleanup prunes the local model root" {
    cleanup="${BATS_TEST_DIRNAME}/../scripts/disk-cleanup.sh"

    run rg -n 'cleanup_local_models' "$cleanup"
    [ "$status" -eq 0 ]

    # Reported in the analyze pass too, or it stays invisible until it is huge
    run rg -n 'local_models_size|Local model' "$cleanup"
    [ "$status" -eq 0 ]
}

@test "1Password CLI ships via Homebrew on the Power profile only" {
    # Homebrew, not Nix: FX verified the brew formula works with the desktop
    # app's biometric integration, and it is 1Password's own documented path.
    run bash -c "sed -n '/optionals (profileName == \"power\")/,/\]/p' '$HOMEBREW_CONFIG' | rg '\"1password-cli\"'"
    [ "$status" -eq 0 ]

    # Must not leak into the Nix system package set
    run rg -n '_1password-cli' "$DARWIN_CONFIG"
    [ "$status" -eq 1 ]

    run rg -n 'OP_BIOMETRIC_UNLOCK_ENABLED' "$HOMEBREW_CONFIG"
    [ "$status" -eq 0 ]
}

@test "the JDK ships only with the Power profile, with JAVA_HOME set" {
    run bash -c "sed -n '/lib.optionals isPowerProfile \[/,/^[[:space:]]*\]/p' '$DARWIN_CONFIG' | rg '^[[:space:]]+jdk([[:space:]]|#)'"
    [ "$status" -eq 0 ]

    run common_package_lines jdk
    [ "$output" = "" ]

    # A JDK on PATH without JAVA_HOME half-works: java runs, but Maven/Gradle
    # and IDE integrations that resolve the toolchain by env var do not.
    run rg -n 'JAVA_HOME' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]
}

@test "gitlab-runner ships only with the Power profile" {
    run bash -c "sed -n '/lib.optionals isPowerProfile \[/,/^[[:space:]]*\]/p' '$DARWIN_CONFIG' | rg '^[[:space:]]+gitlab-runner([[:space:]]|#)'"
    [ "$status" -eq 0 ]

    run common_package_lines gitlab-runner
    [ "$output" = "" ]
}
