#!/bin/bash
# Copyright (c) 2025-2026 Marc Allgeier (fidpa)
# SPDX-License-Identifier: MIT
# https://github.com/fidpa/server-scripts-cli
# ---
# deployment: manual
# service: none
# status: active
# type: monitoring
# requires_root: false
# ---
#
# Monitoring Example Script
# Demonstrates system metrics collection
#
# Usage:
#   ./monitoring-example.sh [--json]

set -uo pipefail

# Parse arguments
OUTPUT_FORMAT="text"
if [[ "${1:-}" == "--json" ]]; then
    OUTPUT_FORMAT="json"
fi

# Collect metrics
CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
MEMORY_USED=$(free -m | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
DISK_USED=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    cat << EOF
{
  "cpu_load": "$CPU_LOAD",
  "memory_percent": $MEMORY_USED,
  "disk_percent": $DISK_USED,
  "timestamp": "$(date -Is)"
}
EOF
else
    echo "=== System Monitoring ==="
    echo "CPU Load: $CPU_LOAD"
    echo "Memory Used: ${MEMORY_USED}%"
    echo "Disk Used: ${DISK_USED}%"
    echo "Timestamp: $(date -Is)"
fi

exit 0
