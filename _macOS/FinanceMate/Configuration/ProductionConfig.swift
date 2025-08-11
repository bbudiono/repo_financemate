import Foundation

/**
 * ProductionConfig.swift
 * 
 * Purpose: Secure production API configuration management
 * Issues & Complexity Summary: API credential management, environment configuration
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~100 (Configuration management + validation)
 *   - Core Algorithm Complexity: Low (Configuration getters + validation)
 *   - Dependencies: 1 New (Foundation framework)
 *   - State Management Complexity: Low (Static configuration values)
 *   - Novelty/Uncertainty Factor: Low (Standard configuration pattern)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 98%
 * Initial Code Complexity Estimate: 85%
 * Target Coverage: Production API credential configuration
 * Security Compliance: No hardcoded secrets, placeholder validation
 * Last Updated: 2025-08-10
 */

/// Production API configuration for OAuth 2.0 providers and external services
struct ProductionAPIConfig {
    
    // MARK: - Gmail Configuration
    
    /// Gmail OAuth 2.0 Client ID
    /// Replace with actual production client ID from Google Cloud Console
    /// Format: "your-client-id.apps.googleusercontent.com"
    static let gmailClientId = "your-gmail-client-id.apps.googleusercontent.com"
    
    /// Gmail API scope for reading email messages
    static let gmailScope = "https://www.googleapis.com/auth/gmail.readonly"
    
    /// Gmail OAuth 2.0 configuration URLs
    static let gmailAuthURL = "https://accounts.google.com/o/oauth2/v2/auth"
    static let gmailTokenURL = "https://oauth2.googleapis.com/token"
    static let gmailRedirectURI = "financemate://oauth/gmail"
    
    // MARK: - Microsoft Outlook Configuration
    
    /// Microsoft Azure App Registration Client ID
    /// Replace with actual production client ID from Azure Portal
    /// Format: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    static let outlookClientId = "your-outlook-client-id"
    
    /// Microsoft Graph API scope for reading mail
    static let outlookScope = "https://graph.microsoft.com/mail.read"
    
    /// Microsoft OAuth 2.0 configuration URLs
    static let outlookAuthURL = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize"
    static let outlookTokenURL = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
    static let outlookRedirectURI = "financemate://oauth/outlook"
    
    // MARK: - AI Chatbot Configuration
    
    /// Claude API configuration (for future AI chatbot enhancement)
    /// Replace with actual Anthropic API configuration
    static let claudeAPIKey = "your-claude-api-key"
    static let claudeBaseURL = "https://api.anthropic.com"
    
    /// OpenAI API configuration (fallback option)
    /// Replace with actual OpenAI API configuration
    static let openAIAPIKey = "your-openai-api-key"
    static let openAIBaseURL = "https://api.openai.com"
    
    // MARK: - Basiq Bank API Configuration
    
    /// Basiq API configuration for Australian bank integration
    /// Replace with actual Basiq production API credentials
    static let basiqAPIKey = "your-basiq-api-key"
    static let basiqBaseURL = "https://au-api.basiq.io"
    static let basiqApplicationId = "your-basiq-application-id"
    
    // MARK: - Environment Configuration
    
    /// Current deployment environment
    enum Environment {
        case development
        case staging
        case production
        
        static let current: Environment = .development
    }
    
    // MARK: - Configuration Validation
    
    /// Validates that production API credentials have been configured
    /// Returns true if all credentials are properly configured (no placeholder values)
    static func validateConfiguration() -> Bool {
        let gmailValid = !gmailClientId.contains("your-") && 
                        gmailClientId.contains(".apps.googleusercontent.com")
        
        let outlookValid = !outlookClientId.contains("your-") && 
                          outlookClientId.count > 30 // UUID format check
        
        // For development, only require OAuth credentials
        if Environment.current == .development {
            return gmailValid || outlookValid // At least one provider configured
        }
        
        // For production, require all critical services
        let aiValid = !claudeAPIKey.contains("your-") || 
                     !openAIAPIKey.contains("your-")
        
        let bankingValid = !basiqAPIKey.contains("your-") && 
                          !basiqApplicationId.contains("your-")
        
        return gmailValid && outlookValid && (aiValid || bankingValid)
    }
    
