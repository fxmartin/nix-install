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
    # A umask alone is NOT sufficient: '> file' on an existing path truncates
    # in place and keeps the old mode, so the path must be unlinked first.
    run rg -n 'umask 077' "$SMB_MODULE"
    [ "$status" -eq 0 ]

    local umask_line unlink_line write_line
    umask_line=$(rg -n 'umask 077' "$SMB_MODULE" | head -1 | cut -d: -f1)
    write_line=$(rg -n 'cat > /etc/auto_smb << AUTO_SMB_EOF' "$SMB_MODULE" | head -1 | cut -d: -f1)
    unlink_line=$(rg -n 'rm -f /etc/auto_smb' "$SMB_MODULE" \
        | awk -F: -v lo="$umask_line" -v hi="$write_line" '$1 > lo && $1 < hi { print $1; exit }')
    [ -n "$unlink_line" ]
}

@test "no-password auto_smb write also unlinks before creating" {
    local umask_line unlink_line write_line
    umask_line=$(rg -n 'umask 022' "$SMB_MODULE" | head -1 | cut -d: -f1)
    write_line=$(rg -n "cat > /etc/auto_smb << 'AUTO_SMB_EOF'" "$SMB_MODULE" | head -1 | cut -d: -f1)
    unlink_line=$(rg -n 'rm -f /etc/auto_smb' "$SMB_MODULE" \
        | awk -F: -v lo="$umask_line" -v hi="$write_line" '$1 > lo && $1 < hi { print $1; exit }')
    [ -n "$unlink_line" ]
}

# Extracts the credentialed branch's real command sequence (umask through the
# opening 'cat >' line) from the module, retargets it at $1, and executes it so
# the assertions below exercise the shipped ordering rather than a hand-copied
# imitation of it.
run_credentialed_write_sequence() {
    local target="$1" script
    script=$(mktemp)
    # Anchor on the bare 'umask 077' command, not the comment that mentions it,
    # so the extracted fragment starts inside the subshell and stays balanced.
    awk '
        /^[[:space:]]*umask 077[[:space:]]*$/ { capture = 1 }
        capture                               { sub(/^[[:space:]]+/, ""); print }
        /cat > \/etc\/auto_smb << AUTO_SMB_EOF/ { if (capture) exit }
    ' "$SMB_MODULE" | sed "s#/etc/auto_smb#${target}#g" > "$script"
    printf 'placeholder-map-line\nAUTO_SMB_EOF\n' >> "$script"
    bash "$script"
    rm -f "$script"
}

@test "credentialed write yields owner-only mode even when auto_smb already exists world-readable" {
    # Regression guard for the actual race: /etc/auto_smb survives across
    # rebuilds, so on every rebuild after the first -- and in particular after
    # a rebuild that took the no-password branch and left the file at 644 --
    # the credential is written onto a pre-existing path. A umask cannot fix
    # the mode of an existing file, so this must be 600 from the first byte,
    # before the trailing chmod ever runs.
    local tmpdir target perm
    tmpdir=$(mktemp -d)
    target="${tmpdir}/auto_smb"

    printf 'stale world-readable map\n' > "$target"
    chmod 644 "$target"

    run_credentialed_write_sequence "$target"

    perm=$(stat -f '%Lp' "$target")
    run grep -q 'placeholder-map-line' "$target"
    local content_status="$status"
    rm -rf "$tmpdir"

    [ "$content_status" -eq 0 ]
    [ "$perm" = "600" ]
}

@test "credentialed write yields owner-only mode when auto_smb does not yet exist" {
    local tmpdir target perm
    tmpdir=$(mktemp -d)
    target="${tmpdir}/auto_smb"

    run_credentialed_write_sequence "$target"

    perm=$(stat -f '%Lp' "$target")
    rm -rf "$tmpdir"
    [ "$perm" = "600" ]
}

