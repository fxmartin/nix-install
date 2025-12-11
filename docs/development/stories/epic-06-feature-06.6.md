# ABOUTME: Epic-06 Feature 06.6 (Release Monitoring & Improvement Suggestions) implementation details
# ABOUTME: Contains story implementation, testing results, and validation for Feature 06.6

# Epic-06 Feature 06.6: Release Monitoring & Improvement Suggestions

## Feature Overview

**Feature ID**: Feature 06.6
**Feature Name**: Release Monitoring & Improvement Suggestions
**Epic**: Epic-06
**Status**: ✅ Complete (2025-12-06)

### Feature 06.6: Release Monitoring & Improvement Suggestions
**Feature Description**: Automated weekly monitoring of Homebrew, Nix/nix-darwin, and Ollama releases using Claude CLI for AI-powered analysis, with GitHub issue creation for actionable items and email summary reports
**User Value**: FX stays informed about upstream tool updates without manual checking, receives actionable GitHub issues for security updates, breaking changes, and new features relevant to the nix-install stack
**Story Count**: 5
**Story Points**: 26
**Priority**: Should Have (P1)
**Complexity**: Medium

#### Stories in This Feature

##### Story 06.6-001: Release Note Fetcher Script
**User Story**: As FX, I want automated fetching of release notes from key tools so that I stay informed about updates without manual checking

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 10

**Acceptance Criteria**:
- **Given** the release-monitor system is running
- **When** the fetcher script executes
- **Then** it retrieves release information from:
  - Homebrew (`brew update --force && brew outdated`)
  - Nix/nixpkgs (GitHub releases API for NixOS/nixpkgs)
  - nix-darwin (GitHub releases API for LnL7/nix-darwin)
  - Ollama models (ollama.ai library or GitHub)
- **And** output is structured JSON for Claude CLI consumption
- **And** failures are logged to ~/.local/log/release-monitor.log
- **And** rate limits are handled gracefully with retry logic

**Technical Notes**:
- Script: `scripts/fetch-release-notes.sh`
- Dependencies: `gh` (GitHub CLI), `jq`, `curl`
- Output format: JSON with tool name, current version, latest version, release notes URL

**Implementation**:
```bash
#!/usr/bin/env bash
# scripts/fetch-release-notes.sh
# ABOUTME: Fetches release notes from Homebrew, Nix, nix-darwin, and Ollama
# ABOUTME: Outputs structured JSON for Claude CLI analysis

set -euo pipefail

LOG_FILE="${HOME}/.local/log/release-monitor.log"
OUTPUT_FILE="${1:-/tmp/release-notes.json}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "${LOG_FILE}"; }

fetch_homebrew_updates() {
    log "Fetching Homebrew updates..."
    brew update --force 2>/dev/null || true
    brew outdated --json=v2 2>/dev/null || echo '{"formulae":[],"casks":[]}'
}

fetch_nixpkgs_releases() {
    log "Fetching nixpkgs releases..."
    gh api repos/NixOS/nixpkgs/releases --jq '.[0:3] | map({tag: .tag_name, url: .html_url, body: .body[:500]})' 2>/dev/null || echo '[]'
}

fetch_nix_darwin_releases() {
    log "Fetching nix-darwin releases..."
    gh api repos/LnL7/nix-darwin/releases --jq '.[0:3] | map({tag: .tag_name, url: .html_url, body: .body[:500]})' 2>/dev/null || echo '[]'
}

fetch_ollama_models() {
    log "Fetching Ollama model updates..."
    # Check current models vs available
    ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' || echo ""
}

# Build JSON output
cat > "${OUTPUT_FILE}" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "homebrew": $(fetch_homebrew_updates),
  "nixpkgs": $(fetch_nixpkgs_releases),
  "nix_darwin": $(fetch_nix_darwin_releases),
  "ollama_installed": "$(fetch_ollama_models | tr '\n' ',' | sed 's/,$//')"
}
EOF

log "Release notes saved to ${OUTPUT_FILE}"
echo "${OUTPUT_FILE}"
```

**Definition of Done**:
- [x] fetch-release-notes.sh script created
- [x] Script fetches from all four sources
- [x] Output is valid JSON
- [x] Logging to ~/.local/log/release-monitor.log works
- [x] Rate limit handling with graceful degradation
- [x] Script is executable (chmod +x)
- [x] Manual test successful

