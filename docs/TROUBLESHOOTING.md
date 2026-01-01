# Troubleshooting Guide

Common issues and solutions for Server Scripts CLI.

## Installation Issues

### yq not found

**Error**:
```
✗ yq is required but not installed
```

**Solution**:
```bash
# Snap (Recommended)
sudo snap install yq

# Or download binary
VERSION=v4.40.5
BINARY=yq_linux_amd64
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O yq
chmod +x yq
sudo mv yq /usr/local/bin/
```

**Verify**:
```bash
yq --version
# Expected: yq (https://github.com/mikefarah/yq/) version v4.x.x
```

### Wrong yq Version (Python wrapper)

**Error**:
```
✗ Unsupported yq detected (expected mikefarah/yq v4+)
```

**Cause**: You have the Python `yq` wrapper instead of mikefarah's yq.

**Solution**:
```bash
# Remove Python yq
pip uninstall yq

# Install mikefarah/yq
sudo snap install yq
```

### Permission Denied on ssc.sh

**Error**:
```
bash: ./ssc.sh: Permission denied
```

**Solution**:
```bash
chmod +x ssc.sh generate-manifest.sh
```

## Manifest Issues

### Manifest Not Found

**Error**:
```
✗ Manifest not found: manifest.yaml
```

**Solution**:
```bash
# Generate manifest
./generate-manifest.sh

# Verify
ls -lh manifest.yaml
```

### YAML Syntax Error

**Error**:
```
✗ YAML syntax error - check manifest manually
```

**Solution**:
```bash
# Validate YAML manually
yq eval '.' manifest.yaml

# Regenerate from scratch
./generate-manifest.sh
```

### Scripts Not Discovered

**Problem**: `ssc list` shows fewer scripts than expected.

**Causes & Solutions**:

1. **Missing Front-Matter**:
   ```bash
   # Add to your scripts
   # ---
   # deployment: manual
   # status: active
   # type: cli-tool
   # requires_root: false
   # ---
   ```

2. **Scripts in Ignored Directories**:
   - Check: `.venv/`, `venv/`, `node_modules/`, `__pycache__/` are excluded
   - Move scripts to `scripts/` directory

3. **Wrong File Extension**:
   - Only `.sh` and `.py` files are discovered
   - Rename: `script` → `script.sh`

4. **Regenerate Manifest**:
   ```bash
   ./generate-manifest.sh --verbose
   ```

## Execution Issues

### Script Not Found in Manifest

**Error**:
```
✗ Script not found: my-script
```

**Solution**:
```bash
# Search for similar names
ssc list --search my

# Regenerate manifest
./generate-manifest.sh

# Verify
ssc list --paths | grep my-script
```

### Script File Not Found

**Error**:
```
✗ Script file not found: /path/to/script.sh
→ Manifest may be outdated - run: ssc generate
```

**Solution**:
```bash
# Regenerate manifest
./generate-manifest.sh

# Or fix path in script's location
```

### Script Requires Root

**Error**:
```
→ Script requires root privileges - using sudo
```

**Solution**:
```bash
# Run with sudo
sudo ssc run backup-example

# Or use sudo interactively
ssc run backup-example
# (ssc will auto-exec with sudo)
```

### Deprecated Script Warning

**Error**:
```
⚠ Script is marked as DEPRECATED
✗ Use --force to run anyway
```

**Solution**:
```bash
# Force run deprecated script
ssc run --force old-script
```

## systemd Integration Issues

### Service Not Found

**Error**:
```
⚠ Service not found
```

**Causes**:
1. Service name typo in front-matter
2. Service not installed on system
3. Service name doesn't include `.service` suffix

**Solution**:
```bash
# Check systemd services
systemctl list-units --type=service | grep backup

# Fix front-matter
# service: backup.service  # Include .service suffix
```

### No Services in Manifest

**Warning**:
```
⚠ No services found in manifest
```

**Solution**:
- Most scripts don't have associated services
- This is normal if you only have manual CLI scripts
- Add `service: <name>.service` to front-matter for systemd-managed scripts

## Validation Issues

### Missing Script Files

**Error**:
```
✗ Missing: scripts/old-script.sh (old-script)
✗ 5 missing files found
```

**Solution**:
```bash
# Regenerate manifest to remove stale entries
./generate-manifest.sh

# Or restore missing files
```

### Unknown Status Scripts

**Warning**:
```
⚠ 12 scripts have unknown status (missing front-matter)
```

**Solution**:
Add YAML front-matter to scripts:
```bash
#!/bin/bash
# ---
# deployment: manual
# service: none
# status: active
# type: cli-tool
# requires_root: false
# ---
```

## Performance Issues

### Slow ssc list

**Cause**: Large manifest with many scripts.

**Solution**:
```bash
# Use filters to reduce output
ssc list --category operations
ssc list --status active --limit 50
```

### Slow Manifest Generation

**Cause**: Many scripts in repository.

**Solution**:
- Normal for 500+ scripts (takes ~10 seconds)
- Use `--dry-run` to preview without writing
- Exclude large directories in `find` command if needed

## Debug Mode

Enable verbose output:

```bash
# Manifest generation
./generate-manifest.sh --verbose

# Check yq availability
command -v yq && yq --version

# Validate manifest
yq eval '.' manifest.yaml | head -50

# List with full paths
ssc list --paths
```

## Getting Help

If issues persist:

1. **Check Requirements**:
   ```bash
   bash --version  # 4.0+
   yq --version    # v4.x.x
   ```

2. **Validate Environment**:
   ```bash
   ./generate-manifest.sh --dry-run --verbose
   ssc validate
   ```

3. **File a Bug Report**:
   - GitHub Issues: https://github.com/fidpa/server-scripts-cli/issues
   - Include: `ssc --version`, error message, OS details
