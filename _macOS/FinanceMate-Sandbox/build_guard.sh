#!/bin/bash

# Build Guard Script - Enforces Architectural Standards
# This script MUST be run as part of the build process
# It will FAIL the build if architectural violations are detected

echo "🔍 Running Architecture Compliance Checks..."

# Check 1: No test files in application source
if [ -d "FinanceMate/Tests" ]; then
    echo "❌ CRITICAL VIOLATION: Test directory found in application source!"
    echo "   Location: FinanceMate/Tests/"
    echo "   All tests MUST be in FinanceMateTests/ target"
    exit 1
fi

# Check 2: No test files in wrong locations
TEST_FILES_IN_APP=$(find FinanceMate -name "*Test*.swift" -o -name "*Tests*.swift" | grep -v "FinanceMateTests")
if [ ! -z "$TEST_FILES_IN_APP" ]; then
    echo "❌ CRITICAL VIOLATION: Test files found in application source!"
    echo "   Files found:"
    echo "$TEST_FILES_IN_APP"
    echo "   All test files MUST be in FinanceMateTests/ target"
    exit 1
fi

# Check 3: Verify test target exists
if [ ! -d "FinanceMateTests" ]; then
    echo "❌ CRITICAL VIOLATION: Test target directory missing!"
    echo "   Expected: FinanceMateTests/"
    echo "   A proper test target is required for TDD"
    exit 1
fi

# Check 4: Verify tests exist
TEST_COUNT=$(find FinanceMateTests -name "*.swift" | wc -l | tr -d ' ')
if [ "$TEST_COUNT" -eq "0" ]; then
    echo "❌ WARNING: No test files found in test target!"
    echo "   This violates TDD principles"
    exit 1
fi

echo "✅ Architecture compliance checks passed"
echo "   Test files found in correct location: $TEST_COUNT"

# Run actual tests
echo "🧪 Running unit tests..."
xcodebuild test \
    -workspace ../FinanceMate.xcworkspace \
    -scheme FinanceMate \
    -destination 'platform=macOS' \
    -resultBundlePath test_results.xcresult \
    2>&1 | tee test_output.log

TEST_RESULT=${PIPESTATUS[0]}

if [ $TEST_RESULT -eq 0 ]; then
    echo "✅ All tests passed"
    
    # Generate coverage report
    echo "📊 Generating coverage report..."
    xcrun xccov view --report test_results.xcresult > coverage_report.txt
    
    # Extract coverage percentage
    COVERAGE=$(grep "Coverage:" coverage_report.txt | head -1 | awk '{print $2}')
    echo "   Code coverage: $COVERAGE"
    
    # Save test results
    cp test_output.log app_test_log.txt
    echo "   Test results saved to app_test_log.txt"
else
    echo "❌ Tests failed! Check test_output.log for details"
    exit 1
fi

echo "🎯 Build guard complete - All checks passed"