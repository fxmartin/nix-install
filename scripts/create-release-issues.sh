#!/usr/bin/env bash
# ABOUTME: Creates GitHub issues from Claude analysis results
# ABOUTME: Implements deduplication and proper labeling (Story 06.6-003)

set -euo pipefail

# Configuration
ANALYSIS_FILE="${1:-/tmp/analysis-results.json}"
OUTPUT_FILE="${2:-/tmp/created-issues.json}"
REPO="${RELEASE_MONITOR_REPO:-fxmartin/nix-install}"
LOG_DIR="${HOME}/.local/log"
LOG_FILE="${LOG_DIR}/release-monitor.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "${LOG_FILE}"
}

log "=== Starting GitHub issue creation ==="

# Check if analysis file exists
if [[ ! -f "${ANALYSIS_FILE}" ]]; then
    log "ERROR: Analysis file not found: ${ANALYSIS_FILE}"
    echo '[]' > "${OUTPUT_FILE}"
    echo "${OUTPUT_FILE}"
    exit 1
fi

# Check for gh CLI
if ! command -v gh &>/dev/null; then
    log "ERROR: GitHub CLI (gh) not found in PATH"
    echo '[]' > "${OUTPUT_FILE}"
    echo "${OUTPUT_FILE}"
    exit 1
fi

# Check gh auth status
if ! gh auth status &>/dev/null; then
    log "ERROR: GitHub CLI not authenticated"
    echo '[]' > "${OUTPUT_FILE}"
    echo "${OUTPUT_FILE}"
    exit 1
fi

# Smart duplicate detection
# Matches on: tool name + issue category (not exact wording)
# This handles Claude generating slightly different descriptions each run
issue_exists() {
    local title="$1"
    local category="$2"  # security, breaking, feature, model, update

    # Extract the tool name from title
    # e.g., "[Release Monitor] ca-certificates: Root certificate..." -> "ca-certificates"
    # e.g., "[Release Monitor] Ollama: New model - DeepSeek-OCR" -> "Ollama"
    local tool_name
    tool_name=$(echo "${title}" | sed -E 's/\[Release Monitor\] ([^:]+):.*/\1/' | tr '[:upper:]' '[:lower:]')

    # For version updates, also extract version numbers to allow same tool with different versions
    local version_pattern=""
    if [[ "${category}" == "update" ]]; then
        # Extract target version (after → or ->)
        version_pattern=$(echo "${title}" | grep -oE '(→|->)\s*[0-9]+\.[0-9]+' | sed 's/[→>-]//g' | tr -d ' ' || echo "")
    fi

    # For Ollama models, extract the model name
    local model_name=""
    if [[ "${category}" == "model" ]]; then
        # Extract model name after "New model - "
        model_name=$(echo "${title}" | sed -E 's/.*New model - ([^[:space:]]+).*/\1/' | tr '[:upper:]' '[:lower:]')
    fi

    # Build search query based on category
    local search_query="in:title \"[Release Monitor]\" \"${tool_name}\""

    # Add category-specific keywords to narrow search
    case "${category}" in
        security)
            search_query="${search_query} label:security"
            ;;
        breaking)
            search_query="${search_query} label:breaking-change"
            ;;
        feature)
            search_query="${search_query} \"New feature\""
            ;;
        model)
            search_query="${search_query} \"New model\""
            ;;
        update)
            # For updates, don't add extra filter - just tool name
            ;;
    esac

    local existing_issues
    existing_issues=$(gh issue list \
        --repo "${REPO}" \
        --state open \
        --search "${search_query}" \
        --json number,title,labels \
        --jq '.[] | "\(.number)|\(.title)|\([.labels[].name] | join(","))"' 2>/dev/null || echo "")

    if [[ -z "${existing_issues}" ]]; then
        return 1  # No matches at all
    fi

    # Check each existing issue for semantic match
    while IFS= read -r issue_line; do
        local issue_num issue_title issue_labels
        issue_num=$(echo "${issue_line}" | cut -d'|' -f1)
        issue_title=$(echo "${issue_line}" | cut -d'|' -f2)
        issue_labels=$(echo "${issue_line}" | cut -d'|' -f3)

        # Extract tool from existing issue
        local existing_tool
        existing_tool=$(echo "${issue_title}" | sed -E 's/\[Release Monitor\] ([^:]+):.*/\1/' | tr '[:upper:]' '[:lower:]')

        # Check if same tool
        if [[ "${existing_tool}" != "${tool_name}" ]]; then
            continue
        fi

        # Category-specific matching
        case "${category}" in
            security)
                # Same tool + security label = duplicate
                if [[ "${issue_labels}" == *"security"* ]]; then
                    log "Duplicate found: #${issue_num} (${tool_name} security update already exists)"
                    return 0
                fi
                ;;
            breaking)
                # Same tool + breaking-change label = duplicate
                if [[ "${issue_labels}" == *"breaking-change"* ]]; then
                    log "Duplicate found: #${issue_num} (${tool_name} breaking change already exists)"
                    return 0
                fi
                ;;
            feature)
                # Same tool + "New feature" in title = duplicate
                if [[ "${issue_title}" == *"New feature"* ]]; then
                    log "Duplicate found: #${issue_num} (${tool_name} new feature already exists)"
                    return 0
                fi
                ;;
            model)
                # Same model name = duplicate
                # Case-insensitive comparison, but keep full name (size/quantization matters)
                local existing_model
                existing_model=$(echo "${issue_title}" | sed -E 's/.*New model - ([^[:space:]]+).*/\1/' | tr '[:upper:]' '[:lower:]')

                # Only normalize: lowercase and common formatting differences (V vs v, - vs .)
                # Keep version numbers and size suffixes as they define different model variants
                local normalized_existing normalized_new
                normalized_existing=$(echo "${existing_model}" | tr '[:upper:]' '[:lower:]' | sed 's/-v/v/g; s/\./-/g')
                normalized_new=$(echo "${model_name}" | tr '[:upper:]' '[:lower:]' | sed 's/-v/v/g; s/\./-/g')

                if [[ "${normalized_existing}" == "${normalized_new}" ]]; then
                    log "Duplicate found: #${issue_num} (Ollama model ${model_name} matches ${existing_model})"
                    return 0
                fi
                ;;
            update)
                # Same tool + same target version = duplicate
                local existing_version
                existing_version=$(echo "${issue_title}" | grep -oE '(→|->)\s*[0-9]+\.[0-9]+' | sed 's/[→>-]//g' | tr -d ' ' || echo "")
                if [[ -n "${version_pattern}" && "${existing_version}" == "${version_pattern}" ]]; then
                    log "Duplicate found: #${issue_num} (${tool_name} ${version_pattern} update already exists)"
                    return 0
                fi
                # If no version in new title, just check tool name
                if [[ -z "${version_pattern}" ]]; then
                    log "Duplicate found: #${issue_num} (${tool_name} update already exists)"
                    return 0
                fi
                ;;
        esac
    done <<< "${existing_issues}"

    return 1  # No semantic match found
}

