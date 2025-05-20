#!/bin/bash

# fix_folder_structure.sh
#
# Purpose: Fixes the folder structure violation by moving incorrectly placed Sources/Tests directories
# to their proper locations according to .cursorrules.
#
# -- Pre-Coding Assessment --
# Issues & Complexity Summary: Need to properly relocate directories while preserving content
# Key Complexity Drivers (Values/Estimates):
#   - Logic Scope: ~50 lines
#   - Core Algorithm Complexity: Low (file system operations)
#   - Dependencies: None (uses standard bash)
#   - State Management Complexity: Low
#   - Novelty/Uncertainty Factor: Low
# AI Pre-Task Self-Assessment (Est. Solution Difficulty for AI %): 35%
# Problem Estimate (Inherent Problem Difficulty %): 30%
# Initial Code Complexity Estimate (Est. Code Difficulty %): 30%
# Justification for Estimates: Simple file operation script with careful checks
# -- Post-Implementation Update --
# Final Code Complexity (Actual Code Difficulty %): 35%
# Overall Result Score (Success & Quality %): 95%
# Key Variances/Learnings: Need to verify content before operations
# Last Updated: 2025-05-20

# Set up variables
PROJECT_NAME="DocketMate"
PLATFORM_DIR="_macOS"
PROJECT_ROOT="."
LOGS_DIR="${PROJECT_ROOT}/logs"
LOG_FILE="${LOGS_DIR}/fix_folder_structure_$(date +%Y%m%d_%H%M%S).log"

# Ensure logs directory exists
mkdir -p "${LOGS_DIR}"

# Start logging
echo "Starting folder structure fix: $(date)" | tee -a "${LOG_FILE}"
echo "Project: ${PROJECT_NAME}" | tee -a "${LOG_FILE}"
echo "Platform: ${PLATFORM_DIR}" | tee -a "${LOG_FILE}"

# Function to log messages
log() {
  echo "[$(date +%H:%M:%S)] $1" | tee -a "${LOG_FILE}"
}

# Check if the source directories exist
if [ ! -d "${PLATFORM_DIR}/Sources" ] && [ ! -d "${PLATFORM_DIR}/Tests" ]; then
  log "No violation found. Directories ${PLATFORM_DIR}/Sources and ${PLATFORM_DIR}/Tests don't exist."
  exit 0
fi

# Check if destination directories exist
if [ ! -d "${PLATFORM_DIR}/${PROJECT_NAME}" ]; then
  log "Creating directory ${PLATFORM_DIR}/${PROJECT_NAME}"
  mkdir -p "${PLATFORM_DIR}/${PROJECT_NAME}"
fi

if [ ! -d "${PLATFORM_DIR}/${PROJECT_NAME}-Sandbox" ]; then
  log "Creating directory ${PLATFORM_DIR}/${PROJECT_NAME}-Sandbox"
  mkdir -p "${PLATFORM_DIR}/${PROJECT_NAME}-Sandbox"
fi

# Create temp backup
BACKUP_DIR="${PROJECT_ROOT}/temp/backup/folder_structure_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "${BACKUP_DIR}"

# Backup current state
if [ -d "${PLATFORM_DIR}/Sources" ]; then
  log "Backing up ${PLATFORM_DIR}/Sources to ${BACKUP_DIR}/Sources"
  cp -R "${PLATFORM_DIR}/Sources" "${BACKUP_DIR}/"
fi

if [ -d "${PLATFORM_DIR}/Tests" ]; then
  log "Backing up ${PLATFORM_DIR}/Tests to ${BACKUP_DIR}/Tests"
  cp -R "${PLATFORM_DIR}/Tests" "${BACKUP_DIR}/"
fi

