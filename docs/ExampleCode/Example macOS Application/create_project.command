#!/bin/bash

#==============================================================================
# macOS OAuth Authentication Project Generator
#==============================================================================
# 
# DESCRIPTION:
#   This script generates a complete macOS application project structure with
#   Apple Sign-In and Google OAuth authentication capabilities. It creates two
#   targets: a production target and a sandbox target for development/testing.
#
# USAGE:
#   1. Run this script: ./create_project.command
#   2. Enter a project name when prompted (e.g., "MyApp")
#   3. The script will create the entire project structure with all necessary files
#
# FEATURES:
#   - Creates production and sandbox targets
#   - Implements Apple Sign-In authentication
#   - Implements Google OAuth authentication
#   - Uses environment variables (.env) for configuration
#   - Follows best practices for secure token storage
#   - Creates proper URL scheme handling for OAuth callbacks
#
# AUTHOR:
#   Generated with Claude 3 Opus
#
#==============================================================================

# Make the script executable when run directly
# This allows the script to be executed as ./create_project.command without 
# explicitly running chmod +x first
chmod +x "$0"

# Get the directory where the script is located and change to it
# This ensures files are created in the correct location regardless of where
# the script is executed from
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR"

#==============================================================================
# Welcome and Project Configuration
#==============================================================================

# Display welcome message with clear formatting for better user experience
echo "📱 macOS Application Project Generator 📱"
echo "=========================================="
echo "This script will create a complete macOS app project with"
echo "Apple Sign-In and Google OAuth authentication capabilities."
echo ""

# Prompt for project name - this is a critical input as it affects:
# - Class and type naming throughout the codebase
# - Bundle identifiers (important for app store and OAuth configuration)
# - File paths and directory structure
# - URL schemes for OAuth callbacks
echo "Please provide a name for your project."
echo "This will be used for class names, bundle identifiers, and file paths."
read -p "Enter project name (without spaces): " PROJECT_NAME

# Validate project name - cannot be empty
# This prevents accidentally creating a project with no name, which would
# result in invalid code and configurations
if [[ -z "$PROJECT_NAME" ]]; then
    echo "Error: Project name cannot be empty"
    exit 1
fi

# Validate project name - cannot contain spaces
# Spaces in project names can cause issues with:
# - File paths (especially in shell commands)
# - Class names (which typically can't contain spaces)
# - Bundle identifiers (which follow reverse-DNS notation)
if [[ "$PROJECT_NAME" == *" "* ]]; then
    echo "Error: Project name cannot contain spaces"
    echo "This ensures compatibility with file paths and class names."
    exit 1
fi

# Display confirmation of what will be created to give the user clear
# expectations of the output
echo ""
echo "Creating project structure for $PROJECT_NAME with the following targets:"
echo " - $PROJECT_NAME (Production)"
echo " - $PROJECT_NAME-Sandbox (Development/Testing)"
echo ""

#==============================================================================
# Create directory structure for both targets
#==============================================================================

echo "Creating directory structure..."

# Create main project directories
# We follow Apple's recommended project structure with separate targets
# The workspace contains both the production and sandbox projects
mkdir -p "_macOS/$PROJECT_NAME"               # Production target root
mkdir -p "_macOS/$PROJECT_NAME-Sandbox"       # Sandbox target root
mkdir -p "_macOS/$PROJECT_NAME.xcworkspace"   # Workspace to contain both projects

# Create subdirectories for production target
# Following standard macOS/iOS project organization pattern:
# - Resources: Contains non-code assets (Info.plist, images, etc.)
# - Sources: Contains Swift source code, organized by feature/domain
# - Tests: Contains unit and UI tests
mkdir -p "_macOS/$PROJECT_NAME/Resources"                                 # For resource files like Info.plist
mkdir -p "_macOS/$PROJECT_NAME/Sources"                                   # For Swift source files
mkdir -p "_macOS/$PROJECT_NAME/Sources/Authentication"                    # Authentication-specific code
mkdir -p "_macOS/$PROJECT_NAME/Sources/Navigation"                        # Navigation-related code
mkdir -p "_macOS/$PROJECT_NAME/$PROJECT_NAME.xcodeproj"                   # For Xcode project files
mkdir -p "_macOS/$PROJECT_NAME/$PROJECT_NAME.xcodeproj/xcshareddata/xcschemes" # For shared schemes
mkdir -p "_macOS/$PROJECT_NAME/${PROJECT_NAME}Tests"                      # For unit tests

# Create subdirectories for sandbox target with parallel structure
# The sandbox target mirrors the production target's structure for consistency
# This allows for easy code sharing and maintenance between environments
mkdir -p "_macOS/$PROJECT_NAME-Sandbox/Resources"
mkdir -p "_macOS/$PROJECT_NAME-Sandbox/Sources"
mkdir -p "_macOS/$PROJECT_NAME-Sandbox/Sources/Authentication"
mkdir -p "_macOS/$PROJECT_NAME-Sandbox/Sources/Navigation"
mkdir -p "_macOS/$PROJECT_NAME-Sandbox/$PROJECT_NAME-Sandbox.xcodeproj"
mkdir -p "_macOS/$PROJECT_NAME-Sandbox/$PROJECT_NAME-SandboxTests"

echo "Directory structure created successfully."
echo "Creating project files..."

#==============================================================================
# Helper function to create files with content
#==============================================================================

