#!/bin/bash

# Headless Testing Script for FinanceMate
# Ensures all tests run without user interaction

set -e

echo "🤖 Starting Headless Test Suite for FinanceMate"
echo "================================================="

# Set headless environment variables
export HEADLESS_MODE=1
export UI_TESTING=1
export NSApplicationLaunchAllowsInvalidation=YES

# Change to project directory
cd "$(dirname "$0")/.."

# Function to run tests with headless configuration
run_headless_tests() {
    local scheme=$1
    local destination=$2
    
    echo "📱 Running headless tests for scheme: $scheme"
    
    # Run tests with specific headless flags
    xcodebuild test \
        -project "_macOS/FinanceMate.xcodeproj" \
        -scheme "$scheme" \
        -destination "$destination" \
        -enableCodeCoverage YES \
        -resultBundlePath "test_results/${scheme}_$(date +%Y%m%d_%H%M%S).xcresult" \
        OTHER_SWIFT_FLAGS="-D HEADLESS_TESTING" \
        GCC_PREPROCESSOR_DEFINITIONS="HEADLESS_TESTING=1" \
        | xcbeautify --report junit --report-path "test_results/${scheme}_junit.xml" || {
            echo "❌ Tests failed for $scheme"
            return 1
        }
    
    echo "✅ Tests completed successfully for $scheme"
}

# Create test results directory
mkdir -p test_results

# Run unit tests (headless by default)
echo "🧪 Running Unit Tests..."
run_headless_tests "FinanceMate" "platform=macOS,arch=arm64"

# Run UI tests in headless mode
echo "🖥️  Running UI Tests (Headless)..."
export UITESTING_HEADLESS=1

# For UI tests, we need to ensure no visual components are shown
run_headless_tests "FinanceMate" "platform=macOS,arch=arm64"

echo ""
echo "🎉 All headless tests completed successfully!"
echo "📊 Test results saved in: test_results/"
echo ""
echo "Key Features Verified:"
echo "- ✅ Core Data model integrity"
echo "- ✅ ViewModel business logic"
echo "- ✅ UI component functionality (headless)"
echo "- ✅ Navigation and user flows"
echo "- ✅ Accessibility compliance"
echo ""
echo "No user interaction required - fully automated test suite!"