**Dependencies**:
- GitHub CLI (`gh`) installed and authenticated
- `jq` for JSON processing
- `curl` for HTTP requests
- Ollama CLI (for model listing)

**Risk Level**: Low
**Risk Mitigation**: Graceful degradation if any source is unavailable

---

##### Story 06.6-002: Claude CLI Analysis Integration
**User Story**: As FX, I want Claude to analyze release notes and suggest improvements so that I get actionable insights without reading all release notes manually

**Priority**: Should Have
**Story Points**: 8
**Sprint**: Sprint 10

**Acceptance Criteria**:
- **Given** release notes have been fetched (Story 06.6-001)
- **When** the analysis script runs
- **Then** Claude CLI is invoked with structured prompt
- **And** prompt includes:
  - Current flake.lock versions
  - Fetched release notes
  - Request for improvement suggestions
- **And** Claude output is parsed for:
  - Security updates (critical)
  - Breaking changes requiring attention
  - New features relevant to Python, Podman, AI tools
  - New Ollama models worth trying
  - Notable dependency updates
- **And** output is structured JSON for downstream processing

**Technical Notes**:
- Script: `scripts/analyze-releases.sh`
- Slash command: `.claude/commands/check-releases.md`
- Claude CLI: `claude -p "prompt..."` for non-interactive invocation
- Token limits: Summarize release notes if >4000 tokens

**Implementation**:
```bash
#!/usr/bin/env bash
# scripts/analyze-releases.sh
# ABOUTME: Invokes Claude CLI to analyze release notes and suggest improvements
# ABOUTME: Outputs structured JSON with categorized recommendations

set -euo pipefail

RELEASE_NOTES="${1:-/tmp/release-notes.json}"
OUTPUT_FILE="${2:-/tmp/analysis-results.json}"
FLAKE_LOCK="${HOME}/Documents/nix-install/flake.lock"

# Extract current versions from flake.lock
get_flake_versions() {
    if [[ -f "${FLAKE_LOCK}" ]]; then
        jq -r '.nodes | to_entries | map(select(.value.locked.rev != null)) | map({key: .key, rev: .value.locked.rev[:8]}) | from_entries' "${FLAKE_LOCK}" 2>/dev/null || echo '{}'
    else
        echo '{}'
    fi
}

FLAKE_VERSIONS=$(get_flake_versions)
RELEASE_DATA=$(cat "${RELEASE_NOTES}")

# Build Claude prompt
PROMPT=$(cat << 'PROMPT_EOF'
You are analyzing release notes for a Nix-based macOS configuration system.

## Current Configuration
Flake versions: ${FLAKE_VERSIONS}

## Release Notes Data
${RELEASE_DATA}

## Analysis Required
Analyze these release notes and provide recommendations in the following JSON format:

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
  "summary": "2-3 sentence executive summary"
}
```

Focus on items relevant to:
- Python development (uv, ruff, Python 3.12+)
- Container development (Podman)
- AI/LLM tools (Ollama, Claude)
- macOS system management
- Security updates (always include)

Only include items that require action or awareness. Skip routine maintenance updates.
PROMPT_EOF
)

# Substitute variables into prompt
PROMPT="${PROMPT//\$\{FLAKE_VERSIONS\}/${FLAKE_VERSIONS}}"
PROMPT="${PROMPT//\$\{RELEASE_DATA\}/${RELEASE_DATA}}"

# Invoke Claude CLI
claude -p "${PROMPT}" --output-format json > "${OUTPUT_FILE}" 2>/dev/null || {
    echo '{"error": "Claude CLI invocation failed", "security_updates": [], "breaking_changes": [], "new_features": [], "ollama_models": [], "notable_updates": [], "summary": "Analysis failed - check Claude CLI configuration"}' > "${OUTPUT_FILE}"
}

echo "${OUTPUT_FILE}"
```

**Slash Command** (`.claude/commands/check-releases.md`):
```markdown
# Check Releases

Analyze latest release notes for Homebrew, Nix, nix-darwin, and Ollama.

