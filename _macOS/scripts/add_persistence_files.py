#!/usr/bin/env python3
"""
Add missing Persistence folder files to FinanceMate Xcode project
Critical P0 build fix: CoreDataModel.swift and PreviewDataProvider.swift
"""

import os
import sys
import subprocess
import glob

def add_persistence_files_to_xcode():
    """Add all Persistence folder Swift files to the Xcode project"""
    
    # Navigate to project directory
    project_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    os.chdir(project_dir)
    
    # Find all Swift files in the Persistence folder
    persistence_files = glob.glob("FinanceMate/FinanceMate/Persistence/*.swift")
    
    if not persistence_files:
        print("❌ No Swift files found in Persistence folder")
        return False
    
    print(f"📁 Found {len(persistence_files)} Persistence Swift files:")
    for file in persistence_files:
        print(f"   - {file}")
    
    # Add each file to the Xcode project using Python
    try:
        # Using a simple approach: modify the project.pbxproj file directly
        import uuid
        
        # Read the project file
        pbxproj_path = "FinanceMate.xcodeproj/project.pbxproj"
        with open(pbxproj_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Create backup
        with open(f"{pbxproj_path}.backup_persistence", 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Find the FinanceMate group and sources build phase
        lines = content.split('\n')
        modified = False
        
        # Add files to the PBXFileReference section
        file_refs = []
        for file_path in persistence_files:
            file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
            file_name = os.path.basename(file_path)
            relative_path = file_path.replace('FinanceMate/FinanceMate/', '')
            
            file_ref_line = f'\t\t{file_uuid} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = "<group>"; }};'
            
            # Find a good place to insert (after other PBXFileReference entries)
            for i, line in enumerate(lines):
                if "PBXFileReference" in line and "sourcecode.swift" in line and not modified:
                    lines.insert(i + 1, file_ref_line)
                    file_refs.append((file_uuid, file_name))
                    modified = True
                    break
        
        if modified:
            # Write the modified content back
            with open(pbxproj_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(lines))
            
            print("✅ Successfully added Persistence files to Xcode project")
            return True
        else:
            print("❌ Failed to modify project.pbxproj file")
            return False
            
    except Exception as e:
        print(f"❌ Error adding files to Xcode project: {e}")
        return False

def verify_build_after_changes():
    """Verify that the build works after adding files"""
    print("\n🔨 Verifying build after adding Persistence files...")
    
    try:
        result = subprocess.run([
            'xcodebuild', '-project', 'FinanceMate.xcodeproj', 
            '-scheme', 'FinanceMate', '-configuration', 'Debug', 
            'build'
        ], capture_output=True, text=True, timeout=120)
        
        if result.returncode == 0:
            print("✅ BUILD SUCCEEDED - Persistence files properly integrated")
            return True
        else:
            print(f"❌ BUILD FAILED - Additional issues remain:")
            print(result.stderr[-500:])  # Show last 500 chars of error
            return False
            
    except subprocess.TimeoutExpired:
        print("⏰ Build timed out - may still be in progress")
        return False
    except Exception as e:
        print(f"❌ Build verification error: {e}")
        return False

if __name__ == "__main__":
    print("🚨 P0 CRITICAL BUILD FIX: Adding missing Persistence files to Xcode project")
    
    # Add Persistence files to project
    if add_persistence_files_to_xcode():
        # Verify build works
        if verify_build_after_changes():
            print("\n🎉 SUCCESS: P0 build issue resolved - ready for modular breakdown")
            sys.exit(0)
        else:
            print("\n⚠️  Files added but build issues remain - need additional investigation")
            sys.exit(1)
    else:
        print("\n❌ FAILED: Could not add Persistence files to Xcode project")
        sys.exit(1)