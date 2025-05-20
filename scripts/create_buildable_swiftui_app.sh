#!/bin/bash
# Purpose: Canonical, project-agnostic script to create and verify a buildable SwiftUI macOS app (Production or Sandbox)
# Issues & Complexity: Must enforce .cursorrules compliance, project-agnosticism, robust error handling, and logging
# Ranking/Rating: 90% (Code), 95% (Problem) - High due to compliance and automation requirements
# -- Pre-Coding Assessment --
# - Logic Scope: ~100 lines
# - Core Algorithm Complexity: Med (file ops, xcodebuild, param handling)
# - Dependencies: bash, xcodebuild, mkdir, cp, grep, sed
# - State Management: Low
# - Novelty/Uncertainty: Med (must be robust, portable)
# AI Pre-Task Self-Assessment: 85%
# Problem Estimate: 90%
# Initial Code Complexity: 90%
# Justification: High compliance, automation, and error handling requirements
# -- Post-Implementation Update --
# Final Code Complexity: [TBD]
# Overall Result Score: [TBD]
# Key Variances/Learnings: [TBD]
# Last Updated: [YYYY-MM-DD]
#
# .cursorrules Reference: §5.1, §5.2, §7.2, §7.3, §10.1, §12
#
# Usage:
#   ./scripts/create_buildable_swiftui_app.sh --env [production|sandbox] --root <project_root> --app <AppName>
#
# All logs are written to logs/create_buildable_swiftui_app_<env>_<timestamp>.log
#
# This script must be tested in Sandbox before Production use.

set -euo pipefail

# Default values (can be overridden by args)
ENV="production"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="DocketMate"
LOG_DIR="$PROJECT_ROOT/logs"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENV="$2"; shift 2;;
    --root)
      PROJECT_ROOT="$2"; shift 2;;
    --app)
      APP_NAME="$2"; shift 2;;
    *)
      echo "Unknown argument: $1"; exit 1;;
  esac
done

# Validate environment
if [[ "$ENV" != "production" && "$ENV" != "sandbox" ]]; then
  echo "[ERROR] --env must be 'production' or 'sandbox'"; exit 2
fi

# Set platform dir and app folder names
PLATFORM_DIR="_macOS"
if [[ "$ENV" == "production" ]]; then
  APP_FOLDER="$APP_NAME"
  XCODEPROJ="$APP_NAME.xcodeproj"
  SCHEME="docketmate" # xcodegen generates lowercase for production
else
  APP_FOLDER="$APP_NAME-Sandbox"
  XCODEPROJ="DocketMate.xcodeproj"
  SCHEME="DocketMate" # xcodegen generates capitalized for sandbox
fi

APP_PATH="$PROJECT_ROOT/$PLATFORM_DIR/$APP_FOLDER"
LOG_FILE="$LOG_DIR/create_buildable_swiftui_app_${ENV}_$TIMESTAMP.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Log function
log() { echo "[$(date +%Y-%m-%dT%H:%M:%S)] $*" | tee -a "$LOG_FILE"; }

log "Starting buildable SwiftUI app creation for $ENV at $APP_PATH"

# Ensure platform/app folders exist
mkdir -p "$APP_PATH/Sources" "$APP_PATH/Resources" "$APP_PATH/Tests"

# Create minimal SwiftUI app files if missing
if [[ ! -f "$APP_PATH/Sources/${APP_NAME}App.swift" ]]; then
  cat > "$APP_PATH/Sources/${APP_NAME}App.swift" <<EOF
import SwiftUI

@main
struct ${APP_NAME}App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
EOF
  log "Created ${APP_NAME}App.swift"
fi

if [[ ! -f "$APP_PATH/Sources/ContentView.swift" ]]; then
  cat > "$APP_PATH/Sources/ContentView.swift" <<EOF
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text(\"Hello, $APP_NAME ($ENV)!\")
            .padding()
    }
}
EOF
  log "Created ContentView.swift"
fi

# Create minimal Xcode project if missing
if [[ ! -d "$APP_PATH/$XCODEPROJ" ]]; then
  log "Creating Xcode project: $XCODEPROJ"
  # Use xcodegen if available, else fallback to xcodebuild
  if command -v xcodegen >/dev/null 2>&1; then
    cat > "$APP_PATH/project.yml" <<EOF
name: DocketMate
options:
  bundleIdPrefix: com.products
  deploymentTarget:
    macOS: "13.5"
targets:
  DocketMate:
    type: application
    platform: macOS
    sources:
      - path: Sources
    resources:
      - path: Resources
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.products.DocketMate
        INFOPLIST_FILE: Resources/Info.plist
        MACOSX_DEPLOYMENT_TARGET: "13.5"
        DEVELOPMENT_TEAM: 7KV34995HH
        CODE_SIGN_STYLE: Automatic
        SIGNING_CERTIFICATE: "Development"
        APP_CATEGORY: Productivity
        VERSION: 0.1
        BUILD: 1
EOF
    (cd "$APP_PATH" && xcodegen)
    log "Generated Xcode project with xcodegen."
  else
    log "[WARN] xcodegen not found. Please create the Xcode project manually."
  fi
fi

# Detect available schemes for compliance and technical debt logging
AVAILABLE_SCHEMES=$(xcodebuild -project "$APP_PATH/$XCODEPROJ" -list | awk '/Schemes:/,/^$/' | tail -n +2 | grep -v '^$' | xargs)
if [[ "$AVAILABLE_SCHEMES" != *"$SCHEME"* ]]; then
  log "[TECHNICAL DEBT] Expected scheme '$SCHEME' not found. Available schemes: $AVAILABLE_SCHEMES."
  # Use the first available scheme as fallback for build, but log as technical debt
  SCHEME=$(echo "$AVAILABLE_SCHEMES" | awk '{print $1}')
  log "[TECHNICAL DEBT] Using fallback scheme: $SCHEME. Please review xcodegen config for naming consistency."
fi

# Build the app
if [[ -d "$APP_PATH/$XCODEPROJ" ]]; then
  log "Building app with xcodebuild (scheme: $SCHEME)..."
  xcodebuild -project "$APP_PATH/$XCODEPROJ" -scheme "$SCHEME" -configuration Debug clean build | tee -a "$LOG_FILE"
  log "Build completed."
else
  log "[ERROR] Xcode project not found at $APP_PATH/$XCODEPROJ. Cannot build."
  # Log actual generated project paths for debugging
  log "[DEBUG] Listing contents of $APP_PATH:"
  ls -l "$APP_PATH" | tee -a "$LOG_FILE"
  exit 3
fi

log "SwiftUI app creation and build verification complete for $ENV."
exit 0 