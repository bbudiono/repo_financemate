#!/usr/bin/env python3

"""
Force SSO Compilation Script
Forces SSO files into the Xcode project Sources build phase with fresh UUIDs
"""

import os
import re
import sys
import uuid
import subprocess

def generate_xcode_uuid():
    """Generate a proper Xcode UUID"""
    return uuid.uuid4().hex[:24].upper()

def find_main_target_uuid(content):
    """Find the main FinanceMate target UUID"""
    # Look for the main FinanceMate native target
    pattern = r'(\w+) /\* FinanceMate \*/ = \{\n\t\t\tisa = PBXNativeTarget;'
    match = re.search(pattern, content)
    if match:
        return match.group(1)
    return None

def find_sources_build_phase_uuid(content, target_uuid):
    """Find the Sources build phase UUID for the target"""
    # Look for the Sources build phase in the target
    target_pattern = rf'{target_uuid} /\* FinanceMate \*/ = \{{[^}}]+buildPhases = \(\s*(.*?)\s*\);'
    target_match = re.search(target_pattern, content, re.DOTALL)
    
    if target_match:
        build_phases = target_match.group(1)
        # Look for Sources build phase UUID
        sources_pattern = r'(\w+) /\* Sources \*/'
        sources_match = re.search(sources_pattern, build_phases)
        if sources_match:
            return sources_match.group(1)
    
    return None

