#!/bin/bash
set -e

#############################################
# Configuration
#############################################

MC_DR_DIR="/data"
VENV_DIR="$MC_DR_DIR/venv"
PLUGINS_DIR="$MC_DR_DIR/plugins"

#############################################
# Ensure working directory exists
#############################################

mkdir -p "$MC_DR_DIR"
cd "$MC_DR_DIR"

#############################################
# Create virtual environment if missing
#############################################

if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

#############################################
# Activate virtual environment
#############################################

source "$VENV_DIR/bin/activate"

#############################################
# Upgrade pip (safe, fast)
#############################################

pip install --upgrade pip

#############################################
# Install / upgrade plugin dependencies
#############################################

if [ -d "$PLUGINS_DIR" ]; then
    echo "Checking plugin dependencies..."

    for plugin in "$PLUGINS_DIR"/*; do
        [[ -e "$plugin" ]] || continue

        META_FILE=""

        if [[ "$plugin" == *.pyz ]]; then
            unzip -o -qq "$plugin" mcdreforged.plugin.json -d /tmp/plugin_meta 2>/dev/null || continue
            META_FILE="/tmp/plugin_meta/mcdreforged.plugin.json"
        elif [[ "$plugin" == *.py ]]; then
            META_FILE="$plugin"
        fi

        if [ -f "$META_FILE" ]; then
            DEPS=$(jq -r '.dependencies[]?' "$META_FILE" 2>/dev/null || true)

            if [ -n "$DEPS" ]; then
                echo "Installing dependencies for $(basename "$plugin"): $DEPS"
                pip install --upgrade $DEPS || \
                    echo "Warning: some dependencies failed for $(basename "$plugin")"
            fi
        fi

        rm -rf /tmp/plugin_meta
    done
fi

#############################################
# Start MCDReforged
#############################################

echo "Starting MCDReforged..."
exec mcdreforged
