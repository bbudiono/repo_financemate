#!/bin/bash

# Complete Folder Rename Script: Final DocketMate → FinanceMate Cleanup
# Generated: 2025-06-02
# Purpose: Complete the comprehensive rename by fixing remaining folder references

set -e

PROJECT_ROOT="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_docketmate"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$PROJECT_ROOT/logs/complete_folder_rename_$TIMESTAMP.log"

# Ensure logs directory exists
mkdir -p "$PROJECT_ROOT/logs"

echo "=== COMPLETE FOLDER RENAME: Final DocketMate → FinanceMate Cleanup ===" | tee "$LOG_FILE"
echo "Started: $(date)" | tee -a "$LOG_FILE"
echo "Project Root: $PROJECT_ROOT" | tee -a "$LOG_FILE"

# Function to log progress
log_progress() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to rename folder safely
rename_folder() {
    local old_path="$1"
    local new_path="$2"
    
    if [ -d "$old_path" ]; then
        log_progress "Renaming: $old_path → $new_path"
        mv "$old_path" "$new_path" 2>&1 | tee -a "$LOG_FILE"
        if [ $? -eq 0 ]; then
            log_progress "✅ Successfully renamed folder"
        else
            log_progress "❌ Failed to rename folder"
            return 1
        fi
    else
        log_progress "⚠️ Folder not found: $old_path"
    fi
}

log_progress "=== PHASE 1: CLEAN BUILD ARTIFACTS ==="

# Remove all build artifacts that contain DocketMate references
log_progress "Removing DocketMate build artifacts..."

# Remove FinanceMateCore build artifacts
if [ -d "$PROJECT_ROOT/_macOS/FinanceMateCore/.build" ]; then
    log_progress "Removing FinanceMateCore build artifacts"
    rm -rf "$PROJECT_ROOT/_macOS/FinanceMateCore/.build"
fi

# Remove Production build artifacts
if [ -d "$PROJECT_ROOT/_macOS/FinanceMate/build" ]; then
    log_progress "Removing Production build artifacts"
    rm -rf "$PROJECT_ROOT/_macOS/FinanceMate/build"
fi

# Remove Sandbox build artifacts
if [ -d "$PROJECT_ROOT/_macOS/FinanceMate-Sandbox/build" ]; then
    log_progress "Removing Sandbox build artifacts"
    rm -rf "$PROJECT_ROOT/_macOS/FinanceMate-Sandbox/build"
fi

log_progress "=== PHASE 2: RENAME REMAINING DOCKETMATE FOLDERS ==="

# Rename the main DocketMate folder in Production
rename_folder "$PROJECT_ROOT/_macOS/FinanceMate/DocketMate" "$PROJECT_ROOT/_macOS/FinanceMate/FinanceMate"

# Clean up FinanceMate-Export that still contains DocketMate.app
if [ -d "$PROJECT_ROOT/_macOS/FinanceMate-Export/DocketMate.app" ]; then
    rename_folder "$PROJECT_ROOT/_macOS/FinanceMate-Export/DocketMate.app" "$PROJECT_ROOT/_macOS/FinanceMate-Export/FinanceMate.app"
fi

# Clean up old archive dSYM
if [ -d "$PROJECT_ROOT/_macOS/FinanceMate.xcarchive/dSYMs/DocketMate.app.dSYM" ]; then
    rename_folder "$PROJECT_ROOT/_macOS/FinanceMate.xcarchive/dSYMs/DocketMate.app.dSYM" "$PROJECT_ROOT/_macOS/FinanceMate.xcarchive/dSYMs/FinanceMate.app.dSYM"
fi

# Check and rename old DocketMate_Sandbox folder if it exists
if [ -d "$PROJECT_ROOT/_macOS/FinanceMate_Sandbox/DocketMate_Sandbox.xcodeproj" ]; then
    rename_folder "$PROJECT_ROOT/_macOS/FinanceMate_Sandbox/DocketMate_Sandbox.xcodeproj" "$PROJECT_ROOT/_macOS/FinanceMate_Sandbox/FinanceMate_Sandbox.xcodeproj"
fi

# Rename DocketMateApp.swift if it exists in the old sandbox structure
if [ -f "$PROJECT_ROOT/_macOS/FinanceMate_Sandbox/Sources/DocketMateApp.swift" ]; then
    log_progress "Renaming DocketMateApp.swift to FinanceMateApp.swift"
    mv "$PROJECT_ROOT/_macOS/FinanceMate_Sandbox/Sources/DocketMateApp.swift" "$PROJECT_ROOT/_macOS/FinanceMate_Sandbox/Sources/FinanceMateApp.swift"
fi

log_progress "=== PHASE 3: VERIFY CLEANUP ==="

# Check for any remaining DocketMate references
log_progress "Checking for remaining DocketMate folder references..."
REMAINING_FOLDERS=$(find "$PROJECT_ROOT" -name "*DocketMate*" -type d 2>/dev/null | wc -l)
REMAINING_FILES=$(find "$PROJECT_ROOT" -name "*DocketMate*" -type f 2>/dev/null | grep -v ".log" | wc -l)

log_progress "Remaining DocketMate folders: $REMAINING_FOLDERS"
log_progress "Remaining DocketMate files: $REMAINING_FILES"

if [ "$REMAINING_FOLDERS" -gt 0 ] || [ "$REMAINING_FILES" -gt 0 ]; then
    log_progress "⚠️ Some DocketMate references remain:"
    find "$PROJECT_ROOT" -name "*DocketMate*" 2>/dev/null | grep -v ".log" | head -10 | tee -a "$LOG_FILE"
fi

log_progress "=== PHASE 4: VALIDATION ==="

# Verify critical folders exist
CRITICAL_FOLDERS=(
    "$PROJECT_ROOT/_macOS/FinanceMate/FinanceMate"
    "$PROJECT_ROOT/_macOS/FinanceMate-Sandbox"
    "$PROJECT_ROOT/_macOS/FinanceMate.xcworkspace"
)

for folder in "${CRITICAL_FOLDERS[@]}"; do
    if [ -d "$folder" ]; then
        log_progress "✅ Critical folder exists: $(basename "$folder")"
    else
        log_progress "❌ Critical folder missing: $folder"
    fi
done

log_progress "=== CLEANUP COMPLETE ==="
log_progress "Finished: $(date)"

echo ""
echo "✅ FOLDER RENAME COMPLETE"
echo "📋 Log saved to: $LOG_FILE"
echo ""
echo "Next steps:"
echo "1. Rename root repository folder: repo_docketmate → repo_financemate"
echo "2. Verify builds still work"
echo "3. Commit changes"