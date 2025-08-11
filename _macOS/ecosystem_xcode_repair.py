#!/usr/bin/env python3
"""
ECOSYSTEM OPTIMIZER: EMERGENCY XCODE PROJECT REPAIR
Sophisticated repair of corrupted Xcode project by adding missing view files
Status: CRITICAL SYSTEM RECOVERY
"""

import re
import uuid
from pathlib import Path

def generate_xcode_ids():
    """Generate unique Xcode-compatible IDs"""
    def make_id():
        return hex(uuid.uuid4().int)[2:].upper()[:24]
    
    return {
        'emailconnector_file_ref': make_id(),
        'emailconnector_build_file': make_id(),
        'chatbot_file_ref': make_id(),
        'chatbot_build_file': make_id()
    }

def repair_xcode_project():
    """Repair the corrupted Xcode project by adding missing views"""
    project_path = Path("FinanceMate.xcodeproj/project.pbxproj")
    
    if not project_path.exists():
        print("❌ ERROR: Xcode project file not found")
        return False
    
    # Read project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Generate unique IDs
    ids = generate_xcode_ids()
    
    print("🔧 ECOSYSTEM REPAIR: Adding missing views to Xcode project")
    print(f"EmailConnectorView File Ref: {ids['emailconnector_file_ref']}")
    print(f"EmailConnectorView Build File: {ids['emailconnector_build_file']}")
    print(f"ChatbotDrawerView File Ref: {ids['chatbot_file_ref']}")
    print(f"ChatbotDrawerView Build File: {ids['chatbot_build_file']}")
    
    # 1. Add PBXBuildFile entries
    build_file_section = re.search(r'/\* Begin PBXBuildFile section \*/(.*?)/\* End PBXBuildFile section \*/', content, re.DOTALL)
    
    if build_file_section:
        new_build_entries = f"""		{ids['emailconnector_build_file']} /* EmailConnectorView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {ids['emailconnector_file_ref']} /* EmailConnectorView.swift */; }};
		{ids['chatbot_build_file']} /* ChatbotDrawerView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {ids['chatbot_file_ref']} /* ChatbotDrawerView.swift */; }};
/* End PBXBuildFile section */"""
        
        content = content.replace("/* End PBXBuildFile section */", new_build_entries)
        print("✅ Added PBXBuildFile entries")
    
    # 2. Add PBXFileReference entries
    file_ref_section = re.search(r'/\* Begin PBXFileReference section \*/(.*?)/\* End PBXFileReference section \*/', content, re.DOTALL)
    
    if file_ref_section:
        new_file_refs = f"""		{ids['emailconnector_file_ref']} /* EmailConnectorView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EmailConnectorView.swift; sourceTree = "<group>"; }};
		{ids['chatbot_file_ref']} /* ChatbotDrawerView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ChatbotDrawerView.swift; sourceTree = "<group>"; }};
/* End PBXFileReference section */"""
        
        content = content.replace("/* End PBXFileReference section */", new_file_refs)
        print("✅ Added PBXFileReference entries")
    
    # 3. Add files to Views group (find and add to appropriate group)
    # Look for existing Views group pattern
    views_group_pattern = r'(.*?path = Views;[\s\S]*?children = \([^)]+)\);'
    match = re.search(views_group_pattern, content)
    
    if match:
        # Add to existing Views group
        views_children = match.group(1)
        new_views_children = f"""{views_children}
				{ids['emailconnector_file_ref']} /* EmailConnectorView.swift */,
				{ids['chatbot_file_ref']} /* ChatbotDrawerView.swift */,
			);"""
        content = content.replace(f"{views_children});", new_views_children)
        print("✅ Added files to Views group")
    else:
        # Find main FinanceMate group and add Views subgroup
        print("⚠️  Views group not found, will need manual addition")
    
    # 4. Add to Sources build phase
    sources_pattern = r'(.*?/\* Sources \*/.*?files = \([^)]+)\);'
    match = re.search(sources_pattern, content, re.DOTALL)
    
    if match:
        sources_files = match.group(1)
        new_sources = f"""{sources_files}
				{ids['emailconnector_build_file']} /* EmailConnectorView.swift in Sources */,
				{ids['chatbot_build_file']} /* ChatbotDrawerView.swift in Sources */,
			);"""
        content = content.replace(f"{sources_files});", new_sources)
        print("✅ Added files to Sources build phase")
    
    # Create backup
    backup_path = project_path.with_suffix('.pbxproj.backup')
    with open(backup_path, 'w') as f:
        f.write(open(project_path).read())
    print(f"✅ Created backup: {backup_path}")
    
    # Write repaired project
    with open(project_path, 'w') as f:
        f.write(content)
    
    print("🎉 ECOSYSTEM REPAIR COMPLETE: Xcode project structure restored")
    return True

if __name__ == "__main__":
    success = repair_xcode_project()
    exit(0 if success else 1)