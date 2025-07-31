#!/bin/bash

# verify-build.sh - Comprehensive build verification for FinanceMate
# This script validates that all builds pass before pushing to remote

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Running comprehensive build verification...${NC}"

# Configuration
PROJECT_ROOT="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate"
MACOS_DIR="$PROJECT_ROOT/_macOS"

# Function to verify macOS build
verify_macos_build() {
    echo -e "${BLUE}Verifying macOS build...${NC}"
    
    cd "$MACOS_DIR"
    
    # Clean build
    if xcodebuild clean -scheme FinanceMate -destination 'platform=macOS' > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Clean build successful${NC}"
    else
        echo -e "${RED}❌ Clean build failed${NC}"
        return 1
    fi
    
    # Build project
    if xcodebuild build -scheme FinanceMate -destination 'platform=macOS' > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Build successful${NC}"
    else
        echo -e "${RED}❌ Build failed${NC}"
        return 1
    fi
    
    # Run unit tests
    if xcodebuild test -scheme FinanceMate -destination 'platform=macOS' -only-testing:FinanceMateTests > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Unit tests passed${NC}"
    else
        echo -e "${RED}❌ Unit tests failed${NC}"
        return 1
    fi
    
    # Skip UI tests - XCUITests have been eliminated for headless compatibility
    echo -e "${YELLOW}ℹ️  UI tests skipped (headless compatibility mode)${NC}"
    
    return 0
}

# Function to verify sandbox build
verify_sandbox_build() {
    echo -e "${BLUE}Verifying sandbox build...${NC}"
    
    cd "$MACOS_DIR/FinanceMate-Sandbox"
    
    # Clean build
    if xcodebuild clean -scheme FinanceMate-Sandbox -destination 'platform=macOS' > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Sandbox clean build successful${NC}"
    else
        echo -e "${RED}❌ Sandbox clean build failed${NC}"
        return 1
    fi
    
    # Build project
    if xcodebuild build -scheme FinanceMate-Sandbox -destination 'platform=macOS' > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Sandbox build successful${NC}"
    else
        echo -e "${RED}❌ Sandbox build failed${NC}"
        return 1
    fi
    
    return 0
}

# Function to check for critical files
check_critical_files() {
    echo -e "${BLUE}Checking for critical files...${NC}"
    
    local critical_files=(
        "$MACOS_DIR/FinanceMate.xcodeproj/project.pbxproj"
        "$MACOS_DIR/FinanceMate/FinanceMate/FinanceMateApp.swift"
        "$MACOS_DIR/FinanceMate/FinanceMate/ContentView.swift"
        "$MACOS_DIR/FinanceMate/FinanceMate/Views/DashboardView.swift"
        "$MACOS_DIR/FinanceMate/FinanceMate/ViewModels/DashboardViewModel.swift"
        "$MACOS_DIR/FinanceMate/FinanceMate/Models/Transaction.swift"
        "$MACOS_DIR/FinanceMate/FinanceMate/PersistenceController.swift"
    )
    
    for file in "${critical_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo -e "${RED}❌ Critical file missing: $file${NC}"
            return 1
        fi
    done
    
    echo -e "${GREEN}✅ All critical files present${NC}"
    return 0
}

# Function to check for compilation errors
check_compilation_errors() {
    echo -e "${BLUE}Checking for compilation errors...${NC}"
    
    cd "$MACOS_DIR"
    
    # Try to build and capture any errors
    if xcodebuild -scheme FinanceMate -destination 'platform=macOS' build 2>&1 | grep -q "error:"; then
        echo -e "${RED}❌ Compilation errors found${NC}"
        return 1
    else
        echo -e "${GREEN}✅ No compilation errors${NC}"
        return 0
    fi
}

# Run all verifications
verification_failed=false

echo -e "${BLUE}📋 Build Verification Summary:${NC}"
echo ""

# Check critical files
if ! check_critical_files; then
    verification_failed=true
fi

# Check compilation errors
if ! check_compilation_errors; then
    verification_failed=true
fi

# Verify macOS build
if ! verify_macos_build; then
    verification_failed=true
fi

# Verify sandbox build
if ! verify_sandbox_build; then
    verification_failed=true
fi

# Final decision
echo ""
if [ "$verification_failed" = true ]; then
    echo -e "${RED}❌ BUILD VERIFICATION FAILED${NC}"
    echo -e "${RED}   Fix all build issues before pushing${NC}"
    exit 1
else
    echo -e "${GREEN}✅ BUILD VERIFICATION PASSED${NC}"
    echo -e "${GREEN}🚀 All builds successful - ready to push${NC}"
    exit 0
fi