#!/usr/bin/env bash
# ABOUTME: Invokes Claude CLI to analyze release notes and suggest improvements
# ABOUTME: Outputs structured JSON with categorized recommendations (Story 06.6-002)

set -euo pipefail

# Configuration
RELEASE_NOTES="${1:-/tmp/release-notes.json}"
OUTPUT_FILE="${2:-/tmp/analysis-results.json}"
LOG_DIR="${HOME}/.local/log"
LOG_FILE="${LOG_DIR}/release-monitor.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "${LOG_FILE}"
}

log "=== Starting release analysis ==="

# Check if release notes exist
if [[ ! -f "${RELEASE_NOTES}" ]]; then
    log "ERROR: Release notes file not found: ${RELEASE_NOTES}"
    echo '{"error": "Release notes file not found", "security_updates": [], "breaking_changes": [], "new_features": [], "ollama_models": [], "notable_updates": [], "summary": "Analysis failed - no release notes available"}' > "${OUTPUT_FILE}"
    echo "${OUTPUT_FILE}"
    exit 1
fi

# Read release notes
RELEASE_DATA=$(cat "${RELEASE_NOTES}")
log "Loaded release notes from ${RELEASE_NOTES}"

# Build the Claude prompt
build_prompt() {
    cat << 'PROMPT_HEADER'
You are analyzing release notes for a Nix-based macOS configuration system (nix-install).

## Context
This is a personal MacBook configuration using:
- nix-darwin for system configuration
- Home Manager for user dotfiles
- Homebrew for GUI apps
- Ollama for local LLM models

The user (FX) is a developer working with Python, Podman, and AI tools.

## Release Notes Data
PROMPT_HEADER

    echo "${RELEASE_DATA}"

    cat << 'PROMPT_FOOTER'

## Analysis Required
Analyze these release notes and provide recommendations. Focus on items relevant to:
- Python development (uv, ruff, Python 3.12+)
- Container development (Podman)
- AI/LLM tools (Ollama, Claude)
- macOS system management
- Security updates (always include)

Output your analysis as JSON in this exact format:
```json
{
  "security_updates": [
    {"tool": "name", "severity": "critical|high|medium", "summary": "brief description", "action": "recommended action"}
  ],
  "breaking_changes": [
    {"tool": "name", "summary": "what changed", "impact": "how it affects config", "action": "required action"}
  ],
  "new_features": [
    {"tool": "name", "feature": "feature name", "relevance": "why relevant to Python/Podman/AI stack", "action": "suggested action"}
  ],
  "ollama_models": [
    {"model": "model name", "description": "what it's good for", "recommendation": "worth trying because..."}
  ],
  "notable_updates": [
    {"tool": "name", "update": "version change", "notes": "why notable"}
  ],
  "summary": "2-3 sentence executive summary of the most important findings"
}
```

Rules:
1. Only include items that require action or awareness
2. Skip routine maintenance updates with no user impact
3. Prioritize security updates (always include if present)
4. For Ollama, focus on models useful for coding assistance
5. Keep descriptions concise but actionable
6. If there's nothing notable, return empty arrays with a summary saying so

Return ONLY the JSON, no additional text or markdown code blocks.
PROMPT_FOOTER
}

# Check for Claude CLI
check_claude_cli() {
    if ! command -v claude &>/dev/null; then
        log "ERROR: Claude CLI not found in PATH"
        return 1
    fi
    return 0
}

# Run Claude analysis
run_analysis() {
    log "Invoking Claude CLI for analysis..."

    local prompt
    prompt=$(build_prompt)

    # Invoke Claude CLI with prompt
    # Use --print flag to output to stdout without interactive mode
    # Add explicit JSON instruction at the end
    local result
    if result=$(echo "${prompt}

IMPORTANT: Output ONLY the JSON object, nothing else. No markdown, no explanation, just the raw JSON starting with { and ending with }." | claude --print 2>/dev/null); then
        log "Claude analysis completed successfully"
        echo "${result}"
    else
        log "ERROR: Claude CLI invocation failed"
        return 1
    fi
}

# Validate JSON output
validate_json() {
    local json="$1"

    if ! echo "${json}" | jq empty 2>/dev/null; then
        log "ERROR: Invalid JSON output from Claude"
        return 1
    fi

    # Check for required fields
    local has_summary
    has_summary=$(echo "${json}" | jq 'has("summary")' 2>/dev/null || echo "false")

    if [[ "${has_summary}" != "true" ]]; then
        log "WARNING: JSON missing summary field"
    fi

    return 0
}

# Create fallback analysis result
create_fallback_result() {
    local reason="${1:-Unknown error}"

    jq -n \
        --arg reason "${reason}" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            error: $reason,
            timestamp: $timestamp,
            security_updates: [],
            breaking_changes: [],
            new_features: [],
            ollama_models: [],
            notable_updates: [],
            summary: ("Analysis failed: " + $reason + ". Check release notes manually.")
        }'
}

# Main execution
main() {
    # Check Claude CLI availability
    if ! check_claude_cli; then
        log "Falling back to empty analysis (no Claude CLI)"
        create_fallback_result "Claude CLI not available" > "${OUTPUT_FILE}"
        echo "${OUTPUT_FILE}"
        exit 0
    fi

    # Run analysis
    local analysis
    if ! analysis=$(run_analysis); then
        log "Analysis failed, creating fallback result"
        create_fallback_result "Claude CLI invocation failed" > "${OUTPUT_FILE}"
        echo "${OUTPUT_FILE}"
        exit 0
    fi

    # Try to extract JSON from response (Claude might include extra text)
    local json_result

    # First, try to find a complete JSON object with the expected structure
    # Look for content between first { and last }
    json_result=$(echo "${analysis}" | sed -n '/{/,/}/p' | tr '\n' ' ' | sed 's/.*\({.*}\).*/\1/' || echo "")

    # If that didn't work, try the raw output
    if ! echo "${json_result}" | jq -e '.summary' &>/dev/null; then
        # Try extracting from markdown code block
        json_result=$(echo "${analysis}" | sed -n '/```json/,/```/p' | grep -v '```' | tr '\n' ' ' || echo "")
    fi

    # If still no valid JSON, try the whole output
    if ! echo "${json_result}" | jq -e '.summary' &>/dev/null; then
        json_result="${analysis}"
    fi

    # Validate and save
    if validate_json "${json_result}"; then
        echo "${json_result}" | jq '.' > "${OUTPUT_FILE}"
        log "Analysis results saved to ${OUTPUT_FILE}"
    else
        log "Invalid JSON, creating fallback"
        create_fallback_result "Invalid JSON output from Claude" > "${OUTPUT_FILE}"
    fi

    echo "${OUTPUT_FILE}"
}

main "$@"
