#!/bin/bash

#
# cleanup_ux_snapshots.sh
# UX Snapshots Cleanup Script
#
# Purpose: Clean up docs/UX_Snapshots directory keeping only files referenced in TEST_PLAN.md
# AUDIT: 20240629-TDD-VALIDATED Task 2.3
#

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UX_SNAPSHOTS_DIR="$SCRIPT_DIR/../docs/UX_Snapshots"
LOG_FILE="$SCRIPT_DIR/../docs/logs/UX_Snapshots_Cleanup_$(date +'%Y%m%d_%H%M%S').log"

# Ensure logs directory exists
mkdir -p "$SCRIPT_DIR/../docs/logs"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== UX Snapshots Cleanup Started ==="
log "Target Directory: $UX_SNAPSHOTS_DIR"
log "Log File: $LOG_FILE"

# Files to keep (referenced in TEST_PLAN.md and recent audit evidence)
KEEP_FILES=(
    "TC_1.1.1_Dashboard_Launch_20240629.png"
    "TC_1.1.2_Navigate_To_Initial_20240629.png"
    "TC_1.1.2_Navigate_To_Dashboard_20240629.png"
    "TC_1.1.2_Navigate_To_Analytics_20240629.png"
    "TC_1.1.2_Navigate_To_Documents_20240629.png"
    "TC_1.1.2_Navigate_To_CoPilot_20240629.png"
    "TC_1.1.2_Navigate_To_Settings_20240629.png"
    "AboutView_Glassmorphism_TDD_20240629.png"
    "AboutView_Glassmorphism_Validation_20240629.png"
)

# Directories to keep
KEEP_DIRS=(
    "theming_audit"
)

log "Files to keep: ${KEEP_FILES[*]}"
log "Directories to keep: ${KEEP_DIRS[*]}"

cd "$UX_SNAPSHOTS_DIR"

# Count files before cleanup
TOTAL_FILES_BEFORE=$(find . -type f | wc -l)
log "Total files before cleanup: $TOTAL_FILES_BEFORE"

# Create a temporary file to track what we're keeping
KEEP_LIST_FILE="/tmp/ux_snapshots_keep_list.txt"
rm -f "$KEEP_LIST_FILE"

# Add files to keep list
for file in "${KEEP_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "$file" >> "$KEEP_LIST_FILE"
        log "KEEP: $file (referenced in TEST_PLAN.md)"
    else
        log "WARNING: Referenced file not found: $file"
    fi
done

# Add directory contents to keep list
for dir in "${KEEP_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        find "$dir" -type f >> "$KEEP_LIST_FILE"
        log "KEEP: $dir/ directory (contains audit evidence)"
    fi
done

# Process all files in the directory
REMOVED_COUNT=0
KEPT_COUNT=0

log "Starting cleanup process..."

for file in $(find . -type f); do
    # Remove leading ./
    clean_file="${file#./}"
    
    # Check if file should be kept
    if grep -Fxq "$clean_file" "$KEEP_LIST_FILE"; then
        log "KEEPING: $clean_file"
        ((KEPT_COUNT++))
    else
        log "REMOVING: $clean_file (not referenced in TEST_PLAN.md)"
        rm -f "$file"
        ((REMOVED_COUNT++))
    fi
done

# Clean up empty directories (but keep the main directory structure)
find . -type d -empty -not -path "." -delete 2>/dev/null || true

# Clean up temporary file
rm -f "$KEEP_LIST_FILE"

# Count files after cleanup
TOTAL_FILES_AFTER=$(find . -type f | wc -l)

log "=== CLEANUP SUMMARY ==="
log "Files before cleanup: $TOTAL_FILES_BEFORE"
log "Files after cleanup: $TOTAL_FILES_AFTER"
log "Files kept: $KEPT_COUNT"
log "Files removed: $REMOVED_COUNT"
log "Space efficiency: Reduced by $REMOVED_COUNT files"

log "=== UX Snapshots Cleanup Complete ==="

echo "SUCCESS: Cleaned up UX Snapshots directory"
echo "Kept $KEPT_COUNT files, removed $REMOVED_COUNT files"
echo "See log for details: $LOG_FILE"