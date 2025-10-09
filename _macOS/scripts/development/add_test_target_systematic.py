#!/usr/bin/env python3
"""
Systematic approach to add FinanceMateTests target to Xcode project
"""

import re
import uuid
import shutil

def generate_uuid():
    """Generate a 24-character uppercase hex string"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def read_project():
    """Read the project file"""
    with open('FinanceMate.xcodeproj/project.pbxproj', 'r') as f:
        return f.read()

def write_project(content):
    """Write the project file"""
    shutil.copy2('FinanceMate.xcodeproj/project.pbxproj', 'FinanceMate.xcodeproj/project.pbxproj.working')
    with open('FinanceMate.xcodeproj/project.pbxproj', 'w') as f:
        f.write(content)

def add_test_target():
    """Add test target to project systematically"""

    content = read_project()

    # Generate UUIDs
    test_target_uuid = generate_uuid()
    test_build_config_uuid = generate_uuid()
    test_product_uuid = generate_uuid()
    test_sources_uuid = generate_uuid()
    test_frameworks_uuid = generate_uuid()
    test_resources_uuid = generate_uuid()
    test_group_uuid = generate_uuid()
    test_debug_config_uuid = generate_uuid()
    test_release_config_uuid = generate_uuid()

    # Test file UUIDs
    transaction_test_file_uuid = generate_uuid()
    transaction_test_ref_uuid = generate_uuid()
    anthropic_test_file_uuid = generate_uuid()
    anthropic_test_ref_uuid = generate_uuid()

    # 1. Add test build files
    build_files_section = content.find('/* End PBXBuildFile section */')
    if build_files_section != -1:
        build_files = f"""
\t\t{transaction_test_file_uuid} /* TransactionQueryHelperTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {transaction_test_ref_uuid} /* TransactionQueryHelperTests.swift */; }};
\t\t{anthropic_test_file_uuid} /* AnthropicAPIClientTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {anthropic_test_ref_uuid} /* AnthropicAPIClientTests.swift */; }};"""

        content = content[:build_files_section] + build_files + '\n' + content[build_files_section:]

    # 2. Add file references
    file_refs_section = content.find('/* End PBXFileReference section */')
    if file_refs_section != -1:
        file_refs = f"""
\t\t{transaction_test_ref_uuid} /* TransactionQueryHelperTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TransactionQueryHelperTests.swift; sourceTree = "<group>"; }};
\t\t{anthropic_test_ref_uuid} /* AnthropicAPIClientTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AnthropicAPIClientTests.swift; sourceTree = "<group>"; }};
\t\t{test_product_uuid} /* FinanceMateTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = FinanceMateTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};"""

        content = content[:file_refs_section] + file_refs + '\n' + content[file_refs_section:]

    # 3. Add test group
    groups_section = content.find('/* End PBXGroup section */')
    if groups_section != -1:
        test_group = f"""
\t\t{test_group_uuid} /* FinanceMateTests */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{transaction_test_ref_uuid} /* TransactionQueryHelperTests.swift */,
\t\t\t\t{anthropic_test_ref_uuid} /* AnthropicAPIClientTests.swift */,
\t\t\t);
\t\t\tpath = FinanceMateTests;
\t\t\tsourceTree = "<group>";
\t\t}};"""

        content = content[:groups_section] + test_group + '\n' + content[groups_section:]

    # 4. Add test target
    targets_section = content.find('/* End PBXNativeTarget section */')
    if targets_section != -1:
        test_target = f"""
\t\t{test_target_uuid} /* FinanceMateTests */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {test_build_config_uuid} /* Build configuration list for PBXNativeTarget "FinanceMateTests" */;
\t\t\tbuildPhases = (
\t\t\t\t{test_sources_uuid} /* Sources */,
\t\t\t\t{test_frameworks_uuid} /* Frameworks */,
\t\t\t\t{test_resources_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = FinanceMateTests;
\t\t\tproductName = FinanceMateTests;
\t\t\tproductReference = {test_product_uuid} /* FinanceMateTests.xctest */;
\t\t\tproductType = "com.apple.product-type.bundle.unit-test";
\t\t}};"""

        content = content[:targets_section] + test_target + '\n' + content[targets_section:]

    # 5. Add build phases
    sources_section = content.find('/* End PBXSourcesBuildPhase section */')
    if sources_section != -1:
        test_sources_phase = f"""
\t\t{test_sources_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{transaction_test_file_uuid} /* TransactionQueryHelperTests.swift in Sources */,
\t\t\t\t{anthropic_test_file_uuid} /* AnthropicAPIClientTests.swift in Sources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};"""

        content = content[:sources_section] + test_sources_phase + '\n' + content[sources_section:]

    frameworks_section = content.find('/* End PBXFrameworksBuildPhase section */')
    if frameworks_section != -1:
        test_frameworks_phase = f"""
\t\t{test_frameworks_uuid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};"""

        content = content[:frameworks_section] + test_frameworks_phase + '\n' + content[frameworks_section:]

    resources_section = content.find('/* End PBXResourcesBuildPhase section */')
    if resources_section != -1:
        test_resources_phase = f"""
\t\t{test_resources_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};"""

        content = content[:resources_section] + test_resources_phase + '\n' + content[resources_section:]

    # 6. Add build configurations
    build_config_section = content.find('/* End XCBuildConfiguration section */')
    if build_config_section != -1:
        test_debug_config = f"""
\t\t{test_debug_config_uuid} /* Debug */ = {{
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

        test_release_config = f"""
