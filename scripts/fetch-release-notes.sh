#!/usr/bin/env bash
# ABOUTME: Fetches release notes from macOS, Homebrew, Nix/nix-darwin, and Ollama
# ABOUTME: Outputs structured JSON for Claude CLI analysis (Story 06.6-001)

set -euo pipefail

# Configuration
LOG_DIR="${HOME}/.local/log"
LOG_FILE="${LOG_DIR}/release-monitor.log"
OUTPUT_FILE="${1:-/tmp/release-notes.json}"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "${LOG_FILE}"
}

log "=== Starting release note fetch ==="

# Check for macOS system updates
fetch_macos_updates() {
    log "Checking for macOS updates..."

    local current_version current_build updates_available

    # Get current macOS version
    current_version=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
    current_build=$(sw_vers -buildVersion 2>/dev/null || echo "unknown")

    log "Current macOS: ${current_version} (${current_build})"

    # Check for available updates (this can take a few seconds)
    # softwareupdate -l lists available updates
    updates_available=$(softwareupdate -l 2>&1 || echo "")

    # Parse update information
    local update_count=0
    local updates_json="[]"

    if echo "${updates_available}" | grep -q "Software Update found"; then
        # Extract update names and versions
        updates_json=$(echo "${updates_available}" | \
            grep -E "^\*|Label:" | \
            sed 's/^\* Label: //' | \
            sed 's/^	Title: //' | \
            grep -v "^$" | \
            jq -R -s 'split("\n") | map(select(length > 0)) | map({name: ., recommended: (. | test("Security|macOS"))})' 2>/dev/null || echo "[]")
        update_count=$(echo "${updates_json}" | jq 'length' 2>/dev/null || echo "0")
    fi

    log "Found ${update_count} macOS update(s) available"

    jq -n \
        --arg current_version "${current_version}" \
        --arg current_build "${current_build}" \
        --argjson updates "${updates_json}" \
        --arg raw_output "$(echo "${updates_available}" | head -20)" \
        '{
            current_version: $current_version,
            current_build: $current_build,
            updates_available: $updates,
            update_count: ($updates | length),
            raw_check: $raw_output
        }'
}

# Fetch Homebrew outdated packages
fetch_homebrew_updates() {
    log "Fetching Homebrew updates..."

    # Update Homebrew quietly
    if ! brew update --force >/dev/null 2>&1; then
        log "WARNING: brew update failed"
    fi

    # Get outdated packages as JSON
    # --greedy: Also check casks with auto-update mechanisms (Chrome, VSCode, etc.)
    local result
    result=$(brew outdated --json=v2 --greedy 2>/dev/null || echo '{"formulae":[],"casks":[]}')

    # Count outdated items for logging
    local formulae_count casks_count
    formulae_count=$(echo "${result}" | jq '.formulae | length' 2>/dev/null || echo "0")
    casks_count=$(echo "${result}" | jq '.casks | length' 2>/dev/null || echo "0")
    log "Found ${formulae_count} outdated formulae, ${casks_count} outdated casks (greedy check)"

    echo "${result}"
}

# Fetch nixpkgs recent commits (nixpkgs-unstable branch)
fetch_nixpkgs_releases() {
    log "Fetching nixpkgs recent commits..."

    local result
    if command -v gh &>/dev/null; then
        # Get recent commits from nixpkgs-unstable branch
        result=$(gh api "repos/NixOS/nixpkgs/commits?sha=nixpkgs-unstable&per_page=5" \
            --jq '.[0:5] | map({
                sha: .sha[0:8],
                message: (.commit.message | split("\n")[0] | .[0:100]),
                author: .commit.author.name,
                date: .commit.author.date,
                url: .html_url
            })' 2>/dev/null || echo '[]')
    else
        log "WARNING: gh CLI not available, using curl fallback"
        result=$(curl -sL "https://api.github.com/repos/NixOS/nixpkgs/commits?sha=nixpkgs-unstable&per_page=5" 2>/dev/null | \
            jq 'map({
                sha: .sha[0:8],
                message: (.commit.message | split("\n")[0] | .[0:100]),
                author: .commit.author.name,
                date: .commit.author.date,
                url: .html_url
            })' 2>/dev/null || echo '[]')
    fi

    local count
    count=$(echo "${result}" | jq 'length' 2>/dev/null || echo "0")
    log "Retrieved ${count} nixpkgs commits"

    echo "${result}"
}

