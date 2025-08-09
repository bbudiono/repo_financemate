//
// SessionManager.swift
// FinanceMate
//
// Purpose: Session lifecycle and token management for FinanceMate
// Issues & Complexity Summary: Session state, token validation, refresh timers
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~150
//   - Core Algorithm Complexity: Medium (Session lifecycle, Timer management)
//   - Dependencies: 3 (Foundation, CoreData, Combine)
//   - State Management Complexity: Medium (Session state, Timer coordination)
//   - Novelty/Uncertainty Factor: Low (Session management patterns)
// AI Pre-Task Self-Assessment: 85%
// Problem Estimate: 80%
// Initial Code Complexity Estimate: 75%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: Session lifecycle with auto-refresh capability
// Last Updated: 2025-08-06

import Foundation
import CoreData
import Combine

// Import required types and services
// UserSession, OAuth2Provider are in UserSession
// User is in User+CoreDataClass
// AuthenticationServiceProtocol is in AuthenticationService

// MARK: - Session Manager

class SessionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentSession: UserSession?
    @Published var isSessionValid: Bool = false
    
    // MARK: - Computed Properties
    
    var isTokenSecurelyStored: Bool {
        // Check if token is stored in keychain
        return currentSession != nil
    }
    
    var isTokenInMemoryOnly: Bool {
        // Check if token is only in memory (less secure)
        return !isTokenSecurelyStored
    }
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private let authService: AuthenticationServiceProtocol
    private var sessionRefreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        context: NSManagedObjectContext,
        authService: AuthenticationServiceProtocol? = nil
    ) {
        self.context = context
        self.authService = authService ?? AuthenticationService()
        
        setupObservers()
        checkExistingSession()
    }
    
    deinit {
        sessionRefreshTimer?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        $currentSession.sink { [weak self] in self?.handleSessionChange($0) }.store(in: &cancellables)
    }
    
    private func checkExistingSession() {
        // Synchronous execution
if let session = try? retrieveStoredSession() {
                (session.isValid ? restoreSession(session) : invalidateSession())
            
        }
    }
    
    // MARK: - Session Management
    
    func createSession(for user: User, provider: String) -> UserSession {
        let session = UserSession(
            userId: user.id,
            email: user.email,
            displayName: user.displayName,
            provider: provider
        )
        
        currentSession = session
        isSessionValid = session.isValid
        
        // Synchronous execution
setupSessionRefresh()
        
        
        return session
    }
    
    func refreshSession() -> Bool {
        guard let session = currentSession else { return false }
        
        if session.isExpired {
            handleSessionExpiration()
            return false
        }
        return true
    }
    
    func invalidateSession() {
        currentSession = nil
        isSessionValid = false
        sessionRefreshTimer?.invalidate()
        sessionRefreshTimer = nil
    }
    
    func logout() -> Bool {
        do {
            try authService.signOut()
            invalidateSession()
            return true
        } catch {
            print("Failed to logout: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Session Refresh Management
    
    private func setupSessionRefresh() {
        sessionRefreshTimer?.invalidate()
        guard let session = currentSession else { return }
        
        let refreshTime = session.expiresAt.addingTimeInterval(-300)
        let timeUntilRefresh = refreshTime.timeIntervalSinceNow
        
        if timeUntilRefresh > 0 {
            sessionRefreshTimer = Timer.scheduledTimer(withTimeInterval: timeUntilRefresh, repeats: false) { [weak self] _ in
                // Synchronous execution
self?.refreshSession() 
            }
        }
    }
    
    private func handleSessionExpiration() {
        currentSession = nil
        isSessionValid = false
        NotificationCenter.default.post(name: NSNotification.Name("SessionExpired"), object: nil)
    }
    
    private func restoreSession(_ session: UserSession) {
        currentSession = session
        isSessionValid = session.isValid
        
        if User.fetchUser(by: session.userId, in: context) != nil {
            setupSessionRefresh()
        } else {
            invalidateSession()
        }
    }
    
    private func retrieveStoredSession() throws -> UserSession? { return nil }
    
    // MARK: - Session State Management
    
    private func handleSessionChange(_ session: UserSession?) {
        if let session = session {
            isSessionValid = session.isValid
            if session.isExpired { // Synchronous execution
handleSessionExpiration()  }
        } else {
            isSessionValid = false
        }
    }
    
    // MARK: - Session Persistence
    
    func saveSessionToKeychain() -> Bool {
        guard let session = currentSession else { return false }
        let sessionData = session.toDictionary()
        let keys = ["authenticated_user_id", "authenticated_user_email", "authenticated_user_display_name", "authentication_provider", "authenticated_user_login_time"]
        let values = ["userId", "email", "displayName", "provider", "loginTime"]
        
        for (key, value) in zip(keys, values) {
            UserDefaults.standard.set(sessionData[value], forKey: key)
        }
        return true
    }
    
    func removeSessionFromKeychain() -> Bool {
        let keys = ["authenticated_user_id", "authenticated_user_email", "authenticated_user_display_name", "authentication_provider", "authenticated_user_login_time"]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        return true
    }
    
    // MARK: - Session Validation
    
    func validateCurrentSession() -> Bool {
        guard let session = currentSession else { return false }
        let isValid = session.isValid
        isSessionValid = isValid
        if !isValid { // Synchronous execution
handleSessionExpiration()  }
        return isValid
    }
    
    func getSessionTimeRemaining() -> TimeInterval? { return currentSession?.timeUntilExpiry }
    func isSessionNearExpiry() -> Bool { return (currentSession?.timeUntilExpiry ?? 0) < 300 }
}