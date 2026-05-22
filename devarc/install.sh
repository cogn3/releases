#!/usr/bin/env bash
#
# install.sh — Install DevArc into ~/.config/opencode
#
# Pulls a devarc release zip from cogn3/releases and extracts:
#   - commands/   → ~/.config/opencode/command/
#   - scripts/    → ~/.config/opencode/scripts/
#   - skills/     → ~/.config/opencode/skill/
#   - templates/  → ~/.config/opencode/templates/
#
# Usage:
#   ./install.sh                    # Install latest version
#   ./install.sh <version>          # Install specific version
#   curl -fsSL https://github.com/cogn3/releases/raw/main/devarc/install.sh | bash
#   curl -fsSL https://github.com/cogn3/releases/raw/main/devarc/install.sh | bash -s -- <version>

set -euo pipefail

# ─── Config ─────────────────────────────────────────────────────────────────
RELEASE_REPO="cogn3/releases"
RELEASE_BASE_URL="https://raw.githubusercontent.com/${RELEASE_REPO}/main/devarc"
GITHUB_API_URL="https://api.github.com/repos/${RELEASE_REPO}/contents/devarc"

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.config/opencode}"
TMP_DIR="$(mktemp -d -t devarc-install.XXXXXX)"
VERSION="${1:-latest}"

# ─── Helpers ────────────────────────────────────────────────────────────────
log()  { printf "\033[1;34m[install]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2; exit 1; }

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# ─── Check dependencies ─────────────────────────────────────────────────────
command -v curl >/dev/null || err "curl is required but not installed"
command -v unzip >/dev/null || err "unzip is required but not installed"

# ─── Resolve version ────────────────────────────────────────────────────────
if [[ "$VERSION" == "latest" ]]; then
  log "Resolving latest version from $RELEASE_REPO..."
  if command -v jq >/dev/null 2>&1; then
    VERSION=$(curl -fsSL "$GITHUB_API_URL" \
      | jq -r '.[] | select(.type=="dir") | .name' \
      | sort -V | tail -n1)
  else
    # Fallback: parse JSON without jq
    VERSION=$(curl -fsSL "$GITHUB_API_URL" \
      | grep -E '"name"' \
      | grep -oE '"[^"]+"' \
      | sed -n '2~2p' \
      | tr -d '"' \
      | sort -V | tail -n1)
  fi
  [[ -n "$VERSION" ]] || err "Could not resolve latest version"
  log "Latest version: $VERSION"
fi

ZIP_NAME="devarc-${VERSION}.zip"
ZIP_URL="${RELEASE_BASE_URL}/${VERSION}/${ZIP_NAME}"

# ─── Download zip ───────────────────────────────────────────────────────────
log "Downloading $ZIP_NAME..."
log "  from: $ZIP_URL"
ZIP_PATH="$TMP_DIR/$ZIP_NAME"

if ! curl -fsSL -o "$ZIP_PATH" "$ZIP_URL"; then
  err "Failed to download $ZIP_URL"
fi

ZIP_SIZE=$(du -h "$ZIP_PATH" | cut -f1)
log "Downloaded ($ZIP_SIZE)"

# ─── Extract ────────────────────────────────────────────────────────────────
log "Extracting to $TMP_DIR..."
unzip -q "$ZIP_PATH" -d "$TMP_DIR/extracted"

for dir in commands scripts skills templates; do
  [[ -d "$TMP_DIR/extracted/$dir" ]] || err "Missing directory in zip: $dir"
done

# ─── Install to ~/.config/opencode ──────────────────────────────────────────
log "Installing to $OPENCODE_DIR..."
mkdir -p "$OPENCODE_DIR"

# OpenCode uses singular forms for command/skill directories
declare -A DIR_MAP=(
  [commands]=command
  [scripts]=scripts
  [skills]=skill
  [templates]=templates
)

for src in commands scripts skills templates; do
  dest="${DIR_MAP[$src]}"
  target="$OPENCODE_DIR/$dest"

  if [[ -d "$target" ]]; then
    log "  $src → $dest/ (merging)"
  else
    log "  $src → $dest/ (creating)"
    mkdir -p "$target"
  fi

  cp -R "$TMP_DIR/extracted/$src/." "$target/"
done

# ─── Done ───────────────────────────────────────────────────────────────────
log "✓ DevArc $VERSION installed to $OPENCODE_DIR"
log ""
log "Available commands:"
for cmd in "$OPENCODE_DIR/command"/arc-*.md; do
  [[ -f "$cmd" ]] || continue
  name=$(basename "$cmd" .md)
  log "  /$name"
done
log ""
log "Run /arc-define to start a new change."
