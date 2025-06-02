// SANDBOX FILE: For testing/development. See .cursorrules.
//
// CrashAlerting.swift
// FinanceMate-Sandbox
//
// Purpose: Comprehensive crash alerting and notification system
// Issues & Complexity Summary: Complex alerting logic with threshold management and notification delivery
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~280
//   - Core Algorithm Complexity: Medium (threshold evaluation, notification routing, rate limiting)
//   - Dependencies: 4 New (Foundation, UserNotifications, os.log, Combine)
//   - State Management Complexity: Medium (alert state tracking, notification management)
//   - Novelty/Uncertainty Factor: Low (established notification patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 68%
// Problem Estimate (Inherent Problem Difficulty %): 65%
// Initial Code Complexity Estimate %: 66%
// Justification for Estimates: Standard notification patterns with some complexity in threshold management
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import Foundation
import UserNotifications
import os.log
import Combine
#if os(macOS)
import AppKit
#endif

// MARK: - Crash Alerting Implementation

public final class CrashAlerting: NSObject, CrashAlertingProtocol, ObservableObject {
    public static let shared = CrashAlerting()
    
    private let alertQueue = DispatchQueue(label: "com.financemate.crash.alerting", qos: .utility)
    
    // Published properties for real-time monitoring
    @Published public private(set) var recentAlerts: [CrashAlert] = []
    @Published public private(set) var alertStatistics: AlertStatistics = AlertStatistics()
    
    // Configuration
    private var alertConfiguration = AlertConfiguration()
    private var criticalityThresholds: [CrashSeverity: Int] = [
        .critical: 1,
        .high: 3,
        .medium: 10,
        .low: 20
    ]
    
    // Alert management
    private var recentAlertCount: [CrashSeverity: Int] = [:]
    private var lastAlertTimes: [CrashSeverity: Date] = [:]
    private var alertHistory: [CrashAlert] = []
    
    // Rate limiting
    private let rateLimitWindow: TimeInterval = 300 // 5 minutes
    private var alertCounts: [String: (count: Int, windowStart: Date)] = [:]
    
    override init() {
        super.init()
        setupNotifications()
        resetAlertCounters()
    }
    
    // MARK: - Public Interface
    
    public func shouldAlert(for report: CrashReport) -> Bool {
        return alertQueue.sync {
            return shouldAlertSync(for: report)
        }
    }
    
