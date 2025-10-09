#!/usr/bin/env python3
"""
GREEN Phase: Add CoreDataModelBuilder.swift to Xcode project - Safe approach
"""

import re
import uuid

def add_coredata_model_builder():
    """Add CoreDataModelBuilder.swift to project safely"""
    print("🟢 GREEN PHASE: Add CoreDataModelBuilder.swift to Xcode project")

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    with open(project_file, 'r') as f:
        content = f.read()

    # Generate IDs for CoreDataModelBuilder
    file_ref_id = str(uuid.uuid4()).replace('-', '')[:24].upper()
    build_file_id = str(uuid.uuid4()).replace('-', '')[:24].upper()

    # Check if CoreDataModelBuilder is already referenced
    if "CoreDataModelBuilder.swift" not in content:
        # Add file reference
        file_ref = f"\t\t{file_ref_id} /* CoreDataModelBuilder.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"FinanceMate/CoreDataModelBuilder.swift\"; sourceTree = \"<group>\"; }};\n"
        content = content.replace("/* End PBXFileReference section */", file_ref + "/* End PBXFileReference section */")

        # Add build file reference
        build_file = f"\t\t{build_file_id} /* CoreDataModelBuilder.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* CoreDataModelBuilder.swift */; }};\n"
        content = content.replace("/* End PBXBuildFile section */", build_file + "/* End PBXBuildFile section */")

        # Add to Sources build phase
        sources_pattern = r'(/\\\\* Sources \\\\*/ = \\\\{[^}]+files = \\\\([^)]+)\\\);)'
        sources_match = re.search(sources_pattern, content, re.DOTALL)

        if sources_match:
            sources_content = sources_match.group(1)
            new_sources = sources_content + f'\\\\n\\\\t\\\\t\\\\t\\\\t{build_file_id} /* CoreDataModelBuilder.swift in Sources */,'
            content = content.replace(sources_content, new_sources)

        # Apply changes
        with open(project_file, 'w') as f:
            f.write(content)

        print("     Added CoreDataModelBuilder.swift to project and Sources")
        return True
    else:
        # File already referenced, check if in Sources
        sources_match = re.search(r'PBXSourcesBuildPhase.*?files = \((.*?)\);', content, re.DOTALL)
        if sources_match:
            sources_content = sources_match.group(1)
            if "CoreDataModelBuilder.swift in Sources" in sources_content:
                print("     CoreDataModelBuilder.swift already in Sources")
                return True
            else:
                print("    ️  CoreDataModelBuilder.swift referenced but not in Sources")
                return False
        else:
            print("     Could not find Sources build phase")
            return False

if __name__ == "__main__":
    if add_coredata_model_builder():
        print("🟢 GREEN PHASE: CoreDataModelBuilder successfully added to project")