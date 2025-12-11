#!/usr/bin/env bash
# ABOUTME: Build script to concatenate modular lib/*.sh files into single bootstrap-dist.sh
# ABOUTME: Creates standalone bootstrap installer from modular source files
# ABOUTME: Usage: ./scripts/build-bootstrap.sh

set -euo pipefail

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Output file
OUTPUT_FILE="${PROJECT_ROOT}/bootstrap-dist.sh"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Validate all library files exist
validate_lib_files() {
    log_info "Validating library files..."

    local lib_files=(
        "lib/common.sh"
        "lib/preflight.sh"
        "lib/user-config.sh"
        "lib/xcode.sh"
        "lib/nix-install.sh"
        "lib/nix-darwin.sh"
        "lib/ssh-github.sh"
        "lib/repo-clone.sh"
        "lib/darwin-rebuild.sh"
        "lib/summary.sh"
    )

    local all_exist=true
    for file in "${lib_files[@]}"; do
        if [[ ! -f "${PROJECT_ROOT}/${file}" ]]; then
            log_error "Missing library file: ${file}"
            all_exist=false
        else
            log_info "  ✓ ${file}"
        fi
    done

    if [[ "${all_exist}" == "false" ]]; then
        log_error "One or more library files are missing"
        return 1
    fi

    log_success "All library files validated"
    return 0
}

# Extract main() function from bootstrap.sh (modular version)
extract_main_function() {
    log_info "Extracting main() function from bootstrap.sh..."

    if [[ ! -f "${PROJECT_ROOT}/bootstrap.sh" ]]; then
        log_error "bootstrap.sh not found"
        return 1
    fi

    # Extract main() function from the modular bootstrap.sh
    # Find the line where main() starts and extract to end
    local main_start
    main_start=$(grep -n "^main()" "${PROJECT_ROOT}/bootstrap.sh" | cut -d: -f1)

    if [[ -z "${main_start}" ]]; then
        log_error "Could not find main() function in bootstrap.sh"
        return 1
    fi

    # Extract from main() to end of file
    sed -n "${main_start},\$p" "${PROJECT_ROOT}/bootstrap.sh" > /tmp/main-function.txt

    if [[ ! -s /tmp/main-function.txt ]]; then
        log_error "Failed to extract main() function"
        return 1
    fi

    log_success "main() function extracted"
    return 0
}

