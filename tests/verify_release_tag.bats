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

@test "signed but unverifiable warns and accepts by default" {
    # SSH signing with no allowedSignersFile: git tag -v exits non-zero even
    # though the tag is genuinely signed. Must be told apart from a bad one.
    ssh-keygen -q -t ed25519 -N "" -f "${BATS_TEST_TMPDIR}/k" </dev/null
    git config gpg.format ssh
    git config user.signingkey "${BATS_TEST_TMPDIR}/k.pub"
    git tag -s v1.0.0 -m "Release v1.0.0"
    run bash "$VERIFY" v1.0.0
    [ "$status" -eq 0 ]
    [[ "$output" == *"NOT verified"* ]]
}

@test "strict mode rejects a signed but unverifiable tag" {
    ssh-keygen -q -t ed25519 -N "" -f "${BATS_TEST_TMPDIR}/k" </dev/null
    git config gpg.format ssh
    git config user.signingkey "${BATS_TEST_TMPDIR}/k.pub"
    git tag -s v1.0.0 -m "Release v1.0.0"
    run env RELEASE_REQUIRE_VERIFIED_TAG=1 bash "$VERIFY" v1.0.0
    [ "$status" -eq 1 ]
    [[ "$output" == *"could not be verified"* ]]
}

@test "fully verifiable signed tag passes cleanly" {
    ssh-keygen -q -t ed25519 -N "" -f "${BATS_TEST_TMPDIR}/k" </dev/null
    git config gpg.format ssh
    git config user.signingkey "${BATS_TEST_TMPDIR}/k.pub"
    printf 't@example.com %s' "$(cat "${BATS_TEST_TMPDIR}/k.pub")" \
        >"${BATS_TEST_TMPDIR}/allowed_signers"
    git config gpg.ssh.allowedSignersFile "${BATS_TEST_TMPDIR}/allowed_signers"
    git tag -s v1.0.0 -m "Release v1.0.0"
    run bash "$VERIFY" v1.0.0
    [ "$status" -eq 0 ]
    [[ "$output" == *"signature verified"* ]]
}