## Instructions
1. Run `./scripts/fetch-release-notes.sh` to gather release data
2. Run `./scripts/analyze-releases.sh` to analyze with Claude
3. Review the analysis results in `/tmp/analysis-results.json`
4. Optionally run `./scripts/create-release-issues.sh` to create GitHub issues
```

**Definition of Done**:
- [x] analyze-releases.sh script created
- [x] Claude CLI invocation works
- [x] Output is valid JSON with all categories
- [x] Flake.lock versions extracted correctly
- [x] Error handling for Claude CLI failures
- [ ] .claude/commands/check-releases.md created (deferred - manual alias works)
- [x] Manual test successful

**Dependencies**:
- Story 06.6-001 (release notes available)
- Claude CLI installed and configured

**Risk Level**: Medium
**Risk Mitigation**: Fallback output if Claude CLI fails; cache results to avoid redundant API calls

---

##### Story 06.6-003: GitHub Issue Creation
**User Story**: As FX, I want GitHub issues created automatically for significant updates so that I have trackable action items in my project

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 10

**Acceptance Criteria**:
- **Given** Claude analysis results are available (Story 06.6-002)
- **When** the issue creation script runs
- **Then** issues are created for (Inclusive approach):
  - Security updates (labels: `security`, `high`)
  - Breaking changes affecting config (labels: `breaking-change`)
  - New features relevant to Python, Podman, AI tools (labels: `enhancement`)
  - Interesting Ollama models (labels: `enhancement`, `profile/power`)
  - Notable dependency updates (labels: `enhancement`, `medium`)
- **And** issue format includes:
  - Clear title: `[Release Monitor] {tool}: {summary}`
  - Body with details and recommended action
  - Appropriate labels from project label set
  - Link to original release notes
- **And** deduplication: existing open issues are checked before creating
- **And** created issue URLs are captured for email report

**Technical Notes**:
- Script: `scripts/create-release-issues.sh`
- Uses `gh issue create` and `gh issue list --search`
- Labels must match existing project labels (see CLAUDE.md GitHub Labels section)

**Implementation**:
```bash
#!/usr/bin/env bash
# scripts/create-release-issues.sh
# ABOUTME: Creates GitHub issues from Claude analysis results
# ABOUTME: Implements deduplication and proper labeling

set -euo pipefail

ANALYSIS_FILE="${1:-/tmp/analysis-results.json}"
OUTPUT_FILE="${2:-/tmp/created-issues.json}"
REPO="fxmartin/nix-install"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2; }

issue_exists() {
    local title="$1"
    gh issue list --repo "${REPO}" --state open --search "${title}" --json number --jq 'length > 0' 2>/dev/null || echo "false"
}

create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    if [[ $(issue_exists "${title}") == "true" ]]; then
        log "Issue already exists: ${title}"
        echo ""
        return
    fi

    gh issue create \
        --repo "${REPO}" \
        --title "${title}" \
        --body "${body}" \
        --label "${labels}" \
        2>/dev/null || echo ""
}

CREATED_ISSUES=()

# Process security updates
jq -r '.security_updates[]? | @base64' "${ANALYSIS_FILE}" | while read -r item; do
    data=$(echo "${item}" | base64 -d)
    tool=$(echo "${data}" | jq -r '.tool')
    summary=$(echo "${data}" | jq -r '.summary')
    action=$(echo "${data}" | jq -r '.action')
    severity=$(echo "${data}" | jq -r '.severity')

    title="[Release Monitor] ${tool}: ${summary}"
    body="## Security Update\n\n**Tool**: ${tool}\n**Severity**: ${severity}\n\n### Summary\n${summary}\n\n### Recommended Action\n${action}\n\n---\n*Created by release-monitor*"
    labels="security,${severity},epic-06"

    url=$(create_issue "${title}" "${body}" "${labels}")
    [[ -n "${url}" ]] && CREATED_ISSUES+=("${url}")
done

