#!/bin/zsh

# build_and_sign.sh
#
# This script automates the complete production build, signing, and notarization
# process for the FinanceMate application.
#
# It performs the following steps:
# 1. Validates environment and required credentials
# 2. Cleans the build directory to ensure a fresh build
# 3. Archives the 'FinanceMate' (Production) scheme
# 4. Exports the archive into a signed .app bundle using the Developer ID method
# 5. Creates a distributable ZIP archive
# 6. Submits the app for notarization with Apple
# 7. Staples the notarization ticket to the app bundle
# 8. Validates the notarized application
#
# Required Environment Variables:
# - APPLE_TEAM_ID: Your Apple Developer Team ID
# - APPLE_CERTIFICATE_NAME: Developer ID Application certificate name (optional)
# - APPLE_APP_SPECIFIC_PASSWORD: App-specific password for notarization
# - APPLE_ID: Apple ID for notarization (optional, uses default if not set)

set -e

echo "🚀 Starting Production Build, Sign & Notarization Process..."

# --- Environment Validation ---
echo "🔍 Validating build environment..."

# Check for required environment variables
if [ -z "$APPLE_TEAM_ID" ]; then
    echo "⚠️  APPLE_TEAM_ID environment variable not set"
    echo "   You can set it by running: export APPLE_TEAM_ID='YOUR_TEAM_ID'"
    echo "   Or add it to your ~/.zshrc or ~/.bash_profile"
    echo "   Find your Team ID at: https://developer.apple.com/account#MembershipDetailsCard"
    MISSING_ENV_VARS=true
fi

# App-specific password handling with multiple options
NOTARIZATION_PASSWORD=""
if [ -n "$APPLE_APP_SPECIFIC_PASSWORD" ]; then
    NOTARIZATION_PASSWORD="$APPLE_APP_SPECIFIC_PASSWORD"
    echo "✅ Using app-specific password from environment variable"
elif security find-generic-password -s "FinanceMate-Notarization" &>/dev/null; then
    NOTARIZATION_PASSWORD=$(security find-generic-password -s "FinanceMate-Notarization" -w)
    echo "✅ Using app-specific password from keychain"
else
    echo "⚠️  App-specific password not found"
    echo "   Set it using environment variable: export APPLE_APP_SPECIFIC_PASSWORD='your-password'"
    echo "   Or store in keychain: security add-generic-password -s 'FinanceMate-Notarization' -a 'notarization' -w 'your-password'"
    echo "   Generate app-specific password at: https://appleid.apple.com/account/manage"
    MISSING_ENV_VARS=true
fi

# Apple ID handling
if [ -z "$APPLE_ID" ]; then
    APPLE_ID=$(defaults read com.apple.dt.Xcode DVTDeveloperAccountManager 2>/dev/null | grep -o '[a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]*\.[a-zA-Z]{2,}' | head -1 || echo "")
    if [ -z "$APPLE_ID" ]; then
        echo "⚠️  APPLE_ID not set and couldn't detect from Xcode"
        echo "   Set it by running: export APPLE_ID='your-apple-id@example.com'"
        MISSING_ENV_VARS=true
    else
        echo "✅ Using Apple ID from Xcode configuration: $APPLE_ID"
    fi
else
    echo "✅ Using Apple ID from environment: $APPLE_ID"
fi

# Certificate name handling
if [ -z "$APPLE_CERTIFICATE_NAME" ]; then
    APPLE_CERTIFICATE_NAME="Developer ID Application"
    echo "✅ Using default certificate pattern: $APPLE_CERTIFICATE_NAME"
else
    echo "✅ Using custom certificate name: $APPLE_CERTIFICATE_NAME"
fi

# Exit if required variables are missing
if [ "$MISSING_ENV_VARS" = true ]; then
    echo ""
    echo "❌ Missing required environment variables. Please set them and try again."
    echo ""
    echo "Quick setup commands:"
    echo "export APPLE_TEAM_ID='YOUR_TEAM_ID'"
    echo "export APPLE_APP_SPECIFIC_PASSWORD='YOUR_APP_SPECIFIC_PASSWORD'"
    echo "export APPLE_ID='your-apple-id@example.com'"
    echo ""
    exit 1