\t\t{test_release_config_uuid} /* Release */ = {{
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

        content = content[:build_config_section] + test_debug_config + '\n' + test_release_config + '\n' + content[build_config_section:]

    # 7. Add configuration list
    config_list_section = content.find('/* End XCConfigurationList section */')
    if config_list_section != -1:
        test_config_list = f"""
\t\t{test_build_config_uuid} /* Build configuration list for PBXNativeTarget "FinanceMateTests" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{test_debug_config_uuid} /* Debug */,
\t\t\t\t{test_release_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Debug;
\t\t}};"""

        content = content[:config_list_section] + test_config_list + '\n' + content[config_list_section:]

    # 8. Update project sections
    # Add test target to targets list
    targets_pattern = r'(targets = \([^)]+))'
    targets_match = re.search(targets_pattern, content, re.DOTALL)
    if targets_match:
        old_targets = targets_match.group(1)
        new_targets = old_targets.replace(
            '9BCE076CC14C69F83263D6C5 /* FinanceMate */',
            '9BCE076CC14C69F83263D6C5 /* FinanceMate */,\n\t\t\t\t' + test_target_uuid + ' /* FinanceMateTests */'
        )
        content = content.replace(old_targets, new_targets)

    # Add test target to TargetAttributes
    target_attrs_pattern = r'(TargetAttributes = \{[^}]+})'
    target_attrs_match = re.search(target_attrs_pattern, content, re.DOTALL)
    if target_attrs_match:
        old_attrs = target_attrs_match.group(1)
        new_attrs = old_attrs.replace(
            'ProvisioningStyle = Automatic;\n\t\t\t\t};',
            'ProvisioningStyle = Automatic;\n\t\t\t\t' + test_target_uuid + ' = {\n\t\t\t\t\tTestTargetID = ' + test_target_uuid + ';\n\t\t\t\t},\n\t\t\t\t};'
        )
        content = content.replace(old_attrs, new_attrs)

    # Add test group to main group
    main_group_pattern = r'(664632500DD526A9BDF8015A /\* \*/ = \{[^}]+children = \([^)]+)\);'
    main_group_match = re.search(main_group_pattern, content, re.DOTALL)
    if main_group_match:
        old_children = main_group_match.group(1)
        new_children = old_children + ',\n\t\t\t\t' + test_group_uuid + ' /* FinanceMateTests */'
        content = content.replace(old_children, new_children)

    # Add test product to Products group
    products_pattern = r'(C190AFCE18F9B21044E96663 /\* Products \*/ = \{[^}]+children = \([^)]+)\);'
    products_match = re.search(products_pattern, content, re.DOTALL)
    if products_match:
        old_products = products_match.group(1)
        new_products = old_products.replace(
            '6AD7F62BE980B30C777D9BCC /* FinanceMate.app */',
            '6AD7F62BE980B30C777D9BCC /* FinanceMate.app */,\n\t\t\t\t' + test_product_uuid + ' /* FinanceMateTests.xctest */'
        )
        content = content.replace(old_products, new_products)

    return content

def main():
    print(" Adding FinanceMateTests target systematically...")

    try:
        content = add_test_target()
        write_project(content)
        print(" FinanceMateTests target added successfully!")
        print(" Backup saved as project.pbxproj.working")
    except Exception as e:
        print(f" Error: {e}")
        return 1

    return 0

if __name__ == '__main__':
    exit(main())