//
//  SettingsManager.swift
//  FinanceMate
//
//  Created by Assistant on 6/10/25.
//

import Combine
import Foundation
import SwiftUI

// MARK: - SettingsAPIService enum
enum SettingsAPIService: String, CaseIterable {
    case openai = "openai"
    case google = "google"
    case anthropic = "anthropic"
    case perplexity = "perplexity"

    var displayName: String {
        switch self {
        case .openai: return "OpenAI"
        case .google: return "Google"
        case .anthropic: return "Anthropic"
        case .perplexity: return "Perplexity"
        }
    }

    var description: String {
        switch self {
        case .openai: return "GPT models for chat and completion"
        case .google: return "Gemini models for advanced reasoning"
        case .anthropic: return "Claude models for conversational AI"
        case .perplexity: return "Perplexity for web-based answers"
        }
    }

    var icon: String {
        switch self {
        case .openai: return "brain"
        case .google: return "magnifyingglass"
        case .anthropic: return "quote.bubble"
        case .perplexity: return "globe"
        }
    }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }

    @Published var autoSyncEnabled: Bool {
        didSet { UserDefaults.standard.set(autoSyncEnabled, forKey: "autoSyncEnabled") }
    }

    @Published var biometricAuthEnabled: Bool {
        didSet { UserDefaults.standard.set(biometricAuthEnabled, forKey: "biometricAuthEnabled") }
    }

    @Published var darkModeEnabled: Bool {
        didSet { UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled") }
    }

    @Published var defaultCurrency: String {
        didSet { UserDefaults.standard.set(defaultCurrency, forKey: "defaultCurrency") }
    }

    @Published var dateFormat: String {
        didSet { UserDefaults.standard.set(dateFormat, forKey: "dateFormat") }
    }

    @Published var autoBackupEnabled: Bool {
        didSet { UserDefaults.standard.set(autoBackupEnabled, forKey: "autoBackupEnabled") }
    }

    // Available options
    let availableCurrencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD"]
    let availableDateFormats = ["MM/dd/yyyy", "dd/MM/yyyy", "yyyy-MM-dd"]

    private init() {
        // Load settings from UserDefaults
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        self.autoSyncEnabled = UserDefaults.standard.object(forKey: "autoSyncEnabled") as? Bool ?? false
        self.biometricAuthEnabled = UserDefaults.standard.object(forKey: "biometricAuthEnabled") as? Bool ?? false
        self.darkModeEnabled = UserDefaults.standard.object(forKey: "darkModeEnabled") as? Bool ?? false
        self.defaultCurrency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
        self.dateFormat = UserDefaults.standard.string(forKey: "dateFormat") ?? "MM/dd/yyyy"
        self.autoBackupEnabled = UserDefaults.standard.object(forKey: "autoBackupEnabled") as? Bool ?? true
    }

    func resetAllSettings() {
        notificationsEnabled = true
        autoSyncEnabled = false
        biometricAuthEnabled = false
        darkModeEnabled = false
        defaultCurrency = "USD"
        dateFormat = "MM/dd/yyyy"
        autoBackupEnabled = true
    }

    @MainActor
    func resetAllData() async {
        // Reset settings
        resetAllSettings()

        // Clear UserDefaults for this app
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }

        // Reset any other app data as needed
        print("All user data has been reset")
    }

    func exportSettings() -> [String: Any] {
        [
            "notificationsEnabled": notificationsEnabled,
            "autoSyncEnabled": autoSyncEnabled,
            "biometricAuthEnabled": biometricAuthEnabled,
            "darkModeEnabled": darkModeEnabled,
            "defaultCurrency": defaultCurrency,
            "dateFormat": dateFormat,
            "autoBackupEnabled": autoBackupEnabled
        ]
    }

    func importSettings(from data: [String: Any]) {
        if let notifications = data["notificationsEnabled"] as? Bool {
            notificationsEnabled = notifications
        }
        if let autoSync = data["autoSyncEnabled"] as? Bool {
            autoSyncEnabled = autoSync
        }
        if let biometric = data["biometricAuthEnabled"] as? Bool {
            biometricAuthEnabled = biometric
        }
        if let darkMode = data["darkModeEnabled"] as? Bool {
            darkModeEnabled = darkMode
        }
        if let currency = data["defaultCurrency"] as? String {
            defaultCurrency = currency
        }
        if let format = data["dateFormat"] as? String {
            dateFormat = format
        }
        if let backup = data["autoBackupEnabled"] as? Bool {
            autoBackupEnabled = backup
        }
    }

    // MARK: - API Key Management

    @MainActor
    func saveAPIKey(_ key: String, for service: SettingsAPIService) {
        let keyName = "apiKey_\(service.rawValue)"
        do {
            try KeychainManager.shared.store(key: keyName, value: key)
            // Success notification could be added here
        } catch {
            print("Failed to save API key for \(service.displayName): \(error)")
            // Error handling could be added here
        }
    }

    @MainActor
    func getAPIKey(for service: SettingsAPIService) -> String? {
        let keyName = "apiKey_\(service.rawValue)"
        do {
            return try KeychainManager.shared.retrieve(key: keyName)
        } catch {
            print("Failed to retrieve API key for \(service.displayName): \(error)")
            return nil
        }
    }

    @MainActor
    func removeAPIKey(for service: SettingsAPIService) {
        let keyName = "apiKey_\(service.rawValue)"
        do {
            try KeychainManager.shared.delete(key: keyName)
        } catch {
            print("Failed to remove API key for \(service.displayName): \(error)")
        }
    }
}
