#!/bin/bash
# Capture merchant extraction diagnostics

echo "=== MERCHANT EXTRACTION DIAGNOSTICS ==="
echo "Starting diagnostic capture..."
echo ""

# Kill existing app
killall FinanceMate 2>/dev/null
sleep 2

# Start Console.app log streaming in background
log stream --predicate 'process == "FinanceMate"' --level info > /tmp/financemate_extraction.log 2>&1 &
LOG_PID=$!

echo "✓ Started log capture (PID: $LOG_PID)"

# Copy .env
cd "$(dirname "$0")/.."
bash copy_env_to_bundle.sh

# Launch app
echo "✓ Launching FinanceMate..."
open /Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-*/Build/Products/Debug/FinanceMate.app

echo ""
echo "MANUAL STEPS:"
echo "1. Wait for app to load (~5 seconds)"
echo "2. Go to Gmail tab"
echo "3. Click 'Extract & Refresh Emails' button"
echo "4. Wait for extraction to complete"
echo "5. Press ENTER here when done"
echo ""
read -p "Press ENTER after extraction completes..."

# Stop log capture
kill $LOG_PID 2>/dev/null

# Analyze logs
echo ""
echo "=== EXTRACTION LOG ANALYSIS ==="
echo ""

# Show merchant extraction logs
echo "MERCHANT EXTRACTIONS (first 20):"
grep "\[TIER1-EXTRACT\]\|\[MERCHANT-EXTRACT\]" /tmp/financemate_extraction.log | head -20

echo ""
echo "MERCHANT MISMATCHES (Bunnings false positives):"
grep -i "bunnings" /tmp/financemate_extraction.log | grep -v "bunnings.com\|bunnings warehouse" | head -10

echo ""
echo "TIER 1 FAILURES:"
grep "\[TIER1-FAIL\]" /tmp/financemate_extraction.log | head -10

echo ""
echo "=== FULL LOG SAVED TO: /tmp/financemate_extraction.log ==="
echo "Review complete log for detailed analysis"
