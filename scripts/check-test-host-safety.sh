#!/usr/bin/env bash
# ABOUTME: Fails when a test file mutates real host paths instead of a temp fixture
# ABOUTME: Guards against the class of bug that wiped /opt/homebrew on 2026-07-28

# Why this exists:
#
# tests/bootstrap_nix_darwin.bats built its Homebrew mock at the real
# /opt/homebrew/bin/brew, and its teardown ran `rm -f /opt/homebrew/bin/brew`
# after every test — 87 times per run. /opt/homebrew is owned by the invoking
# user, so this needed no sudo and failed silently. The first test deleted the
# real brew binary; every later setup recreated it as an empty stub.
#
# On 2026-07-28 an agent ran that suite directly, bypassing tests/run-safe-suite.sh
# (whose entire purpose is to exclude host-mutating suites), and destroyed a
# working Homebrew installation — empty Caskroom, ~40 casks force-reinstalled.
# The landmine had been on main since commit 8b3e0e1 (Story 01.5-001, Epic-01),
# dormant for months because nothing ran that suite.
#
# An allowlist only helps if someone remembers to consult it. This check does not
# depend on anyone remembering.
#
# Tests must use "$TEST_TMP_DIR" / "$BATS_TEST_TMPDIR". Where production code
# hardcodes a system location, add an override seam rather than mutating the host
# (see NIX_INSTALL_BREW_PATH in lib/nix-darwin.sh).

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

# Commands that create, destroy, or overwrite. `tee` counts: `... | tee /etc/x`
# truncates just as surely as `>`.
destructive='rm|rmdir|mkdir|touch|chmod|chown|mv|cp|ln|dd|truncate|tee'

# System locations a test must never touch. A token starting with
# "${TEST_TMP_DIR}" cannot match these — the check is on the literal leading
# path, which is exactly the distinction we want.
system_paths='/opt|/usr|/etc|/nix|/Library|/Applications|/System|/var|/private'

# $HOME is different: overriding it to a temp dir in setup() is the *correct*
# sandboxing pattern, and most suites here do it. So these are only flagged in
# files that do not sandbox HOME. '\$HOME[/"]' avoids matching $HOME_DIR.
home_paths='\$\{HOME\}|\$HOME[/"]|~/|/Users/|/home/'

prefix='(^|[;&|]|\bsudo\b|\brun\b)[[:space:]]*'
suffix='([[:space:]]+-[^[:space:]]+)*[[:space:]]+["'"'"']?'

violations=0

# A file is considered HOME-safe if it reassigns HOME to a temp location. The
# suffix match is deliberately loose: this repo spells the variable both
# TEST_TMP_DIR and TEST_TEMP_DIR, and matching only one produced a wall of false
# positives that would have trained everyone to ignore this check.
sandboxes_home() {
    grep -qE 'HOME=.*(TMPDIR|TMP_DIR|TEMP_DIR|mktemp)' "$1" 2>/dev/null
}

while IFS= read -r file; do
    if sandboxes_home "${file}"; then
        pattern="${prefix}(${destructive})${suffix}(${system_paths})"
    else
        pattern="${prefix}(${destructive})${suffix}(${system_paths}|${home_paths})"
    fi

    # Match against the raw file so '^' sees the real start of line, then drop
    # hits whose content is a full-line comment (prose describing the old bug
    # must not trip the guard). Order matters: piping `grep -n` output into the
    # pattern grep would prefix every line with "NNN:" and silently break the
    # anchor — that mistake made an earlier version of this script report
    # all-clear on the very file that caused the incident.
    matches=$(grep -nE "${pattern}" "${file}" 2>/dev/null \
        | grep -vE '^[0-9]+:[[:space:]]*#' 2>/dev/null) || true

    if [[ -n "${matches}" ]]; then
        echo "" >&2
        echo "✗ ${file}" >&2
        while IFS= read -r line; do
            echo "    ${line}" >&2
            violations=$((violations + 1))
        done <<< "${matches}"
    fi
done < <(find tests -type f \( -name '*.bats' -o -name '*.sh' \) 2>/dev/null | sort)

if [[ "${violations}" -gt 0 ]]; then
    cat >&2 <<'EOF'

Tests must not create, delete, or overwrite anything outside their temp dir.
Fix by either:

  1. Using a fixture path:
       export NIX_INSTALL_BREW_PATH="${TEST_TMP_DIR}/homebrew/bin/brew"

  2. Adding an override seam to the production code when it hardcodes a system
     path, so the test can redirect it (see lib/nix-darwin.sh).

  3. Sandboxing HOME in setup(), if the finding is $HOME-based:
       export HOME="${BATS_TEST_TMPDIR}/home"

Do NOT silence this by deleting the check — it is the only thing standing
between a stray suite run and someone's working machine.
EOF
    echo "✗ ${violations} test line(s) mutate real host paths." >&2
    exit 1
fi

echo "✓ No test mutates real host paths"
