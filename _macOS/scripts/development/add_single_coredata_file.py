#!/usr/bin/env python3
"""
Add single Core Data file to Xcode project
"""

import re
import uuid
import sys

def add_single_file(filename):
    """Add a single file to Xcode project safely"""
    print(f"Adding {filename} to project")

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    with open(project_file, 'r') as f:
        content = f.read()

    # Skip if already present
    if filename in content:
        print(f"    {filename} already in project")
        return True

    # Generate unique IDs
    file_ref_id = str(uuid.uuid4()).replace('-', '')[:24].upper()
    build_file_id = str(uuid.uuid4()).replace('-', '')[:24].upper()

    # Add file reference
    file_ref = f"\t\t{file_ref_id} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"FinanceMate/{filename}\"; sourceTree = \"<group>\"; }};\n"
    content = content.replace("/* End PBXFileReference section */", file_ref + "/* End PBXFileReference section */")

    # Add build file reference
    build_ref = f"\t\t{build_file_id} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* {filename} */; }};\n"
    content = content.replace("/* End PBXBuildFile section */", build_ref + "/* End PBXBuildFile section */")

    # Add to Sources build phase - find existing CoreDataModelBuilder and add after it
    coredata_pattern = r'(2E46FD96467E4F3DB3DD544D /\* CoreDataModelBuilder\.swift in Sources \*/)(\);)'
    match = re.search(coredata_pattern, content)
    if match:
        new_sources = match.group(1) + f",\n\t\t\t\t\t{build_file_id} /* {filename} in Sources */" + match.group(2)
        content = content.replace(match.group(0), new_sources)
        print(f"    Added {filename} after CoreDataModelBuilder")
    else:
        print(f"    Could not find CoreDataModelBuilder pattern")

    # Write changes
    with open(project_file, 'w') as f:
        f.write(content)

    print(f"     {filename} added successfully")
    return True

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 add_single_coredata_file.py <filename>")
        sys.exit(1)

    filename = sys.argv[1]
    add_single_file(filename)