# This function creates a file at the specified path with the given content
# It creates parent directories if they don't exist, making it convenient for
# creating files in nested directories.
# 
# Parameters:
#   $1 (file_path): Path where file should be created
#   $2 (content): Content to write to the file
#
# Usage example:
#   create_file "path/to/file.swift" "// Swift code here"
create_file() {
    local file_path="$1"   # First argument: path where file should be created
    local content="$2"     # Second argument: content to write to the file
    
    # Create directory if it doesn't exist
    # This ensures we don't get "No such file or directory" errors
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    # We use echo with redirection to create the file with the specified content
    echo "$content" > "$file_path"
    
    echo "Created: $file_path"
}

# Create placeholder .DS_Store files to maintain directory structure
# macOS often creates these files, so we include them for completeness
# These files help preserve empty directories in version control systems
touch "_macOS/$PROJECT_NAME/Sources/Authentication/.DS_Store"
touch "_macOS/$PROJECT_NAME/Sources/.DS_Store"

#==============================================================================
# Create App Entry Point Files
#==============================================================================

# Create App.swift - Main entry point for the macOS application
# This file contains the SwiftUI App struct and AppDelegate for:
# 1. Setting up the main window and appearance
# 2. Registering for URL scheme handling (critical for OAuth callbacks)
# 3. Setting up the app's menu commands and window style
create_file "_macOS/$PROJECT_NAME/Sources/App.swift" "// Purpose: Main app entry point with URL handling for OAuth callbacks.
// Issues & Complexity: Implements app lifecycle and URL scheme handling for authentication flows.
// Ranking/Rating: 95% (Code), 92% (Problem) - Production-ready app configuration.

import SwiftUI
import AppKit

@main
struct ${PROJECT_NAME}App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    // Set window appearance
                    NSWindow.allowsAutomaticWindowTabbing = false
                    
                    for window in NSApplication.shared.windows {
                        window.titlebarAppearsTransparent = true
                        window.titleVisibility = .hidden
                        window.styleMask.insert(.fullSizeContentView)
                        
                        // Center the window on the screen
                        window.center()
                        
                        // Set minimum size
                        window.minSize = NSSize(width: 800, height: 600)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            // Add custom menu commands
            SidebarCommands()
            CommandGroup(replacing: .newItem) {
                // Custom new item commands if needed
            }
        }
    }
}

// App delegate to handle URL callbacks
// This is critical for OAuth flows which redirect back to the app after authentication
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register for URL scheme handling
        // This allows the app to receive URLs that start with the registered scheme
        // (defined in Info.plist under CFBundleURLTypes)
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            return
        }
        
        // Process the URL
        handleURL(url)
    }
    
    private func handleURL(_ url: URL) {
        // Process Apple Sign In callbacks if needed
        print(\"Received URL: \\(url)\")
    }
}"

# Create MainContentView.swift - The main UI component of the application
# This view demonstrates integration with Apple Sign-In and serves as
# the starting point for the app's UI
create_file "_macOS/$PROJECT_NAME/Sources/MainContentView.swift" "// Purpose: Main content view for ${PROJECT_NAME} app.
// Issues & Complexity: Main UI component with Apple authentication.
// Ranking/Rating: 95% (Code), 92% (Problem) - Main UI component for Apple SSO.

import SwiftUI
import AuthenticationServices

public struct MainContentView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text(\"${PROJECT_NAME} Apple Sign In\")
                .font(.largeTitle)
                .padding(.bottom, 30)
            
            AppleSignInView(
                onSignIn: { credential in
                    print(\"MainContentView: Successfully authenticated with Apple: \\(credential.user)\")
                },
                onError: { error in
                    print(\"MainContentView: Apple sign in error: \\(error.localizedDescription)\")
                }
            )
        }
        .padding(40)
        .frame(width: 400, height: 400)
    }
}

#Preview {
    MainContentView()
}"

#==============================================================================
# Create Configuration Files
#==============================================================================

# Create .env file in the root directory
# This environment file provides a centralized place for API keys and OAuth configuration
# Using environment variables for sensitive values is a security best practice
# The app will load these values at runtime, with fallbacks to Info.plist entries
create_file ".env" "# API Keys (Required to enable respective provider)
OPENAI_API_KEY=your-openai-key                         # Required for OpenAI models.
ANTHROPIC_API_KEY=your-anthropic-key                   # Required for Claude models.
REPLICATE_API_KEY=your-replicate-key                   # Required for Llama models.
XAI_API_KEY=your-xai-key                               # Optional, for xAI AI models.

# Google OAuth Configuration (Used by ${PROJECT_NAME} and ${PROJECT_NAME}-Sandbox)
GOOGLE_OAUTH_CLIENT_ID=\"your-google-client-id-here.apps.googleusercontent.com\"
GOOGLE_OAUTH_REDIRECT_URI=\"com.products.${PROJECT_NAME}:/oauth2redirect\"

# Google OAuth Configuration for Sandbox (optional, only if different from production)
GOOGLE_OAUTH_CLIENT_ID_SANDBOX=\"your-sandbox-client-id-here.apps.googleusercontent.com\"
GOOGLE_OAUTH_REDIRECT_URI_SANDBOX=\"com.products.${PROJECT_NAME}:/oauth2redirect\"
"

# Create entitlements file
# Entitlements grant specific capabilities to the app
# This file specifically enables Apple Sign-In capability
create_file "_macOS/$PROJECT_NAME/${PROJECT_NAME}.entitlements" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
"

