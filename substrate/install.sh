#!/bin/sh
# Cogentry Substrate Installer
#
# Usage:
#   curl -fsSL https://github.com/cogn3/releases/raw/main/substrate/install.sh | sh
#
# Options:
#   --version <ver>   Install specific version (e.g., v0.2.0). Default: latest
#   --local <path>    Install skills from local codebase instead of downloading
#   --skill-only      Only install skills (skip binary)
#
# Installs the `cs` binary to /usr/local/bin and (if OpenCode is detected)
# the cogentry-substrate skill to ~/.config/opencode/skills/cogentry-substrate/.

set -eu

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

RELEASES_REPO="cogn3/releases"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="cs"
SKILL_NAME="cogentry-substrate"
SKILL_DIR="${HOME}/.config/opencode/skills/${SKILL_NAME}"
OPENCODE_DIR="${HOME}/.config/opencode"

RELEASES_BASE_URL="https://github.com/${RELEASES_REPO}/releases"
LATEST_BASE_URL="${RELEASES_BASE_URL}/latest/download"
SKILL_FILES="SKILL.md commands.md workflows.md search.md specs.md domains.md"

# Command-line options
LOCAL_PATH=""
SKILL_ONLY=false
VERSION=""

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

info() {
    printf '==> %s\n' "$1"
}

warn() {
    printf 'WARN: %s\n' "$1" >&2
}

error() {
    printf 'ERROR: %s\n' "$1" >&2
    exit 1
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --version|-v)
                VERSION="$2"
                shift 2
                ;;
            --local)
                LOCAL_PATH="$2"
                shift 2
                ;;
            --skill-only)
                SKILL_ONLY=true
                shift
                ;;
            -h|--help)
                echo "Usage: install.sh [--version <ver>] [--local <path>] [--skill-only]"
                echo ""
                echo "Options:"
                echo "  --version <ver>   Install specific version (e.g., v0.2.0). Default: latest"
                echo "  --local <path>    Install skills from local codebase"
                echo "  --skill-only      Only install skills (skip binary)"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
}

# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------

detect_platform() {
    os="$(uname -s)"
    arch="$(uname -m)"

    case "${os}" in
        Darwin) os_part="darwin" ;;
        Linux)  os_part="linux" ;;
        *)
            error "Unsupported operating system: ${os}. Supported: macOS, Linux."
            ;;
    esac

    case "${arch}" in
        arm64|aarch64) arch_part="arm64" ;;
        x86_64|amd64)  arch_part="x64" ;;
        *)
            error "Unsupported architecture: ${arch}. Supported: arm64, x86_64."
            ;;
    esac

    echo "${os_part}-${arch_part}"
}

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------

check_prerequisites() {
    if ! command -v curl >/dev/null 2>&1; then
        error "curl is required but not installed."
    fi
    if ! command -v unzip >/dev/null 2>&1; then
        error "unzip is required but not installed."
    fi
}

# ---------------------------------------------------------------------------
# Binary install
# ---------------------------------------------------------------------------

install_binary() {
    platform="$1"
    binary_filename="cs-${platform}"
    zip_filename="${binary_filename}.zip"
    
    # Determine download URL based on version
    if [ -n "${VERSION}" ]; then
        download_url="${RELEASES_BASE_URL}/download/${VERSION}/${zip_filename}"
        info "Installing version: ${VERSION}"
    else
        download_url="${LATEST_BASE_URL}/${zip_filename}"
        info "Installing latest version"
    fi
    
    target_path="${INSTALL_DIR}/${BINARY_NAME}"

    info "Detected platform: ${platform}"
    info "Downloading ${zip_filename}..."

    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "${tmp_dir}"' EXIT
    tmp_zip="${tmp_dir}/${zip_filename}"
    tmp_binary="${tmp_dir}/${binary_filename}"

    if ! curl -fsSL -o "${tmp_zip}" "${download_url}"; then
        error "Failed to download ${download_url}.

This usually means there is no published binary for your platform/version.
Currently supported: darwin-arm64. See ${RELEASES_BASE_URL}"
    fi
    
    info "Extracting ${zip_filename}..."
    if ! unzip -o -q "${tmp_zip}" -d "${tmp_dir}"; then
        error "Failed to extract ${zip_filename}."
    fi
    
    # Rename to standard binary name
    mv "${tmp_binary}" "${tmp_dir}/${BINARY_NAME}"
    tmp_binary="${tmp_dir}/${BINARY_NAME}"

    chmod +x "${tmp_binary}"

    info "Installing to ${target_path}..."

    if [ -w "${INSTALL_DIR}" ]; then
        mv "${tmp_binary}" "${target_path}"
    else
        info "Elevation required to write to ${INSTALL_DIR}."
        if ! sudo mv "${tmp_binary}" "${target_path}"; then
            error "Failed to install binary to ${target_path}."
        fi
    fi

    info "Installed: ${target_path}"
}