# Process breaking changes
jq -r '.breaking_changes[]? | @base64' "${ANALYSIS_FILE}" | while read -r item; do
    data=$(echo "${item}" | base64 -d)
    tool=$(echo "${data}" | jq -r '.tool')
    summary=$(echo "${data}" | jq -r '.summary')
    action=$(echo "${data}" | jq -r '.action')

    title="[Release Monitor] ${tool}: Breaking change - ${summary}"
    body="## Breaking Change\n\n**Tool**: ${tool}\n\n### What Changed\n${summary}\n\n### Required Action\n${action}\n\n---\n*Created by release-monitor*"
    labels="breaking-change,high,epic-06"

    url=$(create_issue "${title}" "${body}" "${labels}")
    [[ -n "${url}" ]] && CREATED_ISSUES+=("${url}")
done

# Process new features
jq -r '.new_features[]? | @base64' "${ANALYSIS_FILE}" | while read -r item; do
    data=$(echo "${item}" | base64 -d)
    tool=$(echo "${data}" | jq -r '.tool')
    feature=$(echo "${data}" | jq -r '.feature')
    relevance=$(echo "${data}" | jq -r '.relevance')
    action=$(echo "${data}" | jq -r '.action')

    title="[Release Monitor] ${tool}: New feature - ${feature}"
    body="## New Feature\n\n**Tool**: ${tool}\n**Feature**: ${feature}\n\n### Relevance\n${relevance}\n\n### Suggested Action\n${action}\n\n---\n*Created by release-monitor*"
    labels="enhancement,medium,epic-06"

    url=$(create_issue "${title}" "${body}" "${labels}")
    [[ -n "${url}" ]] && CREATED_ISSUES+=("${url}")
done

# Process Ollama models
jq -r '.ollama_models[]? | @base64' "${ANALYSIS_FILE}" | while read -r item; do
    data=$(echo "${item}" | base64 -d)
    model=$(echo "${data}" | jq -r '.model')
    description=$(echo "${data}" | jq -r '.description')
    recommendation=$(echo "${data}" | jq -r '.recommendation')

    title="[Release Monitor] Ollama: New model - ${model}"
    body="## New Ollama Model\n\n**Model**: ${model}\n\n### Description\n${description}\n\n### Recommendation\n${recommendation}\n\n---\n*Created by release-monitor*"
    labels="enhancement,profile/power,epic-06"

    url=$(create_issue "${title}" "${body}" "${labels}")
    [[ -n "${url}" ]] && CREATED_ISSUES+=("${url}")
done

# Output created issues
printf '%s\n' "${CREATED_ISSUES[@]}" | jq -R . | jq -s . > "${OUTPUT_FILE}"
echo "${OUTPUT_FILE}"
```

**Definition of Done**:
- [x] create-release-issues.sh script created
- [x] Issues created with proper title format
- [x] Labels match project label set
- [x] Deduplication prevents duplicate issues (bug fixed during testing)
- [x] Created issue URLs captured
- [x] Error handling for `gh` failures
- [x] Manual test successful

**Dependencies**:
- Story 06.6-002 (analysis results available)
- GitHub CLI authenticated with repo write access

**Risk Level**: Low
**Risk Mitigation**: Deduplication prevents issue spam; labels validated against project set

---

##### Story 06.6-004: Weekly Release Monitor LaunchAgent
**User Story**: As FX, I want the release monitor to run automatically every Monday so that I start the week informed about updates

**Priority**: Should Have
**Story Points**: 5
**Sprint**: Sprint 10

**Acceptance Criteria**:
- **Given** all prerequisite stories are complete (06.6-001 through 06.6-003)
- **When** Monday 7 AM arrives
- **Then** LaunchAgent triggers release-monitor.sh
- **And** full workflow executes:
  1. Fetch release notes
  2. Analyze with Claude
  3. Create GitHub issues (if warranted)
  4. Send email summary
- **And** failures send email notification
- **And** manual trigger available via `release-monitor` alias

**Technical Notes**:
- Main script: `scripts/release-monitor.sh`
- LaunchAgent: `darwin/maintenance.nix`
- Alias: `release-monitor` in `home-manager/modules/shell.nix`

**Implementation**:
```bash
#!/usr/bin/env bash
# scripts/release-monitor.sh
# ABOUTME: Main orchestration script for weekly release monitoring
# ABOUTME: Coordinates fetch, analyze, issue creation, and email steps

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOME}/.local/log/release-monitor.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"; }

# Ensure log directory exists
mkdir -p "$(dirname "${LOG_FILE}")"

log "=== Release Monitor Starting ==="

