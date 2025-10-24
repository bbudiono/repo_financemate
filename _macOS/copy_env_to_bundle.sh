#!/bin/bash
# Copy .env file to app bundle Resources during build
# Required for sandboxed app to access OAuth credentials

# Get script directory (works in both Xcode and command line)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source .env (in same directory as script)
ENV_SOURCE="${SCRIPT_DIR}/.env"

# Destination (use Xcode vars if available, otherwise DerivedData)
if [ -n "${BUILT_PRODUCTS_DIR}" ]; then
    # Running from Xcode build phase
    ENV_DEST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Contents/Resources/.env"
else
    # Running from command line - find DerivedData
    DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
    FINANCE_DERIVED=$(find "$DERIVED_DATA" -name "FinanceMate-*" -type d -maxdepth 1 | head -1)
    ENV_DEST="${FINANCE_DERIVED}/Build/Products/Debug/FinanceMate.app/Contents/Resources/.env"
fi

if [ -f "$ENV_SOURCE" ]; then
    echo "Copying .env to app bundle Resources..."
    echo "  Source: $ENV_SOURCE"
    echo "  Dest: $ENV_DEST"
    mkdir -p "$(dirname "$ENV_DEST")"
    cp "$ENV_SOURCE" "$ENV_DEST"
    echo "✅ .env copied successfully"
else
    echo "❌ ERROR: .env file not found at $ENV_SOURCE"
    exit 1
fi
