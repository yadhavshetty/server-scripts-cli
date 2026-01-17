# Manifest Schema Reference

Complete YAML schema documentation for `manifest.yaml`.

## Overview

The manifest file is **auto-generated** from YAML front-matter in your scripts. It provides a centralized registry for script discovery, metadata, and systemd integration.

**Generation**: `./generate-manifest.sh`
**Location**: `manifest.yaml` (repository root)

## Top-Level Structure

```yaml
metadata:        # File metadata
categories:      # Category registry
scripts:         # Script entries
```

## Metadata Section

Auto-generated metadata about the manifest file.

```yaml
metadata:
  version: "1.0.0"
  generated: "2026-01-01T12:00:00+01:00"
  generator: "generate-manifest.sh"
  total_scripts: 4
  with_frontmatter: 4
```

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | Schema version |
| `generated` | ISO-8601 | Generation timestamp |
| `generator` | string | Tool that created manifest |
| `total_scripts` | integer | Total scripts discovered |
| `with_frontmatter` | integer | Scripts with YAML metadata |

## Categories Section

Logical grouping of scripts by purpose.

```yaml
categories:
  operations:
    description: "Maintenance, Validation & Backup"
    path: "scripts/operations/"
  monitoring:
    description: "Health Check & Monitoring Scripts"
    path: "scripts/monitoring/"
```

### Common Categories

- `operations` - Maintenance, backup, validation
- `monitoring` - Health checks, metrics collection
- `setup` - Installation, configuration
- `deployment` - CI/CD, deployment automation
- `development` - Testing, documentation tools

## Scripts Section

Registry of all scripts with extracted metadata.

```yaml
scripts:
  backup-example:
    path: "examples/demo-scripts/backup-example.sh"
    category: "operations"
    deployment: scheduled
    service: none
    status: active
    type: admin
    requires_root: true
```

### Script Entry Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `path` | string | Yes | Relative path from repository root |
| `category` | string | Yes | Category key (from categories section) |
| `deployment` | string | Yes | How script is deployed/executed |
| `service` | string | Yes | Associated systemd service (or "none") |
| `status` | string | Yes | Script lifecycle status |
| `type` | string | Yes | Script type/purpose |
| `requires_root` | boolean | Yes | Whether sudo is required |

## Valid Values

### deployment

| Value | Description |
|-------|-------------|
| `manual` | Run manually via CLI |
| `scheduled` | Scheduled execution (cron/timer) |
| `automated` | Event-triggered execution |
| `cli-tool` | Interactive CLI tool |
| `systemd-timer` | systemd timer-activated |
| `triggered` | Webhook/external trigger |

### type

Scripts are organized into a **4-Tier Hierarchy**:

**Tier 1 - Interactive** (shown by default):

| Value | Description |
|-------|-------------|
| `report` | Status/summary reports |
| `admin` | Regular admin tools (maintenance, sync, restart) |
| `diagnostic` | Debug/troubleshooting/analysis |
| `check` | Validation/health-checks |
| `orchestrator` | Multi-script coordinators |

**Tier 2 - One-time** (use `--all` or `--type`):

| Value | Description |
|-------|-------------|
| `deploy` | Deployment scripts |
| `setup` | Setup/installation |
| `migration` | Data migrations |
| `generator` | File generators |
| `benchmark` | Performance testing |

**Tier 3 - Background** (use `--all` or `--type`):

| Value | Description |
|-------|-------------|
| `daemon` | systemd services (long-running) |
| `scheduled` | Timer-based scripts |
| `exporter` | Prometheus exporters |

**Tier 4 - Internal** (use `--all` or `--type`):

| Value | Description |
|-------|-------------|
| `library` | Sourced by scripts |
| `helper` | Called by scripts |

### Deprecated Types

The following types are **deprecated** and will be auto-migrated by `generate-manifest.sh`:

| Deprecated Value | Migration Target | Note |
|-----------------|------------------|------|
| `cli-tool` | `admin` | Use `deployment: cli-tool` field instead (see Deployment section) |

**Migration Behavior**: If `generate-manifest.sh` encounters `type: cli-tool` in a script's YAML frontmatter, it will:
1. Auto-migrate to `type: admin`
2. Print a warning with migration instructions
3. Continue processing (non-breaking)

**Example**:
```yaml
# ❌ Old (deprecated)
# ---
# type: cli-tool
# ---

# ✅ New (recommended)
# ---
# type: admin
# deployment: cli-tool  # If script is interactive CLI tool
# ---
```

### status

| Value | Description |
|-------|-------------|
| `active` | Actively maintained and in use |
| `deprecated` | Scheduled for removal |
| `development` | Under active development |
| `experimental` | Experimental feature |
| `production` | Production-ready |

### service

- `none` - No associated systemd service
- `<service-name>.service` - Specific service unit
- `<timer-name>.timer` - Specific timer unit

### requires_root

- `true` - Script requires root/sudo
- `false` - Can run as regular user

## YAML Front-Matter Format

Add to your scripts (between `# ---` markers):

```bash
#!/bin/bash
# ---
# deployment: manual
# service: backup.service
# status: active
# type: admin
# requires_root: true
# ---
#
# Script content here
```

**Rules**:
- Must be within first 30 lines of file
- Start/end with `# ---`
- Prefix each line with `# `
- Standard YAML syntax

## Example: Complete Manifest

```yaml
metadata:
  version: "1.0.0"
  generated: "2026-01-01T12:00:00+01:00"
  generator: "generate-manifest.sh"
  total_scripts: 2
  with_frontmatter: 2

categories:
  operations:
    description: "Maintenance & Backup"
    path: "scripts/operations/"

scripts:
  daily-backup:
    path: "scripts/operations/daily-backup.sh"
    category: "operations"
    deployment: scheduled
    service: daily-backup.timer
    status: active
    type: backup
    requires_root: true

  health-check:
    path: "scripts/monitoring/health-check.sh"
    category: "monitoring"
    deployment: automated
    service: health-check.service
    status: active
    type: validation
    requires_root: false
```

## Validation

Check manifest integrity:

```bash
ssc validate
```

Checks:
- YAML syntax validity
- All script paths exist
- Required fields present
- Value constraints

## Regeneration

**When to regenerate**:
- After adding new scripts
- After modifying front-matter
- After moving/renaming scripts

**How**:
```bash
./generate-manifest.sh
```

**Warning**: DO NOT edit `manifest.yaml` manually - it will be overwritten!

## Advanced: Custom Categories

To add custom categories, modify `generate-manifest.sh`:

```bash
# In generate_header() function
categories:
  custom:
    description: "My Custom Category"
    path: "scripts/custom/"
```

Then regenerate the manifest.
