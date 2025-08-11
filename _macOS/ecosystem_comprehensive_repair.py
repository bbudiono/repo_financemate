#!/usr/bin/env python3
"""
ECOSYSTEM OPTIMIZER: COMPREHENSIVE DEPENDENCY REPAIR
Adds ALL missing files created by failing agent to Xcode project
Status: CRITICAL COMPREHENSIVE SYSTEM RECOVERY
"""

import re
import uuid
from pathlib import Path

def generate_xcode_ids(count=4):
    """Generate unique Xcode-compatible IDs"""
    def make_id():
        return hex(uuid.uuid4().int)[2:].upper()[:24]
    
    return [make_id() for _ in range(count)]

def comprehensive_repair():
    """Add all missing dependencies to Xcode project"""
    project_path = Path("FinanceMate.xcodeproj/project.pbxproj")
    
    if not project_path.exists():
        print("❌ ERROR: Xcode project file not found")
        return False
    
    # Read project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Generate unique IDs for missing files
    ids = generate_xcode_ids(4)
    email_service_file_ref, email_service_build, chatbot_vm_file_ref, chatbot_vm_build = ids
    
    print("🔧 COMPREHENSIVE ECOSYSTEM REPAIR: Adding ALL missing dependencies")
    print(f"EmailConnectorService File Ref: {email_service_file_ref}")
    print(f"EmailConnectorService Build File: {email_service_build}")
    print(f"ProductionChatbotViewModel File Ref: {chatbot_vm_file_ref}")
    print(f"ProductionChatbotViewModel Build File: {chatbot_vm_build}")
    
    # Files to add
    files_to_add = [
        {
            'name': 'EmailConnectorService.swift',
            'path': 'FinanceMate/Services/EmailConnectorService.swift',
            'file_ref': email_service_file_ref,
            'build_file': email_service_build
        },
        {
            'name': 'ProductionChatbotViewModel.swift', 
            'path': 'ViewModels/ProductionChatbotViewModel.swift',
            'file_ref': chatbot_vm_file_ref,
            'build_file': chatbot_vm_build
        }
    ]
    
    # 1. Add PBXBuildFile entries
    new_build_entries = ""
    for file in files_to_add:
        new_build_entries += f"		{file['build_file']} /* {file['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {file['file_ref']} /* {file['name']} */; }};\\n"
    
    content = content.replace("/* End PBXBuildFile section */", f"{new_build_entries}/* End PBXBuildFile section */")
    print("✅ Added PBXBuildFile entries for dependencies")
    
    # 2. Add PBXFileReference entries
    new_file_refs = ""
    for file in files_to_add:
        new_file_refs += f"		{file['file_ref']} /* {file['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{file['name']}\"; sourceTree = \"<group>\"; }};\\n"
    
    content = content.replace("/* End PBXFileReference section */", f"{new_file_refs}/* End PBXFileReference section */")
    print("✅ Added PBXFileReference entries for dependencies")
    
    # 3. Add to Sources build phase - find and add to existing sources
    sources_pattern = r'(/\* Sources \*/[^}]+files = \()[^)]+(\);)'
    match = re.search(sources_pattern, content, re.DOTALL)
    
    if match:
        # Add new build files to sources
        new_sources = ""
        for file in files_to_add:
            new_sources += f"				{file['build_file']} /* {file['name']} in Sources */,\\n"
        
        # Insert before the closing );
        before_sources, after_sources = match.groups()
        existing_sources = re.search(r'files = \(([^)]+)\);', match.group(0), re.DOTALL)
        if existing_sources:
            existing_content = existing_sources.group(1)
            new_content = f"{existing_content}{new_sources}			"
            content = content.replace(
                f"files = ({existing_content});",
                f"files = ({new_content});"
            )
            print("✅ Added dependencies to Sources build phase")
    
    # Create comprehensive backup
    backup_path = project_path.with_suffix('.pbxproj.comprehensive_backup')
    with open(backup_path, 'w') as f:
        f.write(open(project_path).read())
    print(f"✅ Created comprehensive backup: {backup_path}")
    
    # Write repaired project
    with open(project_path, 'w') as f:
        f.write(content)
    
    print("🎉 COMPREHENSIVE ECOSYSTEM REPAIR COMPLETE")
    print("📋 Added the following files to Xcode project:")
    for file in files_to_add:
        print(f"   - {file['name']} ({file['path']})")
    
    return True

if __name__ == "__main__":
    success = comprehensive_repair()
    exit(0 if success else 1)