#!/bin/bash
# Copyright (c) 2025-2026 Marc Allgeier (fidpa)
# SPDX-License-Identifier: MIT
# https://github.com/fidpa/server-scripts-cli
#
# Manifest Generator for Server Scripts CLI
# Extracts YAML Front-Matter from all scripts and generates manifest.yaml
#
# Usage:
#   ./generate-manifest.sh              # Generate manifest
#   ./generate-manifest.sh --dry-run    # Preview without writing
#   ./generate-manifest.sh --verbose    # Show progress
#
# Documentation: docs/MANIFEST_SCHEMA.md
# Version: 1.1.1
# Created: 2026-01-02

set -uo pipefail

# ===== Configuration =====
readonly SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# REPO_ROOT detection (git-based with fallback)
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    readonly REPO_ROOT
else
    # Fallback: Script dir is repo root
    readonly REPO_ROOT="$SCRIPT_DIR"
fi
readonly MANIFEST_FILE="${REPO_ROOT}/manifest.yaml"
readonly VERSION="1.1.1"

# ===== Options =====
DRY_RUN=false
VERBOSE=false

# ===== Colors =====
if [[ -t 1 ]]; then
    readonly RED=$'\033[0;31m'
    readonly GREEN=$'\033[0;32m'
    readonly YELLOW=$'\033[1;33m'
    readonly BLUE=$'\033[0;34m'
    readonly CYAN=$'\033[0;36m'
    readonly BOLD=$'\033[1m'
    readonly NC=$'\033[0m'
else
    readonly RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
fi

# ===== Helper Functions =====

print_header() {
    printf "%b%s%b\n" "$BOLD" "$1" "$NC"
}

print_success() {
    printf "%b✓%b %s\n" "$GREEN" "$NC" "$1"
}

print_error() {
    printf "%b✗%b %s\n" "$RED" "$NC" "$1" >&2
}

print_warning() {
    printf "%b⚠%b %s\n" "$YELLOW" "$NC" "$1"
}

print_info() {
    printf "%b→%b %s\n" "$BLUE" "$NC" "$1"
}

print_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        printf "  %s\n" "$1"
    fi
}

# ===== Core Functions =====

# Extract YAML Front-Matter from a script file
# Returns empty string if no front-matter found
extract_frontmatter() {
    local script_path="$1"
    local in_frontmatter=false
    local frontmatter=""
    local line_count=0

    # Only check first 30 lines for front-matter
    while IFS= read -r line && [[ $line_count -lt 30 ]]; do
        ((line_count++))

        # Detect front-matter start/end marker
        if [[ "$line" == "# ---" ]]; then
            if [[ "$in_frontmatter" == "false" ]]; then
                in_frontmatter=true
                continue
            else
                # End of front-matter
                break
            fi
        fi

        # Collect front-matter lines (strip "# " prefix)
        if [[ "$in_frontmatter" == "true" ]]; then
            # Remove leading "# " from YAML lines
            local yaml_line="${line#\# }"
            # Skip empty lines
            if [[ -n "$yaml_line" ]]; then
                frontmatter+="${yaml_line}"$'\n'
            fi
        fi
    done < "$script_path"

    echo -n "$frontmatter"
}

# Generate short display name from path
generate_short_name() {
    local path="$1"
    basename "$path" | sed 's|\.sh$||' | sed 's|\.py$||'
}

# Determine category from path
get_category() {
    local path="$1"
    local relative_path="${path#${REPO_ROOT}/scripts/}"

    # Extract first directory as category
    echo "$relative_path" | cut -d'/' -f1
}