# Create a GitHub issue
# Outputs JSON: {"url": "...", "category": "...", "tool": "..."}
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    local category="${4:-update}"  # Default to 'update' for backwards compatibility

    # Check for duplicates using smart semantic matching
    if issue_exists "${title}" "${category}"; then
        echo ""
        return 0
    fi

    # Extract tool name for the output
    local tool_name
    tool_name=$(echo "${title}" | sed -E 's/\[Release Monitor\] ([^:]+):.*/\1/')

    # Create the issue
    local url
    url=$(gh issue create \
        --repo "${REPO}" \
        --title "${title}" \
        --body "${body}" \
        --label "${labels}" 2>/dev/null) || {
            log "ERROR: Failed to create issue: ${title}"
            echo ""
            return 1
        }

    log "Created issue: ${url}"
    # Output JSON object with url, category, and tool
    echo "{\"url\":\"${url}\",\"category\":\"${category}\",\"tool\":\"${tool_name}\"}"
}

# Process security updates
process_security_updates() {
    log "Processing security updates..."

    local items
    items=$(jq -c '.security_updates // []' "${ANALYSIS_FILE}")

    echo "${items}" | jq -c '.[]' 2>/dev/null | while read -r item; do
        local tool severity summary action
        tool=$(echo "${item}" | jq -r '.tool // "unknown"')
        severity=$(echo "${item}" | jq -r '.severity // "medium"')
        summary=$(echo "${item}" | jq -r '.summary // "Security update available"')
        action=$(echo "${item}" | jq -r '.action // "Review and update"')

        local title="[Release Monitor] ${tool}: ${summary}"
        local body
        body=$(cat << EOF
## Security Update

**Tool**: ${tool}
**Severity**: ${severity}

### Summary
${summary}

### Recommended Action
${action}

---
*Created automatically by release-monitor*
EOF
)
        local labels="security,${severity},epic-06"

        create_issue "${title}" "${body}" "${labels}" "security"
    done
}

# Process breaking changes
process_breaking_changes() {
    log "Processing breaking changes..."

    local items
    items=$(jq -c '.breaking_changes // []' "${ANALYSIS_FILE}")

    echo "${items}" | jq -c '.[]' 2>/dev/null | while read -r item; do
        local tool summary impact action
        tool=$(echo "${item}" | jq -r '.tool // "unknown"')
        summary=$(echo "${item}" | jq -r '.summary // "Breaking change"')
        impact=$(echo "${item}" | jq -r '.impact // "May affect configuration"')
        action=$(echo "${item}" | jq -r '.action // "Review and update"')

        local title="[Release Monitor] ${tool}: Breaking change - ${summary}"
        local body
        body=$(cat << EOF
## Breaking Change

**Tool**: ${tool}

### What Changed
${summary}

### Impact
${impact}

### Required Action
${action}

---
*Created automatically by release-monitor*
EOF
)
        local labels="breaking-change,high,epic-06"

        create_issue "${title}" "${body}" "${labels}" "breaking"
    done
}