    public func sendAlert(for report: CrashReport) async throws {
        Logger.info("Sending alert for crash: \(report.crashType) - \(report.severity)", category: .crash)
        
        return try await withCheckedThrowingContinuation { continuation in
            alertQueue.async { [weak self] in
                do {
                    try self?.sendAlertSync(for: report)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func configureCriticalityThresholds(_ thresholds: [CrashSeverity: Int]) {
        alertQueue.async { [weak self] in
            self?.criticalityThresholds = thresholds
            Logger.info("Criticality thresholds updated", category: .crash, metadata: [
                "critical": "\(thresholds[.critical] ?? 0)",
                "high": "\(thresholds[.high] ?? 0)",
                "medium": "\(thresholds[.medium] ?? 0)",
                "low": "\(thresholds[.low] ?? 0)"
            ])
        }
    }
    
    // MARK: - Configuration
    
    public func configure(_ configuration: AlertConfiguration) {
        alertQueue.async { [weak self] in
            self?.alertConfiguration = configuration
            Logger.info("Alert configuration updated", category: .crash)
        }
    }
    
    public func enableAlert(type: AlertType, enabled: Bool) {
        alertQueue.async { [weak self] in
            self?.alertConfiguration.enabledAlerts[type] = enabled
            Logger.info("Alert type \(type) \(enabled ? "enabled" : "disabled")", category: .crash)
        }
    }
    
    // MARK: - Alert Management
    
    public func getAlertHistory(limit: Int = 100) -> [CrashAlert] {
        return alertQueue.sync {
            return Array(alertHistory.prefix(limit))
        }
    }
    
    public func clearAlertHistory() {
        alertQueue.async { [weak self] in
            self?.alertHistory.removeAll()
            self?.recentAlertCount.removeAll()
            self?.lastAlertTimes.removeAll()
            
            DispatchQueue.main.async {
                self?.recentAlerts.removeAll()
                self?.alertStatistics = AlertStatistics()
            }
            
            Logger.info("Alert history cleared", category: .crash)
        }
    }
    
    public func snoozeAlerts(duration: TimeInterval) {
        alertQueue.async { [weak self] in
            self?.alertConfiguration.snoozeUntil = Date().addingTimeInterval(duration)
            Logger.info("Alerts snoozed for \(duration) seconds", category: .crash)
        }
    }
    
    // MARK: - Private Implementation
    
    private func setupNotifications() {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                Logger.info("Notification permissions granted", category: .crash)
            } else {
                Logger.warning("Notification permissions denied: \(error?.localizedDescription ?? "Unknown")", category: .crash)
            }
        }
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func resetAlertCounters() {
        // Reset alert counters every hour
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.alertQueue.async {
                self?.recentAlertCount.removeAll()
                Logger.debug("Alert counters reset", category: .crash)
            }
        }
    }
    
    private func shouldAlertSync(for report: CrashReport) -> Bool {
        // Check if alerts are snoozed
        if let snoozeUntil = alertConfiguration.snoozeUntil, Date() < snoozeUntil {
            return false
        }
        
        // Check if this alert type is enabled
        let alertType = determineAlertType(for: report)
        if alertConfiguration.enabledAlerts[alertType] != true {
            return false
        }
        
        // Check severity threshold
        guard let threshold = criticalityThresholds[report.severity] else {
            return false
        }
        
        let currentCount = recentAlertCount[report.severity, default: 0] + 1
        recentAlertCount[report.severity] = currentCount
        
        // Check if we've exceeded the threshold
        if currentCount >= threshold {
            // Check rate limiting
            if isRateLimited(for: report) {
                Logger.debug("Alert rate limited for \(report.severity) crash", category: .crash)
                return false
            }
            
            return true
        }
        
        return false
    }
    
    private func sendAlertSync(for report: CrashReport) throws {
        let alert = createAlert(for: report)
        
        // Update alert tracking
        lastAlertTimes[report.severity] = Date()
        alertHistory.insert(alert, at: 0)
        
        // Maintain alert history limit
        if alertHistory.count > alertConfiguration.maxAlertHistory {
            alertHistory.removeLast(alertHistory.count - alertConfiguration.maxAlertHistory)
        }
        
        // Update published properties
        DispatchQueue.main.async { [weak self] in
            self?.recentAlerts.insert(alert, at: 0)
            if let count = self?.recentAlerts.count, count > 20 {
                self?.recentAlerts.removeLast(count - 20)
            }
            self?.updateAlertStatistics()
        }
        
        // Send notifications based on configuration
        if alertConfiguration.enableLocalNotifications {
            try sendLocalNotification(for: alert, report: report)
        }
        
        if alertConfiguration.enableSystemAlerts {
            try sendSystemAlert(for: alert, report: report)
        }
        
        if alertConfiguration.enableEmailAlerts && alertConfiguration.emailRecipients.count > 0 {
            try sendEmailAlert(for: alert, report: report)
        }
        
        if alertConfiguration.enableWebhookAlerts && alertConfiguration.webhookURL != nil {
            try sendWebhookAlert(for: alert, report: report)
        }
        
        Logger.info("Alert sent successfully: \(alert.type) - \(alert.severity)", category: .crash)
    }
    
    private func isRateLimited(for report: CrashReport) -> Bool {
        let key = "\(report.crashType)_\(report.severity)"
        let now = Date()
        
        if let existing = alertCounts[key] {
            let windowAge = now.timeIntervalSince(existing.windowStart)
            if windowAge < rateLimitWindow {
                if existing.count >= alertConfiguration.maxAlertsPerWindow {
                    return true
                }
                alertCounts[key] = (existing.count + 1, existing.windowStart)
            } else {
                alertCounts[key] = (1, now)
            }
        } else {
            alertCounts[key] = (1, now)
        }
        
        return false
    }
    
    private func createAlert(for report: CrashReport) -> CrashAlert {
        let alertType = determineAlertType(for: report)
        let severity = mapCrashSeverityToAlertSeverity(report.severity)
        
        return CrashAlert(
            type: alertType,
            severity: severity,
            title: generateAlertTitle(for: report),
            message: generateAlertMessage(for: report),
            crashId: report.id,
            crashType: report.crashType,
            metadata: generateAlertMetadata(for: report)
        )
    }
    
    private func determineAlertType(for report: CrashReport) -> AlertType {
        switch report.crashType {
        case .memoryLeak:
            return .memoryIssue
        case .unexpectedException, .signalException:
            return .criticalCrash
        case .hangOrTimeout, .uiResponsiveness:
            return .performanceIssue
        case .networkFailure:
            return .networkIssue
        case .authenticationFailure:
            return .securityIssue
        case .dataCorruption:
            return .dataIntegrity
        case .unknown:
            return .unknownIssue
        }
    }
    
    private func mapCrashSeverityToAlertSeverity(_ crashSeverity: CrashSeverity) -> AlertSeverity {
        switch crashSeverity {
        case .low:
            return .info
        case .medium:
            return .warning
        case .high:
            return .error
        case .critical:
            return .critical
        }
    }
    
    private func generateAlertTitle(for report: CrashReport) -> String {
        switch report.severity {
        case .critical:
            return "🚨 Critical Crash Detected"
        case .high:
            return "⚠️ High Severity Crash"
        case .medium:
            return "📢 Crash Alert"
        case .low:
            return "ℹ️ Crash Notification"
        }
    }
    
    private func generateAlertMessage(for report: CrashReport) -> String {
        let appVersion = report.applicationVersion
        let crashType = report.crashType.rawValue.capitalized
        let errorMessage = report.errorMessage.prefix(100)
        
        return "\(crashType) crash in v\(appVersion): \(errorMessage)"
    }
    
    private func generateAlertMetadata(for report: CrashReport) -> [String: String] {
        return [
            "appVersion": report.applicationVersion,
            "buildNumber": report.buildNumber,
            "systemVersion": report.systemVersion,
            "deviceModel": report.deviceModel,
            "sessionId": report.sessionId,
            "timestamp": ISO8601DateFormatter().string(from: report.timestamp)
        ]
    }
    
    // MARK: - Notification Methods
    
    private func sendLocalNotification(for alert: CrashAlert, report: CrashReport) throws {
        let content = UNMutableNotificationContent()
        content.title = alert.title
        content.body = alert.message
        content.sound = alert.severity == .critical ? .defaultCritical : .default
        content.categoryIdentifier = "CRASH_ALERT"
        content.userInfo = alert.metadata
        
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.error("Failed to send local notification: \(error)", category: .crash)
            } else {
                Logger.debug("Local notification sent for crash alert", category: .crash)
            }
        }
    }
    
