#!/bin/bash
# Simple Gmail OAuth validation script
# Tests that the Gmail OAuth button works and opens browser

set -e

echo "========================================"
echo "GMAIL OAUTH VALIDATION"
echo "========================================"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="../test_output/gmail_validation_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

cd "$(dirname "$0")/../_macOS"

# Build the app
echo "Building app..."
xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug build > "$OUTPUT_DIR/build.log" 2>&1

if [ $? -eq 0 ]; then
    echo "Build: PASS"
else
    echo "Build: FAIL"
    exit 1
fi

# Launch app
APP_PATH="/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app"

echo "Launching app..."
open "$APP_PATH" &
sleep 3

# Take screenshot
screencapture -x "$OUTPUT_DIR/app_running.png"
echo "Screenshot captured"

# Check logs for OAuth credentials
log show --predicate 'process == "FinanceMate"' --info --last 30s > "$OUTPUT_DIR/console.log" 2>&1

if grep -q "OAuth credentials loaded successfully" "$OUTPUT_DIR/console.log"; then
    echo "OAuth Credentials: PASS"
else
    echo "OAuth Credentials: FAIL (not loaded)"
fi

echo ""
echo "Manual test required:"
echo "1. Click 'Gmail Receipts' tab"
echo "2. Click 'Connect Gmail' button"
echo "3. Verify browser opens with Google OAuth"
echo ""
echo "App is running. Press Cmd+Q to quit when done."
echo "Evidence saved to: $OUTPUT_DIR"