# Step 1: Fetch release notes
log "Step 1: Fetching release notes..."
RELEASE_FILE="/tmp/release-notes-${TIMESTAMP}.json"
if ! "${SCRIPT_DIR}/fetch-release-notes.sh" "${RELEASE_FILE}" >> "${LOG_FILE}" 2>&1; then
    log "ERROR: Failed to fetch release notes"
    "${SCRIPT_DIR}/send-notification.sh" \
        "${NOTIFICATION_EMAIL:-}" \
        "[ALERT] Release Monitor: Fetch failed" \
        "Release note fetching failed. Check ${LOG_FILE}"
    exit 1
fi

# Step 2: Analyze with Claude
log "Step 2: Analyzing with Claude CLI..."
ANALYSIS_FILE="/tmp/analysis-results-${TIMESTAMP}.json"
if ! "${SCRIPT_DIR}/analyze-releases.sh" "${RELEASE_FILE}" "${ANALYSIS_FILE}" >> "${LOG_FILE}" 2>&1; then
    log "WARNING: Claude analysis failed, continuing with empty analysis"
fi

# Step 3: Create GitHub issues
log "Step 3: Creating GitHub issues..."
ISSUES_FILE="/tmp/created-issues-${TIMESTAMP}.json"
if ! "${SCRIPT_DIR}/create-release-issues.sh" "${ANALYSIS_FILE}" "${ISSUES_FILE}" >> "${LOG_FILE}" 2>&1; then
    log "WARNING: Issue creation failed, continuing"
fi

# Step 4: Send email summary
log "Step 4: Sending email summary..."
"${SCRIPT_DIR}/send-release-summary.sh" "${ANALYSIS_FILE}" "${ISSUES_FILE}" >> "${LOG_FILE}" 2>&1 || true

log "=== Release Monitor Complete ==="

# Cleanup old files (keep last 4 weeks)
find /tmp -name "release-notes-*.json" -mtime +28 -delete 2>/dev/null || true
find /tmp -name "analysis-results-*.json" -mtime +28 -delete 2>/dev/null || true
find /tmp -name "created-issues-*.json" -mtime +28 -delete 2>/dev/null || true
```

**LaunchAgent** (add to `darwin/maintenance.nix`):
```nix
launchd.user.agents.release-monitor = {
  serviceConfig = {
    Label = "com.nix-install.release-monitor";
    ProgramArguments = [
      "${pkgs.bash}/bin/bash"
      "${config.users.users.${username}.home}/Documents/nix-install/scripts/release-monitor.sh"
    ];
    StartCalendarInterval = [{
      Weekday = 1;  # Monday
      Hour = 7;
      Minute = 0;
    }];
    StandardOutPath = "${config.users.users.${username}.home}/.local/log/release-monitor.stdout.log";
    StandardErrorPath = "${config.users.users.${username}.home}/.local/log/release-monitor.stderr.log";
    EnvironmentVariables = {
      PATH = "/run/current-system/sw/bin:/usr/bin:/bin";
      HOME = config.users.users.${username}.home;
      NOTIFICATION_EMAIL = userConfig.email;
    };
  };
};
```

**Alias** (add to `home-manager/modules/shell.nix`):
```nix
shellAliases = {
  # ... existing aliases ...
  release-monitor = "~/Documents/nix-install/scripts/release-monitor.sh";
};
```

**Definition of Done**:
- [x] release-monitor.sh script created
- [ ] LaunchAgent configured in darwin/maintenance.nix (deferred to rebuild)
- [ ] `release-monitor` alias added to shell.nix (deferred to rebuild)
- [x] Workflow executes all four steps
- [x] Error notification sent on failure
- [x] Old files cleaned up after 4 weeks
- [x] Manual test via direct script execution successful

**Dependencies**:
- Stories 06.6-001, 06.6-002, 06.6-003
- Story 06.5-001 (msmtp for email)

**Risk Level**: Low
**Risk Mitigation**: Individual step failures don't block entire workflow; email notification on critical failure

---

##### Story 06.6-005: Release Monitor Email Report
**User Story**: As FX, I want an email summary of the release monitor findings so that I have a record and notification

**Priority**: Should Have
**Story Points**: 3
**Sprint**: Sprint 10

**Acceptance Criteria**:
- **Given** release monitor workflow has completed
- **When** email summary step executes
- **Then** email is sent with:
  - Summary of checked tools and versions
  - List of significant updates found
  - GitHub issues created (with URLs)
  - Recommendations from Claude analysis
- **And** email is sent even if no issues were created (as confirmation)
- **And** email format is clean and readable plain text

**Technical Notes**:
- Script: `scripts/send-release-summary.sh`
- Uses msmtp configured in Story 06.5-001

**Implementation**:
```bash
#!/usr/bin/env bash
# scripts/send-release-summary.sh
# ABOUTME: Sends email summary of release monitor findings
# ABOUTME: Formats analysis results and created issues for email