    private func sendSystemAlert(for alert: CrashAlert, report: CrashReport) throws {
        // For macOS, we can use NSAlert for system-level alerts
        DispatchQueue.main.async {
            let systemAlert = NSAlert()
            systemAlert.messageText = alert.title
            systemAlert.informativeText = alert.message
            systemAlert.alertStyle = alert.severity == .critical ? .critical : .warning
            systemAlert.addButton(withTitle: "OK")
            systemAlert.addButton(withTitle: "View Details")
            
            let response = systemAlert.runModal()
            if response == .alertSecondButtonReturn {
                Logger.info("User requested crash details", category: .crash)
                // Could open crash details view here
            }
        }
    }
    
    private func sendEmailAlert(for alert: CrashAlert, report: CrashReport) throws {
        // Email alerts would typically use a mail service API
        // This is a placeholder implementation
        let emailData = generateEmailContent(for: alert, report: report)
        
        Logger.info("Email alert would be sent to: \(alertConfiguration.emailRecipients.joined(separator: ", "))", category: .crash)
        Logger.debug("Email content: \(emailData)", category: .crash)
        
        // In a real implementation, you would:
        // 1. Use a mail service API (SendGrid, Mailgun, etc.)
        // 2. Or integrate with system mail services
        // 3. Handle email delivery errors and retries
    }
    
