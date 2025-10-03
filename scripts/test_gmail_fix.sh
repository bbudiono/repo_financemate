#!/bin/bash
# Test Gmail OAuth fix

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEST_DIR="../test_output/gmail_fix_$TIMESTAMP"
mkdir -p "$TEST_DIR"

echo "Test dir: $TEST_DIR"

# Kill existing instance
pkill -f "FinanceMate.app" || true
sleep 1

# Launch app
APP="/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app"
open "$APP" &
sleep 4

# Screenshot 1
screencapture -x "$TEST_DIR/01_launched.png"
echo "Screenshot 1: Launched"

# Check startup logs
log show --predicate 'process == "FinanceMate"' --info --last 30s > "$TEST_DIR/startup.log" 2>&1

if grep -q "Credentials stored in memory" "$TEST_DIR/startup.log"; then
    echo "✅ Credentials loaded"
else
    echo "⚠️ Credentials not detected in logs"
fi

echo ""
echo "MANUAL: Click Gmail tab → Connect Gmail button"
echo "Waiting 20 seconds..."
sleep 20

# Screenshot 2
screencapture -x "$TEST_DIR/02_after_click.png"
echo "Screenshot 2: After click"

# Check logs after click
log show --predicate 'process == "FinanceMate"' --info --last 1m > "$TEST_DIR/after_click.log" 2>&1

if grep -q "Connect Gmail button clicked" "$TEST_DIR/after_click.log"; then
    echo "✅ Button clicked"

    if grep -q "Opening OAuth URL" "$TEST_DIR/after_click.log"; then
        echo "✅ OAuth URL generated"
        grep "Opening OAuth URL" "$TEST_DIR/after_click.log" | head -1
    fi
fi

# Final screenshot
sleep 2
screencapture -x "$TEST_DIR/03_final.png"

echo ""
echo "✅ Test complete"
echo "Evidence: $TEST_DIR"
