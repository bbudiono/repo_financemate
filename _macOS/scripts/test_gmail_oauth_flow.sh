#!/bin/bash
# Test Gmail OAuth flow by launching the app

echo "============================================================"
echo "TESTING GMAIL OAUTH FLOW"
echo "============================================================"

# Get app path
APP_PATH="/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found at: $APP_PATH"
    echo "   Please build the app first"
    exit 1
fi

echo "✅ Found app at: $APP_PATH"
echo ""

# Create test output directory
TEST_OUTPUT="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/test_output"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SCREENSHOT_DIR="$TEST_OUTPUT/gmail_oauth_test_$TIMESTAMP"
mkdir -p "$SCREENSHOT_DIR"

echo "📸 Screenshots will be saved to: $SCREENSHOT_DIR"
echo ""

# Launch the app in background
echo "🚀 Launching FinanceMate app..."
open "$APP_PATH" 2>&1 &
APP_PID=$!

# Wait for app to start
sleep 3

# Take initial screenshot
echo "📸 Capturing initial app state..."
screencapture -x -D 1 "$SCREENSHOT_DIR/01_app_launch.png" 2>/dev/null

# Get console output (last 50 lines)
echo "📋 Checking console logs..."
log show --predicate 'process == "FinanceMate"' --info --last 1m > "$SCREENSHOT_DIR/console_log.txt" 2>&1

# Check if OAuth credentials loaded
if grep -q "OAuth credentials loaded successfully" "$SCREENSHOT_DIR/console_log.txt" 2>/dev/null; then
    echo "✅ OAuth credentials loaded successfully"
else
    echo "⚠️  OAuth credentials may not be loaded"
fi

# Wait a bit for user to interact (simulating Gmail tab click)
echo ""
echo "ℹ️  App is running. To test Gmail OAuth:"
echo "   1. Click on the 'Gmail Receipts' tab"
echo "   2. Click 'Connect Gmail' button"
echo "   3. Check if browser opens with OAuth URL"
echo ""
echo "Waiting 10 seconds for testing..."
sleep 10

# Take final screenshot
echo "📸 Capturing final state..."
screencapture -x -D 1 "$SCREENSHOT_DIR/02_gmail_tab.png" 2>/dev/null

# Check for OAuth URL generation in logs
echo ""
echo "============================================================"
echo "RESULTS"
echo "============================================================"

# Count screenshots
SCREENSHOT_COUNT=$(ls -1 "$SCREENSHOT_DIR"/*.png 2>/dev/null | wc -l)
echo "📸 Screenshots captured: $SCREENSHOT_COUNT"

# Check console for OAuth activity
if grep -q "Connect Gmail button clicked" "$SCREENSHOT_DIR/console_log.txt" 2>/dev/null; then
    echo "✅ Gmail button click detected"

    if grep -q "Opening OAuth URL" "$SCREENSHOT_DIR/console_log.txt" 2>/dev/null; then
        echo "✅ OAuth URL generated successfully"
        grep "Opening OAuth URL" "$SCREENSHOT_DIR/console_log.txt" | head -1
    else
        echo "❌ OAuth URL not generated"
    fi
else
    echo "ℹ️  Gmail button not clicked yet"
fi

# Summary
echo ""
echo "============================================================"
echo "TEST ARTIFACTS"
echo "============================================================"
echo "📁 Test output: $SCREENSHOT_DIR"
echo "   • Screenshots: $(ls -1 "$SCREENSHOT_DIR"/*.png 2>/dev/null | wc -l) files"
echo "   • Console log: console_log.txt"
echo ""
echo "✅ OAuth flow test complete. Check screenshots for visual validation."

# Note: App continues running for manual testing
echo ""
echo "ℹ️  App is still running for manual testing."
echo "   To close: Quit from menu or press Cmd+Q in the app"

exit 0