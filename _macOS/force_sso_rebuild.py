#!/usr/bin/env python3

"""
Force SSO Rebuild Script
Forcefully adds all SSO files to the Xcode project with proper target assignment
"""

import os
import re
import sys
import random
import string

def generate_uuid():
    """Generate a 24-character uppercase UUID for Xcode"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=24))

def find_project_file():
    """Find the Xcode project file"""
    current_dir = os.getcwd()
    for file in os.listdir(current_dir):
        if file.endswith('.xcodeproj'):
            return os.path.join(current_dir, file, "project.pbxproj")
    return None

def get_main_target_uuid(content):
    """Find the main target UUID"""
    # Look for the FinanceMate target
    target_match = re.search(r'(\w+) /\* FinanceMate \*/ = {\n\t\t\tisa = PBXNativeTarget;', content)
    if target_match:
        return target_match.group(1)
    return None

def force_add_file_to_project(project_path, file_path, filename):
    """Force add a file to the Xcode project with complete target integration"""
    
    print(f"🔧 Force adding {filename} to Xcode project...")
    
    # Read the project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Check if file is already properly integrated
    if filename in content and "in Sources" in content:
        # Check if it's in the Sources build phase
        sources_pattern = rf'{filename} in Sources'
        if re.search(sources_pattern, content):
            print(f"  ✅ {filename} already properly integrated")
            return content
    
    # Generate UUIDs
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()
    
    print(f"  📋 File ref UUID: {file_ref_uuid}")
    print(f"  📋 Build file UUID: {build_file_uuid}")
    
    # Remove any existing references to avoid duplicates
    content = re.sub(rf'\t\t\w+ /\* {re.escape(filename)} \*/ = {{isa = PBXFileReference;.*?}};\n', '', content)
    content = re.sub(rf'\t\t\w+ /\* {re.escape(filename)} in Sources \*/ = {{isa = PBXBuildFile;.*?}};\n', '', content)
    
    # Find file references section and add new reference
    file_ref_pattern = r'(/* Begin PBXFileReference section \*/\n)(.*?)(\n/* End PBXFileReference section \*/)'
    file_ref_match = re.search(file_ref_pattern, content, re.DOTALL)
    
    if file_ref_match:
        # Determine file type and path
        if filename.endswith('.swift'):
            file_type = 'sourcecode.swift'
        else:
            file_type = 'text'
            
        # Create the file reference entry
        file_ref_entry = f'\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = {filename}; sourceTree = "<group>"; }};\n'
        
        # Add to file references section
        new_file_refs = file_ref_match.group(1) + file_ref_match.group(2) + file_ref_entry + file_ref_match.group(3)
        content = content.replace(file_ref_match.group(0), new_file_refs)
        print(f"  ✅ Added file reference")
    else:
        print(f"  ❌ Could not find PBXFileReference section")
        return content
    
    # Find build files section and add new build file
    build_file_pattern = r'(/* Begin PBXBuildFile section \*/\n)(.*?)(\n/* End PBXBuildFile section \*/)'
    build_file_match = re.search(build_file_pattern, content, re.DOTALL)
    
    if build_file_match:
        # Create the build file entry
        build_file_entry = f'\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};\n'
        
        # Add to build files section
        new_build_files = build_file_match.group(1) + build_file_match.group(2) + build_file_entry + build_file_match.group(3)
        content = content.replace(build_file_match.group(0), new_build_files)
        print(f"  ✅ Added build file reference")
    else:
        print(f"  ❌ Could not find PBXBuildFile section")
        return content
    
    # Find the appropriate group and add the file
    if "Services/" in file_path:
        group_name = "Services"
    elif "Views/" in file_path:
        group_name = "Views"
    else:
        group_name = "FinanceMate"  # fallback to main group
    
    # Find the group and add the file reference
    group_pattern = rf'(\w+) /\* {group_name} \*/ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)(.*?)(\n\t\t\t\);\n\t\t\tpath = {group_name};)'
    group_match = re.search(group_pattern, content, re.DOTALL)
    
    if group_match:
        # Add to existing group
        group_children = group_match.group(2)
        new_group_children = group_children + f'\t\t\t\t{file_ref_uuid} /* {filename} */,\n'
        content = content.replace(group_match.group(2), new_group_children)
        print(f"  ✅ Added to {group_name} group")
    else:
        # Try to find main FinanceMate group as fallback
        main_group_pattern = r'(\w+) /\* FinanceMate \*/ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n(.*?)\n\t\t\t\);\n\t\t\tpath = FinanceMate;'
        main_group_match = re.search(main_group_pattern, content, re.DOTALL)
        if main_group_match:
            group_children = main_group_match.group(2)
            new_group_children = group_children + f'\t\t\t\t{file_ref_uuid} /* {filename} */,\n'
            content = content.replace(main_group_match.group(2), new_group_children)
            print(f"  ✅ Added to main FinanceMate group")
        else:
            print(f"  ⚠️  Could not find appropriate group")
    
    # Find the Sources build phase and add the file
    sources_pattern = r'(\w+ /\* Sources \*/ = {\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = \d+;\n\t\t\tfiles = \(\n)(.*?)(\n\t\t\t\);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};)'
    sources_match = re.search(sources_pattern, content, re.DOTALL)
    
    if sources_match:
        # Add to Sources build phase
        sources_files = sources_match.group(2)
        new_sources_files = sources_files + f'\t\t\t\t{build_file_uuid} /* {filename} in Sources */,\n'
        content = content.replace(sources_match.group(2), new_sources_files)
        print(f"  ✅ Added to Sources build phase")
    else:
        print(f"  ❌ Could not find Sources build phase")
        return content
    
    print(f"  🎉 {filename} forcefully integrated into project")
    return content

def main():
    """Main function"""
    print("🚀 Force SSO Rebuild Script")
    print("=" * 50)
    
    # Find project file
    project_path = find_project_file()
    if not project_path:
        print("❌ Could not find Xcode project file")
        return 1
    
    print(f"📂 Project file: {project_path}")
    
    # List of SSO files that need to be forcefully added
    sso_files = [
        "FinanceMate/FinanceMate/Services/AppleAuthProvider.swift",
        "FinanceMate/FinanceMate/Services/GoogleAuthProvider.swift", 
        "FinanceMate/FinanceMate/Services/TokenStorage.swift",
        "FinanceMate/FinanceMate/Views/LoginView.swift",
    ]
    
    # Check if files exist
    print(f"\n📋 Checking SSO files...")
    existing_files = []
    for file_path in sso_files:
        full_path = os.path.join(os.getcwd(), file_path)
        if os.path.exists(full_path):
            existing_files.append(file_path)
            print(f"  ✅ {file_path}")
        else:
            print(f"  ❌ {file_path} - FILE NOT FOUND")
    
    if not existing_files:
        print("❌ No SSO files found to add")
        return 1
    
    # Backup the project file
    backup_path = project_path + f".backup_force_sso"
    print(f"\n💾 Creating backup: {backup_path}")
    
    with open(project_path, 'r') as f:
        original_content = f.read()
    
    with open(backup_path, 'w') as f:
        f.write(original_content)
    
    # Force add files to project
    print(f"\n🔧 Force adding files to Xcode project...")
    content = original_content
    
    for file_path in existing_files:
        filename = os.path.basename(file_path)
        content = force_add_file_to_project(project_path, file_path, filename)
    
    # Write the updated project file
    print(f"\n💾 Writing updated project file...")
    with open(project_path, 'w') as f:
        f.write(content)
    
    print(f"\n🎉 SSO files forcefully integrated!")
    print(f"📋 Summary:")
    print(f"  • Forcefully integrated {len(existing_files)} SSO files")
    print(f"  • Backup created: {backup_path}")
    print(f"  • Project ready for compilation!")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())