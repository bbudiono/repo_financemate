#!/usr/bin/env python3
"""
Add CoreDataManagerMinimal.swift to Xcode project
"""

import re
import uuid

def add_coredata_manager_minimal():
    """Add CoreDataManagerMinimal.swift to project"""

    project_file = "/Users/bernhardbudionbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    with open(project_file, 'r') as f:
        content = f.read()

    # Generate IDs
    service_ref = str(uuid.uuid4()).replace('-', '')[:24].upper()
    service_build = str(uuid.uuid4()).replace('-', '')[:24].upper()

    # Remove old CoreDataManager reference
    content = re.sub(r'\w+\w+\w+ /\* CoreDataManager\.swift \*/ = \{[^}]*\};?', '', content)

    # Add new file reference
    file_ref = f"\t\t{service_ref} /* CoreDataManager.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"FinanceMate/Services/CoreDataManager.swift\"; sourceTree = \"<group>\"; }};\n"

    # Add build file
    build_file = f"\t\t{service_build} /* CoreDataManager.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {service_ref} /* CoreDataManager.swift */; }};\n"

    # Apply changes
    content = content.replace('/* End PBXFileReference section */', file_ref + '/* End PBXFileReference section */')
    content = content.replace('/* End PBXBuildFile section */', build_file + '/* End PBXBuildFile section */')

    # Add to Sources
    sources_pattern = r'(/\\* Sources \\*/ = \\{[^}]+files = \\([^)]+)\\);'
    sources_match = re.search(sources_pattern, content, re.DOTALL)

    if sources_match:
        sources_content = sources_match.group(1)
        new_sources = sources_content + f'\\n\\t\\t\\t\\t{service_build} /* CoreDataManager.swift in Sources */,'
        content = content.replace(sources_content, new_sources)

    # Add to Services group
    services_pattern = r'(/\* Services \\*/ = \\{[^}]+children = \\([^)]+)\\);'
    services_match = re.search(services_pattern, content, re.DOTALL)

    if services_match:
        services_content = services_match.group(1)
        new_services = services_content + f'\\n\\t\\t\\t\\t{service_ref} /* CoreDataManager.swift */,'
        content = content.replace(services_content, new_services)

    with open(project_file, 'w') as f:
        f.write(content)

    return True

if __name__ == "__main__":
    if add_coredata_manager_minimal():
        print(" Added CoreDataManagerMinimal.swift to project")