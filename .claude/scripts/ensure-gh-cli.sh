#!/bin/bash
# Automated GitHub CLI setup for Claude Code sessions
# This script runs on SessionStart to ensure gh CLI is available and authenticated

set -e

# Add common binary locations to PATH
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# Check if gh is already installed
if command -v gh &> /dev/null; then
    echo "[gh] CLI found at $(which gh)"
else
    echo "[gh] CLI not found, installing..."

    # Detect platform
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    [ "$ARCH" = "x86_64" ] && ARCH="amd64"
    [ "$ARCH" = "aarch64" ] && ARCH="arm64"

    echo "[gh] Detected platform: ${OS}_${ARCH}"

    # Pinned version (supply-chain cool-off: never auto-fetch "latest"). Bump
    # deliberately to a release that is at least 14 days old.
    GH_VERSION="2.92.0"

    echo "[gh] Version: ${GH_VERSION}"

    # Build archive name based on platform
    if [ "$OS" = "darwin" ]; then
        ARCHIVE_NAME="gh_${GH_VERSION}_macOS_${ARCH}.zip"
        EXTRACT_DIR="/tmp/gh_${GH_VERSION}_macOS_${ARCH}"
    else
        ARCHIVE_NAME="gh_${GH_VERSION}_${OS}_${ARCH}.tar.gz"
        EXTRACT_DIR="/tmp/gh_${GH_VERSION}_${OS}_${ARCH}"
    fi
    BASE_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}"

    echo "[gh] Downloading ${ARCHIVE_NAME}..."
    curl -fsSL -o "/tmp/${ARCHIVE_NAME}" "${BASE_URL}/${ARCHIVE_NAME}"

    # Verify the download against the release's published checksums before using it.
    echo "[gh] Verifying checksum..."
    curl -fsSL -o /tmp/gh_checksums.txt "${BASE_URL}/gh_${GH_VERSION}_checksums.txt"
    expected=$(grep " ${ARCHIVE_NAME}\$" /tmp/gh_checksums.txt | awk '{print $1}')
    if command -v sha256sum &> /dev/null; then
        actual=$(sha256sum "/tmp/${ARCHIVE_NAME}" | awk '{print $1}')
    else
        actual=$(shasum -a 256 "/tmp/${ARCHIVE_NAME}" | awk '{print $1}')
    fi
    if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
        echo "[gh] ERROR: checksum verification failed for ${ARCHIVE_NAME}"
        echo "[gh]   expected: ${expected:-<not found>}"
        echo "[gh]   actual:   ${actual}"
        rm -f "/tmp/${ARCHIVE_NAME}" /tmp/gh_checksums.txt
        exit 1
    fi
    echo "[gh] Checksum OK"

    # Extract
    case "$ARCHIVE_NAME" in
        *.zip) unzip -q "/tmp/${ARCHIVE_NAME}" -d /tmp ;;
        *)     tar -xzf "/tmp/${ARCHIVE_NAME}" -C /tmp ;;
    esac

    # Install to ~/.local/bin (works in cloud and local)
    mkdir -p ~/.local/bin
    cp "${EXTRACT_DIR}/bin/gh" ~/.local/bin/gh
    chmod +x ~/.local/bin/gh

    # Clean up
    rm -rf "${EXTRACT_DIR}" "/tmp/${ARCHIVE_NAME}" /tmp/gh_checksums.txt

    echo "[gh] Installed to ~/.local/bin/gh"
fi

# Verify gh is now in PATH
if ! command -v gh &> /dev/null; then
    echo "[gh] ERROR: gh CLI still not found in PATH after installation"
    echo "[gh] Ensure ~/.local/bin is in your PATH"
    exit 1
fi

# Check authentication status
if [ -n "$GH_TOKEN" ]; then
    # GH_TOKEN is set, verify it works
    if gh auth status &> /dev/null; then
        echo "[gh] Authenticated successfully"
    else
        echo "[gh] WARNING: GH_TOKEN is set but authentication check failed"
        echo "[gh] Token may be invalid or expired"
    fi
else
    echo "[gh] NOTE: GH_TOKEN not set - some operations may require authentication"
    echo "[gh] See: docs/general/agent-setup/github-cli-setup.md"
fi

exit 0
