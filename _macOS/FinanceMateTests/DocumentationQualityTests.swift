import XCTest
import Foundation

/// Test case validating documentation quality against Gold Standard template requirements
///
/// This test validates that the project documentation meets the Gold Standard template
/// requirements defined in ~/.claude/templates/project_repo/docs/
///
/// Requirement ID: BLUEPRINT-GOLD-001
/// Status: Pending
/// Dependencies: Gold Standard template analysis
/// Business Impact: Ensures documentation compliance and maintainability
final class DocumentationQualityTests: XCTestCase {

    // MARK: - Test Properties

    private let projectRootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    /// Array of required Gold Standard documents that must be present
    private let requiredDocuments = [
        "README.md",
        "BLUEPRINT.md",
        "TASKS.md",
        "BUILD_FAILURES.md",
        "SPECIFICATION_ARCHITECTURE.md"
    ]

    // MARK: - Test Methods

    /// Test that all required Gold Standard documents exist
    func test_requiredGoldStandardDocumentsExist() throws {
        // This test FAILS because the project doesn't have required documents
        // in the correct locations according to Gold Standard requirements

        let missingDocuments = requiredDocuments.filter { document in
            let documentURL = projectRootURL.appendingPathComponent(document)
            return !FileManager.default.fileExists(atPath: documentURL.path)
        }

        // Assert failure - this documents the gap between current and Gold Standard
        XCTAssertFalse(missingDocuments.isEmpty,
                      "Project is missing required Gold Standard documents: \(missingDocuments)")
    }

    /// Test that BLUEPRINT.md follows Gold Standard structure
    func test_blueprintDocumentStructure() throws {
        let blueprintURL = projectRootURL.appendingPathComponent("BLUEPRINT.md")

        // Check if BLUEPRINT.md exists in project root (Gold Standard requirement)
        guard FileManager.default.fileExists(atPath: blueprintURL.path) else {
            // This FAILS because BLUEPRINT.md is in ../docs/ not project root
            XCTFail("BLUEPRINT.md must exist in project root according to Gold Standard template")
            return
        }

        let blueprintContent = try String(contentsOf: blueprintURL)
        let requiredSections = [
            "EXECUTIVE SUMMARY",
            "PROJECT OVERVIEW",
            "TECHNICAL ARCHITECTURE"
        ]

        let missingSections = requiredSections.filter { section in
            !blueprintContent.contains(section)
        }

        // Assert failure - documents structure gaps
        XCTAssertFalse(missingSections.isEmpty,
                      "BLUEPRINT.md is missing required Gold Standard sections: \(missingSections)")
    }

    /// Test that README.md exists and contains essential information
    func test_readmeDocumentExists() throws {
        let readmeURL = projectRootURL.appendingPathComponent("README.md")

        // This FAILS because README.md doesn't exist in project root
        XCTAssertTrue(FileManager.default.fileExists(atPath: readmeURL.path),
                     "README.md must exist in project root according to Gold Standard template")
    }

    /// Test documentation completeness score
    func test_documentationCompletenessScore() throws {
        var presentDocuments = 0

        for document in requiredDocuments {
            let documentURL = projectRootURL.appendingPathComponent(document)
            if FileManager.default.fileExists(atPath: documentURL.path) {
                presentDocuments += 1
            }
        }

        let completenessScore = Double(presentDocuments) / Double(requiredDocuments.count) * 100

        // This FAILS because completeness is below Gold Standard threshold (90%)
        XCTAssertGreaterThanOrEqual(completenessScore, 90.0,
                                   "Documentation completeness score (\(completenessScore)%) is below Gold Standard requirement (90%)")
    }
}