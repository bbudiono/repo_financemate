#!/bin/bash

# Security Penetration Testing Script
# Created: 2025-06-25
# Purpose: Execute comprehensive security tests and generate evidence

echo "🔒 FINANCEMATE SECURITY PENETRATION TESTING"
echo "=============================================="
echo "Timestamp: $(date)"
echo ""

cd "_macOS/FinanceMate-Sandbox"

echo "🔍 Running Security Penetration Tests..."
echo ""

# Run the security tests
xcodebuild test \
    -project FinanceMate-Sandbox.xcodeproj \
    -scheme FinanceMate-Sandbox \
    -destination 'platform=macOS' \
    -only-testing:FinanceMate-SandboxTests/SecurityPenetrationTests 2>&1 | tee "../../temp/security_test_output.log"

echo ""
echo "📊 Security Test Results:"
echo "=========================="

# Check if security log files were created
if [ -f "../../temp/security_test_*.log" ]; then
    echo "✅ Security test logs generated:"
    ls -la "../../temp/security_test_"*.log
    echo ""
    echo "📋 Security Test Summary:"
    cat "../../temp/security_test_"*.log | grep -E "SUCCESS|FAILURE|VULNERABILITY"
else
    echo "⚠️ No security test logs found"
fi

echo ""
echo "🔒 Security Penetration Testing Complete"
echo "Review logs in /temp/ directory for detailed results"