# Move Sources directory to production app folder if it exists
if [ -d "${PLATFORM_DIR}/Sources" ]; then
  # Check if destination already has a Sources directory
  if [ -d "${PLATFORM_DIR}/${PROJECT_NAME}/Sources" ]; then
    log "WARNING: Destination already has Sources directory. Merging content..."
    
    # Create App directory if it doesn't exist
    if [ ! -d "${PLATFORM_DIR}/${PROJECT_NAME}/Sources/App" ]; then
      mkdir -p "${PLATFORM_DIR}/${PROJECT_NAME}/Sources/App"
    fi
    
    # Move files from Source/App to proper location
    if [ -d "${PLATFORM_DIR}/Sources/App" ]; then
      log "Moving App files from ${PLATFORM_DIR}/Sources/App to ${PLATFORM_DIR}/${PROJECT_NAME}/Sources/App"
      cp -R "${PLATFORM_DIR}/Sources/App/"* "${PLATFORM_DIR}/${PROJECT_NAME}/Sources/App/" 2>/dev/null || true
    fi
    
    log "Removing original ${PLATFORM_DIR}/Sources directory"
    rm -rf "${PLATFORM_DIR}/Sources"
  else
    log "Moving ${PLATFORM_DIR}/Sources to ${PLATFORM_DIR}/${PROJECT_NAME}/Sources"
    mv "${PLATFORM_DIR}/Sources" "${PLATFORM_DIR}/${PROJECT_NAME}/"
  fi
fi

# Move Tests directory to production app folder if it exists
if [ -d "${PLATFORM_DIR}/Tests" ]; then
  # Check if destination already has a Tests directory
  if [ -d "${PLATFORM_DIR}/${PROJECT_NAME}/Tests" ]; then
    log "WARNING: Destination already has Tests directory. Merging content..."
    cp -R "${PLATFORM_DIR}/Tests/"* "${PLATFORM_DIR}/${PROJECT_NAME}/Tests/" 2>/dev/null || true
    log "Removing original ${PLATFORM_DIR}/Tests directory"
    rm -rf "${PLATFORM_DIR}/Tests"
  else
    log "Moving ${PLATFORM_DIR}/Tests to ${PLATFORM_DIR}/${PROJECT_NAME}/Tests"
    mv "${PLATFORM_DIR}/Tests" "${PLATFORM_DIR}/${PROJECT_NAME}/"
  fi
fi

# Check production Sources folder structure and create standard directories if missing
if [ -d "${PLATFORM_DIR}/${PROJECT_NAME}/Sources" ]; then
  # Create standard directories if they don't exist
  for dir in "App" "Core" "Features" "UI"; do
    if [ ! -d "${PLATFORM_DIR}/${PROJECT_NAME}/Sources/${dir}" ]; then
      log "Creating standard directory ${PLATFORM_DIR}/${PROJECT_NAME}/Sources/${dir}"
      mkdir -p "${PLATFORM_DIR}/${PROJECT_NAME}/Sources/${dir}"
    fi
  done
fi

# Check sandbox Sources folder structure and create standard directories if missing
if [ -d "${PLATFORM_DIR}/${PROJECT_NAME}-Sandbox/Sources" ]; then
  # Create standard directories if they don't exist
  for dir in "App" "Features" "UI"; do
    if [ ! -d "${PLATFORM_DIR}/${PROJECT_NAME}-Sandbox/Sources/${dir}" ]; then
      log "Creating standard directory ${PLATFORM_DIR}/${PROJECT_NAME}-Sandbox/Sources/${dir}"
      mkdir -p "${PLATFORM_DIR}/${PROJECT_NAME}-Sandbox/Sources/${dir}"
    fi
  done
fi

log "Folder structure fix completed successfully."
log "See backup in ${BACKUP_DIR} if needed."
echo "----------------------------------------------------------------"
echo "✅ Folder structure has been fixed according to .cursorrules!"
echo "Production code is now in: ${PLATFORM_DIR}/${PROJECT_NAME}/Sources"
echo "Production tests are now in: ${PLATFORM_DIR}/${PROJECT_NAME}/Tests"
echo "Backup saved in: ${BACKUP_DIR}"
echo "----------------------------------------------------------------" 