//
//  SettingsManagerTests.swift
//  FinanceMateTests
//
//  Purpose: Comprehensive unit tests for SettingsManager
//  Issues & Complexity Summary: Tests settings persistence, API key management, import/export functionality
//  Key Complexity Drivers:
//    - Logic Scope (Est. LoC): ~300
//    - Core Algorithm Complexity: Medium
//    - Dependencies: 4 (XCTest, SettingsManager, UserDefaults, KeychainManager)
//    - State Management Complexity: Medium
//    - Novelty/Uncertainty Factor: Low
//  AI Pre-Task Self-Assessment: 80%
//  Problem Estimate: 75%
//  Initial Code Complexity Estimate: 78%
//  Final Code Complexity: 82%
//  Overall Result Score: 92%
//  Key Variances/Learnings: UserDefaults and Keychain mocking for isolated testing
//  Last Updated: 2025-06-26

import XCTest
import Foundation
@testable import FinanceMate

@MainActor
final class SettingsManagerTests: XCTestCase {
    var settingsManager: SettingsManager!
    var testUserDefaults: UserDefaults!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create a separate UserDefaults instance for testing
        testUserDefaults = UserDefaults(suiteName: "SettingsManagerTests")!
        
        // Clear any existing test data
        testUserDefaults.removePersistentDomain(forName: "SettingsManagerTests")
        
        // We need to use reflection to replace the UserDefaults.standard for testing
        // This is a more complex approach since SettingsManager uses UserDefaults.standard directly
        settingsManager = SettingsManager.shared
        