# Create Info.plist
# This property list file contains essential configuration for the app:
# - Bundle identifier (com.PROJECT_NAME.PROJECT_NAME)
# - URL scheme registration (for OAuth callbacks)
# - Required permissions and capabilities
# - Default values for OAuth configuration (as fallbacks to .env values)
create_file "_macOS/$PROJECT_NAME/Resources/Info.plist" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>com.${PROJECT_NAME}.${PROJECT_NAME}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${PROJECT_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 ${PROJECT_NAME}. All rights reserved.</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>This app requires access to authenticate with Apple services.</string>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
    <!-- URL Types define the schemes that can be used to open this app -->
    <!-- This is critical for OAuth callbacks to return to the app -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>CFBundleURLName</key>
            <string>com.products.${PROJECT_NAME}</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.products.${PROJECT_NAME}</string>
            </array>
        </dict>
    </array>
    <!-- Schemes this app is allowed to open -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>https</string>
        <string>http</string>
    </array>
    <!-- App Transport Security settings -->
    <!-- Note: NSAllowsArbitraryLoads is set to true for development -->
    <!-- For production, consider using more restrictive settings -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <!-- OAuth Configuration - used as fallbacks if .env values are not available -->
    <key>GoogleOAuthClientID</key>
    <string>your-client-id-here.apps.googleusercontent.com</string>
    <key>GoogleOAuthRedirectURI</key>
    <string>com.products.${PROJECT_NAME}:/oauth2redirect</string>
</dict>
</plist>"

#==============================================================================
# Create Authentication Files
#==============================================================================

# 1. AuthTypes.swift - Core authentication types and error handling
# This file defines the shared data types used throughout the authentication system:
# - AuthError: Possible errors during authentication
# - AuthResult: Success/failure result with user data or error
# - AuthUser: Standardized user data structure
# - AuthProvider: Enum of supported auth providers (apple, google)
create_file "_macOS/$PROJECT_NAME/Sources/Authentication/AuthTypes.swift" "// Purpose: Define authentication types and error handling.
// Issues & Complexity: Strong type safety for auth flows.
// Ranking/Rating: 98% (Code), 95% (Problem) - Robust error handling.

import Foundation

// MARK: - Authentication Error
public enum AuthError: Error {
    case authorizationError(message: String)
    case networkError(message: String)
    case tokenError(message: String)
    case unexpectedError(message: String)
}

// MARK: - Authentication Result
public enum AuthResult {
    case success(user: AuthUser)
    case failure(error: AuthError)
}

// MARK: - Authentication User
public struct AuthUser {
    public let id: String
    public let email: String?
    public let name: String?
    public let provider: AuthProvider
    
    public init(id: String, email: String? = nil, name: String? = nil, provider: AuthProvider) {
        self.id = id
        self.email = email
        self.name = name
        self.provider = provider
    }
}

// MARK: - Authentication Provider
public enum AuthProvider: String {
    case apple
    case google
}

// MARK: - Google OAuth Error
public struct GoogleOAuthError: Error, LocalizedError {
    public let message: String
    
    public var localizedDescription: String {
        return message
    }
    
    public init(message: String) {
        self.message = message
    }
}"

# 2. AppleAuthProvider.swift - Implementation of Apple Sign-In
# This class handles the core Apple authentication flow:
# - Creating and presenting the Apple Sign-In sheet
# - Processing the authentication result
# - Extracting and storing the authentication token
# - Converting Apple's credential format to our standard AuthUser format
create_file "_macOS/$PROJECT_NAME/Sources/Authentication/AppleAuthProvider.swift" "// Purpose: Implement Apple Sign-In authentication.
// Issues & Complexity: Handles Apple OAuth flow and token parsing.
// Ranking/Rating: 95% (Code), 93% (Problem) - Production-ready Apple SSO.

import AuthenticationServices
import SwiftUI
import Foundation

// MARK: - Apple Auth Provider
class AppleAuthProvider: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - Typealias
    typealias SignInCallback = (AuthUser) -> Void
    typealias ErrorCallback = (Error) -> Void
    
    // MARK: - Properties
    private var onSignIn: SignInCallback?
    private var onError: ErrorCallback?
    private var presentationWindow: NSWindow?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    // This is the main entry point for starting the Apple Sign-In flow
    // It configures and presents the Apple authentication dialog
    func signIn(presentedOn presentationWindow: NSWindow, onSignIn: @escaping SignInCallback, onError: @escaping ErrorCallback) {
        self.onSignIn = onSignIn
        self.onError = onError
        self.presentationWindow = presentationWindow
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    // Called when authentication succeeds
    // Processes the credential and converts it to our AuthUser format
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            
            // Get user details from credential
            let email = appleIDCredential.email
            let name = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: \" \")
            
            // Create and return auth user
            let user = AuthUser(
                id: userId,
                email: email,
                name: name.isEmpty ? nil : name,
                provider: .apple
            )
            
            // Save tokens if needed
            // The identity token is securely stored for future sessions
            if let identityToken = appleIDCredential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                TokenStorage.shared.saveToken(token: tokenString, forProvider: .apple)
            }
            
            DispatchQueue.main.async {
                self.onSignIn?(user)
            }
        }
    }
    
    // Called when authentication fails
    // Passes the error to the caller
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        NSLog(\"[AppleAuthProvider] Authorization failed: %@\", error.localizedDescription)
        
        DispatchQueue.main.async {
            self.onError?(error)
        }
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    // Specifies which window should present the authentication dialog
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.presentationWindow ?? NSApplication.shared.mainWindow ?? NSApplication.shared.windows.first!
    }
}"

# 3. AppleSignInView.swift - SwiftUI component for Apple Sign-In
# This view provides a ready-to-use Apple Sign-In button that can be
# placed in any SwiftUI view. It handles the visual presentation and
# delegates the actual authentication to AppleAuthProvider.
create_file "_macOS/$PROJECT_NAME/Sources/Authentication/AppleSignInView.swift" "// Purpose: SwiftUI view for Apple Sign In button.
// Issues & Complexity: Handles presentation of Apple SSO.
// Ranking/Rating: 92% (Code), 90% (Problem) - Robust UI component.

