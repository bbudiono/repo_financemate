#!/bin/bash

echo "🔧 Fixing Apple Sign-In Entitlements Configuration"
echo "================================================="

PROJECT_DIR="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
cd "$PROJECT_DIR"

echo "🔍 Diagnosed Issue: Entitlements file not being applied during build"
echo "   • Configured: FinanceMate.entitlements contains Apple Sign-In capability ✅"
echo "   • Applied: Build process only applying get-task-allow ❌"
echo ""

echo "🛠️  SOLUTION 1: Clean Build and Reset"
echo "1. Clean Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/FinanceMate-*
echo "   ✅ Derived data cleared"

echo ""
echo "2. Clean build artifacts..."
xcodebuild clean -project FinanceMate.xcodeproj -scheme FinanceMate > /dev/null 2>&1
echo "   ✅ Build artifacts cleaned"

echo ""
echo "🛠️  SOLUTION 2: Verify Xcode Project Entitlements Reference"
echo "3. Checking if entitlements file is properly referenced in project..."

# Check if entitlements file is referenced in project.pbxproj
if grep -q "FinanceMate.entitlements" FinanceMate.xcodeproj/project.pbxproj; then
    echo "   ✅ Entitlements file is referenced in project"
else
    echo "   ❌ Entitlements file is NOT referenced in project"
    echo "   🔧 This needs to be fixed in Xcode manually:"
    echo "      • Open FinanceMate.xcodeproj"
    echo "      • Select FinanceMate target"
    echo "      • Go to Build Settings → Code Signing Entitlements"
    echo "      • Set: FinanceMate/FinanceMate.entitlements"
fi

echo ""
echo "🛠️  SOLUTION 3: Build with Force Entitlements"
echo "4. Building with explicit entitlements..."

# Build with explicit entitlements reference
BUILD_RESULT=$(xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug CODE_SIGN_ENTITLEMENTS="FinanceMate/FinanceMate.entitlements" build 2>&1)
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    echo "   ✅ Build succeeded with explicit entitlements"
    
    # Check if Apple Sign-In entitlement was applied
    ENTITLEMENTS_FILE=$(find ~/Library/Developer/Xcode/DerivedData/FinanceMate-*/Build/Intermediates.noindex/FinanceMate.build/Debug/FinanceMate.build/ -name "FinanceMate.app.xcent" 2>/dev/null | head -1)
    
    if [ -f "$ENTITLEMENTS_FILE" ]; then
        if grep -q "applesignin" "$ENTITLEMENTS_FILE"; then
            echo "   ✅ Apple Sign-In entitlement successfully applied!"
            echo ""
            echo "🎯 APPLE SIGN-IN FIXED!"
            echo "   • Build completed with proper entitlements"
            echo "   • Apple Sign-In capability should now work"
            echo "   • Test by launching FinanceMate and trying Apple SSO"
        else
            echo "   ❌ Apple Sign-In entitlement still not applied"
            echo "   🚨 Manual Xcode configuration required"
        fi
        
        echo ""
        echo "📋 Applied Entitlements:"
        cat "$ENTITLEMENTS_FILE" | grep -A1 -B1 "apple"
    fi
else
    echo "   ❌ Build failed - checking error..."
    echo "$BUILD_RESULT" | grep -i "error\|failed" | head -5
fi

echo ""
echo "🧪 TESTING STEPS:"
echo "1. Launch FinanceMate application"
echo "2. Reset authentication state if needed: ./scripts/reset_auth_state.sh"
echo "3. Try Apple Sign-In button - should work without error"
echo "4. Try Google Sign-In button - should continue working"
echo ""

echo "🔧 IF STILL NOT WORKING:"
echo "1. Open FinanceMate.xcodeproj in Xcode"
echo "2. Select FinanceMate target → Build Settings"
echo "3. Search for 'Code Signing Entitlements'"
echo "4. Set value to: FinanceMate/FinanceMate.entitlements"
echo "5. Build and test again"
echo ""

echo "✅ Apple Sign-In entitlements fix attempt complete!"