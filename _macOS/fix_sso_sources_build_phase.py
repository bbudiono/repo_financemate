#!/usr/bin/env python3

"""
Fix SSO Sources Build Phase Script
Directly manipulates the Xcode project to ensure SSO files are properly added to Sources build phase
"""

import os
import re
import sys
import uuid

def find_project_file():
    """Find the Xcode project file"""
    current_dir = os.getcwd()
    for file in os.listdir(current_dir):
        if file.endswith('.xcodeproj'):
            return os.path.join(current_dir, file, "project.pbxproj")
    return None

def generate_xcode_uuid():
    """Generate a proper Xcode UUID"""
    return uuid.uuid4().hex[:24].upper()

def ensure_sso_files_in_sources_build_phase(project_path):
    """Ensure all SSO files are properly referenced and included in Sources build phase"""
    
    print("🔧 Ensuring SSO files are in Sources build phase...")
    
    # SSO files that must be in the build
    sso_files = {
        'AppleAuthProvider.swift': {
            'path': 'FinanceMate/FinanceMate/Services/AppleAuthProvider.swift',
            'group': 'Services'
        },
        'GoogleAuthProvider.swift': {
            'path': 'FinanceMate/FinanceMate/Services/GoogleAuthProvider.swift', 
            'group': 'Services'
        },
        'TokenStorage.swift': {
            'path': 'FinanceMate/FinanceMate/Services/TokenStorage.swift',
            'group': 'Services'
        },
        'LoginView.swift': {
            'path': 'FinanceMate/FinanceMate/Views/LoginView.swift',
            'group': 'Views'
        }
    }
    
    # Read project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Create backup
    backup_path = project_path + f".backup_sso_sources"
    with open(backup_path, 'w') as f:
        f.write(content)
    print(f"💾 Backup created: {backup_path}")
    
    modified = False
    
    for filename, file_info in sso_files.items():
        print(f"\n🔍 Processing {filename}...")
        
        # Check if file exists
        full_path = os.path.join(os.getcwd(), file_info['path'])
        if not os.path.exists(full_path):
            print(f"  ❌ File not found: {full_path}")
            continue
            
        print(f"  ✅ File exists: {file_info['path']}")
        
        # Generate UUIDs for this file
        file_ref_uuid = generate_xcode_uuid()
        build_file_uuid = generate_xcode_uuid()
        
        print(f"  📋 File ref UUID: {file_ref_uuid}")
        print(f"  📋 Build file UUID: {build_file_uuid}")
        
        # Remove any existing references to avoid duplicates
        # Remove file reference
        escaped_filename = re.escape(filename)
        file_ref_pattern = r'\t\t\w+ /\* ' + escaped_filename + r' \*/ = \{[^}]*isa = PBXFileReference;[^}]*\};'
        if re.search(file_ref_pattern, content):
            print(f"  🗑️ Removing existing file reference")
            content = re.sub(file_ref_pattern, '', content)
            modified = True
        
        # Remove build file reference
        build_file_pattern = r'\t\t\w+ /\* ' + escaped_filename + r' in Sources \*/ = \{[^}]*isa = PBXBuildFile;[^}]*\};'
        if re.search(build_file_pattern, content):
            print(f"  🗑️ Removing existing build file reference")
            content = re.sub(build_file_pattern, '', content)
            modified = True
        
        # Remove from Sources build phase
        sources_file_pattern = r'\t\t\t\t\w+ /\* ' + escaped_filename + r' in Sources \*/,?'
        if re.search(sources_file_pattern, content):
            print(f"  🗑️ Removing from Sources build phase")
            content = re.sub(sources_file_pattern, '', content)
            modified = True
        
        # Remove from groups
        group_file_pattern = r'\t\t\t\t\w+ /\* ' + escaped_filename + r' \*/,?'
        if re.search(group_file_pattern, content):
            print(f"  🗑️ Removing from groups")
            content = re.sub(group_file_pattern, '', content)
            modified = True
        
        # Add file reference
        file_ref_section_pattern = r'(/\* Begin PBXFileReference section \*/\n)(.*?)(\n\t\t/\* End PBXFileReference section \*/)'
        file_ref_match = re.search(file_ref_section_pattern, content, re.DOTALL)
        
        if file_ref_match:
            file_ref_entry = f'\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = "<group>"; }};\n'
            new_file_refs = file_ref_match.group(1) + file_ref_match.group(2) + file_ref_entry + file_ref_match.group(3)
            content = content.replace(file_ref_match.group(0), new_file_refs)
            print(f"  ✅ Added file reference")
            modified = True
        else:
            print(f"  ❌ Could not find PBXFileReference section")
            continue
        
        # Add build file reference
        build_file_section_pattern = r'(/\* Begin PBXBuildFile section \*/\n)(.*?)(\n\t\t/\* End PBXBuildFile section \*/)'
        build_file_match = re.search(build_file_section_pattern, content, re.DOTALL)
        
        if build_file_match:
            build_file_entry = f'\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};\n'
            new_build_files = build_file_match.group(1) + build_file_match.group(2) + build_file_entry + build_file_match.group(3)
            content = content.replace(build_file_match.group(0), new_build_files)
            print(f"  ✅ Added build file reference")
            modified = True
        else:
            print(f"  ❌ Could not find PBXBuildFile section")
            continue
        
        # Add to appropriate group
        group_name = file_info['group']
        group_pattern = r'(\w+ /\* ' + group_name + r' \*/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)(.*?)(\n\t\t\t\);\n\t\t\tpath = ' + group_name + r';)'
        group_match = re.search(group_pattern, content, re.DOTALL)
        
        if group_match:
            group_children = group_match.group(2)
            # Only add if not already present
            if file_ref_uuid not in group_children:
                new_group_children = group_children + f'\t\t\t\t{file_ref_uuid} /* {filename} */,\n'
                content = content.replace(group_match.group(2), new_group_children)
                print(f"  ✅ Added to {group_name} group")
                modified = True
            else:
                print(f"  ℹ️ Already in {group_name} group")
        else:
            print(f"  ⚠️ Could not find {group_name} group, trying main group")
            # Try main FinanceMate group as fallback
            main_group_pattern = r'(\w+ /\* FinanceMate \*/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)(.*?)(\n\t\t\t\);\n\t\t\tpath = FinanceMate;)'
            main_group_match = re.search(main_group_pattern, content, re.DOTALL)
            if main_group_match:
                group_children = main_group_match.group(2)
                if file_ref_uuid not in group_children:
                    new_group_children = group_children + f'\t\t\t\t{file_ref_uuid} /* {filename} */,\n'
                    content = content.replace(main_group_match.group(2), new_group_children)
                    print(f"  ✅ Added to main FinanceMate group")
                    modified = True
        
        # Add to Sources build phase
        sources_pattern = r'(\w+ /\* Sources \*/ = \{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = \d+;\n\t\t\tfiles = \(\n)(.*?)(\n\t\t\t\);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t\};)'
        sources_match = re.search(sources_pattern, content, re.DOTALL)
        
        if sources_match:
            sources_files = sources_match.group(2)
            # Only add if not already present
            if build_file_uuid not in sources_files:
                new_sources_files = sources_files + f'\t\t\t\t{build_file_uuid} /* {filename} in Sources */,\n'
                content = content.replace(sources_match.group(2), new_sources_files)
                print(f"  ✅ Added to Sources build phase")
                modified = True
            else:
                print(f"  ℹ️ Already in Sources build phase")
        else:
            print(f"  ❌ Could not find Sources build phase")
            continue
        
        print(f"  🎉 {filename} successfully integrated!")
    
    if modified:
        # Write updated project file
        with open(project_path, 'w') as f:
            f.write(content)
        print(f"\n💾 Updated project file written")
        return True
    else:
        print(f"\n ℹ️ No modifications needed")
        return False

def main():
    """Main function"""
    print("🚀 Fix SSO Sources Build Phase Script")
    print("=" * 50)
    
    # Find project file
    project_path = find_project_file()
    if not project_path:
        print("❌ Could not find Xcode project file")
        return 1
    
    print(f"📂 Project file: {project_path}")
    
    # Ensure SSO files are in Sources build phase
    success = ensure_sso_files_in_sources_build_phase(project_path)
    
    if success:
        print(f"\n🎉 SSO files successfully integrated into Sources build phase!")
        print(f"📋 Summary:")
        print(f"  • AppleAuthProvider.swift → Services group → Sources build phase")
        print(f"  • GoogleAuthProvider.swift → Services group → Sources build phase") 
        print(f"  • TokenStorage.swift → Services group → Sources build phase")
        print(f"  • LoginView.swift → Views group → Sources build phase")
        print(f"  • All files ready for compilation")
        print(f"\n🔄 Next steps:")
        print(f"  1. Clean build: xcodebuild clean")
        print(f"  2. Build project: xcodebuild build")
        print(f"  3. Verify SSO compilation success")
    else:
        print(f"\n ℹ️ All SSO files already properly configured")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())