set -euo pipefail

ANALYSIS_FILE="${1:-/tmp/analysis-results.json}"
ISSUES_FILE="${2:-/tmp/created-issues.json}"
RECIPIENT="${NOTIFICATION_EMAIL:-}"
HOSTNAME=$(hostname)

if [[ -z "${RECIPIENT}" ]]; then
    echo "No NOTIFICATION_EMAIL set, skipping email" >&2
    exit 0
fi

# Extract summary from analysis
SUMMARY=$(jq -r '.summary // "No summary available"' "${ANALYSIS_FILE}" 2>/dev/null || echo "Analysis unavailable")

# Count items by category
SECURITY_COUNT=$(jq -r '.security_updates | length' "${ANALYSIS_FILE}" 2>/dev/null || echo "0")
BREAKING_COUNT=$(jq -r '.breaking_changes | length' "${ANALYSIS_FILE}" 2>/dev/null || echo "0")
FEATURES_COUNT=$(jq -r '.new_features | length' "${ANALYSIS_FILE}" 2>/dev/null || echo "0")
MODELS_COUNT=$(jq -r '.ollama_models | length' "${ANALYSIS_FILE}" 2>/dev/null || echo "0")

# Get created issue URLs
ISSUES=$(jq -r '.[]' "${ISSUES_FILE}" 2>/dev/null | head -10 || echo "None")

# Build and send email
cat << EOF | msmtp "${RECIPIENT}"
Subject: Weekly Release Monitor - ${HOSTNAME}
From: nix-install <${RECIPIENT}>
To: ${RECIPIENT}
Content-Type: text/plain; charset=UTF-8

=== Weekly Release Monitor Report ===
Generated: $(date)
Host: ${HOSTNAME}

EXECUTIVE SUMMARY
${SUMMARY}

FINDINGS BREAKDOWN
- Security Updates: ${SECURITY_COUNT}
- Breaking Changes: ${BREAKING_COUNT}
- New Features: ${FEATURES_COUNT}
- Ollama Models: ${MODELS_COUNT}

GITHUB ISSUES CREATED
${ISSUES:-None created this week}

NEXT STEPS
$(if [[ "${SECURITY_COUNT}" -gt 0 ]]; then echo "⚠️  Review security updates immediately"; fi)
$(if [[ "${BREAKING_COUNT}" -gt 0 ]]; then echo "⚠️  Check breaking changes before next rebuild"; fi)
$(if [[ "${SECURITY_COUNT}" -eq 0 && "${BREAKING_COUNT}" -eq 0 ]]; then echo "✅ No urgent items this week"; fi)

---
Automated report from nix-install release-monitor
Manual trigger: release-monitor
View logs: ~/.local/log/release-monitor.log
EOF

echo "Email sent to ${RECIPIENT}"
```

**Definition of Done**:
- [x] send-release-summary.sh script created
- [x] Email includes all required sections
- [x] Email sent even with zero findings
- [x] Format is clean and readable
- [x] msmtp integration works
- [x] Manual test successful

**Dependencies**:
- Story 06.5-001 (msmtp configured)
- Story 06.6-004 (orchestration script calls this)

**Risk Level**: Low
**Risk Mitigation**: Email is informational only; failure doesn't affect issue creation

---

## Feature Dependencies

### Dependencies on Other Features
- **Feature 06.5**: msmtp email infrastructure required for email reports
- **Epic-02**: GitHub CLI (`gh`) installed via Homebrew
- **Epic-04**: Shell aliases defined in shell.nix

### Internal Story Dependencies
```
Story 06.6-001 (Release Note Fetcher)
         │
         ▼
