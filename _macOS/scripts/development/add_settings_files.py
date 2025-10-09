#!/usr/bin/env python3
"""
Add Settings files to Xcode project using direct text manipulation
"""

import re

def add_settings_files():
    """Add SettingsSidebar.swift and SettingsContent.swift to project"""

    project_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    # Read project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Generate unique IDs
    import uuid
    settings_sidebar_ref = str(uuid.uuid4()).replace('-', '')[:24].upper()
    settings_content_ref = str(uuid.uuid4()).replace('-', '')[:24].upper()
    settings_sidebar_build = str(uuid.uuid4()).replace('-', '')[:24].upper()
    settings_content_build = str(uuid.uuid4()).replace('-', '')[:24].upper()

    # Add file references before End PBXFileReference section
    file_refs = f"""		{settings_sidebar_ref} /* SettingsSidebar.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "FinanceMate/Views/Settings/SettingsSidebar.swift"; sourceTree = "<group>"; }};
		{settings_content_ref} /* SettingsContent.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "FinanceMate/Views/Settings/SettingsContent.swift"; sourceTree = "<group>"; }};
"""

    # Add build file references before End PBXBuildFile section
    build_files = f"""		{settings_sidebar_build} /* SettingsSidebar.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {settings_sidebar_ref} /* SettingsSidebar.swift */; }};
		{settings_content_build} /* SettingsContent.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {settings_content_ref} /* SettingsContent.swift */; }};
"""

    # Apply changes
    content = content.replace('/* End PBXFileReference section */', file_refs + '/* End PBXFileReference section */')
    content = content.replace('/* End PBXBuildFile section */', build_files + '/* End PBXBuildFile section */')

    # Find and add to Sources build phase
    sources_pattern = r'(/\* Sources \*/ = \{[^}]+files = \([^)]+)\);'
    sources_match = re.search(sources_pattern, content)

    if sources_match:
        sources_content = sources_match.group(1)
        new_sources = sources_content + f'\n\t\t\t\t{settings_sidebar_build} /* SettingsSidebar.swift in Sources */,\n\t\t\t\t{settings_content_build} /* SettingsContent.swift in Sources */,'
        content = content.replace(sources_content, new_sources)
        print(" Added to Sources build phase")
    else:
        print(" Could not find Sources build phase")
        return False

    # Find Settings group and add files
    settings_pattern = r'(/\* Settings \*/ = \{[^}]+children = \([^)]+)\);'
    settings_match = re.search(settings_pattern, content)

    if settings_match:
        settings_content = settings_match.group(1)
        new_settings = settings_content + f'\n\t\t\t\t{settings_sidebar_ref} /* SettingsSidebar.swift */,\n\t\t\t\t{settings_content_ref} /* SettingsContent.swift */,'
        content = content.replace(settings_content, new_settings)
        print(" Added to Settings group")
    else:
        print("️ Could not find Settings group - files added but may need manual organization")

    # Write back
    with open(project_file, 'w') as f:
        f.write(content)

    print(" Successfully added SettingsSidebar.swift and SettingsContent.swift to project")
    return True

if __name__ == "__main__":
    if add_settings_files():
        print(" Files added successfully!")
    else:
        print(" Failed to add files")