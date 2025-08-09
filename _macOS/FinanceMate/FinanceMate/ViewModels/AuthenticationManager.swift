//
// AuthenticationManager.swift
// FinanceMate
//
// Purpose: Core authentication logic and OAuth flows for FinanceMate
// Issues & Complexity Summary: Authentication state management, OAuth 2.0, MFA
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~180
//   - Core Algorithm Complexity: High (Authentication flow, OAuth providers)
//   - Dependencies: 4 (Foundation, CoreData, Combine, AuthenticationServices)
//   - State Management Complexity: High (Authentication state transitions)
//   - Novelty/Uncertainty Factor: Medium (OAuth 2.0 flows)
// AI Pre-Task Self-Assessment: 80%
// Problem Estimate: 85%
// Initial Code Complexity Estimate: 82%
// Final Code Complexity: 78%
// Overall Result Score: 94%
// Key Variances/Learnings: Focused authentication flow management
// Last Updated: 2025-08-06

import Foundation
import CoreData
import Combine
import AuthenticationServices

// Import required types and services
// AuthenticationResult, AuthenticationServiceProtocol are in AuthenticationService
// OAuth2Provider, UserSession are in UserSession 
// User is in User+CoreDataClass
// AuthenticationState is in AuthenticationState

// MARK: - Authentication Manager

class AuthenticationManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var isLoading: Bool = false
    @Published var isMFARequired: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var isAuthenticated: Bool {
        switch authenticationState {
        case .authenticated:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private let authService: AuthenticationServiceProtocol
    
    // MARK: - Initialization
    
    init(
        context: NSManagedObjectContext,
        authService: AuthenticationServiceProtocol? = nil
    ) {
        self.context = context
        self.authService = authService ?? AuthenticationService()
    }
    
    // MARK: - Authentication Methods
    
    func authenticate(email: String, password: String) -> (user: User?, session: UserSession?, error: String?) {
        setLoading(true)
        clearError()
        
        do {
            authenticationState = .authenticating
            
            let result = try (authService as! AuthenticationService).authenticateWithEmail(email: email, password: password)
            
            if let user = result.user {
                let session = UserSession(
                    userId: user.id,
                    email: user.email,
                    displayName: user.displayName,
                    provider: result.provider.rawValue
                )
                
                authenticationState = .authenticated
                isMFARequired = false
                setLoading(false)
                
                return (user: user, session: session, error: nil)
            } else {
                throw AuthenticationError.invalidResponse("No user returned")
            }
            
        } catch {
            handleAuthenticationError(error)
            setLoading(false)
            return (user: nil, session: nil, error: error.localizedDescription)
        }
    }
    
    func authenticateWithOAuth2(provider: OAuth2Provider) -> (user: User?, session: UserSession?, error: String?) {
        setLoading(true)
        clearError()
        
        do {
            authenticationState = .authenticating
            let result = try performOAuthAuthentication(provider: provider)
            
            if result.success, let user = result.user {
                let session = createSession(for: user, provider: result.provider.rawValue)
                authenticationState = .authenticated
                isMFARequired = false
                setLoading(false)
                return (user: user, session: session, error: nil)
            } else {
                let errorMsg = result.error?.localizedDescription ?? "Authentication failed"
                authenticationState = .error(errorMsg)
                errorMessage = errorMsg
                setLoading(false)
                return (user: nil, session: nil, error: errorMsg)
            }
        } catch {
            handleAuthenticationError(error)
            setLoading(false)
            return (user: nil, session: nil, error: error.localizedDescription)
        }
    }
    
    private func performOAuthAuthentication(provider: OAuth2Provider) throws -> AuthenticationResult {
        let authService = AuthenticationService()
        
        switch provider {
        case .apple:
            return try authService.authenticateWithApple()
        case .google:
            return try authService.authenticateWithGoogle()
        case .microsoft:
            throw AuthenticationError.notImplemented("Microsoft SSO not yet implemented")
        case .github:
            throw AuthenticationError.notImplemented("GitHub SSO not yet implemented")
        }
    }
    
    func verifyMFACode(_ code: String) -> (success: Bool, error: String?) {
        setLoading(true)
        clearError()
        
        do {
            // TODO: Implement verifyMFACode in AuthenticationService
            let isValid = false // Placeholder until MFA is implemented
            
            if isValid {
                authenticationState = .authenticated
                isMFARequired = false
                setLoading(false)
                return (success: true, error: nil)
            } else {
                setError("Invalid verification code")
                setLoading(false)
                return (success: false, error: "Invalid verification code")
            }
            
        } catch {
            handleAuthenticationError(error)
            setLoading(false)
            return (success: false, error: error.localizedDescription)
        }
    }
    
    func authenticateWithBiometrics() -> (user: User?, session: UserSession?, error: String?) {
        return performAuthentication { [weak self] in
            guard let self = self else { throw AuthenticationError.failed("Invalid state") }
            return try self.authService.authenticateWithBiometrics()
        }
    }
    
    // MARK: - Apple Sign-In Direct Processing
    
    func processAppleSignInCompletion(_ authorization: ASAuthorization) -> (user: User?, session: UserSession?, error: String?) {
        print("🍎 AuthenticationManager: processAppleSignInCompletion called")
        setLoading(true)
        clearError()
        
        do {
            authenticationState = .authenticating
            let user = try processAppleCredential(authorization)
            let session = createSession(for: user, provider: OAuth2Provider.apple.rawValue)
            
            authenticationState = .authenticated
            isMFARequired = false
            setLoading(false)
            
            return (user: user, session: session, error: nil)
        } catch {
            handleAuthenticationError(error)
            setLoading(false)
            return (user: nil, session: nil, error: error.localizedDescription)
        }
    }
    
    private func processAppleCredential(_ authorization: ASAuthorization) throws -> User {
        print("🍎 DEBUG: Starting processAppleCredential")
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ ERROR: Invalid Apple ID credential type")
            throw AuthenticationError.invalidResponse("Invalid Apple ID credential")
        }
        
        let userIdentifier = appleIDCredential.user
        let email = appleIDCredential.email ?? "\(userIdentifier)@privaterelay.appleid.com"
        let displayName = extractDisplayName(from: appleIDCredential.fullName)
        
        print("🍎 DEBUG: Apple credential data - ID: \(userIdentifier), Email: \(email), Name: \(displayName)")
        
        do {
            print("🍎 DEBUG: Attempting to find or create user")
            let user = try findOrCreateUser(email: email, displayName: displayName)
            print("🍎 DEBUG: User found/created successfully: \(user.id)")
            
            print("🍎 DEBUG: Attempting to save Core Data context")
            try context.save()
            print("🍎 DEBUG: Core Data context saved successfully")
            
            return user
        } catch {
            print("❌ CRITICAL ERROR in processAppleCredential: \(error)")
            print("❌ ERROR TYPE: \(type(of: error))")
            print("❌ ERROR LOCALIZED: \(error.localizedDescription)")
            
            // Enhanced error details for Core Data errors
            if let nsError = error as NSError? {
                print("❌ NSError Code: \(nsError.code)")
                print("❌ NSError Domain: \(nsError.domain)")
                print("❌ NSError UserInfo: \(nsError.userInfo)")
                
                // Check for Core Data specific errors
                if nsError.domain == NSCocoaErrorDomain {
                    switch nsError.code {
                    case NSManagedObjectValidationError:
                        print("❌ Core Data Validation Error")
                    case NSValidationMissingMandatoryPropertyError:
                        print("❌ Missing Mandatory Property Error")
                    case NSCoreDataError:
                        print("❌ Generic Core Data Error")
                    default:
                        print("❌ Unknown Core Data Error Code: \(nsError.code)")
                    }
                }
            }
            
            throw error
        }
    }
    
    private func extractDisplayName(from fullName: PersonNameComponents?) -> String {
        guard let fullName = fullName else { return "Apple User" }
        
        let nameComponents = [fullName.givenName, fullName.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        return nameComponents.isEmpty ? "Apple User" : nameComponents
    }
    
    private func findOrCreateUser(email: String, displayName: String) throws -> User {
        print("🔍 DEBUG: Starting findOrCreateUser - Email: \(email), Name: \(displayName)")
        
        // First, verify Core Data setup inline
        print("🍎 APPLE SSO CORE DATA VALIDATION")
        
        // Check if User entity exists in model
        let entities = context.persistentStoreCoordinator?.managedObjectModel.entities ?? []
        let userEntityExists = entities.contains { $0.name == "User" }
        print("📊 DEBUG: User entity exists in model: \(userEntityExists)")
        print("📊 DEBUG: Available entities: \(entities.compactMap(\.name))")
        
        if !userEntityExists {
            print("❌ CRITICAL: User entity not found in Core Data model")
            throw AuthenticationError.failed("Core Data User entity not properly configured")
        }
        
        print("✅ DEBUG: Core Data User entity validation passed")
        
        do {
            // Check if user already exists
            print("🔍 DEBUG: Checking for existing user with email: \(email)")
            if let existingUser = User.fetchUser(by: email, in: context) {
                print("✅ DEBUG: Found existing user with ID: \(existingUser.id)")
                existingUser.name = displayName
                existingUser.updateLastLogin()
                existingUser.activate()
                print("✅ DEBUG: Updated existing user successfully")
                return existingUser
            } else {
                print("🆕 DEBUG: No existing user found, creating new user")
                
                // Validate Core Data model has User entity
                let entities = context.persistentStoreCoordinator?.managedObjectModel.entities ?? []
                let userEntityExists = entities.contains { $0.name == "User" }
                print("📊 DEBUG: User entity exists in model: \(userEntityExists)")
                print("📊 DEBUG: Available entities: \(entities.compactMap(\.name))")
                
                if !userEntityExists {
                    print("❌ CRITICAL: User entity not found in Core Data model")
                    throw AuthenticationError.failed("User entity not configured in Core Data model")
                }
                
                let user = User.create(in: context, name: displayName, email: email, role: .owner)
                print("✅ DEBUG: Created new user with ID: \(user.id)")
                
                user.activate()
                print("✅ DEBUG: Activated new user account")
                
                // Validate user data before returning
                let validation = user.validate()
                if !validation.isValid {
                    print("❌ ERROR: User validation failed: \(validation.errors)")
                    throw AuthenticationError.failed("User validation failed: \(validation.errors.joined(separator: ", "))")
                }
                print("✅ DEBUG: User validation passed")
                
                return user
            }
        } catch {
            print("❌ ERROR in findOrCreateUser: \(error)")
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    private func performAuthentication(authenticator: () throws -> AuthenticationResult) -> (user: User?, session: UserSession?, error: String?) {
        setLoading(true)
        clearError()
        
        do {
            authenticationState = .authenticating
            let result = try authenticator()
            
            if let user = result.user {
                let session = createSession(for: user, provider: result.provider.rawValue)
                authenticationState = .authenticated
                isMFARequired = false
                setLoading(false)
                return (user: user, session: session, error: nil)
            } else {
                throw AuthenticationError.invalidResponse("No user returned")
            }
        } catch {
            handleAuthenticationError(error)
            setLoading(false)
            return (user: nil, session: nil, error: error.localizedDescription)
        }
    }
    
    private func createSession(for user: User, provider: String) -> UserSession {
        return UserSession(
            userId: user.id,
            email: user.email,
            displayName: user.displayName,
            provider: provider
        )
    }
    
    private func handleAuthenticationError(_ error: Error) {
        let message = (error as? AuthenticationError)?.localizedDescription ?? "Authentication failed: \(error.localizedDescription)"
        setError(message)
        authenticationState = .unauthenticated
    }
    
    private func setLoading(_ loading: Bool) { isLoading = loading }
    private func setError(_ message: String) { errorMessage = message }
    private func clearError() { errorMessage = nil }
}