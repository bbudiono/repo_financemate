#!/bin/bash

# Test Gmail OAuth Flow
# This script launches the app with Gmail OAuth environment variables

echo "=========================================="
echo "GMAIL OAUTH FUNCTIONAL TEST"
echo "Testing with: bernhardbudiono@gmail.com"
echo "=========================================="

# Set working directory
cd "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate"

# Load environment variables
source .env

# Export for the app to use
export GOOGLE_OAUTH_CLIENT_ID
export GOOGLE_OAUTH_CLIENT_SECRET
export GOOGLE_OAUTH_REDIRECT_URI
export ANTHROPIC_API_KEY

# Build the app first
echo "Building FinanceMate app..."
cd _macOS
xcodebuild -scheme FinanceMate -configuration Debug -destination "platform=macOS" build 2>&1 | grep -E "BUILD|WARNING|ERROR"

# Launch the app with environment variables
echo "Launching app with OAuth credentials..."
open -a "/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app"

echo ""
echo "=========================================="
echo "MANUAL VERIFICATION STEPS:"
echo "1. Click on Gmail tab"
echo "2. Click 'Connect Gmail' button"
echo "3. Browser should open with Google OAuth"
echo "4. Sign in with bernhardbudiono@gmail.com"
echo "5. Copy authorization code"
echo "6. Paste code in app"
echo "7. Click 'Submit Code'"
echo "8. Verify emails are fetched"
echo "9. Check if transactions are extracted"
echo "=========================================="

# Keep script running to see any output
sleep 60