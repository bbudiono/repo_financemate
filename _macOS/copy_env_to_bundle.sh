#!/bin/bash
# Copy .env file to app bundle Resources during build
# Required for sandboxed app to access OAuth credentials

ENV_SOURCE="${SRCROOT}/.env"
ENV_DEST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Contents/Resources/.env"

if [ -f "$ENV_SOURCE" ]; then
    echo "Copying .env to app bundle Resources..."
    mkdir -p "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Contents/Resources"
    cp "$ENV_SOURCE" "$ENV_DEST"
    echo "✅ .env copied successfully"
else
    echo "⚠️  WARNING: .env file not found at $ENV_SOURCE"
    echo "   OAuth will not work without .env file"
fi
