#!/usr/bin/env python3
"""Add TransactionDescriptionBuilder.swift to Xcode project"""
import uuid

project_path = "FinanceMate.xcodeproj/project.pbxproj"
file_path = "Services/TransactionDescriptionBuilder.swift"
file_name = "TransactionDescriptionBuilder.swift"

file_ref_uuid = str(uuid.uuid4()).replace('-', '')[:24].upper()
build_file_uuid = str(uuid.uuid4()).replace('-', '')[:24].upper()

print(f"Adding {file_name} to Xcode project...")
print(f"  File UUID: {file_ref_uuid}")
print(f"  Build UUID: {build_file_uuid}")

with open(project_path, 'r') as f:
    content = f.read()

# 1. Add PBXBuildFile entry
build_file_marker = "/* Begin PBXBuildFile section */"
if build_file_marker in content:
    insert_pos = content.find(build_file_marker) + len(build_file_marker)
    new_build_file = f"\n\t\t{build_file_uuid} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {file_name} */; }};"
    content = content[:insert_pos] + new_build_file + content[insert_pos:]
    print(" Added PBXBuildFile entry")

# 2. Add PBXFileReference entry
file_ref_marker = "/* Begin PBXFileReference section */"
if file_ref_marker in content:
    insert_pos = content.find(file_ref_marker) + len(file_ref_marker)
    new_file_ref = f"\n\t\t{file_ref_uuid} /* {file_name} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {file_path}; sourceTree = \"<group>\"; }};"
    content = content[:insert_pos] + new_file_ref + content[insert_pos:]
    print(" Added PBXFileReference entry")

# 3. Add to Services group
services_marker = "394E4BEBB6D3E4E94BB188EA /* Services */ = {"
if services_marker in content:
    services_start = content.find(services_marker)
    children_start = content.find("children = (", services_start)
    children_end = content.find(");", children_start)
    if children_start > 0 and children_end > 0:
        new_child = f"\n\t\t\t\t{file_ref_uuid} /* {file_name} */,"
        content = content[:children_end] + new_child + content[children_end:]
        print(" Added to Services group")

# 4. Add to Sources build phase
sources_marker = "E728BDA24D7E5D5322C4F5B3 /* Sources */ = {"
if sources_marker in content:
    sources_start = content.find(sources_marker)
    files_start = content.find("files = (", sources_start)
    files_end = content.find(");", files_start)
    if files_start > 0 and files_end > 0:
        new_source = f"\n\t\t\t\t{build_file_uuid} /* {file_name} in Sources */,"
        content = content[:files_end] + new_source + content[files_end:]
        print(" Added to Sources build phase")

with open(project_path, 'w') as f:
    f.write(content)

print(f"\n Successfully added {file_name} to Xcode project")
