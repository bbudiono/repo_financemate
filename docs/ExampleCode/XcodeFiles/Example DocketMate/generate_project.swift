#!/usr/bin/swift

import Foundation

// Configuration
let projectName = "FinanceMate"
let organizationName = "FinanceMate"
let bundleIdPrefix = "com.docketmate"
let deploymentTarget = "14.0"

// Paths
let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let projectURL = currentDirectoryURL
let sourcesURL = projectURL.appendingPathComponent("Sources")
let resourcesURL = projectURL.appendingPathComponent("Resources")
let projectFileURL = projectURL.appendingPathComponent("\(projectName).xcodeproj")
let pbxprojURL = projectFileURL.appendingPathComponent("project.pbxproj")

// Create project directory if it doesn't exist
try? FileManager.default.createDirectory(at: projectFileURL, withIntermediateDirectories: true)

// Get all Swift files in the Sources directory
let sourcesEnumerator = FileManager.default.enumerator(at: sourcesURL, includingPropertiesForKeys: nil)
var sourceFiles = [URL]()
while let fileURL = sourcesEnumerator?.nextObject() as? URL {
    if fileURL.pathExtension == "swift" {
        sourceFiles.append(fileURL)
    }
}

// Get resource files if any
var resourceFiles = [URL]()
if FileManager.default.fileExists(atPath: resourcesURL.path) {
    let resourcesEnumerator = FileManager.default.enumerator(at: resourcesURL, includingPropertiesForKeys: nil)
    while let fileURL = resourcesEnumerator?.nextObject() as? URL {
        if !fileURL.hasDirectoryPath {
            resourceFiles.append(fileURL)
        }
    }
}

// Generate UUIDs for project elements
func generateUUID() -> String {
    return UUID().uuidString.uppercased()
}

let mainGroupUUID = generateUUID()
let productRefGroupUUID = generateUUID()
let frameworksGroupUUID = generateUUID()
let sourcesGroupUUID = generateUUID()
let resourcesGroupUUID = generateUUID()
let targetUUID = generateUUID()
let productUUID = generateUUID()
let buildConfigurationListUUID = generateUUID()
let debugConfigurationUUID = generateUUID()
let releaseConfigurationUUID = generateUUID()
let projectUUID = generateUUID()
let buildPhaseSourcesUUID = generateUUID()
let buildPhaseResourcesUUID = generateUUID()
let buildPhaseFrameworksUUID = generateUUID()

// Create file references for source files
var fileReferenceSection = ""
var sourcesBuildPhase = ""
var buildFileSection = ""
var mainGroupChildren = ""
var sourceGroupChildren = ""

for sourceFile in sourceFiles {
    let fileUUID = generateUUID()
    let buildFileUUID = generateUUID()
    let relativePath = sourceFile.path.replacingOccurrences(of: sourcesURL.path + "/", with: "")
    
    // File reference
    fileReferenceSection += "\t\t\(fileUUID) /* \(relativePath) */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"\(relativePath)\"; sourceTree = \"<group>\"; };\n"
    
    // Build file
    buildFileSection += "\t\t\(buildFileUUID) /* \(relativePath) in Sources */ = {isa = PBXBuildFile; fileRef = \(fileUUID) /* \(relativePath) */; };\n"
    
    // Source build phase
    sourcesBuildPhase += "\t\t\t\t\(buildFileUUID) /* \(relativePath) in Sources */,\n"
    
    // Source group children
    sourceGroupChildren += "\t\t\t\t\(fileUUID) /* \(relativePath) */,\n"
}

// Create file references for resource files
var resourcesBuildPhase = ""
var resourceGroupChildren = ""

for resourceFile in resourceFiles {
    let fileUUID = generateUUID()
    let buildFileUUID = generateUUID()
    let relativePath = resourceFile.path.replacingOccurrences(of: resourcesURL.path + "/", with: "")
    let fileType: String
    
    switch resourceFile.pathExtension.lowercased() {
    case "png", "jpg", "jpeg":
        fileType = "image.\(resourceFile.pathExtension.lowercased())"
    case "storyboard":
        fileType = "file.storyboard"
    case "xib":
        fileType = "file.xib"
    case "plist":
        fileType = "text.plist.xml"
    case "json":
        fileType = "text.json"
    case "txt":
        fileType = "text"
    default:
        fileType = "file"
    }
    
    // File reference
    fileReferenceSection += "\t\t\(fileUUID) /* \(relativePath) */ = {isa = PBXFileReference; lastKnownFileType = \(fileType); path = \"\(relativePath)\"; sourceTree = \"<group>\"; };\n"
    
    // Build file
    buildFileSection += "\t\t\(buildFileUUID) /* \(relativePath) in Resources */ = {isa = PBXBuildFile; fileRef = \(fileUUID) /* \(relativePath) */; };\n"
    
    // Resources build phase
    resourcesBuildPhase += "\t\t\t\t\(buildFileUUID) /* \(relativePath) in Resources */,\n"
    
    // Resource group children
    resourceGroupChildren += "\t\t\t\t\(fileUUID) /* \(relativePath) */,\n"
}

// Create product reference
fileReferenceSection += "\t\t\(productUUID) /* \(projectName).app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = \"\(projectName).app\"; sourceTree = BUILT_PRODUCTS_DIR; };\n"

