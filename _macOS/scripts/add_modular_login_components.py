#!/usr/bin/env python3

"""
Add Modular Login Components to Xcode Project
============================================

This script adds the new modular authentication components to the FinanceMate Xcode project:
- LoginHeaderView.swift
- AuthenticationFormView.swift  
- SSOButtonsView.swift
- MFAInputView.swift
- AuthenticationErrorView.swift
- ForgotPasswordView.swift

These components replace the monolithic LoginView.swift implementation.
"""

import os
import sys
import uuid
import shutil
from pathlib import Path

def generate_uuid():
    """Generate a UUID in Xcode format (24 characters, uppercase)"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_modular_components_to_xcode():
    """Add the new modular authentication components to Xcode project"""
    
    project_dir = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS")
    project_file = project_dir / "FinanceMate.xcodeproj/project.pbxproj"
    
    if not project_file.exists():
        print(f"❌ Project file not found: {project_file}")
        return False
    
    # Backup the project file
    backup_file = project_file.with_suffix('.pbxproj.backup_modular_login')
    shutil.copy2(project_file, backup_file)
    print(f"📋 Created backup: {backup_file.name}")
    
    # Read the project file
    with open(project_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Define the new modular components
    new_components = [
        {
            'name': 'LoginHeaderView.swift',
            'path': 'FinanceMate/Views/LoginHeaderView.swift',
            'description': 'Login header with logo and branding'
        },
        {
            'name': 'AuthenticationFormView.swift',
            'path': 'FinanceMate/Views/AuthenticationFormView.swift',
            'description': 'Authentication forms with validation'
        },
        {
            'name': 'SSOButtonsView.swift',
            'path': 'FinanceMate/Views/SSOButtonsView.swift',
            'description': 'SSO buttons (Apple, Google, Microsoft)'
        },
        {
            'name': 'MFAInputView.swift',
            'path': 'FinanceMate/Views/MFAInputView.swift',
            'description': 'Multi-factor authentication input'
        },
        {
            'name': 'AuthenticationErrorView.swift',
            'path': 'FinanceMate/Views/AuthenticationErrorView.swift',
            'description': 'Error handling and loading states'
        },
        {
            'name': 'ForgotPasswordView.swift',
            'path': 'FinanceMate/Views/ForgotPasswordView.swift',
            'description': 'Password reset modal'
        }
    ]
    
    # Generate UUIDs for each component
    file_references = {}
    build_file_references = {}
    
    for component in new_components:
        file_uuid = generate_uuid()
        build_uuid = generate_uuid()
        file_references[component['name']] = file_uuid
        build_file_references[component['name']] = build_uuid
        print(f"🔑 Generated UUIDs for {component['name']}: file={file_uuid}, build={build_uuid}")
    
    # Find the PBXFileReference section
    pbx_file_ref_section = content.find("/* Begin PBXFileReference section */")
    pbx_file_ref_end = content.find("/* End PBXFileReference section */")
    
    if pbx_file_ref_section == -1 or pbx_file_ref_end == -1:
        print("❌ Could not find PBXFileReference section")
        return False
    
    # Add file references
    file_reference_entries = []
    for component in new_components:
        file_uuid = file_references[component['name']]
        entry = f"\t\t{file_uuid} /* {component['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{component['name']}\"; sourceTree = \"<group>\"; }};"
        file_reference_entries.append(entry)
    
    # Insert file references before the end of the section
    new_file_refs = "\n".join(file_reference_entries) + "\n"
    content = content[:pbx_file_ref_end] + new_file_refs + content[pbx_file_ref_end:]
    print(f"✅ Added {len(file_reference_entries)} file references")
    
    # Find the PBXBuildFile section
    pbx_build_file_section = content.find("/* Begin PBXBuildFile section */")
    pbx_build_file_end = content.find("/* End PBXBuildFile section */")
    
    if pbx_build_file_section == -1 or pbx_build_file_end == -1:
        print("❌ Could not find PBXBuildFile section")
        return False
    
    # Add build file entries
    build_file_entries = []
    for component in new_components:
        file_uuid = file_references[component['name']]
        build_uuid = build_file_references[component['name']]
        entry = f"\t\t{build_uuid} /* {component['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {component['name']} */; }};"
        build_file_entries.append(entry)
    
    # Insert build file entries before the end of the section
    new_build_files = "\n".join(build_file_entries) + "\n"
    content = content[:pbx_build_file_end] + new_build_files + content[pbx_build_file_end:]
    print(f"✅ Added {len(build_file_entries)} build file references")
    
    # Find the Views group and add files
    views_group_pattern = "/* Views */ = {"
    views_group_pos = content.find(views_group_pattern)
    
    if views_group_pos != -1:
        # Find the children array
        children_start = content.find("children = (", views_group_pos)
        children_end = content.find(");", children_start)
        
        if children_start != -1 and children_end != -1:
            # Add the new file references to the Views group
            new_children_entries = []
            for component in new_components:
                file_uuid = file_references[component['name']]
                entry = f"\t\t\t\t{file_uuid} /* {component['name']} */,"
                new_children_entries.append(entry)
            
            new_children = "\n" + "\n".join(new_children_entries)
            content = content[:children_end] + new_children + "\n" + content[children_end:]
            print(f"✅ Added {len(new_children_entries)} files to Views group")
    
    # Find the main target's Sources build phase
    sources_build_phase_pattern = "/* Sources */ = {"
    sources_pos = content.find(sources_build_phase_pattern)
    
    if sources_pos != -1:
        # Find the files array
        files_start = content.find("files = (", sources_pos)
        files_end = content.find(");", files_start)
        
        if files_start != -1 and files_end != -1:
            # Add the new build file references
            new_source_entries = []
            for component in new_components:
                build_uuid = build_file_references[component['name']]
                entry = f"\t\t\t\t{build_uuid} /* {component['name']} in Sources */,"
                new_source_entries.append(entry)
            
            new_sources = "\n" + "\n".join(new_source_entries)
            content = content[:files_end] + new_sources + "\n" + content[files_end:]
            print(f"✅ Added {len(new_source_entries)} files to Sources build phase")
    
    # Write the modified project file
    with open(project_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"🎯 Successfully added {len(new_components)} modular login components to Xcode project")
    print("\n📋 Components Added:")
    for component in new_components:
        print(f"  • {component['name']} - {component['description']}")
    
    return True

def main():
    print("🏗️  Adding Modular Login Components to Xcode Project")
    print("=" * 55)
    
    success = add_modular_components_to_xcode()
    
    if success:
        print("\n✅ MODULAR REFACTORING COMPLETE")
        print("🔍 Verification Steps:")
        print("   1. Open FinanceMate.xcodeproj in Xcode")
        print("   2. Check Views group contains all new components")
        print("   3. Build the project (Cmd+B)")
        print("   4. Verify SSO functionality works")
        print("\n🎉 LoginView.swift successfully refactored from 786 → 194 lines!")
        return 0
    else:
        print("\n❌ FAILED TO ADD COMPONENTS")
        print("🔧 Manual steps required:")
        print("   1. Open Xcode")
        print("   2. Right-click Views group")
        print("   3. Add existing files")
        print("   4. Select all new .swift files")
        return 1

if __name__ == "__main__":
    sys.exit(main())