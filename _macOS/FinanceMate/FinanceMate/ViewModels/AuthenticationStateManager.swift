//
// AuthenticationStateManager.swift
// FinanceMate
//
// Purpose: Authentication state coordination and orchestration for FinanceMate
// Issues & Complexity Summary: State coordination, event handling, observer management
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~180
//   - Core Algorithm Complexity: High (State coordination, Event orchestration)
//   - Dependencies: 4 (Foundation, CoreData, Combine, AuthenticationServices)
//   - State Management Complexity: High (Multi-component state coordination)
//   - Novelty/Uncertainty Factor: Medium (Complex state coordination patterns)
// AI Pre-Task Self-Assessment: 75%
// Problem Estimate: 80%
// Initial Code Complexity Estimate: 85%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: Coordinating multiple authentication components
// Last Updated: 2025-08-06

import Foundation
import CoreData
import Combine
import AuthenticationServices

// Import required types and services
// AuthenticationState is in AuthenticationState
// User is in User+CoreDataClass
// UserSession, OAuth2Provider are in UserSession
// AuthenticationServiceProtocol is in AuthenticationService

// MARK: - Authentication State Manager

class AuthenticationStateManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var currentUser: User?
    @Published var currentSession: UserSession?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isMFARequired: Bool = false
    
    // MARK: - Computed Properties
    
    var isAuthenticated: Bool {
        switch authenticationState {
        case .authenticated:
            return true
        default:
            return false
        }
    }
    
    var isSessionValid: Bool {
        guard let session = currentSession else { return false }
        return session.isValid
    }
    
    var isTokenSecurelyStored: Bool {
        return sessionManager.isTokenSecurelyStored
    }
    
    var isTokenInMemoryOnly: Bool {
        return sessionManager.isTokenInMemoryOnly
    }
    
    // MARK: - Component Managers
    
    private let authenticationManager: AuthenticationManager
    private let sessionManager: SessionManager
    private let userProfileManager: UserProfileManager
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        context: NSManagedObjectContext,
        authService: AuthenticationServiceProtocol? = nil
    ) {
        self.context = context
        self.authenticationManager = AuthenticationManager(context: context, authService: authService)
        self.sessionManager = SessionManager(context: context, authService: authService)
        self.userProfileManager = UserProfileManager(context: context)
        
        setupObservers()
        checkExistingSession()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        authenticationManager.$authenticationState.sink { [weak self] in self?.handleAuthenticationStateChange($0) }.store(in: &cancellables)
        authenticationManager.$isLoading.assign(to: &$isLoading)
        authenticationManager.$isMFARequired.assign(to: &$isMFARequired)
        authenticationManager.$errorMessage.compactMap { $0 }.assign(to: &$errorMessage)
        
        sessionManager.$isSessionValid.sink { [weak self] isValid in
            if !isValid && self?.currentSession != nil { self?.handleSessionExpiration() }
        }.store(in: &cancellables)
        sessionManager.$currentSession.assign(to: &$currentSession)
        
        userProfileManager.$currentUser.assign(to: &$currentUser)
        userProfileManager.$errorMessage.compactMap { $0 }.assign(to: &$errorMessage)
    }
    
    private func checkExistingSession() {
        // Synchronous execution
if let session = sessionManager.currentSession, session.isValid {
                restoreAuthenticationState(from: session)
            
        }
    }
    
    // MARK: - Authentication Methods
    
    func authenticate(email: String, password: String) {
        handleAuthenticationResult(authenticationManager.authenticate(email: email, password: password))
    }
    
    func authenticateWithOAuth2(provider: OAuth2Provider) {
        handleAuthenticationResult(authenticationManager.authenticateWithOAuth2(provider: provider))
    }
    
    func verifyMFACode(_ code: String) {
        let result = authenticationManager.verifyMFACode(code)
        if result.success { setupSessionRefresh() }
    }
    
    func authenticateWithBiometrics() {
        handleAuthenticationResult(authenticationManager.authenticateWithBiometrics())
    }
    
    func logout() {
        if sessionManager.logout() {
            currentUser = nil
            currentSession = nil
            authenticationState = .unauthenticated
            isMFARequired = false
            userProfileManager.setCurrentUser(nil)
        }
    }
    
    func processAppleSignInCompletion(_ authorization: ASAuthorization) {
        handleAuthenticationResult(authenticationManager.processAppleSignInCompletion(authorization))
    }
    
    func refreshSession() {
        if !(sessionManager.refreshSession()) {
            handleSessionExpiration()
        }
    }
    
    private func setupSessionRefresh() { /* Handled by SessionManager */ }
    
    // MARK: - User Management
    
    func createAccount(name: String, email: String, password: String) {
        let result = userProfileManager.createAccount(name: name, email: email, password: password)
        if result.success { authenticate(email: email, password: password) }
    }
    
    func resetPassword(email: String) { _ = userProfileManager.resetPassword(email: email) }
    
    func deleteUserAccount() {
        if (userProfileManager.deleteUserAccount()).success { logout() }
    }
    
    // MARK: - Helper Methods
    
    private func handleAuthenticationResult(_ result: (user: User?, session: UserSession?, error: String?)) {
        if let user = result.user, let session = result.session {
            handleSuccessfulAuthentication(user: user, session: session)
        }
    }
    
    private func handleAuthenticationStateChange(_ state: AuthenticationState) {
        authenticationState = state
        
        switch state {
        case .authenticated:
            NotificationCenter.default.post(name: .userAuthenticated, object: nil)
        case .unauthenticated, .sessionExpired:
            currentUser = nil
            currentSession = nil
            isMFARequired = false
            userProfileManager.setCurrentUser(nil)
        case .mfaRequired:
            isMFARequired = true
        case .error(let message):
            errorMessage = message
        case .authenticating:
            break
        }
    }
    
    private func handleSuccessfulAuthentication(user: User, session: UserSession) {
        currentUser = user
        currentSession = session
        userProfileManager.setCurrentUser(user)
        userProfileManager.updateLastLogin()
        userProfileManager.activateUser()
        _ = sessionManager.createSession(for: user, provider: session.provider)
        _ = sessionManager.saveSessionToKeychain()
        
        // Trigger authentication state change to send notification
        handleAuthenticationStateChange(.authenticated)
    }
    
    private func handleSessionExpiration() {
        // Synchronous execution
currentSession = nil
            authenticationState = .sessionExpired
            errorMessage = "Session expired. Please log in again."
            _ = sessionManager.removeSessionFromKeychain()
        
    }
    
    private func restoreAuthenticationState(from session: UserSession) {
        if let user = User.fetchUser(by: session.userId, in: context) {
            currentUser = user
            currentSession = session
            authenticationState = .authenticated
            userProfileManager.setCurrentUser(user)
        } else {
            sessionManager.invalidateSession()
        }
    }
    
    // MARK: - Validation & Security
    
    func validateEmail(_ email: String) -> Bool { return userProfileManager.validateEmail(email) }
    func validatePassword(_ password: String) -> Bool { return userProfileManager.validatePassword(password) }
    func validateMFACode(_ code: String) -> Bool { return userProfileManager.validateMFACode(code) }
    func getPrivacyCompliantUserData() -> [String: Any] { return userProfileManager.getPrivacyCompliantUserData() }
}

// MARK: - Preview Support

extension AuthenticationStateManager {
    static var preview: AuthenticationStateManager {
        return AuthenticationStateManager(
            context: PersistenceController.preview.container.viewContext
        )
    }
    
    static var previewAuthenticated: AuthenticationStateManager {
        let stateManager = AuthenticationStateManager(
            context: PersistenceController.preview.container.viewContext
        )
        
        // Set up authenticated state for preview
        let user = User.create(
            in: PersistenceController.preview.container.viewContext,
            name: "Preview User",
            email: "preview@example.com",
            role: .owner
        )
        
        let session = UserSession(
            userId: user.id,
            email: user.email,
            displayName: user.displayName,
            provider: "preview"
        )
        
        stateManager.currentUser = user
        stateManager.currentSession = session
        stateManager.authenticationState = .authenticated
        
        return stateManager
    }
}