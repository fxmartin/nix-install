#!/usr/bin/env bash
# ABOUTME: Updates MCP server paths in Claude Code config files after nix rebuild
# ABOUTME: Finds current Nix store paths for Context7 and Sequential Thinking servers

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# Find current MCP server paths in Nix store using glob
find_mcp_path() {
    local pattern="$1"
    local binary="$2"
    local path=""

    # Use glob to find matching paths (fast for Nix store)
    # shellcheck disable=SC2231
    for p in /nix/store/*"${pattern}"*/bin/"${binary}"; do
        if [[ -x "${p}" ]]; then
            path="${p}"
        fi
    done

    echo "${path}"
}

# Update JSON file with new path using jq
update_json_path() {
    local file="$1"
    local server="$2"
    local new_path="$3"

    if [[ ! -f "${file}" ]]; then
        log_warn "File not found: ${file}"
        return 1
    fi

    # Check if jq is available
    if ! command -v jq &>/dev/null; then
        log_error "jq is required but not installed"
        return 1
    fi

    # Update the path in the JSON file
    local tmp_file
    tmp_file=$(mktemp)

    if jq --arg path "${new_path}" ".mcpServers.\"${server}\".command = \$path" "${file}" > "${tmp_file}"; then
        mv "${tmp_file}" "${file}"
        return 0
    else
        rm -f "${tmp_file}"
        return 1
    fi
}

main() {
    echo "Updating MCP server paths..."
    echo ""

    # Find current paths
    local context7_path sequential_path
    context7_path=$(find_mcp_path "context7-mcp" "context7-mcp")
    sequential_path=$(find_mcp_path "mcp-server-sequential-thinking" "mcp-server-sequential-thinking")

    # Verify all paths found
    local all_found=true

    if [[ -n "${context7_path}" ]]; then
        log_info "context7: ${context7_path}"
    else
        log_error "context7-mcp not found in Nix store"
        all_found=false
    fi

    if [[ -n "${sequential_path}" ]]; then
        log_info "sequential-thinking: ${sequential_path}"
    else
        log_error "mcp-server-sequential-thinking not found in Nix store"
        all_found=false
    fi

    if [[ "${all_found}" != "true" ]]; then
        log_error "Some MCP servers not found. Run 'darwin-rebuild switch' first."
        exit 1
    fi

    echo ""

    # Update ~/.claude.json
    local claude_json="${HOME}/.claude.json"
    if [[ -f "${claude_json}" ]]; then
        echo "Updating ${claude_json}..."

        # Check if mcpServers section exists
        if jq -e '.mcpServers' "${claude_json}" &>/dev/null; then
            update_json_path "${claude_json}" "context7" "${context7_path}"
            log_info "Updated context7 in ~/.claude.json"

            update_json_path "${claude_json}" "sequential-thinking" "${sequential_path}"
            log_info "Updated sequential-thinking in ~/.claude.json"
        else
            log_warn "No mcpServers section in ~/.claude.json - skipping"
        fi
    else
        log_warn "${HOME}/.claude.json not found"
    fi

    echo ""

    # Update ~/.config/claude/config.json
    local config_json="${HOME}/.config/claude/config.json"
    if [[ -f "${config_json}" ]]; then
        echo "Updating ${config_json}..."

        update_json_path "${config_json}" "context7" "${context7_path}"
        log_info "Updated context7 in config.json"

        update_json_path "${config_json}" "sequential-thinking" "${sequential_path}"
        log_info "Updated sequential-thinking in config.json"
    else
        log_warn "${HOME}/.config/claude/config.json not found"
    fi

    echo ""
    log_info "MCP paths updated successfully!"
    echo ""
    echo "Verify with: claude mcp list"
}

main "$@"
