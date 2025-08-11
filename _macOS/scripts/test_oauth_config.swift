#!/usr/bin/env swift

/**
 * test_oauth_config.swift
 * 
 * Quick test script to validate OAuth configuration status
 * Run: swift test_oauth_config.swift
 */

import Foundation

// Note: In real app, this would be imported from ProductionConfig
struct TestProductionAPIConfig {
    // Current placeholder values (need to be replaced with real credentials)
    static let gmailClientId = "your-gmail-client-id.apps.googleusercontent.com"
    static let outlookClientId = "your-outlook-client-id"
    
    // Validation functions
    static func validateProvider(_ provider: String) -> Bool {
        switch provider.lowercased() {
        case "gmail":
            return !gmailClientId.contains("your-") && 
                   gmailClientId.contains(".apps.googleusercontent.com")
        case "outlook":
            return !outlookClientId.contains("your-") && 
                   outlookClientId.count > 30
        default:
            return false
        }
    }
    
    static var configuredProviders: [String] {
        var providers: [String] = []
        if validateProvider("gmail") { providers.append("Gmail") }
        if validateProvider("outlook") { providers.append("Outlook") }
        return providers
    }
    
    static var pendingProviders: [String] {
        var pending: [String] = []
        if !validateProvider("gmail") { pending.append("Gmail (Google Cloud Console)") }
        if !validateProvider("outlook") { pending.append("Outlook (Microsoft Azure)") }
        return pending
    }
    
    static var configurationSummary: String {
        let configured = configuredProviders
        let pending = pendingProviders
        
        var summary = """
        FinanceMate OAuth Configuration Status:
        
        ✅ Configured Services (\(configured.count)):
        """
        
        if configured.isEmpty {
            summary += "\n   (None configured - placeholder values detected)"
        } else {
            for service in configured {
                summary += "\n   • \(service)"
            }
        }
        
        summary += "\n\n⏳ Pending Configuration (\(pending.count)):"
        
        if pending.isEmpty {
            summary += "\n   (All OAuth providers configured!)"
        } else {
            for service in pending {
                summary += "\n   • \(service)"
            }
        }
        
        summary += "\n"
        
        return summary
    }
}

// Run the test
print("🔧 FinanceMate OAuth Configuration Test")
print("=====================================")
print("")
print(TestProductionAPIConfig.configurationSummary)

if TestProductionAPIConfig.configuredProviders.isEmpty {
    print("🚨 ACTION REQUIRED:")
    print("   Follow the setup guide in docs/PRODUCTION_OAUTH_SETUP_GUIDE.md")
    print("   to configure production OAuth credentials.")
    print("")
    print("🎯 Expected after setup:")
    print("   ✅ Gmail OAuth: Functional")
    print("   ✅ Outlook OAuth: Functional")  
    print("   ✅ Email receipt processing: Ready")
} else {
    print("🎉 OAuth configuration is ready for production!")
    print("   Email receipt processing can now authenticate users.")
}

print("")
print("📖 Next steps: See docs/OAUTH_IMPLEMENTATION_COMPLETE.md")