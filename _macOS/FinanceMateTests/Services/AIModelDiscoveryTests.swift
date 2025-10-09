import XCTest
@testable import FinanceMate

/// Test suite for AI Model Configuration Manager - Model Discovery
/// BLUEPRINT.md 3.1.1.9: LLM-as-a-Judge Architecture
final class AIModelDiscoveryTests: XCTestCase {

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

    func testLocalModelDiscovery() {
        // Given: Mock Ollama service
        let mockOllamaService = MockOllamaService()
        manager.ollamaService = mockOllamaService
        mockOllamaService.mockModels = [
            OllamaModel(name: "llama3.2", size: "4.7B"),
            OllamaModel(name: "qwen2.5", size: "7B")
        ]

        // When: Discovering local models
        let models = manager.discoverLocalModels()

        // Then: Should return available local models
        XCTAssertEqual(models.count, 2)
        XCTAssertTrue(models.contains { $0.id == "llama3.2" })
        XCTAssertTrue(models.contains { $0.id == "qwen2.5" })
    }

    func testCloudModelDiscovery() {
        // Given: Mock API services
        let mockOpenAIService = MockOpenAIService()
        let mockAnthropicService = MockAnthropicService()
        manager.openaiService = mockOpenAIService
        manager.anthropicService = mockAnthropicService

        mockOpenAIService.mockModels = ["gpt-4", "gpt-3.5-turbo"]
        mockAnthropicService.mockModels = ["claude-3-5-sonnet", "claude-3-haiku"]

        // When: Discovering cloud models
        let models = manager.discoverCloudModels()

        // Then: Should return all available cloud models
        XCTAssertEqual(models.count, 4)
        XCTAssertTrue(models.contains { $0.id == "gpt-4" })
        XCTAssertTrue(models.contains { $0.id == "gpt-3.5-turbo" })
        XCTAssertTrue(models.contains { $0.id == "claude-3-5-sonnet" })
        XCTAssertTrue(models.contains { $0.id == "claude-3-haiku" })
    }
}