#!/bin/bash

# SANDBOX FILE: For testing/development. See .cursorrules.
# Purpose: Pre-build validation script to ensure asset catalogs are properly configured
# Issues & Complexity Summary: Automated validation system for preventing TestFlight deployment issues
# Key Complexity Drivers:
#   - Logic Scope (Est. LoC): ~120
#   - Core Algorithm Complexity: Med
#   - Dependencies: 2 (jq, actool validation)
#   - State Management Complexity: Low
#   - Novelty/Uncertainty Factor: Low
# AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
# Problem Estimate (Inherent Problem Difficulty %): 70%
# Initial Code Complexity Estimate %: 70%
# Justification for Estimates: Standard pre-build validation with asset checking
# Final Code Complexity (Actual %): TBD
# Overall Result Score (Success & Quality %): TBD
# Key Variances/Learnings: TBD
# Last Updated: 2025-06-02

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MACOS_DIR="$PROJECT_ROOT/_macOS"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() { echo -e "${BLUE}[PRE-BUILD VALIDATION]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Required macOS App Store icon files
REQUIRED_ICON_FILES=(
    "icon_16x16.png"
    "icon_16x16@2x.png"
    "icon_32x32.png"
    "icon_32x32@2x.png"
    "icon_128x128.png"
    "icon_128x128@2x.png"
    "icon_256x256.png"
    "icon_256x256@2x.png"
    "icon_512x512.png"
    "icon_512x512@2x.png"
)

# Check if AppIcon.appiconset contains only required files
validate_icon_files() {
    local appiconset_dir="$1"
    local environment="$2"
    
    log "Validating icon files for $environment..."
    
    if [[ ! -d "$appiconset_dir" ]]; then
        error "$environment AppIcon.appiconset not found: $appiconset_dir"
        return 1
    fi
    
    local validation_errors=0
    
    # Check all required files exist
    for required_file in "${REQUIRED_ICON_FILES[@]}"; do
        local file_path="$appiconset_dir/$required_file"
        if [[ ! -f "$file_path" ]]; then
            error "$environment: Missing required icon file: $required_file"
            ((validation_errors++))
        fi
    done
    
    # Check for unassigned files (files not in Contents.json)
    local unassigned_files=()
    for file in "$appiconset_dir"/*.png; do
        if [[ -f "$file" ]]; then
            local basename_file
            basename_file=$(basename "$file")
            local is_required=false
            
            for required in "${REQUIRED_ICON_FILES[@]}"; do
                if [[ "$basename_file" == "$required" ]]; then
                    is_required=true
                    break
                fi
            done
            
            if [[ "$is_required" == false ]]; then
                unassigned_files+=("$basename_file")
            fi
        fi
    done
    
    if [[ ${#unassigned_files[@]} -gt 0 ]]; then
        error "$environment: Found unassigned files that will cause build warnings:"
        for unassigned in "${unassigned_files[@]}"; do
            echo "  - $unassigned"
        done
        ((validation_errors++))
    fi
    
    # Validate Contents.json structure
    local contents_json="$appiconset_dir/Contents.json"
    if [[ ! -f "$contents_json" ]]; then
        error "$environment: Contents.json not found"
        ((validation_errors++))
    elif command -v jq &> /dev/null; then
        # Validate JSON syntax
        if ! jq . "$contents_json" > /dev/null 2>&1; then
            error "$environment: Invalid JSON syntax in Contents.json"
            ((validation_errors++))
        else
            # Check that Contents.json references all required files
            local missing_references=0
            for required_file in "${REQUIRED_ICON_FILES[@]}"; do
                if ! jq -e --arg filename "$required_file" '.images[] | select(.filename == $filename)' "$contents_json" > /dev/null 2>&1; then
                    error "$environment: Contents.json missing reference to $required_file"
                    ((missing_references++))
                fi
            done
            
            if [[ $missing_references -gt 0 ]]; then
                ((validation_errors++))
            fi
        fi
    fi
    
    if [[ $validation_errors -eq 0 ]]; then
        success "$environment icon validation passed"
        return 0
    else
        error "$environment icon validation failed with $validation_errors errors"
        return 1
    fi
}

# Validate that both environments have identical icon configurations
validate_environment_sync() {
    local prod_appiconset="$MACOS_DIR/FinanceMate/FinanceMate/Assets.xcassets/AppIcon.appiconset"
    local sandbox_appiconset="$MACOS_DIR/FinanceMate-Sandbox/FinanceMate-Sandbox/Assets.xcassets/AppIcon.appiconset"
    
    log "Validating Production and Sandbox environment synchronization..."
    
    if [[ ! -d "$prod_appiconset" ]] || [[ ! -d "$sandbox_appiconset" ]]; then
        warning "Cannot validate environment sync - one or both AppIcon.appiconset directories missing"
        return 0
    fi
    
    # Compare Contents.json files
    local prod_contents="$prod_appiconset/Contents.json"
    local sandbox_contents="$sandbox_appiconset/Contents.json"
    
    if [[ -f "$prod_contents" ]] && [[ -f "$sandbox_contents" ]]; then
        if ! diff -q "$prod_contents" "$sandbox_contents" > /dev/null; then
            warning "Production and Sandbox Contents.json files differ"
            echo "Production: $prod_contents"
            echo "Sandbox: $sandbox_contents"
        else
            success "Production and Sandbox Contents.json are synchronized"
        fi
    fi
    
    # Compare icon file checksums
    local checksum_mismatches=0
    for required_file in "${REQUIRED_ICON_FILES[@]}"; do
        local prod_file="$prod_appiconset/$required_file"
        local sandbox_file="$sandbox_appiconset/$required_file"
        
        if [[ -f "$prod_file" ]] && [[ -f "$sandbox_file" ]]; then
            local prod_checksum
            local sandbox_checksum
            prod_checksum=$(shasum -a 256 "$prod_file" | cut -d' ' -f1)
            sandbox_checksum=$(shasum -a 256 "$sandbox_file" | cut -d' ' -f1)
            
            if [[ "$prod_checksum" != "$sandbox_checksum" ]]; then
                warning "Icon file $required_file differs between Production and Sandbox"
                ((checksum_mismatches++))
            fi
        fi
    done
    
    if [[ $checksum_mismatches -eq 0 ]]; then
        success "All icon files are synchronized between environments"
    else
        warning "$checksum_mismatches icon files differ between environments"
    fi
    
    return 0
}

# Check for potential App Store compliance issues
validate_app_store_compliance() {
    log "Validating App Store compliance requirements..."
    
    local compliance_issues=0
    
    # Check for proper bundle identifier format
    local prod_project="$MACOS_DIR/FinanceMate/FinanceMate.xcodeproj/project.pbxproj"
    if [[ -f "$prod_project" ]]; then
        if grep -q "com\.ablankcanvas\.financemate" "$prod_project"; then
            success "Production bundle identifier follows proper format"
        else
            warning "Production bundle identifier may not follow expected format"
            ((compliance_issues++))
        fi
    fi
    
    # Check for App Category setting
    if grep -q "LSApplicationCategoryType.*Productivity" "$prod_project" 2>/dev/null; then
        success "App category properly set to Productivity"
    else
        warning "App category may not be properly configured"
        ((compliance_issues++))
    fi
    
    if [[ $compliance_issues -eq 0 ]]; then
        success "App Store compliance validation passed"
    else
        warning "Found $compliance_issues potential App Store compliance issues"
    fi
    
    return 0
}

# Main validation function
main() {
    log "Starting pre-build asset validation..."
    
    local total_errors=0
    
    # Validate Production AppIcon.appiconset
    local prod_appiconset="$MACOS_DIR/FinanceMate/FinanceMate/Assets.xcassets/AppIcon.appiconset"
    if ! validate_icon_files "$prod_appiconset" "Production"; then
        ((total_errors++))
    fi
    
    # Validate Sandbox AppIcon.appiconset
    local sandbox_appiconset="$MACOS_DIR/FinanceMate-Sandbox/FinanceMate-Sandbox/Assets.xcassets/AppIcon.appiconset"
    if [[ -d "$sandbox_appiconset" ]]; then
        if ! validate_icon_files "$sandbox_appiconset" "Sandbox"; then
            ((total_errors++))
        fi
    else
        warning "Sandbox AppIcon.appiconset not found - consider running fix_app_icon_assets.sh"
    fi
    
    # Validate environment synchronization
    validate_environment_sync
    
    # Validate App Store compliance
    validate_app_store_compliance
    
    echo ""
    if [[ $total_errors -eq 0 ]]; then
        success "Pre-build asset validation passed!"
        log "All icon assets are properly configured for TestFlight deployment"
        exit 0
    else
        error "Pre-build asset validation failed with $total_errors errors"
        log "Run 'scripts/fix_app_icon_assets.sh' to automatically fix icon issues"
        exit 1
    fi
}

# Show help if requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Pre-Build Asset Validation Script"
    echo ""
    echo "This script validates that AppIcon.appiconset is properly configured"
    echo "for both Production and Sandbox environments to prevent TestFlight"
    echo "deployment issues."
    echo ""
    echo "Usage: $0"
    echo ""
    echo "What it checks:"
    echo "  - All required icon sizes are present"
    echo "  - No unassigned files that cause build warnings"
    echo "  - Contents.json is properly formatted"
    echo "  - Production and Sandbox environments are synchronized"
    echo "  - Basic App Store compliance requirements"
    echo ""
    echo "If validation fails, run: scripts/fix_app_icon_assets.sh"
    exit 0
fi

# Run main function
main "$@"