# Process new features
process_new_features() {
    log "Processing new features..."

    local items
    items=$(jq -c '.new_features // []' "${ANALYSIS_FILE}")

    echo "${items}" | jq -c '.[]' 2>/dev/null | while read -r item; do
        local tool feature relevance action
        tool=$(echo "${item}" | jq -r '.tool // "unknown"')
        feature=$(echo "${item}" | jq -r '.feature // "New feature"')
        relevance=$(echo "${item}" | jq -r '.relevance // "May be useful"')
        action=$(echo "${item}" | jq -r '.action // "Consider adopting"')

        local title="[Release Monitor] ${tool}: New feature - ${feature}"
        local body
        body=$(cat << EOF
## New Feature

**Tool**: ${tool}
**Feature**: ${feature}

### Why This Is Relevant
${relevance}

### Suggested Action
${action}

---
*Created automatically by release-monitor*
EOF
)
        local labels="enhancement,medium,epic-06"

        create_issue "${title}" "${body}" "${labels}" "feature"
    done
}

# Process Ollama models
process_ollama_models() {
    log "Processing Ollama models..."

    local items
    items=$(jq -c '.ollama_models // []' "${ANALYSIS_FILE}")

    echo "${items}" | jq -c '.[]' 2>/dev/null | while read -r item; do
        local model description recommendation
        model=$(echo "${item}" | jq -r '.model // "unknown"')
        description=$(echo "${item}" | jq -r '.description // "New model available"')
        recommendation=$(echo "${item}" | jq -r '.recommendation // "May be worth trying"')

        local title="[Release Monitor] Ollama: New model - ${model}"
        local body
        body=$(cat << EOF
## New Ollama Model

**Model**: ${model}

### Description
${description}

### Recommendation
${recommendation}

### How to Try
\`\`\`bash
ollama pull ${model}
ollama run ${model}
\`\`\`

---
*Created automatically by release-monitor*
EOF
)
        local labels="enhancement,profile/power,epic-06"

        create_issue "${title}" "${body}" "${labels}" "model"
    done
}

# Process notable updates
process_notable_updates() {
    log "Processing notable updates..."

    local items
    items=$(jq -c '.notable_updates // []' "${ANALYSIS_FILE}")

    echo "${items}" | jq -c '.[]' 2>/dev/null | while read -r item; do
        local tool update notes
        tool=$(echo "${item}" | jq -r '.tool // "unknown"')
        update=$(echo "${item}" | jq -r '.update // "Update available"')
        notes=$(echo "${item}" | jq -r '.notes // "Notable update"')

        local title="[Release Monitor] ${tool}: ${update}"
        local body
        body=$(cat << EOF
## Notable Update

**Tool**: ${tool}
**Update**: ${update}

### Notes
${notes}

---
*Created automatically by release-monitor*
EOF
)
        local labels="enhancement,medium,epic-06"

        create_issue "${title}" "${body}" "${labels}" "update"
    done
}

# Main execution
main() {
    # Check if analysis has an error
    local has_error
    has_error=$(jq -r 'has("error")' "${ANALYSIS_FILE}" 2>/dev/null || echo "false")

    if [[ "${has_error}" == "true" ]]; then
        local error_msg
        error_msg=$(jq -r '.error' "${ANALYSIS_FILE}")
        log "Analysis had error: ${error_msg}, skipping issue creation"
        echo '[]' > "${OUTPUT_FILE}"
        echo "${OUTPUT_FILE}"
        exit 0
    fi

    # Collect all created issue JSON objects
    local created_issues=()

    # Process each category - each returns JSON objects
    while IFS= read -r json_obj; do
        [[ -n "${json_obj}" ]] && created_issues+=("${json_obj}")
    done < <(process_security_updates)

    while IFS= read -r json_obj; do
        [[ -n "${json_obj}" ]] && created_issues+=("${json_obj}")
    done < <(process_breaking_changes)

    while IFS= read -r json_obj; do
        [[ -n "${json_obj}" ]] && created_issues+=("${json_obj}")
    done < <(process_new_features)

    while IFS= read -r json_obj; do
        [[ -n "${json_obj}" ]] && created_issues+=("${json_obj}")
    done < <(process_ollama_models)

    while IFS= read -r json_obj; do
        [[ -n "${json_obj}" ]] && created_issues+=("${json_obj}")
    done < <(process_notable_updates)

    # Write output as JSON array of objects (handle empty array case)
    if [[ ${#created_issues[@]} -eq 0 ]]; then
        echo '[]' > "${OUTPUT_FILE}"
    else
        printf '%s\n' "${created_issues[@]}" | jq -s '.' > "${OUTPUT_FILE}"
    fi

    local count="${#created_issues[@]}"
    log "Created ${count} GitHub issues"
    log "Issue URLs saved to ${OUTPUT_FILE}"

    echo "${OUTPUT_FILE}"
}

main "$@"
