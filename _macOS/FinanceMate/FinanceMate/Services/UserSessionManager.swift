

//
//  UserSessionManager.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: User session management for tracking authentication state and user activity in Sandbox environment
* Issues & Complexity Summary: Session lifecycle management with activity tracking and timeout handling
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~200
  - Core Algorithm Complexity: Medium
  - Dependencies: 3 New (SessionTracking, ActivityMonitoring, TimeoutManagement)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 65%
* Problem Estimate (Inherent Problem Difficulty %): 60%
* Initial Code Complexity Estimate %: 62%
* Justification for Estimates: Standard session management with timeout and activity tracking
* Final Code Complexity (Actual %): TBD - Implementation in progress
* Overall Result Score (Success & Quality %): TBD - TDD development
* Key Variances/Learnings: Robust session management with proper security considerations
* Last Updated: 2025-06-02
*/

import Foundation
import Combine

// MARK: - Supporting Types

public struct AuthenticatedUser: Codable {
    public let id: String
    public var email: String
    public var displayName: String
    public let provider: String
    public let isEmailVerified: Bool
    public let createdAt: Date
    
    public init(id: String, email: String, displayName: String, provider: String, isEmailVerified: Bool) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.provider = provider
        self.isEmailVerified = isEmailVerified
        self.createdAt = Date()
    }
}

// MARK: - User Session Manager

@MainActor
public class UserSessionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var currentSession: UserSession?
    @Published public var isSessionActive: Bool = false
    @Published public var lastActivityDate: Date?
    @Published public var sessionDuration: TimeInterval = 0
    
    // MARK: - Private Properties
    
    private var sessionTimer: Timer?
    private var activityTimer: Timer?
    private let sessionTimeout: TimeInterval = 3600 // 1 hour
    private let activityCheckInterval: TimeInterval = 60 // 1 minute
    private var cancellables = Set<AnyCancellable>()
    
    // Session callbacks
    public var onSessionExpired: (() -> Void)?
    public var onSessionWarning: ((TimeInterval) -> Void)?
    
    // MARK: - Initialization
    
    public init() {
        setupSessionMonitoring()
        loadExistingSession()
    }
    
    // MARK: - Session Management
    
    public func createSession(for user: AuthenticatedUser) async {
        let session = UserSession(
            id: UUID().uuidString,
            user: user,
            startTime: Date(),
            lastActivityTime: Date(),
            isActive: true
        )
        
        currentSession = session
        isSessionActive = true
        lastActivityDate = Date()
        
        startSessionTimer()
        startActivityMonitoring()
        saveSession(session)
        
        logSessionEvent(.sessionStarted, for: session)
    }
    
    public func refreshActivity() {
        guard var session = currentSession else { return }
        
        let now = Date()
        session.lastActivityTime = now
        session.activityCount += 1
        
        currentSession = session
        lastActivityDate = now
        
        saveSession(session)
        
        // Reset session timer if we're close to timeout
        let timeSinceLastActivity = now.timeIntervalSince(session.lastActivityTime)
        if timeSinceLastActivity > (sessionTimeout * 0.8) {
            resetSessionTimer()
        }
    }
    
    public func extendSession() async {
        guard var session = currentSession else { return }
        
        let now = Date()
        session.lastActivityTime = now
        session.extensionCount += 1
        
        currentSession = session
        lastActivityDate = now
        
        resetSessionTimer()
        saveSession(session)
        
        logSessionEvent(.sessionExtended, for: session)
    }
    
    public func clearSession() async {
        if let session = currentSession {
            logSessionEvent(.sessionEnded, for: session)
        }
        
        stopSessionTimer()
        stopActivityMonitoring()
        
        currentSession = nil
        isSessionActive = false
        lastActivityDate = nil
        sessionDuration = 0
        
        UserDefaults.standard.removeObject(forKey: sessionStorageKey)
    }
    
    // MARK: - Session Validation
    
    public func validateSession() async -> Bool {
        guard let session = currentSession else { return false }
        
        let now = Date()
        let timeSinceLastActivity = now.timeIntervalSince(session.lastActivityTime)
        
        if timeSinceLastActivity > sessionTimeout {
            await expireSession()
            return false
        }
        
        return session.isActive
    }
    
    public func getRemainingSessionTime() async -> TimeInterval {
        guard let session = currentSession else { return 0 }
        
        let timeSinceLastActivity = Date().timeIntervalSince(session.lastActivityTime)
        return max(0, sessionTimeout - timeSinceLastActivity)
    }
    
    public func getSessionDuration() -> TimeInterval {
        guard let session = currentSession else { return 0 }
        return Date().timeIntervalSince(session.startTime)
    }
    
    // MARK: - Session Analytics
    
    public func getSessionAnalytics() async -> SessionAnalytics? {
        guard let session = currentSession else { return nil }
        
        let duration = getSessionDuration()
        let averageActivityInterval = duration / Double(max(session.activityCount, 1))
        
        return SessionAnalytics(
            sessionId: session.id,
            totalDuration: duration,
            activityCount: session.activityCount,
            extensionCount: session.extensionCount,
            averageActivityInterval: averageActivityInterval,
            isActive: session.isActive
        )
    }
    
    // MARK: - Private Methods
    
    private func setupSessionMonitoring() {
        // Monitor session duration
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateSessionDuration()
            }
            .store(in: &cancellables)
    }
    
    private func loadExistingSession() {
        guard let sessionData = UserDefaults.standard.data(forKey: sessionStorageKey),
              let session = try? JSONDecoder().decode(UserSession.self, from: sessionData) else {
            return
        }
        
        // Check if session is still valid
        let now = Date()
        let timeSinceLastActivity = now.timeIntervalSince(session.lastActivityTime)
        
        if timeSinceLastActivity <= sessionTimeout && session.isActive {
            currentSession = session
            isSessionActive = true
            lastActivityDate = session.lastActivityTime
            
            startSessionTimer()
            startActivityMonitoring()
            
            logSessionEvent(.sessionRestored, for: session)
        } else {
            // Session expired, clear it
            UserDefaults.standard.removeObject(forKey: sessionStorageKey)
        }
    }
    
    private func saveSession(_ session: UserSession) {
        do {
            let sessionData = try JSONEncoder().encode(session)
            UserDefaults.standard.set(sessionData, forKey: sessionStorageKey)
        } catch {
            print("Failed to save session: \(error)")
        }
    }
    
    private func startSessionTimer() {
        stopSessionTimer()
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: sessionTimeout, repeats: false) { [weak self] _ in
            Task { @MainActor in
                await self?.expireSession()
            }
        }
    }
    
    private func stopSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }
    
    private func resetSessionTimer() {
        startSessionTimer()
    }
    
    private func startActivityMonitoring() {
        stopActivityMonitoring()
        
        activityTimer = Timer.scheduledTimer(withTimeInterval: activityCheckInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkForSessionWarning()
            }
        }
    }
    
    private func stopActivityMonitoring() {
        activityTimer?.invalidate()
        activityTimer = nil
    }
    
    private func updateSessionDuration() {
        if let session = currentSession {
            sessionDuration = Date().timeIntervalSince(session.startTime)
        }
    }
    
    private func checkForSessionWarning() async {
        let remainingTime = await getRemainingSessionTime()
        
        // Warn when 5 minutes remaining
        if remainingTime <= 300 && remainingTime > 240 {
            onSessionWarning?(remainingTime)
        }
    }
    
    private func expireSession() async {
        if let session = currentSession {
            logSessionEvent(.sessionExpired, for: session)
        }
        
        await clearSession()
        onSessionExpired?()
    }
    
    private func logSessionEvent(_ event: SessionEvent, for session: UserSession) {
        _ = SessionLogEntry(
            event: event,
            sessionId: session.id,
            userId: session.user.id,
            timestamp: Date()
        )
        
        // In a real implementation, this would be logged to analytics
        print("Session Event: \(event.rawValue) for session \(session.id)")
    }
    
    private var sessionStorageKey: String {
        return "current_user_session"
    }
}

