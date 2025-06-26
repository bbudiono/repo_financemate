//
//  SecurityAuditLogger.swift
//  FinanceMate
//
//  Purpose: Comprehensive security audit logging for compliance
//  Tracks all authentication and security-related events

import CryptoKit
import Foundation
import OSLog

@MainActor
public final class SecurityAuditLogger {
    public static let shared = SecurityAuditLogger()

    private let logger = Logger(subsystem: "com.ablankcanvas.FinanceMate", category: "Security")
    private let auditQueue = DispatchQueue(label: "com.financemate.audit", qos: .utility)
    private let auditLogPath: URL

    private init() {
        // Create secure audit log directory
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let auditDir = appSupport.appendingPathComponent("FinanceMate/SecurityAudit")

        try? FileManager.default.createDirectory(at: auditDir, withIntermediateDirectories: true)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let filename = "audit_\(dateFormatter.string(from: Date())).log"

        auditLogPath = auditDir.appendingPathComponent(filename)
    }

    // MARK: - Public Methods

    public func log(event: SecurityEvent) {
        let entry = AuditLogEntry(
            timestamp: Date(),
            eventType: event.type,
            userId: getCurrentUserId(),
            deviceId: getDeviceId(),
            details: event.details,
            severity: event.severity,
            ipAddress: getIPAddress(),
            checksum: ""
        )

        // Add checksum for tamper detection
        var mutableEntry = entry
        mutableEntry.checksum = calculateChecksum(for: entry)

        // Log to system
        logger.log(level: event.severity.osLogType, "\(event.type): \(event.details)")

        // Write to secure audit file
        auditQueue.async { [weak self] in
            self?.writeToAuditLog(mutableEntry)
        }

        // Alert on critical events
        if event.severity == .critical {
            notifyCriticalSecurityEvent(event)
        }
    }

    public func verifyAuditLog() -> AuditVerificationResult {
        var validEntries = 0
        var tamperedEntries = 0
        var totalEntries = 0

        guard let logData = try? String(contentsOf: auditLogPath),
              !logData.isEmpty else {
            return AuditVerificationResult(isValid: true, tamperedEntries: 0, totalEntries: 0)
        }

        let lines = logData.components(separatedBy: .newlines)

        for line in lines where !line.isEmpty {
            totalEntries += 1

            if let entry = parseAuditEntry(from: line) {
                let calculatedChecksum = calculateChecksum(for: entry)
                if calculatedChecksum == entry.checksum {
                    validEntries += 1
                } else {
                    tamperedEntries += 1
                    logger.critical("Tampered audit entry detected: \(entry.timestamp)")
                }
            }
        }

        return AuditVerificationResult(
            isValid: tamperedEntries == 0,
            tamperedEntries: tamperedEntries,
            totalEntries: totalEntries
        )
    }

    public func exportAuditLog(from startDate: Date, to endDate: Date) -> Data? {
        guard let logData = try? String(contentsOf: auditLogPath) else {
            return nil
        }

        let lines = logData.components(separatedBy: .newlines)
        var filteredEntries: [AuditLogEntry] = []

        for line in lines where !line.isEmpty {
            if let entry = parseAuditEntry(from: line),
               entry.timestamp >= startDate && entry.timestamp <= endDate {
                filteredEntries.append(entry)
            }
        }

        return try? JSONEncoder().encode(filteredEntries)
    }

    // MARK: - Private Methods

    private func writeToAuditLog(_ entry: AuditLogEntry) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(entry),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }

        let logLine = jsonString + "\n"

        if FileManager.default.fileExists(atPath: auditLogPath.path) {
            if let fileHandle = try? FileHandle(forWritingTo: auditLogPath) {
                fileHandle.seekToEndOfFile()
                if let data = logLine.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            }
        } else {
            try? logLine.write(to: auditLogPath, atomically: true, encoding: .utf8)
        }
    }

    private func calculateChecksum(for entry: AuditLogEntry) -> String {
        let checksumData = "\(entry.timestamp)\(entry.eventType)\(entry.userId)\(entry.deviceId)\(entry.details)\(entry.severity.rawValue)"
        let hash = SHA256.hash(data: checksumData.data(using: .utf8)!)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func parseAuditEntry(from line: String) -> AuditLogEntry? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let data = line.data(using: .utf8) else {
            return nil
        }

        return try? decoder.decode(AuditLogEntry.self, from: data)
    }

    private func getCurrentUserId() -> String {
        // In production, this would get the actual user ID
        ProcessInfo.processInfo.userName
    }

    private func getDeviceId() -> String {
        // Get hardware UUID
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))

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

    private func getIPAddress() -> String {
        // In production, this would get the actual IP
        "127.0.0.1"
    }

    private func notifyCriticalSecurityEvent(_ event: SecurityEvent) {
        // In production, this would send alerts to security team
        logger.critical("SECURITY ALERT: \(event.type) - \(event.details)")
    }
}

