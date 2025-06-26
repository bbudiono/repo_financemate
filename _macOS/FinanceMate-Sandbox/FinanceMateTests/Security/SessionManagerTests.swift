//
//  SessionManagerTests.swift
//  FinanceMateTests
//
//  Purpose: Tests for session management and security policies
//  Validates timeout, activity monitoring, and authorization

import XCTest
@testable import FinanceMate

final class SessionManagerTests: XCTestCase {
    var sessionManager: SessionManager!

    override func setUp() {
        super.setUp()
        sessionManager = SessionManager.shared

        // Clean up any existing session
        Task {
            try? await sessionManager.terminateSession(reason: "Test setup")
        }
    }

    override func tearDown() {
        // Clean up session
        Task {
            try? await sessionManager.terminateSession(reason: "Test teardown")
        }
        super.tearDown()
    }

    // MARK: - Session Creation Tests

    func testCreateSession() async throws {
        // Given
        let user = AuthenticatedUser(
            id: "test_user_123",
            email: "test@financemate.com",
            name: "Test User",
            pictureURL: nil
        )

        // When
        try await sessionManager.createSession(for: user)

        // Then
        XCTAssertTrue(sessionManager.isSessionActive)
        XCTAssertNotNil(sessionManager.sessionExpiresAt)
        XCTAssertFalse(sessionManager.requiresReauthentication)

        // Verify expiration is in the future
        if let expiresAt = sessionManager.sessionExpiresAt {
            XCTAssertGreaterThan(expiresAt, Date())
        }
    }

    func testCreateSessionWithBiometric() async throws {
        // Given
        let user = AuthenticatedUser(
            id: "biometric_user",
            email: "biometric@financemate.com",
            name: "Biometric User",
            pictureURL: nil
        )

        // When/Then - Should not throw
        do {
            try await sessionManager.createSession(for: user, withBiometric: true)
            XCTAssertTrue(sessionManager.isSessionActive)
        } catch {
            // Expected in test environment without biometric hardware
            XCTAssertTrue(error is KeychainError || error is BiometricError)
        }
    }

    // MARK: - Session Validation Tests

    func testValidateActiveSession() async throws {
        // Given - Create a session first
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)

        // When
        let isValid = try await sessionManager.validateSession()

