#!/bin/bash

# Define the absolute path for artifacts, consistent with ScreenshotService.swift
ARTIFACTS_DIR="$HOME/Documents/test_artifacts"
LOG_FILE="$(pwd)/e2e_test_output.log"
RESULT_BUNDLE_PATH="$(pwd)/e2e_test_results.xcresult"

echo "🚀 Running E2E Tests with Visual Evidence"
echo "========================================"
echo "Artifacts will be saved to: $ARTIFACTS_DIR"

# Clean previous run and create artifacts directory
rm -rf "$ARTIFACTS_DIR"
rm -f "$LOG_FILE"
rm -rf "$RESULT_BUNDLE_PATH"
mkdir -p "$ARTIFACTS_DIR"

# Build the app first
echo "📦 Building FinanceMate..."
xcodebuild build \
    -workspace ../FinanceMate.xcworkspace \
    -scheme FinanceMate \
    -destination 'platform=macOS' \
    -quiet

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful"

# Run the E2E tests with the CORRECT target syntax
# The format is 'TestTarget/TestClass'
echo "🧪 Running E2E Authentication Tests..."
xcodebuild test \
    -workspace ../FinanceMate.xcworkspace \
    -scheme FinanceMate \
    -destination 'platform=macOS' \
    -only-testing:FinanceMateTests/AuthenticationE2ETests \
    -resultBundlePath "$RESULT_BUNDLE_PATH" \
    2>&1 | tee "$LOG_FILE"

TEST_RESULT=${PIPESTATUS[0]}

# Check results
echo ""
echo "📊 Test Results:"
echo "=================="

if [ $TEST_RESULT -eq 0 ]; then
    echo "✅ E2E Tests PASSED"
else
    echo "❌ E2E Tests FAILED"
    echo "See logs for details: $LOG_FILE"
fi

# Check for screenshots in the correct directory
echo ""
echo "📸 Screenshot Evidence:"
echo "======================"

# Look for the specific success screenshot
SUCCESS_SCREENSHOT="$ARTIFACTS_DIR/E2E_Auth_Success_Dashboard.png"

if [ -f "$SUCCESS_SCREENSHOT" ]; then
    echo "✅ SUCCESS: '$SUCCESS_SCREENSHOT' captured."
    ls -l "$ARTIFACTS_DIR"
else
    echo "❌ FAILURE: Success screenshot was not found."
    echo "Listing contents of artifacts directory (if any):"
    ls -l "$ARTIFACTS_DIR"
fi

echo ""
echo "📁 Test artifacts saved to: $ARTIFACTS_DIR"
echo "📋 Test logs saved to: $LOG_FILE"

exit $TEST_RESULT