# Changelog

All notable changes to server-scripts-cli will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2026-01-17

### Fixed
- **HIGH**: Generator now supports `examples/demo-scripts/` directory as fallback when `scripts/` doesn't exist ([#codex-high](https://github.com/fidpa/server-scripts-cli/issues))
  - Enables testing generator in standalone demo repository without manual setup
  - Priority-based directory search: `scripts/` first, then `examples/demo-scripts/`
- **MEDIUM**: Fixed type taxonomy inconsistency - removed `cli-tool` default type, changed to `admin` ([#codex-medium](https://github.com/fidpa/server-scripts-cli/issues))
  - Default type changed from `cli-tool` to `admin` (Tier 1 type)
  - Updated CLI help text to show valid type examples
- **MEDIUM**: Added auto-migration for deprecated `cli-tool` type → `admin` with warnings ([#codex-medium](https://github.com/fidpa/server-scripts-cli/issues))
  - Non-breaking change: existing scripts with `type: cli-tool` auto-migrate
  - Warning messages guide users to update YAML frontmatter
- **LOW**: Synchronized version strings across all files to v1.1.1 ([#codex-low](https://github.com/fidpa/server-scripts-cli/issues))

### Changed
- Generator now scans directories in priority order: `scripts/` first, then `examples/demo-scripts/`
- Default type for scripts without frontmatter changed from `cli-tool` to `admin`
- Updated CLI help text (`ssc list --help`) to remove `cli-tool` references

### Deprecated
- Type `cli-tool` is now deprecated - use `deployment: cli-tool` field instead
- See [MANIFEST_SCHEMA.md](docs/MANIFEST_SCHEMA.md#deprecated-types) for migration guide

### Documentation
- Added "Deprecated Types" section to [MANIFEST_SCHEMA.md](docs/MANIFEST_SCHEMA.md)
- Added migration examples and behavior documentation

## [1.1.0] - 2026-01-16

### Added
- **4-Tier Type System**: Organize scripts by usage pattern
  - Tier 1 (Interactive): `report`, `admin`, `diagnostic`, `check`, `orchestrator`
  - Tier 2 (One-time): `deploy`, `setup`, `migration`, `generator`, `benchmark`
  - Tier 3 (Background): `daemon`, `scheduled`, `exporter`
  - Tier 4 (Internal): `library`, `helper`
- **Smart Default Filtering**: `ssc list` shows only Interactive types (Tier 1) by default
- **New `--all` flag**: Show complete script list including all tiers
- **Enhanced Help Text**: Detailed type hierarchy documentation in `ssc list --help`
- **Color-Coded Types**: Visual distinction between tiers (Green/Yellow/Cyan/Magenta)
- **New Type: `benchmark`**: Performance testing scripts (Tier 2)

### Changed
- **Demo Scripts Updated**: Migrated to new type system
  - `backup-example.sh`: `backup` → `admin`
  - `monitoring-example.sh`: `monitoring` → `check`
  - `health-check.sh`: `validation` → `check`
  - `deploy-example.sh`: `automation` → `deploy`
- **Manifest Schema**: Updated with complete type hierarchy documentation
- **README**: Enhanced feature list and examples

### Deprecated
- Legacy types (`automation`, `backup`, `monitoring`, `validation`) still supported but superseded by new types

## [1.0.0] - 2026-01-02

### Added
- Initial public release
- Core commands: `list`, `run`, `info`, `status`, `logs`, `validate`, `generate`
- YAML manifest-based script discovery
- systemd integration for status and logs
- Category and status filtering
- Search functionality
- Security: Input validation, safe execution, requires_root detection
- Demo scripts: 4 examples (backup, monitoring, health-check, deployment)
- Complete documentation suite
- MIT License

[1.1.1]: https://github.com/fidpa/server-scripts-cli/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/fidpa/server-scripts-cli/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/fidpa/server-scripts-cli/releases/tag/v1.0.0
