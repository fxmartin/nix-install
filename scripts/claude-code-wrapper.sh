#!/usr/bin/env bash
# ABOUTME: Wrapper script for Claude Code CLI that auto-detects macOS appearance
# ABOUTME: and sets the appropriate theme (light/dark) before launching

set -euo pipefail

# =============================================================================
# CLAUDE CODE AUTO-THEME WRAPPER
# =============================================================================
# This script detects macOS light/dark mode and updates Claude Code's theme
# setting before launching. Works around the lack of native auto-theme support.
#
# GitHub Issue tracking this feature:
# https://github.com/anthropics/claude-code/issues/11813
#
# Usage: claude-code-wrapper.sh [claude-code-args...]
# =============================================================================

SETTINGS_FILE="${HOME}/.claude/settings.json"

# Detect macOS appearance (returns "Dark" or "Light")
get_macos_appearance() {
    local appearance
    appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
    echo "$appearance"
}

# Update Claude Code theme in settings.json
update_claude_theme() {
    local theme="$1"

    # Ensure settings directory exists
    mkdir -p "${HOME}/.claude"

    # If settings file doesn't exist, create it with theme
    if [[ ! -f "$SETTINGS_FILE" ]]; then
        echo "{\"theme\": \"$theme\"}" > "$SETTINGS_FILE"
        return
    fi

    # Check if jq is available for proper JSON manipulation
    if command -v jq &>/dev/null; then
        # Use jq for safe JSON manipulation
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg theme "$theme" '.theme = $theme' "$SETTINGS_FILE" > "$tmp_file" && mv "$tmp_file" "$SETTINGS_FILE"
    else
        # Fallback: sed-based replacement (less safe but works for simple cases)
        if grep -q '"theme"' "$SETTINGS_FILE"; then
            # Replace existing theme value
            sed -i '' "s/\"theme\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"theme\": \"$theme\"/" "$SETTINGS_FILE"
        else
            # Add theme to existing JSON (assumes valid JSON object)
            sed -i '' "s/^{/{\"theme\": \"$theme\", /" "$SETTINGS_FILE"
        fi
    fi
}

# Main logic
main() {
    local appearance theme

    # Detect current macOS appearance
    appearance=$(get_macos_appearance)

    # Map appearance to Claude Code theme
    if [[ "$appearance" == "Dark" ]]; then
        theme="dark"
    else
        theme="light"
    fi

    # Update settings
    update_claude_theme "$theme"

    # Launch Claude Code with all passed arguments
    exec claude "$@"
}

main "$@"
