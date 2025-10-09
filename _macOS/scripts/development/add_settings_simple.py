#!/usr/bin/env python3
"""
Add Settings files to Xcode project - Simple version
"""

import re
import uuid

def add_settings_files():
    """Add SettingsSidebar.swift and SettingsContent.swift to project"""

    project_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    with open(project_file, 'r') as f:
        content = f.read()

    # Generate IDs
    sidebar_ref = str(uuid.uuid4()).replace('-', '')[:24].upper()
    content_ref = str(uuid.uuid4()).replace('-', '')[:24].upper()
    sidebar_build = str(uuid.uuid4()).replace('-', '')[:24].upper()
    content_build = str(uuid.uuid4()).replace('-', '')[:24].upper()

    # Add file references
    file_refs = f"\t\t{sidebar_ref} /* SettingsSidebar.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"FinanceMate/Views/Settings/SettingsSidebar.swift\"; sourceTree = \"<group>\"; }};\n\t\t{content_ref} /* SettingsContent.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"FinanceMate/Views/Settings/SettingsContent.swift\"; sourceTree = \"<group>\"; }};\n"

    # Add build files
    build_files = f"\t\t{sidebar_build} /* SettingsSidebar.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {sidebar_ref} /* SettingsSidebar.swift */; }};\n\t\t{content_build} /* SettingsContent.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {content_ref} /* SettingsContent.swift */; }};\n"

    # Apply changes
    content = content.replace('/* End PBXFileReference section */', file_refs + '/* End PBXFileReference section */')
    content = content.replace('/* End PBXBuildFile section */', build_files + '/* End PBXBuildFile section */')

    # Add to Sources
    sources_pattern = r'(/\* Sources \*/ = \{[^}]+files = \([^)]+)\);'
    sources_match = re.search(sources_pattern, content)

    if sources_match:
        sources_content = sources_match.group(1)
        new_sources = sources_content + f'\n\t\t\t\t{sidebar_build} /* SettingsSidebar.swift in Sources */,\n\t\t\t\t{content_build} /* SettingsContent.swift in Sources */,'
        content = content.replace(sources_content, new_sources)

    with open(project_file, 'w') as f:
        f.write(content)

    return True

if __name__ == "__main__":
    if add_settings_files():
        print(" Added SettingsSidebar.swift and SettingsContent.swift to project")