#!/usr/bin/env python3

import sys
import os
import uuid
from pathlib import Path

def add_files_to_pbxproj():
    """Add SSO implementation files to Xcode project"""
    
    project_root = Path(__file__).parent.parent
    pbxproj_path = project_root / "FinanceMate.xcodeproj" / "project.pbxproj"
    
    # Files to add with their relative paths from project root
    files_to_add = [
        ("FinanceMate/FinanceMate/Services/AppleAuthProvider.swift", "AppleAuthProvider.swift"),
        ("FinanceMate/FinanceMate/Services/GoogleAuthProvider.swift", "GoogleAuthProvider.swift"),
        ("FinanceMate/FinanceMate/Services/TokenStorage.swift", "TokenStorage.swift"),
        ("FinanceMate/FinanceMate/Services/SSOManager.swift", "SSOManager.swift"),
    ]
    
    if not pbxproj_path.exists():
        print(f"ERROR: Could not find project.pbxproj at {pbxproj_path}")
        return False
    
    # Read the project file
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Generate UUIDs for new files
    file_references = {}
    build_files = {}
    
    for file_path, file_name in files_to_add:
        file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
        build_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
        
        file_references[file_name] = (file_uuid, file_path)
        build_files[file_name] = build_uuid
    
    # Add file references to PBXFileReference section
    pbx_file_reference_section = "/* Begin PBXFileReference section */"
    if pbx_file_reference_section in content:
        insertion_point = content.find(pbx_file_reference_section) + len(pbx_file_reference_section)
        
        new_references = []
        for file_name, (file_uuid, file_path) in file_references.items():
            new_references.append(f"""
\t\t{file_uuid} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = "<group>"; }};""")
        
        content = content[:insertion_point] + ''.join(new_references) + content[insertion_point:]
    
    # Add build files to PBXBuildFile section
    pbx_build_file_section = "/* Begin PBXBuildFile section */"
    if pbx_build_file_section in content:
        insertion_point = content.find(pbx_build_file_section) + len(pbx_build_file_section)
        
        new_build_files = []
        for file_name in build_files:
            file_uuid = file_references[file_name][0]
            build_uuid = build_files[file_name]
            new_build_files.append(f"""
\t\t{build_uuid} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {file_name} */; }};""")
        
        content = content[:insertion_point] + ''.join(new_build_files) + content[insertion_point:]
    
    # Find Services group and add file references
    services_group_pattern = r'(\/\* Services \*\/ = \{[^}]*children = \([^)]*)'
    import re
    
    services_match = re.search(services_group_pattern, content)
    if services_match:
        group_content = services_match.group(1)
        insertion_point = content.find(group_content) + len(group_content)
        
        new_group_entries = []
        for file_name, (file_uuid, _) in file_references.items():
            new_group_entries.append(f"""
\t\t\t\t{file_uuid} /* {file_name} */,""")
        
        content = content[:insertion_point] + ''.join(new_group_entries) + content[insertion_point:]
    
    # Add to PBXSourcesBuildPhase
    sources_build_phase_pattern = r'(\/\* Sources \*\/ = \{[^}]*files = \([^)]*)'
    sources_match = re.search(sources_build_phase_pattern, content)
    if sources_match:
        sources_content = sources_match.group(1)
        insertion_point = content.find(sources_content) + len(sources_content)
        
        new_source_entries = []
        for file_name in build_files:
            build_uuid = build_files[file_name]
            new_source_entries.append(f"""
\t\t\t\t{build_uuid} /* {file_name} in Sources */,""")
        
        content = content[:insertion_point] + ''.join(new_source_entries) + content[insertion_point:]
    
    # Write back to file
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added SSO files to Xcode project:")
    for file_name, (_, file_path) in file_references.items():
        print(f"   - {file_name} -> {file_path}")
    
    return True

if __name__ == "__main__":
    success = add_files_to_pbxproj()
    sys.exit(0 if success else 1)