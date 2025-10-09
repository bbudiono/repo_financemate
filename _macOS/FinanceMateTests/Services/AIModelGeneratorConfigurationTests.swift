import XCTest
@testable import FinanceMate

/// Test suite for AI Model Configuration Manager - Generator Model Configuration
/// BLUEPRINT.md 3.1.1.9: LLM-as-a-Judge Architecture
final class AIModelGeneratorConfigurationTests: XCTestCase {

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

    func testGeneratorModelSelection() {
        // Given: Available models from different providers
        let models = [
            AIModel(id: "gpt-4", name: "GPT-4", provider: .openai, type: .cloud),
            AIModel(id: "claude-3-5-sonnet", name: "Claude 3.5 Sonnet", provider: .anthropic, type: .cloud),
            AIModel(id: "llama3.2", name: "Llama 3.2", provider: .ollama, type: .local)
        ]

        // When: Adding generator models
        let result1 = manager.addGeneratorModel(models[0])
        let result2 = manager.addGeneratorModel(models[1])
        let result3 = manager.addGeneratorModel(models[2])

        // Then: All models should be added successfully
        XCTAssertTrue(result1.success)
        XCTAssertTrue(result2.success)
        XCTAssertTrue(result3.success)

        let generatorModels = manager.getGeneratorModels()
        XCTAssertEqual(generatorModels.count, 3)
        XCTAssertTrue(generatorModels.contains { $0.id == "gpt-4" })
        XCTAssertTrue(generatorModels.contains { $0.id == "claude-3-5-sonnet" })
        XCTAssertTrue(generatorModels.contains { $0.id == "llama3.2" })
    }

    func testGeneratorModelLimit() {
        // Given: 4 available generator models
        let models = (0..<4).map { i in
            AIModel(id: "model-\(i)", name: "Model \(i)", provider: .openai, type: .cloud)
        }

        // When: Adding more than 3 generator models
        let result1 = manager.addGeneratorModel(models[0])
        let result2 = manager.addGeneratorModel(models[1])
        let result3 = manager.addGeneratorModel(models[2])
        let result4 = manager.addGeneratorModel(models[3]) // Should fail

        // Then: First 3 should succeed, 4th should fail
        XCTAssertTrue(result1.success)
        XCTAssertTrue(result2.success)
        XCTAssertTrue(result3.success)
        XCTAssertFalse(result4.success)

        XCTAssertEqual(manager.getGeneratorModels().count, 3)
        XCTAssertEqual(result4.error?.localizedDescription, "Maximum 3 generator models allowed")
    }
}