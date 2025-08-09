#!/usr/bin/env python3
"""
Add UI test files to FinanceMate Xcode project
This script adds the missing UI test files to the FinanceMateUITests target
"""

import re
import uuid
import sys
import os

def generate_uuid():
    """Generate a 24-character UUID for Xcode"""
    return uuid.uuid4().hex[:24].upper()

def main():
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_path):
        print(f"Error: {project_path} not found")
        return 1
    
    # Read the project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Files to add
    ui_test_files = [
        "FinanceMateUITests.swift",
        "DashboardViewUITests.swift", 
        "TransactionsViewUITests.swift",
        "SettingsViewUITests.swift"
    ]
    
    # Generate UUIDs for each file
    file_refs = {}
    build_files = {}
    
    for filename in ui_test_files:
        file_refs[filename] = generate_uuid()
        build_files[filename] = generate_uuid()
    
    # Add PBXFileReference entries
    file_ref_section = ""
    for filename in ui_test_files:
        file_ref_section += f"\t\t{file_refs[filename]} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};\n"
    
    # Find the end of PBXFileReference section and add our entries
    file_ref_pattern = r"(/* End PBXFileReference section \*/)"
    content = re.sub(file_ref_pattern, file_ref_section + r"\1", content)
    
    # Add PBXBuildFile entries
    build_file_section = ""
    for filename in ui_test_files:
        build_file_section += f"\t\t{build_files[filename]} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[filename]} /* {filename} */; }};\n"
    
    # Find the end of PBXBuildFile section and add our entries
    build_file_pattern = r"(/* End PBXBuildFile section \*/)"
    content = re.sub(build_file_pattern, build_file_section + r"\1", content)
    
    # Add files to FinanceMateUITests group
    group_pattern = r"(children = \(\s*\);.*?path = FinanceMateUITests;)"
    replacement = f"children = (\n"
    for filename in ui_test_files:
        replacement += f"\t\t\t\t{file_refs[filename]} /* {filename} */,\n"
    replacement += "\t\t\t);\n\t\t\tpath = FinanceMateUITests;"
    
    content = re.sub(r"children = \(\s*\);\s*path = FinanceMateUITests;", replacement, content, flags=re.MULTILINE | re.DOTALL)
    
    # Add build files to FinanceMateUITests target sources
    target_pattern = r"(buildActionMask = 2147483647;\s*files = \(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;\s*\};\s*.*?isa = PBXSourcesBuildPhase.*?FinanceMateUITests)"
    
    sources_replacement = f"buildActionMask = 2147483647;\n\t\t\tfiles = (\n"
    for filename in ui_test_files:
        sources_replacement += f"\t\t\t\t{build_files[filename]} /* {filename} in Sources */,\n"
    sources_replacement += "\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};"
    
    # Find and replace the FinanceMateUITests sources section
    if "FinanceMateUITests" in content:
        # Look for the specific sources build phase for FinanceMateUITests
        sources_pattern = r"(buildActionMask = 2147483647;\s*files = \(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;\s*\};.*?/* Sources \*/.*?isa = PBXSourcesBuildPhase)"
        
        # Let's be more specific and look for the FinanceMateUITests target sources
        lines = content.split('\n')
        new_lines = []
        in_uitests_sources = False
        
        for i, line in enumerate(lines):
            if "buildActionMask = 2147483647;" in line and i < len(lines) - 5:
                # Check if this is followed by empty files array and FinanceMateUITests reference nearby
                next_lines = '\n'.join(lines[i:i+10])
                if "files = (" in next_lines and "FinanceMateUITests" in next_lines:
                    in_uitests_sources = True
                    new_lines.append(line)
                    continue
            
            if in_uitests_sources and "files = (" in line:
                new_lines.append("\t\t\tfiles = (")
                for filename in ui_test_files:
                    new_lines.append(f"\t\t\t\t{build_files[filename]} /* {filename} in Sources */,")
                in_uitests_sources = False
                continue
            elif in_uitests_sources and ");" in line and "runOnlyForDeploymentPostprocessing" in lines[i+1]:
                new_lines.append("\t\t\t);")
                in_uitests_sources = False
                continue
            elif in_uitests_sources and "files = (" not in line and ");" not in line:
                continue  # Skip the empty line between files = ( and );
            else:
                new_lines.append(line)
        
        content = '\n'.join(new_lines)
    
    # Write the updated project file
    with open(project_path, 'w') as f:
        f.write(content)
    
    print("Successfully added UI test files to Xcode project:")
    for filename in ui_test_files:
        print(f"  - {filename}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())