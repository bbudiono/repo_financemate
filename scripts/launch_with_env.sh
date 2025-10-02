#!/bin/bash
# Launch FinanceMate with environment variables from .env file

cd "$(dirname "$0")/.."

# Load .env file
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "Loaded environment variables from .env"
else
    echo "ERROR: .env file not found"
    echo "Run: cp .env.template .env"
    exit 1
fi

# Verify critical vars
if [ -z "$GOOGLE_OAUTH_CLIENT_ID" ]; then
    echo "ERROR: GOOGLE_OAUTH_CLIENT_ID not set in .env"
    exit 1
fi

echo "Launching FinanceMate with environment..."
echo "  GOOGLE_OAUTH_CLIENT_ID: ${GOOGLE_OAUTH_CLIENT_ID:0:20}..."

# Launch app with environment
open -n --env "GOOGLE_OAUTH_CLIENT_ID=$GOOGLE_OAUTH_CLIENT_ID" \
        --env "GOOGLE_OAUTH_CLIENT_SECRET=$GOOGLE_OAUTH_CLIENT_SECRET" \
        --env "ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" \
        "_macOS/$(ls -t _macOS/../Library/Developer/Xcode/DerivedData/FinanceMate-*/Build/Products/Debug/FinanceMate.app | head -1)"

echo "FinanceMate launched with OAuth credentials"
