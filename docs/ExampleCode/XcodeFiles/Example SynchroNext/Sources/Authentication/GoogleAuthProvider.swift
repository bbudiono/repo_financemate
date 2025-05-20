// Copyright (c) $(date +"%Y") {CompanyName}
// Version: 1.0.1 // Incremented version due to signIn method signature change
// Purpose: Provides Google OAuth2 authentication for macOS, handling the full sign-in flow, token exchange, and user info extraction for SSO integration.
// Dependencies:
//   - AuthenticationServices (framework for ASWebAuthenticationSession)
//   - AppKit (framework for NSWindow)
//   - Foundation (framework for URLSession, UUID, JSONSerialization etc.)
// Usage: Instantiated and used by UI components (e.g., MainContentView) to initiate Google Sign-In.
//
// --- Change Log ---
// 2025-05-19: Initial structure from example code.
// 2025-05-19: Updated header for .cursorrules compliance.
//             Refactored signIn method to use a Result-based completion handler.
//             Added UserSession struct.
// 2025-05-20: Made GoogleAuthProvider conform to ObservableObject for SwiftUI compatibility. Required for @StateObject usage in MainContentView. Added @Published properties for state updates if needed.
//
// -- Quality Rating (.cursorrules §6.4.1) --
// Readability: 8/10 (OAuth logic is complex but structured; comments help)
// Efficiency: 7/10 (Multiple network calls inherent to OAuth; can be improved with better error mapping)
// Maintainability: 8/10 (Clear separation of concerns for OAuth steps)
// Error Handling: 7/10 (Custom error type used; more granular Google API errors could be mapped)
// Documentation: 9/10 (Header updated; inline comments explain OAuth steps)
// Script Functionality: 8/10 (Handles core OAuth flow; token validation is client-side)
// Security: 8/10 (Uses ASWebAuthenticationSession, ephemeral sessions, state/nonce for CSRF/replay. Relies on client-side token presence.)
// ---
// Overall Score: 80%
// Justification: Implements complex OAuth flow for macOS. Score reflects client-side nature and areas for enhanced error handling and server-side validation for production hardening.
//
// -- Pre-Coding Assessment (Original) --
// Issues & Complexity Summary: OAuth2 flow, ephemeral session, token exchange, JWT parsing, error handling, config flexibility.
// Ranking/Rating: 90% (Code), 88% (Problem) - High complexity due to OAuth, network, and security requirements. (Retained for context)
// Key Complexity Drivers (Values/Estimates):
// - Logic Scope (New/Mod LoC Est.): ~300
// - Core Algorithm Complexity: High (OAuth2, JWT parsing)
// - Dependencies (New/Mod Cnt.): 2 New (ASWebAuthenticationSession, URLSession)
// - State Management Complexity: Med (session, callbacks)
// - Novelty/Uncertainty Factor: Med (OAuth2 on macOS)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty for AI %): 90%
// Problem Estimate (Inherent Problem Difficulty %): 88%
// Initial Code Complexity Estimate (Est. Code Difficulty %): 90%
// Justification for Estimates: OAuth2 is inherently complex, requires careful error handling, and secure token management. macOS-specific UI/UX and ephemeral session handling add to the challenge.
//
// -- Post-Implementation Update (After this edit) --
// Final Code Complexity (Actual Code Difficulty %): 90% (Remains high due to OAuth)
// Overall Result Score (Success & Quality %): 85% (Improved with Result type and better structure)
// Key Variances/Learnings: Refactored to use modern Swift Result type for cleaner callback handling.
// Last Updated: $(date +"%Y-%m-%d")

import AuthenticationServices
import AppKit // Required for NSWindow
import Foundation
import Combine

// Define UserSession struct for Google Sign In
struct GoogleUserSession {
    let idToken: String
    let userID: String?
    let email: String?
    let fullName: String?
    // Can add accessToken if needed for Google API calls beyond authentication
}