    private func sendWebhookAlert(for alert: CrashAlert, report: CrashReport) throws {
        guard let webhookURL = alertConfiguration.webhookURL else {
            throw AlertingError.webhookNotConfigured
        }
        
        let webhookData = generateWebhookPayload(for: alert, report: report)
        
        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: webhookData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                Logger.error("Webhook alert failed: \(error)", category: .crash)
            } else if let httpResponse = response as? HTTPURLResponse {
                if 200...299 ~= httpResponse.statusCode {
                    Logger.info("Webhook alert sent successfully", category: .crash)
                } else {
                    Logger.error("Webhook alert failed with status: \(httpResponse.statusCode)", category: .crash)
                }
            }
        }.resume()
    }
    
    private func generateEmailContent(for alert: CrashAlert, report: CrashReport) -> String {
        return """
        Subject: \(alert.title)
        
        \(alert.message)
        
        Crash Details:
        - Type: \(report.crashType.rawValue)
        - Severity: \(report.severity.description)
        - App Version: \(report.applicationVersion)
        - Build: \(report.buildNumber)
        - System: \(report.systemVersion)
        - Device: \(report.deviceModel)
        - Time: \(DateFormatter.emailFormatter.string(from: report.timestamp))
        
        Error Message:
        \(report.errorMessage)
        
        Stack Trace:
        \(report.stackTrace.prefix(10).joined(separator: "\n"))
        
        Environment Info:
        \(report.environmentInfo.map { "\($0.key): \($0.value)" }.joined(separator: "\n"))
        """
    }
    
    private func generateWebhookPayload(for alert: CrashAlert, report: CrashReport) -> [String: Any] {
        return [
            "alert": [
                "id": alert.id.uuidString,
                "type": alert.type.rawValue,
                "severity": alert.severity.rawValue,
                "title": alert.title,
                "message": alert.message,
                "timestamp": ISO8601DateFormatter().string(from: alert.timestamp)
            ],
            "crash": [
                "id": report.id.uuidString,
                "type": report.crashType.rawValue,
                "severity": report.severity.rawValue,
                "errorMessage": report.errorMessage,
                "applicationVersion": report.applicationVersion,
                "buildNumber": report.buildNumber,
                "systemVersion": report.systemVersion,
                "deviceModel": report.deviceModel,
                "sessionId": report.sessionId,
                "timestamp": ISO8601DateFormatter().string(from: report.timestamp),
                "stackTrace": report.stackTrace,
                "environmentInfo": report.environmentInfo
            ]
        ]
    }
    
    private func updateAlertStatistics() {
        let now = Date()
        let dayAgo = now.addingTimeInterval(-86400)
        
        let recentAlerts = alertHistory.filter { $0.timestamp > dayAgo }
        
        let criticalCount = recentAlerts.filter { $0.severity == .critical }.count
        let errorCount = recentAlerts.filter { $0.severity == .error }.count
        let warningCount = recentAlerts.filter { $0.severity == .warning }.count
        let infoCount = recentAlerts.filter { $0.severity == .info }.count
        
        alertStatistics = AlertStatistics(
            totalAlerts24h: recentAlerts.count,
            criticalAlerts24h: criticalCount,
            errorAlerts24h: errorCount,
            warningAlerts24h: warningCount,
            infoAlerts24h: infoCount,
            lastAlert: alertHistory.first?.timestamp
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension CrashAlerting: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.info("User interacted with crash notification: \(response.actionIdentifier)", category: .crash)
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

// MARK: - Supporting Types

public struct CrashAlert: Codable, Identifiable {
    public var id = UUID()
    public let type: AlertType
    public let severity: AlertSeverity
    public let title: String
    public let message: String
    public let timestamp: Date
    public let crashId: UUID
    public let crashType: CrashType
    public let metadata: [String: String]
    
    public init(type: AlertType, severity: AlertSeverity, title: String, message: String, crashId: UUID, crashType: CrashType, metadata: [String: String]) {
        self.type = type
        self.severity = severity
        self.title = title
        self.message = message
        self.timestamp = Date()
        self.crashId = crashId
        self.crashType = crashType
        self.metadata = metadata
    }
}

public enum AlertType: String, CaseIterable, Codable {
    case criticalCrash = "critical_crash"
    case memoryIssue = "memory_issue"
    case performanceIssue = "performance_issue"
    case networkIssue = "network_issue"
    case securityIssue = "security_issue"
    case dataIntegrity = "data_integrity"
    case unknownIssue = "unknown_issue"
}

public enum AlertSeverity: String, CaseIterable, Codable {
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
}

public struct AlertConfiguration: Codable {
    public var enableLocalNotifications = true
    public var enableSystemAlerts = true
    public var enableEmailAlerts = false
    public var enableWebhookAlerts = false
    
    public var emailRecipients: [String] = []
    public var webhookURL: URL? = nil
    
    public var maxAlertsPerWindow = 5
    public var maxAlertHistory = 1000
    
    public var snoozeUntil: Date? = nil
    
    public var enabledAlerts: [AlertType: Bool] = [
        .criticalCrash: true,
        .memoryIssue: true,
        .performanceIssue: true,
        .networkIssue: false,
        .securityIssue: true,
        .dataIntegrity: true,
        .unknownIssue: false
    ]
    
    public init() {}
}

public struct AlertStatistics: Codable {
    public let totalAlerts24h: Int
    public let criticalAlerts24h: Int
    public let errorAlerts24h: Int
    public let warningAlerts24h: Int
    public let infoAlerts24h: Int
    public let lastAlert: Date?
    public let generatedAt: Date
    
    public init(
        totalAlerts24h: Int = 0,
        criticalAlerts24h: Int = 0,
        errorAlerts24h: Int = 0,
        warningAlerts24h: Int = 0,
        infoAlerts24h: Int = 0,
        lastAlert: Date? = nil
    ) {
        self.totalAlerts24h = totalAlerts24h
        self.criticalAlerts24h = criticalAlerts24h
        self.errorAlerts24h = errorAlerts24h
        self.warningAlerts24h = warningAlerts24h
        self.infoAlerts24h = infoAlerts24h
        self.lastAlert = lastAlert
        self.generatedAt = Date()
    }
}

public enum AlertingError: Error, LocalizedError {
    case webhookNotConfigured
    case notificationPermissionDenied
    case emailConfigurationInvalid
    
    public var errorDescription: String? {
        switch self {
        case .webhookNotConfigured:
            return "Webhook URL not configured"
        case .notificationPermissionDenied:
            return "Notification permission denied"
        case .emailConfigurationInvalid:
            return "Email configuration invalid"
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let emailFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()
}