# Build bootstrap-dist.sh by concatenating all modules
build_bootstrap_dist() {
    log_info "Building bootstrap-dist.sh..."

    # Create header with shebang and documentation
    cat > "${OUTPUT_FILE}" << 'HEADER_EOF'
#!/usr/bin/env bash
# ABOUTME: Stage 2 bootstrap installer - interactive macOS configuration with Nix-Darwin
# ABOUTME: Built from modular lib/*.sh files by scripts/build-bootstrap.sh
# ABOUTME: This is a GENERATED FILE - Do not edit directly, edit lib/*.sh instead

# ==============================================================================
# TWO-STAGE BOOTSTRAP PATTERN - STAGE 2: INTERACTIVE INSTALLER
# ==============================================================================
#
# This script is STAGE 2 of the two-stage bootstrap pattern:
#
# STAGE 1 (setup.sh):
#   - Curl-pipeable wrapper with NO interactive prompts
#   - Downloads this script to /tmp
#   - Executes this script locally (NOT piped)
#
# STAGE 2 (THIS FILE - bootstrap-dist.sh):
#   - Full interactive installer with user prompts
#   - Runs with proper stdin connected to terminal
#   - Uses standard "read -r" commands (works because NOT piped)
#   - Performs actual Nix-Darwin installation
#
# WHY THIS WORKS:
#   When setup.sh downloads this script and executes it with "bash bootstrap-dist.sh",
#   stdin is properly connected to the terminal, allowing interactive prompts
#   to read user input. No /dev/tty redirects or workarounds needed.
#
# INSTALLATION METHODS:
#   1. Recommended (via setup.sh wrapper):
#      curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/setup.sh | bash
#
#   2. Direct execution (advanced users):
#      curl -fsSL https://raw.githubusercontent.com/fxmartin/nix-install/main/bootstrap-dist.sh -o bootstrap-dist.sh
#      chmod +x bootstrap-dist.sh
#      ./bootstrap-dist.sh
#
# ==============================================================================

set -euo pipefail  # Strict error handling

HEADER_EOF

    # Append each library file in dependency order
    # Remove shebang, set -euo pipefail, and double-sourcing guards from modules
    # (main script already has these)

    log_info "Concatenating library modules..."

    local lib_files=(
        "lib/common.sh"
        "lib/preflight.sh"
        "lib/user-config.sh"
        "lib/xcode.sh"
        "lib/nix-install.sh"
        "lib/nix-darwin.sh"
        "lib/ssh-github.sh"
        "lib/repo-clone.sh"
        "lib/darwin-rebuild.sh"
        "lib/summary.sh"
    )

    for lib_file in "${lib_files[@]}"; do
        log_info "  Adding ${lib_file}..."

        echo "" >> "${OUTPUT_FILE}"
        echo "# ==============================================================================" >> "${OUTPUT_FILE}"
        echo "# MODULE: ${lib_file}" >> "${OUTPUT_FILE}"
        echo "# ==============================================================================" >> "${OUTPUT_FILE}"
        echo "" >> "${OUTPUT_FILE}"

        # Append module content, skipping:
        # - ABOUTME comments (already in header)
        # - Double-sourcing guards (not needed in monolithic file)
        # - Empty lines at start
        grep -v "^# ABOUTME:" "${PROJECT_ROOT}/${lib_file}" | \
        grep -v "^\[\[ -n \"\${_.*_LOADED:-}\" \]\]" | \
        grep -v "^readonly _.*_LOADED=1" | \
        sed '/./,$!d' >> "${OUTPUT_FILE}"
    done

    # Append main() function
    log_info "Adding main() function..."
    echo "" >> "${OUTPUT_FILE}"
    echo "# ==============================================================================" >> "${OUTPUT_FILE}"
    echo "# MAIN ORCHESTRATOR" >> "${OUTPUT_FILE}"
    echo "# ==============================================================================" >> "${OUTPUT_FILE}"
    echo "" >> "${OUTPUT_FILE}"
    cat /tmp/main-function.txt >> "${OUTPUT_FILE}"

    # Make executable
    chmod +x "${OUTPUT_FILE}"

    log_success "bootstrap-dist.sh built successfully"
    return 0
}

# Validate generated file with bash -n
validate_syntax() {
    log_info "Validating bash syntax with bash -n..."

    if bash -n "${OUTPUT_FILE}"; then
        log_success "✓ Syntax validation passed"
        return 0
    else
        log_error "✗ Syntax validation failed"
        return 1
    fi
}

# Display build summary
display_summary() {
    local dist_lines
    dist_lines=$(wc -l < "${OUTPUT_FILE}")

    echo ""
    log_success "================================================"
    log_success "Build Complete!"
    log_success "================================================"
    log_info "Output file: ${OUTPUT_FILE}"
    log_info "Total lines: ${dist_lines}"
    log_info "Modules concatenated: 10 library files + main()"
    echo ""
    log_info "To use the built installer:"
    log_info "  ./bootstrap-dist.sh"
    echo ""
}

# Main build process
main() {
    log_info "================================================"
    log_info "Bootstrap Build Script"
    log_info "================================================"
    log_info "Project root: ${PROJECT_ROOT}"
    log_info "Output file: ${OUTPUT_FILE}"
    echo ""

    # Run build steps
    validate_lib_files || exit 1
    extract_main_function || exit 1
    build_bootstrap_dist || exit 1
    validate_syntax || exit 1
    display_summary

    return 0
}

# Run main
main "$@"
