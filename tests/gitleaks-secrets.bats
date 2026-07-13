#!/usr/bin/env bats
# ABOUTME: Test suite for the gitleaks CI gate (Story 9.2-001)
# ABOUTME: Validates CI workflow shape, .gitleaks.toml config, fixture allowlist,
# ABOUTME: and gitleaks detection/clean-repo/allowlist/history-mode behaviors.
# ABOUTME: Uses gitleaks v8 API (dir / git subcommands).

# ---------------------------------------------------------------------------
# Setup helpers
# ---------------------------------------------------------------------------

REPO_ROOT="${BATS_TEST_DIRNAME}/.."
WORKFLOW="${REPO_ROOT}/.github/workflows/security-scan.yml"
GITLEAKS_CONFIG="${REPO_ROOT}/.gitleaks.toml"
FIXTURE="${REPO_ROOT}/tests/fixtures/leaked-key.txt"

setup() {
    # Locate gitleaks binary — try $PATH first, then well-known nix-managed path
    GITLEAKS_BIN=""
    if command -v gitleaks &>/dev/null; then
        GITLEAKS_BIN="$(command -v gitleaks)"
    elif [[ -x /run/current-system/sw/bin/gitleaks ]]; then
        GITLEAKS_BIN="/run/current-system/sw/bin/gitleaks"
    fi
}

# Skip a test with a clear reason when gitleaks is unavailable.
require_gitleaks() {
    if [[ -z "$GITLEAKS_BIN" ]]; then
        skip "gitleaks binary not found — skipped (CI will validate)"
    fi
}

# ---------------------------------------------------------------------------
# CI Workflow shape tests
# ---------------------------------------------------------------------------

@test "security-scan.yml exists" {
    [ -f "$WORKFLOW" ]
}

@test "security-scan.yml triggers on pull_request to main" {
    run grep -E "pull_request" "$WORKFLOW"
    [ "$status" -eq 0 ]
    [[ "$output" == *"pull_request"* ]]
}

@test "security-scan.yml triggers on push to main" {
    run grep -E "push" "$WORKFLOW"
    [ "$status" -eq 0 ]
}

@test "security-scan.yml targets main branch for both triggers" {
    # Count occurrences of main under the on: triggers block
    run grep -c "main" "$WORKFLOW"
    [ "$status" -eq 0 ]
    [ "$output" -ge 2 ]
}

@test "security-scan.yml uses full fetch-depth for history scan" {
    run grep "fetch-depth: 0" "$WORKFLOW"
    [ "$status" -eq 0 ]
}

@test "security-scan.yml references gitleaks action" {
    run grep "gitleaks/gitleaks-action" "$WORKFLOW"
    [ "$status" -eq 0 ]
}

@test "security-scan.yml passes GITHUB_TOKEN to gitleaks action" {
    run grep "GITHUB_TOKEN" "$WORKFLOW"
    [ "$status" -eq 0 ]
}

@test "security-scan.yml references GITLEAKS_CONFIG pointing to .gitleaks.toml" {
    run grep "GITLEAKS_CONFIG" "$WORKFLOW"
    [ "$status" -eq 0 ]
    [[ "$output" == *".gitleaks.toml"* ]]
}

@test "security-scan.yml has ABOUTME header comments" {
    run grep "^# ABOUTME:" "$WORKFLOW"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -ge 2 ]
}

