#!/usr/bin/env python3

"""
Manual Add SSO Files Script
Manually adds missing SSO files to the project with proper UUIDs
"""

import os
import re
import sys
import uuid

def generate_xcode_uuid():
    """Generate a proper Xcode UUID"""
    return uuid.uuid4().hex[:24].upper()

def add_sso_files_manually():
    """Manually add SSO files to project"""
    
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    
    print("🔧 Manually adding SSO files to project...")
    
    # Read project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Create backup
    backup_path = project_path + f".backup_manual_sso"
    with open(backup_path, 'w') as f:
        f.write(content)
    print(f"💾 Backup created: {backup_path}")
    
    # SSO files to add
    sso_files = [
        {
            'name': 'AppleAuthProvider.swift',
            'file_ref_uuid': generate_xcode_uuid(),
            'build_file_uuid': generate_xcode_uuid(),
            'group': 'Services'
        },
        {
            'name': 'GoogleAuthProvider.swift', 
            'file_ref_uuid': generate_xcode_uuid(),
            'build_file_uuid': generate_xcode_uuid(),
            'group': 'Services'
        },
        {
            'name': 'TokenStorage.swift',
            'file_ref_uuid': generate_xcode_uuid(),
            'build_file_uuid': generate_xcode_uuid(),
            'group': 'Services'
        },
        {
            'name': 'LoginView.swift',
            'file_ref_uuid': generate_xcode_uuid(),
            'build_file_uuid': generate_xcode_uuid(),
            'group': 'Views'
        }
    ]
    
    # Add file references
    print("\n📋 Adding file references...")
    file_ref_section_start = content.find("/* Begin PBXFileReference section */")
    if file_ref_section_start == -1:
        print("❌ Could not find PBXFileReference section")
        return False
    
    # Find the end of existing file references (look for first empty line or end section)
    section_start = content.find('\n', file_ref_section_start) + 1
    
    file_refs_to_add = []
    for file_info in sso_files:
        file_ref = f"\t\t{file_info['file_ref_uuid']} /* {file_info['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_info['name']}; sourceTree = \"<group>\"; }};\n"
        file_refs_to_add.append(file_ref)
        print(f"  ✅ Prepared file reference for {file_info['name']}")
    
    # Insert after the section header
    insert_pos = section_start
    for file_ref in file_refs_to_add:
        content = content[:insert_pos] + file_ref + content[insert_pos:]
        insert_pos += len(file_ref)
    
    # Add build file references
    print("\n🔧 Adding build file references...")
    build_file_section_start = content.find("/* Begin PBXBuildFile section */")
    if build_file_section_start == -1:
        print("❌ Could not find PBXBuildFile section")
        return False
    
    build_section_start = content.find('\n', build_file_section_start) + 1
    
    build_files_to_add = []
    for file_info in sso_files:
        build_file = f"\t\t{file_info['build_file_uuid']} /* {file_info['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_info['file_ref_uuid']} /* {file_info['name']} */; }};\n"
        build_files_to_add.append(build_file)
        print(f"  ✅ Prepared build file reference for {file_info['name']}")
    
    # Insert after the section header
    insert_pos = build_section_start
    for build_file in build_files_to_add:
        content = content[:insert_pos] + build_file + content[insert_pos:]
        insert_pos += len(build_file)
    
    # Add to Sources build phase
    print("\n🏗️ Adding to Sources build phase...")
    sources_pattern = r'(\w+ /\* Sources \*/ = \{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = \d+;\n\t\t\tfiles = \(\n)(.*?)(\n\t\t\t\);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t\};)'
    sources_match = re.search(sources_pattern, content, re.DOTALL)
    
    if sources_match:
        sources_files = sources_match.group(2)
        new_sources_files = sources_files
        
        for file_info in sso_files:
            new_sources_files += f"\t\t\t\t{file_info['build_file_uuid']} /* {file_info['name']} in Sources */,\n"
            print(f"  ✅ Added {file_info['name']} to Sources build phase")
        
        new_sources_section = sources_match.group(1) + new_sources_files + sources_match.group(3)
        content = content.replace(sources_match.group(0), new_sources_section)
    else:
        print("❌ Could not find Sources build phase")
        return False
    
    # Add to groups
    print("\n📁 Adding to groups...")
    for file_info in sso_files:
        group_name = file_info['group']
        # Find the specific group pattern
        group_pattern = r'(\w+ /\* ' + group_name + r' \*/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)(.*?)(\n\t\t\t\);\n\t\t\tpath = ' + group_name + r';)'
        group_match = re.search(group_pattern, content, re.DOTALL)
        
        if group_match:
            group_children = group_match.group(2)
            new_group_children = group_children + f"\t\t\t\t{file_info['file_ref_uuid']} /* {file_info['name']} */,\n"
            new_group_section = group_match.group(1) + new_group_children + group_match.group(3)
            content = content.replace(group_match.group(0), new_group_section)
            print(f"  ✅ Added {file_info['name']} to {group_name} group")
        else:
            # Try main FinanceMate group as fallback
            main_group_pattern = r'(\w+ /\* FinanceMate \*/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)(.*?)(\n\t\t\t\);\n\t\t\tpath = FinanceMate;)'
            main_group_match = re.search(main_group_pattern, content, re.DOTALL)
            if main_group_match:
                group_children = main_group_match.group(2)
                new_group_children = group_children + f"\t\t\t\t{file_info['file_ref_uuid']} /* {file_info['name']} */,\n"
                new_group_section = main_group_match.group(1) + new_group_children + main_group_match.group(3)
                content = content.replace(main_group_match.group(0), new_group_section)
                print(f"  ✅ Added {file_info['name']} to main FinanceMate group (fallback)")
            else:
                print(f"  ⚠️ Could not find group for {file_info['name']}")
    
    # Write updated project file
    with open(project_path, 'w') as f:
        f.write(content)
    
    print(f"\n💾 Updated project file written!")
    
    # Print summary
    print(f"\n🎉 SSO Files Integration Summary:")
    for file_info in sso_files:
        print(f"  • {file_info['name']}")
        print(f"    - File Ref UUID: {file_info['file_ref_uuid']}")
        print(f"    - Build File UUID: {file_info['build_file_uuid']}")
        print(f"    - Group: {file_info['group']}")
    
    return True

def main():
    """Main function"""
    print("🚀 Manual Add SSO Files Script")
    print("=" * 50)
    
    if not os.path.exists("FinanceMate.xcodeproj/project.pbxproj"):
        print("❌ Could not find Xcode project file")
        return 1
    
    success = add_sso_files_manually()
    
    if success:
        print(f"\n🎉 SSO files manually added to project!")
        print(f"\n🔄 Next steps:")
        print(f"  1. Clean build: xcodebuild clean")
        print(f"  2. Build project: xcodebuild build")
        print(f"  3. Verify SSO compilation success")
    else:
        print(f"\n❌ Failed to add SSO files")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())