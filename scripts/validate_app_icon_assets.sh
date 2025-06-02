#!/bin/bash

# SANDBOX FILE: For testing/development. See .cursorrules.
# Purpose: Validate AppIcon.appiconset configuration for macOS App Store compliance
# Issues & Complexity Summary: Icon asset validation and cleanup for TestFlight deployment
# Key Complexity Drivers:
#   - Logic Scope (Est. LoC): ~150
#   - Core Algorithm Complexity: Med
#   - Dependencies: 2 New (jq, Xcode validation)
#   - State Management Complexity: Low
#   - Novelty/Uncertainty Factor: Low
# AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
# Problem Estimate (Inherent Problem Difficulty %): 70%
# Initial Code Complexity Estimate %: 70%
# Justification for Estimates: Standard macOS icon validation with asset cleanup
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

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Required macOS App Store icon sizes (based on Apple's Human Interface Guidelines)
declare -A REQUIRED_ICONS
REQUIRED_ICONS["16x16_1x"]="icon_16x16.png"
REQUIRED_ICONS["16x16_2x"]="icon_16x16@2x.png"
REQUIRED_ICONS["32x32_1x"]="icon_32x32.png"
REQUIRED_ICONS["32x32_2x"]="icon_32x32@2x.png"
REQUIRED_ICONS["128x128_1x"]="icon_128x128.png"
REQUIRED_ICONS["128x128_2x"]="icon_128x128@2x.png"
REQUIRED_ICONS["256x256_1x"]="icon_256x256.png"
REQUIRED_ICONS["256x256_2x"]="icon_256x256@2x.png"
REQUIRED_ICONS["512x512_1x"]="icon_512x512.png"
REQUIRED_ICONS["512x512_2x"]="icon_512x512@2x.png"

# Function to validate icon dimensions
validate_icon_dimensions() {
    local file_path="$1"
    local expected_size="$2"
    
    if [[ ! -f "$file_path" ]]; then
        error "Icon file missing: $file_path"
        return 1
    fi
    
    # Use sips to get image dimensions (macOS built-in tool)
    local dimensions
    dimensions=$(sips -g pixelWidth -g pixelHeight "$file_path" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    
    if [[ "$dimensions" != "$expected_size" ]]; then
        error "Icon $file_path has incorrect dimensions: $dimensions (expected: $expected_size)"
        return 1
    fi
    
    success "Icon $file_path validated: $dimensions"
    return 0
}

# Function to validate Contents.json structure
validate_contents_json() {
    local appiconset_dir="$1"
    local contents_json="$appiconset_dir/Contents.json"
    
    if [[ ! -f "$contents_json" ]]; then
        error "Contents.json not found in $appiconset_dir"
        return 1
    fi
    
    log "Validating Contents.json structure..."
    
    # Check if jq is available for JSON validation
    if ! command -v jq &> /dev/null; then
        warning "jq not available, skipping JSON structure validation"
        return 0
    fi
    
    # Validate JSON syntax
    if ! jq . "$contents_json" > /dev/null 2>&1; then
        error "Invalid JSON syntax in Contents.json"
        return 1
    fi
    
    # Count referenced images in Contents.json
    local referenced_count
    referenced_count=$(jq '.images | length' "$contents_json")
    
    log "Contents.json references $referenced_count icon entries"
    
    # Validate that all required icons are referenced
    local missing_references=0
    for size_scale in "${!REQUIRED_ICONS[@]}"; do
        local filename="${REQUIRED_ICONS[$size_scale]}"
        local size="${size_scale%_*}"
        local scale="${size_scale#*_}"
        
        # Convert scale format
        if [[ "$scale" == "2x" ]]; then
            scale="2x"
        else
            scale="1x"
        fi
        
        # Check if this icon is referenced in Contents.json
        local found
        found=$(jq --arg size "$size" --arg scale "$scale" --arg filename "$filename" '
            .images[] | select(.size == $size and .scale == $scale and .filename == $filename)
        ' "$contents_json")
        
        if [[ -z "$found" ]]; then
            error "Missing reference in Contents.json: $size@${scale} ($filename)"
            ((missing_references++))
        fi
    done
    
    if [[ $missing_references -gt 0 ]]; then
        error "Contents.json is missing $missing_references required icon references"
        return 1
    fi
    
    success "Contents.json structure validation passed"
    return 0
}

# Function to identify unassigned files
identify_unassigned_files() {
    local appiconset_dir="$1"
    local contents_json="$appiconset_dir/Contents.json"
    
    log "Identifying unassigned files in $appiconset_dir..."
    
    # Get all PNG files in the directory
    local all_files
    all_files=$(find "$appiconset_dir" -name "*.png" -type f -exec basename {} \;)
    
    # Get referenced files from Contents.json
    local referenced_files=""
    if command -v jq &> /dev/null && [[ -f "$contents_json" ]]; then
        referenced_files=$(jq -r '.images[].filename' "$contents_json" 2>/dev/null | grep -v "null")
    fi
    
    # Find unassigned files
    local unassigned_count=0
    echo "$all_files" | while read -r file; do
        if [[ -n "$file" ]]; then
            local is_referenced=false
            echo "$referenced_files" | while read -r ref_file; do
                if [[ "$file" == "$ref_file" ]]; then
                    is_referenced=true
                    break
                fi
            done
            
            if [[ "$is_referenced" == false ]]; then
                if [[ $unassigned_count -eq 0 ]]; then
                    warning "Found unassigned files:"
                fi
                echo "  - $file"
                ((unassigned_count++))
            fi
        fi
    done
    
    if [[ $unassigned_count -gt 0 ]]; then
        return 1
    else
        success "No unassigned files found"
        return 0
    fi
}

# Function to validate a single AppIcon.appiconset
validate_appiconset() {
    local appiconset_dir="$1"
    local environment="$2"
    
    log "Validating AppIcon.appiconset for $environment environment: $appiconset_dir"
    
    if [[ ! -d "$appiconset_dir" ]]; then
        error "AppIcon.appiconset directory not found: $appiconset_dir"
        return 1
    fi
    
    local validation_errors=0
    
    # Validate Contents.json
    if ! validate_contents_json "$appiconset_dir"; then
        ((validation_errors++))
    fi
    
    # Validate icon file dimensions
    for size_scale in "${!REQUIRED_ICONS[@]}"; do
        local filename="${REQUIRED_ICONS[$size_scale]}"
        local file_path="$appiconset_dir/$filename"
        local expected_size="${size_scale%_*}"
        local scale="${size_scale#*_}"
        
        # Convert @2x scale to actual pixel dimensions
        if [[ "$scale" == "2x" ]]; then
            local base_size="${expected_size%x*}"
            local doubled_size=$((base_size * 2))
            expected_size="${doubled_size}x${doubled_size}"
        fi
        
        if ! validate_icon_dimensions "$file_path" "$expected_size"; then
            ((validation_errors++))
        fi
    done
    
    # Check for unassigned files
    if ! identify_unassigned_files "$appiconset_dir"; then
        warning "Unassigned files detected (will cause Xcode warnings)"
    fi
    
    if [[ $validation_errors -eq 0 ]]; then
        success "$environment AppIcon.appiconset validation passed!"
        return 0
    else
        error "$environment AppIcon.appiconset validation failed with $validation_errors errors"
        return 1
    fi
}

# Main validation function
main() {
    log "Starting AppIcon asset validation..."
    
    local total_errors=0
    
    # Validate Production AppIcon.appiconset
    local prod_appiconset="$MACOS_DIR/FinanceMate/FinanceMate/Assets.xcassets/AppIcon.appiconset"
    if ! validate_appiconset "$prod_appiconset" "Production"; then
        ((total_errors++))
    fi
    
    # Validate Sandbox AppIcon.appiconset (if exists)
    local sandbox_appiconset="$MACOS_DIR/FinanceMate-Sandbox/FinanceMate-Sandbox/Assets.xcassets/AppIcon.appiconset"
    if [[ -d "$sandbox_appiconset" ]]; then
        if ! validate_appiconset "$sandbox_appiconset" "Sandbox"; then
            ((total_errors++))
        fi
    else
        warning "Sandbox AppIcon.appiconset not found at $sandbox_appiconset"
    fi
    
    echo ""
    if [[ $total_errors -eq 0 ]]; then
        success "All AppIcon asset validations passed!"
        exit 0
    else
        error "AppIcon asset validation failed with $total_errors errors"
        exit 1
    fi
}

# Run main function
main "$@"