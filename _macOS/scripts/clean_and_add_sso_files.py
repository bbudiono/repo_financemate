#!/usr/bin/env python3

import sys
import os
import uuid
import re
from pathlib import Path

def clean_and_add_sso_files():
    """Clean up duplicate SSO entries and properly add SSO files to Xcode project"""
    
    project_root = Path(__file__).parent.parent
    pbxproj_path = project_root / "FinanceMate.xcodeproj" / "project.pbxproj"
    
    if not pbxproj_path.exists():
        print(f"ERROR: Could not find project.pbxproj at {pbxproj_path}")
        return False
    
    # Read the project file
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    print("🧹 Cleaning up duplicate SSO entries...")
    
    # Remove ALL existing SSO-related entries
    sso_files = ['AppleAuthProvider.swift', 'GoogleAuthProvider.swift', 'TokenStorage.swift', 'SSOManager.swift']
    
    # Remove duplicate PBXBuildFile entries
    for file_name in sso_files:
        escaped_name = re.escape(file_name)
        pattern = rf'\s*[A-F0-9]+ /\* {escaped_name} in Sources \*/ = \{{isa = PBXBuildFile; fileRef = [A-F0-9]+ /\* {escaped_name} \*/; \}};'
        content = re.sub(pattern, '', content)
    
    # Remove duplicate PBXFileReference entries
    for file_name in sso_files:
        escaped_name = re.escape(file_name)
        pattern = rf'\s*[A-F0-9]+ /\* {escaped_name} \*/ = \{{isa = PBXFileReference; [^}}]+path = {escaped_name}; [^}}]+\}};'
        content = re.sub(pattern, '', content)
    
    # Remove duplicate group entries
    for file_name in sso_files:
        escaped_name = re.escape(file_name)
        pattern = rf'\s*[A-F0-9]+ /\* {escaped_name} \*/,'
        content = re.sub(pattern, '', content)
    
    # Remove duplicate source build phase entries
    for file_name in sso_files:
        escaped_name = re.escape(file_name)
        pattern = rf'\s*[A-F0-9]+ /\* {escaped_name} in Sources \*/,'
        content = re.sub(pattern, '', content)
    
    print("✅ Cleaned up duplicate entries")
    
    # Generate new UUIDs for SSO files
    file_references = {}
    build_files = {}
    
    for file_name in sso_files:
        file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
        build_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
        
        file_references[file_name] = file_uuid
        build_files[file_name] = build_uuid
    
    print("🔧 Adding clean SSO file entries...")
    
    # Add file references to PBXFileReference section
    pbx_file_reference_section = "/* Begin PBXFileReference section */"
    if pbx_file_reference_section in content:
        insertion_point = content.find(pbx_file_reference_section) + len(pbx_file_reference_section)
        
        new_references = []
        for file_name in sso_files:
            file_uuid = file_references[file_name]
            new_references.append(f"""
\t\t{file_uuid} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = "<group>"; }};""")
        
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
    
    # Find Services group and add file references
    # Look for the main Services group (not the test one)
    services_pattern = r'(SERVICES2025MAINGROUPAABBCC /\* Services \*/ = \{[^}]*children = \([^)]*?)(\);)'
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
    else:
        print("⚠️  Could not find main Services group, trying alternative pattern...")
        # Try alternative pattern
        alt_pattern = r'(/\* Services \*/ = \{[^}]*children = \([^)]*?)(\);)'
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
    
    # Find main target's PBXSourcesBuildPhase and add to Sources
    # Look for the main target (not test targets)
    sources_pattern = r'(buildActionMask = 2147483647;\s*files = \([^)]*?)(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;)'
    sources_matches = re.finditer(sources_pattern, content, re.DOTALL)
    
    # We want the first (main target) sources build phase
    sources_match = None
    for match in sources_matches:
        # Skip if this looks like a test target
        preceding_text = content[:match.start()]
        if 'Test' not in preceding_text[-200:]:
            sources_match = match
            break
    
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
    else:
        print("⚠️  Could not find main target Sources build phase")
    
    # Write back to file
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print("✅ Successfully cleaned and added SSO files to Xcode project:")
    for file_name in sso_files:
        print(f"   - {file_name} -> Services/{file_name}")
    
    return True

if __name__ == "__main__":
    success = clean_and_add_sso_files()
    sys.exit(0 if success else 1)