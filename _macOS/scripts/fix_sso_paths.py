#!/usr/bin/env python3

import sys
import os
import uuid
import re
from pathlib import Path

def fix_sso_file_paths():
    """Fix SSO file paths in Xcode project to point to correct main target location"""
    
    project_root = Path(__file__).parent.parent
    pbxproj_path = project_root / "FinanceMate.xcodeproj" / "project.pbxproj"
    
    if not pbxproj_path.exists():
        print(f"ERROR: Could not find project.pbxproj at {pbxproj_path}")
        return False
    
    # Read the project file
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    print("🔧 Fixing SSO file paths to point to main target...")
    
    # SSO files that need path correction
    sso_files = ['AppleAuthProvider.swift', 'GoogleAuthProvider.swift', 'TokenStorage.swift', 'SSOManager.swift']
    
    # Remove ALL existing SSO-related entries (clean slate)
    for file_name in sso_files:
        escaped_name = re.escape(file_name)
        
        # Remove PBXBuildFile entries
        pattern = rf'\s*[A-F0-9]+ /\* {escaped_name} in Sources \*/ = \{{[^}}]+\}};'
        content = re.sub(pattern, '', content)
        
        # Remove PBXFileReference entries
        pattern = rf'\s*[A-F0-9]+ /\* {escaped_name} \*/ = \{{[^}}]+\}};'
        content = re.sub(pattern, '', content)
        
        # Remove group entries
        pattern = rf'\s*[A-F0-9]+ /\* {escaped_name} \*/,'
        content = re.sub(pattern, '', content)
        
        # Remove source build phase entries
        pattern = rf'\s*[A-F0-9]+ /\* {escaped_name} in Sources \*/,'
        content = re.sub(pattern, '', content)
    
    print("✅ Cleaned up all existing SSO entries")
    
    # Generate new UUIDs for SSO files with correct paths
    file_references = {}
    build_files = {}
    
    for file_name in sso_files:
        file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
        build_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
        
        file_references[file_name] = file_uuid
        build_files[file_name] = build_uuid
    
    print("🔧 Adding SSO files with correct main target paths...")
    
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
    
    # Add build files to PBXBuildFile section
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
    
    # Find the main Services group (not test group) and add file references
    # Look for Services group that contains AuthenticationService.swift
    services_pattern = r'(/\* Services \*/ = \{[^}]*children = \([^)]*AUTH001SERVICE2025AABBCCDD[^)]*?)(\);)'
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
        print("⚠️  Could not find main Services group")
        # Try alternative pattern - look for any Services group with existing files
        alt_pattern = r'(/\* Services \*/ = \{[^}]*children = \([^)]*\n\t\t\t\t[A-F0-9]+ /\* [^*]+ \*/,[^)]*?)(\);)'
        alt_match = re.search(alt_pattern, content, re.DOTALL)
        if alt_match:
            group_content = alt_match.group(1)
            closing = alt_match.group(2)
            
            new_group_entries = []
            for file_name in sso_files:
                file_uuid = file_references[file_name]
                new_group_entries.append(f"""
\t\t\t\t{file_uuid} /* {file_name} */,""")
            
            updated_group = group_content + ''.join(new_group_entries) + "\n\t\t\t" + closing
            content = content.replace(alt_match.group(0), updated_group)
            print("✅ Added SSO files to Services group (alternative pattern)")
    
    # Find the main target's PBXSourcesBuildPhase (not test target)
    # Look for the sources build phase that contains AuthenticationService
    sources_pattern = r'(buildActionMask = 2147483647;\s*files = \([^)]*AUTH001BUILDSERVICE2025[^)]*?)(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;)'
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
        # Try to find any main sources build phase (first occurrence)
        alt_sources_pattern = r'(buildActionMask = 2147483647;\s*files = \([^)]*?)(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;)'
        alt_sources_matches = list(re.finditer(alt_sources_pattern, content, re.DOTALL))
        
        if alt_sources_matches:
            # Use the first match (should be main target)
            alt_sources_match = alt_sources_matches[0]
            files_content = alt_sources_match.group(1)
            closing = alt_sources_match.group(2)
            
            new_source_entries = []
            for file_name in sso_files:
                build_uuid = build_files[file_name]
                new_source_entries.append(f"""
\t\t\t\t{build_uuid} /* {file_name} in Sources */,""")
            
            updated_sources = files_content + ''.join(new_source_entries) + closing
            content = content.replace(alt_sources_match.group(0), updated_sources)
            print("✅ Added SSO files to Sources build phase (first match)")
    
    # Write back to file
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print("✅ Successfully fixed SSO file paths in Xcode project:")
    for file_name in sso_files:
        print(f"   - {file_name} -> FinanceMate/FinanceMate/Services/{file_name}")
    
    return True

if __name__ == "__main__":
    success = fix_sso_file_paths()
    sys.exit(0 if success else 1)