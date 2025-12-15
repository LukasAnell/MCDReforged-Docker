#!/bin/bash
set -e

#############################################
# Configuration
#############################################

MC_DR_DIR="/data"
VENV_DIR="$MC_DR_DIR/venv"
REQ_EXTRA="$MC_DR_DIR/requirements-extra.txt"

#############################################
# Ensure working directory exists
#############################################

mkdir -p "$MC_DR_DIR"
cd "$MC_DR_DIR"

#############################################
# Create virtual environment if missing
#############################################

if [ ! -d "$VENV_DIR" ]; then
  echo "Creating Python virtual environment at $VENV_DIR..."
  python3 -m venv "$VENV_DIR"
fi

#############################################
# Activate virtual environment
#############################################

source "$VENV_DIR/bin/activate"

#############################################
# Upgrade packaging tooling
#############################################

pip install --upgrade pip setuptools wheel

#############################################
# Ensure MCDReforged is installed in THIS venv
# (so all future pip installs land in /data/venv)
#############################################

pip install --upgrade mcdreforged

#############################################
# Optional: install server-specific extra requirements (persistent)
#############################################

if [ -f "$REQ_EXTRA" ]; then
  echo "Installing extra requirements from $(basename "$REQ_EXTRA")..."
  pip install -r "$REQ_EXTRA" || echo "Warning: some extra requirements failed to install"
fi

#############################################
# Initialize MCDReforged on first run (idempotent)
#############################################

if [ ! -f "$MC_DR_DIR/config/config.yml" ]; then
  echo "MCDReforged not initialized. Running init..."
  mcdreforged init
fi

#############################################
# Start MCDReforged (container-safe)
#############################################

echo "Starting MCDReforged..."
exec mcdreforged
