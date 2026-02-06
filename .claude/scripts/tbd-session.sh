#!/bin/bash
# Ensure tbd CLI is installed and run tbd prime for Claude Code sessions
# Installed by: tbd setup --auto
# This script runs on SessionStart and PreCompact

# Get npm global bin directory (if npm is available)
NPM_GLOBAL_BIN=""
if command -v npm &> /dev/null; then
    NPM_PREFIX=$(npm config get prefix 2>/dev/null)
    if [ -n "$NPM_PREFIX" ] && [ -d "$NPM_PREFIX/bin" ]; then
        NPM_GLOBAL_BIN="$NPM_PREFIX/bin"
    fi
fi

# Add common binary locations to PATH (persists for entire script)
# Include npm global bin if found
export PATH="$NPM_GLOBAL_BIN:$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# Function to ensure tbd is available
ensure_tbd() {
    # Check if tbd is already installed
    if command -v tbd &> /dev/null; then
        return 0
    fi

    echo "[tbd] CLI not found, installing..."

    # Try npm first (most common for Node.js tools)
    if command -v npm &> /dev/null; then
        echo "[tbd] Installing via npm..."
        npm install -g get-tbd 2>/dev/null || {
            # If global install fails (permissions), try local install
            echo "[tbd] Global npm install failed, trying user install..."
            mkdir -p ~/.local/bin
            npm install --prefix ~/.local get-tbd
            # Create symlink if needed
            if [ -f ~/.local/node_modules/.bin/tbd ]; then
                ln -sf ~/.local/node_modules/.bin/tbd ~/.local/bin/tbd
            fi
        }
    elif command -v pnpm &> /dev/null; then
        echo "[tbd] Installing via pnpm..."
        pnpm add -g get-tbd
    elif command -v yarn &> /dev/null; then
        echo "[tbd] Installing via yarn..."
        yarn global add get-tbd
    else
        echo "[tbd] ERROR: No package manager found (npm, pnpm, or yarn required)"
        echo "[tbd] Please install Node.js and npm, then run: npm install -g get-tbd"
        return 1
    fi

    # Verify installation
    if command -v tbd &> /dev/null; then
        echo "[tbd] Successfully installed to $(which tbd)"
        return 0
    else
        echo "[tbd] WARNING: tbd installed but not found in PATH"
        echo "[tbd] Checking common locations..."
        # Try to find and add to path (include npm global bin)
        for dir in "$NPM_GLOBAL_BIN" ~/.local/bin ~/.local/node_modules/.bin /usr/local/bin; do
            if [ -n "$dir" ] && [ -x "$dir/tbd" ]; then
                export PATH="$dir:$PATH"
                echo "[tbd] Found at $dir/tbd"
                return 0
            fi
        done
        echo "[tbd] Could not locate tbd after installation"
        return 1
    fi
}

# Main
ensure_tbd || exit 1

# Run tbd prime with any passed arguments (e.g., --brief for PreCompact)
tbd prime "$@"
