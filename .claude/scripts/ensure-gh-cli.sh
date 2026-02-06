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

    # Get latest version from GitHub API (with fallback)
    GH_VERSION=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest 2>/dev/null \
        | grep -o '"tag_name": *"v[^"]*"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')

    # Fallback version if API fails
    GH_VERSION=${GH_VERSION:-2.83.1}

    echo "[gh] Version: ${GH_VERSION}"

    # Build download URL based on platform
    if [ "$OS" = "darwin" ]; then
        DOWNLOAD_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_macOS_${ARCH}.zip"
        ARCHIVE_EXT="zip"
    else
        DOWNLOAD_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_${OS}_${ARCH}.tar.gz"
        ARCHIVE_EXT="tar.gz"
    fi

    echo "[gh] Downloading from ${DOWNLOAD_URL}..."

    # Download
    curl -fsSL -o "/tmp/gh.${ARCHIVE_EXT}" "$DOWNLOAD_URL"

    # Extract based on archive type
    if [ "$ARCHIVE_EXT" = "zip" ]; then
        unzip -q "/tmp/gh.zip" -d /tmp
        EXTRACT_DIR="/tmp/gh_${GH_VERSION}_macOS_${ARCH}"
    else
        tar -xzf "/tmp/gh.tar.gz" -C /tmp
        EXTRACT_DIR="/tmp/gh_${GH_VERSION}_${OS}_${ARCH}"
    fi

    # Install to ~/.local/bin (works in cloud and local)
    mkdir -p ~/.local/bin
    cp "${EXTRACT_DIR}/bin/gh" ~/.local/bin/gh
    chmod +x ~/.local/bin/gh

    # Clean up
    rm -rf "${EXTRACT_DIR}" "/tmp/gh.${ARCHIVE_EXT}"

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
