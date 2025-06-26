#!/bin/bash

# E2E Test Runner Script
# This script runs the E2E tests and captures screenshots

set -e

echo "🚀 Starting E2E Test Execution"
echo "=============================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create directories
echo "📁 Creating test directories..."
mkdir -p test_artifacts
mkdir -p test_reports

# Clean previous artifacts
echo "🧹 Cleaning previous artifacts..."
rm -f test_artifacts/*.png
rm -f test_reports/*.log

# Build the project first
echo -e "\n${YELLOW}📦 Building FinanceMate project...${NC}"
xcodebuild build \
    -project FinanceMate.xcodeproj \
    -scheme FinanceMate \
    -destination 'platform=macOS' \
    -derivedDataPath build/ \
    | tee test_reports/build.log

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build succeeded${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# Run the XCUITests specifically for E2E
echo -e "\n${YELLOW}🧪 Running E2E XCUITests...${NC}"
xcodebuild test \
    -project FinanceMate.xcodeproj \
    -scheme FinanceMate \
    -destination 'platform=macOS' \
    -only-testing:FinanceMateUITests/AuthenticationE2ETests \
    -resultBundlePath test_reports/results.xcresult \
    -derivedDataPath build/ \
    2>&1 | tee test_reports/test_output.log

TEST_RESULT=$?

# Extract screenshots from test results
echo -e "\n${YELLOW}📸 Extracting screenshots...${NC}"

# Find screenshots in DerivedData
find build/Logs/Test -name "*.png" -type f 2>/dev/null | while read screenshot; do
    filename=$(basename "$screenshot")
    cp "$screenshot" "test_artifacts/$filename"
    echo "  - Copied: $filename"
done

# Also check for screenshots in the xcresult bundle
if [ -d "test_reports/results.xcresult" ]; then
    # Extract attachments from xcresult
    xcrun xcresulttool get --path test_reports/results.xcresult --format json > test_reports/results.json
    
    # Use xcresulttool to export attachments
    xcrun xcresulttool export --type file \
        --path test_reports/results.xcresult \
        --output-path test_artifacts \
        --id "$(xcrun xcresulttool get --path test_reports/results.xcresult --format json | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)" \
        2>/dev/null || true
fi

# Count screenshots
SCREENSHOT_COUNT=$(find test_artifacts -name "*.png" -type f 2>/dev/null | wc -l | tr -d ' ')

echo -e "\n${YELLOW}📊 Test Summary${NC}"
echo "=================="

if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${RED}❌ Some tests failed${NC}"
fi

echo "📸 Screenshots captured: $SCREENSHOT_COUNT"
echo "📁 Test artifacts saved to: test_artifacts/"
echo "📄 Test logs saved to: test_reports/"

# Generate summary report
cat > test_reports/summary.md << EOF
# E2E Test Execution Summary

**Date:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Status:** $([ $TEST_RESULT -eq 0 ] && echo "✅ Passed" || echo "❌ Failed")

## Screenshots Captured

Total screenshots: $SCREENSHOT_COUNT

### Screenshot List:
EOF

# List all screenshots
find test_artifacts -name "*.png" -type f 2>/dev/null | while read screenshot; do
    echo "- $(basename "$screenshot")" >> test_reports/summary.md
done

echo -e "\n✅ E2E test execution complete!"

# If running in CI, set output
if [ -n "$GITHUB_ACTIONS" ]; then
    echo "::set-output name=screenshot_count::$SCREENSHOT_COUNT"
    echo "::set-output name=test_result::$TEST_RESULT"
fi

exit $TEST_RESULT