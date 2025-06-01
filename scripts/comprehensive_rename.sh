#!/bin/bash

# Comprehensive DocketMate -> FinanceMate Rename Script
# Generated: 2025-06-02

echo "🔄 Starting comprehensive rename from DocketMate to FinanceMate..."

# Function to rename directories
rename_directories() {
    echo "📁 Renaming directories..."
    
    # Rename main directories (from innermost to outermost to avoid conflicts)
    if [ -d "_macOS/DocketMate-Sandbox/DocketMate-Sandbox" ]; then
        mv "_macOS/DocketMate-Sandbox/DocketMate-Sandbox" "_macOS/DocketMate-Sandbox/FinanceMate-Sandbox"
        echo "✅ Renamed _macOS/DocketMate-Sandbox/DocketMate-Sandbox to FinanceMate-Sandbox"
    fi
    
    if [ -d "_macOS/DocketMate-Sandbox" ]; then
        mv "_macOS/DocketMate-Sandbox" "_macOS/FinanceMate-Sandbox"
        echo "✅ Renamed _macOS/DocketMate-Sandbox to FinanceMate-Sandbox"
    fi
    
    if [ -d "_macOS/DocketMate" ]; then
        mv "_macOS/DocketMate" "_macOS/FinanceMate"
        echo "✅ Renamed _macOS/DocketMate to FinanceMate"
    fi
    
    if [ -d "_macOS/DocketMateCore" ]; then
        mv "_macOS/DocketMateCore" "_macOS/FinanceMateCore"
        echo "✅ Renamed _macOS/DocketMateCore to FinanceMateCore"
    fi
    
    if [ -d "_macOS/DocketMateUnified" ]; then
        mv "_macOS/DocketMateUnified" "_macOS/FinanceMateUnified"
        echo "✅ Renamed _macOS/DocketMateUnified to FinanceMateUnified"
    fi
    
    if [ -d "_macOS/DocketMate_Sandbox" ]; then
        mv "_macOS/DocketMate_Sandbox" "_macOS/FinanceMate_Sandbox"
        echo "✅ Renamed _macOS/DocketMate_Sandbox to FinanceMate_Sandbox"
    fi
}

# Function to rename Xcode project files
rename_xcode_projects() {
    echo "🔨 Renaming Xcode project files..."
    
    # Rename Production project
    if [ -d "_macOS/FinanceMate/DocketMate.xcodeproj" ]; then
        mv "_macOS/FinanceMate/DocketMate.xcodeproj" "_macOS/FinanceMate/FinanceMate.xcodeproj"
        echo "✅ Renamed Production .xcodeproj"
    fi
    
    # Rename Sandbox project
    if [ -d "_macOS/FinanceMate-Sandbox/DocketMate-Sandbox.xcodeproj" ]; then
        mv "_macOS/FinanceMate-Sandbox/DocketMate-Sandbox.xcodeproj" "_macOS/FinanceMate-Sandbox/FinanceMate-Sandbox.xcodeproj"
        echo "✅ Renamed Sandbox .xcodeproj"
    fi
    
    # Rename workspace
    if [ -d "_macOS/DocketMate.xcworkspace" ]; then
        mv "_macOS/DocketMate.xcworkspace" "_macOS/FinanceMate.xcworkspace"
        echo "✅ Renamed .xcworkspace"
    fi
    
    # Rename archive
    if [ -d "_macOS/DocketMate.xcarchive" ]; then
        mv "_macOS/DocketMate.xcarchive" "_macOS/FinanceMate.xcarchive"
        echo "✅ Renamed .xcarchive"
    fi
    
    # Rename export
    if [ -d "_macOS/DocketMate-Export" ]; then
        mv "_macOS/DocketMate-Export" "_macOS/FinanceMate-Export"
        echo "✅ Renamed Export directory"
    fi
}

# Function to update file contents
update_file_contents() {
    echo "📝 Updating file contents..."
    
    # Update Xcode project files (pbxproj)
    find . -name "*.pbxproj" -type f -exec sed -i '' 's/DocketMate/FinanceMate/g' {} +
    echo "✅ Updated .pbxproj files"
    
    # Update plist files
    find . -name "*.plist" -type f -exec sed -i '' 's/DocketMate/FinanceMate/g' {} +
    echo "✅ Updated .plist files"
    
    # Update Swift files
    find . -name "*.swift" -type f -exec sed -i '' 's/DocketMate/FinanceMate/g' {} +
    echo "✅ Updated .swift files"
    
    # Update documentation files
    find . -name "*.md" -type f -exec sed -i '' 's/DocketMate/FinanceMate/g' {} +
    echo "✅ Updated .md files"
    
    # Update configuration files
    find . -name "*.json" -type f -exec sed -i '' 's/DocketMate/FinanceMate/g' {} +
    find . -name "*.yml" -type f -exec sed -i '' 's/DocketMate/FinanceMate/g' {} +
    echo "✅ Updated configuration files"
}

# Function to rename entitlements files
rename_entitlements() {
    echo "🔐 Renaming entitlements files..."
    
    if [ -f "_macOS/FinanceMate/DocketMate.entitlements" ]; then
        mv "_macOS/FinanceMate/DocketMate.entitlements" "_macOS/FinanceMate/FinanceMate.entitlements"
        echo "✅ Renamed Production entitlements"
    fi
    
    if [ -f "_macOS/FinanceMate-Sandbox/FinanceMate-Sandbox/DocketMate-Sandbox.entitlements" ]; then
        mv "_macOS/FinanceMate-Sandbox/FinanceMate-Sandbox/DocketMate-Sandbox.entitlements" "_macOS/FinanceMate-Sandbox/FinanceMate-Sandbox/FinanceMate-Sandbox.entitlements"
        echo "✅ Renamed Sandbox entitlements"
    fi
}

# Execute rename steps
echo "🚀 Beginning comprehensive rename process..."
echo ""

# Step 1: Rename directories
rename_directories
echo ""

# Step 2: Rename Xcode projects  
rename_xcode_projects
echo ""

# Step 3: Rename entitlements
rename_entitlements
echo ""

# Step 4: Update file contents (this should be last)
update_file_contents
echo ""

echo "✅ Comprehensive rename completed!"
echo "📋 Summary:"
echo "   - All directories renamed from DocketMate -> FinanceMate"
echo "   - All Xcode projects renamed"
echo "   - All source code references updated"
echo "   - All documentation updated"
echo "   - Bundle identifiers will need to be updated in Xcode"
echo ""
echo "⚠️  Next steps:"
echo "   1. Open Xcode and update Bundle IDs"
echo "   2. Verify builds are successful"
echo "   3. Update GitHub repository name"
echo "   4. Commit all changes"