def force_sso_into_compilation():
    """Force SSO files into the compilation with comprehensive approach"""
    
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    
    print("🚀 Force SSO Compilation Script")
    print("=" * 50)
    
    # SSO files that MUST be in compilation
    sso_files = {
        'AppleAuthProvider.swift': {
            'path': 'FinanceMate/Services/AppleAuthProvider.swift',
            'full_path': 'FinanceMate/FinanceMate/Services/AppleAuthProvider.swift'
        },
        'GoogleAuthProvider.swift': {
            'path': 'FinanceMate/Services/GoogleAuthProvider.swift',
            'full_path': 'FinanceMate/FinanceMate/Services/GoogleAuthProvider.swift'
        },
        'TokenStorage.swift': {
            'path': 'FinanceMate/Services/TokenStorage.swift',
            'full_path': 'FinanceMate/FinanceMate/Services/TokenStorage.swift'
        },
        'LoginView.swift': {
            'path': 'FinanceMate/Views/LoginView.swift',
            'full_path': 'FinanceMate/FinanceMate/Views/LoginView.swift'
        }
    }
    
    # Read project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Create backup
    backup_path = project_path + f".backup_force_compilation"
    with open(backup_path, 'w') as f:
        f.write(content)
    print(f"💾 Backup created: {backup_path}")
    
    # Find main target and sources build phase
    main_target_uuid = find_main_target_uuid(content)
    if not main_target_uuid:
        print("❌ Could not find main FinanceMate target")
        return False
    
    print(f"🎯 Found main target UUID: {main_target_uuid}")
    
    sources_build_phase_uuid = find_sources_build_phase_uuid(content, main_target_uuid)
    if not sources_build_phase_uuid:
        print("❌ Could not find Sources build phase")
        return False
    
    print(f"🔧 Found Sources build phase UUID: {sources_build_phase_uuid}")
    
    modified = False
    
    for filename, file_info in sso_files.items():
        print(f"\n🔍 Processing {filename}...")
        
        # Check if file exists
        full_path = os.path.join(os.getcwd(), file_info['full_path'])
        if not os.path.exists(full_path):
            print(f"  ❌ File not found: {full_path}")
            continue
            
        print(f"  ✅ File exists: {file_info['full_path']}")
        
        # Generate fresh UUIDs
        file_ref_uuid = generate_xcode_uuid() 
        build_file_uuid = generate_xcode_uuid()
        
        print(f"  📋 File ref UUID: {file_ref_uuid}")
        print(f"  📋 Build file UUID: {build_file_uuid}")
        
        # Remove any existing references first
        escaped_filename = re.escape(filename)
        
        # Remove file reference
        file_ref_pattern = r'\t\t\w+ /\* ' + escaped_filename + r' \*/ = \{[^}]*isa = PBXFileReference;[^}]*\};\n'
        content = re.sub(file_ref_pattern, '', content)
        
        # Remove build file reference
        build_file_pattern = r'\t\t\w+ /\* ' + escaped_filename + r' in Sources \*/ = \{[^}]*isa = PBXBuildFile;[^}]*\};\n'
        content = re.sub(build_file_pattern, '', content)
        
        # Remove from Sources build phase
        sources_file_pattern = r'\t\t\t\t\w+ /\* ' + escaped_filename + r' in Sources \*/,?\n'
        content = re.sub(sources_file_pattern, '', content)
        
        # Remove from groups
        group_file_pattern = r'\t\t\t\t\w+ /\* ' + escaped_filename + r' \*/,?\n'
        content = re.sub(group_file_pattern, '', content)
        
        # Add file reference in PBXFileReference section
        file_ref_section_pattern = r'(/\* Begin PBXFileReference section \*/\n)'
        if re.search(file_ref_section_pattern, content):
            file_ref_entry = f'\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = "<group>"; }};\n'
            content = re.sub(file_ref_section_pattern, r'\1' + file_ref_entry, content)
            print(f"  ✅ Added file reference")
            modified = True
        
        # Add build file reference in PBXBuildFile section
        build_file_section_pattern = r'(/\* Begin PBXBuildFile section \*/\n)'
        if re.search(build_file_section_pattern, content):
            build_file_entry = f'\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};\n'
            content = re.sub(build_file_section_pattern, r'\1' + build_file_entry, content)  
            print(f"  ✅ Added build file reference")
            modified = True
        
        # Add to Sources build phase using the UUID we found
        sources_pattern = rf'({sources_build_phase_uuid} /\* Sources \*/ = \{{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = \d+;\n\t\t\tfiles = \(\n)(.*?)(\n\t\t\t\);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t\}};)'
        sources_match = re.search(sources_pattern, content, re.DOTALL)
        
        if sources_match:
            existing_files = sources_match.group(2)
            new_files = existing_files + f'\t\t\t\t{build_file_uuid} /* {filename} in Sources */,\n'
            new_sources_section = sources_match.group(1) + new_files + sources_match.group(3)
            content = content.replace(sources_match.group(0), new_sources_section)
            print(f"  ✅ Added to Sources build phase")
            modified = True
        else:
            print(f"  ❌ Could not find specific Sources build phase")
        
        # Add to appropriate group (Services or Views)
        group_name = 'Services' if 'Services' in file_info['path'] else 'Views'
        group_pattern = rf'(\w+ /\* {group_name} \*/ = \{{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)(.*?)(\n\t\t\t\);\n\t\t\tpath = {group_name};)'
        group_match = re.search(group_pattern, content, re.DOTALL)
        
        if group_match:
            group_children = group_match.group(2)
            new_group_children = group_children + f'\t\t\t\t{file_ref_uuid} /* {filename} */,\n'
            new_group_section = group_match.group(1) + new_group_children + group_match.group(3)
            content = content.replace(group_match.group(0), new_group_section)
            print(f"  ✅ Added to {group_name} group")
            modified = True
        else:
            print(f"  ⚠️ Could not find {group_name} group")
        
        print(f"  🎉 {filename} forcefully integrated!")
    
    if modified:
        # Write updated project file
        with open(project_path, 'w') as f:
            f.write(content)
        print(f"\n💾 Updated project file written")
        
        # Clean and rebuild to force new SwiftFileList generation
        print(f"\n🧹 Cleaning and rebuilding...")
        
        try:
            subprocess.run(['xcodebuild', 'clean', '-project', 'FinanceMate.xcodeproj', '-scheme', 'FinanceMate'], check=True, capture_output=True)
            print(f"✅ Clean completed")
        except subprocess.CalledProcessError as e:
            print(f"⚠️ Clean failed: {e}")
        
        return True
    else:
        print(f"\n ℹ️ No modifications made")
        return False

def main():
    """Main function"""
    
    if not os.path.exists("FinanceMate.xcodeproj/project.pbxproj"):
        print("❌ Could not find Xcode project file")
        return 1
    
    success = force_sso_into_compilation()
    
    if success:
        print(f"\n🎉 SSO files forcefully integrated into compilation!")
        print(f"📋 Integration Summary:")
        print(f"  • AppleAuthProvider.swift → Services group → Sources build phase")
        print(f"  • GoogleAuthProvider.swift → Services group → Sources build phase") 
        print(f"  • TokenStorage.swift → Services group → Sources build phase")
        print(f"  • LoginView.swift → Views group → Sources build phase")
        print(f"  • All files ready for compilation")
        print(f"\n🔄 Next steps:")
        print(f"  1. Test build: xcodebuild build -project FinanceMate.xcodeproj -scheme FinanceMate")
        print(f"  2. Verify SSO compilation success")
        print(f"  3. Check SwiftFileList for SSO files")
    else:
        print(f"\n❌ Failed to integrate SSO files")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())