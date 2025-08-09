#!/usr/bin/env python3

"""
Add LoginView.swift to the main FinanceMate target's Sources build phase
This is the root cause of the compilation issue - LoginView.swift is not in the main target
"""

import re

def fix_main_target_loginview():
    """Add LoginView.swift to main target Sources build phase"""
    
    print("🔧 ADDING LOGINVIEW.SWIFT TO MAIN TARGET SOURCES BUILD PHASE")
    print("=" * 65)
    
    project_file = "FinanceMate.xcodeproj/project.pbxproj"
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    print("✅ Read project.pbxproj file")
    
    # Find the main target's Sources build phase (E728BDA24D7E5D5322C4F5B3)
    # Look for the build phase that contains the main Views like DashboardView.swift
    main_sources_pattern = r'E728BDA24D7E5D5322C4F5B3 /\* Sources \*/ = \{[^}]*?\};'
    main_sources_match = re.search(main_sources_pattern, content, re.DOTALL)
    
    if not main_sources_match:
        print("❌ Could not find main target's Sources build phase")
        return False
    
    main_sources_id = "E728BDA24D7E5D5322C4F5B3"
    main_sources_content = main_sources_match.group(0)
    
    print(f"✅ Found main target Sources build phase ID: {main_sources_id}")
    
    # Check if LoginView.swift is already in the main target
    if "9FEE7DA7396D41348A8DBE42 /* LoginView.swift in Sources */" in main_sources_content:
        print("✅ LoginView.swift is already in main target Sources build phase")
        return True
    
    print("🔍 LoginView.swift missing from main target - adding it...")
    
    # Find a good insertion point (after TransactionsView.swift)
    insertion_pattern = r'(\t\t\t\t25E1A4A0009D4E86A514BDE0 /\* TransactionsView\.swift in Sources \*/,\n)'
    insertion_match = re.search(insertion_pattern, main_sources_content)
    
    if not insertion_match:
        print("❌ Could not find insertion point in main target Sources build phase")
        return False
    
    # Insert LoginView.swift after TransactionsView.swift
    insertion_point = insertion_match.end()
    new_sources_content = (main_sources_content[:insertion_point] + 
                          '\t\t\t\t9FEE7DA7396D41348A8DBE42 /* LoginView.swift in Sources */,\n' +
                          main_sources_content[insertion_point:])
    
    # Update the content
    content = content.replace(main_sources_content, new_sources_content)
    
    print("✅ Added LoginView.swift to main target Sources build phase")
    
    # Write the updated project file
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Updated project.pbxproj file")
    print("🎉 LOGINVIEW.SWIFT ADDED TO MAIN TARGET - BUILD SHOULD NOW WORK!")
    
    return True

if __name__ == "__main__":
    success = fix_main_target_loginview()
    exit(0 if success else 1)