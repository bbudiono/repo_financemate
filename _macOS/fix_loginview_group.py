#!/usr/bin/env python3

"""
Fix LoginView.swift group reference in Xcode project
The issue is that LoginView.swift is in the wrong Views group
"""

import re

def fix_loginview_group():
    """Fix LoginView.swift to be in the correct Views group"""
    
    print("🔧 FIXING LOGINVIEW.SWIFT GROUP REFERENCE")
    print("=" * 50)
    
    project_file = "FinanceMate.xcodeproj/project.pbxproj"
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    print("✅ Read project.pbxproj file")
    
    # Find the active Views group (the one that contains DashboardView.swift used by main target)
    active_views_group_match = re.search(r'(\w+) /\* Views \*/ = \{[^}]*?88211B32F54FEC04C1A3EE94 /\* DashboardView\.swift \*/[^}]*?\};', content, re.DOTALL)
    
    if not active_views_group_match:
        print("❌ Could not find the active Views group")
        return False
    
    active_views_group_id = active_views_group_match.group(1)
    print(f"✅ Found active Views group ID: {active_views_group_id}")
    
    # Check if LoginView.swift is already in the active Views group
    if "29888C7DB68145839C2AFD19 /* LoginView.swift */" in active_views_group_match.group(0):
        print("✅ LoginView.swift is already in the active Views group")
        return True
    
    # Find the Views group that contains LoginView.swift
    loginview_group_match = re.search(r'(\w+) /\* Views \*/ = \{[^}]*?29888C7DB68145839C2AFD19 /\* LoginView\.swift \*/[^}]*?\};', content, re.DOTALL)
    
    if not loginview_group_match:
        print("❌ Could not find Views group containing LoginView.swift")
        return False
    
    print("✅ Found Views group containing LoginView.swift")
    
    # Remove LoginView.swift from its current group
    old_group_content = loginview_group_match.group(0)
    new_group_content = re.sub(r'\t\t\t\t29888C7DB68145839C2AFD19 /\* LoginView\.swift \*/,\n', '', old_group_content)
    content = content.replace(old_group_content, new_group_content)
    
    print("✅ Removed LoginView.swift from old Views group")
    
    # Add LoginView.swift to the active Views group
    active_group_content = active_views_group_match.group(0)
    
    # Find the position to insert LoginView.swift (after TransactionsView.swift)
    insertion_point = active_group_content.find("12A4667FC12C467998B0A1B8 /* TransactionsView.swift */,")
    if insertion_point == -1:
        print("❌ Could not find insertion point in active Views group")
        return False
    
    # Find the end of the TransactionsView.swift line
    line_end = active_group_content.find('\n', insertion_point)
    
    # Insert LoginView.swift after TransactionsView.swift
    new_active_content = (active_group_content[:line_end] + 
                         '\n\t\t\t\t29888C7DB68145839C2AFD19 /* LoginView.swift */,' +
                         active_group_content[line_end:])
    
    content = content.replace(active_group_content, new_active_content)
    
    print("✅ Added LoginView.swift to active Views group")
    
    # Write the updated project file
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Updated project.pbxproj file")
    print("🎉 LOGINVIEW.SWIFT GROUP REFERENCE FIXED!")
    
    return True

if __name__ == "__main__":
    success = fix_loginview_group()
    exit(0 if success else 1)