    /// Validates specific API provider configuration
    static func validateProvider(_ provider: String) -> Bool {
        switch provider.lowercased() {
        case "gmail":
            return !gmailClientId.contains("your-") && 
                   gmailClientId.contains(".apps.googleusercontent.com")
        case "outlook":
            return !outlookClientId.contains("your-") && 
                   outlookClientId.count > 30
        case "claude":
            return !claudeAPIKey.contains("your-")
        case "openai":
            return !openAIAPIKey.contains("your-")
        case "basiq":
            return !basiqAPIKey.contains("your-") && 
                   !basiqApplicationId.contains("your-")
        default:
            return false
        }
    }
    
    /// Returns list of configured API providers
    static var configuredProviders: [String] {
        var providers: [String] = []
        
        if validateProvider("gmail") {
            providers.append("Gmail")
        }
        
        if validateProvider("outlook") {
            providers.append("Outlook")
        }
        
        if validateProvider("claude") {
            providers.append("Claude AI")
        }
        
        if validateProvider("openai") {
            providers.append("OpenAI")
        }
        
        if validateProvider("basiq") {
            providers.append("Basiq Banking")
        }
        
        return providers
    }
    
    /// Returns list of providers requiring configuration
    static var pendingProviders: [String] {
        var pending: [String] = []
        
        if !validateProvider("gmail") {
            pending.append("Gmail (Google Cloud Console)")
        }
        
        if !validateProvider("outlook") {
            pending.append("Outlook (Microsoft Azure)")
        }
        
        if Environment.current == .production {
            if !validateProvider("claude") && !validateProvider("openai") {
                pending.append("AI Service (Claude or OpenAI)")
            }
            
            if !validateProvider("basiq") {
                pending.append("Basiq Banking API")
            }
        }
        
        return pending
    }
    
    // MARK: - Development Helpers
    
    /// Configuration summary for development/debugging
    static var configurationSummary: String {
        let configured = configuredProviders
        let pending = pendingProviders
        
        var summary = """
        FinanceMate Production Configuration Status:
        Environment: \(Environment.current)
        
        ✅ Configured Services (\(configured.count)):
        """
        
        if configured.isEmpty {
            summary += "\n   (None configured)"
        } else {
            for service in configured {
                summary += "\n   • \(service)"
            }
        }
        
        summary += "\n\n⏳ Pending Configuration (\(pending.count)):"
        
        if pending.isEmpty {
            summary += "\n   (All required services configured)"
        } else {
            for service in pending {
                summary += "\n   • \(service)"
            }
        }
        
        return summary
    }
    
    /// Quick validation check for essential services
    static var isReadyForProduction: Bool {
        return Environment.current == .production ? 
               validateConfiguration() : 
               (validateProvider("gmail") || validateProvider("outlook"))
    }
}

// MARK: - Configuration Extensions

extension ProductionAPIConfig {
    
    /// OAuth provider configuration bundle
    struct OAuthProvider {
        let clientId: String
        let scope: String
        let authURL: String
        let tokenURL: String
        let redirectURI: String
    }
    
    /// Get OAuth configuration for provider
    static func oauthConfig(for provider: String) -> OAuthProvider? {
        switch provider.lowercased() {
        case "gmail":
            return OAuthProvider(
                clientId: gmailClientId,
                scope: gmailScope,
                authURL: gmailAuthURL,
                tokenURL: gmailTokenURL,
                redirectURI: gmailRedirectURI
            )
        case "outlook":
            return OAuthProvider(
                clientId: outlookClientId,
                scope: outlookScope,
                authURL: outlookAuthURL,
                tokenURL: outlookTokenURL,
                redirectURI: outlookRedirectURI
            )
        default:
            return nil
        }
    }
}