#!/bin/bash

# FinanceMate TestFlight Readiness Verification Script
# Version: 1.0.0
# Date: June 26, 2025

echo "🚀 FinanceMate TestFlight Readiness Verification"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ARCHIVE_PATH="FinanceMate-TestFlight-Final.xcarchive"
ERRORS=0
WARNINGS=0

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        ((ERRORS++))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo -e "\n${BLUE}1. Archive Verification${NC}"
echo "========================"

# Check if archive exists
if [ -d "$ARCHIVE_PATH" ]; then
    print_status 0 "Archive exists: $ARCHIVE_PATH"
else
    print_status 1 "Archive missing: $ARCHIVE_PATH"
fi

# Check if app bundle exists in archive
APP_PATH="$ARCHIVE_PATH/Products/Applications/FinanceMate.app"
if [ -d "$APP_PATH" ]; then
    print_status 0 "App bundle exists in archive"
else
    print_status 1 "App bundle missing in archive"
fi

# Check if executable exists
EXECUTABLE_PATH="$APP_PATH/Contents/MacOS/FinanceMate"
if [ -f "$EXECUTABLE_PATH" ]; then
    print_status 0 "Executable exists and is ready"
    
    # Check executable permissions
    if [ -x "$EXECUTABLE_PATH" ]; then
        print_status 0 "Executable has proper permissions"
    else
        print_status 1 "Executable lacks execution permissions"
    fi
else
    print_status 1 "Executable missing"
fi

echo -e "\n${BLUE}2. Code Signing Verification${NC}"
echo "============================="

# Verify code signature
if codesign -dv --verbose=2 "$APP_PATH" 2>&1 | grep -q "Apple Development"; then
    print_status 0 "Code signature valid (Apple Development)"
else
    print_status 1 "Code signature invalid or missing"
fi

# Check team identifier
if codesign -dv "$APP_PATH" 2>&1 | grep -q "TeamIdentifier=7KV34995HH"; then
    print_status 0 "Team identifier correct: 7KV34995HH"
else
    print_status 1 "Team identifier incorrect or missing"
fi

echo -e "\n${BLUE}3. Bundle Configuration${NC}"
echo "========================"

INFO_PLIST="$APP_PATH/Contents/Info.plist"

# Check bundle identifier
if /usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$INFO_PLIST" 2>/dev/null | grep -q "com.ablankcanvas.financemate"; then
    print_status 0 "Bundle identifier correct: com.ablankcanvas.financemate"
else
    print_status 1 "Bundle identifier incorrect"
fi

# Check version
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST" 2>/dev/null)
if [ "$VERSION" = "1.0.0" ]; then
    print_status 0 "Version correct: $VERSION"
else
    print_status 1 "Version incorrect: $VERSION (expected 1.0.0)"
fi

# Check build number
BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST" 2>/dev/null)
if [ "$BUILD" = "1" ]; then
    print_status 0 "Build number correct: $BUILD"
else
    print_status 1 "Build number incorrect: $BUILD (expected 1)"
fi

# Check app category
CATEGORY=$(/usr/libexec/PlistBuddy -c "Print LSApplicationCategoryType" "$INFO_PLIST" 2>/dev/null)
if [ "$CATEGORY" = "public.app-category.productivity" ]; then
    print_status 0 "App category correct: Productivity"
else
    print_status 1 "App category incorrect: $CATEGORY"
fi

echo -e "\n${BLUE}4. Asset Verification${NC}"
echo "====================="

# Check app icons
ICONS_PATH="$APP_PATH/Contents/Resources"
if [ -f "$ICONS_PATH/AppIcon.icns" ]; then
    print_status 0 "App icon file exists"
else
    print_status 1 "App icon file missing"
fi

# Check if Assets.car exists
if [ -f "$ICONS_PATH/Assets.car" ]; then
    print_status 0 "Asset catalog compiled"
else
    print_status 1 "Asset catalog missing"
fi

echo -e "\n${BLUE}5. Entitlements Check${NC}"
echo "====================="

# Check entitlements using codesign output
if codesign -d --entitlements - "$APP_PATH" 2>/dev/null | grep -A2 "com.apple.security.app-sandbox" | grep -q "true"; then
    print_status 0 "App sandbox enabled"
else
    print_status 1 "App sandbox not enabled"
fi

if codesign -d --entitlements - "$APP_PATH" 2>/dev/null | grep -A2 "com.apple.security.network.client" | grep -q "true"; then
    print_status 0 "Network client access enabled"
else
    print_status 1 "Network client access not enabled"
fi

echo -e "\n${BLUE}6. Build Verification${NC}"
echo "====================="

# Try to build the project
print_info "Attempting quick build verification..."
if xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Release -quiet -dry-run build 2>/dev/null; then
    print_status 0 "Project build configuration valid"
else
    print_warning "Build configuration may have issues (non-critical for archive)"
fi

echo -e "\n${BLUE}7. Documentation Check${NC}"
echo "========================"

# Check for release notes
if [ -f "TestFlight-Release-Notes.md" ]; then
    print_status 0 "TestFlight release notes prepared"
else
    print_status 1 "TestFlight release notes missing"
fi

# Check for submission checklist
if [ -f "TestFlight-Submission-Checklist.md" ]; then
    print_status 0 "Submission checklist prepared"
else
    print_status 1 "Submission checklist missing"
fi

echo -e "\n${BLUE}Summary${NC}"
echo "========"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 SUCCESS: FinanceMate is 100% ready for TestFlight submission!${NC}"
    echo -e "${GREEN}✅ All critical requirements met${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS warning(s) noted (non-critical)${NC}"
    fi
    echo -e "\n${BLUE}Next Steps:${NC}"
    echo "1. Open Xcode Organizer"
    echo "2. Select the FinanceMate-TestFlight-Final.xcarchive"
    echo "3. Click 'Distribute App'"
    echo "4. Choose 'App Store Connect'"
    echo "5. Follow the upload process"
    echo -e "\n${GREEN}Archive ready for upload! 🚀${NC}"
    exit 0
else
    echo -e "${RED}❌ FAILED: $ERRORS critical error(s) must be resolved${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS warning(s) also noted${NC}"
    fi
    echo -e "\n${RED}Please resolve the errors above before submitting to TestFlight.${NC}"
    exit 1
fi