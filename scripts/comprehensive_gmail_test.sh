#!/bin/bash
# Comprehensive Gmail transaction extraction test

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEST_DIR="../test_output/comprehensive_$TIMESTAMP"
mkdir -p "$TEST_DIR"

echo "=========================================="
echo "COMPREHENSIVE GMAIL EXTRACTION TEST"
echo "=========================================="
echo "Test directory: $TEST_DIR"

# Kill existing app
pkill -f "FinanceMate.app" || true
sleep 2

# Build fresh
cd "../_macOS"
echo "Building app..."
xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug build > "$TEST_DIR/build.log" 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded"
else
    echo "❌ Build failed"
    exit 1
fi

# Launch app
APP="/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app"
echo "Launching app..."
open "$APP"
sleep 6

screencapture -x "$TEST_DIR/01_launched.png"
echo "Screenshot 1: Launched"

echo ""
echo "=========================================="
echo "MANUAL TEST STEPS"
echo "=========================================="
echo "1. Click 'Gmail Receipts' tab"
echo "2. Wait for emails to load (you should already be authenticated)"
echo "3. Review the extracted transaction details:"
echo "   - Do you see email subject?"
echo "   - Do you see email sender?"
echo "   - Do you see GST amount?"
echo "   - Do you see line items?"
echo "4. Click 'Create Transaction' button"
echo "5. Open Console.app → Filter 'FinanceMate' → Look for:"
echo "   '=== CREATE TRANSACTION BUTTON CLICKED ==='"
echo "6. Go to Transactions tab - does new transaction appear?"
echo ""
echo "Waiting 40 seconds for comprehensive testing..."
sleep 20

screencapture -x "$TEST_DIR/02_gmail_tab.png"
echo "Screenshot 2: Gmail tab state"

sleep 20

screencapture -x "$TEST_DIR/03_transactions_tab.png"
echo "Screenshot 3: Transactions tab"

sleep 3
screencapture -x "$TEST_DIR/04_final.png"
echo "Screenshot 4: Final state"

echo ""
echo "=========================================="
echo "TEST COMPLETE"
echo "=========================================="
echo "Evidence: $TEST_DIR"
echo "Screenshots: 4 files"
echo ""
echo "Please report:"
echo "1. Do extracted transactions show comprehensive details?"
echo "2. Does Create Transaction button work? (Check Console.app)"
echo "3. Does transaction appear in Transactions tab?"
