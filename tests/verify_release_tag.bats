#!/usr/bin/env bats
# ABOUTME: Tests the three-way release-tag signature classification (issue #358)
# ABOUTME: Guards against accepting an unsigned tag as signed, the prior bug

setup() {
    VERIFY="${BATS_TEST_DIRNAME}/../scripts/verify-release-tag.sh"
    REPO="${BATS_TEST_TMPDIR}/repo"
    mkdir -p "$REPO"
    cd "$REPO" || return 1
    git init -q .
    git config user.email t@example.com
    git config user.name Tester
    git commit -q --allow-empty -m "seed"
}

@test "unknown tag exits 2" {
    run bash "$VERIFY" v9.9.9
    [ "$status" -eq 2 ]
    [[ "$output" == *"does not exist"* ]]
}

@test "lightweight tag is rejected as unsigned" {
    git tag v1.0.0
    run bash "$VERIFY" v1.0.0
    [ "$status" -eq 1 ]
    [[ "$output" == *"lightweight"* ]]
}

@test "unsigned annotated tag is rejected" {
    # The exact case the previous grep-for-a-block check let through when the
    # block was absent, and which must never be reported as signed.
    git tag -a v1.0.0 -m "Release v1.0.0"
    run bash "$VERIFY" v1.0.0
    [ "$status" -eq 1 ]
    [[ "$output" == *"no signature"* ]]
}

@test "missing tag name exits 2 with usage" {
    run bash "$VERIFY"
    [ "$status" -eq 2 ]
}

@test "signed but unverifiable is REJECTED by default (fails closed)" {
    # SSH signing with no allowedSignersFile: git tag -v exits non-zero even
    # though the tag is genuinely signed. A signature nobody can check proves
    # nothing, so this must fail rather than be waved through.
    ssh-keygen -q -t ed25519 -N "" -f "${BATS_TEST_TMPDIR}/k" </dev/null
    git config gpg.format ssh
    git config user.signingkey "${BATS_TEST_TMPDIR}/k.pub"
    git tag -s v1.0.0 -m "Release v1.0.0"
    run bash "$VERIFY" v1.0.0
    [ "$status" -eq 1 ]
    [[ "$output" == *"signer trust is not configured"* ]]
    # The remedy must be printed, or the failure is just an obstacle.
    [[ "$output" == *"allowedSignersFile"* ]]
}

@test "explicit opt-out accepts a signed but unverifiable tag" {
    ssh-keygen -q -t ed25519 -N "" -f "${BATS_TEST_TMPDIR}/k" </dev/null
    git config gpg.format ssh
    git config user.signingkey "${BATS_TEST_TMPDIR}/k.pub"
    git tag -s v1.0.0 -m "Release v1.0.0"
    run env RELEASE_ALLOW_UNVERIFIED_TAG=1 bash "$VERIFY" v1.0.0
    [ "$status" -eq 0 ]
    [[ "$output" == *"NOT verified"* ]]
}

@test "fully verifiable signed tag passes cleanly" {
    ssh-keygen -q -t ed25519 -N "" -f "${BATS_TEST_TMPDIR}/k" </dev/null
    git config gpg.format ssh
    git config user.signingkey "${BATS_TEST_TMPDIR}/k.pub"
    printf 't@example.com %s' "$(cat "${BATS_TEST_TMPDIR}/k.pub")" \
        >"${BATS_TEST_TMPDIR}/allowed_signers"
    git config gpg.ssh.allowedSignersFile "${BATS_TEST_TMPDIR}/allowed_signers"
    git tag -s v1.0.0 -m "Release v1.0.0"
    run env GIT_CONFIG_GLOBAL=/dev/null bash "$VERIFY" v1.0.0
    [ "$status" -eq 0 ]
    [[ "$output" == *"signature verified"* ]]
}

@test "configured signer trust takes precedence over the repo fallback" {
    ssh-keygen -q -t ed25519 -N "" -f "${BATS_TEST_TMPDIR}/signing-key" </dev/null
    ssh-keygen -q -t ed25519 -N "" -f "${BATS_TEST_TMPDIR}/other-key" </dev/null
    git config gpg.format ssh
    git config user.signingkey "${BATS_TEST_TMPDIR}/signing-key.pub"
    git tag -s v1.0.0 -m "Release v1.0.0"
    printf 't@example.com %s' "$(cat "${BATS_TEST_TMPDIR}/signing-key.pub")" \
        >"${REPO}/.allowed_signers"
    printf 't@example.com %s' "$(cat "${BATS_TEST_TMPDIR}/other-key.pub")" \
        >"${BATS_TEST_TMPDIR}/configured_allowed_signers"
    git config gpg.ssh.allowedSignersFile "${BATS_TEST_TMPDIR}/configured_allowed_signers"

    run bash "$VERIFY" v1.0.0
    [ "$status" -eq 1 ]
    [[ "$output" == *"signature is invalid"* ]]
}

@test "repo-owned signer trust verifies a tag without local configuration" {
    ssh-keygen -q -t ed25519 -N "" -f "${BATS_TEST_TMPDIR}/k" </dev/null
    git config gpg.format ssh
    git config user.signingkey "${BATS_TEST_TMPDIR}/k.pub"
    git tag -s v1.0.0 -m "Release v1.0.0"
    printf 't@example.com %s' "$(cat "${BATS_TEST_TMPDIR}/k.pub")" \
        >"${REPO}/.allowed_signers"
    git config --unset gpg.format
    git config --unset user.signingkey

    run env GIT_CONFIG_GLOBAL=/dev/null bash "$VERIFY" v1.0.0
    [ "$status" -eq 0 ]
    [[ "$output" == *"signature verified"* ]]
}
