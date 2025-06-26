// ChatModels.swift
// Shared types for chat functionality
// Part of systematic production readiness fixes for FinanceMate

import Combine
import Foundation

// MARK: - Chat Models
public struct ChatMessage: Identifiable {
    public let id = UUID()
    public let text: String
    public let isFromUser: Bool
    public let timestamp: Date

    public init(text: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}

public struct ChatResponse {
    public let message: String
    public let confidence: Double
    public let timestamp: Date

    public init(message: String, confidence: Double = 1.0, timestamp: Date = Date()) {
        self.message = message
        self.confidence = confidence
        self.timestamp = timestamp
    }
}

// MARK: - Chat Errors
public enum ChatError: Error, LocalizedError {
    case networkError(String)
    case apiKeyMissing
    case invalidResponse
    case rateLimited
    case serverError(Int)
    case backendUnavailable
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiKeyMissing:
            return "API key is missing or invalid"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimited:
            return "Rate limit exceeded"
        case .serverError(let code):
            return "Server error: \(code)"
        case .backendUnavailable:
            return "Backend service is currently unavailable"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Chat Protocol
public protocol ChatbotBackendProtocol: ObservableObject {
    var isConnected: Bool { get }
    var chatbotResponsePublisher: AnyPublisher<ChatMessage, Never> { get }

    func sendUserMessage(text: String) -> AnyPublisher<ChatResponse, ChatError>
    func disconnect()
    func reconnect() -> AnyPublisher<Bool, ChatError>
}
