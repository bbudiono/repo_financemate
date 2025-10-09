#!/usr/bin/env python3
"""
Script to add FinanceMateTests target to Xcode project for TDD Phase 1 RED
Creates test target configuration for comprehensive authentication testing
"""

import re
import uuid
import shutil
from pathlib import Path

def generate_uuid():
    """Generate a random UUID string"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_test_target_to_project():
    """Add FinanceMateTests target to existing Xcode project"""

    project_path = Path("FinanceMate.xcodeproj/project.pbxproj")
    if not project_path.exists():
        print(" project.pbxproj not found")
        return False

    # Read current project file
    with open(project_path, 'r') as f:
        content = f.read()

    # Generate unique IDs for test target
    test_target_id = generate_uuid()
    test_build_config_id = generate_uuid()
    test_debug_config_id = generate_uuid()
    test_release_config_id = generate_uuid()
    test_config_list_id = generate_uuid()

    # Test files to add
    test_files = [
        ("AuthTypesTests.swift", "FinanceMateTests/"),
        ("AuthenticationManagerTests.swift", "FinanceMateTests/"),
        ("Services/EmailConnectorServiceTests.swift", "FinanceMateTests/Services/"),
        ("Services/CoreDataManagerTests.swift", "FinanceMateTests/Services/"),
        ("Services/GmailAPIServiceTests.swift", "FinanceMateTests/Services/"),
        ("Services/SplitAllocationValidationServiceTests.swift", "FinanceMateTests/Services/"),
        ("Services/SplitAllocationTaxCategoryServiceTests.swift", "FinanceMateTests/Services/"),
        ("Services/SplitAllocationCalculationServiceTests.swift", "FinanceMateTests/Services/"),
        ("ViewModels/SplitAllocationViewModelTests.swift", "FinanceMateTests/ViewModels/"),
        ("SplitAllocationTests.swift", "FinanceMateTests/"),
        ("AccessibilityTests.swift", "FinanceMateTests/"),
        ("AccessibilityUnitTests.swift", "FinanceMateTests/"),
        ("Views/SplitVisualIndicatorTests.swift", "FinanceMateTests/Views/"),
        ("SimpleValidationTests.swift", "FinanceMateTests/")
    ]

    # Find insertion points
    pbx_build_file_section = re.search(r'\/\* Begin PBXBuildFile section \*/', content)
    pbx_file_reference_section = re.search(r'\/\* Begin PBXFileReference section \*/', content)
    pbx_native_target_section = re.search(r'\/\* Begin PBXNativeTarget section \*/', content)
    pbx_project_section = re.search(r'\/\* Begin PBXProject section \*/', content)
    xc_build_configuration_section = re.search(r'\/\* Begin XCBuildConfiguration section \*/', content)
    xc_configuration_list_section = re.search(r'\/\* Begin XCConfigurationList section \*/', content)

    if not all([pbx_build_file_section, pbx_file_reference_section, pbx_native_target_section,
                pbx_project_section, xc_build_configuration_section, xc_configuration_list_section]):
        print(" Could not find all required sections in project.pbxproj")
        return False

    # Create test target build files entries
    build_file_entries = []
    file_reference_entries = []

    for file_name, folder_path in test_files:
        file_id = generate_uuid()
        ref_id = generate_uuid()

        build_file_entries.append(f'\t\t{file_id} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {ref_id} /* {file_name} */; }};')
        file_reference_entries.append(f'\t\t{ref_id} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{file_name}"; sourceTree = "<group>"; }};')

    # Build file entries for test target
    test_build_file_entries = [
        f'\t\t{test_build_config_id} /* XCTest.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = "XCTest_XCTest_Framework_" /* XCTest.framework */; }};',
    ]

    # Test target build configuration entries
    test_debug_config = f'''
\t	{test_debug_config_id} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"$(inherited)",
					"DEBUG=1",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/FinanceMate.app/Contents/MacOS/FinanceMate";
			}};
			name = Debug;
		}};'''

    test_release_config = f'''
\t	{test_release_config_id} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				SWIFT_VERSION = 5.0;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/FinanceMate.app/Contents/MacOS/FinanceMate";
			}};
			name = Release;
		}};'''

    # Test target configuration
    test_target_entry = f'''
\t\t{test_target_id} /* FinanceMateTests */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {test_config_list_id} /* Build configuration list for PBXNativeTarget "FinanceMateTests" */;
			buildPhases = (
				{test_build_config_id} /* Sources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = FinanceMateTests;
			productName = FinanceMateTests;
			productReference = "FinanceMateTests_Product_" /* FinanceMateTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		}};'''

    # Test configuration list
    test_config_list_entry = f'''
\t\t{test_config_list_id} /* Build configuration list for PBXNativeTarget "FinanceMateTests" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{test_debug_config_id} /* Debug */,
				{test_release_config_id} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		}};'''

    # Insert entries into project file
    new_content = content

    # Insert build file entries
    build_file_insert_pos = pbx_build_file_section.end()
    new_content = new_content[:build_file_insert_pos] + '\n' + '\n'.join(build_file_entries) + new_content[build_file_insert_pos:]

    # Insert file reference entries
    file_ref_insert_pos = pbx_file_reference_section.end()
    new_content = new_content[:file_ref_insert_pos] + '\n' + '\n'.join(file_reference_entries) + new_content[file_ref_insert_pos:]

    # Insert test target entry
    target_insert_pos = pbx_native_target_section.end()
    new_content = new_content[:target_insert_pos] + test_target_entry + new_content[target_insert_pos:]

    # Insert build configurations
    build_config_insert_pos = xc_build_configuration_section.end()
    new_content = new_content[:build_config_insert_pos] + test_debug_config + test_release_config + new_content[build_config_insert_pos:]

    # Insert configuration list
    config_list_insert_pos = xc_configuration_list_section.end()
    new_content = new_content[:config_list_insert_pos] + test_config_list_entry + new_content[config_list_insert_pos:]

    # Write updated project file
    with open(project_path, 'w') as f:
        f.write(new_content)

    print(" Test target configuration added to project.pbxproj")
    return True

def main():
    """Main execution function"""
    print(" Phase 1 RED: Adding FinanceMateTests target to Xcode project")

    if add_test_target_to_project():
        print(" Test target successfully configured")
        print(" Next: Run 'xcodebuild test -scheme FinanceMate -destination platform=macOS' to verify RED phase")
    else:
        print(" Failed to configure test target")
        return 1

    return 0

if __name__ == "__main__":
    exit(main())