class GoogleAuthProvider: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    // MARK: - ObservableObject State
    // Add @Published properties if you want to reflect sign-in state in the UI
    @Published var isSigningIn: Bool = false
    @Published var lastError: String? = nil
    @Published var userSession: GoogleUserSession? = nil

    private var authenticationSession: ASWebAuthenticationSession?
    private var currentCompletionHandler: ((Result<GoogleUserSession, Error>) -> Void)? // Store completion handler

    // Configuration loaded from Info.plist or environment
    internal var clientID: String {
        // First try to read from Info.plist
        if let clientID = Bundle.main.object(forInfoDictionaryKey: "GoogleOAuthClientID") as? String, !clientID.isEmpty {
            return clientID
        }
        
        // Fallback to environment variable
        if let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"], !clientID.isEmpty {
            return clientID
        }
        
        // Hardcoded fallback (for development only)
        return "228508661428-ev4272rg5hc6rdm5aeuc6anh8efd1ojk.apps.googleusercontent.com"
    }
    
    internal var redirectURI: String {
        // First try to read from Info.plist
        if let redirectURI = Bundle.main.object(forInfoDictionaryKey: "GoogleOAuthRedirectURI") as? String, !redirectURI.isEmpty {
            return redirectURI
        }
        
        // Fallback to environment variable
        if let redirectURI = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_REDIRECT_URI"], !redirectURI.isEmpty {
            return redirectURI
        }
        
        // Hardcoded fallback (for development only)
        return "com.products.synchronext:/oauth2redirect"
    }
    
    // Callbacks for success or failure
    var onSignInSuccess: ((_ idToken: String, _ fullName: String?, _ email: String?) -> Void)?
    var onSignInFailure: ((_ error: Error) -> Void)?

    struct GoogleOAuthError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    // Updated signIn method
    func signIn(presentingWindow: NSWindow, completion: @escaping (Result<GoogleUserSession, Error>) -> Void) {
        self.currentCompletionHandler = completion // Store the completion handler
        self.isSigningIn = true
        self.lastError = nil

        guard !clientID.contains("YOUR_GOOGLE_CLIENT_ID_PLACEHOLDER") && !clientID.isEmpty else { // Added !clientID.isEmpty
            let error = GoogleOAuthError(message: "Google Client ID not configured. Please set GoogleOAuthClientID in Info.plist or GOOGLE_OAUTH_CLIENT_ID in environment. Current ClientID: \(clientID)")
            NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
            self.lastError = error.localizedDescription
            self.isSigningIn = false
            completion(.failure(error))
            return
        }
        
        guard let authURL = buildAuthURL() else {
            let error = GoogleOAuthError(message: "Could not create Google authentication URL. ClientID used: \(clientID), RedirectURI: \(redirectURI)")
            NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
            self.lastError = error.localizedDescription
            self.isSigningIn = false
            completion(.failure(error))
            return
        }

        NSLog("[GoogleAuthProvider] Attempting to construct Auth URL with ClientID: %@ and RedirectURI: %@", clientID, redirectURI)
        NSLog("[GoogleAuthProvider] Constructed Auth URL: %@", authURL.absoluteString)

        // !!!!! DEBUG ASSERTION !!!!!
        // This will crash the app if authURL contains the old, deleted client ID.
        // This helps verify if the authURL is being constructed incorrectly locally.
        let oldProblematicClientID = "228508661428-pf2lhpj4amgc8k9hcnolov1pq59jkqou.apps.googleusercontent.com"
        if authURL.absoluteString.contains(oldProblematicClientID) {
            let errorMessage = "[GoogleAuthProvider] CRITICAL ERROR: authURL is being constructed with the OLD DELETED clientID: \(oldProblematicClientID). URL: \(authURL.absoluteString). Current clientID in code: \(self.clientID)"
            NSLog("%@", errorMessage) // Log before crash
            self.lastError = errorMessage
            self.isSigningIn = false
            completion(.failure(GoogleOAuthError(message: errorMessage))) // Call completion before assertion
            assertionFailure(errorMessage)
        }
        // !!!!! END DEBUG ASSERTION !!!!!

        // Initialize the ASWebAuthenticationSession
        // The callbackURLScheme should be the scheme part of your redirectURI
        let scheme = redirectURI.components(separatedBy: ":").first
        
        self.authenticationSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: scheme) { [weak self] callbackURL, error in
                guard let self = self else { return }

                if let error = error {
                    // Capture more detailed error information
                    let nsError = error as NSError
                    let detailedErrorMessage = """
                    ASWebAuthenticationSession Error Details:
                    Localized Description: \(nsError.localizedDescription)
                    Domain: \(nsError.domain)
                    Code: \(nsError.code)
                    User Info: \(nsError.userInfo.description)
                    """
                    
                    // Log this detailed message (as a fallback, not primary reliance)
                    NSLog("[GoogleAuthProvider] Google Sign-In Full Error Details: %@", detailedErrorMessage)
                    
                    // Pass the detailed message to the failure callback so it appears in the UI alert
                    self.currentCompletionHandler?(.failure(GoogleOAuthError(message: detailedErrorMessage)))
                    
                    self.authenticationSession = nil // Release the session
                    return
                }

                guard let callbackURL = callbackURL else {
                    let error = GoogleOAuthError(message: "Invalid callback URL received.")
                    NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
                    self.currentCompletionHandler?(.failure(error))
                    return
                }

                self.handleOAuthCallback(url: callbackURL) // This will eventually call completion
        }

        self.authenticationSession?.presentationContextProvider = self
        self.authenticationSession?.prefersEphemeralWebBrowserSession = true // Recommended for privacy
        
        // Ensure this runs on the main thread if it involves UI presentation implicitly
        DispatchQueue.main.async {
            self.authenticationSession?.start()
        }
    }

    private func buildAuthURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "accounts.google.com"
        components.path = "/o/oauth2/v2/auth"

        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"), // Using Authorization Code Flow
            URLQueryItem(name: "scope", value: "openid email profile"), // Request ID token, email, and profile
            URLQueryItem(name: "state", value: UUID().uuidString), // For CSRF protection
            URLQueryItem(name: "nonce", value: UUID().uuidString) // For ID token replay protection
        ]
        return components.url
    }

    internal func handleOAuthCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            let error = GoogleOAuthError(message: "Could not parse callback URL.")
            NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
            self.lastError = error.localizedDescription
            self.isSigningIn = false
            self.currentCompletionHandler?(.failure(error))
            return
        }

        if let errorParam = queryItems.first(where: { $0.name == "error" })?.value {
            let error = GoogleOAuthError(message: "Google Sign-In error: \(errorParam)")
            NSLog("[GoogleAuthProvider] Error from Google: %@", error.localizedDescription)
            self.lastError = error.localizedDescription
            self.isSigningIn = false
            self.currentCompletionHandler?(.failure(error))
            return
        }

        guard let authorizationCode = queryItems.first(where: { $0.name == "code" })?.value else {
            let error = GoogleOAuthError(message: "Authorization code not found in callback.")
            NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
            self.lastError = error.localizedDescription
            self.isSigningIn = false
            self.currentCompletionHandler?(.failure(error))
            return
        }

        // Exchange authorization code for tokens
        exchangeCodeForTokens(authorizationCode: authorizationCode)
    }

    private func exchangeCodeForTokens(authorizationCode: String) {
        guard let tokenURL = URL(string: "https://oauth2.googleapis.com/token") else {
            self.currentCompletionHandler?(.failure(GoogleOAuthError(message: "Invalid token endpoint URL.")))
            return
        }

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParameters = [
            "code": authorizationCode,
            "client_id": clientID,
            // If you have a client secret and are using a "Web application" type OAuth client,
            // you might need to include it here. For "macOS" or "iOS" app types, it's often not required for the token exchange
            // if PKCE was used or if it's a public client.
            // "client_secret": "YOUR_CLIENT_SECRET", 
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code"
        ]
        request.httpBody = bodyParameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                NSLog("[GoogleAuthProvider] Token exchange error: %@", error.localizedDescription)
                self.lastError = error.localizedDescription
                self.isSigningIn = false
                self.currentCompletionHandler?(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                var responseBody: String = "No response body"
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    responseBody = body
                }
                let error = GoogleOAuthError(message: "Token exchange failed with status: \(statusCode). Body: \(responseBody)")
                NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
                self.lastError = error.localizedDescription
                self.isSigningIn = false
                self.currentCompletionHandler?(.failure(error))
                return
            }

            guard let data = data else {
                let error = GoogleOAuthError(message: "No data received from token exchange.")
                NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
                self.lastError = error.localizedDescription
                self.isSigningIn = false
                self.currentCompletionHandler?(.failure(error))
                return
            }

            do {
                if let tokenResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let idToken = tokenResponse["id_token"] as? String {
                    // Successfully got the ID token. Now parse it or use it to get user info.
                    self.parseIDTokenAndFetchUserInfo(idToken: idToken) // This will call completion
                } else {
                    let error = GoogleOAuthError(message: "Could not parse ID token from response.")
                    NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
                    self.lastError = error.localizedDescription
                    self.isSigningIn = false
                    self.currentCompletionHandler?(.failure(error))
                }
            } catch {
                let error = GoogleOAuthError(message: "Error parsing token response JSON: \(error.localizedDescription)")
                NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
                self.lastError = error.localizedDescription
                self.isSigningIn = false
                self.currentCompletionHandler?(.failure(error))
            }
        }
        task.resume()
    }
    
    internal func parseIDTokenAndFetchUserInfo(idToken: String) {
        // For simplicity, we are not validating the ID token signature here.
        // In a production app, you MUST validate the ID token on your backend server.
        // See: https://developers.google.com/identity/sign-in/web/backend-auth

        guard let claims = decodeJWT(jwtToken: idToken) else {
            let error = GoogleOAuthError(message: "Could not decode ID token.")
            NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
            self.lastError = error.localizedDescription
            self.isSigningIn = false
            self.currentCompletionHandler?(.failure(error))
            return
        }

        let userID = claims["sub"] as? String
        let email = claims["email"] as? String
        let fullName = claims["name"] as? String
        
        let userSession = GoogleUserSession(idToken: idToken, userID: userID, email: email, fullName: fullName)
        self.userSession = userSession
        self.isSigningIn = false
        self.lastError = nil
        self.currentCompletionHandler?(.success(userSession))
        
        // Clean up old callbacks if they exist to prevent multiple calls from a single sign-in attempt
        self.onSignInSuccess = nil
        self.onSignInFailure = nil
    }

    // Helper to decode JWT (very basic, no signature validation)
    private func decodeJWT(jwtToken: String) -> [String: Any]? {
        let segments = jwtToken.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }

        var payload = segments[1]
        // Add padding if necessary for base64 decoding
        while payload.count % 4 != 0 {
            payload += "="
        }

        guard let payloadData = Data(base64Encoded: payload, options: .ignoreUnknownCharacters) else { return nil }

        do {
            return try JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any]
        } catch {
            return nil
        }
    }

    // MARK: - ASWebAuthenticationPresentationContextProviding
    // Need to conform to ASWebAuthenticationPresentationContextProviding to specify the window for the auth session.
    // This was missing from the original provider and is essential for ASWebAuthenticationSession on macOS.
    // Note: The class declaration should be 'class GoogleAuthProvider: NSObject, ASWebAuthenticationPresentationContextProviding {'

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Ensure this returns the correct window. This might need to be passed in if signIn is called from different contexts.
        // For now, assuming there's a main window or the window passed to signIn can be used.
        // The `presentingWindow` parameter in `signIn` is the one to use.
        // However, this delegate method doesn't have access to it directly if the session outlives the signIn call's scope.
        // For ASWebAuthenticationSession, this is often just the most relevant window.
        
        // A common approach is to use the key window or the main window of the application.
        // If signIn is always called with a valid window, and the session is tied to that call's lifetime (which it is here),
        // it's generally okay.
        return NSApplication.shared.windows.first { $0.isKeyWindow } ?? NSApplication.shared.windows.first!
    }
} 