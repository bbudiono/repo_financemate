#!/bin/bash
# Test Gmail OAuth with console output capture

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEST_DIR="../test_output/debug_$TIMESTAMP"
mkdir -p "$TEST_DIR"

echo "============================================"
echo "GMAIL OAUTH DEBUG TEST"
echo "============================================"
echo "Test dir: $TEST_DIR"

# Kill existing
pkill -f "FinanceMate.app" || true
sleep 2

# Launch app and capture console in background
APP="/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app"

echo "Launching app..."
"$APP/Contents/MacOS/FinanceMate" 2>&1 | tee "$TEST_DIR/console_output.txt" &
APP_PID=$!

echo "App PID: $APP_PID"
echo "Console output being captured to: $TEST_DIR/console_output.txt"

sleep 5

echo ""
echo "App should be running. Check console output:"
echo ""
cat "$TEST_DIR/console_output.txt"

echo ""
echo "============================================"
echo "NEXT STEPS"
echo "============================================"
echo "1. Click Gmail Receipts tab"
echo "2. Click Connect Gmail button"
echo "3. Check if error appears"
echo ""
echo "Console output continues in: $TEST_DIR/console_output.txt"
echo "App PID: $APP_PID (use 'kill $APP_PID' to stop)"
