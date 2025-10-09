#!/usr/bin/env python3
"""
GREEN Phase: Add CoreDataModelBuilder.swift to Xcode project
"""

import re
import uuid

def fix_coredata_model_builder():
    """Add CoreDataModelBuilder.swift file and build references"""
    print("🟢 GREEN PHASE: Add CoreDataModelBuilder to project")

    # Generate unique IDs
    build_file_id = str(uuid.uuid4()).replace('-', '')[:24].upper()
    file_ref_id = str(uuid.uuid4()).replace('-', '')[:24].upper()

    with open("FinanceMate.xcodeproj/project.pbxproj", 'r') as f:
        content = f.read()

    # Add file reference if missing
    if f"{file_ref_id} /* CoreDataModelBuilder.swift */" not in content:
        file_ref = f"\t\t{file_ref_id} /* CoreDataModelBuilder.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"FinanceMate/CoreDataModelBuilder.swift\"; sourceTree = \"<group>\"; }};\n"
        content = content.replace("/* End PBXFileReference section */", file_ref + "/* End PBXFileReference section */")

        # Add build file reference
        build_file = f"\t\t{build_file_id} /* CoreDataModelBuilder.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* CoreDataModelBuilder.swift */; }};\n"
        content = content.replace("/* End PBXBuildFile section */", build_file + "/* End PBXBuildFile section */")

        # Add to Sources build phase
        sources_match = re.search(r'(PBXSourcesBuildPhase.*?files = \([^)]+)(\);)', content, re.DOTALL)
        if sources_match:
            sources_content = sources_match.group(1)
            new_sources = sources_content + f",\n\t\t\t\t\t{build_file_id} /* CoreDataModelBuilder.swift in Sources */"
            content = content.replace(sources_match.group(0), sources_match.group(1) + new_sources + sources_match.group(2))

        with open("FinanceMate.xcodeproj/project.pbxproj", 'w') as f:
            f.write(content)
        print("    Added CoreDataModelBuilder.swift to project and Sources")
    else:
        print("    CoreDataModelBuilder.swift already in project")
    return True

if __name__ == "__main__":
    fix_coredata_model_builder()
    print("🟢 GREEN PHASE: CoreDataModelBuilder fix applied")