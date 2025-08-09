import Foundation
import OSLog

/// User profile management for contextual help system
/// Focused responsibility: Manage user profiles and industry settings for personalized help
// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class HelpProfileManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var userProfile: UserProfile = .unknown
    @Published var userIndustry: UserIndustry = .other
    @Published var isAccessibilityModeEnabled: Bool = false
    @Published var isOfflineModeEnabled: Bool = false
    
    // MARK: - Private Properties
    
    private let logger = Logger(subsystem: "com.financemate.help", category: "HelpProfileManager")
    
    // MARK: - Initialization
    
    init() {
        logger.debug("HelpProfileManager initialized")
    }
    
    // MARK: - Profile Management
    
    /// Set user profile for personalized help
    func setUserProfile(_ profile: UserProfile) {
        self.userProfile = profile
        logger.info("User profile set to: \(profile.rawValue)")
    }
    
    /// Set user industry for specialized content
    func setUserIndustry(_ industry: UserIndustry) {
        self.userIndustry = industry
        logger.info("User industry set to: \(industry.rawValue)")
    }
    
    /// Enable accessibility features
    func enableAccessibilityMode(_ enabled: Bool) {
        self.isAccessibilityModeEnabled = enabled
        logger.info("Accessibility mode \(enabled ? "enabled" : "disabled")")
    }
    
    /// Set offline mode
    func setOfflineMode(_ enabled: Bool) {
        self.isOfflineModeEnabled = enabled
        logger.info("Offline mode \(enabled ? "enabled" : "disabled")")
    }
    
    /// Get current user profile
    func getCurrentProfile() -> UserProfile {
        return userProfile
    }
    
    /// Get current user industry
    func getCurrentIndustry() -> UserIndustry {
        return userIndustry
    }
    
    /// Check if accessibility mode is enabled
    func isAccessibilityEnabled() -> Bool {
        return isAccessibilityModeEnabled
    }
    
    /// Check if offline mode is enabled
    func isOfflineEnabled() -> Bool {
        return isOfflineModeEnabled
    }
    
    /// Get user expertise level for personalization
    func getRecommendedComplexity() -> HelpComplexity {
        switch userProfile {
        case .unknown:
            return .simplified
        case .personal:
            return .balanced
        case .business:
            return .advanced
        case .mixed:
            return .balanced
        }
    }
    
    /// Check if user needs business-specific help
    func needsBusinessContent() -> Bool {
        return userProfile == .business || userProfile == .mixed
    }
    
    /// Check if user needs personal finance help
    func needsPersonalContent() -> Bool {
        return userProfile == .personal || userProfile == .mixed || userProfile == .unknown
    }
    
    /// Check if user needs industry-specific guidance
    func needsIndustrySpecificContent() -> Bool {
        return userIndustry != .other
    }
    
    /// Get industry-specific content requirements
    func getIndustryRequirements() -> [String] {
        switch userIndustry {
        case .construction:
            return ["construction_tax_guidance", "trade_deductions", "equipment_depreciation"]
        case .technology:
            return ["r_and_d_tax_credits", "software_expenses", "intellectual_property"]
        case .retail:
            return ["inventory_management", "sales_tax", "cost_of_goods_sold"]
        case .healthcare:
            return ["medical_expenses", "practice_management", "equipment_deductions"]
        case .education:
            return ["education_expenses", "professional_development", "book_deductions"]
        case .finance:
            return ["investment_income", "financial_instruments", "regulatory_compliance"]
        case .other:
            return []
        }
    }
    
    /// Reset profile to default values
    func resetProfile() {
        userProfile = .unknown
        userIndustry = .other
        isAccessibilityModeEnabled = false
        isOfflineModeEnabled = false
        logger.info("User profile reset to defaults")
    }
    
    /// Validate profile settings
    func validateProfileSettings() -> Bool {
        // Basic validation - could be expanded with more complex rules
        return true
    }
    
    /// Export profile settings
    func exportProfileSettings() -> [String: Any] {
        return [
            "userProfile": userProfile.rawValue,
            "userIndustry": userIndustry.rawValue,
            "accessibilityMode": isAccessibilityModeEnabled,
            "offlineMode": isOfflineModeEnabled
        ]
    }
    
    /// Import profile settings
    func importProfileSettings(_ settings: [String: Any]) {
        if let profileString = settings["userProfile"] as? String,
           let profile = UserProfile(rawValue: profileString) {
            setUserProfile(profile)
        }
        
        if let industryString = settings["userIndustry"] as? String,
           let industry = UserIndustry(rawValue: industryString) {
            setUserIndustry(industry)
        }
        
        if let accessibilityMode = settings["accessibilityMode"] as? Bool {
            enableAccessibilityMode(accessibilityMode)
        }
        
        if let offlineMode = settings["offlineMode"] as? Bool {
            setOfflineMode(offlineMode)
        }
        
        logger.info("Profile settings imported successfully")
    }
}

// MARK: - User Profile Types

enum UserProfile: String, CaseIterable, Codable {
    case business = "business"
    case personal = "personal"
    case mixed = "mixed"
    case unknown = "unknown"
}

enum UserIndustry: String, CaseIterable, Codable {
    case construction = "construction"
    case technology = "technology"
    case retail = "retail"
    case healthcare = "healthcare"
    case education = "education"
    case finance = "finance"
    case other = "other"
}