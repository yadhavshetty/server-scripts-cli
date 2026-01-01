# Setup Guide

Complete installation and configuration guide for Server Scripts CLI.

## Prerequisites

### Required

- **Bash 4.0+**: Check version with `bash --version`
- **yq v4+**: YAML processor by mikefarah

### Optional

- **systemd**: For service status and log querying
- **Git**: For automatic repository root detection

## Installing yq

**Snap (Recommended)**:
```bash
sudo snap install yq
```

**Binary Download**:
```bash
VERSION=v4.40.5
BINARY=yq_linux_amd64
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O yq
chmod +x yq
sudo mv yq /usr/local/bin/
```

**Verify**:
```bash
yq --version
# Expected: yq (https://github.com/mikefarah/yq/) version v4.40.5
```

## Installation Methods

### Method 1: Local Repository (Recommended)

```bash
# Clone repository
git clone https://github.com/fidpa/server-scripts-cli
cd server-scripts-cli

# Make scripts executable
chmod +x ssc.sh generate-manifest.sh

# Create alias in ~/.bashrc
echo "alias ssc='$(pwd)/ssc.sh'" >> ~/.bashrc
source ~/.bashrc

# Test
ssc --version
```

### Method 2: System-Wide Installation

```bash
# Install to /usr/local/bin
sudo cp ssc.sh /usr/local/bin/ssc
sudo cp generate-manifest.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/{ssc,generate-manifest.sh}

# Test
ssc --version
```

### Method 3: User-Local Symlink

```bash
# Create ~/.local/bin if it doesn't exist
mkdir -p ~/.local/bin

# Symlink
ln -s $(pwd)/ssc.sh ~/.local/bin/ssc

# Ensure ~/.local/bin is in PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Test
ssc --version
```

## Repository Structure

Your repository should follow this structure:

```
your-repo/
├── scripts/
│   ├── operations/
│   │   └── backup.sh         # Your scripts here
│   ├── monitoring/
│   │   └── health-check.sh
│   └── setup/
│       └── install.sh
├── ssc.sh                      # CLI tool
├── generate-manifest.sh        # Manifest generator
└── manifest.yaml               # Auto-generated (DO NOT EDIT)
```

## Generating Your First Manifest

1. **Add YAML front-matter to your scripts**:

```bash
#!/bin/bash
# ---
# deployment: manual
# service: none
# status: active
# type: cli-tool
# requires_root: false
# ---
#
# Your script content
```

2. **Run generator**:

```bash
./generate-manifest.sh
```

3. **Verify**:

```bash
ssc list
ssc validate
```

## Configuration

### Environment Variables

Optional configuration via environment variables:

```bash
# Manifest location (default: ./manifest.yaml)
export SSC_MANIFEST_FILE="/path/to/custom/manifest.yaml"

# Log level (debug, info, warning, error)
export SSC_LOG_LEVEL="info"

# Color output (auto, always, never)
export SSC_COLOR="auto"
```

### Configuration File

Create `~/.config/ssc/ssc.env`:

```bash
SSC_MANIFEST_FILE="/path/to/manifest.yaml"
SSC_LOG_LEVEL="info"
SSC_COLOR="auto"
```

Source in your shell:
```bash
echo 'source ~/.config/ssc/ssc.env' >> ~/.bashrc
```

## systemd Integration (Optional)

### Service Status Queries

If your scripts have associated systemd services, use:

```bash
# Show all service statuses
ssc status

# Show specific service
ssc status -s backup-example

# Include logs
ssc status -s backup-example -l -n 50
```

### Timer Overview

```bash
# Show systemd timer schedule
ssc status --timers
```

### Log Queries

```bash
# Show logs for script's service
ssc logs backup-example

# With options (passed to journalctl)
ssc logs backup-example -n 100 --since "1 hour ago"
```

## Updating Scripts

1. **Edit your scripts** (add/modify YAML front-matter)
2. **Regenerate manifest**:
   ```bash
   ./generate-manifest.sh
   ```
3. **Validate**:
   ```bash
   ssc validate
   ```

## Tab Completion (Optional)

Bash completion support:

```bash
# Install completion (if available in repo)
sudo cp completions/ssc.bash /etc/bash_completion.d/
source /etc/bash_completion.d/ssc.bash
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues.

## Next Steps

- Read [MANIFEST_SCHEMA.md](MANIFEST_SCHEMA.md) for complete YAML reference
- Check [examples/demo-scripts/](../examples/demo-scripts/) for script patterns
- Run `ssc help` for CLI reference
