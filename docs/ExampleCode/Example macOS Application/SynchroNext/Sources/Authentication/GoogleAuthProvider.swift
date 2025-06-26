import AuthenticationServices
import AppKit // Required for NSWindow
import Foundation

class GoogleAuthProvider: NSObject {

    private var authenticationSession: ASWebAuthenticationSession?

    // Configuration loaded from Info.plist or environment
    private var clientID: String {
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
    
    private var redirectURI: String {
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

    func signIn(presentingWindow: NSWindow) {
        guard !clientID.contains("YOUR_GOOGLE_CLIENT_ID") else {
            let error = GoogleOAuthError(message: "Google Client ID not configured. Please set GoogleOAuthClientID in Info.plist or GOOGLE_OAUTH_CLIENT_ID in environment. Current ClientID: \(clientID)")
            NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
            self.onSignInFailure?(error)
            return
        }
        
        guard let authURL = buildAuthURL() else {
            let error = GoogleOAuthError(message: "Could not create Google authentication URL. ClientID used: \(clientID), RedirectURI: \(redirectURI)")
            NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
            self.onSignInFailure?(error)
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
                    self.onSignInFailure?(GoogleOAuthError(message: detailedErrorMessage))
                    
                    self.authenticationSession = nil // Release the session
                    return
                }

                guard let callbackURL = callbackURL else {
                    let error = GoogleOAuthError(message: "Invalid callback URL received.")
                    NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
                    self.onSignInFailure?(error)
                    return
                }

                self.handleOAuthCallback(url: callbackURL)
        }

        self.authenticationSession?.presentationContextProvider = self
        self.authenticationSession?.prefersEphemeralWebBrowserSession = true // Recommended for privacy
        self.authenticationSession?.start()
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

    private func handleOAuthCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            let error = GoogleOAuthError(message: "Could not parse callback URL.")
            NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
            self.onSignInFailure?(error)
            return
        }

        if let errorParam = queryItems.first(where: { $0.name == "error" })?.value {
            let error = GoogleOAuthError(message: "Google Sign-In error: \(errorParam)")
            NSLog("[GoogleAuthProvider] Error from Google: %@", error.localizedDescription)
            self.onSignInFailure?(error)
            return
        }

        guard let authorizationCode = queryItems.first(where: { $0.name == "code" })?.value else {
            let error = GoogleOAuthError(message: "Authorization code not found in callback.")
            NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
            self.onSignInFailure?(error)
            return
        }

        // Exchange authorization code for tokens
        exchangeCodeForTokens(authorizationCode: authorizationCode)
    }

    private func exchangeCodeForTokens(authorizationCode: String) {
        guard let tokenURL = URL(string: "https://oauth2.googleapis.com/token") else {
            self.onSignInFailure?(GoogleOAuthError(message: "Invalid token endpoint URL."))
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
                self.onSignInFailure?(error)
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
                self.onSignInFailure?(error)
                return
            }

            guard let data = data else {
                let error = GoogleOAuthError(message: "No data received from token exchange.")
                NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
                self.onSignInFailure?(error)
                return
            }

            do {
                if let tokenResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let idToken = tokenResponse["id_token"] as? String {
                    // Successfully got the ID token. Now parse it or use it to get user info.
                    self.parseIDTokenAndFetchUserInfo(idToken: idToken)
                } else {
                    let error = GoogleOAuthError(message: "Could not parse ID token from response.")
                    NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
                    self.onSignInFailure?(error)
                }
            } catch {
                let error = GoogleOAuthError(message: "Error parsing token response JSON: \(error.localizedDescription)")
                NSLog("[GoogleAuthProvider] Error: %@", error.localizedDescription)
                self.onSignInFailure?(error)
            }
        }
        task.resume()
    }
    
    private func parseIDTokenAndFetchUserInfo(idToken: String) {
        // The ID token is a JWT. For a "dead simple" approach, we'll decode the payload.
        // For robust production apps, you should validate the ID token signature on a server.
        // Here, we'll just extract claims.
        let segments = idToken.components(separatedBy: ".")
        guard segments.count > 1 else {
            self.onSignInFailure?(GoogleOAuthError(message: "Invalid ID token format."))
            return
        }

        var payload = segments[1]
        // Add padding if necessary for base64 decoding
        while payload.count % 4 != 0 {
            payload += "="
        }

        guard let payloadData = Data(base64Encoded: payload, options: .ignoreUnknownCharacters) else {
            self.onSignInFailure?(GoogleOAuthError(message: "Could not base64 decode ID token payload."))
            return
        }

        do {
            if let claims = try JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any] {
                let email = claims["email"] as? String
                let name = claims["name"] as? String // Google often provides 'name'
                // Or try to construct from given_name and family_name
                let givenName = claims["given_name"] as? String
                let familyName = claims["family_name"] as? String
                
                var fullName = name
                if fullName == nil || fullName!.isEmpty {
                    var nameParts: [String] = []
                    if let gn = givenName, !gn.isEmpty { nameParts.append(gn) }
                    if let fn = familyName, !fn.isEmpty { nameParts.append(fn) }
                    if !nameParts.isEmpty {
                        fullName = nameParts.joined(separator: " ")
                    }
                }
                
                // For this minimal example, we assume success if we have an ID token.
                // You might want to also get an access token from the token exchange response
                // if you need to call other Google APIs.
                NSLog("[GoogleAuthProvider] Google Sign-In Successful. ID Token acquired.")
                self.onSignInSuccess?(idToken, fullName, email)
            } else {
                self.onSignInFailure?(GoogleOAuthError(message: "Could not parse claims from ID token payload."))
            }
        } catch {
            self.onSignInFailure?(GoogleOAuthError(message: "Error parsing ID token claims JSON: \(error.localizedDescription)"))
        }
    }
}

// Required for ASWebAuthenticationSession
extension GoogleAuthProvider: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Return the main window of the application
        return NSApplication.shared.windows.first { $0.isKeyWindow } ?? NSApplication.shared.windows.first!
    }
} 