@test "security-scan.yml supports workflow_dispatch for manual triggers" {
    run grep "workflow_dispatch" "$WORKFLOW"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# .gitleaks.toml config shape tests
# ---------------------------------------------------------------------------

@test ".gitleaks.toml exists at repo root" {
    [ -f "$GITLEAKS_CONFIG" ]
}

@test ".gitleaks.toml extends useDefault ruleset" {
    run grep "useDefault = true" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
}

@test ".gitleaks.toml has global allowlist section" {
    run grep "\[allowlist\]" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
}

@test ".gitleaks.toml has ABOUTME header comments" {
    run grep "^# ABOUTME:" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
}

@test ".gitleaks.toml allowlists calibre plugin path (known false positive)" {
    run grep "calibre" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
}

@test ".gitleaks.toml allowlists the synthetic test fixture path" {
    run grep "leaked-key" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
}

@test ".gitleaks.toml has commit-level allowlist entries for historical placeholders" {
    # Verify at least one SHA is allowlisted
    run grep -E "[0-9a-f]{40}" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
}

@test ".gitleaks.toml is valid TOML (no syntax errors caught by grep heuristic)" {
    # Rough sanity: every [section] line should not have stray characters
    run grep -E "^\[" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
    # Each section header must end with ] not trailing garbage
    while IFS= read -r line; do
        [[ "$line" =~ ^\[.*\]$ ]]
    done < <(grep -E "^\[" "$GITLEAKS_CONFIG")
}

# ---------------------------------------------------------------------------
# Test fixture tests
# ---------------------------------------------------------------------------

@test "tests/fixtures/leaked-key.txt exists" {
    [ -f "$FIXTURE" ]
}

@test "tests/fixtures/leaked-key.txt contains ABOUTME header" {
    run grep "^# ABOUTME:" "$FIXTURE"
    [ "$status" -eq 0 ]
}

@test "tests/fixtures/leaked-key.txt contains a fake RSA private key block" {
    run grep "BEGIN RSA PRIVATE KEY" "$FIXTURE"
    [ "$status" -eq 0 ]
}

@test "tests/fixtures/leaked-key.txt contains END RSA PRIVATE KEY marker" {
    run grep "END RSA PRIVATE KEY" "$FIXTURE"
    [ "$status" -eq 0 ]
}

@test "tests/fixtures/leaked-key.txt contains a comment marking it as fake/fabricated" {
    run grep -i "fake\|fabricated\|synthetic\|NOT real\|not a real" "$FIXTURE"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Gitleaks detection tests (skip gracefully when binary absent)
# ---------------------------------------------------------------------------

@test "gitleaks binary is available (skip if absent)" {
    require_gitleaks
    run "$GITLEAKS_BIN" version
    [ "$status" -eq 0 ]
}

@test "gitleaks dir: clean directory scan produces zero findings" {
    require_gitleaks
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    echo "# harmless nix config" > "$tmpdir/flake.nix"
    echo "description = no secrets here" >> "$tmpdir/flake.nix"
    run "$GITLEAKS_BIN" dir "$tmpdir" 2>&1
    [ "$status" -eq 0 ]
}

@test "gitleaks dir: detects RSA private key in a temp file (no config)" {
    require_gitleaks
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    # Write a fake RSA key block — gitleaks default rules flag this pattern.
    # The key header is split across variables to prevent gitleaks from flagging
    # the test file itself (the fixture file tests/fixtures/leaked-key.txt is the
    # authoritative copy for detection testing).
    cp "$FIXTURE" "$tmpdir/fake-secret.pem"
    run "$GITLEAKS_BIN" dir "$tmpdir" 2>&1
    # gitleaks exits 1 when leaks are found
    [ "$status" -eq 1 ]
}

@test "gitleaks dir: fixture file triggers detection WITHOUT config allowlist" {
    require_gitleaks
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    cp "$FIXTURE" "$tmpdir/leaked-key.txt"
    run "$GITLEAKS_BIN" dir "$tmpdir" 2>&1
    # The fixture RSA key block must be detected (exit 1 = leaks found)
    [ "$status" -eq 1 ]
}

@test "gitleaks dir: repo fixtures directory is CLEAN with .gitleaks.toml allowlist" {
    require_gitleaks
    # Scan the actual fixtures directory using the project config — must be clean
    run "$GITLEAKS_BIN" dir "${REPO_ROOT}/tests/fixtures" \
        --config "$GITLEAKS_CONFIG" 2>&1
    [ "$status" -eq 0 ]
}

@test "gitleaks dir: tracked working tree scan produces no unexpected findings" {
    require_gitleaks
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT

    # Copy tracked regular files only. Scanning the repository directory directly
    # also traverses local caches, downloaded artifacts, and nested repositories.
    while IFS= read -r -d '' tracked_file; do
        if [[ -f "${REPO_ROOT}/${tracked_file}" ]]; then
            mkdir -p "${tmpdir}/$(dirname "$tracked_file")"
            cp "${REPO_ROOT}/${tracked_file}" "${tmpdir}/${tracked_file}"
        fi
    done < <(git -C "$REPO_ROOT" ls-files -z)

    run "$GITLEAKS_BIN" dir "$tmpdir" \
        --config "$GITLEAKS_CONFIG" 2>&1
    [ "$status" -eq 0 ]
}

@test "gitleaks git: history-mode scan of recent commits exits without tool error" {
    require_gitleaks
    # Scan last 10 commits in git history — verifies the gate works in history mode
    cd "$REPO_ROOT"
    run "$GITLEAKS_BIN" git . \
        --config "$GITLEAKS_CONFIG" \
        --log-opts="-n 10" 2>&1
    # Exit codes: 0=clean, 1=leaks found, >1=tool/parse error
    # We accept 0 or 1 (findings), but reject tool crashes (>1)
    [ "$status" -lt 2 ]
}

@test "gitleaks git: recent commits produce no findings with project config" {
    require_gitleaks
    cd "$REPO_ROOT"
    run "$GITLEAKS_BIN" git . \
        --config "$GITLEAKS_CONFIG" \
        --log-opts="-n 5" 2>&1
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Allowlist false-negative guard
# ---------------------------------------------------------------------------

@test "allowlist guard: fixture path pattern in .gitleaks.toml matches leaked-key.txt" {
    run grep "leaked-key" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
    [[ "$output" == *"leaked-key"* ]]
}

@test "allowlist guard: calibre plugin path is still in allowlist (regression)" {
    run grep "calibre" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
}

@test "allowlist guard: commit allowlist covers at least one historical SHA" {
    run grep -E "'''[0-9a-f]{40}'''" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
}

@test "allowlist guard: fixture allowlist entry covers tests/fixtures path" {
    # The allowlist path pattern must be broad enough to cover tests/fixtures/leaked-key.txt
    # It uses leaked-key as the path pattern which matches the filename
    run grep -E "leaked-key|tests/fixtures" "$GITLEAKS_CONFIG"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Integration: CI workflow + config coherence
# ---------------------------------------------------------------------------

@test "integration: workflow GITLEAKS_CONFIG matches repo config filename" {
    run grep "GITLEAKS_CONFIG.*\.gitleaks\.toml" "$WORKFLOW"
    [ "$status" -eq 0 ]
    [ -f "${REPO_ROOT}/.gitleaks.toml" ]
}

@test "integration: gitleaks-action is pinned to an immutable commit SHA" {
    run grep "gitleaks-action@" "$WORKFLOW"
    [ "$status" -eq 0 ]
    [[ "$output" =~ @[0-9a-f]{40}([[:space:]]|$) ]]
}

@test "integration: checkout action is pinned to an immutable commit SHA" {
    run grep "actions/checkout@" "$WORKFLOW"
    [ "$status" -eq 0 ]
    [[ "$output" =~ @[0-9a-f]{40}([[:space:]]|$) ]]
}

@test "integration: gitleaks config and fixture are both committed to the branch" {
    [ -f "$GITLEAKS_CONFIG" ]
    [ -f "$FIXTURE" ]
}

# ---------------------------------------------------------------------------
# Manual test stubs (FX performs in CI environment)
# ---------------------------------------------------------------------------

@test "MANUAL: PR with a real AWS key is blocked by gitleaks action" {
    skip "Manual test: open a PR with a real-looking AWS key, verify CI fails"
}

@test "MANUAL: PR with no secrets passes the gitleaks gate cleanly" {
    skip "Manual test: open a normal PR, verify security-scan job passes green"
}

@test "MANUAL: workflow_dispatch runs scan against main branch without error" {
    skip "Manual test: trigger workflow_dispatch from GitHub Actions UI"
}

@test "MANUAL: .gitleaks.toml path allowlist suppresses the fixture file in live CI" {
    skip "Manual test: confirm tests/fixtures/leaked-key.txt does not fail CI on a PR"
}