# Fetch nix-darwin recent commits (master branch)
fetch_nix_darwin_releases() {
    log "Fetching nix-darwin recent commits..."

    local result
    if command -v gh &>/dev/null; then
        # Get recent commits from master branch
        result=$(gh api "repos/LnL7/nix-darwin/commits?sha=master&per_page=5" \
            --jq '.[0:5] | map({
                sha: .sha[0:8],
                message: (.commit.message | split("\n")[0] | .[0:100]),
                author: .commit.author.name,
                date: .commit.author.date,
                url: .html_url
            })' 2>/dev/null || echo '[]')
    else
        log "WARNING: gh CLI not available, using curl fallback"
        result=$(curl -sL "https://api.github.com/repos/LnL7/nix-darwin/commits?sha=master&per_page=5" 2>/dev/null | \
            jq 'map({
                sha: .sha[0:8],
                message: (.commit.message | split("\n")[0] | .[0:100]),
                author: .commit.author.name,
                date: .commit.author.date,
                url: .html_url
            })' 2>/dev/null || echo '[]')
    fi

    local count
    count=$(echo "${result}" | jq 'length' 2>/dev/null || echo "0")
    log "Retrieved ${count} nix-darwin commits"

    echo "${result}"
}

# Fetch Ollama available models (top trending)
fetch_ollama_models() {
    log "Fetching Ollama model information..."

    # Get currently installed models
    local installed_models=""
    if command -v ollama &>/dev/null; then
        installed_models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | tr '\n' ',' | sed 's/,$//' || echo "")
        log "Installed Ollama models: ${installed_models:-none}"
    else
        log "WARNING: ollama CLI not available"
    fi

    # Fetch trending/notable models from Ollama library page
    # Note: Ollama doesn't have a public API, so we check GitHub for new releases
    local ollama_releases
    if command -v gh &>/dev/null; then
        ollama_releases=$(gh api repos/ollama/ollama/releases \
            --jq '.[0:3] | map({
                tag: .tag_name,
                name: .name,
                url: .html_url,
                published: .published_at,
                body: (.body // "" | .[0:1000])
            })' 2>/dev/null || echo '[]')
    else
        ollama_releases=$(curl -sL "https://api.github.com/repos/ollama/ollama/releases?per_page=3" 2>/dev/null | \
            jq 'map({
                tag: .tag_name,
                name: .name,
                url: .html_url,
                published: .published_at,
                body: (.body // "" | .[0:1000])
            })' 2>/dev/null || echo '[]')
    fi

    jq -n \
        --arg installed "${installed_models}" \
        --argjson releases "${ollama_releases}" \
        '{installed: $installed, releases: $releases}'
}

# Get current flake.lock versions for context
get_flake_versions() {
    log "Reading flake.lock versions..."

    local flake_lock="${HOME}/Documents/nix-install/flake.lock"

    if [[ -f "${flake_lock}" ]]; then
        local result
        # Use a filter file to avoid shell escaping issues
        result=$(jq '[.nodes | to_entries[] | select(.value.locked.rev) | {
            key: .key,
            rev: .value.locked.rev[0:8],
            type: (.value.locked.type // "unknown"),
            owner: (.value.locked.owner // ""),
            repo: (.value.locked.repo // "")
        }] | INDEX(.key) | map_values(del(.key))' "${flake_lock}" 2>/dev/null || echo '{}')

        log "Extracted flake.lock versions"
        echo "${result}"
    else
        log "WARNING: flake.lock not found at ${flake_lock}"
        echo '{}'
    fi
}

# Main execution
main() {
    log "Building release notes JSON..."

    # Gather all data
    local macos_data homebrew_data nixpkgs_data nix_darwin_data ollama_data flake_versions

    macos_data=$(fetch_macos_updates)
    homebrew_data=$(fetch_homebrew_updates)
    nixpkgs_data=$(fetch_nixpkgs_releases)
    nix_darwin_data=$(fetch_nix_darwin_releases)
    ollama_data=$(fetch_ollama_models)
    flake_versions=$(get_flake_versions)

    # Build final JSON output
    jq -n \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg hostname "$(hostname)" \
        --argjson macos "${macos_data}" \
        --argjson homebrew "${homebrew_data}" \
        --argjson nixpkgs "${nixpkgs_data}" \
        --argjson nix_darwin "${nix_darwin_data}" \
        --argjson ollama "${ollama_data}" \
        --argjson flake_versions "${flake_versions}" \
        '{
            timestamp: $timestamp,
            hostname: $hostname,
            macos: $macos,
            flake_versions: $flake_versions,
            homebrew: $homebrew,
            nixpkgs: $nixpkgs,
            nix_darwin: $nix_darwin,
            ollama: $ollama
        }' > "${OUTPUT_FILE}"

    log "Release notes saved to ${OUTPUT_FILE}"
    echo "${OUTPUT_FILE}"
}

main "$@"
