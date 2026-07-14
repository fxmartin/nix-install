#!/usr/bin/env bats
# ABOUTME: Guards the reduced communication stack and global Hugging Face CLI
# ABOUTME: Prevents retired meeting apps and apfel from returning to managed state

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    DARWIN_CONFIG="${REPO_ROOT}/darwin/configuration.nix"
    HOMEBREW_CONFIG="${REPO_ROOT}/darwin/homebrew.nix"
}

@test "Hugging Face Hub CLI is installed globally from Nix" {
    run rg -n '^\s+python312Packages\.huggingface-hub\b' "$DARWIN_CONFIG"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
}

@test "retired meeting and Apple Intelligence tools are absent from Homebrew" {
    run rg -n '^\s+"(apfel|zoom|webex)"' "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]
}

@test "current documentation no longer advertises Zoom or Webex" {
    run rg -n -i '\b(zoom|webex)\b' \
        "${REPO_ROOT}/README.md" \
        "${REPO_ROOT}/docs/REQUIREMENTS.md" \
        "${REPO_ROOT}/docs/apps/README.md" \
        "${REPO_ROOT}/docs/apps/communication/whatsapp.md" \
        "${REPO_ROOT}/docs/licensed-apps.md" \
        "${REPO_ROOT}/docs/post-install.md"
    [ "$status" -eq 1 ]
}

@test "retired meeting-app guides are removed" {
    [ ! -e "${REPO_ROOT}/docs/apps/communication/zoom.md" ]
    [ ! -e "${REPO_ROOT}/docs/apps/communication/cisco-webex.md" ]
}
