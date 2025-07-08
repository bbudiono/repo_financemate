#!/bin/zsh

# automate_xcode_config.sh
#
# This script automates the two manual configuration steps required for
# FinanceMate production deployment:
#
# 1. Apple Developer Team Configuration
# 2. Core Data Build Phase Configuration
#
# Usage: ./scripts/automate_xcode_config.sh [TEAM_ID]
#
# If TEAM_ID is not provided, it will use the environment variable APPLE_TEAM_ID
# or prompt for manual input.

set -e

echo "🔧 FinanceMate Xcode Configuration Automation"
echo "=============================================="

# --- Configuration ---
PROJECT_DIR="_macOS"
PROJECT_PATH="$PROJECT_DIR/FinanceMate.xcodeproj"
PBXPROJ_PATH="$PROJECT_PATH/project.pbxproj"
CORE_DATA_MODEL_PATH="$PROJECT_DIR/FinanceMate/FinanceMate/Models/FinanceMateModel.xcdatamodeld"

# --- Validate Environment ---
echo "🔍 Validating project structure..."

if [ ! -f "$PBXPROJ_PATH" ]; then
    echo "❌ Project file not found: $PBXPROJ_PATH"
    exit 1
fi

if [ ! -d "$CORE_DATA_MODEL_PATH" ]; then
    echo "❌ Core Data model not found: $CORE_DATA_MODEL_PATH"
    exit 1
fi

echo "✅ Project structure validated"

# --- Apple Developer Team Configuration ---
echo ""
echo "🍎 Configuring Apple Developer Team..."

# Determine Team ID
TEAM_ID=""
if [ -n "$1" ]; then
    TEAM_ID="$1"
    echo "✅ Using Team ID from command line argument: $TEAM_ID"
elif [ -n "$APPLE_TEAM_ID" ]; then
    TEAM_ID="$APPLE_TEAM_ID"
    echo "✅ Using Team ID from environment variable: $TEAM_ID"
else
    echo "⚠️  No Team ID provided. Current configuration will be used."
    # Extract current team ID from project file
    CURRENT_TEAM_ID=$(grep -m 1 "DEVELOPMENT_TEAM = " "$PBXPROJ_PATH" | sed 's/.*DEVELOPMENT_TEAM = \([^;]*\);.*/\1/' | tr -d ' ')
    if [ -n "$CURRENT_TEAM_ID" ]; then
        echo "📋 Current Team ID in project: $CURRENT_TEAM_ID"
        echo "   To change it, run: $0 NEW_TEAM_ID"
    else
        echo "❌ No Team ID found in project file and none provided"
        echo "   Please provide Team ID: $0 YOUR_TEAM_ID"
        exit 1
    fi
    TEAM_ID="$CURRENT_TEAM_ID"
fi

# Update Team ID in project file if provided
if [ -n "$TEAM_ID" ] && [ "$TEAM_ID" != "USE_CURRENT" ]; then
    echo "🔄 Updating DEVELOPMENT_TEAM in project file to: $TEAM_ID"
    
    # Create backup
    cp "$PBXPROJ_PATH" "$PBXPROJ_PATH.backup-$(date +%Y%m%d_%H%M%S)"
    
    # Update all DEVELOPMENT_TEAM entries
    sed -i '' "s/DEVELOPMENT_TEAM = [^;]*/DEVELOPMENT_TEAM = $TEAM_ID/g" "$PBXPROJ_PATH"
    
    # Verify changes
    UPDATED_COUNT=$(grep -c "DEVELOPMENT_TEAM = $TEAM_ID" "$PBXPROJ_PATH")
    echo "✅ Updated $UPDATED_COUNT DEVELOPMENT_TEAM entries"
    
    # Also update ExportOptions.plist if it exists
    EXPORT_OPTIONS_PATH="$PROJECT_DIR/ExportOptions.plist"
    if [ -f "$EXPORT_OPTIONS_PATH" ]; then
        echo "🔄 Updating ExportOptions.plist teamID..."
        # Create backup
        cp "$EXPORT_OPTIONS_PATH" "$EXPORT_OPTIONS_PATH.backup-$(date +%Y%m%d_%H%M%S)"
        
        # Update teamID in plist
        /usr/libexec/PlistBuddy -c "Set :teamID $TEAM_ID" "$EXPORT_OPTIONS_PATH" 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :teamID string $TEAM_ID" "$EXPORT_OPTIONS_PATH"
        
        echo "✅ Updated ExportOptions.plist teamID"
    fi
fi

# --- Core Data Build Phase Configuration ---
echo ""
echo "💾 Configuring Core Data Build Phase..."

# Check if Core Data model is already in build phase
if grep -q "FinanceMateModel.xcdatamodeld" "$PBXPROJ_PATH"; then
    echo "✅ Core Data model already configured in build phase"
else
    echo "🔄 Adding Core Data model to build phase..."
    
    # This is a complex operation that requires careful manipulation of the pbxproj file
    # For safety, we'll use a Python script to handle this
    
    # Create a temporary Python script for pbxproj manipulation
    cat > /tmp/add_coredata_to_pbxproj.py << 'EOF'
#!/usr/bin/env python3
import sys
import uuid
import re

