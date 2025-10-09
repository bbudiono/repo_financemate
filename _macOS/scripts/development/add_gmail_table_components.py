#!/usr/bin/env python3
"""
Add GmailTableRow component files to Xcode project
"""

import os
import re
import uuid

def add_file_to_xcode_project(project_path, file_path, group_name="Views/Gmail"):
    """Add a Swift file to the Xcode project"""

    # Read the project.pbxproj file
    pbxproj_path = os.path.join(project_path, "project.pbxproj")

    with open(pbxproj_path, 'r') as f:
        content = f.read()

    # Generate UUIDs
    file_ref_uuid = str(uuid.uuid4()).replace('-', '')
    build_file_uuid = str(uuid.uuid4()).replace('-', '')

    # Extract filename
    filename = os.path.basename(file_path)

    # Find the target
    target_uuid = None
    target_match = re.search(r'PBXNativeTarget.*?name\s*=\s*FinanceMate.*?;\s*(\w+)', content, re.DOTALL)
    if target_match:
        target_uuid = target_match.group(1)

    if not target_uuid:
        print("Could not find FinanceMate target")
        return False

    # Find the source build phase
    source_build_phase_uuid = None
    source_match = re.search(r'PBXSourcesBuildPhase.*?name\s*=\s*Sources.*?;\s*(\w+)', content, re.DOTALL)
    if source_match:
        source_build_phase_uuid = source_match.group(1)

    if not source_build_phase_uuid:
        print("Could not find Sources build phase")
        return False

    # Add file reference
    file_ref_entry = f"""\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{filename}"; sourceTree = "<group>"; }};"""

    # Add build file
    build_file_entry = f"""\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};"""

    # Add to sources build phase
    sources_entry = f"""\t\t\t\t{build_file_uuid} /* {filename} in Sources */,"""

    # Find where to insert these entries
    # Insert file reference after other file references
    file_ref_pattern = r'(\t\t\w+ /\* \w+\.swift \*/ = \{isa = PBXFileReference;.*?\}\;)\n'
    file_ref_matches = list(re.finditer(file_ref_pattern, content))

    if file_ref_matches:
        last_match = file_ref_matches[-1]
        insert_pos = last_match.end()
        content = content[:insert_pos] + '\n' + file_ref_entry + content[insert_pos:]

    # Insert build file after other build files
    build_file_pattern = r'(\t\t\w+ /\* \w+\.swift in Sources \*/ = \{isa = PBXBuildFile;.*?\}\;)\n'
    build_file_matches = list(re.finditer(build_file_pattern, content))

    if build_file_matches:
        last_match = build_file_matches[-1]
        insert_pos = last_match.end()
        content = content[:insert_pos] + '\n' + build_file_entry + content[insert_pos:]

    # Find and insert into Sources build phase
    sources_pattern = r'(PBXSourcesBuildPhase.*?files = \(\n)(.*?)(\);)'
    sources_match = re.search(sources_pattern, content, re.DOTALL)

    if sources_match:
        sources_content = sources_match.group(2)
        # Insert before the closing parenthesis
        new_sources_content = sources_content + sources_entry + '\n'
        content = content.replace(sources_match.group(0),
                                 sources_match.group(1) + new_sources_content + sources_match.group(3))

    # Find the Gmail group and add the file to it
    group_pattern = rf'(/* {group_name} */ = {{[^}]*children = \([^)]*)(\);)'
    group_match = re.search(group_pattern, content, re.DOTALL)

    if group_match:
        group_children = group_match.group(1)
        group_entry = f"\t\t\t\t{file_ref_uuid} /* {filename} */,"
        new_group_children = group_children + '\n' + group_entry
        content = content.replace(group_match.group(0),
                                 group_children + group_entry + group_match.group(2))

    # Write the updated content
    with open(pbxproj_path, 'w') as f:
        f.write(content)

    print(f"Added {filename} to Xcode project")
    return True

def main():
    """Main function"""
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj"

    # Files to add
    files_to_add = [
        "FinanceMate/Views/Gmail/GmailTableRowStatusIndicator.swift",
        "FinanceMate/Views/Gmail/GmailTableRowActions.swift",
        "FinanceMate/Views/Gmail/GmailTableRowInlineEditor.swift"
    ]

    for file_path in files_to_add:
        full_path = os.path.join(
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS",
            file_path
        )

        if os.path.exists(full_path):
            add_file_to_xcode_project(project_path, file_path)
        else:
            print(f"File not found: {full_path}")

if __name__ == "__main__":
    main()