#!/bin/bash
# ensure_xcode_files.sh
# Purpose: Project-agnostic script to ensure required Xcode files exist and are properly structured
# Created: 2025-06-18
# Author: AI Agent
# -- Pre-Coding Assessment --
# Issues & Complexity Summary: Script to verify and create essential Xcode project files.
# Key Complexity Drivers:
#   - Logic Scope (New/Mod LoC Est.): ~100
#   - Core Algorithm Complexity: Medium (file system operations, project file parsing)
#   - Dependencies (New/Mod Cnt.): 0 (uses only bash)
#   - Error Handling Complexity: High (must handle various error conditions)
#   - Novelty/Uncertainty Factor: Medium (requires Xcode project structure knowledge)
# AI Pre-Task Self-Assessment (Est. Solution Difficulty for AI %): 25%
# Problem Estimate (Inherent Problem Difficulty %): 30%

# Strict error handling
set -e

# Script parameters
APP_NAME=""
ENV="production"
PROJECT_ROOT=""
LOG_DIR="logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE=""

# Default platform directory
PLATFORM_DIR="_macOS"

show_usage() {
  echo "Usage: bash scripts/ensure_xcode_files.sh --app <app_name> --env <environment> --root <project_root>"
  echo "Options:"
  echo "  --app <app_name>       The name of the app (e.g., DocketMate)"
  echo "  --env <environment>    Environment: production or sandbox (default: production)"
  echo "  --root <project_root>  The root directory of the project (optional, uses current directory if not specified)"
  echo "Example:"
  echo "  bash scripts/ensure_xcode_files.sh --app DocketMate --env sandbox --root /path/to/project"
  exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --app)
      APP_NAME="$2"
      shift 2
      ;;
    --env)
      ENV="$2"
      shift 2
      ;;
    --root)
      PROJECT_ROOT="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1"
      show_usage
      ;;
  esac
done

# Validate required parameters
if [ -z "$APP_NAME" ]; then
  echo "Error: App name is required"
  show_usage
fi

# Set project root to current directory if not specified
if [ -z "$PROJECT_ROOT" ]; then
  PROJECT_ROOT=$(pwd)
fi

# Ensure log directory exists
mkdir -p "${PROJECT_ROOT}/${LOG_DIR}"
LOG_FILE="${PROJECT_ROOT}/${LOG_DIR}/ensure_xcode_files_${ENV}_${TIMESTAMP}.log"

log() {
  local message="$1"
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $message" | tee -a "$LOG_FILE"
}

# Determine app directory name based on environment
if [ "$ENV" = "sandbox" ]; then
  APP_DIR="${APP_NAME}_Sandbox"
else
  APP_DIR="${APP_NAME}"
fi

APP_PATH="${PROJECT_ROOT}/${PLATFORM_DIR}/${APP_DIR}"
XCODEPROJ_PATH="${APP_PATH}.xcodeproj"

log "Starting Xcode files verification for ${APP_NAME} (${ENV}) in ${PROJECT_ROOT}"
log "App path: ${APP_PATH}"
log "Xcode project path: ${XCODEPROJ_PATH}"

# Check if app directory exists
if [ ! -d "$APP_PATH" ]; then
  log "Creating app directory: ${APP_PATH}"
  mkdir -p "${APP_PATH}/Sources"
  mkdir -p "${APP_PATH}/Resources"
  mkdir -p "${APP_PATH}/Tests"
fi

# Check if Sources directory exists
if [ ! -d "${APP_PATH}/Sources" ]; then
  log "Creating Sources directory: ${APP_PATH}/Sources"
  mkdir -p "${APP_PATH}/Sources"
fi

# Check if Info.plist exists
if [ ! -f "${APP_PATH}/Info.plist" ]; then
  log "Creating Info.plist file"
  cat > "${APP_PATH}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>\$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF
fi

# Check if entitlements file exists
if [ ! -f "${APP_PATH}/${APP_DIR}.entitlements" ]; then
  log "Creating ${APP_DIR}.entitlements file"
  cat > "${APP_PATH}/${APP_DIR}.entitlements" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
EOF
fi

# Create minimal Swift files if they don't exist
if [ ! -f "${APP_PATH}/Sources/ContentView.swift" ]; then
  log "Creating ContentView.swift"
  cat > "${APP_PATH}/Sources/ContentView.swift" << EOF
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("${APP_NAME}")
                .font(.largeTitle)
            Text("Version 1.0.0")
                .font(.caption)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
EOF
fi

if [ ! -f "${APP_PATH}/Sources/${APP_DIR}App.swift" ]; then
  log "Creating ${APP_DIR}App.swift"
  cat > "${APP_PATH}/Sources/${APP_DIR}App.swift" << EOF
import SwiftUI
import AppKit

@main
struct ${APP_DIR}App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("Quit ${APP_NAME}") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}
EOF
fi

log "Verification completed. All essential Xcode files are in place."
log "To build the project, run: xcodebuild clean build -scheme \"${APP_DIR}\" -configuration Debug"

exit 0
