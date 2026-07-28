#!/usr/bin/env bats
# ABOUTME: Regression tests for the /etc/auto_smb credential write race (10.3-002)
# ABOUTME: Verifies restrictive permissions from first byte and full URL-encoding

setup() {
    REPO_ROOT="${BATS_TEST_DIRNAME}/.."
    SMB_MODULE="${REPO_ROOT}/darwin/smb-automount.nix"
}

@test "credentialed auto_smb write sets umask 077 before the heredoc content" {
    run rg -n 'umask 077' "$SMB_MODULE"
    [ "$status" -eq 0 ]

    local umask_line write_line
    umask_line=$(rg -n 'umask 077' "$SMB_MODULE" | head -1 | cut -d: -f1)
    write_line=$(rg -n 'cat > /etc/auto_smb << AUTO_SMB_EOF' "$SMB_MODULE" | head -1 | cut -d: -f1)
    [ -n "$umask_line" ]
    [ -n "$write_line" ]
    [ "$umask_line" -lt "$write_line" ]
}

@test "credentialed auto_smb write no longer relies on chmod-after alone" {
    # The umask must be the mechanism establishing the mode; chmod 600 may
    # still run afterward for clarity/logging but must not be the only guard.
    run rg -n 'umask 077' "$SMB_MODULE"
    [ "$status" -eq 0 ]
}

@test "no-password auto_smb write keeps a consistent umask-then-content ordering" {
    run rg -n 'umask 022' "$SMB_MODULE"
    [ "$status" -eq 0 ]

    local umask_line write_line
    umask_line=$(rg -n 'umask 022' "$SMB_MODULE" | head -1 | cut -d: -f1)
    write_line=$(rg -n "cat > /etc/auto_smb << 'AUTO_SMB_EOF'" "$SMB_MODULE" | head -1 | cut -d: -f1)
    [ -n "$umask_line" ]
    [ -n "$write_line" ]
    [ "$umask_line" -lt "$write_line" ]

    run rg -n 'chmod 644 /etc/auto_smb' "$SMB_MODULE"
    [ "$status" -eq 0 ]
}

@test "URL-encode sed pipeline encodes percent first" {
    run rg -n "URL_ENCODE_SED='" "$SMB_MODULE"
    [ "$status" -eq 0 ]

    local line pct_idx at_idx
    line=$(rg "URL_ENCODE_SED='" "$SMB_MODULE")
    pct_idx=$(awk -v l="$line" 'BEGIN{print index(l, "s/%/%25/g")}')
    at_idx=$(awk -v l="$line" 'BEGIN{print index(l, "s/@/%40/g")}')
    [ "$pct_idx" -gt 0 ]
    [ "$at_idx" -gt 0 ]
    [ "$pct_idx" -lt "$at_idx" ]
}

@test "URL-encode sed pipeline covers space, plus, and semicolon" {
    for token in 's/%/%25/g' 's/ /%20/g' 's/+/%2B/g' 's/;/%3B/g'; do
        run grep -F -- "$token" "$SMB_MODULE"
        [ "$status" -eq 0 ]
    done
}

@test "URL-encode sed pipeline correctly encodes a password with %, space, +, and ;" {
    local line sed_expr
    line=$(rg "URL_ENCODE_SED='" "$SMB_MODULE")
    sed_expr=$(echo "$line" | sed -E "s/^[^']*URL_ENCODE_SED='([^']*)'.*/\1/")
    [ -n "$sed_expr" ]

    RAW_PASSWORD='p@ss:w/ord#1?a&b 100%+;free'
    run bash -c 'echo "$1" | sed -e "$2"' _ "$RAW_PASSWORD" "$sed_expr"
    [ "$status" -eq 0 ]
    [ "$output" = "p%40ss%3Aw%2Ford%231%3Fa%26b%20100%25%2B%3Bfree" ]
}
