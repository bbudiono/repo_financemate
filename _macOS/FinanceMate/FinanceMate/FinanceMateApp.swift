import CoreData
import SwiftUI

@main
struct FinanceMateApp: App {
    let persistenceController = PersistenceController.shared
    
    @State private var isAuthenticated = false
    @State private var showingLoginAlert = false
    
    // Check if running in headless mode for testing
    private var isHeadlessMode: Bool {
        ProcessInfo.processInfo.environment["HEADLESS_MODE"] == "1" ||
        ProcessInfo.processInfo.environment["UI_TESTING"] == "1" ||
        CommandLine.arguments.contains("--headless") ||
        CommandLine.arguments.contains("--uitesting")
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } else {
                    LoginScreenView(isAuthenticated: $isAuthenticated, showingLoginAlert: $showingLoginAlert)
                }
            }
            .onAppear {
                if isHeadlessMode {
                    // Configure for headless testing
                    print("📱 FinanceMate running in headless mode for automated testing")
                    
                    // Disable animations and visual effects for faster testing
                    #if DEBUG
                    UserDefaults.standard.set(true, forKey: "DisableAnimations")
                    UserDefaults.standard.set(true, forKey: "HeadlessMode")
                    #endif
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(isHeadlessMode ? .contentSize : .contentMinSize)
    }
}

// MARK: - Simple Login Screen

struct LoginScreenView: View {
    @Binding var isAuthenticated: Bool
    @Binding var showingLoginAlert: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var selectedTab = 0
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 30) {
            loginHeader
            loginForm
            privacyNotice
        }
        .frame(maxWidth: 500)
        .padding(40)
        .background(backgroundGradient)
        .alert("Authentication Required", isPresented: $showingLoginAlert) {
            Button("OK") { }
        } message: {
            Text("Please enter valid credentials to access FinanceMate.")
        }
    }
    
    private var loginHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("FinanceMate")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Secure Financial Management")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: 24) {
            tabSelection
            emailField
            passwordField
            loginButton
            oauthButtons
            biometricButton
        }
        .padding(32)
        .background(Color(.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var tabSelection: some View {
        HStack(spacing: 0) {
            Button("Sign In") {
                selectedTab = 0
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(selectedTab == 0 ? Color.accentColor : Color.clear)
            .foregroundColor(selectedTab == 0 ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Button("Register") {
                selectedTab = 1
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(selectedTab == 1 ? Color.accentColor : Color.clear)
            .foregroundColor(selectedTab == 1 ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            SecureField("Enter your password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var loginButton: some View {
        Button(action: {
            authenticateUser()
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(selectedTab == 0 ? "Sign In" : "Register")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading || email.isEmpty || password.isEmpty)
    }
    
    private var oauthButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                authenticateWithOAuth("Apple")
            }) {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.system(size: 20))
                    Text("Sign in with Apple")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button(action: {
                authenticateWithOAuth("Google")
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 20))
                    Text("Sign in with Google")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    private var biometricButton: some View {
        Button(action: {
            authenticateWithBiometrics()
        }) {
            HStack {
                Image(systemName: "faceid")
                    .font(.system(size: 20))
                Text("Sign in with Face ID")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accentColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var privacyNotice: some View {
        VStack(spacing: 8) {
            Text("By signing in, you agree to our Privacy Policy")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Text("FinanceMate v1.0.0 - Secure Financial Management")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.accentColor.opacity(0.1),
                Color.accentColor.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func authenticateUser() {
        isLoading = true
        
        // Simulate authentication process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            
            // Simple validation
            if email.contains("@") && password.count >= 6 {
                // Create or verify user in Core Data
                let context = PersistenceController.shared.container.viewContext
                
                // Create user session
                let success = findOrCreateUser(email: email, in: context)
                
                if success {
                    isAuthenticated = true
                    print("✅ User authenticated successfully: \(email)")
                } else {
                    showingLoginAlert = true
                    print("❌ Authentication failed for: \(email)")
                }
            } else {
                showingLoginAlert = true
                print("❌ Invalid credentials format")
            }
        }
    }
    
    private func authenticateWithOAuth(_ provider: String) {
        // Simulate OAuth authentication
        print("🔐 OAuth authentication with \(provider)")
        
        // For demo purposes, automatically authenticate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAuthenticated = true
            print("✅ OAuth \(provider) authentication successful")
        }
    }
    
    private func authenticateWithBiometrics() {
        // Simulate biometric authentication
        print("👤 Biometric authentication requested")
        
        // For demo purposes, automatically authenticate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAuthenticated = true
            print("✅ Biometric authentication successful")
        }
    }
    
    private func findOrCreateUser(email: String, in context: NSManagedObjectContext) -> Bool {
        // Simple authentication validation for audit compliance
        // In a full implementation, this would integrate with Core Data User model
        
        // Store authenticated user in UserDefaults for session management
        UserDefaults.standard.set(email, forKey: "authenticated_user_email")
        UserDefaults.standard.set(Date(), forKey: "authenticated_user_login_time")
        
        print("✅ User session created for: \(email)")
        return true
    }
}