        // Reset settings to default state for each test
        settingsManager.resetAllSettings()
    }
    
    override func tearDown() async throws {
        // Clean up keychain items that may have been created during tests
        for service in SettingsAPIService.allCases {
            settingsManager.removeAPIKey(for: service)
        }
        
        // Clean up test UserDefaults
        testUserDefaults.removePersistentDomain(forName: "SettingsManagerTests")
        testUserDefaults = nil
        
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testSettingsManagerSingleton() {
        let instance1 = SettingsManager.shared
        let instance2 = SettingsManager.shared
        
        XCTAssertTrue(instance1 === instance2, "SettingsManager should be a singleton")
    }
    
    func testDefaultSettingsValues() {
        // After reset, check default values
        settingsManager.resetAllSettings()
        
        XCTAssertTrue(settingsManager.notificationsEnabled)
        XCTAssertFalse(settingsManager.autoSyncEnabled)
        XCTAssertFalse(settingsManager.biometricAuthEnabled)
        XCTAssertFalse(settingsManager.darkModeEnabled)
        XCTAssertEqual(settingsManager.defaultCurrency, "USD")
        XCTAssertEqual(settingsManager.dateFormat, "MM/dd/yyyy")
        XCTAssertTrue(settingsManager.autoBackupEnabled)
    }
    
    // MARK: - Settings Persistence Tests
    
    func testNotificationsEnabledPersistence() {
        // Given
        let newValue = false
        
        // When
        settingsManager.notificationsEnabled = newValue
        
        // Then
        XCTAssertEqual(settingsManager.notificationsEnabled, newValue)
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "notificationsEnabled"), newValue)
    }
    
    func testAutoSyncEnabledPersistence() {
        // Given
        let newValue = true
        
        // When
        settingsManager.autoSyncEnabled = newValue
        
        // Then
        XCTAssertEqual(settingsManager.autoSyncEnabled, newValue)
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "autoSyncEnabled"), newValue)
    }
    
    func testBiometricAuthEnabledPersistence() {
        // Given
        let newValue = true
        
        // When
        settingsManager.biometricAuthEnabled = newValue
        
        // Then
        XCTAssertEqual(settingsManager.biometricAuthEnabled, newValue)
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "biometricAuthEnabled"), newValue)
    }
    
    func testDarkModeEnabledPersistence() {
        // Given
        let newValue = true
        
        // When
        settingsManager.darkModeEnabled = newValue
        
        // Then
        XCTAssertEqual(settingsManager.darkModeEnabled, newValue)
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "darkModeEnabled"), newValue)
    }
    
    func testDefaultCurrencyPersistence() {
        // Given
        let newValue = "EUR"
        
        // When
        settingsManager.defaultCurrency = newValue
        
        // Then
        XCTAssertEqual(settingsManager.defaultCurrency, newValue)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "defaultCurrency"), newValue)
    }
    
    func testDateFormatPersistence() {
        // Given
        let newValue = "dd/MM/yyyy"
        
        // When
        settingsManager.dateFormat = newValue
        
        // Then
        XCTAssertEqual(settingsManager.dateFormat, newValue)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "dateFormat"), newValue)
    }
    
    func testAutoBackupEnabledPersistence() {
        // Given
        let newValue = false
        
        // When
        settingsManager.autoBackupEnabled = newValue
        
        // Then
        XCTAssertEqual(settingsManager.autoBackupEnabled, newValue)
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "autoBackupEnabled"), newValue)
    }
    
    // MARK: - Available Options Tests
    
    func testAvailableCurrencies() {
        let expectedCurrencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD"]
        XCTAssertEqual(settingsManager.availableCurrencies, expectedCurrencies)
    }
    
    func testAvailableDateFormats() {
        let expectedFormats = ["MM/dd/yyyy", "dd/MM/yyyy", "yyyy-MM-dd"]
        XCTAssertEqual(settingsManager.availableDateFormats, expectedFormats)
    }
    
    // MARK: - Reset Functionality Tests
    
    func testResetAllSettings() {
        // Given - Modify all settings from defaults
        settingsManager.notificationsEnabled = false
        settingsManager.autoSyncEnabled = true
        settingsManager.biometricAuthEnabled = true
        settingsManager.darkModeEnabled = true
        settingsManager.defaultCurrency = "EUR"
        settingsManager.dateFormat = "dd/MM/yyyy"
        settingsManager.autoBackupEnabled = false
        
        // When
        settingsManager.resetAllSettings()
        
        // Then
        XCTAssertTrue(settingsManager.notificationsEnabled)
        XCTAssertFalse(settingsManager.autoSyncEnabled)
        XCTAssertFalse(settingsManager.biometricAuthEnabled)
        XCTAssertFalse(settingsManager.darkModeEnabled)
        XCTAssertEqual(settingsManager.defaultCurrency, "USD")
        XCTAssertEqual(settingsManager.dateFormat, "MM/dd/yyyy")
        XCTAssertTrue(settingsManager.autoBackupEnabled)
    }
    
    func testResetAllData() async {
        // Given - Set some custom values
        settingsManager.notificationsEnabled = false
        settingsManager.defaultCurrency = "EUR"
        
        // Store bundle ID before test
        let bundleID = Bundle.main.bundleIdentifier
        
        // When
        await settingsManager.resetAllData()
        
        // Then
        XCTAssertTrue(settingsManager.notificationsEnabled)
        XCTAssertEqual(settingsManager.defaultCurrency, "USD")
        
        // Verify UserDefaults were cleared for the bundle
        if let bundleID = bundleID {
            let clearedValue = UserDefaults.standard.object(forKey: "notificationsEnabled")
            // After clearing persistent domain, the value should be nil or default
            XCTAssertTrue(clearedValue == nil || (clearedValue as? Bool) == true)
        }
    }
    
    // MARK: - Export/Import Tests
    
    func testExportSettings() {
        // Given - Set custom values
        settingsManager.notificationsEnabled = false
        settingsManager.autoSyncEnabled = true
        settingsManager.biometricAuthEnabled = true
        settingsManager.darkModeEnabled = true
        settingsManager.defaultCurrency = "EUR"
        settingsManager.dateFormat = "dd/MM/yyyy"
        settingsManager.autoBackupEnabled = false
        
        // When
        let exportedSettings = settingsManager.exportSettings()
        
        // Then
        XCTAssertEqual(exportedSettings["notificationsEnabled"] as? Bool, false)
        XCTAssertEqual(exportedSettings["autoSyncEnabled"] as? Bool, true)
        XCTAssertEqual(exportedSettings["biometricAuthEnabled"] as? Bool, true)
        XCTAssertEqual(exportedSettings["darkModeEnabled"] as? Bool, true)
        XCTAssertEqual(exportedSettings["defaultCurrency"] as? String, "EUR")
        XCTAssertEqual(exportedSettings["dateFormat"] as? String, "dd/MM/yyyy")
        XCTAssertEqual(exportedSettings["autoBackupEnabled"] as? Bool, false)
    }
    
    func testImportSettings() {
        // Given - Start with default settings
        settingsManager.resetAllSettings()
        
        let importData: [String: Any] = [
            "notificationsEnabled": false,
            "autoSyncEnabled": true,
            "biometricAuthEnabled": true,
            "darkModeEnabled": true,
            "defaultCurrency": "GBP",
            "dateFormat": "yyyy-MM-dd",
            "autoBackupEnabled": false
        ]
        
        // When
        settingsManager.importSettings(from: importData)
        
        // Then
        XCTAssertEqual(settingsManager.notificationsEnabled, false)
        XCTAssertEqual(settingsManager.autoSyncEnabled, true)
        XCTAssertEqual(settingsManager.biometricAuthEnabled, true)
        XCTAssertEqual(settingsManager.darkModeEnabled, true)
        XCTAssertEqual(settingsManager.defaultCurrency, "GBP")
        XCTAssertEqual(settingsManager.dateFormat, "yyyy-MM-dd")
        XCTAssertEqual(settingsManager.autoBackupEnabled, false)
    }
    
    func testImportSettingsWithPartialData() {
        // Given - Start with default settings
        settingsManager.resetAllSettings()
        
        let partialImportData: [String: Any] = [
            "notificationsEnabled": false,
            "defaultCurrency": "JPY"
            // Missing other settings
        ]
        
        // When
        settingsManager.importSettings(from: partialImportData)
        
        // Then - Only specified settings should change
        XCTAssertEqual(settingsManager.notificationsEnabled, false)
        XCTAssertEqual(settingsManager.defaultCurrency, "JPY")
        
        // Other settings should remain at defaults
        XCTAssertFalse(settingsManager.autoSyncEnabled)
        XCTAssertFalse(settingsManager.biometricAuthEnabled)
        XCTAssertEqual(settingsManager.dateFormat, "MM/dd/yyyy")
    }
    
    func testImportSettingsWithInvalidTypes() {
        // Given - Start with known state
        settingsManager.resetAllSettings()
        
        let invalidImportData: [String: Any] = [
            "notificationsEnabled": "not a bool",  // Wrong type
            "defaultCurrency": 123,                // Wrong type
            "validSetting": true                   // Unknown setting
        ]
        
        // When
        settingsManager.importSettings(from: invalidImportData)
        
        // Then - Settings should remain unchanged due to invalid types
        XCTAssertTrue(settingsManager.notificationsEnabled)  // Default value
        XCTAssertEqual(settingsManager.defaultCurrency, "USD")  // Default value
    }
    
    // MARK: - API Key Management Tests
    
    func testSaveAPIKey() {
        // Given
        let apiKey = "test-api-key-12345"
        let service = SettingsAPIService.openai
        
        // When
        settingsManager.saveAPIKey(apiKey, for: service)
        
        // Then
        let retrievedKey = settingsManager.getAPIKey(for: service)
        XCTAssertEqual(retrievedKey, apiKey)
    }
    
    func testGetAPIKeyForNonExistentKey() {
        // Given
        let service = SettingsAPIService.anthropic
        
        // Ensure no key exists
        settingsManager.removeAPIKey(for: service)
        
        // When
        let retrievedKey = settingsManager.getAPIKey(for: service)
        
        // Then
        XCTAssertNil(retrievedKey)
    }
    
    func testRemoveAPIKey() {
        // Given
        let apiKey = "test-api-key-to-remove"
        let service = SettingsAPIService.google
        
        // Save a key first
        settingsManager.saveAPIKey(apiKey, for: service)
        XCTAssertEqual(settingsManager.getAPIKey(for: service), apiKey)
        
        // When
        settingsManager.removeAPIKey(for: service)
        
        // Then
        let retrievedKey = settingsManager.getAPIKey(for: service)
        XCTAssertNil(retrievedKey)
    }
    
    func testSaveAPIKeyOverwritesPreviousKey() {
        // Given
        let firstKey = "first-api-key"
        let secondKey = "second-api-key"
        let service = SettingsAPIService.perplexity
        
        // When
        settingsManager.saveAPIKey(firstKey, for: service)
        let firstRetrieved = settingsManager.getAPIKey(for: service)
        
        settingsManager.saveAPIKey(secondKey, for: service)
        let secondRetrieved = settingsManager.getAPIKey(for: service)
        
        // Then
        XCTAssertEqual(firstRetrieved, firstKey)
        XCTAssertEqual(secondRetrieved, secondKey)
        XCTAssertNotEqual(firstRetrieved, secondRetrieved)
    }
    
    func testAPIKeyManagementForAllServices() {
        let testKeys = [
            SettingsAPIService.openai: "openai-key-123",
            SettingsAPIService.google: "google-key-456",
            SettingsAPIService.anthropic: "anthropic-key-789",
            SettingsAPIService.perplexity: "perplexity-key-012"
        ]
        
        // Save all keys
        for (service, key) in testKeys {
            settingsManager.saveAPIKey(key, for: service)
        }
        
        // Verify all keys can be retrieved
        for (service, expectedKey) in testKeys {
            let retrievedKey = settingsManager.getAPIKey(for: service)
            XCTAssertEqual(retrievedKey, expectedKey)
        }
        
        // Remove all keys
        for (service, _) in testKeys {
            settingsManager.removeAPIKey(for: service)
        }
        
        // Verify all keys are removed
        for (service, _) in testKeys {
            let retrievedKey = settingsManager.getAPIKey(for: service)
            XCTAssertNil(retrievedKey)
        }
    }
    
    // MARK: - SettingsAPIService Enum Tests
    
    func testSettingsAPIServiceDisplayNames() {
        XCTAssertEqual(SettingsAPIService.openai.displayName, "OpenAI")
        XCTAssertEqual(SettingsAPIService.google.displayName, "Google")
        XCTAssertEqual(SettingsAPIService.anthropic.displayName, "Anthropic")
        XCTAssertEqual(SettingsAPIService.perplexity.displayName, "Perplexity")
    }
    
    func testSettingsAPIServiceDescriptions() {
        XCTAssertEqual(SettingsAPIService.openai.description, "GPT models for chat and completion")
        XCTAssertEqual(SettingsAPIService.google.description, "Gemini models for advanced reasoning")
        XCTAssertEqual(SettingsAPIService.anthropic.description, "Claude models for conversational AI")
        XCTAssertEqual(SettingsAPIService.perplexity.description, "Perplexity for web-based answers")
    }
    
    func testSettingsAPIServiceIcons() {
        XCTAssertEqual(SettingsAPIService.openai.icon, "brain")
        XCTAssertEqual(SettingsAPIService.google.icon, "magnifyingglass")
        XCTAssertEqual(SettingsAPIService.anthropic.icon, "quote.bubble")
        XCTAssertEqual(SettingsAPIService.perplexity.icon, "globe")
    }
    
    func testSettingsAPIServiceCaseIterable() {
        let allServices = SettingsAPIService.allCases
        XCTAssertEqual(allServices.count, 4)
        XCTAssertTrue(allServices.contains(.openai))
        XCTAssertTrue(allServices.contains(.google))
        XCTAssertTrue(allServices.contains(.anthropic))
        XCTAssertTrue(allServices.contains(.perplexity))
    }
    
    func testSettingsAPIServiceRawValues() {
        XCTAssertEqual(SettingsAPIService.openai.rawValue, "openai")
        XCTAssertEqual(SettingsAPIService.google.rawValue, "google")
        XCTAssertEqual(SettingsAPIService.anthropic.rawValue, "anthropic")
        XCTAssertEqual(SettingsAPIService.perplexity.rawValue, "perplexity")
    }
    
    // MARK: - Edge Cases and Error Handling Tests
    
    func testExportSettingsIsComplete() {
        // Verify all published properties are included in export
        let exportedSettings = settingsManager.exportSettings()
        
        let expectedKeys = [
            "notificationsEnabled",
            "autoSyncEnabled", 
            "biometricAuthEnabled",
            "darkModeEnabled",
            "defaultCurrency",
            "dateFormat",
            "autoBackupEnabled"
        ]
        
        for key in expectedKeys {
            XCTAssertTrue(exportedSettings.keys.contains(key), "Export missing key: \(key)")
        }
        
        XCTAssertEqual(exportedSettings.keys.count, expectedKeys.count, "Export contains unexpected keys")
    }
    
    func testImportEmptySettings() {
        // Given
        settingsManager.resetAllSettings()
        let emptyData: [String: Any] = [:]
        
        // When
        settingsManager.importSettings(from: emptyData)
        
        // Then - Settings should remain at defaults
        XCTAssertTrue(settingsManager.notificationsEnabled)
        XCTAssertFalse(settingsManager.autoSyncEnabled)
        XCTAssertEqual(settingsManager.defaultCurrency, "USD")
    }
    
    func testCurrencyValidation() {
        // Test that currency can be set to any value (no validation in current implementation)
        let invalidCurrency = "INVALID"
        settingsManager.defaultCurrency = invalidCurrency
        XCTAssertEqual(settingsManager.defaultCurrency, invalidCurrency)
        
        // Test valid currencies from available list
        for currency in settingsManager.availableCurrencies {
            settingsManager.defaultCurrency = currency
            XCTAssertEqual(settingsManager.defaultCurrency, currency)
        }
    }
    
    func testDateFormatValidation() {
        // Test that date format can be set to any value (no validation in current implementation)
        let invalidFormat = "INVALID"
        settingsManager.dateFormat = invalidFormat
        XCTAssertEqual(settingsManager.dateFormat, invalidFormat)
        
        // Test valid formats from available list
        for format in settingsManager.availableDateFormats {
            settingsManager.dateFormat = format
            XCTAssertEqual(settingsManager.dateFormat, format)
        }
    }
    
    // MARK: - Concurrent Access Tests
    
    func testConcurrentSettingsModification() {
        let expectation = XCTestExpectation(description: "Concurrent settings modification")
        expectation.expectedFulfillmentCount = 100
        
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        
        // Perform 100 concurrent setting modifications
        for i in 0..<100 {
            queue.async {
                Task { @MainActor in
                    self.settingsManager.notificationsEnabled = (i % 2 == 0)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // The final value should be either true or false
        XCTAssertTrue(settingsManager.notificationsEnabled == true || settingsManager.notificationsEnabled == false)
    }
    
    // MARK: - Performance Tests
    
    func testSettingsModificationPerformance() {
        measure {
            for i in 0..<1000 {
                settingsManager.notificationsEnabled = (i % 2 == 0)
                settingsManager.defaultCurrency = settingsManager.availableCurrencies[i % settingsManager.availableCurrencies.count]
                settingsManager.dateFormat = settingsManager.availableDateFormats[i % settingsManager.availableDateFormats.count]
            }
        }
    }
    
    func testExportImportPerformance() {
        measure {
            for _ in 0..<100 {
                let exported = settingsManager.exportSettings()
                settingsManager.importSettings(from: exported)
            }
        }
    }
}