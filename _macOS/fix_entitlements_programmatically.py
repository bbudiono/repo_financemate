#!/usr/bin/env python3
"""
ECOSYSTEM OPTIMIZER: Programmatic Entitlements Configuration Fix
Corrects misleading guidance about manual Xcode configuration - patches .pbxproj directly
"""

import re
import shutil
from datetime import datetime

def backup_pbxproj():
    """Create backup before modifying project file"""
    pbxproj_path = "FinanceMate.xcodeproj/project.pbxproj"
    backup_path = f"{pbxproj_path}.backup_entitlements_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    print(f"Creating backup: {backup_path}")
    shutil.copy2(pbxproj_path, backup_path)
    return backup_path

def add_entitlements_reference(pbxproj_content):
    """Add CODE_SIGN_ENTITLEMENTS build setting to all relevant build configurations"""
    
    # Define the entitlements setting to add
    entitlements_setting = '\t\t\t\tCODE_SIGN_ENTITLEMENTS = "FinanceMate/FinanceMate.entitlements";'
    
    # Pattern to find build configuration sections for FinanceMate target
    # Look for buildSettings sections that already have CODE_SIGN_IDENTITY
    pattern = r'(buildSettings = \{[^}]*CODE_SIGN_IDENTITY[^}]*?)(\n\t\t\t\};)'
    
    def replacement(match):
        build_settings = match.group(1)
        closing = match.group(2)
        
        # Only add if CODE_SIGN_ENTITLEMENTS is not already present
        if 'CODE_SIGN_ENTITLEMENTS' not in build_settings:
            return build_settings + '\n' + entitlements_setting + closing
        return match.group(0)
    
    # Apply the replacement
    modified_content = re.sub(pattern, replacement, pbxproj_content, flags=re.DOTALL)
    
    return modified_content

def verify_entitlements_file_exists():
    """Verify the entitlements file exists"""
    import os
    entitlements_path = "FinanceMate/FinanceMate.entitlements"
    if not os.path.exists(entitlements_path):
        print(f"ERROR: Entitlements file not found at {entitlements_path}")
        return False
    
    print(f"✅ Entitlements file verified at: {entitlements_path}")
    return True

def main():
    print("🔧 ECOSYSTEM OPTIMIZER: Programmatic Entitlements Configuration")
    print("Correcting misleading manual configuration guidance...")
    
    # Verify entitlements file exists
    if not verify_entitlements_file_exists():
        return False
    
    pbxproj_path = "FinanceMate.xcodeproj/project.pbxproj"
    
    # Create backup
    backup_path = backup_pbxproj()
    
    # Read current project file
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Check if CODE_SIGN_ENTITLEMENTS already exists
    if 'CODE_SIGN_ENTITLEMENTS' in content:
        print("✅ CODE_SIGN_ENTITLEMENTS already configured in project")
        return True
    
    # Add entitlements reference
    print("Adding CODE_SIGN_ENTITLEMENTS build setting...")
    modified_content = add_entitlements_reference(content)
    
    if modified_content == content:
        print("⚠️  No changes made - build configuration pattern not found")
        return False
    
    # Write modified content
    with open(pbxproj_path, 'w') as f:
        f.write(modified_content)
    
    print("✅ Successfully added CODE_SIGN_ENTITLEMENTS programmatically")
    print(f"   Backup created: {backup_path}")
    print("   Entitlements path: FinanceMate/FinanceMate.entitlements")
    
    return True

if __name__ == "__main__":
    success = main()
    if success:
        print("\n🎯 CORRECTION COMPLETE: Manual Xcode configuration NOT required")
        print("   Everything can be done programmatically via .pbxproj patching")
    else:
        print("\n❌ CORRECTION FAILED: Manual verification may be needed")