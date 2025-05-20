#!/bin/bash

# create_sandbox_swiftui_app.sh
#
# Purpose: Creates a buildable SwiftUI app for sandbox testing environment.
# This script adheres to .cursorrules for project structure and naming conventions.

# --- Configuration - Derived from .cursorrules and BLUEPRINT.MD ---
PROJECT_NAME="DocketMate"
PLATFORM_DIR="_macOS"
SANDBOX_APP_FOLDER_NAME="${PROJECT_NAME}_Sandbox"
SANDBOX_DIR="${PLATFORM_DIR}/${SANDBOX_APP_FOLDER_NAME}"

# Create sandbox directory structure
mkdir -p ${SANDBOX_DIR}/Sources
mkdir -p ${SANDBOX_DIR}/Resources

# Timestamp for logging
timestamp() {
  date +"[%Y-%m-%dT%H:%M:%S]"
}

echo "$(timestamp) Starting buildable SwiftUI app creation for sandbox at $SANDBOX_DIR"

# Create base SwiftUI files if they don't exist yet
if [ ! -f "${SANDBOX_DIR}/Sources/DocketMateApp.swift" ]; then
  cat > "${SANDBOX_DIR}/Sources/DocketMateApp.swift" << EOF
import SwiftUI

@main
struct DocketMate_SandboxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
EOF
  echo "$(timestamp) Created DocketMateApp.swift"
fi

if [ ! -f "${SANDBOX_DIR}/Sources/ContentView.swift" ]; then
  cat > "${SANDBOX_DIR}/Sources/ContentView.swift" << EOF
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, DocketMate (sandbox)!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
EOF
  echo "$(timestamp) Created ContentView.swift"
fi

# Create Info.plist if it doesn't exist
if [ ! -f "${SANDBOX_DIR}/Resources/Info.plist" ]; then
  cat > "${SANDBOX_DIR}/Resources/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025. All rights reserved.</string>
</dict>
</plist>
EOF
  echo "$(timestamp) Created Info.plist"
fi

# Generate Xcode project using xcodegen
echo "$(timestamp) Creating Xcode project: ${PROJECT_NAME}_Sandbox.xcodeproj"

# Create project.yml for xcodegen
cat > "${SANDBOX_DIR}/project.yml" << EOF
name: ${PROJECT_NAME}_Sandbox
options:
  bundleIdPrefix: com.products
  deploymentTarget:
    macOS: 13.5
targets:
  ${PROJECT_NAME}_Sandbox:
    type: application
    platform: macOS
    sources: Sources
    info:
      path: Resources/Info.plist
      properties:
        CFBundleDisplayName: ${PROJECT_NAME} Sandbox
        LSApplicationCategoryType: public.app-category.productivity
EOF

# Run xcodegen
cd "${SANDBOX_DIR}" && xcodegen generate

echo "$(timestamp) Generated Xcode project with xcodegen."

# Get the absolute path to the project
PROJECT_ABS_PATH="$(cd "${SANDBOX_DIR}" && pwd)/${PROJECT_NAME}_Sandbox.xcodeproj"

# Check for build scheme
SCHEME="${PROJECT_NAME}_Sandbox"
AVAILABLE_SCHEMES=$(xcodebuild -project "${PROJECT_ABS_PATH}" -list 2>/dev/null | grep -A 10 "Schemes:" | tail -n +2 | sed 's/^ *//')

if [[ -z "${AVAILABLE_SCHEMES}" ]]; then
  echo "$(timestamp) [TECHNICAL DEBT] No schemes found in project."
  echo "$(timestamp) Skipping build verification."
  exit 0
fi

if [[ ! $AVAILABLE_SCHEMES =~ $SCHEME ]]; then
  echo "$(timestamp) [TECHNICAL DEBT] Expected scheme '${SCHEME}' not found. Available schemes: ${AVAILABLE_SCHEMES}."
  SCHEME=$(echo $AVAILABLE_SCHEMES | head -n 1)
  echo "$(timestamp) [TECHNICAL DEBT] Using fallback scheme: ${SCHEME}. Please review xcodegen config for naming consistency."
fi

# Build the app
echo "$(timestamp) Building app with xcodebuild (scheme: ${SCHEME})..."
cd "${SANDBOX_DIR}" && xcodebuild -project "${PROJECT_NAME}_Sandbox.xcodeproj" -scheme "${SCHEME}" -configuration Debug clean build

if [ $? -eq 0 ]; then
  echo "$(timestamp) Build successful."
  echo "$(timestamp) Sandbox SwiftUI app creation and build verification complete."
else
  echo "$(timestamp) Build failed. Please check the output above for errors."
  exit 1
fi 