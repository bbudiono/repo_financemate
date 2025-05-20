# DocketMate Project Scripts

This document catalogs all utility scripts used in the DocketMate project, their purpose, and usage instructions.

## Build Scripts

### test_builds.sh

**Purpose**: Validates that the project builds successfully in both Debug and Release configurations.

**Location**: `scripts/test_builds.sh`

**Usage**:
```bash
./scripts/test_builds.sh
```

**Features**:
- Tests both Debug and Release configurations
- Generates detailed logs in the `logs/` directory
- Provides clear success/failure indicators for each build
- Returns non-zero exit code if any build fails

**When to use**: 
- Before committing changes that might affect build integrity
- As part of continuous integration workflows
- When troubleshooting build-related issues

## Xcode Configuration Scripts

### ensure_xcode_files.sh

**Purpose**: Ensures that all required Xcode project files exist and are properly configured according to project standards.

**Location**: `scripts/ensure_xcode_files.sh`

**Usage**:
```bash
./scripts/ensure_xcode_files.sh
```

**Features**:
- Validates shared workspace structure
- Configures proper FileRef entries for production and sandbox projects
- Sets up dependency-based parallel builds
- Implements robust logging to the `logs/` directory

**When to use**:
- After pulling changes that modify Xcode project structure
- When setting up a new development environment
- When experiencing issues with Xcode project configuration 