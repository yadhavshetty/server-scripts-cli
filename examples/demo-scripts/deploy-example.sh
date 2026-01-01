#!/bin/bash
# Copyright (c) 2025-2026 Marc Allgeier (fidpa)
# SPDX-License-Identifier: MIT
# https://github.com/fidpa/server-scripts-cli
# ---
# deployment: manual
# service: none
# status: active
# type: automation
# requires_root: true
# ---
#
# Deployment Example Script
# Demonstrates a deployment workflow with checks
#
# Usage:
#   sudo ./deploy-example.sh [--force]

set -uo pipefail

readonly DEPLOY_DIR="/opt/myapp"
readonly CONFIG_FILE="${DEPLOY_DIR}/config.conf"

# Parse arguments
FORCE=false
if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

# Check root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script requires root privileges"
    exit 1
fi

echo "=== Deployment Script ==="
echo "Target: $DEPLOY_DIR"
echo ""

# Pre-deployment checks
if [[ ! -d "$DEPLOY_DIR" && "$FORCE" != "true" ]]; then
    echo "Error: Deploy directory does not exist: $DEPLOY_DIR"
    echo "Use --force to create it"
    exit 1
fi

# Create deployment directory
echo "→ Creating deployment directory..."
mkdir -p "$DEPLOY_DIR"

# Write config
echo "→ Writing configuration..."
cat > "$CONFIG_FILE" << EOF
# Application Configuration
# Generated: $(date -Is)
app_version=1.0.0
environment=production
EOF

# Set permissions
echo "→ Setting permissions..."
chmod 755 "$DEPLOY_DIR"
chmod 644 "$CONFIG_FILE"

echo ""
echo "✓ Deployment completed successfully"
echo "  Directory: $DEPLOY_DIR"
echo "  Config: $CONFIG_FILE"
exit 0
