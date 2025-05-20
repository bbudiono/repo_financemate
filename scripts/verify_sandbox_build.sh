#!/bin/bash

# verify_sandbox_build.sh
#
# Purpose: Verifies the sandbox build of the DocketMate project.
# This script adheres to .cursorrules for project structure and naming conventions.
#
# Outputs:
#   - Exits with 0 on successful build.
#   - Exits with a non-zero status code on build failure and prints error messages.

# --- Configuration - Derived from .cursorrules and BLUEPRINT.MD ---
PROJECT_NAME="DocketMate"
# .cursorrules 5.1.1: Platform-specific root (e.g., _macOS/)
PLATFORM_DIR="_macOS" # Assuming macOS as per rule 1.13 (PLATFORM PRIORITY)
# .cursorrules 5.1.1: Sandbox App Folder
SANDBOX_APP_FOLDER_NAME="${PROJECT_NAME}_Sandbox"
# .cursorrules 5.1.1 & 5.1.2: Sandbox Xcode project file
SANDBOX_PROJECT_NAME="${PROJECT_NAME}_Sandbox.xcodeproj"
# .cursorrules 5.1.1: SHARED Xcode Workspace
WORKSPACE_NAME="${PROJECT_NAME}.xcworkspace"
# .cursorrules 1.2: Blueprint defines project root. Assuming script is run from project root.
PROJECT_ROOT="."

# --- Paths ---
# Path to the _macOS directory
PLATFORM_ROOT_PATH="${PROJECT_ROOT}/${PLATFORM_DIR}"
# Path to the sandbox project directory
SANDBOX_PROJECT_DIR_PATH="${PLATFORM_ROOT_PATH}/${SANDBOX_APP_FOLDER_NAME}"
# Path to the sandbox .xcodeproj file
SANDBOX_XCODEPROJ_PATH="${SANDBOX_PROJECT_DIR_PATH}/${SANDBOX_PROJECT_NAME}"
# Path to the shared .xcworkspace file
WORKSPACE_PATH="${PLATFORM_ROOT_PATH}/${WORKSPACE_NAME}"

# Sandbox scheme name (obtained from xcodebuild -list output)
SANDBOX_SCHEME_NAME="DocketMate_Sandbox"  # Consistent with folder name

# Log file for build output
BUILD_LOG_FILE="${PROJECT_ROOT}/logs/sandbox_build_verify.log"
mkdir -p "${PROJECT_ROOT}/logs" # Ensure logs directory exists

echo "--- Starting Sandbox Build Verification for ${PROJECT_NAME} ---"
echo "Timestamp: $(date)"
echo "Project Root: $(pwd)"
echo "Platform Directory: ${PLATFORM_ROOT_PATH}"
echo "Sandbox Project Directory: ${SANDBOX_PROJECT_DIR_PATH}"
echo "Sandbox Xcode Project: ${SANDBOX_XCODEPROJ_PATH}"
echo "Workspace: ${WORKSPACE_PATH}"
echo "Sandbox Scheme: ${SANDBOX_SCHEME_NAME}"
echo "Build Log: ${BUILD_LOG_FILE}"
echo "---------------------------------------------------------"

# --- Validation ---
if [ ! -d "${PLATFORM_ROOT_PATH}" ]; then
  echo "ERROR: Platform directory '${PLATFORM_ROOT_PATH}' not found. Ensure you are in the project root and the directory exists." >&2
  exit 1
fi

if [ ! -d "${SANDBOX_PROJECT_DIR_PATH}" ]; then
  echo "ERROR: Sandbox project directory '${SANDBOX_PROJECT_DIR_PATH}' not found." >&2
  exit 1
fi

if [ ! -e "${WORKSPACE_PATH}" ]; then
  echo "ERROR: Workspace '${WORKSPACE_PATH}' not found." >&2
  exit 1
fi

echo "All required paths seem to exist. Proceeding with build..."
echo "---------------------------------------------------------"

# --- Build Commands ---
# Clean the build
echo "Attempting to clean the workspace..."
xcodebuild clean \
  -workspace "${WORKSPACE_PATH}" \
  -scheme "${SANDBOX_SCHEME_NAME}" \
  -configuration Debug \
  ARCHS=x86_64 \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  > "${BUILD_LOG_FILE}" 2>&1

# Check log for successful clean instead of relying on exit code
if ! grep -q "CLEAN SUCCEEDED" "${BUILD_LOG_FILE}"; then
  echo "ERROR: Xcode clean failed for workspace '${WORKSPACE_PATH}' and scheme '${SANDBOX_SCHEME_NAME}'." >&2
  echo "Please check the log for details: ${BUILD_LOG_FILE}" >&2
  cat "${BUILD_LOG_FILE}" >&2
  exit 2
fi
echo "Clean successful."

# Build the project
echo "Attempting to build the workspace..."
xcodebuild build \
  -workspace "${WORKSPACE_PATH}" \
  -scheme "${SANDBOX_SCHEME_NAME}" \
  -configuration Debug \
  ARCHS=x86_64 \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  >> "${BUILD_LOG_FILE}" 2>&1 # Append to log

# Check log for successful build instead of relying on exit code
if grep -q "BUILD SUCCEEDED" "${BUILD_LOG_FILE}"; then
  echo "---------------------------------------------------------"
  echo "✅ Sandbox Build Verification Successful for ${PROJECT_NAME}!"
  echo "---------------------------------------------------------"
  exit 0
else
  echo "ERROR: Xcode build failed for workspace '${WORKSPACE_PATH}' and scheme '${SANDBOX_SCHEME_NAME}'." >&2
  echo "Please check the log for details: ${BUILD_LOG_FILE}" >&2
  cat "${BUILD_LOG_FILE}" >&2
  exit 3
fi 