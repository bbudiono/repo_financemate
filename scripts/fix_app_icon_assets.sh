#!/bin/bash

# SANDBOX FILE: For testing/development. See .cursorrules.
# Purpose: Fix AppIcon.appiconset configuration by cleaning unassigned files and ensuring proper Contents.json
# Issues & Complexity Summary: Clean up duplicate icon files and ensure App Store compliance
# Key Complexity Drivers:
#   - Logic Scope (Est. LoC): ~100
#   - Core Algorithm Complexity: Low
#   - Dependencies: 1 (Xcode/macOS tools)
#   - State Management Complexity: Low
#   - Novelty/Uncertainty Factor: Low
# AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
# Problem Estimate (Inherent Problem Difficulty %): 65%
# Initial Code Complexity Estimate %: 65%
# Justification for Estimates: Straightforward file cleanup with JSON validation
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
log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Create proper Contents.json for macOS App Store
create_contents_json() {
    local appiconset_dir="$1"
    local contents_json="$appiconset_dir/Contents.json"
    
    log "Creating proper Contents.json for macOS App Store compliance..."
    
    cat > "$contents_json" << 'EOF'
{
  "images" : [
    {
      "size" : "16x16",
      "idiom" : "mac",
      "filename" : "icon_16x16.png",
      "scale" : "1x"
    },
    {
      "size" : "16x16",
      "idiom" : "mac",
      "filename" : "icon_16x16@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "32x32",
      "idiom" : "mac",
      "filename" : "icon_32x32.png",
      "scale" : "1x"
    },
    {
      "size" : "32x32",
      "idiom" : "mac",
      "filename" : "icon_32x32@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "128x128",
      "idiom" : "mac",
      "filename" : "icon_128x128.png",
      "scale" : "1x"
    },
    {
      "size" : "128x128",
      "idiom" : "mac",
      "filename" : "icon_128x128@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "256x256",
      "idiom" : "mac",
      "filename" : "icon_256x256.png",
      "scale" : "1x"
    },
    {
      "size" : "256x256",
      "idiom" : "mac",
      "filename" : "icon_256x256@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "512x512",
      "idiom" : "mac",
      "filename" : "icon_512x512.png",
      "scale" : "1x"
    },
    {
      "size" : "512x512",
      "idiom" : "mac",
      "filename" : "icon_512x512@2x.png",
      "scale" : "2x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF

    success "Contents.json created successfully"
}

# Clean unassigned files from AppIcon.appiconset
clean_unassigned_files() {
    local appiconset_dir="$1"
    
    log "Cleaning unassigned files from $appiconset_dir..."
    
    # Files that should be referenced in Contents.json
    local required_files=(
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
    
    # Find all PNG files in the directory
    local files_to_remove=()
    
    for file in "$appiconset_dir"/*.png; do
        if [[ -f "$file" ]]; then
            local basename_file
            basename_file=$(basename "$file")
            local is_required=false
            
            for required in "${required_files[@]}"; do
                if [[ "$basename_file" == "$required" ]]; then
                    is_required=true
                    break
                fi
            done
            
            if [[ "$is_required" == false ]]; then
                files_to_remove+=("$file")
            fi
        fi
    done
    
    # Remove unassigned files
    if [[ ${#files_to_remove[@]} -gt 0 ]]; then
        warning "Removing ${#files_to_remove[@]} unassigned files:"
        for file in "${files_to_remove[@]}"; do
            echo "  - $(basename "$file")"
            rm "$file"
        done
        success "Unassigned files removed"
    else
        success "No unassigned files found"
    fi
    
    # Remove other unwanted files
    local unwanted_files=(
        "$appiconset_dir/AppIcon.icns"
        "$appiconset_dir/temp"
    )
    
    for unwanted in "${unwanted_files[@]}"; do
        if [[ -e "$unwanted" ]]; then
            log "Removing unwanted file/directory: $(basename "$unwanted")"
            rm -rf "$unwanted"
        fi
    done
}

# Validate that all required icons exist
validate_required_icons() {
    local appiconset_dir="$1"
    
    log "Validating required icon files..."
    
    local required_files=(
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
    
    local missing_files=()
    
    for required_file in "${required_files[@]}"; do
        local file_path="$appiconset_dir/$required_file"
        if [[ ! -f "$file_path" ]]; then
            missing_files+=("$required_file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        error "Missing required icon files:"
        for missing in "${missing_files[@]}"; do
            echo "  - $missing"
        done
        return 1
    else
        success "All required icon files present"
        return 0
    fi
}

# Fix a single AppIcon.appiconset
fix_appiconset() {
    local appiconset_dir="$1"
    local environment="$2"
    
    log "Fixing AppIcon.appiconset for $environment environment: $appiconset_dir"
    
    if [[ ! -d "$appiconset_dir" ]]; then
        error "AppIcon.appiconset directory not found: $appiconset_dir"
        return 1
    fi
    
    # Create backup
    local backup_dir="$appiconset_dir.backup.$(date +%Y%m%d_%H%M%S)"
    log "Creating backup at $backup_dir"
    cp -r "$appiconset_dir" "$backup_dir"
    
    # Clean unassigned files
    clean_unassigned_files "$appiconset_dir"
    
    # Create proper Contents.json
    create_contents_json "$appiconset_dir"
    
    # Validate required icons exist
    if ! validate_required_icons "$appiconset_dir"; then
        error "Missing required icon files. Please ensure all icon sizes are present."
        return 1
    fi
    
    success "$environment AppIcon.appiconset fixed successfully!"
    return 0
}

# Create Sandbox Assets.xcassets if it doesn't exist
create_sandbox_assets() {
    local sandbox_dir="$MACOS_DIR/FinanceMate-Sandbox/FinanceMate-Sandbox"
    local sandbox_assets="$sandbox_dir/Assets.xcassets"
    local sandbox_appiconset="$sandbox_assets/AppIcon.appiconset"
    
    if [[ ! -d "$sandbox_assets" ]]; then
        log "Creating Sandbox Assets.xcassets directory..."
        mkdir -p "$sandbox_appiconset"
        
        # Copy icon files from Production
        local prod_appiconset="$MACOS_DIR/FinanceMate/FinanceMate/Assets.xcassets/AppIcon.appiconset"
        if [[ -d "$prod_appiconset" ]]; then
            log "Copying icon files from Production to Sandbox..."
            cp "$prod_appiconset"/icon_*.png "$sandbox_appiconset/" 2>/dev/null || true
        fi
        
        success "Sandbox Assets.xcassets created"
    fi
}

# Main function
main() {
    log "Starting AppIcon asset fix process..."
    
    local total_errors=0
    
    # Fix Production AppIcon.appiconset
    local prod_appiconset="$MACOS_DIR/FinanceMate/FinanceMate/Assets.xcassets/AppIcon.appiconset"
    if ! fix_appiconset "$prod_appiconset" "Production"; then
        ((total_errors++))
    fi
    
    # Create and fix Sandbox AppIcon.appiconset
    create_sandbox_assets
    local sandbox_appiconset="$MACOS_DIR/FinanceMate-Sandbox/FinanceMate-Sandbox/Assets.xcassets/AppIcon.appiconset"
    if ! fix_appiconset "$sandbox_appiconset" "Sandbox"; then
        ((total_errors++))
    fi
    
    echo ""
    if [[ $total_errors -eq 0 ]]; then
        success "All AppIcon assets fixed successfully!"
        log ""
        log "Summary of changes:"
        log "- Removed unassigned files causing Xcode warnings"
        log "- Created proper Contents.json for App Store compliance"
        log "- Ensured both Production and Sandbox have identical icon configurations"
        log ""
        log "You can now build without icon warnings!"
        exit 0
    else
        error "AppIcon asset fix failed with $total_errors errors"
        exit 1
    fi
}

# Run main function
main "$@"