# Parse a single YAML field from front-matter
parse_yaml_field() {
    local frontmatter="$1"
    local field="$2"
    local default="${3:-}"

    local value
    value=$(echo "$frontmatter" | grep "^${field}:" | sed "s/^${field}:[[:space:]]*//" | head -1)

    if [[ -z "$value" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# Generate manifest header
generate_header() {
    local total_scripts="$1"
    local with_frontmatter="$2"
    local timestamp
    timestamp=$(date -Is)

    cat << EOF
# Server Scripts Manifest - Auto-generated from YAML Front-Matter
# DO NOT EDIT MANUALLY - Regenerate with: ./generate-manifest.sh
#
# Documentation: docs/MANIFEST_SCHEMA.md
# Version: ${VERSION}

metadata:
  version: "${VERSION}"
  generated: "${timestamp}"
  generator: "generate-manifest.sh"
  total_scripts: ${total_scripts}
  with_frontmatter: ${with_frontmatter}

# Categories derived from directory structure
categories:
  operations:
    description: "Maintenance, Validation & Backup"
    path: "scripts/operations/"
  monitoring:
    description: "Health Check & Monitoring Scripts"
    path: "scripts/monitoring/"
  setup:
    description: "Installation & Setup Scripts"
    path: "scripts/setup/"

# Script Registry
scripts:
EOF
}

# Generate YAML entry for a single script
generate_script_entry() {
    local script_path="$1"
    local relative_path="${script_path#${REPO_ROOT}/}"
    local short_name
    short_name=$(generate_short_name "$script_path")
    local category
    category=$(get_category "$script_path")

    # Extract front-matter
    local frontmatter
    frontmatter=$(extract_frontmatter "$script_path")

    # Parse fields (with defaults for scripts without front-matter)
    local deployment status type requires_root service

    if [[ -n "$frontmatter" ]]; then
        deployment=$(parse_yaml_field "$frontmatter" "deployment" "manual")
        status=$(parse_yaml_field "$frontmatter" "status" "active")
        type=$(parse_yaml_field "$frontmatter" "type" "admin")
        requires_root=$(parse_yaml_field "$frontmatter" "requires_root" "false")
        service=$(parse_yaml_field "$frontmatter" "service" "none")
    else
        # Defaults for scripts without front-matter
        deployment="manual"
        status="active"
        type="admin"
        requires_root="false"
        service="none"
    fi

    # Auto-migrate deprecated cli-tool type
    if [[ "$type" == "cli-tool" ]]; then
        local script_file="${script_path##*/}"
        print_warning "Script ${script_file}: type 'cli-tool' is deprecated, auto-migrating to 'admin'"
        print_info "  → Update YAML frontmatter: type: admin"
        print_info "  → Or use deployment field: deployment: cli-tool"
        type="admin"
    fi

    # Generate YAML entry
    cat << EOF
  ${short_name}:
    path: "${relative_path}"
    category: "${category}"
    deployment: ${deployment}
    service: ${service}
    status: ${status}
    type: ${type}
    requires_root: ${requires_root}

EOF
}

# Main manifest generation
generate_manifest() {
    print_header "Generating Script Manifest"
    echo ""

    local temp_file
    temp_file=$(mktemp)
    trap "rm -f '$temp_file'" EXIT

    local script_count=0
    local frontmatter_count=0
    local script_list=()

    # Detect script directory (priority: scripts/ → examples/demo-scripts/)
    readonly SCRIPT_DIRECTORIES=("scripts" "examples/demo-scripts")
    local SCAN_DIR=""

    for dir in "${SCRIPT_DIRECTORIES[@]}"; do
        if [[ -d "${REPO_ROOT}/${dir}" ]]; then
            SCAN_DIR="${REPO_ROOT}/${dir}"
            print_info "Scanning ${dir}/ directory..."
            break
        fi
    done

    if [[ -z "$SCAN_DIR" ]]; then
        print_error "No script directories found"
        print_info "Expected: scripts/ or examples/demo-scripts/"
        return 1
    fi

    # Find all scripts (excluding hidden, .venv, node_modules, etc.)
    while IFS= read -r script_path; do
        script_list+=("$script_path")
        ((script_count++))

        # Check for front-matter
        if head -30 "$script_path" 2>/dev/null | grep -q "^# ---"; then
            ((frontmatter_count++))
        fi

        print_verbose "Found: ${script_path#${REPO_ROOT}/}"
    done < <(find "$SCAN_DIR" -type f \( -name "*.sh" -o -name "*.py" \) \
        ! -name "__init__.py" \
        ! -path "*/.venv/*" \
        ! -path "*/venv/*" \
        ! -path "*/node_modules/*" \
        ! -path "*/__pycache__/*" \
        2>/dev/null | sort)

    if [[ $script_count -eq 0 ]]; then
        print_warning "No scripts found in ${SCAN_DIR}"
        print_info "Add some .sh or .py files to the scripts directory"
        return 1
    fi

    print_info "Found $script_count scripts ($frontmatter_count with front-matter)"
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN - Not writing manifest"
        print_info "Would generate manifest with $script_count scripts"
        return 0
    fi

    print_info "Generating manifest..."

    # Write header
    generate_header "$script_count" "$frontmatter_count" > "$temp_file"

    # Process each script
    local processed=0
    for script_path in "${script_list[@]}"; do
        generate_script_entry "$script_path" >> "$temp_file"
        ((processed++))

        # Progress indicator (every 10 scripts for small repos)
        if [[ $((processed % 10)) -eq 0 ]]; then
            printf "\r  Processed: %d/%d scripts" "$processed" "$script_count"
        fi
    done
    printf "\r  Processed: %d/%d scripts\n" "$processed" "$script_count"

    # Move to final location
    mv "$temp_file" "$MANIFEST_FILE"
    trap - EXIT

    echo ""
    print_success "Manifest generated: $MANIFEST_FILE"
    print_info "Total scripts: $script_count"
    if [[ $script_count -gt 0 ]]; then
        print_info "With front-matter: $frontmatter_count ($(( frontmatter_count * 100 / script_count ))%)"
    fi

    # Validate YAML syntax
    if command -v yq &>/dev/null; then
        if yq eval '.' "$MANIFEST_FILE" > /dev/null 2>&1; then
            print_success "YAML syntax valid"
        else
            print_error "YAML syntax error - check manifest manually"
            return 1
        fi
    else
        print_warning "yq not found - skipping YAML validation"
        print_info "Install: snap install yq"
    fi
}

# ===== Usage =====
usage() {
    cat << EOF
${BOLD}generate-manifest.sh${NC} - Manifest Generator for Server Scripts CLI

${BOLD}USAGE:${NC}
    ./generate-manifest.sh [options]

${BOLD}OPTIONS:${NC}
    -d, --dry-run    Preview without writing manifest
    -v, --verbose    Show detailed progress
    -h, --help       Show this help message

${BOLD}EXAMPLES:${NC}
    ./generate-manifest.sh              # Generate manifest
    ./generate-manifest.sh --dry-run    # Preview changes
    ./generate-manifest.sh --verbose    # Show all scripts found

${BOLD}OUTPUT:${NC}
    manifest.yaml (in repository root)

EOF
}

# ===== Main =====
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Run generation
    generate_manifest
}

main "$@"
