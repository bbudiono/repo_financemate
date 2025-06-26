// Purpose: Simple Apple Sign In implementation using AuthenticationServices.
// Issues & Complexity: Minimal implementation for Apple SSO.
// Ranking/Rating: 95% (Code), 90% (Problem) - Simple implementation.

import SwiftUI
import AuthenticationServices
import Foundation
import CryptoKit

/// Core Apple authentication provider implementation
public class AppleAuthProviderSandbox: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    // Simplified public API
    public var onSignIn: ((ASAuthorizationAppleIDCredential) -> Void)?
    public var onError: ((Error) -> Void)?
    
    // Callbacks expected by AppleSignInView
    public var onSignInSuccess: ((_ userIdentifier: String, _ fullName: String?, _ email: String?) -> Void)?
    public var onSignInFailure: ((String) -> Void)?
    
    private var currentNonce: String?
    
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
        // Consider using TokenStorageSandbox.removeKey(forKey: TokenKeysSandbox.appleUserID) etc.
        print("User signed out from Apple (Sandbox)")
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            // Consider using AuthErrorSandbox for structured errors
            let error = NSError(domain: "AppleSignInSandbox", code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid credential"])
            onError?(error)
            onSignInFailure?(error.localizedDescription)
            return
        }
        
        onSignIn?(appleIDCredential)

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
        
        // Potentially store using TokenStorageSandbox and AppleUserInfoSandbox here
        onSignInSuccess?(userIdentifier, fullName, email)
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple failed (Sandbox): \\(error.localizedDescription)")
        onError?(error)
        onSignInFailure?(error.localizedDescription) // Consider mapping to AuthErrorSandbox
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = NSApplication.shared.windows.first else {
            fatalError("No window available for presentation (Sandbox)")
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
                    fatalError("Unable to generate nonce (Sandbox). SecRandomCopyBytes failed with OSStatus \\(errorCode)")
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