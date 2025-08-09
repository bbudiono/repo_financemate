#!/bin/bash

# Continuous Testing Script for FinanceMate
# Purpose: Run lightweight, non-disruptive unit tests continuously during development
# Focus: Unit tests only, skip UI tests that interrupt development

set -e

PROJECT_DIR="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
PROJECT_NAME="FinanceMate"

echo "🧪 FinanceMate Continuous Testing"
echo "================================="
echo "Running lightweight unit tests only (no XCUITest interruptions)"
echo

cd "$PROJECT_DIR"

# Function to run specific test class
run_test_class() {
    local test_class=$1
    echo "🔬 Testing: $test_class"
    
    if xcodebuild test \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$PROJECT_NAME" \
        -destination 'platform=macOS' \
        -only-testing:"${PROJECT_NAME}Tests/$test_class" \
        -quiet > /dev/null 2>&1; then
        echo "✅ $test_class PASSED"
        return 0
    else
        echo "❌ $test_class FAILED"
        return 1
    fi
}

# Function to run all unit tests (excluding UI tests)
run_unit_tests() {
    echo "🚀 Running Core Unit Tests (TDD Focus)"
    echo "-------------------------------------"
    
    # Core Data Tests
    run_test_class "CoreDataTests"
    
    # ViewModel Tests (MVVM Business Logic)
    run_test_class "DashboardViewModelTests" 
    run_test_class "FinancialGoalViewModelTests"
    run_test_class "FinancialEntityViewModelTests"
    
    echo
    echo "📊 Unit Test Summary Complete"
    echo "All critical business logic validated ✅"
}

# Function to validate build without full test suite
validate_build() {
    echo "🔨 Build Validation"
    echo "------------------"
    
    if xcodebuild build \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$PROJECT_NAME" \
        -destination 'platform=macOS' \
        -quiet > /dev/null 2>&1; then
        echo "✅ Build SUCCESSFUL"
        return 0
    else
        echo "❌ Build FAILED"
        return 1
    fi
}

# Main execution
main() {
    echo "⏰ $(date '+%Y-%m-%d %H:%M:%S') - Starting continuous testing cycle"
    echo
    
    # Quick build validation
    if ! validate_build; then
        echo "🚫 Build failed - fix compilation errors first"
        exit 1
    fi
    
    # Run lightweight unit tests
    run_unit_tests
    
    echo
    echo "🎉 Continuous testing cycle complete!"
    echo "💡 Development-friendly: No UI test interruptions"
    echo "🔄 Re-run this script after code changes"
}

# Execute main function
main "$@"