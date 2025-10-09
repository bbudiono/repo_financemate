#!/usr/bin/env python3
"""
Add remaining Core Data dependencies to Xcode project
"""

import re
import uuid

def add_file_to_project(content, filename, file_ref_id, build_file_id):
    """Add a single file to Xcode project"""
    print(f"    Adding {filename}")

    # Add file reference
    file_ref = f"\t\t{file_ref_id} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"FinanceMate/{filename}\"; sourceTree = \"<group>\"; }};\n"
    content = content.replace("/* End PBXFileReference section */", file_ref + "/* End PBXFileReference section */")

    # Add build file reference
    build_ref = f"\t\t{build_file_id} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* {filename} */; }};\n"
    content = content.replace("/* End PBXBuildFile section */", build_ref + "/* End PBXBuildFile section */")

    # Add to Sources build phase
    sources_match = re.search(r'(PBXSourcesBuildPhase.*?files = \([^)]+)(\);)', content, re.DOTALL)
    if sources_match:
        sources_content = sources_match.group(1)
        new_sources = sources_content + f",\n\t\t\t\t\t{build_file_id} /* {filename} in Sources */"
        content = content.replace(sources_match.group(0), sources_match.group(1) + new_sources + sources_match.group(2))

    return content

def add_coredata_dependencies():
    """Add CoreDataEntityBuilder and CoreDataRelationshipBuilder to project"""
    print("🟢 Adding Core Data dependencies to Xcode project")

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    with open(project_file, 'r') as f:
        content = f.read()

    # Generate unique IDs
    entity_builder_file_ref = str(uuid.uuid4()).replace('-', '')[:24].upper()
    entity_builder_build_file = str(uuid.uuid4()).replace('-', '')[:24].upper()
    relationship_builder_file_ref = str(uuid.uuid4()).replace('-', '')[:24].upper()
    relationship_builder_build_file = str(uuid.uuid4()).replace('-', '')[:24].upper()

    # Add files if not already present
    if "CoreDataEntityBuilder.swift" not in content:
        content = add_file_to_project(content, "CoreDataEntityBuilder.swift",
                                   entity_builder_file_ref, entity_builder_build_file)

    if "CoreDataRelationshipBuilder.swift" not in content:
        content = add_file_to_project(content, "CoreDataRelationshipBuilder.swift",
                                   relationship_builder_file_ref, relationship_builder_build_file)

    # Write changes
    with open(project_file, 'w') as f:
        f.write(content)

    print(" Core Data dependencies added successfully")

if __name__ == "__main__":
    add_coredata_dependencies()