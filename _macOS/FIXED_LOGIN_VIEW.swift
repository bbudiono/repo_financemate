import SwiftUI
import AuthenticationServices

/**
 * FIXED LoginView.swift - P0 CRITICAL SSO Button Visibility Fix
 * 
 * Purpose: Resolve missing SSO buttons by simplifying view hierarchy and ensuring proper rendering
 * CRITICAL FIXES:
 * 1. Move SSO buttons outside of tab-specific forms to always be visible
 * 2. Simplify view hierarchy to prevent rendering issues
 * 3. Ensure SSO buttons appear on both Sign In and Register tabs
 * 4. Professional UI design to improve from 2/10 rating
 * 5. Clear visual hierarchy and proper accessibility
 */

struct FixedLoginView: View {
    
    @StateObject private var authViewModel = AuthenticationViewModel(
        context: PersistenceController.shared.container.viewContext
    )
    
    @State private var email = ""
    @State private var password = ""
    @State private var mfaCode = ""
    @State private var showingRegistration = false
    @State private var showingForgotPassword = false
    @State private var isPasswordVisible = false
    @State private var selectedTab = 0 // 0: Login, 1: Register
    
    // Focus states
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @FocusState private var mfaCodeFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundView
                
                // Main content
                VStack(spacing: 0) {
                    // Logo and title
                    headerView
                    
                    Spacer()
                    
                    // Authentication container - SIMPLIFIED HIERARCHY
                    authenticationContainer
                    
                    Spacer()
                    
                    // Footer
                    footerView
                }
                .frame(maxWidth: 500)
                .padding(.horizontal, 40)
                .padding(.vertical, 60)
                
