#!/usr/bin/env python3
"""
Direct Gmail Services Addition Script
Purpose: Add Gmail service files with correct paths to Xcode project
"""

import os
import re
import uuid

def generate_uuid():
    """Generate a random UUID for Xcode file references"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def main():
    """Add Gmail service files with correct paths"""
    print("🚀 Adding Gmail Service Files with Correct Paths...")
    
    base_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_file = f"{base_dir}/FinanceMate.xcodeproj/project.pbxproj"
    
    # Service files with correct relative paths
    service_files = [
        {
            "name": "EmailConnectorService.swift",
            "path": "FinanceMate/FinanceMate/Services/EmailConnectorService.swift"
        },
        {
            "name": "GmailAPIService.swift", 
            "path": "FinanceMate/FinanceMate/Services/GmailAPIService.swift"
        },
        {
            "name": "EmailOAuthManager.swift",
            "path": "FinanceMate/FinanceMate/Services/EmailOAuthManager.swift"  
        },
        {
            "name": "ProductionAPIConfig.swift",
            "path": "FinanceMate/FinanceMate/Services/ProductionAPIConfig.swift"
        }
    ]
    
    # Verify all files exist
    for file_info in service_files:
        full_path = f"{base_dir}/{file_info['path']}"
        if not os.path.exists(full_path):
            print(f"❌ File not found: {full_path}")
            return False
        print(f"✅ Found: {file_info['name']}")
    
    # Read project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Generate UUIDs for each file
    file_refs = {}
    build_files = {}
    
    for file_info in service_files:
        file_refs[file_info['name']] = generate_uuid()
        build_files[file_info['name']] = generate_uuid()
    
    # Add file references to PBXFileReference section
    pbx_file_ref_pattern = r'(\s*\/\* End PBXFileReference section \*\/)'
    
    file_ref_entries = []
    for file_info in service_files:
        uuid_ref = file_refs[file_info['name']]
        file_ref_entry = f'\t\t{uuid_ref} /* {file_info["name"]} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {file_info["name"]}; sourceTree = "<group>"; }};'
        file_ref_entries.append(file_ref_entry)
    
    file_ref_insertion = '\n'.join(file_ref_entries) + '\n'
    content = re.sub(pbx_file_ref_pattern, file_ref_insertion + r'\1', content)
    
    # Add build files to PBXBuildFile section
    pbx_build_file_pattern = r'(\s*\/\* End PBXBuildFile section \*\/)'
    
    build_file_entries = []
    for file_info in service_files:
        uuid_build = build_files[file_info['name']]
        uuid_ref = file_refs[file_info['name']]
        build_file_entry = f'\t\t{uuid_build} /* {file_info["name"]} in Sources */ = {{isa = PBXBuildFile; fileRef = {uuid_ref} /* {file_info["name"]} */; }};'
        build_file_entries.append(build_file_entry)
    
    build_file_insertion = '\n'.join(build_file_entries) + '\n'
    content = re.sub(pbx_build_file_pattern, build_file_insertion + r'\1', content)
    
    # Add to Services group
    services_group_pattern = r'(SERVICES2025GROUPAABBCCDDEE \/\* Services \*\/ = \{\s*isa = PBXGroup;\s*children = \(\s*[^)]+)(\s*\);\s*path = Services;)'
    
    services_group_entries = []
    for file_info in service_files:
        uuid_ref = file_refs[file_info['name']]
        services_group_entries.append(f'\t\t\t\t{uuid_ref} /* {file_info["name"]} */,')
    
    services_insertion = '\n'.join(services_group_entries) + '\n'
    content = re.sub(services_group_pattern, r'\1' + '\n' + services_insertion + r'\2', content, flags=re.DOTALL)
    
    # Add to FinanceMate target Sources build phase
    finance_mate_sources_pattern = r'(SOURCES2025FINANCEMATEAABBCC \/\* Sources \*\/ = \{\s*isa = PBXSourcesBuildPhase;\s*buildActionMask = [^;]+;\s*files = \(\s*[^)]+)(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;)'
    
    sources_entries = []
    for file_info in service_files:
        uuid_build = build_files[file_info['name']]
        sources_entries.append(f'\t\t\t\t{uuid_build} /* {file_info["name"]} in Sources */,')
    
    sources_insertion = '\n'.join(sources_entries) + '\n'
    content = re.sub(finance_mate_sources_pattern, r'\1' + '\n' + sources_insertion + r'\2', content, flags=re.DOTALL)
    
    # Write updated project file
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Gmail service files successfully added to Xcode project!")
    print("📝 Files added:")
    for file_info in service_files:
        print(f"  - {file_info['name']} ({file_info['path']})")
    
    return True

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)