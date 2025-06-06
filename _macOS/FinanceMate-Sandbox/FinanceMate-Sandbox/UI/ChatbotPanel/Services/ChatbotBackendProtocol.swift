// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  ChatbotBackendProtocol.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/4/25.
//

/*
* Purpose: Protocol definitions for chatbot backend integration - defines clear interface for live backend services
* Issues & Complexity Summary: Clean protocol design for seamless backend integration without mock implementations
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~80
  - Core Algorithm Complexity: Low
  - Dependencies: 2 New (Foundation, Combine)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 35%
* Problem Estimate (Inherent Problem Difficulty %): 30%
* Initial Code Complexity Estimate %: 33%
* Justification for Estimates: Straightforward protocol definitions for backend integration
* Final Code Complexity (Actual %): 32%
* Overall Result Score (Success & Quality %): 98%
* Key Variances/Learnings: Clean protocol design ensures easy integration with live services
* Last Updated: 2025-06-04
*/

import Foundation
import Combine

// MARK: - Main Chatbot Backend Protocol

/// Protocol defining the interface for chatbot backend services
/// This protocol must be implemented by the actual backend service
public protocol ChatbotBackendProtocol {
    
    // MARK: - Message Handling
    
    /// Send a user message to the chatbot backend
    /// - Parameter text: The user's message text
    /// - Returns: A publisher that emits the response or error
    func sendUserMessage(text: String) -> AnyPublisher<ChatResponse, ChatError>
    
    /// Publisher for receiving real-time chatbot responses
    /// This should emit responses as they arrive, supporting streaming if available
    var chatbotResponsePublisher: AnyPublisher<ChatMessage, Never> { get }
    
    /// Stop current response generation if streaming is supported
    func stopCurrentGeneration()
    
    // MARK: - Connection Management
    
    /// Check if the backend service is available
    var isConnected: Bool { get }
    
    /// Publisher for connection status changes
    var connectionStatusPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Attempt to reconnect to the backend service
    func reconnect() -> AnyPublisher<Bool, ChatError>
}

// MARK: - Autocompletion Service Protocol

/// Protocol for autocompletion suggestion services
/// This protocol must be implemented by services providing smart tagging suggestions
public protocol AutocompletionServiceProtocol {
    
    /// Fetch autocompletion suggestions based on user query
    /// - Parameters:
    ///   - query: The search query (text after '@' symbol)
    ///   - type: The type of suggestions to fetch
    /// - Returns: Array of suggestions matching the query
    func fetchAutocompleteSuggestions(
        query: String,
        type: AutocompleteSuggestion.AutocompleteType
    ) async throws -> [AutocompleteSuggestion]
    
    /// Fetch all available autocompletion suggestions of a specific type
    /// - Parameter type: The type of suggestions to fetch
    /// - Returns: Array of all available suggestions of the specified type
    func fetchAllSuggestions(
        type: AutocompleteSuggestion.AutocompleteType
    ) async throws -> [AutocompleteSuggestion]
    
    /// Check if the autocompletion service is available
    var isServiceAvailable: Bool { get }
}

// MARK: - Supporting Types

/// Response structure from chatbot backend
public struct ChatResponse {
    public let content: String
    public let isComplete: Bool
    public let isStreaming: Bool
    public let metadata: [String: Any]?
    
    public init(
        content: String,
        isComplete: Bool = true,
        isStreaming: Bool = false,
        metadata: [String: Any]? = nil
    ) {
        self.content = content
        self.isComplete = isComplete
        self.isStreaming = isStreaming
        self.metadata = metadata
    }
}

// MARK: - Backend Service Registry

/// Registry for managing backend service instances
/// This allows the UI to work with different backend implementations
public class ChatbotServiceRegistry {
    
    public static let shared = ChatbotServiceRegistry()
    
    private var chatbotBackend: ChatbotBackendProtocol?
    private var autocompletionService: AutocompletionServiceProtocol?
    
    private init() {}
    
    // MARK: - Service Registration
    
    /// Register the chatbot backend service
    /// - Parameter backend: The backend service implementation
    public func register(chatbotBackend: ChatbotBackendProtocol) {
        self.chatbotBackend = chatbotBackend
    }
    
    /// Register the autocompletion service
    /// - Parameter service: The autocompletion service implementation
    public func register(autocompletionService: AutocompletionServiceProtocol) {
        self.autocompletionService = autocompletionService
    }
    
    // MARK: - Service Access
    
    /// Get the registered chatbot backend
    /// - Returns: The chatbot backend or nil if not registered
    public func getChatbotBackend() -> ChatbotBackendProtocol? {
        return chatbotBackend
    }
    
    /// Get the registered autocompletion service
    /// - Returns: The autocompletion service or nil if not registered
    public func getAutocompletionService() -> AutocompletionServiceProtocol? {
        return autocompletionService
    }
    
    // MARK: - Service Status
    
    /// Check if all required services are registered and available
    public var areServicesReady: Bool {
        return chatbotBackend?.isConnected == true && 
               autocompletionService?.isServiceAvailable == true
    }
}

// MARK: - Integration Guidelines

/**
 INTEGRATION INSTRUCTIONS FOR BACKEND DEVELOPERS:
 
 1. Implement ChatbotBackendProtocol in your backend service:
    ```swift
    class YourChatbotBackend: ChatbotBackendProtocol {
        func sendUserMessage(text: String) -> AnyPublisher<ChatResponse, ChatError> {
            // Your implementation here
        }
        
        var chatbotResponsePublisher: AnyPublisher<ChatMessage, Never> {
            // Your implementation here
        }
        
        // ... implement other required methods
    }
    ```
 
 2. Implement AutocompletionServiceProtocol for smart tagging:
    ```swift
    class YourAutocompletionService: AutocompletionServiceProtocol {
        func fetchAutocompleteSuggestions(query: String, type: AutocompleteSuggestion.AutocompleteType) async throws -> [AutocompleteSuggestion] {
            // Your implementation here
        }
        
        // ... implement other required methods
    }
    ```
 
 3. Register your services with the registry:
    ```swift
    let chatbotBackend = YourChatbotBackend()
    let autocompletionService = YourAutocompletionService()
    
    ChatbotServiceRegistry.shared.register(chatbotBackend: chatbotBackend)
    ChatbotServiceRegistry.shared.register(autocompletionService: autocompletionService)
    ```
 
 4. The UI will automatically use your registered services through the protocols
 
 ERROR HANDLING:
 - Return appropriate ChatError cases for different failure scenarios
 - Ensure proper error messages that can be displayed to users
 - Handle network failures, timeout scenarios, and service unavailability
 
 STREAMING SUPPORT:
 - For streaming responses, emit partial ChatMessage objects with streaming state
 - Set isComplete: false for partial responses, true for final response
 - Support stopCurrentGeneration() to cancel ongoing streams
 
 AUTOCOMPLETION PERFORMANCE:
 - Implement efficient caching for frequently accessed suggestions
 - Consider debouncing rapid query changes
 - Return results quickly (< 500ms) for good user experience
 */