        // Then
        XCTAssertTrue(isValid)
        XCTAssertTrue(sessionManager.isSessionActive)
    }

    func testValidateExpiredSession() async throws {
        // Given - Create session then manipulate expiration
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)

        // Force expiration by manipulating the stored session
        if let sessionString = try? KeychainManager.shared.retrieve(key: "active_session"),
           let sessionData = Data(base64Encoded: sessionString),
           var session = try? JSONDecoder().decode(Session.self, from: sessionData) {

            session.expiresAt = Date().addingTimeInterval(-3600) // Expired 1 hour ago
            let updatedData = try JSONEncoder().encode(session)
            try KeychainManager.shared.store(key: "active_session", value: updatedData.base64EncodedString())
        }

        // When/Then
        do {
            _ = try await sessionManager.validateSession()
            XCTFail("Should throw sessionExpired error")
        } catch {
            XCTAssertEqual(error as? SessionError, .sessionExpired)
        }
    }

    // MARK: - Session Extension Tests

    func testExtendSession() async throws {
        // Given - Create session
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)

        let originalExpiration = sessionManager.sessionExpiresAt

        // Wait a moment
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // When
        try await sessionManager.extendSession()

        // Then
        XCTAssertNotNil(sessionManager.sessionExpiresAt)
        if let original = originalExpiration,
           let extended = sessionManager.sessionExpiresAt {
            XCTAssertGreaterThan(extended, original)
        }
    }

    func testExtendSessionWhenInactive() async throws {
        // Given - No active session
        sessionManager.isSessionActive = false

        // When
        try await sessionManager.extendSession()

        // Then - Should return silently without error
        XCTAssertFalse(sessionManager.isSessionActive)
    }

    // MARK: - Session Termination Tests

    func testTerminateSession() async throws {
        // Given - Create session
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)

        // When
        try await sessionManager.terminateSession(reason: "User initiated logout")

        // Then
        XCTAssertFalse(sessionManager.isSessionActive)
        XCTAssertNil(sessionManager.sessionExpiresAt)
        XCTAssertFalse(sessionManager.requiresReauthentication)

        // Verify session is removed from keychain
        do {
            _ = try KeychainManager.shared.retrieve(key: "active_session")
            XCTFail("Session should be removed from keychain")
        } catch {
            XCTAssertEqual(error as? KeychainError, .itemNotFound)
        }
    }

    // MARK: - Session Lock Tests

    func testLockSession() async throws {
        // Given - Active session
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)

        // When
        await sessionManager.lockSession()

        // Then
        XCTAssertTrue(sessionManager.requiresReauthentication)
        XCTAssertTrue(sessionManager.isSessionActive) // Still active but locked
    }

    func testUnlockSession() async throws {
        // Given - Locked session
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)
        await sessionManager.lockSession()

        // When/Then
        do {
            try await sessionManager.unlockSession()
            XCTAssertFalse(sessionManager.requiresReauthentication)
        } catch {
            // Expected in test environment without biometric
            XCTAssertTrue(error is BiometricError || error is SessionError)
        }
    }

    // MARK: - Security Policy Tests

    func testAuthorizeViewSensitiveData() async throws {
        // Given - Active session
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)

        // When/Then
        do {
            try await sessionManager.authorizeAction(.viewSensitiveData)
            // Success or biometric required
        } catch {
            // Expected if biometric is required
            XCTAssertTrue(error is BiometricError || error is SessionError)
        }
    }

    func testAuthorizeModifySecuritySettings() async throws {
        // Given - Active session
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)

        // When - Immediate authorization should succeed
        try await sessionManager.authorizeAction(.modifySecuritySettings)

        // Wait for activity timeout
        sessionManager.lastActivityTime = Date().addingTimeInterval(-400) // 6+ minutes ago

        // Then - Should require recent authentication
        do {
            try await sessionManager.authorizeAction(.modifySecuritySettings)
            XCTFail("Should require recent authentication")
        } catch {
            XCTAssertEqual(error as? SessionError, .recentAuthenticationRequired)
        }
    }

    func testAuthorizeWithLockedSession() async throws {
        // Given - Locked session
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)
        await sessionManager.lockSession()

        // When/Then
        do {
            try await sessionManager.authorizeAction(.viewSensitiveData)
            XCTFail("Should throw reauthenticationRequired")
        } catch {
            XCTAssertEqual(error as? SessionError, .reauthenticationRequired)
        }
    }

    // MARK: - Session Warning Tests

    func testSessionWarningCreation() {
        // Given
        let warning = SessionWarning(
            title: "Test Warning",
            message: "This is a test",
            primaryAction: "OK",
            secondaryAction: "Cancel"
        )

        // When
        sessionManager.sessionWarning = warning

        // Then
        XCTAssertNotNil(sessionManager.sessionWarning)
        XCTAssertEqual(sessionManager.sessionWarning?.title, "Test Warning")
    }

    // MARK: - Error Tests

    func testSessionErrorDescriptions() {
        let testCases: [(SessionError, String)] = [
            (.invalidSession, "Invalid session"),
            (.sessionExpired, "Your session has expired. Please sign in again."),
            (.deviceMismatch, "Session security violation detected"),
            (.maxDurationExceeded, "Maximum session duration exceeded. Please sign in again."),
            (.unauthorized, "You are not authorized to perform this action"),
            (.reauthenticationRequired, "Please authenticate to continue"),
            (.recentAuthenticationRequired, "This action requires recent authentication"),
            (.unlockFailed, "Failed to unlock session")
        ]

        for (error, expectedDescription) in testCases {
            XCTAssertEqual(error.errorDescription, expectedDescription)
        }
    }

    // MARK: - Device Binding Tests

    func testDeviceMismatchDetection() async throws {
        // This test would require mocking the device identifier
        // In a real scenario, it would detect if session is accessed from different device

        // Given - Create session
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)

        // When - Validate from same device
        let isValid = try await sessionManager.validateSession()

        // Then
        XCTAssertTrue(isValid)
    }

    // MARK: - Concurrent Session Tests

    func testConcurrentSessionOperations() async throws {
        // Given
        let user = AuthenticatedUser(id: "123", email: "test@test.com", name: "Test", pictureURL: nil)
        try await sessionManager.createSession(for: user)

        // When - Perform multiple concurrent operations
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    try? await self.sessionManager.validateSession()
                }

                group.addTask {
                    try? await self.sessionManager.extendSession()
                }
            }
        }

        // Then - Session should still be valid
        XCTAssertTrue(sessionManager.isSessionActive)
    }
}

// MARK: - Test Helpers

private struct Session: Codable {
    let id: String
    let userId: String
    let createdAt: Date
    var expiresAt: Date
    var lastActivityAt: Date
    let ipAddress: String
    let deviceId: String
    let isBiometricEnabled: Bool
}
