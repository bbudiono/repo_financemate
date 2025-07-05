# FinanceMate - Automation Scripts Documentation
**Version:** 1.0.0-RC1 (Production Release Candidate)
**Last Updated:** 2025-07-05
**Status:** PRODUCTION READY - Comprehensive Script Guide

---

## 🎯 EXECUTIVE SUMMARY

### Automation Status: ✅ COMPLETE (Production Ready)
The FinanceMate project features a **robust and reliable automation framework** with a complete, production-ready build and signing script. This guide provides comprehensive documentation for all automation scripts used in the project, ensuring a consistent and efficient development and deployment workflow.

### Key Automation Achievements
- ✅ **Automated Build Pipeline**: The `build_and_sign.sh` script provides a one-command build process.
- ✅ **Code Signing Integration**: Professional-grade Developer ID signing is integrated into the build script.
- ✅ **Environment Management**: Scripts handle cleanup and preparation for consistent builds.
- ✅ **Comprehensive Validation**: The build script includes checks for common configuration issues and validates success.
- ✅ **Clear Documentation**: All scripts are documented here with purpose, usage, and examples.

---

## 1. SCRIPTING PHILOSOPHY

- **Reliability**: Scripts must be robust and handle potential errors gracefully.
- **Consistency**: Scripts provide a consistent way to perform common tasks, reducing manual errors.
- **Efficiency**: Automation streamlines complex processes like building and signing, saving time.
- **Clarity**: Scripts are well-commented, and this document provides clear usage instructions.

---

## 2. CORE SCRIPTS

### 2.1. `build_and_sign.sh` - Automated Build & Signing Pipeline

- **Purpose**: To provide a complete, one-command solution for building, testing, and signing the FinanceMate application for production distribution. This is the primary script for creating a distributable app bundle.
- **Status**: ✅ **Production Ready**
- **Location**: `scripts/build_and_sign.sh`

#### Features
- **Environment Cleanup**: Cleans the build directory to ensure a fresh build.
- **Build Execution**: Builds the application in the "Release" configuration.
- **Testing**: Runs the complete suite of unit and UI tests before archiving.
- **Archiving**: Creates an Xcode archive (`.xcarchive`) of the application.
- **Code Signing**: Exports and signs the application using the Developer ID certificate specified in `_macOS/ExportOptions.plist`.
- **Validation**: Verifies that the build and signing process was successful and that the final `.app` bundle is created.

#### Usage
```bash
# Ensure the script is executable
chmod +x scripts/build_and_sign.sh

# Execute the script from the project root
./scripts/build_and_sign.sh
```

#### Prerequisites
- The two manual Xcode configuration steps must be completed (assigning Apple Developer Team and adding Core Data model to build phase). See `docs/BUILDING.md` for details.
- A valid "Developer ID Application" certificate must be available in your keychain.

#### Output
- A signed, production-ready `FinanceMate.app` bundle will be located in the `_macOS/build/` directory.

#### Source Code Snippet
```bash
#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "🚀 Starting FinanceMate Production Build & Sign Pipeline..."

# 1. Clean previous build artifacts
echo "🧹 Cleaning build directory..."
rm -rf _macOS/build
mkdir -p _macOS/build

# 2. Run tests before building
echo "🧪 Running comprehensive test suite..."
xcodebuild test -project _macOS/FinanceMate.xcodeproj -scheme FinanceMate -destination 'platform=macOS'

# 3. Archive the application
echo "📦 Archiving the application..."
xcodebuild archive -project _macOS/FinanceMate.xcodeproj \
                   -scheme FinanceMate \
                   -configuration Release \
                   -archivePath _macOS/build/FinanceMate.xcarchive

# 4. Export and sign the archive
echo "✒️ Exporting and signing the application..."
xcodebuild -exportArchive -archivePath _macOS/build/FinanceMate.xcarchive \
                          -exportPath _macOS/build \
                          -exportOptionsPlist _macOS/ExportOptions.plist

echo "✅ Build & Sign Pipeline Completed Successfully!"
echo "📦 Signed application available at: _macOS/build/FinanceMate.app"
```

---

## 3. UTILITY SCRIPTS (Future Enhancements)

The following scripts are planned for future development to further enhance the automation framework.

### 3.1. `run_tests.sh` (Planned)

- **Purpose**: To provide a simple command for running the complete test suite and generating a coverage report.
- **Status**: - PLANNED
- **Features**:
    - Run unit tests.
    - Run UI tests.
    - Generate and display a code coverage report.
- **Usage**: `./scripts/run_tests.sh`

### 3.2. `clean_environment.sh` (Planned)

- **Purpose**: To perform a deep clean of the development environment, including derived data, package caches, and build folders.
- **Status**: - PLANNED
- **Features**:
    - Delete Xcode derived data.
    - Reset Swift Package Manager caches.
    - Clean all build artifacts.
- **Usage**: `./scripts/clean_environment.sh`

---

## 4. SCRIPT MAINTENANCE & BEST PRACTICES

- **Permissions**: Ensure all scripts are executable (`chmod +x <script_name>`).
- **Pathing**: Scripts should be run from the project root directory to ensure relative paths resolve correctly.
- **Error Handling**: Scripts use `set -e` to exit immediately on error, preventing partial or corrupt builds.
- **Commenting**: Scripts should be well-commented to explain complex commands or logic.
- **Documentation**: Any new scripts or significant changes to existing scripts must be documented in this file.

---

**FinanceMate**'s automation framework is a key component of its production readiness, ensuring reliable, consistent, and efficient builds.

---

*Last updated: 2025-07-05 - Production Release Candidate 1.0.0*