Story 06.6-002 (Claude CLI Analysis)
         │
         ▼
Story 06.6-003 (GitHub Issue Creation)
         │
         ├──────────────────────┐
         ▼                      ▼
Story 06.6-004             Story 06.6-005
(Weekly LaunchAgent)       (Email Report)
```

## Files to Create

| File | Purpose | Story |
|------|---------|-------|
| `scripts/fetch-release-notes.sh` | Fetch releases from Homebrew, Nix, Ollama | 06.6-001 |
| `scripts/analyze-releases.sh` | Claude CLI analysis wrapper | 06.6-002 |
| `scripts/create-release-issues.sh` | GitHub issue creation | 06.6-003 |
| `scripts/release-monitor.sh` | Main orchestration script | 06.6-004 |
| `scripts/send-release-summary.sh` | Email summary generation | 06.6-005 |
| `.claude/commands/check-releases.md` | Manual trigger slash command | 06.6-002 |

## Files to Modify

| File | Modification | Story |
|------|--------------|-------|
| `darwin/maintenance.nix` | Add release-monitor LaunchAgent | 06.6-004 |
| `home-manager/modules/shell.nix` | Add `release-monitor` alias | 06.6-004 |
| `bootstrap.sh` | Add new scripts to Phase 4 download | All |

## Security Considerations

- **No secrets in scripts**: Environment variables for sensitive data
- **GitHub token**: Uses `gh auth` (already configured)
- **Email credentials**: Via macOS Keychain (Feature 06.5)
- **Claude CLI**: Uses system authentication

## Testing Strategy (Performed by FX)

1. **Fetcher test**: Run `./scripts/fetch-release-notes.sh` manually, verify JSON output
2. **Analysis test**: Run `./scripts/analyze-releases.sh` with sample data
3. **Issue creation test**: Create a test issue, then delete it
4. **Full workflow test**: Run `release-monitor` alias manually
5. **LaunchAgent verification**: `launchctl list | grep release-monitor`
6. **Email test**: Verify email arrives after manual run

## Testing Results (2025-12-06)

### Test Execution Summary

| Test | Status | Notes |
|------|--------|-------|
| 1. Release Note Fetcher | ✅ PASSED | Homebrew (5 formulae, 1 cask), nixpkgs (5 commits), nix-darwin (5 commits), Ollama (9 models, 3 releases) |
| 2. Claude CLI Analysis | ✅ PASSED | 1 security, 1 breaking change, 3 features, 3 models, 4 notable updates |
| 3. GitHub Issue Creation | ✅ PASSED | Bug fixed during testing (deduplication) |
| 4. Full Workflow | ✅ PASSED | 48 seconds total, 11 issues created |
| 5. Email Summary | ✅ PASSED | Email received with correct formatting |

### Bug Fixed During Testing

**Issue**: Deduplication was failing, creating duplicate GitHub issues on subsequent runs.

**Root Cause**: The search term was truncated to 50 characters with `cut -c1-50`, creating partial words (e.g., `"update fr"` from `"update from"`). GitHub search didn't match partial words, returning 0 results.

**Fix**:
1. Extract just the tool name for search query
2. Use `in:title` qualifier for precise GitHub search
3. Fetch matching issue titles and perform exact string comparison
4. Handle empty array output properly

**Files Modified**: `scripts/create-release-issues.sh` (lines 48-79, 87-92, 341-346)

### Email Validation

Received email at `notifications@fxmartin.me` with:
- ✅ Subject: `Weekly Release Monitor - fxmartins-MacBook-Pro.local`
- ✅ Status banner: `ATTENTION REQUIRED: Security updates found`
- ✅ Executive summary (actionable, concise)
- ✅ Findings breakdown with counts
- ✅ GitHub issue URLs (10 issues)
- ✅ Next steps (prioritized)
- ✅ Useful commands section

### Remaining Items (Deferred to Rebuild)

- [ ] LaunchAgent in `darwin/maintenance.nix`
- [ ] `release-monitor` alias in `home-manager/modules/shell.nix`
- [ ] `.claude/commands/check-releases.md` slash command
