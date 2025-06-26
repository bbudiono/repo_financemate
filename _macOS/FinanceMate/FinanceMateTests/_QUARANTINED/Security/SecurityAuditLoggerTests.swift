//
//  SecurityAuditLoggerTests.swift
//  FinanceMateTests
//
//  Purpose: Tests for security audit logging and compliance
//  Validates tamper detection, log integrity, and event tracking

import XCTest
@testable import FinanceMate

final class SecurityAuditLoggerTests: XCTestCase {
    var auditLogger: SecurityAuditLogger!
    var testLogPath: URL!

    override func setUp() {
        super.setUp()
        auditLogger = SecurityAuditLogger.shared

        // Get test log path
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let filename = "audit_\(dateFormatter.string(from: Date())).log"
        testLogPath = appSupport
            .appendingPathComponent("FinanceMate/SecurityAudit")
            .appendingPathComponent(filename)
    }

    override func tearDown() {
        // Clean up test logs
        try? FileManager.default.removeItem(at: testLogPath)
        super.tearDown()
    }

    // MARK: - Event Logging Tests

    func testLogAuthenticationSuccess() {
        // Given
        let event = SecurityEvent.authenticationSuccess(
            userId: "test_user",
            method: .appleSignIn
        )

        // When
        auditLogger.log(event: event)

        // Wait for async write
        let expectation = XCTestExpectation(description: "Log write")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then - Verify log file exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: testLogPath.path))
    }

    func testLogMultipleEventTypes() {
        // Given - Various event types
        let events: [SecurityEvent] = [
            .authenticationSuccess(userId: "user1", method: .googleSignIn),
            .authenticationFailure(userId: "user2", reason: "Invalid password"),
            .sessionCreated(userId: "user1"),
            .sessionExpired(userId: "user1"),
            .sessionRevoked(userId: "user2", reason: "Manual logout"),
            .keychainStore(key: "api_key", requiresBiometric: true),
            .keychainRetrieve(key: "api_key"),
            .keychainDelete(key: "old_key"),
            .oauthTokenRefresh(userId: "user1"),
            .biometricAuthSuccess,
            .biometricAuthFailure(reason: "User cancelled"),
            .suspiciousActivity(details: "Multiple failed login attempts"),
            .securityPolicyViolation(policy: "session_timeout", details: "Session exceeded max duration")
        ]

        // When
        for event in events {
            auditLogger.log(event: event)
        }

        // Wait for async writes
        let expectation = XCTestExpectation(description: "Log writes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        // Then - All events should be logged
        XCTAssertTrue(FileManager.default.fileExists(atPath: testLogPath.path))
    }

    // MARK: - Audit Verification Tests

    func testVerifyValidAuditLog() {
        // Given - Log some events
        auditLogger.log(event: .authenticationSuccess(userId: "user1", method: .appleSignIn))
        auditLogger.log(event: .sessionCreated(userId: "user1"))

        // Wait for writes
        let expectation = XCTestExpectation(description: "Log writes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // When
        let result = auditLogger.verifyAuditLog()

        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.tamperedEntries, 0)
        XCTAssertGreaterThan(result.totalEntries, 0)
    }

    func testDetectTamperedLog() {
        // Given - Log an event
        auditLogger.log(event: .authenticationSuccess(userId: "user1", method: .appleSignIn))

        // Wait for write
        let expectation = XCTestExpectation(description: "Log write")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Tamper with the log file
        if let logContent = try? String(contentsOf: testLogPath),
           var lines = logContent.components(separatedBy: .newlines).filter({ !$0.isEmpty }),
           let firstLine = lines.first {

            // Modify the log entry
            if var entry = try? JSONDecoder().decode(AuditLogEntry.self, from: firstLine.data(using: .utf8)!) {
                entry.details = "TAMPERED: " + entry.details
                if let tamperedData = try? JSONEncoder().encode(entry),
                   let tamperedString = String(data: tamperedData, encoding: .utf8) {
                    lines[0] = tamperedString
                    let tamperedContent = lines.joined(separator: "\n") + "\n"
                    try? tamperedContent.write(to: testLogPath, atomically: true, encoding: .utf8)
                }
            }
        }

        // When
        let result = auditLogger.verifyAuditLog()

        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertGreaterThan(result.tamperedEntries, 0)
    }

    // MARK: - Event Type Tests

    func testEventTypeStrings() {
        let testCases: [(SecurityEvent, String)] = [
            (.authenticationSuccess(userId: "u1", method: .appleSignIn), "AUTH_SUCCESS"),
            (.authenticationFailure(userId: "u1", reason: "test"), "AUTH_FAILURE"),
            (.sessionCreated(userId: "u1"), "SESSION_CREATED"),
            (.sessionExpired(userId: "u1"), "SESSION_EXPIRED"),
            (.sessionRevoked(userId: "u1", reason: "test"), "SESSION_REVOKED"),
            (.keychainStore(key: "k1", requiresBiometric: false), "KEYCHAIN_STORE"),
            (.keychainRetrieve(key: "k1"), "KEYCHAIN_RETRIEVE"),
            (.keychainDelete(key: "k1"), "KEYCHAIN_DELETE"),
            (.keychainClearAll, "KEYCHAIN_CLEAR_ALL"),
            (.oauthTokenRefresh(userId: "u1"), "OAUTH_TOKEN_REFRESH"),
            (.biometricAuthSuccess, "BIOMETRIC_SUCCESS"),
            (.biometricAuthFailure(reason: "test"), "BIOMETRIC_FAILURE"),
            (.suspiciousActivity(details: "test"), "SUSPICIOUS_ACTIVITY"),
            (.securityPolicyViolation(policy: "p1", details: "test"), "POLICY_VIOLATION")
        ]

        for (event, expectedType) in testCases {
            XCTAssertEqual(event.type, expectedType)
        }
    }

    func testEventSeverityLevels() {
        // Info level events
        let infoEvents: [SecurityEvent] = [
            .authenticationSuccess(userId: "u1", method: .appleSignIn),
            .sessionCreated(userId: "u1"),
            .keychainStore(key: "k1", requiresBiometric: false),
            .keychainRetrieve(key: "k1"),
            .oauthTokenRefresh(userId: "u1"),
            .biometricAuthSuccess
        ]

        for event in infoEvents {
            XCTAssertEqual(event.severity, .info)
        }

        // Warning level events
        let warningEvents: [SecurityEvent] = [
            .sessionExpired(userId: "u1"),
            .keychainDelete(key: "k1"),
            .keychainClearAll
        ]

        for event in warningEvents {
            XCTAssertEqual(event.severity, .warning)
        }

        // Error level events
        let errorEvents: [SecurityEvent] = [
            .authenticationFailure(userId: "u1", reason: "test"),
            .sessionRevoked(userId: "u1", reason: "test"),
            .biometricAuthFailure(reason: "test")
        ]

        for event in errorEvents {
            XCTAssertEqual(event.severity, .error)
        }

        // Critical level events
        let criticalEvents: [SecurityEvent] = [
            .suspiciousActivity(details: "test"),
            .securityPolicyViolation(policy: "p1", details: "test")
        ]

        for event in criticalEvents {
            XCTAssertEqual(event.severity, .critical)
        }
    }

    // MARK: - Export Tests

    func testExportAuditLogDateRange() {
        // Given - Log events across different times
        let now = Date()
        let events = [
            SecurityEvent.authenticationSuccess(userId: "user1", method: .appleSignIn),
            SecurityEvent.sessionCreated(userId: "user1"),
            SecurityEvent.sessionExpired(userId: "user1")
        ]

        for event in events {
            auditLogger.log(event: event)
        }

        // Wait for writes
        let expectation = XCTestExpectation(description: "Log writes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // When - Export for today
        let exportData = auditLogger.exportAuditLog(
            from: now.addingTimeInterval(-3600),
            to: now.addingTimeInterval(3600)
        )

        // Then
        XCTAssertNotNil(exportData)
        if let data = exportData,
           let entries = try? JSONDecoder().decode([AuditLogEntry].self, from: data) {
            XCTAssertGreaterThan(entries.count, 0)
        }
    }

    func testExportEmptyDateRange() {
        // Given - Log an event
        auditLogger.log(event: .authenticationSuccess(userId: "user1", method: .appleSignIn))

        // Wait for write
        let expectation = XCTestExpectation(description: "Log write")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // When - Export for future date range
        let futureStart = Date().addingTimeInterval(86400) // Tomorrow
        let futureEnd = futureStart.addingTimeInterval(3600)
        let exportData = auditLogger.exportAuditLog(from: futureStart, to: futureEnd)

        // Then
        if let data = exportData,
           let entries = try? JSONDecoder().decode([AuditLogEntry].self, from: data) {
            XCTAssertEqual(entries.count, 0)
        }
    }

    // MARK: - Concurrent Logging Tests

    func testConcurrentLogging() {
        // Given
        let expectation = XCTestExpectation(description: "Concurrent logs")
        expectation.expectedFulfillmentCount = 100

        // When - Log 100 events concurrently
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            let event = SecurityEvent.authenticationSuccess(
                userId: "user_\(index)",
                method: index % 2 == 0 ? .appleSignIn : .googleSignIn
            )
            auditLogger.log(event: event)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        // Wait for all writes
        let writeExpectation = XCTestExpectation(description: "Write completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            writeExpectation.fulfill()
        }
        wait(for: [writeExpectation], timeout: 2.0)

        // Then - Verify all logs are valid
        let result = auditLogger.verifyAuditLog()
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.tamperedEntries, 0)
    }

    // MARK: - Critical Event Tests

    func testCriticalEventNotification() {
        // Given - Critical security event
        let criticalEvent = SecurityEvent.suspiciousActivity(
            details: "Multiple unauthorized access attempts detected"
        )

        // When
        auditLogger.log(event: criticalEvent)

        // Then - In production, this would trigger alerts
        // For testing, we just verify it was logged
        let expectation = XCTestExpectation(description: "Critical log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(FileManager.default.fileExists(atPath: testLogPath.path))
    }
}
