#!/bin/bash
# Fetch real Gmail emails by running the actual FinanceMate app in background
# This uses the existing OAuth tokens and Swift extraction code

echo "🚀 Launching FinanceMate to fetch real Gmail data..."
echo "📧 This will use production OAuth tokens and Gmail API..."

# Run FinanceMate in background and capture logs
FINANCE_MATE_APP="/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app/Contents/MacOS/FinanceMate"

if [ ! -f "$FINANCE_MATE_APP" ]; then
    echo "❌ FinanceMate not built. Building now..."
    cd "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug build
fi

echo "✅ FinanceMate ready"
echo "📋 Next: Open FinanceMate manually, go to Gmail tab, let it extract"
echo "📋 Then check Console.app for [EXTRACT-] logs to see actual extraction results"
echo ""
echo "Alternatively: Use the Re-Extract All button in the app to force fresh extraction"