def add_coredata_to_pbxproj(pbxproj_path, coredata_path):
    """Add Core Data model to Xcode project build phase"""
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Generate unique IDs for the new entries
    fileref_id = ''.join([format(x, 'X') for x in uuid.uuid4().bytes[:12]])
    buildfile_id = ''.join([format(x, 'X') for x in uuid.uuid4().bytes[:12]])
    
    # Extract relative path for Core Data model
    coredata_rel_path = coredata_path.replace('_macOS/FinanceMate/', '')
    
    # Add PBXFileReference entry
    fileref_section = re.search(r'(/\* Begin PBXFileReference section \*/.*?)/\* End PBXFileReference section \*/', content, re.DOTALL)
    if fileref_section:
        fileref_entry = f'\t\t{fileref_id} /* FinanceMateModel.xcdatamodeld */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.xcdatamodel; path = FinanceMateModel.xcdatamodeld; sourceTree = "<group>"; versionGroupType = wrapper.xcdatamodel; }};\n'
        new_fileref_section = fileref_section.group(1) + fileref_entry + '\t/* End PBXFileReference section */'
        content = content.replace(fileref_section.group(0), new_fileref_section)
    
    # Add PBXBuildFile entry
    buildfile_section = re.search(r'(/\* Begin PBXBuildFile section \*/.*?)/\* End PBXBuildFile section \*/', content, re.DOTALL)
    if buildfile_section:
        buildfile_entry = f'\t\t{buildfile_id} /* FinanceMateModel.xcdatamodeld in Sources */ = {{isa = PBXBuildFile; fileRef = {fileref_id} /* FinanceMateModel.xcdatamodeld */; }};\n'
        new_buildfile_section = buildfile_section.group(1) + buildfile_entry + '\t/* End PBXBuildFile section */'
        content = content.replace(buildfile_section.group(0), new_buildfile_section)
    
    # Find the main app target's Sources build phase and add the build file
    # This is a simplified approach - in a real scenario, you'd want to identify the correct target
    sources_phases = re.findall(r'([\w\d]+) /\* Sources \*/ = \{[^}]*isa = PBXSourcesBuildPhase;[^}]*files = \(([^)]*)\);', content, re.DOTALL)
    
    for phase_id, files_content in sources_phases:
        # Add to the main app target (not test targets)
        if 'FinanceMateApp.swift' in files_content:
            new_files_content = files_content.rstrip() + f'\n\t\t\t\t{buildfile_id} /* FinanceMateModel.xcdatamodeld in Sources */,'
            content = content.replace(files_content, new_files_content)
            break
    
    # Add to group structure (simplified)
    models_group = re.search(r'([\w\d]+) /\* Models \*/ = \{[^}]*isa = PBXGroup;[^}]*children = \(([^)]*)\);', content, re.DOTALL)
    if models_group:
        group_id, children_content = models_group.groups()
        new_children_content = children_content.rstrip() + f'\n\t\t\t\t{fileref_id} /* FinanceMateModel.xcdatamodeld */,'
        content = content.replace(children_content, new_children_content)
    
    # Write back to file
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    return True

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 add_coredata_to_pbxproj.py <pbxproj_path> <coredata_path>")
        sys.exit(1)
    
    pbxproj_path = sys.argv[1]
    coredata_path = sys.argv[2]
    
    try:
        add_coredata_to_pbxproj(pbxproj_path, coredata_path)
        print("✅ Successfully added Core Data model to build phase")
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)
EOF
    
    # Run the Python script to add Core Data model
    python3 /tmp/add_coredata_to_pbxproj.py "$PBXPROJ_PATH" "$CORE_DATA_MODEL_PATH"
    
    # Clean up temporary script
    rm /tmp/add_coredata_to_pbxproj.py
    
    echo "✅ Core Data model added to build phase"
fi

# --- Validation ---
echo ""
echo "🔍 Validating configuration..."

# Test build to ensure everything works
echo "🏗️ Testing build configuration..."
cd "$PROJECT_DIR"

# Clean build directory first
echo "🧹 Cleaning build directory..."
xcodebuild clean -project FinanceMate.xcodeproj -scheme FinanceMate -quiet

# Attempt to build
echo "🔨 Testing build..."
if xcodebuild build -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug -quiet; then
    echo "✅ Build test successful!"
else
    echo "❌ Build test failed. Please check the configuration."
    echo "   You may need to manually verify the Core Data model is properly added."
    exit 1
fi

cd - > /dev/null

# --- Summary ---
echo ""
echo "🎉 Configuration Complete!"
echo "=========================="
echo "✅ Apple Developer Team: $TEAM_ID"
echo "✅ Core Data Build Phase: Configured"
echo "✅ Build Test: Passed"
echo ""
echo "🚀 Next Steps:"
echo "1. Run ./scripts/build_and_sign.sh to create production build"
echo "2. Test the application on a clean system"
echo "3. Submit for App Store review or distribute as needed"
echo ""
echo "📋 Backup Files Created:"
echo "   • $PBXPROJ_PATH.backup-$(date +%Y%m%d_%H%M%S)"
if [ -f "$PROJECT_DIR/ExportOptions.plist.backup-$(date +%Y%m%d_%H%M%S)" ]; then
    echo "   • $PROJECT_DIR/ExportOptions.plist.backup-$(date +%Y%m%d_%H%M%S)"
fi