#!/bin/bash

# create_workspace.sh
#
# Purpose: Creates a shared Xcode workspace containing both production and sandbox projects.
# This script adheres to .cursorrules for project structure and naming conventions.

# --- Configuration - Derived from .cursorrules and BLUEPRINT.MD ---
PROJECT_NAME="DocketMate"
PLATFORM_DIR="_macOS"
PRODUCTION_APP_FOLDER_NAME="${PROJECT_NAME}"
SANDBOX_APP_FOLDER_NAME="${PROJECT_NAME}_Sandbox"
WORKSPACE_NAME="${PROJECT_NAME}.xcworkspace"

# Paths
PLATFORM_ROOT_PATH="${PLATFORM_DIR}"
WORKSPACE_PATH="${PLATFORM_ROOT_PATH}/${WORKSPACE_NAME}"
PRODUCTION_PROJECT_DIR="${PLATFORM_ROOT_PATH}/${PRODUCTION_APP_FOLDER_NAME}"
SANDBOX_PROJECT_DIR="${PLATFORM_ROOT_PATH}/${SANDBOX_APP_FOLDER_NAME}"
PRODUCTION_PROJECT_PATH="${PRODUCTION_PROJECT_DIR}/${PROJECT_NAME}.xcodeproj"
SANDBOX_PROJECT_PATH="${SANDBOX_PROJECT_DIR}/${PROJECT_NAME}_Sandbox.xcodeproj"

# Timestamp for logging
timestamp() {
  date +"[%Y-%m-%dT%H:%M:%S]"
}

echo "$(timestamp) Creating Xcode workspace: ${WORKSPACE_PATH}"

# Check if projects exist
if [ ! -d "${PRODUCTION_PROJECT_PATH}" ]; then
  echo "$(timestamp) Production project not found at ${PRODUCTION_PROJECT_PATH}"
  
  if [ ! -d "${PRODUCTION_PROJECT_DIR}" ]; then
    echo "$(timestamp) Production directory not found, will be created by the workspace"
  else
    echo "$(timestamp) Run create_buildable_swiftui_app.sh first to create the production project."
  fi
fi

if [ ! -d "${SANDBOX_PROJECT_PATH}" ]; then
  echo "$(timestamp) Sandbox project not found at ${SANDBOX_PROJECT_PATH}"
  
  if [ ! -d "${SANDBOX_PROJECT_DIR}" ]; then
    echo "$(timestamp) Sandbox directory not found, will be created by the workspace"
  else
    echo "$(timestamp) Run create_sandbox_swiftui_app.sh first to create the sandbox project."
  fi
fi

# Create workspace directory
mkdir -p "${WORKSPACE_PATH}/xcshareddata"

# Create workspace contents using relative paths
cat > "${WORKSPACE_PATH}/contents.xcworkspacedata" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:${PRODUCTION_APP_FOLDER_NAME}/${PROJECT_NAME}.xcodeproj">
   </FileRef>
   <FileRef
      location = "group:${SANDBOX_APP_FOLDER_NAME}/${PROJECT_NAME}_Sandbox.xcodeproj">
   </FileRef>
</Workspace>
EOF

# Create workspace settings
cat > "${WORKSPACE_PATH}/xcshareddata/IDEWorkspaceChecks.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEDidComputeMac32BitWarning</key>
	<true/>
</dict>
</plist>
EOF

echo "$(timestamp) Workspace created successfully at ${WORKSPACE_PATH}"
echo "$(timestamp) Workspace contains references to:"
echo "$(timestamp) - Production project: ${PRODUCTION_APP_FOLDER_NAME}/${PROJECT_NAME}.xcodeproj"
echo "$(timestamp) - Sandbox project: ${SANDBOX_APP_FOLDER_NAME}/${PROJECT_NAME}_Sandbox.xcodeproj" 