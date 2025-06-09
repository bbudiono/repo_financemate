//
//  SettingsManager.swift
//  FinanceMate
//
//  Created by Assistant on 6/10/25.
//

import SwiftUI
import Foundation
import Combine

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
        return [
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
}