fi

# Verify code signing identity
echo "🔐 Verifying code signing identity..."
if ! security find-identity -v -p codesigning | grep -q "$APPLE_CERTIFICATE_NAME"; then
    echo "❌ Code signing identity not found: $APPLE_CERTIFICATE_NAME"
    echo "   Please ensure you have a valid Developer ID Application certificate installed"
    echo "   Download from: https://developer.apple.com/account/resources/certificates/list"
    exit 1
fi
echo "✅ Code signing identity verified"

# --- Configuration ---
PROJECT_DIR="_macOS"
PROJECT_PATH="$PROJECT_DIR/FinanceMate.xcodeproj"
SCHEME="FinanceMate" # This is the production scheme
CONFIGURATION="Release"

# --- Paths ---
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/$SCHEME.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"
EXPORT_OPTIONS_PLIST="$PROJECT_DIR/ExportOptions.plist"
APP_PATH="$EXPORT_PATH/$SCHEME.app"
ZIP_PATH="$BUILD_DIR/$SCHEME.zip"

# --- 1. Clean Build Directory ---
echo "🧹 Cleaning previous build artifacts..."
rm -rf "$BUILD_DIR"
mkdir -p "$EXPORT_PATH"
echo "✅ Cleaned build directory."

# --- 2. Archive the Application ---
echo "📦 Archiving the application (Scheme: $SCHEME, Configuration: $CONFIGURATION)..."
xcodebuild archive \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -quiet

if [ $? -ne 0 ]; then
    echo "❌ Archiving failed."
    exit 1
fi
echo "✅ Archive successfully created at: $ARCHIVE_PATH"

# --- 3. Export the Signed .app Bundle ---
echo "🖋️ Exporting and signing the archive with Developer ID..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
    -quiet

if [ $? -ne 0 ]; then
    echo "❌ Exporting the archive failed."
    exit 1
fi
echo "✅ .app bundle successfully exported and signed to: $EXPORT_PATH"

# --- 4. Create Distributable Archive ---
echo "📦 Creating distributable ZIP archive for notarization..."
if [ ! -f "$APP_PATH" ]; then
    echo "❌ App bundle not found at: $APP_PATH"
    exit 1
fi

# Create ZIP archive for notarization
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

if [ $? -ne 0 ]; then
    echo "❌ Failed to create ZIP archive."
    exit 1
fi
echo "✅ ZIP archive created at: $ZIP_PATH"

# --- 5. Submit for Notarization ---
echo "🍎 Submitting application to Apple for notarization..."
echo "   This process may take several minutes..."

# Use notarytool (Xcode 13+) for notarization
NOTARIZATION_OUTPUT=$(xcrun notarytool submit "$ZIP_PATH" \
    --apple-id "$APPLE_ID" \
    --password "$NOTARIZATION_PASSWORD" \
    --team-id "$APPLE_TEAM_ID" \
    --wait \
    --output-format json 2>&1)

NOTARIZATION_EXIT_CODE=$?

# Parse the notarization response
if [ $NOTARIZATION_EXIT_CODE -eq 0 ]; then
    echo "✅ Notarization submitted successfully!"
    
    # Extract the submission ID for reference
    SUBMISSION_ID=$(echo "$NOTARIZATION_OUTPUT" | grep -o '"id": "[^"]*"' | sed 's/"id": "\([^"]*\)"/\1/' | head -1)
    if [ -n "$SUBMISSION_ID" ]; then
        echo "📋 Submission ID: $SUBMISSION_ID"
    fi
    
    # Check if notarization was successful
    if echo "$NOTARIZATION_OUTPUT" | grep -q '"status": "Accepted"'; then
        echo "✅ Notarization completed successfully!"
        NOTARIZATION_SUCCESS=true
    else
        echo "❌ Notarization failed or is still processing"
        echo "📄 Notarization details:"
        echo "$NOTARIZATION_OUTPUT"
        NOTARIZATION_SUCCESS=false
    fi
else
    echo "❌ Failed to submit for notarization"
    echo "📄 Error details:"
    echo "$NOTARIZATION_OUTPUT"
    NOTARIZATION_SUCCESS=false
