#!/bin/bash
# Copyright (c) 2025-2026 Marc Allgeier (fidpa)
# SPDX-License-Identifier: MIT
# https://github.com/fidpa/server-scripts-cli
# ---
# deployment: scheduled
# service: none
# status: active
# type: backup
# requires_root: true
# ---
#
# Backup Example Script
# Demonstrates a backup script pattern with root privileges
#
# Usage:
#   sudo ./backup-example.sh [--dry-run]

set -uo pipefail

readonly BACKUP_DIR="/var/backups/example"
readonly SOURCE_DIR="/etc"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Parse arguments
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# Check root
if [[ $EUID -ne 0 && "$DRY_RUN" == "false" ]]; then
    echo "Error: This script requires root privileges"
    exit 1
fi

echo "=== Backup Example Script ==="
echo "Source: $SOURCE_DIR"
echo "Destination: $BACKUP_DIR"
echo "Timestamp: $TIMESTAMP"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN] Would create backup: ${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"
    exit 0
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create backup
echo "Creating backup..."
tar -czf "${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz" -C "$SOURCE_DIR" . 2>/dev/null || {
    echo "Error: Backup failed"
    exit 1
}

echo "✓ Backup completed: ${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"
exit 0
