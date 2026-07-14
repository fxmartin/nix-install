#!/usr/bin/env bats
# ABOUTME: Guards the intentionally minimal Microsoft Office application set
# ABOUTME: Prevents the full Office suite and unwanted companion apps from returning

setup() {
    HOMEBREW_CONFIG="${BATS_TEST_DIRNAME}/../darwin/homebrew.nix"
    README_FILE="${BATS_TEST_DIRNAME}/../README.md"
}

@test "Standard and Power profiles install only the three required Office apps" {
    for cask_name in microsoft-word microsoft-excel microsoft-powerpoint; do
        run rg -n "\"${cask_name}\"" "$HOMEBREW_CONFIG"
        [ "$status" -eq 0 ]
    done
}

@test "full Office bundle and companion apps remain absent" {
    run rg -n '"microsoft-(office|office-businesspro|outlook|onenote|teams|onedrive|365-copilot)"' \
        "$HOMEBREW_CONFIG"
    [ "$status" -eq 1 ]
}

@test "README advertises the minimal Office set" {
    run rg -n 'Office 365 \(Word, Excel, PowerPoint\)' "$README_FILE"
    [ "$status" -eq 0 ]

    run rg -n 'Office 365 \(Word, Excel, PowerPoint, Outlook, OneNote, Teams\)' "$README_FILE"
    [ "$status" -eq 1 ]
}
