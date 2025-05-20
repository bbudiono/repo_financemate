#!/bin/bash

# test_builds.sh - Script to test both Debug and Release builds
# Part of DocketMate project
# 
# This script verifies that the project builds successfully in both
# Debug and Release configurations, providing a quick way to validate
# project stability before committing changes.

# Set up logging
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LOGS_DIR="${ROOT_DIR}/logs"
LOG_FILE="${LOGS_DIR}/test_builds_$(date +%Y%m%d_%H%M%S).log"

# Create logs directory if it doesn't exist
mkdir -p "$LOGS_DIR"

# Log both to file and stdout
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message" | tee -a "$LOG_FILE"
}

# Function to test a specific build configuration
test_build() {
    local config="$1"
    log "Testing $config build configuration..."
    
    cd "$ROOT_DIR/_macOS" || {
        log "ERROR: Could not find _macOS directory"
        return 1
    }
    
    log "Running xcodebuild for $config configuration..."
    xcodebuild -workspace DocketMate.xcworkspace -scheme "DocketMate" -configuration "$config" build 2>&1 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log "✅ $config build SUCCEEDED"
        return 0
    else
        log "❌ $config build FAILED"
        return 1
    }
}

log "Starting build tests for DocketMate"
log "========================================"

# Test Debug build
test_build "Debug"
DEBUG_RESULT=$?

# Test Release build
test_build "Release"
RELEASE_RESULT=$?

# Summary
log "========================================"
log "Build Test Summary:"
[ $DEBUG_RESULT -eq 0 ] && log "Debug build: ✅ SUCCESS" || log "Debug build: ❌ FAILED"
[ $RELEASE_RESULT -eq 0 ] && log "Release build: ✅ SUCCESS" || log "Release build: ❌ FAILED"

# Final result
if [ $DEBUG_RESULT -eq 0 ] && [ $RELEASE_RESULT -eq 0 ]; then
    log "All builds PASSED"
    exit 0
else
    log "Some builds FAILED"
    exit 1
fi
