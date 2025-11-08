#!/bin/bash
# Capture comprehensive merchant extraction diagnostics from NSLog output
# This script runs the app in headless mode and captures all extraction logs
# to analyze the complete flow: GmailEmail → extractMerchant() → normalizeDisplayName() → MerchantDatabase

set -e

PROJECT_DIR="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
LOG_FILE="/tmp/financemate_extraction_diagnostics_$(date +%Y%m%d_%H%M%S).log"

echo "🔍 FinanceMate Merchant Extraction Diagnostics"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This script will:"
echo "1. Build FinanceMate in Debug mode"
echo "2. Launch the app and trigger Gmail sync"
echo "3. Capture ALL NSLog output from merchant extraction"
echo "4. Analyze the complete extraction flow"
echo ""
echo "Output will be saved to: $LOG_FILE"
echo ""

# Build the app in Debug mode (NSLog enabled)
echo "Building FinanceMate (Debug mode)..."
cd "$PROJECT_DIR"
xcodebuild -project FinanceMate.xcodeproj \
    -scheme FinanceMate \
    -configuration Debug \
    clean build \
    > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful"
echo ""
echo "🚀 Launching FinanceMate..."
echo "   The app will open and trigger Gmail sync automatically"
echo "   All extraction logs will be captured to: $LOG_FILE"
echo ""
echo "   Press Ctrl+C when Gmail sync is complete to stop logging"
echo ""

# Launch the app and capture NSLog output
# NSLog writes to system.log which we can capture with 'log stream'
open -a "$PROJECT_DIR/build/Debug/FinanceMate.app" &
APP_PID=$!

# Wait for app to launch
sleep 2

# Stream logs with filtering for our specific log tags
log stream --predicate 'processImagePath CONTAINS "FinanceMate"' --level debug 2>&1 | \
    grep -E '\[MERCHANT-EXTRACT\]|\[NORMALIZE\]|\[TIER1-EXTRACT\]|\[TIER1-FAIL\]|\[EXTRACT-' | \
    tee "$LOG_FILE"

# When Ctrl+C is pressed, this will execute
trap "echo ''; echo 'Diagnostic capture stopped.'; echo 'Log saved to: $LOG_FILE'; kill $APP_PID 2>/dev/null; exit 0" INT

wait