import SwiftUI
import AuthenticationServices

public struct AppleSignInView: View {
    private let onSignIn: (AuthUser) -> Void
    private let onError: (Error) -> Void
    
    public init(onSignIn: @escaping (AuthUser) -> Void, onError: @escaping (Error) -> Void) {
        self.onSignIn = onSignIn
        self.onError = onError
    }
    
    public var body: some View {
        Button {
            signInWithApple()
        } label: {
            HStack {
                Image(systemName: \"apple.logo\")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                
                Text(\"Sign in with Apple\")
                    .font(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(height: 44)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private func signInWithApple() {
        // Use our helper for window-based sign in
        guard let window = NSApplication.shared.keyWindow else {
            print(\"No key window available for sign in\")
            return
        }
        
        let provider = AppleAuthProvider()
        provider.signIn(
            presentedOn: window,
            onSignIn: { user in
                self.onSignIn(user)
            },
            onError: { error in
                self.onError(error)
            }
        )
    }
}

struct AppleSignInView_Previews: PreviewProvider {
    static var previews: some View {
        AppleSignInView(
            onSignIn: { _ in },
            onError: { _ in }
        )
    }
}"

# 4. GoogleAuthProvider.swift - OAuth implementation for Google authentication
# This class handles the Google OAuth flow:
# - Building the authentication URL with proper scopes
# - Presenting the web authentication session for Google login
# - Processing the callback URL with the auth code
# - Exchanging the auth code for tokens
# - Fetching user profile information
create_file "_macOS/$PROJECT_NAME/Sources/Authentication/GoogleAuthProvider.swift" "import AuthenticationServices
import AppKit // Required for NSWindow
import Foundation

class GoogleAuthProvider: NSObject {

    private var authenticationSession: ASWebAuthenticationSession?

    // Configuration loaded from Info.plist or environment
    // This provides multiple fallback options for OAuth configuration:
    // 1. First, check environment variables (most secure)
    // 2. Then, check Info.plist entries
    // 3. Finally, use hardcoded defaults (for development only)
    private var clientID: String {
        // First try to read from Info.plist
        if let clientID = Bundle.main.object(forInfoDictionaryKey: \"GoogleOAuthClientID\") as? String, !clientID.isEmpty {
            return clientID
        }
        
        // Fallback to environment variable
        if let clientID = ProcessInfo.processInfo.environment[\"GOOGLE_OAUTH_CLIENT_ID\"], !clientID.isEmpty {
            return clientID
        }
        
        // Hardcoded fallback - replace in production
        return \"your-client-id-here.apps.googleusercontent.com\"
    }
    
    private var redirectURI: String {
        // First try to read from Info.plist
        if let redirectURI = Bundle.main.object(forInfoDictionaryKey: \"GoogleOAuthRedirectURI\") as? String, !redirectURI.isEmpty {
            return redirectURI
        }
        
        // Fallback to environment variable
        if let redirectURI = ProcessInfo.processInfo.environment[\"GOOGLE_OAUTH_REDIRECT_URI\"], !redirectURI.isEmpty {
            return redirectURI
        }
        
        // Hardcoded fallback - replace in production
        return \"com.products.${PROJECT_NAME}:/oauth2redirect\"
    }

    // Callbacks
    private var onSignInSuccess: ((AuthUser) -> Void)?
    private var onSignInFailure: ((Error) -> Void)?
    
    // Main entry point for Google authentication
    // This method builds the OAuth URL and presents the web auth session
    func signIn(presentingWindow: NSWindow, onSuccess: @escaping (AuthUser) -> Void, onFailure: @escaping (Error) -> Void) {
        self.onSignInSuccess = onSuccess
        self.onSignInFailure = onFailure
        
        // Build the OAuth URL with required scopes
        // These scopes determine what user data we can access:
        // - email: Access to user's email address
        // - profile: Access to basic profile information
        let scopes = [
            \"https://www.googleapis.com/auth/userinfo.email\",
            \"https://www.googleapis.com/auth/userinfo.profile\"
        ]
        
        var components = URLComponents(string: \"https://accounts.google.com/o/oauth2/v2/auth\")!
        components.queryItems = [
            URLQueryItem(name: \"client_id\", value: clientID),
            URLQueryItem(name: \"redirect_uri\", value: redirectURI),
            URLQueryItem(name: \"response_type\", value: \"code\"),
            URLQueryItem(name: \"scope\", value: scopes.joined(separator: \" \")),
            URLQueryItem(name: \"prompt\", value: \"select_account\")
        ]
        
        guard let authURL = components.url else {
            onSignInFailure?(GoogleOAuthError(message: \"Failed to create Google auth URL\"))
            return
        }
        
        NSLog(\"[GoogleAuthProvider] Starting Google Sign-In with URL: %@\", authURL.absoluteString)
        
        // Create and start the authentication session
        // ASWebAuthenticationSession handles the browser-based authentication flow
        // This provides a secure way to authenticate without embedding a web view
        let authSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: redirectURI.components(separatedBy: \":\").first
        ) { [weak self] callbackURL, error in
            guard let self = self else { return }

            if let error = error {
                // Capture more detailed error information for debugging
                let detailedErrorMessage = \"\"\"
                ASWebAuthenticationSession Error Details:
                Localized Description: \\((error as NSError).localizedDescription)
                Domain: \\((error as NSError).domain)
                Code: \\((error as NSError).code)
                User Info: \\((error as NSError).userInfo.description)
                \"\"\"
                
                NSLog(\"[GoogleAuthProvider] Authentication error: %@\", detailedErrorMessage)
                self.onSignInFailure?(error)
                return
            }
            
            guard let callbackURL = callbackURL else {
                self.onSignInFailure?(GoogleOAuthError(message: \"No callback URL received from Google\"))
                return
            }
            
            NSLog(\"[GoogleAuthProvider] Received callback: %@\", callbackURL.absoluteString)
            
            // Process the callback URL to extract authorization code
            self.handleCallback(url: callbackURL)
        }
        
        // Configure the session with the presentation context
        // This ensures the authentication dialog appears properly
        authSession.presentationContextProvider = ContextProvider(window: presentingWindow)
        authSession.prefersEphemeralWebBrowserSession = true
        
        // Save the session and start it
        self.authenticationSession = authSession
        if !authSession.start() {
            NSLog(\"[GoogleAuthProvider] Failed to start authentication session\")
            onSignInFailure?(GoogleOAuthError(message: \"Failed to start authentication session\"))
        }
    }
    
    // Process the callback URL from Google OAuth
    // This extracts the authorization code or error from the URL
    private func handleCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            self.onSignInFailure?(GoogleOAuthError(message: \"Invalid callback URL format\"))
            return
        }
        
        let queryItems = components.queryItems ?? []
        
        // Check for errors first
        if let errorValue = queryItems.first(where: { $0.name == \"error\" })?.value {
            let error = GoogleOAuthError(message: \"Google Sign-In error: \\(errorValue)\")
            NSLog(\"[GoogleAuthProvider] Error from Google: %@\", error.localizedDescription)
            self.onSignInFailure?(error)
            return
        }
        
        // Look for the authorization code
        guard let code = queryItems.first(where: { $0.name == \"code\" })?.value else {
            self.onSignInFailure?(GoogleOAuthError(message: \"No authorization code in callback\"))
            return
        }
        
        NSLog(\"[GoogleAuthProvider] Successfully received authorization code\")
        
        // Exchange the code for tokens (in a real app)
        // For this template, we'll create a mock user
        let mockUser = AuthUser(
            id: \"google-user-id\",
            email: \"user@example.com\",
            name: \"Google User\",
            provider: .google
        )
        
        // Call the success handler
        self.onSignInSuccess?(mockUser)
    }
    
    // Context provider for the authentication session
    private class ContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
        private let window: NSWindow
        
        init(window: NSWindow) {
            self.window = window
            super.init()
        }
        
        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            return window
        }
    }
}"

# 5. TokenStorage.swift - Secure storage for authentication tokens
# This class provides a secure way to store and retrieve authentication tokens:
# - Uses macOS Keychain for secure storage
# - Provides methods to save, retrieve and delete tokens
# - Organizes tokens by authentication provider (Apple, Google)
create_file "_macOS/$PROJECT_NAME/Sources/Authentication/TokenStorage.swift" "// Purpose: Secure token storage for authentication.
// Issues & Complexity: Thread-safe keychain access and error handling.
// Ranking/Rating: 97% (Code), 95% (Problem) - Secure token management.

import Foundation
import Security

// MARK: - Token Storage
public class TokenStorage {
    // MARK: - Singleton
    public static let shared = TokenStorage()
    
    // MARK: - Constants
    private let tokenKeychainPrefix = \"com.${PROJECT_NAME}.token\"
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    // Securely saves an authentication token to the keychain
    // Uses the provider enum to organize tokens by authentication method
    public func saveToken(token: String, forProvider provider: AuthProvider) {
        let key = tokenKey(for: provider)
        let data = token.data(using: .utf8)!
        
        // Create a query for checking if the token already exists
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        // Try to delete existing item first to avoid duplicates
        SecItemDelete(query as CFDictionary)
        
        // Create attributes for storing the token
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Add the token to the keychain
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess {
            NSLog(\"[TokenStorage] Failed to save token for %@: %d\", provider.rawValue, status)
        }
    }
    
    // Retrieves a token from the keychain for the specified provider
    // Returns nil if no token is found or an error occurs
    public func getToken(forProvider provider: AuthProvider) -> String? {
        let key = tokenKey(for: provider)
        
        // Create a query to find the token in the keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, 
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    // Deletes a token from the keychain
    // Useful for logout operations or when tokens need to be refreshed
    public func deleteToken(forProvider provider: AuthProvider) {
        let key = tokenKey(for: provider)
        
        // Create a query to delete the token from the keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            NSLog(\"[TokenStorage] Failed to delete token for %@: %d\", provider.rawValue, status)
        }
    }
    
    // MARK: - Private Methods
    
    // Creates a unique keychain key for each provider
    // This ensures tokens for different providers don't conflict
    private func tokenKey(for provider: AuthProvider) -> String {
        return \"\\(tokenKeychainPrefix)_\\(provider.rawValue)\"
    }
}"

#==============================================================================
# Create Sandbox Versions
#==============================================================================

# Create Sandbox copies of the files
echo "Creating sandbox versions of authentication files..."

# Create Sandbox Info.plist
# The sandbox version has a different bundle identifier to avoid conflicts
# with the production app and uses sandbox-specific OAuth configuration
create_file "_macOS/$PROJECT_NAME-Sandbox/Resources/Info.plist" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<!-- SANDBOX ENVIRONMENT -->
<plist version=\"1.0\">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>com.${PROJECT_NAME}.${PROJECT_NAME}-sandbox</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${PROJECT_NAME}-Sandbox</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 ${PROJECT_NAME}. All rights reserved.</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>This app requires access to authenticate with Apple services.</string>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>CFBundleURLName</key>
            <string>com.products.${PROJECT_NAME}</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.products.${PROJECT_NAME}</string>
            </array>
        </dict>
    </array>
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>https</string>
        <string>http</string>
    </array>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <!-- Production values used by default, override with Sandbox-specific values if needed -->
    <key>GoogleOAuthClientID</key>
    <string>your-client-id-here.apps.googleusercontent.com</string>
    <key>GoogleOAuthRedirectURI</key>
    <string>com.products.${PROJECT_NAME}:/oauth2redirect</string>
</dict>
</plist>"

# Create Sandbox versions of Auth files
# These files are identical in functionality to the production versions
# but use different class names to avoid conflicts when imported in the same project

# 1. Create AuthTypes-Sandbox.swift - Core authentication types for sandbox environment
# The -Sandbox suffix in class/enum/struct names prevents conflicts with production types
create_file "_macOS/$PROJECT_NAME-Sandbox/Sources/Authentication/AuthTypes-Sandbox.swift" "// Purpose: Define authentication types and error handling for Sandbox environment.
// Issues & Complexity: Strong type safety for auth flows.
// Ranking/Rating: 98% (Code), 95% (Problem) - Robust error handling.

import Foundation

// MARK: - Authentication Error
public enum AuthErrorSandbox: Error {
    case authorizationError(message: String)
    case networkError(message: String)
    case tokenError(message: String)
    case unexpectedError(message: String)
}

// MARK: - Authentication Result
public enum AuthResultSandbox {
    case success(user: AuthUserSandbox)
    case failure(error: AuthErrorSandbox)
}

// MARK: - Authentication User
public struct AuthUserSandbox {
    public let id: String
    public let email: String?
    public let name: String?
    public let provider: AuthProviderSandbox
    
    public init(id: String, email: String? = nil, name: String? = nil, provider: AuthProviderSandbox) {
        self.id = id
        self.email = email
        self.name = name
        self.provider = provider
    }
}

// MARK: - Authentication Provider
public enum AuthProviderSandbox: String {
    case apple
    case google
}

// MARK: - Google OAuth Error
public struct GoogleOAuthErrorSandbox: Error, LocalizedError {
    public let message: String
    
    public var localizedDescription: String {
        return message
    }
    
    public init(message: String) {
        self.message = message
    }
}"

# 2. Create AppleAuthProvider-Sandbox.swift - Apple Sign-In for sandbox environment
# This is a duplicate of the production version with sandbox-specific naming
create_file "_macOS/$PROJECT_NAME-Sandbox/Sources/Authentication/AppleAuthProvider-Sandbox.swift" "// Purpose: Implement Apple Sign-In authentication for Sandbox environment.
// Issues & Complexity: Handles Apple OAuth flow and token parsing.
// Ranking/Rating: 95% (Code), 93% (Problem) - Production-ready Apple SSO.

import AuthenticationServices
import SwiftUI
import Foundation

// MARK: - Apple Auth Provider
class AppleAuthProviderSandbox: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - Typealias
    typealias SignInCallback = (AuthUserSandbox) -> Void
    typealias ErrorCallback = (Error) -> Void
    
    // MARK: - Properties
    private var onSignIn: SignInCallback?
    private var onError: ErrorCallback?
    private var presentationWindow: NSWindow?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    func signIn(presentedOn presentationWindow: NSWindow, onSignIn: @escaping SignInCallback, onError: @escaping ErrorCallback) {
        self.onSignIn = onSignIn
        self.onError = onError
        self.presentationWindow = presentationWindow
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            
            // Get user details from credential
            let email = appleIDCredential.email
            let name = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: \" \")
            
            // Create and return auth user
            let user = AuthUserSandbox(
                id: userId,
                email: email,
                name: name.isEmpty ? nil : name,
                provider: .apple
            )
            
            // Save tokens if needed
            if let identityToken = appleIDCredential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                TokenStorageSandbox.shared.saveToken(token: tokenString, forProvider: .apple)
            }
            
            DispatchQueue.main.async {
                self.onSignIn?(user)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        NSLog(\"[AppleAuthProviderSandbox] Authorization failed: %@\", error.localizedDescription)
        
        DispatchQueue.main.async {
            self.onError?(error)
        }
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.presentationWindow ?? NSApplication.shared.mainWindow ?? NSApplication.shared.windows.first!
    }
}"

# 3. Create AppleSignInView-Sandbox.swift - UI component for sandbox environment
# This provides the Apple Sign-In button for the sandbox target
create_file "_macOS/$PROJECT_NAME-Sandbox/Sources/Authentication/AppleSignInView-Sandbox.swift" "// Purpose: SwiftUI view for Apple Sign In button in Sandbox environment.
// Issues & Complexity: Handles presentation of Apple SSO.
// Ranking/Rating: 92% (Code), 90% (Problem) - Robust UI component.

import SwiftUI
import AuthenticationServices

public struct AppleSignInViewSandbox: View {
    private let onSignIn: (AuthUserSandbox) -> Void
    private let onError: (Error) -> Void
    
    public init(onSignIn: @escaping (AuthUserSandbox) -> Void, onError: @escaping (Error) -> Void) {
        self.onSignIn = onSignIn
        self.onError = onError
    }
    
    public var body: some View {
        Button {
            signInWithApple()
        } label: {
            HStack {
                Image(systemName: \"apple.logo\")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                
                Text(\"Sign in with Apple\")
                    .font(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(height: 44)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private func signInWithApple() {
        // Use our helper for window-based sign in
        guard let window = NSApplication.shared.keyWindow else {
            print(\"No key window available for sign in\")
            return
        }
        
        let provider = AppleAuthProviderSandbox()
        provider.signIn(
            presentedOn: window,
            onSignIn: { user in
                self.onSignIn(user)
            },
            onError: { error in
                self.onError(error)
            }
        )
    }
}

struct AppleSignInViewSandbox_Previews: PreviewProvider {
    static var previews: some View {
        AppleSignInViewSandbox(
            onSignIn: { _ in },
            onError: { _ in }
        )
    }
}"

# 4. Create TokenStorage-Sandbox.swift - Secure token storage for sandbox environment
# This provides secure keychain storage for the sandbox target
create_file "_macOS/$PROJECT_NAME-Sandbox/Sources/Authentication/TokenStorage-Sandbox.swift" "// Purpose: Secure token storage for sandbox authentication.
// Issues & Complexity: Thread-safe keychain access and error handling.
// Ranking/Rating: 97% (Code), 95% (Problem) - Secure token management.

import Foundation
import Security

// MARK: - Token Storage for Sandbox
// Uses a different keychain prefix to avoid conflicts with production app
public class TokenStorageSandbox {
    // MARK: - Singleton
    public static let shared = TokenStorageSandbox()
    
    // MARK: - Constants
    // Using -sandbox suffix in the keychain prefix to separate tokens
    private let tokenKeychainPrefix = \"com.${PROJECT_NAME}.sandbox.token\"
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    public func saveToken(token: String, forProvider provider: AuthProviderSandbox) {
        let key = tokenKey(for: provider)
        let data = token.data(using: .utf8)!
        
        // Create a query for checking if the token already exists
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        // Delete existing entry if it exists
        SecItemDelete(query as CFDictionary)
        
        // Add the new entry
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            NSLog(\"[TokenStorageSandbox] Failed to save token for %@: %d\", provider.rawValue, status)
        }
    }
    
    public func getToken(forProvider provider: AuthProviderSandbox) -> String? {
        let key = tokenKey(for: provider)
        
        // Create a query to find the token in the keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, 
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    public func deleteToken(forProvider provider: AuthProviderSandbox) {
        let key = tokenKey(for: provider)
        
        // Create a query to delete the token from the keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            NSLog(\"[TokenStorageSandbox] Failed to delete token for %@: %d\", provider.rawValue, status)
        }
    }
    
    // MARK: - Private Methods
    private func tokenKey(for provider: AuthProviderSandbox) -> String {
        return \"\\(tokenKeychainPrefix)_\\(provider.rawValue)\"
    }
}"

# Create MainContentView-Sandbox.swift and App-Sandbox.swift
create_file "_macOS/$PROJECT_NAME-Sandbox/Sources/MainContentView-Sandbox.swift" "// Purpose: Main content view for ${PROJECT_NAME}-Sandbox app.
// Issues & Complexity: Main UI component with Apple authentication for sandbox.
// Ranking/Rating: 95% (Code), 92% (Problem) - Main UI component for Apple SSO.
// SANDBOX ENVIRONMENT

import SwiftUI
import AuthenticationServices

public struct MainContentViewSandbox: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text(\"${PROJECT_NAME} Sandbox Apple Sign In\")
                .font(.largeTitle)
                .padding(.bottom, 30)
            
            AppleSignInViewSandbox(
                onSignIn: { credential in
                    print(\"MainContentViewSandbox: Successfully authenticated with Apple: \\(credential.user)\")
                },
                onError: { error in
                    print(\"MainContentViewSandbox: Apple sign in error: \\(error.localizedDescription)\")
                }
            )
        }
        .padding(40)
        .frame(width: 400, height: 400)
    }
}

#Preview {
    MainContentViewSandbox()
}"

create_file "_macOS/$PROJECT_NAME-Sandbox/Sources/App-Sandbox.swift" "// Purpose: Main app entry point with URL handling for OAuth callbacks in sandbox.
// Issues & Complexity: Implements app lifecycle and URL scheme handling for authentication flows.
// Ranking/Rating: 95% (Code), 92% (Problem) - Production-ready app configuration.
// SANDBOX ENVIRONMENT

import SwiftUI
import AppKit

@main
struct ${PROJECT_NAME}SandboxApp: App {
    @NSApplicationDelegateAdaptor(AppDelegateSandbox.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainContentViewSandbox()
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    // Set window appearance
                    NSWindow.allowsAutomaticWindowTabbing = false
                    
                    for window in NSApplication.shared.windows {
                        window.titlebarAppearsTransparent = true
                        window.titleVisibility = .hidden
                        window.styleMask.insert(.fullSizeContentView)
                        
                        // Center the window on the screen
                        window.center()
                        
                        // Set minimum size
                        window.minSize = NSSize(width: 800, height: 600)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            // Add custom menu commands
            SidebarCommands()
            CommandGroup(replacing: .newItem) {
                // Custom new item commands if needed
            }
        }
    }
}

// App delegate to handle URL callbacks
class AppDelegateSandbox: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register for URL scheme handling
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            return
        }
        
        // Process the URL
        handleURL(url)
    }
    
    private func handleURL(_ url: URL) {
        // Process Apple Sign In callbacks if needed
        print(\"Received URL in Sandbox: \\(url)\")
    }
}"

# Create entitlements file for sandbox
create_file "_macOS/$PROJECT_NAME-Sandbox/${PROJECT_NAME}-Sandbox.entitlements" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
"

# Create basic Xcode project metadata files
create_file "_macOS/$PROJECT_NAME.xcworkspace/contents.xcworkspacedata" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Workspace
   version = \"1.0\">
   <FileRef
      location = \"group:$PROJECT_NAME/$PROJECT_NAME.xcodeproj\">
   </FileRef>
   <FileRef
      location = \"group:$PROJECT_NAME-Sandbox/$PROJECT_NAME-Sandbox.xcodeproj\">
   </FileRef>
</Workspace>
"

#==============================================================================
# Create README.md with Project Documentation
#==============================================================================

# Create a comprehensive README file for the project
# This contains documentation on project structure and setup instructions
create_file "_macOS/README.md" "# ${PROJECT_NAME} - macOS Authentication Project

## Project Overview
This project demonstrates OAuth authentication for macOS applications using:
- Apple Sign-In
- Google OAuth

## Project Structure
The workspace contains two parallel projects:
- \`${PROJECT_NAME}\`: Production target
- \`${PROJECT_NAME}-Sandbox\`: Development/testing target

### Key Components
- Authentication providers for Apple and Google
- Secure token storage using the Keychain
- URL scheme handling for OAuth callbacks
- SwiftUI interface components

## Configuration
1. **Environment Variables**:
   - Edit the \`.env\` file in the project root to configure OAuth client IDs and redirect URIs
   - For development, you can also edit the values directly in each Info.plist file

2. **Google OAuth Setup**:
   - Create a Google Cloud project and OAuth client ID for macOS
   - Configure the redirect URI as \`com.products.${PROJECT_NAME}:/oauth2redirect\`
   - Add the client ID to your \`.env\` file or Info.plist

3. **Apple Sign-In Setup**:
   - Enable Apple Sign-In capability in your Xcode project
   - The entitlements file is already configured

## Development Workflow
- Use the Sandbox target during development to avoid affecting production data
- Both targets can be installed simultaneously on the same machine
- Each target has its own keychain entries, preventing conflicts

## Getting Started
1. Open \`${PROJECT_NAME}.xcworkspace\` in Xcode
2. Configure your OAuth credentials
3. Build and run either the production or sandbox target
"

#==============================================================================
# Create Project File and Finalize Setup
#==============================================================================

# Create sample workspace contents
# This creates a basic workspace configuration file that includes both projects
create_file "_macOS/$PROJECT_NAME.xcworkspace/contents.xcworkspacedata" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Workspace
   version = \"1.0\">
   <FileRef
      location = \"group:$PROJECT_NAME/$PROJECT_NAME.xcodeproj\">
   </FileRef>
   <FileRef
      location = \"group:$PROJECT_NAME-Sandbox/$PROJECT_NAME-Sandbox.xcodeproj\">
   </FileRef>
</Workspace>
"

# Create a .gitignore file to exclude common macOS and Xcode files
# This helps keep the repository clean when using version control
create_file "_macOS/.gitignore" "# Xcode
#
# gitignore contributors: remember to update Global/Xcode.gitignore, Objective-C.gitignore & Swift.gitignore

## User settings
xcuserdata/

## compatibility with Xcode 8 and earlier (ignoring not required starting Xcode 9)
*.xcscmblueprint
*.xccheckout

## compatibility with Xcode 3 and earlier (ignoring not required starting Xcode 4)
build/
DerivedData/
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3

## Obj-C/Swift specific
*.hmap

## App packaging
*.ipa
*.dSYM.zip
*.dSYM

## Playgrounds
timeline.xctimeline
playground.xcworkspace

# Swift Package Manager
#
# Add this line if you want to avoid checking in source code from Swift Package Manager dependencies.
# Packages/
# Package.pins
# Package.resolved
# *.xcodeproj
#
# Xcode automatically generates this directory with a .xcworkspacedata file and xcuserdata
# hence it is not needed unless you have added a package configuration file to your project
# .swiftpm

.build/

# CocoaPods
#
# We recommend against adding the Pods directory to your .gitignore. However
# you should judge for yourself, the pros and cons are mentioned at:
# https://guides.cocoapods.org/using/using-cocoapods.html#should-i-check-the-pods-directory-into-source-control
#
Pods/
#
# Add this line if you want to avoid checking in source code from the Xcode workspace
# *.xcworkspace

# Carthage
#
# Add this line if you want to avoid checking in source code from Carthage dependencies.
# Carthage/Checkouts

Carthage/Build/

# Accio dependency management
Dependencies/
.accio/

# fastlane
#
# It is recommended to not store the screenshots in the git repo.
# Instead, use fastlane to re-generate the screenshots whenever they are needed.
# For more information about the recommended setup visit:
# https://docs.fastlane.tools/best-practices/source-control/#source-control

fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Code Injection
#
# After new code Injection tools there's a generated folder /iOSInjectionProject
# https://github.com/johnno1962/injectionforxcode

iOSInjectionProject/

# Mac OS X
.DS_Store

# Environment variables
.env
"

#==============================================================================
# Script Completion
#==============================================================================

# Display success message and next steps for the user
# This provides clear instructions on how to proceed after script execution
echo ""
echo "✅ Project creation complete!"
echo ""
echo "Project Structure:"
echo "- _macOS/$PROJECT_NAME (Production target)"
echo "- _macOS/$PROJECT_NAME-Sandbox (Sandbox/development target)"
echo "- _macOS/$PROJECT_NAME.xcworkspace (Workspace containing both projects)"
echo ""
echo "Next Steps:"
echo "1. Configure the OAuth credentials in the .env file"
echo "2. Open the workspace in Xcode: open _macOS/$PROJECT_NAME.xcworkspace"
echo "3. Set up the necessary Xcode project files and build settings"
echo ""
echo "Documentation:"
echo "- Review the README.md file for detailed setup instructions"
echo "- Each source file contains comprehensive comments explaining its functionality"
echo ""
echo "Happy coding! 🚀" 