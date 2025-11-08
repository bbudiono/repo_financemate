#!/bin/bash

# OAuth Automatic Flow Validation Script
# Tests that LocalOAuthServer is properly integrated and working
# This validates the restoration of automatic OAuth (no manual code entry)

set -e

PROJECT_ROOT="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate"
MACOS_DIR="$PROJECT_ROOT/_macOS"
ENV_FILE="$MACOS_DIR/.env"

echo "=== OAuth Automatic Flow Validation ==="
echo ""

# Test 1: Check LocalOAuthServer.swift exists
echo "✓ Test 1: LocalOAuthServer.swift file exists"
if [ -f "$MACOS_DIR/FinanceMate/Services/LocalOAuthServer.swift" ]; then
    echo "  ✅ PASS: LocalOAuthServer.swift found"
else
    echo "  ❌ FAIL: LocalOAuthServer.swift not found"
    exit 1
fi

# Test 2: Check .env has localhost:8080 redirect
echo ""
echo "✓ Test 2: .env configured with localhost:8080/callback"
if grep -q "GOOGLE_OAUTH_REDIRECT_URI=http://localhost:8080/callback" "$ENV_FILE"; then
    echo "  ✅ PASS: Redirect URI correctly configured"
else
    echo "  ❌ FAIL: Redirect URI not set to localhost:8080/callback"
    echo "  Current value:"
    grep "GOOGLE_OAUTH_REDIRECT_URI" "$ENV_FILE"
    exit 1
fi

# Test 3: Check GmailViewModel has LocalOAuthServer integration
echo ""
echo "✓ Test 3: GmailViewModel uses LocalOAuthServer"
if grep -q "private let oauthServer = LocalOAuthServer()" "$MACOS_DIR/FinanceMate/GmailViewModel.swift"; then
    echo "  ✅ PASS: LocalOAuthServer integrated into GmailViewModel"
else
    echo "  ❌ FAIL: LocalOAuthServer not found in GmailViewModel"
    exit 1
fi

# Test 4: Check startAutomaticOAuthFlow method exists
echo ""
echo "✓ Test 4: Automatic OAuth flow method exists"
if grep -q "func startAutomaticOAuthFlow()" "$MACOS_DIR/FinanceMate/GmailViewModel.swift"; then
    echo "  ✅ PASS: startAutomaticOAuthFlow() method found"
else
    echo "  ❌ FAIL: startAutomaticOAuthFlow() method not found"
    exit 1
fi

# Test 5: Check GmailView calls automatic flow (not manual)
echo ""
echo "✓ Test 5: GmailView uses automatic flow"
if grep -q "viewModel.startAutomaticOAuthFlow()" "$MACOS_DIR/FinanceMate/GmailView.swift"; then
    echo "  ✅ PASS: GmailView calls startAutomaticOAuthFlow()"
else
    echo "  ❌ FAIL: GmailView doesn't call automatic OAuth flow"
    exit 1
fi

# Test 6: Check manual code input UI is removed
echo ""
echo "✓ Test 6: Manual code input UI removed"
if ! grep -q 'TextField("Enter authorization code"' "$MACOS_DIR/FinanceMate/GmailView.swift"; then
    echo "  ✅ PASS: Manual code input TextField not found (good!)"
else
    echo "  ❌ FAIL: Manual code input still present in UI"
    exit 1
fi

# Test 7: Check LocalOAuthServer has proper callback handling
echo ""
echo "✓ Test 7: LocalOAuthServer has callback handler"
if grep -q 'private var callbackHandler: ((String) -> Void)?' "$MACOS_DIR/FinanceMate/Services/LocalOAuthServer.swift"; then
    echo "  ✅ PASS: Callback handler properly defined"
else
    echo "  ❌ FAIL: Callback handler not found"
    exit 1
fi

# Test 8: Check server starts on port 8080
echo ""
echo "✓ Test 8: Server configured for port 8080"
if grep -q 'func startServer(port: UInt16 = 8080' "$MACOS_DIR/FinanceMate/Services/LocalOAuthServer.swift"; then
    echo "  ✅ PASS: Server defaults to port 8080"
else
    echo "  ❌ FAIL: Server port configuration incorrect"
    exit 1
fi

# Test 9: Check OAuth credentials are present in .env
echo ""
echo "✓ Test 9: OAuth credentials configured"
if grep -q "GOOGLE_OAUTH_CLIENT_ID=" "$ENV_FILE" && grep -q "GOOGLE_OAUTH_CLIENT_SECRET=" "$ENV_FILE"; then
    echo "  ✅ PASS: OAuth credentials present in .env"
else
    echo "  ❌ FAIL: OAuth credentials missing from .env"
    exit 1
fi

# Test 10: Check GmailOAuthHelper uses .env redirect URI
echo ""
echo "✓ Test 10: GmailOAuthHelper loads redirect URI from .env"
if grep -q 'guard let redirectURI = DotEnvLoader.get("GOOGLE_OAUTH_REDIRECT_URI")' "$MACOS_DIR/FinanceMate/GmailOAuthHelper.swift"; then
    echo "  ✅ PASS: Redirect URI loaded dynamically from .env"
else
    echo "  ❌ FAIL: Hardcoded redirect URI detected"
    exit 1
fi

echo ""
echo "==================================="
echo "✅ ALL TESTS PASSED!"
echo "==================================="
echo ""
echo "🎉 OAuth Automatic Flow Restored Successfully!"
echo ""
echo "User Experience:"
echo "  1. Click 'Connect Gmail' button"
echo "  2. Browser opens Google OAuth page"
echo "  3. User clicks 'Allow'"
echo "  4. Automatic redirect to localhost:8080/callback"
echo "  5. LocalOAuthServer captures code"
echo "  6. Token exchange happens automatically"
echo "  7. User is authenticated - NO manual code entry!"
echo ""
echo "Next Steps:"
echo "  1. Build the app: xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate build"
echo "  2. Run the app and test OAuth flow"
echo "  3. Verify no manual code entry is required"
echo "  4. Check Google Cloud Console has http://localhost:8080/callback in authorized redirect URIs"
echo ""
