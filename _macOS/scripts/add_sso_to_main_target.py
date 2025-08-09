#!/usr/bin/env python3

import sys
import os
import uuid
import re
from pathlib import Path

def add_sso_to_main_target():
    """Add SSO files specifically to the main target's Sources build phase"""
    
    project_root = Path(__file__).parent.parent
    pbxproj_path = project_root / "FinanceMate.xcodeproj" / "project.pbxproj"
    
    if not pbxproj_path.exists():
        print(f"ERROR: Could not find project.pbxproj at {pbxproj_path}")
        return False
    
    # Read the project file
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    print("🔧 Adding SSO files specifically to main target...")
    
    # SSO files to add
    sso_files = ['AppleAuthProvider.swift', 'GoogleAuthProvider.swift', 'TokenStorage.swift', 'SSOManager.swift']
    
    # Generate new UUIDs for SSO files
    file_references = {}
    build_files = {}
    
    for file_name in sso_files:
        # Generate UUIDs in the same format as existing ones (24 chars)
        file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
        build_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
        
        file_references[file_name] = file_uuid
        build_files[file_name] = build_uuid
    
    print("🔧 Adding file references...")
    
    # Add file references to PBXFileReference section
    pbx_file_reference_section = "/* Begin PBXFileReference section */"
    if pbx_file_reference_section in content:
        insertion_point = content.find(pbx_file_reference_section) + len(pbx_file_reference_section)
        
        new_references = []
        for file_name in sso_files:
            file_uuid = file_references[file_name]
            new_references.append(f"""
\t\t{file_uuid} /* {file_name} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = "<group>"; }};""")
        
        content = content[:insertion_point] + ''.join(new_references) + content[insertion_point:]
        print("✅ Added file references")
    
    # Add build files that reference the file references
    pbx_build_file_section = "/* Begin PBXBuildFile section */"
    if pbx_build_file_section in content:
        insertion_point = content.find(pbx_build_file_section) + len(pbx_build_file_section)
        
        new_build_files = []
        for file_name in sso_files:
            file_uuid = file_references[file_name]
            build_uuid = build_files[file_name]
            new_build_files.append(f"""
\t\t{build_uuid} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {file_name} */; }};""")
        
        content = content[:insertion_point] + ''.join(new_build_files) + content[insertion_point:]
        print("✅ Added build file references")
    
    # Find the main Services group (where AuthenticationService is) and add file references
    services_pattern = r'(/\* Services \*/ = \{[^}]*children = \([^)]*AUTHSERVICE2025[^)]*?)(\);)'
    services_match = re.search(services_pattern, content, re.DOTALL)
    
    if services_match:
        group_content = services_match.group(1)
        closing = services_match.group(2)
        
        new_group_entries = []
        for file_name in sso_files:
            file_uuid = file_references[file_name]
            new_group_entries.append(f"""
\t\t\t\t{file_uuid} /* {file_name} */,""")
        
        updated_group = group_content + ''.join(new_group_entries) + "\n\t\t\t" + closing
        content = content.replace(services_match.group(0), updated_group)
        print("✅ Added SSO files to main Services group")
    else:
        print("⚠️  Could not find main Services group with AuthenticationService")
    
    # Find the main target's Sources build phase (where AuthenticationService is compiled)
    sources_pattern = r'(buildActionMask = 2147483647;\s*files = \([^)]*AUTHBUILD2025SERVICEAABBCCDD[^)]*?)(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;)'
    sources_match = re.search(sources_pattern, content, re.DOTALL)
    
    if sources_match:
        files_content = sources_match.group(1)
        closing = sources_match.group(2)
        
        new_source_entries = []
        for file_name in sso_files:
            build_uuid = build_files[file_name]
            new_source_entries.append(f"""
\t\t\t\t{build_uuid} /* {file_name} in Sources */,""")
        
        updated_sources = files_content + ''.join(new_source_entries) + closing
        content = content.replace(sources_match.group(0), updated_sources)
        print("✅ Added SSO files to main target Sources build phase")
    else:
        print("⚠️  Could not find main target Sources build phase with AuthenticationService")
        return False
    
    # Write back to file
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added SSO files to main target:")
    for file_name in sso_files:
        print(f"   - {file_name}")
    
    return True

if __name__ == "__main__":
    success = add_sso_to_main_target()
    sys.exit(0 if success else 1)