#!/usr/bin/env python3

"""
SSO Compilation Fix Script
Adds all missing SSO-related files to the Xcode project target
"""

import os
import re
import sys

def find_project_file():
    """Find the Xcode project file"""
    current_dir = os.getcwd()
    for file in os.listdir(current_dir):
        if file.endswith('.xcodeproj'):
            return os.path.join(current_dir, file, "project.pbxproj")
    return None

def add_file_to_project(project_path, file_path, group_name="Services"):
    """Add a file to the Xcode project"""
    
    print(f"Adding {file_path} to Xcode project...")
    
    # Read the project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Get the filename
    filename = os.path.basename(file_path)
    
    # Check if file is already in project
    if filename in content:
        print(f"  ✅ {filename} already in project")
        return content
    
    # Generate UUIDs for the file references
    import random
    import string
    
    def generate_uuid():
        return ''.join(random.choices(string.ascii_uppercase + string.digits, k=24))
    
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()
    
    # Find the file references section
    file_ref_section = re.search(r'(/* Begin PBXFileReference section \*/.*?)(\n/* End PBXFileReference section \*/)', content, re.DOTALL)
    if not file_ref_section:
        print(f"  ❌ Could not find PBXFileReference section")
        return content
        
    # Add file reference
    file_ref_entry = f'\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = "<group>"; }};\n'
    new_file_ref_section = file_ref_section.group(1) + file_ref_entry + file_ref_section.group(2)
    content = content.replace(file_ref_section.group(0), new_file_ref_section)
    
    # Find the build files section
    build_file_section = re.search(r'(/* Begin PBXBuildFile section \*/.*?)(\n/* End PBXBuildFile section \*/)', content, re.DOTALL)
    if build_file_section:
        # Add build file entry
        build_file_entry = f'\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};\n'
        new_build_file_section = build_file_section.group(1) + build_file_entry + build_file_section.group(2)
        content = content.replace(build_file_section.group(0), new_build_file_section)
    
    # Find the Services group (or create it)
    services_group_pattern = rf'(\w+) /\* {group_name} \*/ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n(.*?)\n\t\t\t\);\n\t\t\tpath = {group_name};'
    services_match = re.search(services_group_pattern, content, re.DOTALL)
    
    if services_match:
        # Add to existing Services group
        group_children = services_match.group(2)
        new_children = group_children + f'\t\t\t\t{file_ref_uuid} /* {filename} */,\n'
        content = content.replace(services_match.group(2), new_children)
    else:
        print(f"  ⚠️  {group_name} group not found, file added to project but may need manual group assignment")
    
    # Find the Sources build phase and add the file
    sources_phase_pattern = r'(\w+ /\* Sources \*/ = {\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = \d+;\n\t\t\tfiles = \(\n)(.*?)(\n\t\t\t\);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};)'
    sources_match = re.search(sources_phase_pattern, content, re.DOTALL)
    
    if sources_match:
        # Add to Sources build phase
        sources_files = sources_match.group(2)
        new_sources = sources_files + f'\t\t\t\t{build_file_uuid} /* {filename} in Sources */,\n'
        content = content.replace(sources_match.group(2), new_sources)
    
    print(f"  ✅ {filename} added to project")
    return content

def main():
    """Main function"""
    print("🔧 SSO Compilation Fix Script")
    print("=" * 50)
    
    # Find project file
    project_path = find_project_file()
    if not project_path:
        print("❌ Could not find Xcode project file")
        return 1
    
    print(f"📂 Project file: {project_path}")
    
    # List of SSO files that need to be added
    sso_files = [
        ("FinanceMate/FinanceMate/Services/AppleAuthProvider.swift", "Services"),
        ("FinanceMate/FinanceMate/Services/GoogleAuthProvider.swift", "Services"),
        ("FinanceMate/FinanceMate/Services/TokenStorage.swift", "Services"),
        ("FinanceMate/FinanceMate/Views/LoginView.swift", "Views"),
    ]
    
    # Check if files exist
    print("\n📋 Checking SSO files...")
    existing_files = []
    for file_path, group in sso_files:
        full_path = os.path.join(os.getcwd(), file_path)
        if os.path.exists(full_path):
            existing_files.append((file_path, group))
            print(f"  ✅ {file_path}")
        else:
            print(f"  ❌ {file_path} - FILE NOT FOUND")
    
    if not existing_files:
        print("❌ No SSO files found to add")
        return 1
    
    # Backup the project file
    backup_path = project_path + f".backup_sso_fix"
    print(f"\n💾 Creating backup: {backup_path}")
    
    with open(project_path, 'r') as f:
        original_content = f.read()
    
    with open(backup_path, 'w') as f:
        f.write(original_content)
    
    # Add files to project
    print(f"\n🔧 Adding files to Xcode project...")
    content = original_content
    
    for file_path, group in existing_files:
        content = add_file_to_project(project_path, file_path, group)
    
    # Write the updated project file
    print(f"\n💾 Writing updated project file...")
    with open(project_path, 'w') as f:
        f.write(content)
    
    print(f"\n✅ SSO files added to Xcode project!")
    print(f"📋 Summary:")
    print(f"  • Added {len(existing_files)} SSO files to compilation")
    print(f"  • Backup created: {backup_path}")
    print(f"  • Ready to build!")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())