// MARK: - Supporting Data Models

public struct UserSession: Codable {
    public let id: String
    public let user: AuthenticatedUser
    public let startTime: Date
    public var lastActivityTime: Date
    public var isActive: Bool
    public var activityCount: Int
    public var extensionCount: Int
    
    public init(id: String, user: AuthenticatedUser, startTime: Date, lastActivityTime: Date, isActive: Bool) {
        self.id = id
        self.user = user
        self.startTime = startTime
        self.lastActivityTime = lastActivityTime
        self.isActive = isActive
        self.activityCount = 1
        self.extensionCount = 0
    }
}

public struct SessionAnalytics {
    public let sessionId: String
    public let totalDuration: TimeInterval
    public let activityCount: Int
    public let extensionCount: Int
    public let averageActivityInterval: TimeInterval
    public let isActive: Bool
    
    public init(sessionId: String, totalDuration: TimeInterval, activityCount: Int, extensionCount: Int, averageActivityInterval: TimeInterval, isActive: Bool) {
        self.sessionId = sessionId
        self.totalDuration = totalDuration
        self.activityCount = activityCount
        self.extensionCount = extensionCount
        self.averageActivityInterval = averageActivityInterval
        self.isActive = isActive
    }
}

public struct SessionLogEntry {
    public let event: SessionEvent
    public let sessionId: String
    public let userId: String
    public let timestamp: Date
    
    public init(event: SessionEvent, sessionId: String, userId: String, timestamp: Date) {
        self.event = event
        self.sessionId = sessionId
        self.userId = userId
        self.timestamp = timestamp
    }
}

public enum SessionEvent: String, CaseIterable {
    case sessionStarted = "session_started"
    case sessionEnded = "session_ended"
    case sessionExpired = "session_expired"
    case sessionExtended = "session_extended"
    case sessionRestored = "session_restored"
    case activityDetected = "activity_detected"
    case warningShown = "warning_shown"
    
    public var displayName: String {
        switch self {
        case .sessionStarted:
            return "Session Started"
        case .sessionEnded:
            return "Session Ended"
        case .sessionExpired:
            return "Session Expired"
        case .sessionExtended:
            return "Session Extended"
        case .sessionRestored:
            return "Session Restored"
        case .activityDetected:
            return "Activity Detected"
        case .warningShown:
            return "Warning Shown"
        }
    }
}