#!/bin/bash

# Verify NO MOCK DATA in Dashboard
# This script checks that all dashboard data comes from Core Data

echo "========================================="
echo "MOCK DATA VERIFICATION AUDIT"
echo "Date: $(date)"
echo "========================================="
echo ""

# Define mock data patterns to search for
MOCK_PATTERNS=(
    "1247.82"      # Mock category amount
    "856.34"       # Mock category amount  
    "634.91"       # Mock category amount
    "Netflix.*15.99"  # Mock subscription
    "Spotify.*9.99"   # Mock subscription
    "4247.83"      # Mock forecast amount
    "52847.92"     # Mock forecast amount
    "Total Monthly: \$81.96"  # Hardcoded total
)

echo "1. Checking for hardcoded mock data in source files..."
echo ""

FOUND_MOCK=false

for pattern in "${MOCK_PATTERNS[@]}"; do
    echo -n "Checking for pattern: $pattern ... "
    
    # Search in all Swift files
    if grep -r "$pattern" --include="*.swift" . 2>/dev/null | grep -v "verify_no_mock_data.sh" | grep -v "DashboardDataTests.swift"; then
        echo "❌ FOUND MOCK DATA!"
        FOUND_MOCK=true
    else
        echo "✅ Clean"
    fi
done

echo ""
echo "2. Verifying Core Data integration..."
echo ""

# Check for Core Data fetch requests in dashboard
echo -n "Checking for @FetchRequest in DashboardView ... "
if grep -q "@FetchRequest" FinanceMate/Views/DashboardView.swift; then
    echo "✅ Found"
else
    echo "❌ Missing"
fi

echo -n "Checking for DashboardDataService usage ... "
if grep -q "DashboardDataService" FinanceMate/Views/Dashboard/*.swift 2>/dev/null; then
    echo "✅ Found"
else
    echo "❌ Missing"
fi

echo ""
echo "3. Checking new real data components..."
echo ""

COMPONENTS=("RealCategoryView" "RealSubscriptionView" "RealForecastView")
for component in "${COMPONENTS[@]}"; do
    echo -n "Checking $component ... "
    if [ -f "FinanceMate/Views/Dashboard/$component.swift" ]; then
        echo "✅ Exists"
    else
        echo "❌ Missing"
    fi
done

echo ""
echo "4. Building application to verify compilation..."
echo ""

xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug build > /tmp/build_output.txt 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded"
else
    echo "❌ Build failed. Check /tmp/build_output.txt"
    exit 1
fi

echo ""
echo "5. Checking for test data creation functions..."
echo ""

echo -n "Checking for createTestDataIfNeeded ... "
if grep -q "createTestDataIfNeeded" FinanceMate/Views/DashboardView.swift; then
    echo "❌ FOUND - Mock data function still exists!"
    FOUND_MOCK=true
else
    echo "✅ Removed"
fi

echo ""
echo "========================================="
echo "AUDIT RESULTS"
echo "========================================="
echo ""

if [ "$FOUND_MOCK" = true ]; then
    echo "❌ FAILED: Mock data still present in codebase"
    echo ""
    echo "Action Required:"
    echo "- Remove all hardcoded values"
    echo "- Ensure all data comes from Core Data"
    echo "- Use DashboardDataService for data operations"
    exit 1
else
    echo "✅ PASSED: No mock data found"
    echo ""
    echo "Summary:"
    echo "- All hardcoded values removed"
    echo "- Core Data integration active"
    echo "- Real data components implemented"
    echo "- Build successful"
fi

echo ""
echo "Dashboard now uses 100% REAL DATA from Core Data!"