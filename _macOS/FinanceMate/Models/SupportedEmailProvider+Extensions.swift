import SwiftUI

/**
 * SupportedEmailProvider+Extensions.swift
 * 
 * Purpose: PHASE 3.3 - Modular email provider extensions (extracted from ProviderSelectionView)
 * Issues & Complexity Summary: Email provider display properties and configuration extensions
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~90 (focused provider property extensions)
 *   - Core Algorithm Complexity: Low (property computation and static data)
 *   - Dependencies: 2 (SwiftUI Color, SupportedEmailProvider enum)
 *   - State Management Complexity: None (static computed properties)
 *   - Novelty/Uncertainty Factor: Low (established extension patterns)
 * AI Pre-Task Self-Assessment: 98%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 72%
 * Target Coverage: Provider property extension testing
 * Australian Compliance: Provider security level display standards
 * Last Updated: 2025-08-08
 */

/// Extension providing display properties and configuration for email providers
/// Extracted from ProviderSelectionView to maintain <200 line rule
extension SupportedEmailProvider {
    
    // MARK: - Display Properties
    
    var iconName: String {
        switch self {
        case .gmail: return "envelope.badge"
        case .outlook: return "envelope.circle"
        case .icloud: return "icloud"
        }
    }
    
    var brandColor: Color {
        switch self {
        case .gmail: return .red
        case .outlook: return .blue
        case .icloud: return .cyan
        }
    }
    
    var securityLevel: String {
        switch self {
        case .gmail: return "OAuth 2.0"
        case .outlook: return "OAuth 2.0"
        case .icloud: return "App Password"
        }
    }
    
    var description: String {
        switch self {
        case .gmail: return "Google Gmail accounts with OAuth authentication"
        case .outlook: return "Microsoft Outlook/Hotmail accounts"
        case .icloud: return "Apple iCloud Mail accounts"
        }
    }
    
    // MARK: - Help Content
    
    var helpText: String {
        switch self {
        case .gmail:
            return "Gmail integration uses OAuth 2.0 for secure authentication. You'll be redirected to Google's authentication page to grant permission for email access."
        case .outlook:
            return "Outlook integration supports Microsoft personal and work accounts. Authentication is handled through Microsoft's secure OAuth flow."
        case .icloud:
            return "iCloud Mail requires an app-specific password. You can generate this in your Apple ID settings under Security > App-Specific Passwords."
        }
    }
    
    var setupInstructions: [String] {
        switch self {
        case .gmail:
            return [
                "Click 'Connect to Gmail' and sign in to your Google account",
                "Grant FinanceMate permission to read your emails",
                "Your credentials are stored securely in Keychain"
            ]
        case .outlook:
            return [
                "Click 'Connect to Outlook' and sign in to your Microsoft account",
                "Approve the email access request",
                "Both personal and work accounts are supported"
            ]
        case .icloud:
            return [
                "Go to appleid.apple.com and sign in",
                "Navigate to Security > App-Specific Passwords",
                "Generate a new password for 'FinanceMate'",
                "Enter your Apple ID and the generated password"
            ]
        }
    }
    
    // MARK: - Configuration Properties
    
    var displayName: String {
        switch self {
        case .gmail: return "Gmail"
        case .outlook: return "Outlook"
        case .icloud: return "iCloud Mail"
        }
    }
    
    var requiresOAuth: Bool {
        switch self {
        case .gmail, .outlook: return true
        case .icloud: return false
        }
    }
    
    var supportsBatchProcessing: Bool {
        switch self {
        case .gmail, .outlook: return true
        case .icloud: return false
        }
    }
    
    var maxEmailsPerBatch: Int {
        switch self {
        case .gmail: return 100
        case .outlook: return 50
        case .icloud: return 25
        }
    }
}