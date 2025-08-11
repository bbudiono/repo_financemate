#!/usr/bin/env python3

"""
Gmail Services Xcode Integration Script
Purpose: Add real Gmail service files to Xcode project compilation
"""

import os
import re
import uuid
import shutil

def generate_uuid():
    """Generate a random UUID for Xcode file references"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def backup_project_file(project_path):
    """Create a backup of the project.pbxproj file"""
    backup_path = f"{project_path}.backup_gmail_services_{generate_uuid()[:8]}"
    shutil.copy2(project_path, backup_path)
    print(f"✅ Created backup: {backup_path}")
    return backup_path

def read_project_file(project_path):
    """Read and return project.pbxproj content"""
    try:
        with open(project_path, 'r', encoding='utf-8') as f:
            content = f.read()
        print(f"✅ Successfully read project file: {project_path}")
        return content
    except Exception as e:
        print(f"❌ Error reading project file: {e}")
        return None

def write_project_file(project_path, content):
    """Write content back to project.pbxproj file"""
    try:
        with open(project_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Successfully wrote project file: {project_path}")
        return True
    except Exception as e:
        print(f"❌ Error writing project file: {e}")
        return False

def find_target_section(content, target_name):
    """Find the target section in the project file"""
    pattern = rf'\/\* {target_name} \*\/ = \{{[^}}]+buildPhases = \(\s*([^)]+)\);'
    match = re.search(pattern, content, re.DOTALL)
    if match:
        return match.group(1)
    return None

def find_sources_build_phase(content, target_name):
    """Find the Sources build phase UUID for a target"""
    target_section = find_target_section(content, target_name)
    if not target_section:
        return None
    
    # Look for Sources build phase reference
    sources_match = re.search(r'([A-F0-9]{24}) \/\* Sources \*\/', target_section)
    if sources_match:
        return sources_match.group(1)
    return None

def add_file_reference(content, file_name, file_path, uuid_ref):
    """Add a file reference to the project"""
    # Find the /* Begin PBXFileReference section */
    pattern = r'(\/\* Begin PBXFileReference section \*\/\s*)'
    
    file_ref_entry = f'''{uuid_ref} /* {file_name} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = "<group>"; }};
\t\t'''
    
    def replacement_func(match):
        return match.group(1) + file_ref_entry
    
    content = re.sub(pattern, replacement_func, content)
    return content

def add_build_file(content, file_name, uuid_ref, uuid_build):
    """Add a build file entry"""
    pattern = r'(\/\* Begin PBXBuildFile section \*\/\s*)'
    
    build_file_entry = f'''{uuid_build} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {uuid_ref} /* {file_name} */; }};
\t\t'''
    
    def replacement_func(match):
        return match.group(1) + build_file_entry
    
    content = re.sub(pattern, replacement_func, content)
    return content

def add_to_sources_build_phase(content, sources_uuid, file_name, uuid_build):
    """Add file to Sources build phase"""
    # Find the sources build phase section
    pattern = rf'({sources_uuid} \/\* Sources \*\/ = \{{\s*isa = PBXSourcesBuildPhase;\s*buildActionMask = [^;]+;\s*files = \(\s*)([^)]+)(\s*\);)'
    
    def replacement_func(match):
        prefix = match.group(1)
        existing_files = match.group(2)
        suffix = match.group(3)
        
        new_entry = f"\t\t\t\t{uuid_build} /* {file_name} in Sources */,\n"
        return prefix + existing_files + new_entry + suffix
    
    content = re.sub(pattern, replacement_func, content, flags=re.DOTALL)
    return content

def add_to_group(content, group_name, file_name, uuid_ref):
    """Add file reference to a group (e.g., Services group)"""
    # Find the Services group
    pattern = rf'(\/\* {group_name} \*\/ = \{{\s*isa = PBXGroup;\s*children = \(\s*)([^)]+)(\s*\);[^}}]+name = {group_name};)'
    
    def replacement_func(match):
        prefix = match.group(1)
        existing_children = match.group(2)
        suffix = match.group(3)
        
        new_entry = f"\t\t\t\t{uuid_ref} /* {file_name} */,\n"
        return prefix + existing_children + new_entry + suffix
    
    content = re.sub(pattern, replacement_func, content, flags=re.DOTALL)
    return content

def add_file_to_project(content, file_name, group_name, target_name):
    """Add a single file to the Xcode project"""
    print(f"📝 Adding {file_name} to {target_name} target...")
    
    # Generate UUIDs
    uuid_ref = generate_uuid()
    uuid_build = generate_uuid()
    
    # Find Sources build phase UUID
    sources_uuid = find_sources_build_phase(content, target_name)
    if not sources_uuid:
        print(f"❌ Could not find Sources build phase for {target_name}")
        return content
    
    # Add file reference
    content = add_file_reference(content, file_name, f"FinanceMate/Services/{file_name}", uuid_ref)
    
    # Add build file
    content = add_build_file(content, file_name, uuid_ref, uuid_build)
    
    # Add to Sources build phase
    content = add_to_sources_build_phase(content, sources_uuid, file_name, uuid_build)
    
    # Add to Services group
    content = add_to_group(content, group_name, file_name, uuid_ref)
    
    print(f"✅ Successfully added {file_name}")
    return content

def main():
    """Main integration function"""
    print("🚀 Starting Gmail Services Xcode Integration...")
    
    # Project paths
    base_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_path = f"{base_dir}/FinanceMate.xcodeproj/project.pbxproj"
    
    # Service files to integrate
    service_files = [
        "EmailConnectorService.swift",
        "GmailAPIService.swift", 
        "EmailOAuthManager.swift",
        "ProductionAPIConfig.swift"
    ]
    
    # Verify service files exist
    for file_name in service_files:
        file_path = f"{base_dir}/FinanceMate/FinanceMate/Services/{file_name}"
        if not os.path.exists(file_path):
            print(f"❌ Service file not found: {file_path}")
            return False
    
    # Create backup
    backup_path = backup_project_file(project_path)
    
    # Read project file
    content = read_project_file(project_path)
    if not content:
        return False
    
    # Add each service file to both main targets
    targets = ["FinanceMate", "FinanceMate-Sandbox"]
    
    for target_name in targets:
        print(f"\n📂 Processing target: {target_name}")
        
        for file_name in service_files:
            content = add_file_to_project(content, file_name, "Services", target_name)
    
    # Write updated project file
    if write_project_file(project_path, content):
        print("\n✅ Gmail services successfully integrated into Xcode project!")
        print(f"📝 Backup created: {backup_path}")
        return True
    else:
        print("\n❌ Failed to write project file")
        return False

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)