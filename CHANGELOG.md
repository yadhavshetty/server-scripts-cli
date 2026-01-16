# Changelog

All notable changes to server-scripts-cli will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.1.0]: https://github.com/fidpa/server-scripts-cli/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/fidpa/server-scripts-cli/releases/tag/v1.0.0
