import SwiftUI
import AuthenticationServices

/**
 * UniformSSOButton.swift
 * 
 * Purpose: Uniform SSO button component providing consistent styling across all authentication providers
 * Issues & Complexity Summary: Standardized button design with provider-specific branding
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~200
 *   - Core Algorithm Complexity: Low (UI styling, Button composition)
 *   - Dependencies: 2 (SwiftUI, AuthenticationServices)
 *   - State Management Complexity: Low (Button state only)
 *   - Novelty/Uncertainty Factor: Low (Standard UI component)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 88%
 * Overall Result Score: 93%
 * Key Variances/Learnings: Consistent button dimensions with provider-specific branding
 * Last Updated: 2025-08-04
 */

// MARK: - SSO Provider Configuration

struct SSOProvider {
    let id: String
    let title: String
    let iconName: String
    let backgroundColor: Color
    let foregroundColor: Color
    let isApple: Bool
    
    static let apple = SSOProvider(
        id: "apple",
        title: "Sign in with Apple",
        iconName: "apple.logo",
        backgroundColor: .black,
        foregroundColor: .white,
        isApple: true
    )
    
    static let google = SSOProvider(
        id: "google",
        title: "Sign in with Google",
        iconName: "g.circle.fill",
        backgroundColor: Color(red: 0.26, green: 0.52, blue: 0.96), // Google Blue
        foregroundColor: .white,
        isApple: false
    )
    
    static let microsoft = SSOProvider(
        id: "microsoft",
        title: "Sign in with Microsoft",
        iconName: "m.circle.fill",
        backgroundColor: Color(red: 0.0, green: 0.46, blue: 0.74), // Microsoft Blue
        foregroundColor: .white,
        isApple: false
    )
}

// MARK: - SSO Button Actions

struct SSOButtonActions {
    let onAppleSignIn: () -> Void
    let onGoogleSignIn: () -> Void
    let onMicrosoftSignIn: () -> Void
}

// MARK: - Uniform SSO Button

struct UniformSSOButton: View {
    let provider: SSOProvider
    let action: () -> Void
    let isLoading: Bool
    
    // Constants for uniform sizing
    private let buttonHeight: CGFloat = 50
    private let cornerRadius: CGFloat = 12
    private let iconSize: CGFloat = 20
    private let fontSize: CGFloat = 16
    
    init(provider: SSOProvider, isLoading: Bool = false, action: @escaping () -> Void) {
        self.provider = provider
        self.action = action
        self.isLoading = isLoading
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Loading indicator or icon
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: provider.foregroundColor))
                        .scaleEffect(0.8)
                        .frame(width: iconSize, height: iconSize)
                } else {
                    Image(systemName: provider.iconName)
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(provider.foregroundColor)
                        .frame(width: iconSize, height: iconSize)
                }
                
                Text(provider.title)
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(provider.foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(provider.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(provider.backgroundColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .accessibility(identifier: "\(provider.id)SSOButton")
        .accessibility(label: Text(provider.title))
        .accessibility(hint: Text("Double tap to sign in with \(provider.id)"))
    }
}

// MARK: - Apple-Specific SSO Button (using native SignInWithAppleButton with uniform sizing)

struct UniformAppleSSOButton: View {
    let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onCompletion: (Result<ASAuthorization, Error>) -> Void
    let isLoading: Bool
    
    // Constants for uniform sizing - SAME AS OTHER BUTTONS
    private let buttonHeight: CGFloat = 50
    private let cornerRadius: CGFloat = 12
    
    init(
        isLoading: Bool = false,
        onRequest: @escaping (ASAuthorizationAppleIDRequest) -> Void,
        onCompletion: @escaping (Result<ASAuthorization, Error>) -> Void
    ) {
        self.isLoading = isLoading
        self.onRequest = onRequest
        self.onCompletion = onCompletion
    }
    
    var body: some View {
        ZStack {
            // Native Apple Sign-In button with uniform dimensions
            SignInWithAppleButton(onRequest: onRequest, onCompletion: onCompletion)
                .frame(height: buttonHeight)
                .signInWithAppleButtonStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            
            // Loading overlay if needed
            if isLoading {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.black.opacity(0.8))
                    .frame(height: buttonHeight)
                    .overlay(
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            
                            Text("Signing in...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    )
            }
        }
        .accessibility(identifier: "AppleSSOButton")
        .accessibility(label: Text("Sign in with Apple"))
        .accessibility(hint: Text("Double tap to sign in with Apple ID"))
    }
}

// MARK: - SSO Button Group Component

struct SSOButtonGroup: View {
    let actions: SSOButtonActions
    let isLoading: Bool
    let appleSSOCompletion: (ASAuthorizationAppleIDRequest) -> Void
    let appleSSOOnCompletion: (Result<ASAuthorization, Error>) -> Void
    
    init(
        actions: SSOButtonActions,
        isLoading: Bool = false,
        appleSSOCompletion: @escaping (ASAuthorizationAppleIDRequest) -> Void,
        appleSSOOnCompletion: @escaping (Result<ASAuthorization, Error>) -> Void
    ) {
        self.actions = actions
        self.isLoading = isLoading
        self.appleSSOCompletion = appleSSOCompletion
        self.appleSSOOnCompletion = appleSSOOnCompletion
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Apple Sign-In (native button with uniform sizing)
            UniformAppleSSOButton(
                isLoading: isLoading,
                onRequest: appleSSOCompletion,
                onCompletion: appleSSOOnCompletion
            )
            
            // Google Sign-In
            UniformSSOButton(
                provider: .google,
                isLoading: isLoading,
                action: actions.onGoogleSignIn
            )
            
            // Microsoft Sign-In
            UniformSSOButton(
                provider: .microsoft,
                isLoading: isLoading,
                action: actions.onMicrosoftSignIn
            )
        }
    }
}

// MARK: - SSO Section with Divider

struct SSOSectionWithDivider: View {
    let actions: SSOButtonActions
    let isLoading: Bool
    let appleSSOCompletion: (ASAuthorizationAppleIDRequest) -> Void
    let appleSSOOnCompletion: (Result<ASAuthorization, Error>) -> Void
    
    var body: some View {
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
            
            // SSO Buttons with uniform styling
            SSOButtonGroup(
                actions: actions,
                isLoading: isLoading,
                appleSSOCompletion: appleSSOCompletion,
                appleSSOOnCompletion: appleSSOOnCompletion
            )
        }
    }
}

// MARK: - Preview

struct UniformSSOButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Uniform SSO Buttons")
                .font(.headline)
            
            VStack(spacing: 12) {
                UniformSSOButton(provider: .apple) {
                    print("Apple Sign-In tapped")
                }
                
                UniformSSOButton(provider: .google) {
                    print("Google Sign-In tapped")
                }
                
                UniformSSOButton(provider: .microsoft) {
                    print("Microsoft Sign-In tapped")
                }
                
                UniformSSOButton(provider: .google, isLoading: true) {
                    print("Loading button")
                }
            }
            
            Divider()
            
            SSOSectionWithDivider(
                actions: SSOButtonActions(
                    onAppleSignIn: { print("Apple") },
                    onGoogleSignIn: { print("Google") },
                    onMicrosoftSignIn: { print("Microsoft") }
                ),
                appleSSOCompletion: { _ in },
                appleSSOOnCompletion: { _ in }
            )
        }
        .padding()
        .previewDisplayName("Uniform SSO Buttons")
    }
}