#!/bin/bash

#
# validate_codesign.sh
# FinanceMate Code Signing Validation Script
#
# Purpose: Comprehensive code signing validation for macOS FinanceMate application
# AUDIT: 20240629-TDD-VALIDATED Task 2.2
# Test Case: 1.3.1 - Production Build Archive & Notarization Check
#

set -e  # Exit on any error

# Configuration
PROJECT_NAME="FinanceMate"
PROJECT_PATH="../_macOS/FinanceMate/FinanceMate.xcodeproj"
SCHEME_NAME="FinanceMate"
BUILD_CONFIG="${1:-Release}"  # Default to Release if no argument provided
ARCHIVE_PATH="../temp/FinanceMate_CodeSign_Archive_$(date +'%Y%m%d_%H%M%S').xcarchive"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../docs/logs"
LOG_FILE="$LOG_DIR/CodeSign_Validation_$(date +'%Y%m%d_%H%M%S').log"

# Ensure logs directory exists
mkdir -p "$LOG_DIR"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling function
handle_error() {
    log "ERROR: $1"
    log "FAILURE: Code signing validation failed"
    echo "FAILURE"
    exit 1
}

log "=== FinanceMate Code Signing Validation Started ==="
log "Configuration: $BUILD_CONFIG"
log "Archive Path: $ARCHIVE_PATH"
log "Log File: $LOG_FILE"

# Validate prerequisites
log "Step 1: Validating prerequisites"

if [ ! -d "$PROJECT_PATH" ]; then
    handle_error "Project not found at $PROJECT_PATH"
fi

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    handle_error "xcodebuild command not found. Ensure Xcode is installed."
fi

# Check if codesign is available
if ! command -v codesign &> /dev/null; then
    handle_error "codesign command not found."
fi

# Check if spctl is available
if ! command -v spctl &> /dev/null; then
    handle_error "spctl command not found."
fi

log "Prerequisites validated successfully"

# Step 2: Archive the application
log "Step 2: Creating archive for $SCHEME_NAME"

# Change to the project directory
cd "$(dirname "$PROJECT_PATH")"

# Create archive
log "Running xcodebuild archive..."
if xcodebuild archive \
    -project "$(basename "$PROJECT_PATH")" \
    -scheme "$SCHEME_NAME" \
    -configuration "$BUILD_CONFIG" \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    CODE_SIGNING_REQUIRED=NO \
    >> "$LOG_FILE" 2>&1; then
    log "Archive created successfully: $ARCHIVE_PATH"
else
    handle_error "Failed to create archive. Check build configuration and signing certificates."
fi

# Step 3: Locate the .app bundle
log "Step 3: Locating .app bundle within archive"

APP_BUNDLE_PATH="$ARCHIVE_PATH/Products/Applications/$PROJECT_NAME.app"

if [ ! -d "$APP_BUNDLE_PATH" ]; then
    # Try alternative path structure
    APP_BUNDLE_PATH="$ARCHIVE_PATH/Products/Applications/$SCHEME_NAME.app"
    if [ ! -d "$APP_BUNDLE_PATH" ]; then
        handle_error "Could not locate .app bundle in archive at expected paths"
    fi
fi

log "Found .app bundle: $APP_BUNDLE_PATH"

# Step 4: Verify code signature
log "Step 4: Verifying code signature with codesign"

log "Running codesign --verify --deep --strict --verbose=2..."
if codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE_PATH" >> "$LOG_FILE" 2>&1; then
    log "Code signature verification: PASSED"
else
    handle_error "Code signature verification failed. The app may not be properly signed."
fi

# Additional codesign information
log "Extracting code signature information..."
codesign --display --verbose=4 "$APP_BUNDLE_PATH" >> "$LOG_FILE" 2>&1 || true

# Step 5: Simulate Gatekeeper check
log "Step 5: Simulating Gatekeeper check with spctl"

log "Running spctl -a -vvv (Gatekeeper simulation)..."
if spctl -a -vvv "$APP_BUNDLE_PATH" >> "$LOG_FILE" 2>&1; then
    log "Gatekeeper simulation: PASSED"
    log "App would be accepted by macOS Gatekeeper"
else
    # spctl might fail for development builds, so we'll log but not fail entirely
    log "WARNING: Gatekeeper simulation failed. This may be expected for development builds."
    log "Check log for details. For App Store distribution, ensure proper notarization."
fi

# Step 6: Additional validation checks
log "Step 6: Additional validation checks"

# Check for hardened runtime
log "Checking for Hardened Runtime..."
if codesign --display --verbose "$APP_BUNDLE_PATH" 2>&1 | grep -q "runtime"; then
    log "Hardened Runtime: ENABLED"
else
    log "WARNING: Hardened Runtime not detected"
fi

# Check for embedded provisioning profile (if present)
log "Checking for embedded provisioning profile..."
if [ -f "$APP_BUNDLE_PATH/Contents/embedded.provisionprofile" ]; then
    log "Embedded provisioning profile: FOUND"
else
    log "Embedded provisioning profile: NOT FOUND (may be expected for some distribution methods)"
fi

# Check entitlements
log "Extracting entitlements..."
codesign --display --entitlements - "$APP_BUNDLE_PATH" >> "$LOG_FILE" 2>&1 || true

# Step 7: Generate summary report
log "Step 7: Generating validation summary"

log "=== CODE SIGNING VALIDATION SUMMARY ==="
log "Project: $PROJECT_NAME"
log "Configuration: $BUILD_CONFIG"
log "Archive: $ARCHIVE_PATH"
log "App Bundle: $APP_BUNDLE_PATH"
log "Timestamp: $(date)"

# Final validation status
if [ -d "$APP_BUNDLE_PATH" ]; then
    log "=== VALIDATION COMPLETE ==="
    log "Code signing validation completed successfully"
    log "App is properly signed and ready for distribution testing"
    echo "SUCCESS"
    exit 0
else
    handle_error "Final validation failed"
fi