@test "the existing-file regression test has teeth: omitting the unlink leaves 644" {
    # Negative control. If this ever reports 600, the assertion above has
    # stopped proving anything and the guard must be re-derived.
    local tmpdir target perm
    tmpdir=$(mktemp -d)
    target="${tmpdir}/auto_smb"

    printf 'stale world-readable map\n' > "$target"
    chmod 644 "$target"
    ( umask 077; printf 'secret\n' > "$target" )

    perm=$(stat -f '%Lp' "$target")
    rm -rf "$tmpdir"
    [ "$perm" = "644" ]
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

@test "credentialed chmod 600 executes only after the umask 077 subshell closes" {
    local umask_line close_line chmod_line
    umask_line=$(rg -n 'umask 077' "$SMB_MODULE" | head -1 | cut -d: -f1)
    close_line=$(rg -n '^\s*AUTO_SMB_EOF\s*$' "$SMB_MODULE" | awk -F: -v start="$umask_line" '$1 > start { print $1; exit }')
    chmod_line=$(rg -n 'chmod 600 /etc/auto_smb' "$SMB_MODULE" | head -1 | cut -d: -f1)
    [ -n "$umask_line" ]
    [ -n "$close_line" ]
    [ -n "$chmod_line" ]
    [ "$umask_line" -lt "$close_line" ]
    [ "$close_line" -lt "$chmod_line" ]
}

@test "no-password chmod 644 executes only after the umask 022 subshell closes" {
    local umask_line close_line chmod_line
    umask_line=$(rg -n 'umask 022' "$SMB_MODULE" | head -1 | cut -d: -f1)
    close_line=$(rg -n '^\s*AUTO_SMB_EOF\s*$' "$SMB_MODULE" | awk -F: -v start="$umask_line" '$1 > start { print $1; exit }')
    chmod_line=$(rg -n 'chmod 644 /etc/auto_smb' "$SMB_MODULE" | head -1 | cut -d: -f1)
    [ -n "$umask_line" ]
    [ -n "$close_line" ]
    [ -n "$chmod_line" ]
    [ "$umask_line" -lt "$close_line" ]
    [ "$close_line" -lt "$chmod_line" ]
}

@test "umask 077 extracted from the credentialed branch actually strips group/other rwx on a real file" {
    local umask_val tmpdir perm
    umask_val=$(rg -o 'umask 0[0-7]{2,3}' "$SMB_MODULE" | head -1 | awk '{print $2}')
    [ "$umask_val" = "077" ]

    tmpdir=$(mktemp -d)
    ( umask "$umask_val"; : > "$tmpdir/secretfile" )
    perm=$(stat -f '%Lp' "$tmpdir/secretfile")
    rm -rf "$tmpdir"
    [ "$perm" = "600" ]
}

@test "URL-encode sed pipeline does not double-encode a literal percent sequence alongside a real @" {
    local line sed_expr
    line=$(rg "URL_ENCODE_SED='" "$SMB_MODULE")
    sed_expr=$(echo "$line" | sed -E "s/^[^']*URL_ENCODE_SED='([^']*)'.*/\1/")
    [ -n "$sed_expr" ]

    # A password that already contains the literal text "%40" (which happens
    # to be the escape sequence '@' encodes to) must have its '%' encoded to
    # %25 without corrupting the trailing "40", and the real '@' must still
    # be encoded to %40 -- proving % is encoded before the other rules run.
    RAW_PASSWORD='user%40name@host'
    run bash -c 'echo "$1" | sed -e "$2"' _ "$RAW_PASSWORD" "$sed_expr"
    [ "$status" -eq 0 ]
    [ "$output" = "user%2540name%40host" ]
}

@test "URL-encode sed pipeline handles an empty password without error" {
    local line sed_expr
    line=$(rg "URL_ENCODE_SED='" "$SMB_MODULE")
    sed_expr=$(echo "$line" | sed -E "s/^[^']*URL_ENCODE_SED='([^']*)'.*/\1/")
    [ -n "$sed_expr" ]

    RAW_PASSWORD=''
    run bash -c 'echo "$1" | sed -e "$2"' _ "$RAW_PASSWORD" "$sed_expr"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "no-password branch's SMB URL structurally omits the credential placeholder" {
    local no_cred_count cred_count
    no_cred_count=$(grep -Fc -- '${nasConfig.username}@${nasConfig.host}' "$SMB_MODULE")
    cred_count=$(grep -Fc -- ':\$ENCODED_PASSWORD@' "$SMB_MODULE")
    [ "$no_cred_count" -eq 1 ]
    [ "$cred_count" -eq 1 ]
}
