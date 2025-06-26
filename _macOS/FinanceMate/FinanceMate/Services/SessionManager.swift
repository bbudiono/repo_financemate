//
//  SessionManager.swift
//  FinanceMate
//
//  Purpose: Secure session management with timeout and security policies
//  Implements zero-trust principles and continuous validation

import AppKit
import Combine
import Foundation
import IOKit

@MainActor
public final class SessionManager: ObservableObject {
    public static let shared = SessionManager()

    @Published public var isSessionActive = false
    @Published public var sessionExpiresAt: Date?
    @Published public var requiresReauthentication = false
    @Published public var sessionWarning: SessionWarning?

    private let keychainManager = KeychainManager.shared
    private let auditLogger = SecurityAuditLogger.shared
    private let biometricManager = BiometricAuthManager.shared

    // Session configuration
    private let sessionTimeout: TimeInterval = 900 // 15 minutes
    private let warningThreshold: TimeInterval = 120 // 2 minutes before expiry
    private let maxSessionDuration: TimeInterval = 28_800 // 8 hours

    // Activity monitoring
    private var lastActivityTime = Date()
    private var sessionStartTime: Date?
    private var activityTimer: Timer?
    private var warningTimer: Timer?

    // Security policies
    private var failedValidationAttempts = 0
    private let maxFailedAttempts = 3

    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupActivityMonitoring()
        setupSessionValidation()
    }

    // MARK: - Public Methods

    /// Create a new session after successful authentication
    public func createSession(for user: AuthenticatedUser, withBiometric: Bool = false) async throws {
        // Generate session ID
        let sessionId = UUID().uuidString

        // Calculate expiration
        let expiresAt = Date().addingTimeInterval(sessionTimeout)

        // Create session data
        let session = Session(
            id: sessionId,
            userId: user.id,
            createdAt: Date(),
            expiresAt: expiresAt,
            lastActivityAt: Date(),
            ipAddress: getIPAddress(),
            deviceId: getDeviceIdentifier(),
            isBiometricEnabled: withBiometric
        )

        // Store session
        let sessionData = try JSONEncoder().encode(session)
        let sessionString = sessionData.base64EncodedString()

        try keychainManager.store(
            key: "active_session",
            value: sessionString,
            requiresBiometric: withBiometric
        )

        // Update state
        isSessionActive = true
        sessionExpiresAt = expiresAt
        sessionStartTime = Date()
        lastActivityTime = Date()
        failedValidationAttempts = 0

        // Start monitoring
        startActivityTimer()
        scheduleExpiryWarning(for: expiresAt)

        // Audit log
        auditLogger.log(event: .sessionCreated(userId: user.id))
    }

    /// Validate current session
    public func validateSession() async throws -> Bool {
        do {
            // Retrieve session
            let sessionString = try keychainManager.retrieve(key: "active_session")
            guard let sessionData = Data(base64Encoded: sessionString) else {
                throw SessionError.invalidSession
            }

            var session = try JSONDecoder().decode(Session.self, from: sessionData)

            // Check expiration
            if session.expiresAt < Date() {
                throw SessionError.sessionExpired
            }

            // Check device binding
            if session.deviceId != getDeviceIdentifier() {
                auditLogger.log(event: .suspiciousActivity(
                    details: "Session accessed from different device"
                ))
                throw SessionError.deviceMismatch
            }

            // Check session duration limit
            if let startTime = sessionStartTime,
               Date().timeIntervalSince(startTime) > maxSessionDuration {
                throw SessionError.maxDurationExceeded
            }

            // Check for suspicious IP changes (in production)
            // This would compare current IP with session.ipAddress

            // Update last activity
            session.lastActivityAt = Date()
            let updatedData = try JSONEncoder().encode(session)
            try keychainManager.store(
                key: "active_session",
                value: updatedData.base64EncodedString(),
                requiresBiometric: session.isBiometricEnabled
            )

            // Reset failed attempts on successful validation
            failedValidationAttempts = 0

            return true
        } catch {
            failedValidationAttempts += 1

            if failedValidationAttempts >= maxFailedAttempts {
                auditLogger.log(event: .suspiciousActivity(
                    details: "Multiple failed session validation attempts"
                ))
                try? await terminateSession(reason: "Security policy violation")
            }

            throw error
        }
    }

    /// Extend session on user activity
    public func extendSession() async throws {
        guard isSessionActive else { return }

        // Don't extend if we're close to max duration
        if let startTime = sessionStartTime,
           Date().timeIntervalSince(startTime) > maxSessionDuration - sessionTimeout {
            return
        }

        // Validate session first
        guard try await validateSession() else {
            return
        }

        // Calculate new expiration
        let newExpiresAt = Date().addingTimeInterval(sessionTimeout)

        // Update session
        let sessionString = try keychainManager.retrieve(key: "active_session")
        guard let sessionData = Data(base64Encoded: sessionString) else {
            return
        }

        var session = try JSONDecoder().decode(Session.self, from: sessionData)
        session.expiresAt = newExpiresAt
        session.lastActivityAt = Date()

        let updatedData = try JSONEncoder().encode(session)
        try keychainManager.store(
            key: "active_session",
            value: updatedData.base64EncodedString(),
            requiresBiometric: session.isBiometricEnabled
        )

        // Update state
        sessionExpiresAt = newExpiresAt
        lastActivityTime = Date()

        // Reschedule warning
        scheduleExpiryWarning(for: newExpiresAt)
    }

    /// Terminate session
    public func terminateSession(reason: String = "User initiated") async throws {
        defer {
            // Clear state
            isSessionActive = false
            sessionExpiresAt = nil
            sessionStartTime = nil
            requiresReauthentication = false
            sessionWarning = nil

            // Stop timers
            activityTimer?.invalidate()
            warningTimer?.invalidate()
        }

        // Get session for audit
        if let sessionString = try? keychainManager.retrieve(key: "active_session"),
           let sessionData = Data(base64Encoded: sessionString),
           let session = try? JSONDecoder().decode(Session.self, from: sessionData) {
            // Audit log
            auditLogger.log(event: .sessionRevoked(userId: session.userId, reason: reason))
        }

        // Clear session from keychain
        try keychainManager.delete(key: "active_session")

        // Clear OAuth tokens if signing out completely
        if reason.lowercased().contains("sign out") {
            try? await OAuth2Manager.shared.signOut()
        }
    }

    /// Lock session (requires reauthentication)
    public func lockSession() async {
        requiresReauthentication = true
        activityTimer?.invalidate()

        if let sessionString = try? keychainManager.retrieve(key: "active_session"),
           let sessionData = Data(base64Encoded: sessionString),
           let session = try? JSONDecoder().decode(Session.self, from: sessionData) {
            auditLogger.log(event: .suspiciousActivity(
                details: "Session locked due to inactivity"
            ))
        }
    }

    /// Unlock session with biometric authentication
    public func unlockSession() async throws {
        guard requiresReauthentication else { return }

        // Require biometric authentication
        let authenticated = try await biometricManager.authenticate(
            reason: "Unlock your session"
        )

        if authenticated {
            requiresReauthentication = false
            lastActivityTime = Date()
            startActivityTimer()

            // Extend session
            try await extendSession()
        } else {
            throw SessionError.unlockFailed
        }
    }

    // MARK: - Security Policy Enforcement

    /// Check if action is allowed in current session state
    public func authorizeAction(_ action: SecurityAction) async throws {
        // Validate session first
        guard try await validateSession() else {
            throw SessionError.unauthorized
        }

        // Check if reauthentication required
        if requiresReauthentication {
            throw SessionError.reauthenticationRequired
        }

        // Check action-specific policies
        switch action {
        case .viewSensitiveData:
            // Require biometric for sensitive data
            if biometricManager.isBiometricAuthEnabled() {
                try await biometricManager.authenticateForSensitiveOperation("view sensitive data")
            }

        case .modifySecuritySettings:
            // Always require recent authentication
            if Date().timeIntervalSince(lastActivityTime) > 300 { // 5 minutes
                throw SessionError.recentAuthenticationRequired
            }

        case .exportData:
            // Log data export attempts
            auditLogger.log(event: .suspiciousActivity(
                details: "Data export requested"
            ))
        }

        // Update activity
        lastActivityTime = Date()
    }

    // MARK: - Private Methods

    private func setupActivityMonitoring() {
        // Monitor user activity
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .keyDown]) { [weak self] _ in
            Task { @MainActor in
                self?.handleUserActivity()
            }
        }

        // Monitor app state
        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handleAppActivation()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handleAppDeactivation()
                }
            }
            .store(in: &cancellables)
    }

    private func setupSessionValidation() {
        // Periodic session validation
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    try? await self?.validateSession()
                }
            }
            .store(in: &cancellables)
    }

    private func startActivityTimer() {
        activityTimer?.invalidate()

        activityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkInactivity()
            }
        }
    }

    private func scheduleExpiryWarning(for expiryDate: Date) {
        warningTimer?.invalidate()

        let warningDate = expiryDate.addingTimeInterval(-warningThreshold)
        let timeUntilWarning = warningDate.timeIntervalSinceNow

        if timeUntilWarning > 0 {
            warningTimer = Timer.scheduledTimer(withTimeInterval: timeUntilWarning, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    self?.showExpiryWarning()
                }
            }
        }
    }

    private func handleUserActivity() {
        guard isSessionActive && !requiresReauthentication else { return }

        let timeSinceLastActivity = Date().timeIntervalSince(lastActivityTime)

        // Only extend if significant time has passed
        if timeSinceLastActivity > 60 { // 1 minute
            Task {
                try? await extendSession()
            }
        }

        lastActivityTime = Date()
    }

    private func handleAppActivation() {
        guard isSessionActive else { return }

        // Check if we need to re-authenticate
        let inactiveTime = Date().timeIntervalSince(lastActivityTime)

        if inactiveTime > 300 { // 5 minutes
            Task {
                await lockSession()
            }
        }
    }

    private func handleAppDeactivation() {
        // Record last activity time
        lastActivityTime = Date()
    }

    private func checkInactivity() async {
        guard isSessionActive && !requiresReauthentication else { return }

        let inactiveTime = Date().timeIntervalSince(lastActivityTime)

        if inactiveTime > sessionTimeout {
            await lockSession()
        }
    }

    private func showExpiryWarning() {
        sessionWarning = SessionWarning(
            title: "Session Expiring Soon",
            message: "Your session will expire in 2 minutes. Would you like to extend it?",
            primaryAction: "Extend Session",
            secondaryAction: "Sign Out"
        )
    }

    private func getIPAddress() -> String {
        // In production, get actual IP
        "127.0.0.1"
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
}

// MARK: - Supporting Types

struct Session: Codable {
    let id: String
    let userId: String
    let createdAt: Date
    var expiresAt: Date
    var lastActivityAt: Date
    let ipAddress: String
    let deviceId: String
    let isBiometricEnabled: Bool
}

public struct SessionWarning {
    let title: String
    let message: String
    let primaryAction: String
    let secondaryAction: String
}

public enum SecurityAction {
    case viewSensitiveData
    case modifySecuritySettings
    case exportData
}

public enum SessionError: LocalizedError {
    case invalidSession
    case sessionExpired
    case deviceMismatch
    case maxDurationExceeded
    case unauthorized
    case reauthenticationRequired
    case recentAuthenticationRequired
    case unlockFailed

    public var errorDescription: String? {
        switch self {
        case .invalidSession:
            return "Invalid session"
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .deviceMismatch:
            return "Session security violation detected"
        case .maxDurationExceeded:
            return "Maximum session duration exceeded. Please sign in again."
        case .unauthorized:
            return "You are not authorized to perform this action"
        case .reauthenticationRequired:
            return "Please authenticate to continue"
        case .recentAuthenticationRequired:
            return "This action requires recent authentication"
        case .unlockFailed:
            return "Failed to unlock session"
        }
    }
}
