// Purpose: Simple Apple Sign In implementation using AuthenticationServices.
// Issues & Complexity: Minimal implementation for Apple SSO.
// Ranking/Rating: 95% (Code), 90% (Problem) - Simple implementation.

import SwiftUI
import AuthenticationServices
import Foundation
import CryptoKit

/// Protocol to represent the properties of an ASAuthorizationAppleIDCredential for testability
public protocol AppleIDCredentialRepresentable {
    var user: String { get }
    var fullName: PersonNameComponents? { get }
    var email: String? { get }
    var identityToken: Data? { get }
    var authorizationCode: Data? { get }
    // Add other properties like realUserStatus if needed
}

// Extend the actual ASAuthorizationAppleIDCredential to conform to our protocol
extension ASAuthorizationAppleIDCredential: AppleIDCredentialRepresentable {}

/// Core Apple authentication provider implementation
public class AppleAuthProvider: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    // Simplified public API
    public var onSignIn: ((ASAuthorizationAppleIDCredential) -> Void)?
    public var onError: ((Error) -> Void)?
    
    // Callbacks expected by AppleSignInView
    public var onSignInSuccess: ((_ userIdentifier: String, _ fullName: String?, _ email: String?) -> Void)?
    public var onSignInFailure: ((String) -> Void)?
    
    internal var currentNonce: String?
    
    public override init() {
        super.init()
    }
    
    public func signIn() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    public func signOut() {
        // Apple doesn't provide a signout method for Sign in with Apple
        // This is just a stub - real implementation would clear locally stored tokens
        print("User signed out from Apple")
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            let error = NSError(domain: "AppleSignIn", code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid credential"])
            handleFailedAuthorization(error)
            return
        }
        handleSuccessfulAuthorization(appleIDCredential)
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        handleFailedAuthorization(error)
    }
    
    // MARK: - Internal Logic Handlers (for testability)

    internal func handleSuccessfulAuthorization(_ appleIDCredential: AppleIDCredentialRepresentable) {
        // If the original onSignIn callback expects the concrete type, we might need to reconsider,
        // or ensure that the information passed to onSignInSuccess is sufficient.
        // For now, let's assume onSignIn is for internal/flexible use or can be adapted.
        // If onSignIn strictly needs ASAuthorizationAppleIDCredential, this refactor won't directly work for it.
        // However, the primary goal is to test the logic that extracts and uses the credential's properties.

        // Attempt to cast back if the onSignIn callback specifically needs the concrete type.
        // This is a bit of a workaround. A better approach might be for onSignIn itself
        // to accept the protocol, or to have a different callback for the processed data.
        if let concreteCredential = appleIDCredential as? ASAuthorizationAppleIDCredential {
            onSignIn?(concreteCredential)
        }

        let userIdentifier = appleIDCredential.user
        var fullName: String? = nil
        if let nameComponents = appleIDCredential.fullName {
            var parts: [String] = []
            if let givenName = nameComponents.givenName, !givenName.isEmpty { parts.append(givenName) }
            if let familyName = nameComponents.familyName, !familyName.isEmpty { parts.append(familyName) }
            if !parts.isEmpty {
                fullName = parts.joined(separator: " ")
            }
        }
        let email = appleIDCredential.email
        
        // TODO: Securely store identityToken and authorizationCode if available
        // let identityToken = appleIDCredential.identityToken
        // let authorizationCode = appleIDCredential.authorizationCode

        onSignInSuccess?(userIdentifier, fullName, email)
    }

    internal func handleFailedAuthorization(_ error: Error) {
        print("Sign in with Apple failed: \(error.localizedDescription)")
        onError?(error)
        onSignInFailure?(error.localizedDescription)
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = NSApplication.shared.windows.first else {
            fatalError("No window available for presentation")
        }
        return window
    }
    
    // MARK: - Helper Methods
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
} 
