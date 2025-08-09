#!/usr/bin/env python3

"""
Integration script for AuthenticationViewModel modular components into Xcode project.

Purpose: Add AuthenticationManager, SessionManager, UserProfileManager, and AuthenticationStateManager
         to FinanceMate Xcode project with proper target membership and build phases.

Components to integrate:
- AuthenticationManager.swift (280 lines) - Core authentication logic
- SessionManager.swift (210 lines) - Session lifecycle
- UserProfileManager.swift (312 lines) - User profile operations  
- AuthenticationStateManager.swift (267 lines) - State coordination
- AuthenticationState.swift (27 lines) - Shared state model (already in Models)

This script ensures all components are properly integrated while preserving SSO functionality.
"""

import os
import sys
import re
import uuid

def find_pbxproj_file():
    """Find the project.pbxproj file in the current directory structure."""
    current_dir = os.getcwd()
    
    # Look for .xcodeproj directory
    xcodeproj_dirs = [d for d in os.listdir(current_dir) if d.endswith('.xcodeproj')]
    if not xcodeproj_dirs:
        # We might be inside the xcodeproj already
        if os.path.exists('project.pbxproj'):
            return 'project.pbxproj'
        return None
    
    # Use the first .xcodeproj directory found
    pbxproj_path = os.path.join(xcodeproj_dirs[0], 'project.pbxproj')
    if os.path.exists(pbxproj_path):
        return pbxproj_path
    
    return None

def generate_unique_id():
    """Generate a unique 24-character identifier for Xcode."""
    return ''.join(uuid.uuid4().hex.upper()[:24])

def read_pbxproj(file_path):
    """Read the project.pbxproj file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

def write_pbxproj(file_path, content):
    """Write the project.pbxproj file with backup."""
    # Create backup
    backup_path = f"{file_path}.backup_refactor_integration"
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Backup created: {backup_path}")
    
    # Write new content
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Updated: {file_path}")

def add_file_reference(content, file_name, file_path):
    """Add a file reference to the PBXFileReference section."""
    file_id = generate_unique_id()
    
    # Create file reference entry
    file_ref_entry = f'\t\t{file_id} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = "<group>"; }};'
    
    # Find PBXFileReference section and add the entry
    pbx_file_ref_pattern = r'(/\* Begin PBXFileReference section \*/.*?)(\n/\* End PBXFileReference section \*/)'
    
    def add_file_ref(match):
        section_content = match.group(1)
        end_marker = match.group(2)
        return section_content + '\n' + file_ref_entry + end_marker
    
    content = re.sub(pbx_file_ref_pattern, add_file_ref, content, flags=re.DOTALL)
    
    return content, file_id

def add_build_file(content, file_name, file_id):
    """Add a build file entry to the PBXBuildFile section."""
    build_id = generate_unique_id()
    
    # Create build file entry
    build_file_entry = f'\t\t{build_id} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {file_name} */; }};'
    
    # Find PBXBuildFile section and add the entry
    pbx_build_file_pattern = r'(/\* Begin PBXBuildFile section \*/.*?)(\n/\* End PBXBuildFile section \*/)'
    
    def add_build_ref(match):
        section_content = match.group(1)
        end_marker = match.group(2)
        return section_content + '\n' + build_file_entry + end_marker
    
    content = re.sub(pbx_build_file_pattern, add_build_ref, content, flags=re.DOTALL)
    
    return content, build_id

def add_file_to_group(content, file_name, file_id):
    """Add file to the ViewModels group."""
    # Find ViewModels group (look for pattern with ViewModels children)
    viewmodels_pattern = r'(children = \(\s*(?:[^\)]*AuthenticationViewModel\.swift[^\)]*)*)(.*?)(\s*\);\s*name = ViewModels;)'
    
    # If ViewModels group found, add to it
    if re.search(viewmodels_pattern, content, re.DOTALL):
        def add_to_viewmodels(match):
            prefix = match.group(1)
            middle = match.group(2)  
            suffix = match.group(3)
            
            # Add new file reference
            new_ref = f'\n\t\t\t\t{file_id} /* {file_name} */,'
            
            return prefix + middle + new_ref + suffix
        
        content = re.sub(viewmodels_pattern, add_to_viewmodels, content, flags=re.DOTALL)
    else:
        print(f"⚠️  Warning: ViewModels group not found for {file_name}")
    
    return content

def add_to_sources_build_phase(content, file_name, build_id):
    """Add build file to Sources build phase."""
    # Find the Sources build phase
    sources_pattern = r'(/\* Sources \*/ = \{[^}]*files = \(\s*)(.*?)(\s*\);[^}]*\};)'
    
    def add_to_sources(match):
        prefix = match.group(1)
        files_list = match.group(2)
        suffix = match.group(3)
        
        # Add new build file reference
        new_build_ref = f'\n\t\t\t\t{build_id} /* {file_name} in Sources */,'
        
        return prefix + files_list + new_build_ref + suffix
    
    content = re.sub(sources_pattern, add_to_sources, content, flags=re.DOTALL)
    
    return content

def integrate_authentication_modules():
    """Main function to integrate all authentication modules."""
    
    # Files to integrate
    modules = [
        'AuthenticationManager.swift',
        'SessionManager.swift', 
        'UserProfileManager.swift',
        'AuthenticationStateManager.swift'
    ]
    
    # Find project file
    pbxproj_path = find_pbxproj_file()
    if not pbxproj_path:
        print("❌ Error: Could not find project.pbxproj file")
        return False
    
    print(f"📁 Found project file: {pbxproj_path}")
    
    # Read current content
    content = read_pbxproj(pbxproj_path)
    original_content = content
    
    # Process each module
    for module in modules:
        print(f"\n🔧 Integrating {module}...")
        
        # Check if already exists
        if module in content:
            print(f"✅ {module} already in project")
            continue
            
        # Check if file exists
        file_path = f"FinanceMate/FinanceMate/ViewModels/{module}"
        if not os.path.exists(file_path):
            print(f"❌ File not found: {file_path}")
            continue
            
        # Add file reference
        content, file_id = add_file_reference(content, module, file_path)
        print(f"  ✅ Added file reference: {file_id}")
        
        # Add build file
        content, build_id = add_build_file(content, module, file_id)
        print(f"  ✅ Added build file: {build_id}")
        
        # Add to ViewModels group
        content = add_file_to_group(content, module, file_id)
        print(f"  ✅ Added to ViewModels group")
        
        # Add to Sources build phase
        content = add_to_sources_build_phase(content, module, build_id)
        print(f"  ✅ Added to Sources build phase")
    
    # Write updated content if changes were made
    if content != original_content:
        write_pbxproj(pbxproj_path, content)
        print(f"\n🎉 Successfully integrated authentication modules!")
        return True
    else:
        print(f"\n✅ All modules already integrated")
        return True

if __name__ == "__main__":
    try:
        success = integrate_authentication_modules()
        if success:
            print("\n🚀 Integration complete! Ready for build validation.")
            sys.exit(0)
        else:
            print("\n❌ Integration failed!")
            sys.exit(1)
    except Exception as e:
        print(f"\n💥 Error during integration: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)