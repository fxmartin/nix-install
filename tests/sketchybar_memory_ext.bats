#!/usr/bin/env bats
# ABOUTME: Tests SketchyBar memory bar rendering thresholds
# ABOUTME: Verifies the bar tracks mactop-style used memory

setup() {
    TEST_TMP_DIR="$(mktemp -d)"
    export TEST_TMP_DIR
    export SKETCHYBAR_CALLS="${TEST_TMP_DIR}/sketchybar.calls"
    mkdir -p "${TEST_TMP_DIR}/bin"

    cat > "${TEST_TMP_DIR}/bin/sketchybar" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${SKETCHYBAR_CALLS}"
SCRIPT
    chmod +x "${TEST_TMP_DIR}/bin/sketchybar"
    export PATH="${TEST_TMP_DIR}/bin:${PATH}"
}

teardown() {
    rm -rf "${TEST_TMP_DIR}"
}

@test "memory_ext renders four full bars for 33.8GB used on 48GB total" {
    NAME=memory.ext \
    STALE=0 \
    MEM_USED=33.8 \
    MEM_TOTAL=48.0 \
    MEM_ACTIVE=17.9 \
    MEM_INACTIVE=10.0 \
    SWAP_USED=0.0 \
    MEM_PRESSURE=normal \
    run "${BATS_TEST_DIRNAME}/../config/sketchybar/plugins/memory_ext.sh"

    [ "$status" -eq 0 ]
    grep -q "label=▰▰▰▰▱ 70% U33.8G A17.9G I10.0G S0.0G" "${SKETCHYBAR_CALLS}"
}

@test "memory_ext renders five full bars at 80 percent used memory" {
    NAME=memory.ext \
    STALE=0 \
    MEM_USED=38.4 \
    MEM_TOTAL=48.0 \
    MEM_ACTIVE=38.4 \
    MEM_INACTIVE=4.0 \
    SWAP_USED=0.0 \
    MEM_PRESSURE=normal \
    run "${BATS_TEST_DIRNAME}/../config/sketchybar/plugins/memory_ext.sh"

    [ "$status" -eq 0 ]
    grep -q "label=▰▰▰▰▰ 80% U38.4G A38.4G I4.0G S0.0G" "${SKETCHYBAR_CALLS}"
}

@test "memory_ext short item shows used percent and used GB" {
    NAME=memory.short \
    STALE=0 \
    MEM_USED=24.0 \
    MEM_TOTAL=48.0 \
    MEM_ACTIVE='' \
    MEM_INACTIVE=0.0 \
    SWAP_USED=0.0 \
    MEM_PRESSURE=normal \
    run "${BATS_TEST_DIRNAME}/../config/sketchybar/plugins/memory_ext.sh"

    [ "$status" -eq 0 ]
    grep -q "label=▰▰▰▱▱ 50% U24.0G S0.0G" "${SKETCHYBAR_CALLS}"
}
