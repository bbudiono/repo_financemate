import XCTest
@testable import FinanceMate

/// Tests for device capability detection (BLUEPRINT Line 161)
final class ExtractionCapabilityDetectorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear any previous alert flag
        UserDefaults.standard.removeObject(forKey: "HasShownCapabilityAlert")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "HasShownCapabilityAlert")
        super.tearDown()
    }

    // CYCLE 1: Detection Logic Test
    func testDeviceCapabilityDetectionOnLaunch() {
        // Given: App has just launched
        XCTAssertNil(UserDefaults.standard.object(forKey: "HasShownCapabilityAlert"),
                     "Alert flag should not exist before first launch")

        // When: Capabilities are detected
        let capabilities = ExtractionCapabilityDetector.detect()

        // Then: All 4 required checks must be performed
        XCTAssertFalse(capabilities.macOSVersion.isEmpty, "macOS version must be detected")
        XCTAssertNotEqual(capabilities.chipType, "Unknown", "Chip type must be detected")
        // Apple Intelligence & Foundation Models may be false, but must be checkable
        XCTAssertTrue(capabilities.strategy == .foundationModels || capabilities.strategy == .regexOnly,
                      "Strategy must be determined based on capabilities")

        // And: Detection results should be persisted
        ExtractionCapabilityDetector.persistDetectionResults(capabilities)

        let hasShownAlert = UserDefaults.standard.bool(forKey: "HasShownCapabilityAlert")
        XCTAssertTrue(hasShownAlert, "Alert flag should be set after first detection")
    }

    func testCapabilityDetectionRequiresMinimumMacOS() {
        // When: Capabilities are detected
        let capabilities = ExtractionCapabilityDetector.detect()

        // Then: macOS version should be parseable
        let versionComponents = capabilities.macOSVersion.split(separator: ".")
        XCTAssertGreaterThanOrEqual(versionComponents.count, 2, "Version should have at least major.minor")

        if let majorVersion = Int(versionComponents[0]) {
            // If macOS >= 26, Foundation Models might be available
            if majorVersion >= 26 {
                // May or may not be available depending on Apple Intelligence
                XCTAssertTrue(capabilities.foundationModelsAvailable || !capabilities.appleIntelligenceEnabled,
                              "Foundation Models should only be available with Apple Intelligence on macOS 26+")
            } else {
                // macOS < 26: Foundation Models definitely not available
                XCTAssertFalse(capabilities.foundationModelsAvailable,
                               "Foundation Models require macOS 26+")
            }
        }
    }

    func testChipTypeDetectionReturnsValidResult() {
        // When: Chip type is detected
        let capabilities = ExtractionCapabilityDetector.detect()

        // Then: Should return a valid chip type
        let validChipTypes = ["M1", "M2", "M3", "M4", "Unknown"]
        XCTAssertTrue(validChipTypes.contains(capabilities.chipType),
                      "Chip type '\(capabilities.chipType)' should be one of: \(validChipTypes.joined(separator: ", "))")
    }

    func testStrategyMatchesCapabilities() {
        // When: Capabilities are detected
        let capabilities = ExtractionCapabilityDetector.detect()

        // Then: Strategy should match Foundation Models availability
        if capabilities.foundationModelsAvailable {
            XCTAssertEqual(capabilities.strategy, .foundationModels,
                           "Should use Foundation Models strategy when available")
        } else {
            XCTAssertEqual(capabilities.strategy, .regexOnly,
                           "Should use regex strategy when Foundation Models unavailable")
        }
    }
}
