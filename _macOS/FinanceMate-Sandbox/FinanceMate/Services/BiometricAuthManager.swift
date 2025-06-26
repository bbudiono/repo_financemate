//
//  BiometricAuthManager.swift
//  FinanceMate
//
//  Purpose: Biometric authentication using Touch ID/Face ID on macOS
//  Provides additional security layer for sensitive operations

import CryptoKit
import Foundation
import IOKit
import LocalAuthentication

@MainActor
public final class BiometricAuthManager: ObservableObject {
    public static let shared = BiometricAuthManager()

    @Published public var isBiometricAvailable = false
    @Published public var biometricType: LABiometryType = .none
    @Published public var isAuthenticated = false

    private let context = LAContext()
    private let keychainManager = KeychainManager.shared
    private let auditLogger = SecurityAuditLogger.shared

    private init() {
        checkBiometricAvailability()
    }

    // MARK: - Public Methods

    /// Check if biometric authentication is available
    public func checkBiometricAvailability() {
        var error: NSError?
        isBiometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        if isBiometricAvailable {
            biometricType = context.biometryType
        } else {
            biometricType = .none
            if let error = error {
                print("Biometric authentication not available: \(error.localizedDescription)")
            }
        }
    }

    /// Authenticate using biometrics
    public func authenticate(reason: String) async throws -> Bool {
        guard isBiometricAvailable else {
            throw BiometricError.notAvailable
        }

        // Set context properties
        context.localizedCancelTitle = "Cancel"
        context.localizedFallbackTitle = "Use Password"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            isAuthenticated = success

            if success {
                auditLogger.log(event: .biometricAuthSuccess)
            }

            return success
        } catch let error as LAError {
            let biometricError = mapLAError(error)
            auditLogger.log(event: .biometricAuthFailure(reason: biometricError.localizedDescription))
            throw biometricError
        } catch {
            auditLogger.log(event: .biometricAuthFailure(reason: error.localizedDescription))
            throw BiometricError.unknown(error)
        }
    }

    /// Authenticate for sensitive operations (e.g., viewing passwords)
    public func authenticateForSensitiveOperation(_ operation: String) async throws {
        let reason = "Authenticate to \(operation)"

        guard try await authenticate(reason: reason) else {
            throw BiometricError.authenticationFailed
        }

        // Additional verification - check session validity
        do {
            try await OAuth2Manager.shared.validateSession()
        } catch {
            throw BiometricError.sessionInvalid
        }
    }

    /// Enable biometric authentication for the app
    public func enableBiometricAuth() async throws {
        guard isBiometricAvailable else {
            throw BiometricError.notAvailable
        }

        // Authenticate first
        let reason = "Enable biometric authentication for FinanceMate"
        guard try await authenticate(reason: reason) else {
            throw BiometricError.authenticationFailed
        }

        // Store biometric preference
        try keychainManager.store(key: "biometric_enabled", value: "true", requiresBiometric: true)

        // Generate and store biometric-protected key
        let protectedKey = generateBiometricProtectedKey()
        try keychainManager.store(key: "biometric_key", value: protectedKey, requiresBiometric: true)
    }

    /// Disable biometric authentication
    public func disableBiometricAuth() async throws {
        // Verify user identity first
        let reason = "Disable biometric authentication"
        guard try await authenticate(reason: reason) else {
            throw BiometricError.authenticationFailed
        }

        // Remove biometric settings
        try keychainManager.delete(key: "biometric_enabled")
        try keychainManager.delete(key: "biometric_key")

        isAuthenticated = false
    }

    /// Check if biometric auth is enabled
    public func isBiometricAuthEnabled() -> Bool {
        do {
            let enabled = try keychainManager.retrieve(key: "biometric_enabled")
            return enabled == "true"
        } catch {
            return false
        }
    }

    /// Authenticate and retrieve protected data
    public func authenticateAndRetrieve(key: String, reason: String) async throws -> String {
        // First authenticate
        guard try await authenticate(reason: reason) else {
            throw BiometricError.authenticationFailed
        }

        // Then retrieve the protected data
        return try keychainManager.retrieve(key: key)
    }

    /// Store data with biometric protection
    public func storeWithBiometricProtection(key: String, value: String, reason: String) async throws {
        // Authenticate first
        guard try await authenticate(reason: reason) else {
            throw BiometricError.authenticationFailed
        }

        // Store with biometric requirement
        try keychainManager.store(key: key, value: value, requiresBiometric: true)
    }

    // MARK: - Session Management

    /// Create a biometric-protected session
    public func createBiometricSession(duration: TimeInterval = 300) async throws -> BiometricSession {
        guard try await authenticate(reason: "Create secure session") else {
            throw BiometricError.authenticationFailed
        }

        let session = BiometricSession(
            id: UUID().uuidString,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(duration),
            deviceId: getDeviceIdentifier()
        )

        // Store session
        let sessionData = try JSONEncoder().encode(session)
        let sessionString = sessionData.base64EncodedString()
        try keychainManager.store(key: "biometric_session", value: sessionString, requiresBiometric: true)

        return session
    }

    /// Validate biometric session
    public func validateBiometricSession() async throws -> Bool {
        do {
            let sessionString = try keychainManager.retrieve(key: "biometric_session")
            guard let sessionData = Data(base64Encoded: sessionString) else {
                return false
            }

            let session = try JSONDecoder().decode(BiometricSession.self, from: sessionData)

            // Check expiration
            if session.expiresAt < Date() {
                try keychainManager.delete(key: "biometric_session")
                return false
            }

            // Verify device
            if session.deviceId != getDeviceIdentifier() {
                throw BiometricError.deviceMismatch
            }

            return true
        } catch {
            return false
        }
    }

    // MARK: - Private Methods

    private func mapLAError(_ error: LAError) -> BiometricError {
        switch error.code {
        case .authenticationFailed:
            return .authenticationFailed
        case .userCancel:
            return .userCancelled
        case .userFallback:
            return .userFallback
        case .systemCancel:
            return .systemCancelled
        case .passcodeNotSet:
            return .passcodeNotSet
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .biometryLockout:
            return .lockout
        default:
            return .unknown(error)
        }
    }

    private func generateBiometricProtectedKey() -> String {
        let key = SymmetricKey(size: .bits256)
        return key.withUnsafeBytes { bytes in
            Data(bytes).base64EncodedString()
        }
    }

    private func getDeviceIdentifier() -> String {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))

        var deviceId = "unknown"
        if let deviceIdCF = IORegistryEntryCreateCFProperty(
            service,
            kIOPlatformUUIDKey as CFString,
            kCFAllocatorDefault,
            0
        ) {
            deviceId = deviceIdCF.takeUnretainedValue() as? String ?? deviceId
        }

        IOObjectRelease(service)
        return deviceId
    }

    /// Get human-readable biometric type
    public var biometricTypeDescription: String {
        switch biometricType {
        case .none:
            return "Not Available"
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        case .opticID:
            return "Optic ID"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - Supporting Types

public struct BiometricSession: Codable {
    let id: String
    let createdAt: Date
    let expiresAt: Date
    let deviceId: String
}

public enum BiometricError: LocalizedError {
    case notAvailable
    case notEnrolled
    case authenticationFailed
    case userCancelled
    case userFallback
    case systemCancelled
    case passcodeNotSet
    case lockout
    case deviceMismatch
    case sessionInvalid
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device"
        case .notEnrolled:
            return "No biometric data is enrolled. Please set up Touch ID or Face ID in System Preferences"
        case .authenticationFailed:
            return "Biometric authentication failed"
        case .userCancelled:
            return "Authentication was cancelled by the user"
        case .userFallback:
            return "User chose to enter password instead"
        case .systemCancelled:
            return "Authentication was cancelled by the system"
        case .passcodeNotSet:
            return "Device passcode is not set"
        case .lockout:
            return "Biometric authentication is locked due to too many failed attempts"
        case .deviceMismatch:
            return "Session was created on a different device"
        case .sessionInvalid:
            return "The session is invalid or has expired"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .notAvailable:
            return "This device doesn't support biometric authentication"
        case .notEnrolled:
            return "Go to System Preferences > Touch ID (or Face ID) to set up biometric authentication"
        case .authenticationFailed:
            return "Try again or use your password"
        case .lockout:
            return "Enter your device passcode to unlock biometric authentication"
        case .passcodeNotSet:
            return "Set up a device passcode in System Preferences"
        default:
            return nil
        }
    }
}
