#!/bin/bash
# Copyright (c) 2025-2026 Marc Allgeier (fidpa)
# SPDX-License-Identifier: MIT
# https://github.com/fidpa/server-scripts-cli
# ---
# deployment: automated
# service: health-check.service
# status: active
# type: check
# requires_root: false
# ---
#
# Health Check Script
# Validates system health and returns exit code
#
# Usage:
#   ./health-check.sh

set -uo pipefail

readonly MAX_LOAD=10.0
readonly MAX_MEMORY_PERCENT=90
readonly MAX_DISK_PERCENT=85

# Check CPU load
CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
if (( $(echo "$CPU_LOAD > $MAX_LOAD" | bc -l 2>/dev/null || echo 0) )); then
    echo "CRITICAL: CPU load too high: $CPU_LOAD"
    exit 1
fi

# Check memory
MEMORY_USED=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
if [[ $MEMORY_USED -gt $MAX_MEMORY_PERCENT ]]; then
    echo "CRITICAL: Memory usage too high: ${MEMORY_USED}%"
    exit 1
fi

# Check disk
DISK_USED=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [[ $DISK_USED -gt $MAX_DISK_PERCENT ]]; then
    echo "CRITICAL: Disk usage too high: ${DISK_USED}%"
    exit 1
fi

echo "OK: All health checks passed"
exit 0
