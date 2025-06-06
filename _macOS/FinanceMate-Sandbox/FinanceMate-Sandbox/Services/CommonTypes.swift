// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  CommonTypes.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/5/25.
//

/*
* Purpose: Shared type definitions to prevent duplicate enum conflicts
* Issues & Complexity Summary: Central type definitions for LLM providers and authentication
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Low
  - Dependencies: 0 New (Foundation types only)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 30%
* Problem Estimate (Inherent Problem Difficulty %): 25%
* Initial Code Complexity Estimate %: 28%
* Justification for Estimates: Simple enum definitions with string mappings
* Final Code Complexity (Actual %): 28%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Centralized type definitions prevent compilation conflicts
* Last Updated: 2025-06-05
*/

import Foundation

// MARK: - LLM Provider Types

/// Shared LLM Provider enumeration used across all services
public enum LLMProvider: String, CaseIterable, Codable {
    case openai = "openai"
    case anthropic = "anthropic"
    case googleai = "googleai"
    
    public var displayName: String {
        switch self {
        case .openai: return "OpenAI"
        case .anthropic: return "Anthropic"
        case .googleai: return "Google AI"
        }
    }
    
    public var apiKeyEnvironmentVariable: String {
        switch self {
        case .openai: return "OPENAI_API_KEY"
        case .anthropic: return "ANTHROPIC_API_KEY"
        case .googleai: return "GOOGLE_AI_API_KEY"
        }
    }
}

// MARK: - Authentication Types

public enum AuthenticationProvider: String, CaseIterable, Codable {
    case apple = "apple"
    case google = "google"
    case microsoft = "microsoft"
    
    public var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        case .microsoft: return "Microsoft"
        }
    }
}

public enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated
    case failed(String)
    
    public static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthenticated, .unauthenticated),
             (.authenticating, .authenticating),
             (.authenticated, .authenticated):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

// MARK: - API Response Types

public struct APIResponse<T: Codable>: Codable {
    public let data: T?
    public let error: String?
    public let timestamp: Date
    
    public init(data: T? = nil, error: String? = nil) {
        self.data = data
        self.error = error
        self.timestamp = Date()
    }
}

public struct LLMAuthenticationResult {
    public let provider: LLMProvider
    public let isValid: Bool
    public let error: String?
    public let responseTime: TimeInterval?
    public let success: Bool
    public let userInfo: [String: Any]?
    public let fallbackUsed: String?
    
    public init(provider: LLMProvider, isValid: Bool, error: String? = nil, responseTime: TimeInterval? = nil) {
        self.provider = provider
        self.isValid = isValid
        self.error = error
        self.responseTime = responseTime
        self.success = isValid
        self.userInfo = nil
        self.fallbackUsed = nil
    }
    
    public init(provider: LLMProvider, success: Bool, userInfo: [String: Any]? = nil, error: String? = nil, responseTime: TimeInterval? = nil, fallbackUsed: String? = nil) {
        self.provider = provider
        self.isValid = success
        self.success = success
        self.userInfo = userInfo
        self.error = error
        self.responseTime = responseTime
        self.fallbackUsed = fallbackUsed
    }
}