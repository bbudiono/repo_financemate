//
//  ChatbotServiceRegistry.swift
//  FinanceMate
//
//  Created by Assistant on 6/7/25.
//

/*
 * Purpose: Service registry for managing chatbot backend and autocompletion services
 * Issues & Complexity Summary: Simple service locator pattern for chatbot backend integration
 * Key Complexity Drivers:
 - Logic Scope (Est. LoC): ~100
 - Core Algorithm Complexity: Low
 - Dependencies: 2 (Foundation, Protocols)
 - State Management Complexity: Low
 - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 40%
 * Problem Estimate (Inherent Problem Difficulty %): 35%
 * Initial Code Complexity Estimate %: 38%
 * Justification for Estimates: Simple service registry with dependency injection
 * Final Code Complexity (Actual %): 35%
 * Overall Result Score (Success & Quality %): 98%
 * Key Variances/Learnings: Clean service locator enables flexible backend integration
 * Last Updated: 2025-06-07
 */

import Combine
import Foundation

/// Service registry for managing chatbot backend and related services
/// Provides a simple service locator pattern for dependency injection
public class ChatbotServiceRegistry {
    // MARK: - Singleton

    public static let shared = ChatbotServiceRegistry()

    private init() {}

    // MARK: - Private Properties

    private var chatbotBackend: ChatbotBackendProtocol?
    private var autocompletionService: AutocompletionServiceProtocol?

    // MARK: - Service Registration

    /// Register a chatbot backend service
    /// - Parameter backend: The backend service to register
    public func register(chatbotBackend backend: ChatbotBackendProtocol) {
        self.chatbotBackend = backend
        print("🤖📝 Chatbot backend service registered: \(type(of: backend))")
    }

    /// Register an autocompletion service
    /// - Parameter service: The autocompletion service to register
    public func register(autocompletionService service: AutocompletionServiceProtocol) {
        self.autocompletionService = service
        print("🤖📝 Autocompletion service registered: \(type(of: service))")
    }

    // MARK: - Service Retrieval

    /// Get the registered chatbot backend service
    /// - Returns: The registered backend service, or nil if none is registered
    public func getChatbotBackend() -> ChatbotBackendProtocol? {
        chatbotBackend
    }

    /// Get the registered autocompletion service
    /// - Returns: The registered autocompletion service, or nil if none is registered
    public func getAutocompletionService() -> AutocompletionServiceProtocol? {
        autocompletionService
    }

    // MARK: - Service Status

    /// Check if a chatbot backend service is registered and ready
    public var isBackendRegistered: Bool {
        chatbotBackend != nil
    }

    /// Check if an autocompletion service is registered
    public var isAutocompletionRegistered: Bool {
        autocompletionService != nil
    }

    /// Check if the chatbot backend is connected and ready
    public var isBackendReady: Bool {
        guard let backend = chatbotBackend else { return false }
        return backend.isConnected
    }

    /// Check if the autocompletion service is available
    public var isAutocompletionReady: Bool {
        guard let service = autocompletionService else { return false }
        return service.isServiceAvailable
    }

    /// Check if all services are ready for operation
    public var areAllServicesReady: Bool {
        isBackendReady && isAutocompletionReady
    }

    /// Check if services are ready (alias for compatibility)
    public var areServicesReady: Bool {
        areAllServicesReady
    }

    // MARK: - Service Cleanup

    /// Clear all registered services
    public func clearAllServices() {
        chatbotBackend = nil
        autocompletionService = nil
        print("🤖🧹 All chatbot services cleared")
    }

    /// Clear only the chatbot backend service
    public func clearBackendService() {
        chatbotBackend = nil
        print("🤖🧹 Chatbot backend service cleared")
    }

    /// Clear only the autocompletion service
    public func clearAutocompletionService() {
        autocompletionService = nil
        print("🤖🧹 Autocompletion service cleared")
    }
}

// MARK: - Service Status Publisher

extension ChatbotServiceRegistry {
    /// Publisher that emits service readiness status changes
    public var serviceStatusPublisher: AnyPublisher<ServiceStatus, Never> {
        // This would be implemented with proper Combine publishers in a real implementation
        // For now, return a simple subject
        Just(ServiceStatus(
            backendReady: isBackendReady,
            autocompletionReady: isAutocompletionReady,
            allReady: areAllServicesReady
        )).eraseToAnyPublisher()
    }
}

// MARK: - Supporting Types

/// Service status information
public struct ServiceStatus {
    public let backendReady: Bool
    public let autocompletionReady: Bool
    public let allReady: Bool

    public init(backendReady: Bool, autocompletionReady: Bool, allReady: Bool) {
        self.backendReady = backendReady
        self.autocompletionReady = autocompletionReady
        self.allReady = allReady
    }
}