                // Loading overlay
                if authViewModel.isLoading {
                    loadingOverlay
                }
            }
        }
        .frame(minWidth: 600, minHeight: 700)
        .background(Color(.windowBackgroundColor))
        .onAppear {
            emailFocused = true
            print("🔍 FIXED LOGIN VIEW: onAppear called, selectedTab: \(selectedTab), isMFARequired: \(authViewModel.isMFARequired)")
        }
        .alert("Authentication Error", isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button("OK") {
                authViewModel.errorMessage = nil
            }
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 24) {
            // App icon
            Image("AppIcon")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Title
            VStack(spacing: 8) {
                Text("FinanceMate")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Secure Financial Management")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .accessibility(identifier: "LoginHeader")
    }
    
    // MARK: - Authentication Container - SIMPLIFIED STRUCTURE
    
    private var authenticationContainer: some View {
        VStack(spacing: 32) {
            // Tab selection
            tabSelector
            
            // Form content based on state
            if authViewModel.isMFARequired {
                mfaView
            } else {
                // Main authentication content
                VStack(spacing: 24) {
                    // Traditional login/register forms
                    if selectedTab == 0 {
                        loginFormFields
                    } else {
                        registrationFormFields
                    }
                    
                    // SSO BUTTONS SECTION - ALWAYS VISIBLE FOR BOTH TABS
                    ssoButtonsSection
                }
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button(action: { 
                selectedTab = 0
                print("🔍 TAB: Switched to Sign In (0)")
            }) {
                Text("Sign In")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(selectedTab == 0 ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        selectedTab == 0 ? Color.accentColor : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: { 
                selectedTab = 1
                print("🔍 TAB: Switched to Register (1)")
            }) {
                Text("Register")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(selectedTab == 1 ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        selectedTab == 1 ? Color.accentColor : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibility(identifier: "AuthenticationTabs")
    }
    
    // MARK: - Login Form Fields
    
    private var loginFormFields: some View {
        VStack(spacing: 24) {
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .focused($emailFocused)
                    .onSubmit {
                        passwordFocused = true
                    }
                    .disableAutocorrection(true)
                    .accessibility(identifier: "EmailField")
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack {
                    Group {
                        if isPasswordVisible {
                            TextField("Enter your password", text: $password)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
                    }
                    .focused($passwordFocused)
                    .onSubmit {
                        Task {
                            await authViewModel.authenticate(email: email, password: password)
                        }
                    }
                    
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .textFieldStyle(CustomTextFieldStyle())
                .accessibility(identifier: "PasswordField")
            }
            
            // Forgot password link
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showingForgotPassword = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.accentColor)
            }
            
            // Sign in button
            Button(action: {
                Task {
                    await authViewModel.authenticate(email: email, password: password)
                }
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text("Sign In")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
            .buttonStyle(PlainButtonStyle())
            .accessibility(identifier: "SignInButton")
        }
    }
    
    // MARK: - Registration Form Fields
    
    @State private var registerName = ""
    @State private var registerEmail = ""
    @State private var registerPassword = ""
    @State private var confirmPassword = ""
    
    private var registrationFormFields: some View {
        VStack(spacing: 24) {
            // Name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Enter your full name", text: $registerName)
                    .textFieldStyle(CustomTextFieldStyle())
                    .accessibility(identifier: "NameField")
            }
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Enter your email", text: $registerEmail)
                    .textFieldStyle(CustomTextFieldStyle())
                    .disableAutocorrection(true)
                    .accessibility(identifier: "RegisterEmailField")
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                SecureField("Create a password", text: $registerPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .accessibility(identifier: "RegisterPasswordField")
            }
            
            // Confirm password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                SecureField("Confirm your password", text: $confirmPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .accessibility(identifier: "ConfirmPasswordField")
            }
            
            // Password requirements
            VStack(alignment: .leading, spacing: 4) {
                Text("Password Requirements:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: registerPassword.count >= 8 ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(registerPassword.count >= 8 ? .green : .secondary)
                        .font(.system(size: 12))
                    
                    Text("At least 8 characters")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: registerPassword == confirmPassword && !confirmPassword.isEmpty ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(registerPassword == confirmPassword && !confirmPassword.isEmpty ? .green : .secondary)
                        .font(.system(size: 12))
                    
                    Text("Passwords match")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding(.top, 8)
            
            // Register button
            Button(action: {
                Task {
                    await authViewModel.createAccount(
                        name: registerName,
                        email: registerEmail,
                        password: registerPassword
                    )
                }
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text("Create Account")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(authViewModel.isLoading || !isRegistrationValid)
            .buttonStyle(PlainButtonStyle())
            .accessibility(identifier: "RegisterButton")
        }
    }
    
    private var isRegistrationValid: Bool {
        return !registerName.isEmpty &&
               !registerEmail.isEmpty &&
               registerPassword.count >= 8 &&
               registerPassword == confirmPassword
    }
    
    // MARK: - SSO BUTTONS SECTION - ALWAYS VISIBLE
    
    private var ssoButtonsSection: some View {
        VStack(spacing: 20) {
            // OAuth divider
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary.opacity(0.3))
                
                Text("or")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary.opacity(0.3))
            }
            
            // SSO BUTTONS - PROMINENT AND ALWAYS VISIBLE
            VStack(spacing: 12) {
                // Sign in with Apple - ENHANCED VISIBILITY
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                        print("🍎 FIXED LOGIN: Apple Sign-In onRequest called - setting up authorization request")
                    },
                    onCompletion: { result in
                        print("🍎 FIXED LOGIN: Apple Sign-In onCompletion called with result: \(result)")
                        switch result {
                        case .success(let authorization):
                            print("🍎 FIXED LOGIN: SUCCESS - Processing authorization")
                            Task {
                                await authViewModel.processAppleSignInCompletion(authorization)
                            }
                        case .failure(let error):
                            print("🍎 FIXED LOGIN: FAILURE - \(error)")
                            authViewModel.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
                        }
                    }
                )
                .frame(height: 50)
                .signInWithAppleButtonStyle(.black)
                .accessibility(identifier: "SignInWithAppleButton")
                
                // Sign in with Google - ENHANCED VISIBILITY
                Button(action: {
                    print("🔵 FIXED LOGIN: Google button tapped")
                    Task {
                        await authViewModel.authenticateWithOAuth2(provider: .google)
                    }
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        Text("Sign in with Google")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibility(identifier: "SignInWithGoogleButton")
                
                // Sign in with Microsoft - ENHANCED VISIBILITY
                Button(action: {
                    print("🔷 FIXED LOGIN: Microsoft button tapped")
                    Task {
                        await authViewModel.authenticateWithOAuth2(provider: .microsoft)
                    }
                }) {
                    HStack {
                        Image(systemName: "m.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        Text("Sign in with Microsoft")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.indigo, Color.indigo.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibility(identifier: "SignInWithMicrosoftButton")
                
                // Biometric authentication
                biometricButton
            }
            .onAppear {
                print("🔍 SSO BUTTONS SECTION: onAppear called - SSO buttons should be visible")
            }
        }
    }
    
    // MARK: - MFA View
    
    private var mfaView: some View {
        VStack(spacing: 24) {
            // MFA header
            VStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("Multi-Factor Authentication")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Enter the 6-digit code from your authenticator app")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // MFA code field
            VStack(alignment: .leading, spacing: 8) {
                Text("Verification Code")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("000000", text: $mfaCode)
                    .textFieldStyle(CustomTextFieldStyle())
                    .focused($mfaCodeFocused)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .onChange(of: mfaCode) { newValue in
                        // Limit to 6 digits
                        if newValue.count > 6 {
                            mfaCode = String(newValue.prefix(6))
                        }
                        
                        // Auto-submit when 6 digits are entered
                        if newValue.count == 6 {
                            Task {
                                await authViewModel.verifyMFACode(newValue)
                            }
                        }
                    }
                    .accessibility(identifier: "MFACodeField")
            }
            
            // Verify button
            Button(action: {
                Task {
                    await authViewModel.verifyMFACode(mfaCode)
                }
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text("Verify")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(authViewModel.isLoading || mfaCode.count != 6)
            .buttonStyle(PlainButtonStyle())
            .accessibility(identifier: "VerifyMFAButton")
        }
        .onAppear {
            mfaCodeFocused = true
        }
    }
    
    // MARK: - Biometric Button
    
    private var biometricButton: some View {
        Button(action: {
            Task {
                await authViewModel.authenticateWithBiometrics()
            }
        }) {
            HStack {
                Image(systemName: "faceid")
                    .font(.system(size: 20))
                
                Text("Sign in with Face ID")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.accentColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(identifier: "BiometricSignInButton")
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(spacing: 16) {
            // Privacy policy
            HStack {
                Text("By signing in, you agree to our")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Button("Privacy Policy") {
                    // Open privacy policy
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.accentColor)
            }
            
            // Version info
            Text("FinanceMate v1.0.0")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Background
    
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.accentColor.opacity(0.1),
                Color.accentColor.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Authenticating...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(Color.black.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Custom Text Field Style

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @StateObject private var authViewModel = AuthenticationViewModel(
        context: PersistenceController.shared.container.viewContext
    )
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "key.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("Reset Password")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Enter your email address and we'll send you instructions to reset your password.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .disableAutocorrection(true)
            }
            
            // Reset button
            Button(action: {
                Task {
                    await authViewModel.resetPassword(email: email)
                    dismiss()
                }
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text("Send Reset Instructions")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(authViewModel.isLoading || email.isEmpty)
            .buttonStyle(PlainButtonStyle())
            
            // Cancel button
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(width: 400)
        .background(Color(.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

struct FixedLoginView_Previews: PreviewProvider {
    static var previews: some View {
        FixedLoginView()
            .previewDisplayName("Fixed Login View")
    }
}