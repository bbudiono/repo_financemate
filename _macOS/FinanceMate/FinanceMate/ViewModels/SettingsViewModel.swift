import Combine
import Foundation
import SwiftUI

/**
 * SettingsViewModel.swift
 *
 * Purpose: MVVM ViewModel for user settings and preferences management
 * Issues & Complexity Summary: Handles theme, currency, and notification preferences with UserDefaults persistence
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~120
 *   - Core Algorithm Complexity: Medium (UserDefaults integration)
 *   - Dependencies: 2 New (UserDefaults, Combine)
 *   - State Management Complexity: Medium (Multiple reactive properties)
 *   - Novelty/Uncertainty Factor: Low (Standard settings pattern)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: 78%
 * Overall Result Score: 85%
 * Key Variances/Learnings: UserDefaults integration simpler than expected
 * Last Updated: 2025-07-05
 */

// EMERGENCY FIX: Removed to eliminate Swift Concurrency crashes
// COMPREHENSIVE FIX: Removed ALL Swift Concurrency patterns to eliminate TaskLocal crashes
class SettingsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var theme: String {
        didSet {
            userDefaults.set(theme, forKey: "theme")
        }
    }

    @Published var currency: String {
        didSet {
            userDefaults.set(currency, forKey: "currency")
        }
    }

    @Published var notifications: Bool {
        didSet {
            userDefaults.set(notifications, forKey: "notifications")
        }
    }

    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let userDefaults: UserDefaults

    // MARK: - Constants

    private enum Defaults {
        static let theme = "System"
        static let currency = "AUD" // Australian Dollar default for Australian locale compliance
        static let notifications = true
    }

    private enum Keys {
        static let theme = "theme"
        static let currency = "currency"
        static let notifications = "notifications"
    }

    // MARK: - Available Options

    static let availableThemes = ["System", "Light", "Dark"]
    static let availableCurrencies = [
        "AUD",
        "USD",
        "EUR",
        "GBP",
        "JPY",
        "CAD",
    ] // AUD first for Australian locale compliance

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        // Load saved settings or use defaults
        theme = userDefaults.string(forKey: Keys.theme) ?? Defaults.theme
        currency = userDefaults.string(forKey: Keys.currency) ?? Defaults.currency

        // Handle bool default value properly
        if userDefaults.object(forKey: Keys.notifications) == nil {
            notifications = Defaults.notifications
            userDefaults.set(Defaults.notifications, forKey: Keys.notifications)
        } else {
            notifications = userDefaults.bool(forKey: Keys.notifications)
        }
    }

    // MARK: - Public Methods

    /// Reset all settings to default values
    func resetSettings() {
        theme = Defaults.theme
        currency = Defaults.currency
        notifications = Defaults.notifications
        clearError()
    }

    /// Clear any error state
    func clearError() {
        errorMessage = nil
    }

    /// Validate current settings
    func validateSettings() -> Bool {
        return Self.availableThemes.contains(theme) &&
            Self.availableCurrencies.contains(currency)
    }

    // MARK: - Helper Methods

    /// Get display name for current theme
    func themeDisplayName() -> String {
        switch theme {
        case "System":
            return "Follow System"
        case "Light":
            return "Light Mode"
        case "Dark":
            return "Dark Mode"
        default:
            return theme
        }
    }

    /// Get currency symbol for current currency
    func currencySymbol() -> String {
        switch currency {
        case "USD":
            return "$"
        case "EUR":
            return "€"
        case "GBP":
            return "£"
        case "JPY":
            return "¥"
        case "AUD":
            return "A$"
        case "CAD":
            return "C$"
        default:
            return currency
        }
    }

    /// Apply current theme to the environment
    func applyTheme() -> ColorScheme? {
        switch theme {
        case "Light":
            return .light
        case "Dark":
            return .dark
        default:
            return nil // System default
        }
    }

    /// Save all settings (explicit save method)
    func saveSettings() {
        userDefaults.set(theme, forKey: Keys.theme)
        userDefaults.set(currency, forKey: Keys.currency)
        userDefaults.set(notifications, forKey: Keys.notifications)
        userDefaults.synchronize()
    }

    /// Export settings as dictionary
    func exportSettings() -> [String: Any] {
        return [
            "theme": theme,
            "currency": currency,
            "notifications": notifications,
        ]
    }

    /// Import settings from dictionary
    func importSettings(from data: [String: Any]) {
        if let newTheme = data["theme"] as? String,
           Self.availableThemes.contains(newTheme)
        {
            theme = newTheme
        }

        if let newCurrency = data["currency"] as? String,
           Self.availableCurrencies.contains(newCurrency)
        {
            currency = newCurrency
        }

        if let newNotifications = data["notifications"] as? Bool {
            notifications = newNotifications
        }
    }
}
