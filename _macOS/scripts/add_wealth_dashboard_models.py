#!/usr/bin/env python3
"""
Script to add WealthDashboardModels.swift to the Xcode project file
"""

import re
import uuid

def generate_unique_id():
    """Generate a unique 24-character hex ID for Xcode"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_wealth_dashboard_models_to_project():
    """Add WealthDashboardModels.swift to the Xcode project"""
    
    project_file = "FinanceMate.xcodeproj/project.pbxproj"
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Generate unique IDs for the new file
    file_ref_id = generate_unique_id()
    build_file_id = generate_unique_id()
    
    # Add PBXBuildFile entry (find a good location after other Swift files)
    build_file_entry = f'\t\t{build_file_id} /* WealthDashboardModels.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* WealthDashboardModels.swift */; }};\n'
    
    # Find location to insert PBXBuildFile (after other Dashboard files)
    build_file_pattern = r'(NETWEALTHDASHVIEW2025BUILD01.*?\n)'
    content = re.sub(build_file_pattern, r'\1' + build_file_entry, content)
    
    # Add PBXFileReference entry
    file_ref_entry = f'\t\t{file_ref_id} /* WealthDashboardModels.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "Dashboard/WealthDashboardModels.swift"; sourceTree = "<group>"; }};\n'
    
    # Find location to insert PBXFileReference (after other Dashboard files)
    file_ref_pattern = r'(NETWEALTHDASHVIEW001AABBCC.*?\n)'
    content = re.sub(file_ref_pattern, r'\1' + file_ref_entry, content)
    
    # Add to Sources build phase (in the Views section)
    source_entry = f'\t\t\t\t{build_file_id} /* WealthDashboardModels.swift in Sources */,\n'
    
    # Find the Sources build phase and add after NetWealthDashboardView
    sources_pattern = r'(NETWEALTHDASHVIEW2025BUILD01.*?\n)'
    content = re.sub(sources_pattern, r'\1' + source_entry, content)
    
    # Add to the Views group (file listing in project navigator)
    group_entry = f'\t\t\t\t{file_ref_id} /* WealthDashboardModels.swift */,\n'
    
    # Find the Views group and add after NetWealthDashboardView
    group_pattern = r'(NETWEALTHDASHVIEW001AABBCC.*?\n)'
    content = re.sub(group_pattern, r'\1' + group_entry, content)
    
    # Write the updated project file
    with open(project_file, 'w') as f:
        f.write(content)
    
    print(f"✅ Added WealthDashboardModels.swift to Xcode project")
    print(f"   File Reference ID: {file_ref_id}")
    print(f"   Build File ID: {build_file_id}")

if __name__ == "__main__":
    add_wealth_dashboard_models_to_project()