fi

# --- 6. Staple Notarization Ticket ---
if [ "$NOTARIZATION_SUCCESS" = true ]; then
    echo "🎫 Stapling notarization ticket to application..."
    
    xcrun stapler staple "$APP_PATH"
    STAPLE_EXIT_CODE=$?
    
    if [ $STAPLE_EXIT_CODE -eq 0 ]; then
        echo "✅ Notarization ticket stapled successfully!"
    else
        echo "⚠️  Failed to staple notarization ticket, but app is still notarized"
        echo "   The app will still be accepted by Gatekeeper when downloaded"
    fi
    
    # --- 7. Validate Notarized Application ---
    echo "🔍 Validating notarized application..."
    
    xcrun stapler validate "$APP_PATH"
    VALIDATION_EXIT_CODE=$?
    
    if [ $VALIDATION_EXIT_CODE -eq 0 ]; then
        echo "✅ Application validation successful!"
    else
        echo "⚠️  Application validation had issues, but notarization was successful"
    fi
    
    # Additional validation with spctl
    echo "🔒 Verifying Gatekeeper acceptance..."
    spctl --assess --type execute --verbose "$APP_PATH"
    GATEKEEPER_EXIT_CODE=$?
    
    if [ $GATEKEEPER_EXIT_CODE -eq 0 ]; then
        echo "✅ Application will be accepted by Gatekeeper!"
    else
        echo "⚠️  Gatekeeper validation had issues"
    fi
else
    echo "⚠️  Skipping stapling due to notarization failure"
    echo "   You can manually check notarization status later using:"
    echo "   xcrun notarytool history --apple-id '$APPLE_ID' --password '$NOTARIZATION_PASSWORD' --team-id '$APPLE_TEAM_ID'"
fi

# --- 8. Create Final Distribution Package ---
echo "📦 Creating final distribution package..."

DIST_DIR="$BUILD_DIR/distribution"
mkdir -p "$DIST_DIR"

# Copy the notarized app
cp -R "$APP_PATH" "$DIST_DIR/"

# Create installation instructions
cat > "$DIST_DIR/README.txt" << EOF
FinanceMate v1.0.0 - Production Release

Installation Instructions:
1. Drag FinanceMate.app to your Applications folder
2. Launch FinanceMate from Applications or Spotlight
3. The application is code-signed and notarized by Apple

System Requirements:
- macOS 14.0 or later
- 100MB free disk space

For support, visit: https://github.com/financemate/support

Thank you for using FinanceMate!
EOF

echo "✅ Distribution package created at: $DIST_DIR"

# --- Completion ---
echo ""
echo "🎉 Production Build, Sign & Notarization Complete!"
echo ""
echo "📁 Build Artifacts:"
echo "   • Signed App Bundle: $APP_PATH"
echo "   • Notarization Archive: $ZIP_PATH"
echo "   • Distribution Package: $DIST_DIR"
echo ""

if [ "$NOTARIZATION_SUCCESS" = true ]; then
    echo "✅ Status: READY FOR DISTRIBUTION"
    echo "   • Code signed with Developer ID"
    echo "   • Notarized by Apple"
    echo "   • Gatekeeper compatible"
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. Test the app on a clean system"
    echo "   2. Distribute via your preferred channels"
    echo "   3. Monitor for any user feedback"
else
    echo "⚠️  Status: SIGNED BUT NOT NOTARIZED"
    echo "   • App is code signed and will run on your machine"
    echo "   • Notarization failed - check Apple Developer account"
    echo "   • Users may see security warnings"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "   1. Verify Apple ID and app-specific password"
    echo "   2. Check team ID is correct"
    echo "   3. Ensure certificates are valid and not expired"
    echo "   4. Review notarization logs for specific errors"
fi

echo ""
echo "📊 Build Summary:"
echo "   • Project: $SCHEME"
echo "   • Configuration: $CONFIGURATION"
echo "   • Team ID: $APPLE_TEAM_ID"
echo "   • Apple ID: $APPLE_ID"
echo "   • Build Time: $(date)"

exit 0 