import XCTest
@testable import FinanceMate

// MARK: - ATOMIC TDD TEST: AIModelSelectionComponents Refactoring Validation
// REQUIREMENT: BLUEPRINT.md Modular Architecture Compliance
// TEST TYPE: Structural Validation Test (Failing)

final class AIModelSelectionComponentsRefactoringTests: XCTestCase {

    // MARK: - Failing Test: Component Size Violation

    func testAIModelSelectionComponentsShouldNotExceedAtomicSizeLimit() {
        // GIVEN: AIModelSelectionComponents.swift file path
        let componentPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Views/Settings/AIModelSelectionComponents.swift"

        // WHEN: Reading file content and counting lines
        let content = try? String(contentsOfFile: componentPath)
        let lineCount = content?.components(separatedBy: .newlines).count ?? 0

        // THEN: Component should not exceed 250 lines (Atomic TDD requirement)
        // FAILING ASSERTION: Current implementation has 391 lines
        XCTAssertLessThanOrEqual(lineCount, 250,
            "AIModelSelectionComponents.swift violates Atomic TDD size limit. Current: \(lineCount) lines, Maximum: 250 lines. Component must be refactored into smaller, focused modules.")
    }

    // MARK: - Failing Test: Component Modularity Validation

    func testAIModelSelectionComponentsShouldBeModular() {
        // GIVEN: AIModelSelectionComponents.swift file path
        let componentPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Views/Settings/AIModelSelectionComponents.swift"

        // WHEN: Analyzing component structure for extractable sections
        let content = try? String(contentsOfFile: componentPath)
        let structCount = content?.components(separatedBy: "struct ").count - 1

        // THEN: Component should have extractable sub-components
        // FAILING ASSERTION: Current structure doesn't support clean extraction
        XCTAssertGreaterThan(structCount, 4,
            "AIModelSelectionComponents.swift should have extractable components. Current struct count: \(structCount), Expected: >4 extractable components")
    }

    // MARK: - Failing Test: Single Responsibility Principle

    func testAIModelSelectionComponentsShouldFollowSingleResponsibility() {
        // GIVEN: AIModelSelectionComponents.swift file path
        let componentPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Views/Settings/AIModelSelectionComponents.swift"

        // WHEN: Analyzing component responsibilities
        let content = try? String(contentsOfFile: componentPath)

        var responsibilities = 0
        if content?.contains("Judge") == true { responsibilities += 1 }
        if content?.contains("Generator") == true { responsibilities += 1 }
        if content?.contains("Health") == true { responsibilities += 1 }
        if content?.contains("Action") == true { responsibilities += 1 }

        // THEN: Should have single, focused responsibility
        // FAILING ASSERTION: Current component handles multiple responsibilities
        XCTAssertLessThanOrEqual(responsibilities, 2,
            "AIModelSelectionComponents should have focused responsibility. Current responsibilities: \(responsibilities), Maximum: 2")
    }
}