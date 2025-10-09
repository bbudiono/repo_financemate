#!/usr/bin/env python3
"""
Add GmailFilterManager.swift and GmailFilterService.swift to Xcode project build target
"""
import subprocess
import uuid
import sys

project_path = "FinanceMate.xcodeproj/project.pbxproj"
files_to_add = [
    ("FinanceMate/Services/GmailFilterManager.swift", "GmailFilterManager.swift"),
    ("FinanceMate/Services/GmailFilterService.swift", "GmailFilterService.swift"),
]

# Generate UUIDs for the new file references
file_refs = {}
build_file_refs = {}

for file_path, file_name in files_to_add:
    file_ref_uuid = str(uuid.uuid4()).replace('-', '')[:24].upper()
    build_file_uuid = str(uuid.uuid4()).replace('-', '')[:24].upper()
    file_refs[file_name] = (file_ref_uuid, file_path)
    build_file_refs[file_name] = build_file_uuid

print(f"Adding filter services to Xcode project...")
print(f"  - {files_to_add[0][1]}: {file_refs[files_to_add[0][1]][0]}")
print(f"  - {files_to_add[1][1]}: {file_refs[files_to_add[1][1]][0]}")

# Read the project file
with open(project_path, 'r') as f:
    content = f.read()

# Find the PBXFileReference section and add our files
file_ref_section_marker = "/* Begin PBXFileReference section */"
if file_ref_section_marker in content:
    insert_pos = content.find(file_ref_section_marker) + len(file_ref_section_marker)

    new_refs = "\n"
    for file_name, (file_ref_uuid, file_path) in file_refs.items():
        new_refs += f"\t\t{file_ref_uuid} /* {file_name} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = \"<group>\"; }};\n"

    content = content[:insert_pos] + new_refs + content[insert_pos:]
    print(" Added PBXFileReference entries")
else:
    print(" Could not find PBXFileReference section")
    sys.exit(1)

# Find the Services group and add our files there
services_group_marker = "/* Services */ = {"
if services_group_marker in content:
    # Find the children array in the Services group
    services_start = content.find(services_group_marker)
    children_start = content.find("children = (", services_start)
    children_end = content.find(");", children_start)

    if children_start > 0 and children_end > 0:
        insert_pos = children_end
        new_children = ""
        for file_name, (file_ref_uuid, _) in file_refs.items():
            new_children += f"\n\t\t\t\t{file_ref_uuid} /* {file_name} */,"

        content = content[:insert_pos] + new_children + content[insert_pos:]
        print(" Added files to Services group")
    else:
        print("️  Could not find Services group children array")
else:
    print("️  Services group not found, files may not be organized correctly")

# Find PBXSourcesBuildPhase and add our files
sources_build_phase_marker = "isa = PBXSourcesBuildPhase"
if sources_build_phase_marker in content:
    # Find the files array
    build_phase_start = content.find(sources_build_phase_marker)
    files_array_start = content.find("files = (", build_phase_start)
    files_array_end = content.find(");", files_array_start)

    if files_array_start > 0 and files_array_end > 0:
        insert_pos = files_array_end

        # First add PBXBuildFile entries
        build_file_section_marker = "/* Begin PBXBuildFile section */"
        if build_file_section_marker in content:
            build_file_insert = content.find(build_file_section_marker) + len(build_file_section_marker)
            build_file_entries = "\n"
            for file_name in build_file_refs:
                build_uuid = build_file_refs[file_name]
                file_ref_uuid = file_refs[file_name][0]
                build_file_entries += f"\t\t{build_uuid} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {file_name} */; }};\n"

            content = content[:build_file_insert] + build_file_entries + content[build_file_insert:]
            print(" Added PBXBuildFile entries")

        # Then add references to the build phase
        build_refs = ""
        for file_name, build_uuid in build_file_refs.items():
            build_refs += f"\n\t\t\t\t{build_uuid} /* {file_name} in Sources */,"

        # Re-find the position after our previous insertions
        build_phase_start = content.find(sources_build_phase_marker)
        files_array_start = content.find("files = (", build_phase_start)
        files_array_end = content.find(");", files_array_start)
        insert_pos = files_array_end

        content = content[:insert_pos] + build_refs + content[insert_pos:]
        print(" Added files to Sources build phase")
    else:
        print(" Could not find Sources build phase files array")
        sys.exit(1)
else:
    print(" Could not find PBXSourcesBuildPhase")
    sys.exit(1)

# Write back the modified project file
with open(project_path, 'w') as f:
    f.write(content)

print("\n Successfully added GmailFilterManager.swift and GmailFilterService.swift to Xcode project")
print("   Files are now in the build target and should compile.")