// Main children
mainGroupChildren = """
				\(sourcesGroupUUID) /* Sources */,
				\(resourcesGroupUUID) /* Resources */,
				\(productRefGroupUUID) /* Products */,
				\(frameworksGroupUUID) /* Frameworks */,
"""

// Create the project.pbxproj content
let pbxprojContent = """
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
\(buildFileSection)
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
\(fileReferenceSection)
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		\(buildPhaseFrameworksUUID) /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		\(mainGroupUUID) = {
			isa = PBXGroup;
			children = (
\(mainGroupChildren)
			);
			sourceTree = "<group>";
		};
		\(productRefGroupUUID) /* Products */ = {
			isa = PBXGroup;
			children = (
				\(productUUID) /* \(projectName).app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		\(frameworksGroupUUID) /* Frameworks */ = {
			isa = PBXGroup;
			children = (
			);
			name = Frameworks;
			sourceTree = "<group>";
		};
		\(sourcesGroupUUID) /* Sources */ = {
			isa = PBXGroup;
			children = (
\(sourceGroupChildren)
			);
			path = Sources;
			sourceTree = "<group>";
		};
		\(resourcesGroupUUID) /* Resources */ = {
			isa = PBXGroup;
			children = (
\(resourceGroupChildren)
			);
			path = Resources;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		\(targetUUID) /* \(projectName) */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = \(buildConfigurationListUUID) /* Build configuration list for PBXNativeTarget "\(projectName)" */;
			buildPhases = (
				\(buildPhaseSourcesUUID) /* Sources */,
				\(buildPhaseResourcesUUID) /* Resources */,
				\(buildPhaseFrameworksUUID) /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = \(projectName);
			productName = \(projectName);
			productReference = \(productUUID) /* \(projectName).app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		\(projectUUID) /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				ORGANIZATIONNAME = "\(organizationName)";
				TargetAttributes = {
					\(targetUUID) = {
						CreatedOnToolsVersion = 14.0;
					};
				};
			};
			buildConfigurationList = \(buildConfigurationListUUID) /* Build configuration list for PBXNativeTarget "\(projectName)" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = \(mainGroupUUID);
			productRefGroup = \(productRefGroupUUID) /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				\(targetUUID) /* \(projectName) */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		\(buildPhaseResourcesUUID) /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
\(resourcesBuildPhase)
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		\(buildPhaseSourcesUUID) /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
\(sourcesBuildPhase)
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		\(debugConfigurationUUID) /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
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
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				COPY_PHASE_STRIP = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				INFOPLIST_FILE = "$(SRCROOT)/Resources/Info.plist";
				INFOPLIST_KEY_CFBundleDisplayName = \(projectName);
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.productivity";
				INFOPLIST_KEY_NSHumanReadableCopyright = "Copyright © \(organizationName). All rights reserved.";
				INFOPLIST_KEY_NSMainStoryboardFile = "";
				INFOPLIST_KEY_NSPrincipalClass = NSApplication;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = \(deploymentTarget);
				MARKETING_VERSION = 1.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				PRODUCT_BUNDLE_IDENTIFIER = \(bundleIdPrefix).\(projectName.lowercased());
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		\(releaseConfigurationUUID) /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
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
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				COPY_PHASE_STRIP = NO;
				CURRENT_PROJECT_VERSION = 1;
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
				INFOPLIST_FILE = "$(SRCROOT)/Resources/Info.plist";
				INFOPLIST_KEY_CFBundleDisplayName = \(projectName);
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.productivity";
				INFOPLIST_KEY_NSHumanReadableCopyright = "Copyright © \(organizationName). All rights reserved.";
				INFOPLIST_KEY_NSMainStoryboardFile = "";
				INFOPLIST_KEY_NSPrincipalClass = NSApplication;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = \(deploymentTarget);
				MARKETING_VERSION = 1.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				PRODUCT_BUNDLE_IDENTIFIER = \(bundleIdPrefix).\(projectName.lowercased());
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		\(buildConfigurationListUUID) /* Build configuration list for PBXNativeTarget "\(projectName)" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				\(debugConfigurationUUID) /* Debug */,
				\(releaseConfigurationUUID) /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = \(projectUUID) /* Project object */;
}
"""

// Write the project.pbxproj file
try pbxprojContent.write(to: pbxprojURL, atomically: true, encoding: .utf8)

// Create essential directories
try? FileManager.default.createDirectory(at: resourcesURL, withIntermediateDirectories: true)

// Create Info.plist file if it doesn't exist
let infoPlistURL = resourcesURL.appendingPathComponent("Info.plist")
if !FileManager.default.fileExists(atPath: infoPlistURL.path) {
    let infoPlistContent = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>$(MARKETING_VERSION)</string>
	<key>CFBundleVersion</key>
	<string>$(CURRENT_PROJECT_VERSION)</string>
	<key>LSMinimumSystemVersion</key>
	<string>$(MACOSX_DEPLOYMENT_TARGET)</string>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © \(organizationName). All rights reserved.</string>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.productivity</string>
</dict>
</plist>
"""
    try infoPlistContent.write(to: infoPlistURL, atomically: true, encoding: .utf8)
}

print("✅ Successfully created Xcode project at: \(projectFileURL.path)")
print("🔍 Generated project for \(sourceFiles.count) source files")
print("ℹ️ You can now open the project in Xcode") 