// MARK: - Supporting Types

public enum SecurityEvent {
    case authenticationSuccess(userId: String, method: AuthMethod)
    case authenticationFailure(userId: String, reason: String)
    case sessionCreated(userId: String)
    case sessionExpired(userId: String)
    case sessionRevoked(userId: String, reason: String)
    case keychainStore(key: String, requiresBiometric: Bool)
    case keychainRetrieve(key: String)
    case keychainDelete(key: String)
    case keychainClearAll
    case oauthTokenRefresh(userId: String)
    case biometricAuthSuccess
    case biometricAuthFailure(reason: String)
    case suspiciousActivity(details: String)
    case securityPolicyViolation(policy: String, details: String)

    var type: String {
        switch self {
        case .authenticationSuccess: return "AUTH_SUCCESS"
        case .authenticationFailure: return "AUTH_FAILURE"
        case .sessionCreated: return "SESSION_CREATED"
        case .sessionExpired: return "SESSION_EXPIRED"
        case .sessionRevoked: return "SESSION_REVOKED"
        case .keychainStore: return "KEYCHAIN_STORE"
        case .keychainRetrieve: return "KEYCHAIN_RETRIEVE"
        case .keychainDelete: return "KEYCHAIN_DELETE"
        case .keychainClearAll: return "KEYCHAIN_CLEAR_ALL"
        case .oauthTokenRefresh: return "OAUTH_TOKEN_REFRESH"
        case .biometricAuthSuccess: return "BIOMETRIC_SUCCESS"
        case .biometricAuthFailure: return "BIOMETRIC_FAILURE"
        case .suspiciousActivity: return "SUSPICIOUS_ACTIVITY"
        case .securityPolicyViolation: return "POLICY_VIOLATION"
        }
    }

    var details: String {
        switch self {
        case .authenticationSuccess(let userId, let method):
            return "User \(userId) authenticated via \(method)"
        case .authenticationFailure(let userId, let reason):
            return "Authentication failed for \(userId): \(reason)"
        case .sessionCreated(let userId):
            return "Session created for user \(userId)"
        case .sessionExpired(let userId):
            return "Session expired for user \(userId)"
        case .sessionRevoked(let userId, let reason):
            return "Session revoked for user \(userId): \(reason)"
        case .keychainStore(let key, let requiresBiometric):
            return "Stored key '\(key)' with biometric: \(requiresBiometric)"
        case .keychainRetrieve(let key):
            return "Retrieved key '\(key)'"
        case .keychainDelete(let key):
            return "Deleted key '\(key)'"
        case .keychainClearAll:
            return "Cleared all keychain items"
        case .oauthTokenRefresh(let userId):
            return "OAuth token refreshed for user \(userId)"
        case .biometricAuthSuccess:
            return "Biometric authentication successful"
        case .biometricAuthFailure(let reason):
            return "Biometric authentication failed: \(reason)"
        case .suspiciousActivity(let details):
            return "Suspicious activity detected: \(details)"
        case .securityPolicyViolation(let policy, let details):
            return "Policy '\(policy)' violated: \(details)"
        }
    }

    var severity: SecuritySeverity {
        switch self {
        case .authenticationSuccess, .sessionCreated, .keychainStore,
             .keychainRetrieve, .oauthTokenRefresh, .biometricAuthSuccess:
            return .info
        case .sessionExpired, .keychainDelete, .keychainClearAll:
            return .warning
        case .authenticationFailure, .sessionRevoked, .biometricAuthFailure:
            return .error
        case .suspiciousActivity, .securityPolicyViolation:
            return .critical
        }
    }
}

public enum AuthMethod: String {
    case appleSignIn = "Apple Sign In"
    case googleSignIn = "Google Sign In"
    case biometric = "Biometric"
    case password = "Password"
}

public enum SecuritySeverity: String, Codable {
    case info
    case warning
    case error
    case critical

    var osLogType: OSLogType {
        switch self {
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .critical: return .fault
        }
    }
}

public struct AuditLogEntry: Codable {
    let timestamp: Date
    let eventType: String
    let userId: String
    let deviceId: String
    let details: String
    let severity: SecuritySeverity
    let ipAddress: String
    var checksum: String
}

public struct AuditVerificationResult {
    let isValid: Bool
    let tamperedEntries: Int
    let totalEntries: Int
}
