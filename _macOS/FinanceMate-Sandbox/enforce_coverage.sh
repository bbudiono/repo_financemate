#!/bin/bash

# AUDIT-2024JUL02-QUALITY-GATE: Coverage Enforcement Script
# Purpose: Block builds that don't meet 80% coverage requirements
# Usage: ./enforce_coverage.sh

set -euo pipefail

echo "🔍 AUDIT-2024JUL02-QUALITY-GATE: Coverage Enforcement Starting..."

# Configuration
REQUIRED_COVERAGE=80
ANALYSIS_SCRIPT="docs/coverage_reports/comprehensive_coverage_analysis.py"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Ensure we're in the right directory
if [[ ! -f "FinanceMate.xcodeproj/project.pbxproj" ]]; then
    echo "❌ ERROR: Must run from FinanceMate-Sandbox directory"
    exit 1
fi

# Check if analysis script exists
if [[ ! -f "$ANALYSIS_SCRIPT" ]]; then
    echo "❌ ERROR: Coverage analysis script not found: $ANALYSIS_SCRIPT"
    echo "🔧 Run comprehensive coverage analysis first"
    exit 1
fi

echo "📊 Running comprehensive coverage analysis..."

# Run the coverage analysis
python3 "$ANALYSIS_SCRIPT"
ANALYSIS_EXIT_CODE=$?

echo ""
echo "📋 Coverage Analysis Results:"

if [[ $ANALYSIS_EXIT_CODE -eq 0 ]]; then
    echo "✅ QUALITY GATE PASSED"
    echo "   All critical files meet ${REQUIRED_COVERAGE}%+ coverage requirement"
    echo "   Build may proceed with deployment"
    echo ""
    echo "🎯 Coverage Status: COMPLIANT"
    echo "🚀 Release Status: APPROVED"
    exit 0
else
    echo "❌ QUALITY GATE FAILED"
    echo "   One or more critical files below ${REQUIRED_COVERAGE}% coverage requirement"
    echo "   Build BLOCKED until coverage requirements are met"
    echo ""
    echo "🚫 Coverage Status: NON-COMPLIANT"
    echo "⛔ Release Status: BLOCKED"
    echo ""
    echo "📋 Required Actions:"
    echo "   1. Review coverage report in docs/coverage_reports/"
    echo "   2. Implement missing tests for failing files"
    echo "   3. Re-run build after achieving ${REQUIRED_COVERAGE}%+ coverage"
    echo "   4. Consult QUALITY_GATE_REMEDIATION_PLAN.md for guidance"
    echo ""
    echo "📄 Key Reports:"
    echo "   • docs/coverage_reports/AUDIT_COVERAGE_FINAL_REPORT.md"
    echo "   • docs/coverage_reports/QUALITY_GATE_REMEDIATION_PLAN.md"
    echo "   • docs/coverage_reports/comprehensive_coverage_$(date +%Y%m%d)*.md"
    exit 1
fi
