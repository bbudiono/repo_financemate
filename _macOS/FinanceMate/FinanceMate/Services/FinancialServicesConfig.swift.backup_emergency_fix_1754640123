//
//  FinancialServicesConfig.swift
//  FinanceMate
//
//  Created by Bernhard Budiono on 8/6/25.
//

import Foundation

/// Configuration management for financial services
/// Handles environment-specific settings and secure credential storage
struct FinancialServicesConfig {
    
    // MARK: - Environment Detection
    
    static var currentEnvironment: FinancialServiceEnvironment {
        #if DEBUG
        return .sandbox
        #else
        return .production
        #endif
    }
    
    // MARK: - Basiq Configuration
    
    static var basiqAPIKey: String {
        // Use environment variable for local development
        // Use Keychain for production deployment
        #if DEBUG
        if let envKey = ProcessInfo.processInfo.environment["BASIQ_API_KEY_SANDBOX"] {
            return envKey
        }
        // Fallback to Keychain even in debug if env var not set
        return KeychainManager.shared.retrieve(key: "BASIQ_API_KEY_SANDBOX") ?? ""
        #else
        return KeychainManager.shared.retrieve(key: "BASIQ_API_KEY_PROD") ?? ""
        #endif
    }
    
    static var basiqBaseURL: String {
        return currentEnvironment.baseURL
    }
    
    static var basiqVersion: String {
        return "2.0" // Basiq API version
    }
    
    // MARK: - NAB Configuration (Future)
    
    static var nabAPIKey: String {
        #if DEBUG
        if let envKey = ProcessInfo.processInfo.environment["NAB_API_KEY_SANDBOX"] {
            return envKey
        }
        return KeychainManager.shared.retrieve(key: "NAB_API_KEY_SANDBOX") ?? ""
        #else
        return KeychainManager.shared.retrieve(key: "NAB_API_KEY_PROD") ?? ""
        #endif
    }
    
    // MARK: - Network Configuration
    
    static var requestTimeout: TimeInterval {
        return 30.0 // 30 seconds
    }
    
    static var maxRetries: Int {
        return 3
    }
    
    static var retryDelay: TimeInterval {
        return 2.0 // Base delay for exponential backoff
    }
    
    // MARK: - Data Sync Configuration
    
    static var syncInterval: TimeInterval {
        return 300.0 // 5 minutes
    }
    
    static var transactionHistoryDays: Int {
        return 90 // Fetch 90 days of transaction history by default
    }
    
    static var maxTransactionsPerRequest: Int {
        return 500 // Maximum transactions to fetch per API call
    }
    
    // MARK: - Security Configuration
    
    static var usesPinning: Bool {
        #if DEBUG
        return false // Disable certificate pinning in debug for easier testing
        #else
        return true // Enable certificate pinning in production
        #endif
    }
    
    static var encryptLocalCache: Bool {
        return true // Always encrypt cached financial data
    }
    
    // MARK: - Validation
    
    static func validateConfiguration() -> Bool {
        // Ensure required API keys are present
        if basiqAPIKey.isEmpty {
            print("⚠️ Warning: Basiq API key not configured")
            return false
        }
        
        // Validate URL format
        guard let url = URL(string: basiqBaseURL) else {
            print("⚠️ Warning: Invalid Basiq base URL")
            return false
        }
        
        // Check for HTTPS in production
        if currentEnvironment == .production && url.scheme != "https" {
            print("⚠️ Warning: Production API must use HTTPS")
            return false
        }
        
        return true
    }
    
    // MARK: - User Defaults Keys
    
    struct UserDefaultsKeys {
        static let lastSyncDate = "FinancialServices.lastSyncDate"
        static let selectedInstitution = "FinancialServices.selectedInstitution"
        static let syncEnabled = "FinancialServices.syncEnabled"
        static let notificationsEnabled = "FinancialServices.notificationsEnabled"
    }
}

// MARK: - Keychain Manager Extension

extension KeychainManager {
    /// Store Basiq API credentials securely
    func storeBasiqCredentials(apiKey: String, environment: FinancialServiceEnvironment) {
        let key = environment == .sandbox ? "BASIQ_API_KEY_SANDBOX" : "BASIQ_API_KEY_PROD"
        store(key: key, value: apiKey)
    }
    
    /// Retrieve Basiq API credentials
    func retrieveBasiqCredentials(for environment: FinancialServiceEnvironment) -> String? {
        let key = environment == .sandbox ? "BASIQ_API_KEY_SANDBOX" : "BASIQ_API_KEY_PROD"
        return retrieve(key: key)
    }
    
    /// Clear all financial service credentials
    func clearFinancialCredentials() {
        delete(key: "BASIQ_API_KEY_SANDBOX")
        delete(key: "BASIQ_API_KEY_PROD")
        delete(key: "NAB_API_KEY_SANDBOX")
        delete(key: "NAB_API_KEY_PROD")
    }
}