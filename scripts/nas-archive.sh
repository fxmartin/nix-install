#!/usr/bin/env bash
# ABOUTME: Bundles a NAS directory into a checksummed tar.zst archive for the B2 archive pipeline
# ABOUTME: Story 11.1-002 - staging free-space guard and no-overwrite guard; upload lands in 11.1-003

set -euo pipefail

NAS_ARCHIVE_VERSION="1.0.0"

# Staging directory can be overridden for testing; defaults to the NAS path
# from the story's acceptance criteria.
STAGING_DIR="${NAS_ARCHIVE_STAGING_DIR:-/Volume1/Data/Archives/_staging}"

usage() {
    cat <<'EOF'
Usage: nas-archive.sh bundle <source-dir> <archive-name>

Bundles <source-dir> into a checksummed tar.zst archive under the staging
directory (default /Volume1/Data/Archives/_staging, override with
NAS_ARCHIVE_STAGING_DIR).

Produces in the staging directory:
  <archive-name>.tar.zst           the compressed bundle
  <archive-name>.sha256            sha256sum manifest of the bundle
  <archive-name>.filelist.txt.zst  compressed listing of bundled files

Refuses to run if staging free space is less than the source size, and
refuses to overwrite an existing bundle with the same name.
EOF
}

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

die() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

# Restrict archive names to a safe filename character set so they cannot
# escape the staging directory or collide with tar/zstd option parsing.
validate_archive_name() {
    local name="$1"
    [[ "${name}" =~ ^[A-Za-z0-9._-]+$ ]] \
        || die "archive name must contain only letters, numbers, dots, dashes, underscores: ${name}"
}

cmd_bundle() {
    local source_dir="${1:-}"
    local archive_name="${2:-}"

    if [[ -z "${source_dir}" || -z "${archive_name}" ]]; then
        usage >&2
        exit 1
    fi

    [[ -d "${source_dir}" ]] || die "source directory does not exist: ${source_dir}"
    validate_archive_name "${archive_name}"

    mkdir -p "${STAGING_DIR}"

    local archive_path="${STAGING_DIR}/${archive_name}.tar.zst"
    local sha_path="${STAGING_DIR}/${archive_name}.sha256"
    local filelist_path="${STAGING_DIR}/${archive_name}.filelist.txt.zst"

    if [[ -e "${archive_path}" ]]; then
        die "bundle already exists, refusing to overwrite: ${archive_path}"
    fi

    log "Computing source size for ${source_dir}"
    local source_size_kb
    source_size_kb=$(du -sk "${source_dir}" | awk '{print $1}')
    [[ -n "${source_size_kb}" ]] || die "could not determine source size for ${source_dir}"

    log "Checking staging free space in ${STAGING_DIR}"
    local free_kb
    free_kb=$(df -k "${STAGING_DIR}" | awk 'NR==2 {print $4}')
    [[ -n "${free_kb}" ]] || die "could not determine free space for ${STAGING_DIR}"

    if (( free_kb < source_size_kb )); then
        die "insufficient staging free space: need ${source_size_kb}KB, have ${free_kb}KB in ${STAGING_DIR}"
    fi

    log "Bundling ${source_dir} -> ${archive_path}"
    tar -I 'zstd -T0 -10' -cf "${archive_path}" -C "${source_dir}" .
    log "Bundle created: ${archive_path}"

    log "Writing checksum manifest"
    (cd "${STAGING_DIR}" && sha256sum "${archive_name}.tar.zst" > "${archive_name}.sha256")

    log "Writing compressed file listing"
    tar -I 'zstd -T0 -10' -tf "${archive_path}" | zstd -q -T0 -o "${filelist_path}"

    log "Bundle complete:"
    log "  archive:  ${archive_path}"
    log "  checksum: ${sha_path}"
    log "  filelist: ${filelist_path}"
}

main() {
    local subcommand="${1:-}"

    case "${subcommand}" in
        bundle)
            shift
            cmd_bundle "$@"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        "")
            usage >&2
            exit 1
            ;;
        *)
            printf 'Error: unknown subcommand: %s\n' "${subcommand}" >&2
            usage >&2
            exit 1
            ;;
    esac
}

main "$@"
