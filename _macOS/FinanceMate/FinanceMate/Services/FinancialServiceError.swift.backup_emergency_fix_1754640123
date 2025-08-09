//
//  FinancialServiceError.swift
//  FinanceMate
//
//  Created by Bernhard Budiono on 8/6/25.
//

import Foundation

/// Comprehensive error handling for financial service operations
enum FinancialServiceError: LocalizedError {
    case connectionFailed(String)
    case authenticationRequired
    case invalidCredentials
    case sessionExpired
    case rateLimitExceeded(retryAfter: TimeInterval)
    case institutionUnavailable(String)
    case dataParsingError(String)
    case networkError(Error)
    case invalidAPIKey
    case accountNotFound(String)
    case transactionNotFound(String)
    case insufficientPermissions
    case serviceUnavailable
    case invalidRequest(String)
    case serverError(statusCode: Int, message: String?)
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            return "Failed to connect to financial institution: \(message)"
        case .authenticationRequired:
            return "Authentication required. Please log in to your financial institution."
        case .invalidCredentials:
            return "Invalid credentials provided. Please check your login details."
        case .sessionExpired:
            return "Your session has expired. Please reconnect to continue."
        case .rateLimitExceeded(let retryAfter):
            return "Rate limit exceeded. Please try again in \(Int(retryAfter)) seconds."
        case .institutionUnavailable(let name):
            return "\(name) is currently unavailable. Please try again later."
        case .dataParsingError(let message):
            return "Error processing financial data: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidAPIKey:
            return "Invalid API key. Please check your configuration."
        case .accountNotFound(let id):
            return "Account \(id) not found."
        case .transactionNotFound(let id):
            return "Transaction \(id) not found."
        case .insufficientPermissions:
            return "Insufficient permissions to access this data."
        case .serviceUnavailable:
            return "Financial service is temporarily unavailable."
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .serverError(let code, let message):
            if let message = message {
                return "Server error (\(code)): \(message)"
            }
            return "Server error occurred (code: \(code))"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .connectionFailed, .institutionUnavailable, .serviceUnavailable:
            return "Please check your internet connection and try again."
        case .authenticationRequired, .invalidCredentials, .sessionExpired:
            return "Please reconnect to your financial institution."
        case .rateLimitExceeded:
            return "Wait a moment before trying again."
        case .invalidAPIKey:
            return "Contact support to verify your API configuration."
        case .insufficientPermissions:
            return "Request additional permissions from your financial institution."
        default:
            return "Please try again or contact support if the issue persists."
        }
    }
    
    /// Determine if the error is recoverable with retry
    var isRetryable: Bool {
        switch self {
        case .rateLimitExceeded, .networkError, .serviceUnavailable, .institutionUnavailable:
            return true
        default:
            return false
        }
    }
    
    /// Get retry delay if applicable
    var retryDelay: TimeInterval? {
        switch self {
        case .rateLimitExceeded(let delay):
            return delay
        case .networkError, .serviceUnavailable:
            return 5.0 // Default 5 second retry
        case .institutionUnavailable:
            return 30.0 // Try again in 30 seconds
        default:
            return nil
        }
    }
}