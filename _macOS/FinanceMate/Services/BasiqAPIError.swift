//
//  BasiqAPIError.swift
//  FinanceMate
//
//  Created by FinanceMate on 2025-10-15.
//  Copyright © 2025 FinanceMate. All rights reserved.
//

import Foundation

/// Basiq API error types for comprehensive error handling
enum BasiqAPIError: LocalizedError {
    case missingCredentials
    case notAuthenticated
    case invalidResponse
    case invalidURL
    case authenticationFailed(String)
    case connectionFailed(String)
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Basiq API credentials are not configured"
        case .notAuthenticated:
            return "Not authenticated with Basiq API"
        case .invalidResponse:
            return "Invalid response from Basiq API"
        case .invalidURL:
            return "Invalid URL format"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        }
    }
}