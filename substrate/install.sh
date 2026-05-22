#!/bin/sh
# Cogentry Substrate Installer
#
# Usage:
#   curl -fsSL https://github.com/cogn3/releases/raw/main/substrate/install.sh | sh
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

LATEST_BASE_URL="https://github.com/${RELEASES_REPO}/releases/latest/download"
SKILL_URL="https://github.com/${RELEASES_REPO}/raw/main/substrate/SKILLS.md"

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
}

# ---------------------------------------------------------------------------
# Binary install
# ---------------------------------------------------------------------------

install_binary() {
    platform="$1"
    binary_filename="cs-${platform}"
    binary_url="${LATEST_BASE_URL}/${binary_filename}"
    target_path="${INSTALL_DIR}/${BINARY_NAME}"

    info "Detected platform: ${platform}"
    info "Downloading ${binary_filename} from latest release..."

    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "${tmp_dir}"' EXIT
    tmp_binary="${tmp_dir}/${BINARY_NAME}"

    if ! curl -fsSL -o "${tmp_binary}" "${binary_url}"; then
        error "Failed to download ${binary_url}.

This usually means there is no published binary for your platform yet.
Currently supported: darwin-arm64. See https://github.com/${RELEASES_REPO}/releases"
    fi

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

    if ! curl -fsSL -o "${SKILL_DIR}/SKILL.md" "${SKILL_URL}"; then
        warn "Failed to download skill from ${SKILL_URL}; skipping."
        return 0
    fi

    info "Installed skill: ${SKILL_DIR}/SKILL.md"
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
    info "Cogentry Substrate Installer"

    check_prerequisites

    platform="$(detect_platform)"

    install_binary "${platform}"
    install_skill
    verify_install

    info "Done. Run 'cs --help' to get started."
}

main "$@"