# ---------------------------------------------------------------------------
# OpenCode skill install
# ---------------------------------------------------------------------------

install_skill() {
    if [ ! -d "${OPENCODE_DIR}" ]; then
        info "OpenCode not detected at ${OPENCODE_DIR}; skipping skill install."
        return 0
    fi

    info "OpenCode detected; installing ${SKILL_NAME} skill..."

    mkdir -p "${SKILL_DIR}"

    if [ -n "${LOCAL_PATH}" ]; then
        # Local mode: copy from local codebase
        local_skills="${LOCAL_PATH}/skills"
        if [ ! -d "${local_skills}" ]; then
            error "Local skills directory not found: ${local_skills}"
        fi
        
        for skill_file in ${SKILL_FILES}; do
            src="${local_skills}/${skill_file}"
            if [ -f "${src}" ]; then
                cp "${src}" "${SKILL_DIR}/${skill_file}"
                info "Installed (local): ${SKILL_DIR}/${skill_file}"
            else
                warn "Local file not found: ${src}; skipping."
            fi
        done
    else
        # Remote mode: download from version-specific skills folder
        if [ -n "${VERSION}" ]; then
            skill_base_url="https://github.com/${RELEASES_REPO}/raw/main/substrate/${VERSION}/skills"
        else
            # For latest, we need to determine the latest version first
            # Fall back to using the latest tag's skills
            skill_base_url="https://github.com/${RELEASES_REPO}/raw/main/substrate/skills"
            # Try to get latest version tag
            latest_version="$(curl -fsSL -o /dev/null -w '%{url_effective}' "${RELEASES_BASE_URL}/latest" 2>/dev/null | sed 's|.*/||')"
            if [ -n "${latest_version}" ] && [ "${latest_version}" != "latest" ]; then
                skill_base_url="https://github.com/${RELEASES_REPO}/raw/main/substrate/${latest_version}/skills"
            fi
        fi
        
        for skill_file in ${SKILL_FILES}; do
            skill_url="${skill_base_url}/${skill_file}"
            if ! curl -fsSL -o "${SKILL_DIR}/${skill_file}" "${skill_url}"; then
                warn "Failed to download ${skill_file} from ${skill_url}; skipping."
            else
                info "Installed: ${SKILL_DIR}/${skill_file}"
            fi
        done
    fi
}

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

verify_install() {
    target_path="${INSTALL_DIR}/${BINARY_NAME}"

    # Always verify the binary we just installed, not whatever 'cs' resolves to on PATH.
    if [ -x "${target_path}" ]; then
        version="$("${target_path}" --version 2>/dev/null || echo unknown)"
        info "Installed cs version: ${version}"
    else
        warn "Binary not found at ${target_path} after install."
        return 0
    fi

    # Warn if the user's PATH would resolve 'cs' to something else.
    if command -v "${BINARY_NAME}" >/dev/null 2>&1; then
        resolved="$(command -v "${BINARY_NAME}")"
        if [ "${resolved}" != "${target_path}" ]; then
            warn "Another '${BINARY_NAME}' is earlier on PATH: ${resolved}"
            warn "It will be used instead of ${target_path}."
            warn "Remove it (e.g. 'npm unlink -g cogentry-substrate') or reorder PATH."
        fi
    else
        warn "${INSTALL_DIR} is not on PATH; add it to use '${BINARY_NAME}' globally."
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    parse_args "$@"
    
    info "Cogentry Substrate Installer"

    if [ "${SKILL_ONLY}" = false ]; then
        check_prerequisites
        platform="$(detect_platform)"
        install_binary "${platform}"
    fi
    
    install_skill
    
    if [ "${SKILL_ONLY}" = false ]; then
        verify_install
    fi

    info "Done. Run 'cs --help' to get started."
}

main "$@"
