import XCTest
@testable import FinanceMate

/// Test suite for AI Model Configuration Manager - Judge Model Configuration
/// BLUEPRINT.md 3.1.1.9: LLM-as-a-Judge Architecture
final class AIModelJudgeConfigurationTests: XCTestCase {

    var manager: AIModelConfigurationManager!
    var mockPersistenceController: MockPersistenceController!

    override func setUp() {
        super.setUp()
        mockPersistenceController = MockPersistenceController()
        manager = AIModelConfigurationManager(persistenceController: mockPersistenceController)
    }

    override func tearDown() {
        manager = nil
        mockPersistenceController = nil
        super.tearDown()
    }

    func testJudgeModelSelection() {
        // Given: Available local models
        let localModels = [
            AIModel(id: "llama3.2", name: "Llama 3.2", provider: .ollama, type: .local),
            AIModel(id: "qwen2.5", name: "Qwen 2.5", provider: .ollama, type: .local)
        ]

        // When: Selecting judge model
        let result = manager.setJudgeModel(localModels[0])

        // Then: Judge model should be configured
        XCTAssertTrue(result.success)
        XCTAssertEqual(manager.getCurrentJudgeModel()?.id, "llama3.2")
        XCTAssertEqual(manager.getCurrentJudgeModel()?.name, "Llama 3.2")
        XCTAssertEqual(manager.getCurrentJudgeModel()?.provider, .ollama)
    }

    func testJudgeModelValidation() {
        // Given: Invalid judge model (cloud model)
        let cloudModel = AIModel(id: "gpt-4", name: "GPT-4", provider: .openai, type: .cloud)

        // When: Attempting to set invalid judge model
        let result = manager.setJudgeModel(cloudModel)

        // Then: Should fail - judge must be local
        XCTAssertFalse(result.success)
        XCTAssertNotNil(result.error)
        XCTAssertEqual(result.error?.localizedDescription, "Judge LLM must be a local Ollama model")
        XCTAssertNil(manager.getCurrentJudgeModel())
    }
}