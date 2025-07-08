#!/bin/zsh

# setup_deployment_environment.sh
#
# This script sets up the complete deployment environment for FinanceMate,
# including all required tools, credentials, and configuration validation.
#
# Usage: ./scripts/setup_deployment_environment.sh

set -e

echo "🛠️  FinanceMate Deployment Environment Setup"
echo "============================================"

# --- Environment Detection ---
echo "🔍 Detecting environment..."

# Check macOS version
MACOS_VERSION=$(sw_vers -productVersion)
echo "   macOS Version: $MACOS_VERSION"

# Check Xcode installation
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -1)
    echo "   Xcode: $XCODE_VERSION"
else
    echo "❌ Xcode not found. Please install Xcode from the App Store."
    exit 1
fi

# Check Python installation
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "   Python: $PYTHON_VERSION"
else
    echo "❌ Python 3 not found. Please install Python 3."
    exit 1
fi

# Check Git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo "   Git: $GIT_VERSION"
else
    echo "❌ Git not found. Please install Git."
    exit 1
fi

echo "✅ Environment detection complete"

# --- Project Structure Validation ---
echo ""
echo "📁 Validating project structure..."

# Check for required files
REQUIRED_FILES=(
    "_macOS/FinanceMate.xcodeproj/project.pbxproj"
    "_macOS/FinanceMate/FinanceMate/Models/FinanceMateModel.xcdatamodeld"
    "_macOS/ExportOptions.plist"
    "scripts/pbxproj_manager.py"
    "scripts/automated_build_and_deploy.sh"
    "scripts/build_and_sign.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ] || [ -d "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ $file (missing)"
        exit 1
    fi
done

echo "✅ Project structure validation complete"

# --- Credential Configuration ---
echo ""
echo "🔐 Credential Configuration"
echo "=========================="

# Check for Apple Team ID
if [ -n "$APPLE_TEAM_ID" ]; then
    echo "✅ APPLE_TEAM_ID found in environment: $APPLE_TEAM_ID"
else
    echo "⚠️  APPLE_TEAM_ID not set in environment"
    
    # Try to extract from existing project
    if [ -f "_macOS/FinanceMate.xcodeproj/project.pbxproj" ]; then
        CURRENT_TEAM_ID=$(grep -m 1 "DEVELOPMENT_TEAM = " "_macOS/FinanceMate.xcodeproj/project.pbxproj" | sed 's/.*DEVELOPMENT_TEAM = \([^;]*\);.*/\1/' | tr -d ' ')
        if [ -n "$CURRENT_TEAM_ID" ]; then
            echo "📋 Found Team ID in project: $CURRENT_TEAM_ID"
            echo "   To use this ID, run: export APPLE_TEAM_ID='$CURRENT_TEAM_ID'"
        fi
    fi
    
    echo ""
    echo "   To set your Apple Team ID:"
    echo "   1. Visit https://developer.apple.com/account#MembershipDetailsCard"
    echo "   2. Copy your Team ID"
    echo "   3. Run: export APPLE_TEAM_ID='YOUR_TEAM_ID'"
    echo "   4. Add to your ~/.zshrc for persistence"
fi

# Check for Apple ID
if [ -n "$APPLE_ID" ]; then
    echo "✅ APPLE_ID found in environment: $APPLE_ID"
else
    echo "⚠️  APPLE_ID not set in environment"
    
    # Try to detect from Xcode
    XCODE_APPLE_ID=$(defaults read com.apple.dt.Xcode DVTDeveloperAccountManager 2>/dev/null | grep -o '[a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]*\.[a-zA-Z]{2,}' | head -1 || echo "")
    if [ -n "$XCODE_APPLE_ID" ]; then
        echo "📋 Found Apple ID in Xcode: $XCODE_APPLE_ID"
        echo "   To use this ID, run: export APPLE_ID='$XCODE_APPLE_ID'"
    fi
    
    echo ""
    echo "   To set your Apple ID:"
    echo "   export APPLE_ID='your-apple-id@example.com'"
fi

# Check for App-Specific Password
if [ -n "$APPLE_APP_SPECIFIC_PASSWORD" ]; then
    echo "✅ APPLE_APP_SPECIFIC_PASSWORD found in environment"
elif security find-generic-password -s "FinanceMate-Notarization" &>/dev/null; then
    echo "✅ App-specific password found in keychain"
else
    echo "⚠️  App-specific password not found"
    echo ""
    echo "   To set up app-specific password:"
    echo "   1. Visit https://appleid.apple.com/account/manage"
    echo "   2. Generate app-specific password"
    echo "   3. Option A - Environment variable:"
    echo "      export APPLE_APP_SPECIFIC_PASSWORD='your-password'"
    echo "   4. Option B - Keychain (more secure):"
    echo "      security add-generic-password -s 'FinanceMate-Notarization' -a 'notarization' -w 'your-password'"
fi

# Check for Code Signing Identity
echo ""
echo "🔐 Code Signing Identity"
echo "======================="

if security find-identity -v -p codesigning | grep -q "Developer ID Application"; then
    echo "✅ Developer ID Application certificate found"
    security find-identity -v -p codesigning | grep "Developer ID Application"
else
    echo "❌ Developer ID Application certificate not found"
    echo ""
    echo "   To install code signing certificate:"
    echo "   1. Visit https://developer.apple.com/account/resources/certificates/list"
    echo "   2. Create/download 'Developer ID Application' certificate"
    echo "   3. Double-click to install in Keychain Access"
fi

# --- Environment Setup Script Generation ---
echo ""
echo "📝 Generating environment setup script..."

cat > setup_env.sh << 'EOF'
#!/bin/zsh

# FinanceMate Environment Setup
# Generated by setup_deployment_environment.sh

# Apple Developer Configuration
# export APPLE_TEAM_ID="YOUR_TEAM_ID"
# export APPLE_ID="your-apple-id@example.com"
# export APPLE_APP_SPECIFIC_PASSWORD="your-app-specific-password"

# Optional: Custom certificate name
# export APPLE_CERTIFICATE_NAME="Developer ID Application: Your Name"

# Load environment variables
if [ -f ".env" ]; then
    source .env
fi

echo "🍎 FinanceMate Environment Loaded"
echo "Team ID: ${APPLE_TEAM_ID:-'Not set'}"
echo "Apple ID: ${APPLE_ID:-'Not set'}"
echo "App Password: ${APPLE_APP_SPECIFIC_PASSWORD:+'Set'}"
EOF

chmod +x setup_env.sh
echo "✅ Environment setup script created: setup_env.sh"

# --- .env Template Generation ---
echo ""
echo "📝 Generating .env template..."

cat > .env.template << 'EOF'
# FinanceMate Environment Configuration
# Copy this file to .env and fill in your values

# Apple Developer Team ID (required)
# Find at: https://developer.apple.com/account#MembershipDetailsCard
APPLE_TEAM_ID=YOUR_TEAM_ID

# Apple ID for notarization (required)
APPLE_ID=your-apple-id@example.com

# App-specific password for notarization (required)
# Generate at: https://appleid.apple.com/account/manage
APPLE_APP_SPECIFIC_PASSWORD=your-app-specific-password

# Optional: Custom certificate name
# APPLE_CERTIFICATE_NAME=Developer ID Application: Your Name

# Optional: Build configuration
# BUILD_CONFIGURATION=Release
# ARCHIVE_SCHEME=FinanceMate
EOF

echo "✅ Environment template created: .env.template"

# --- Validation Script ---
echo ""
echo "📝 Generating validation script..."

cat > scripts/validate_environment.sh << 'EOF'
#!/bin/zsh

# validate_environment.sh
# Validates the deployment environment setup

set -e

echo "🔍 Validating FinanceMate Deployment Environment"
echo "==============================================="

# Check required environment variables
VALIDATION_ERRORS=0

if [ -z "$APPLE_TEAM_ID" ]; then
    echo "❌ APPLE_TEAM_ID not set"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
else
    echo "✅ APPLE_TEAM_ID: $APPLE_TEAM_ID"
fi

if [ -z "$APPLE_ID" ]; then
    echo "❌ APPLE_ID not set"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
else
    echo "✅ APPLE_ID: $APPLE_ID"
fi

if [ -z "$APPLE_APP_SPECIFIC_PASSWORD" ] && ! security find-generic-password -s "FinanceMate-Notarization" &>/dev/null; then
    echo "❌ App-specific password not found"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
else
    echo "✅ App-specific password configured"
fi

# Check code signing
if security find-identity -v -p codesigning | grep -q "Developer ID Application"; then
    echo "✅ Code signing identity available"
else
    echo "❌ Code signing identity not found"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

# Check tools
if command -v xcodebuild &> /dev/null; then
    echo "✅ Xcode command line tools available"
else
    echo "❌ Xcode command line tools not found"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

if command -v python3 &> /dev/null; then
    echo "✅ Python 3 available"
else
    echo "❌ Python 3 not found"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

# Summary
echo ""
if [ $VALIDATION_ERRORS -eq 0 ]; then
    echo "✅ Environment validation passed!"
    echo "   Ready to run automated deployment"
    exit 0
else
    echo "❌ Environment validation failed with $VALIDATION_ERRORS errors"
    echo "   Please fix the errors above before proceeding"
    exit 1
fi
EOF

chmod +x scripts/validate_environment.sh
echo "✅ Validation script created: scripts/validate_environment.sh"

# --- Quick Start Guide ---
echo ""
echo "📝 Generating quick start guide..."

cat > QUICK_START.md << 'EOF'
# FinanceMate Deployment Quick Start

## 1. Environment Setup
```bash
# Copy environment template
cp .env.template .env

# Edit .env with your credentials
nano .env

# Load environment
source setup_env.sh
```

## 2. Validate Environment
```bash
# Validate all requirements
source setup_env.sh
./scripts/validate_environment.sh
```

## 3. Deploy Application
```bash
# Complete automated deployment
./scripts/automated_build_and_deploy.sh
```

## 4. Configuration Only (if needed)
```bash
# Just fix configuration issues
./scripts/automated_build_and_deploy.sh --config-only
```

## Troubleshooting

### Missing Team ID
```bash
# Find your Team ID at: https://developer.apple.com/account#MembershipDetailsCard
export APPLE_TEAM_ID="YOUR_TEAM_ID"
```

### Missing Code Signing Certificate
1. Visit https://developer.apple.com/account/resources/certificates/list
2. Create/download 'Developer ID Application' certificate
3. Double-click to install in Keychain Access

### App-Specific Password
1. Visit https://appleid.apple.com/account/manage
2. Generate app-specific password
3. Add to keychain: `security add-generic-password -s 'FinanceMate-Notarization' -a 'notarization' -w 'your-password'`

For detailed documentation, see: `docs/AUTOMATED_DEPLOYMENT_GUIDE.md`
EOF

echo "✅ Quick start guide created: QUICK_START.md"

# --- Final Summary ---
echo ""
echo "🎉 Environment Setup Complete!"
echo "=============================="
echo ""
echo "📋 Created Files:"
echo "   • setup_env.sh - Environment loader"
echo "   • .env.template - Environment configuration template"
echo "   • scripts/validate_environment.sh - Environment validator"
echo "   • QUICK_START.md - Quick start guide"
echo ""
echo "🚀 Next Steps:"
echo "1. Copy .env.template to .env and fill in your credentials"
echo "2. Run: source setup_env.sh"
echo "3. Run: ./scripts/validate_environment.sh"
echo "4. Run: ./scripts/automated_build_and_deploy.sh"
echo ""
echo "📚 Documentation:"
echo "   • QUICK_START.md - Quick start guide"
echo "   • docs/AUTOMATED_DEPLOYMENT_GUIDE.md - Comprehensive guide"
echo ""
echo "✨ Status: Ready for automated deployment!"

exit 0