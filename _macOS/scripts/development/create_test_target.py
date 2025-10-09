#!/usr/bin/env python3
"""
Script to create FinanceMateTests target in Xcode project
This will add the missing test target and configure it properly
"""

import re
import uuid
import shutil
from pathlib import Path

def generate_uuid():
    """Generate a random UUID string for Xcode project references"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def read_project_file():
    """Read the current project.pbxproj file"""
    with open('FinanceMate.xcodeproj/project.pbxproj', 'r') as f:
        return f.read()

def write_project_file(content):
    """Write the updated content to project.pbxproj"""
    # Create backup first
    shutil.copy2('FinanceMate.xcodeproj/project.pbxproj', 'FinanceMate.xcodeproj/project.pbxproj.backup')
    with open('FinanceMate.xcodeproj/project.pbxproj', 'w') as f:
        f.write(content)

def find_last_section(content, section_name):
    """Find the end of a specific section in the project file"""
    pattern = rf'/\* End {section_name} section \*/'
    matches = list(re.finditer(pattern, content))
    if matches:
        return matches[-1].end()
    return None

def add_test_target(content):
    """Add FinanceMateTests target to the project"""

    # Generate UUIDs for new objects
    test_target_uuid = generate_uuid()
    test_target_config_uuid = generate_uuid()
    test_product_uuid = generate_uuid()

    # Find the last PBXBuildFile entry to add new ones
    build_files_section = find_last_section(content, "PBXBuildFile")
    if build_files_section:
        insert_pos = build_files_section
    else:
        # Fallback: find first section end
        insert_pos = content.find('/* End PBXBuildFile section */')
        if insert_pos == -1:
            insert_pos = content.find('/* Begin PBXBuildFile section */')

    # Test files to add
    test_files = [
        ('TransactionQueryHelperTests.swift', generate_uuid()),
        ('AnthropicAPIClientTests.swift', generate_uuid())
    ]

    # Build file entries for test sources
    build_file_entries = []
    for filename, file_uuid in test_files:
        entry = f"""\t\t{file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {generate_uuid()} /* {filename} */; }};"""
        build_file_entries.append(entry)

    # Insert build file entries
    insert_point = content.find('/* End PBXBuildFile section */')
    if insert_point != -1:
        before = content[:insert_point]
        after = content[insert_point:]
        new_build_files = '\n'.join(build_file_entries) + '\n'
        content = before + new_build_files + after

    # Add file references
    insert_point = content.find('/* End PBXFileReference section */')
    if insert_point != -1:
        before = content[:insert_point]
        after = content[insert_point:]

        file_refs = []
        for filename, _ in test_files:
            file_uuid = generate_uuid()
            ref_entry = f"""\t\t{file_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{filename}"; sourceTree = "<group>"; }};"""
            file_refs.append(ref_entry)

        # Add test bundle reference
        test_bundle_uuid = generate_uuid()
        test_bundle_ref = f"""\t\t{test_bundle_uuid} /* FinanceMateTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = FinanceMateTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};"""
        file_refs.append(test_bundle_ref)

        new_file_refs = '\n'.join(file_refs) + '\n'
        content = before + new_file_refs + after

    # Add test target
    insert_point = content.find('/* End PBXNativeTarget section */')
    if insert_point != -1:
        before = content[:insert_point]
        after = content[insert_point:]

        # Create test build phase UUID
        test_sources_phase_uuid = generate_uuid()
        test_frameworks_phase_uuid = generate_uuid()
        test_resources_phase_uuid = generate_uuid()

        test_target_entry = f"""\t\t{test_target_uuid} /* FinanceMateTests */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {test_target_config_uuid} /* Build configuration list for PBXNativeTarget "FinanceMateTests" */;
\t\t\tbuildPhases = (
\t\t\t\t{test_sources_phase_uuid} /* Sources */,
\t\t\t\t{test_frameworks_phase_uuid} /* Frameworks */,
\t\t\t\t{test_resources_phase_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = FinanceMateTests;
\t\t\tproductName = FinanceMateTests;
\t\t\tproductReference = {test_bundle_uuid} /* FinanceMateTests.xctest */;
\t\t\tproductType = "com.apple.product-type.bundle.unit-test";
\t\t}};"""

        content = before + test_target_entry + '\n' + after

    # Add build phases
    insert_point = content.find('/* End PBXSourcesBuildPhase section */')
    if insert_point != -1:
        before = content[:insert_point]
        after = content[insert_point:]

        test_sources_phase_uuid = generate_uuid()
        test_sources_entry = f"""\t\t{test_sources_phase_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{test_files[0][1]} /* TransactionQueryHelperTests.swift in Sources */,
\t\t\t\t{test_files[1][1]} /* AnthropicAPIClientTests.swift in Sources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};"""

        content = before + test_sources_entry + '\n' + after

    insert_point = content.find('/* End PBXFrameworksBuildPhase section */')
    if insert_point != -1:
        before = content[:insert_point]
        after = content[insert_point:]

        test_frameworks_phase_uuid = generate_uuid()
        test_frameworks_entry = f"""\t\t{test_frameworks_phase_uuid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};"""

        content = before + test_frameworks_entry + '\n' + after

    insert_point = content.find('/* End PBXResourcesBuildPhase section */')
    if insert_point != -1:
        before = content[:insert_point]
        after = content[insert_point:]

        test_resources_phase_uuid = generate_uuid()
        test_resources_entry = f"""\t\t{test_resources_phase_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};"""

        content = before + test_resources_entry + '\n' + after

    # Add test target to project targets
    insert_point = content.find('targets = (')
    if insert_point != -1:
        # Find the closing parenthesis for targets
        start_pos = insert_point
        paren_count = 0
        for i, char in enumerate(content[start_pos:], start_pos):
            if char == '(':
                paren_count += 1
            elif char == ')':
                paren_count -= 1
                if paren_count == 0:
                    # Insert before the closing parenthesis
                    before = content[:i]
                    after = content[i:]
                    test_target_ref = f"""\t\t\t{test_target_uuid} /* FinanceMateTests,"""
                    content = before + '\n' + test_target_ref + after
                    break

    # Update TargetAttributes
    insert_point = content.find('TargetAttributes = {')
    if insert_point != -1:
        # Find the closing brace for TargetAttributes
        start_pos = insert_point
        brace_count = 0
        for i, char in enumerate(content[start_pos:], start_pos):
            if char == '{':
                brace_count += 1
            elif char == '}':
                brace_count -= 1
                if brace_count == 0:
                    # Insert before the closing brace
                    before = content[:i]
                    after = content[i:]
                    test_attribute = f"""\n\t\t\t\t{test_target_uuid} = {{
\t\t\t\t\tTestTargetID = {test_target_uuid};
\t\t\t\t}},"""
                    content = before + test_attribute + after
                    break

    # Add test target build configuration
    insert_point = content.find('/* End XCConfigurationList section */')
    if insert_point != -1:
        before = content[:insert_point]
        after = content[insert_point:]

        debug_config_uuid = generate_uuid()
        release_config_uuid = generate_uuid()

        test_config_list = f"""\t\t{test_target_config_uuid} /* Build configuration list for PBXNativeTarget "FinanceMateTests" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_config_uuid} /* Debug */,
\t\t\t\t{release_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Debug;
\t\t}};"""

        content = before + test_config_list + '\n' + after

        # Add the actual build configurations
        insert_point = content.find('/* End XCBuildConfiguration section */')
        if insert_point != -1:
            before = content[:insert_point]
            after = content[insert_point:]

            debug_config = f"""\t\t{debug_config_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCOMBINE_HIDPI_IMAGES = YES;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = 7KV34995HH;
\t\t\t\tENABLE_TESTING_SEARCH_PATHS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = FinanceMateTests;
\t\t\t\tINFOPLIST_KEY_NSHumanReadableCopyright = "";
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.ablankcanvas.FinanceMateTests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_INSTALL_OBJC_HEADER = NO;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tTEST_TARGET_NAME = FinanceMate;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};"""

            release_config = f"""\t\t{release_config_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCOMBINE_HIDPI_IMAGES = YES;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = 7KV34995HH;
\t\t\t\tENABLE_TESTING_SEARCH_PATHS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = FinanceMateTests;
\t\t\t\tINFOPLIST_KEY_NSHumanReadableCopyright = "";
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.ablankcanvas.FinanceMateTests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_INSTALL_OBJC_HEADER = NO;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tTEST_TARGET_NAME = FinanceMate;
\t\t\t}};
\t\t\tname = Release;
\t\t}};"""

            content = before + debug_config + '\n' + release_config + '\n' + after

    return content

def add_test_group(content):
    """Add FinanceMateTests group to the project"""
    insert_point = content.find('/* End PBXGroup section */')
    if insert_point != -1:
        before = content[:insert_point]
        after = content[insert_point:]

        group_uuid = generate_uuid()
        test_group_entry = f"""\t\t{group_uuid} /* FinanceMateTests */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\tE728BDA24D7E5D5322C4F5B3 /* TransactionQueryHelperTests.swift */,
\t\t\t\tA3B5C8D9E7F2A4B6C8D0E1F2 /* AnthropicAPIClientTests.swift */,
\t\t\t);
\t\t\tpath = FinanceMateTests;
\t\t\tsourceTree = "<group>";
\t\t}};"""

        content = before + test_group_entry + '\n' + after

        # Add the group to the main group
        insert_point = content.find('mainGroup =')
        if insert_point != -1:
            # Find the main group UUID and add our test group to it
            main_group_pattern = r'mainGroup = ([A-F0-9]{24});'
            match = re.search(main_group_pattern, content)
            if match:
                main_group_uuid = match.group(1)
                # Find the main group definition
                group_pattern = rf'{main_group_uuid} /\* .*/ = {{\s*isa = PBXGroup;\s*children = \((.*?)\);'
                group_match = re.search(group_pattern, content, re.DOTALL)
                if group_match:
                    children_content = group_match.group(1)
                    if group_uuid not in children_content:
                        new_children = children_content.rstrip() + f',\n\t\t\t\t{group_uuid} /* FinanceMateTests */,'
                        content = content.replace(group_match.group(0),
                                                group_match.group(0).replace(children_content, new_children))

    return content

def main():
    """Main function to create the test target"""
    print(" Creating FinanceMateTests target in Xcode project...")

    # Read current project file
    content = read_project_file()

    # Add test target
    content = add_test_target(content)

    # Add test group
    content = add_test_group(content)

    # Write updated project file
    write_project_file(content)

    print(" FinanceMateTests target created successfully!")
    print(" Backup saved as project.pbxproj.backup")

    # Verify test files exist
    test_files = ['FinanceMateTests/TransactionQueryHelperTests.swift', 'FinanceMateTests/AnthropicAPIClientTests.swift']
    for test_file in test_files:
        if Path(test_file).exists():
            print(f" Found test file: {test_file}")
        else:
            print(f" Missing test file: {test_file}")

if __name__ == '__main__':
    main()