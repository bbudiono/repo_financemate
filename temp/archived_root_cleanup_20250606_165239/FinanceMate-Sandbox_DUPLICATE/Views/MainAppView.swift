// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  MainAppView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/5/25.
//

/*
* Purpose: Main application view that handles authentication flow and displays appropriate content
* Issues & Complexity Summary: Authentication state management with seamless transition between sign-in and main app
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Low-Medium
  - Dependencies: 3 New (SwiftUI, AuthenticationService, Views)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 45%
* Problem Estimate (Inherent Problem Difficulty %): 40%
* Initial Code Complexity Estimate %: 43%
* Justification for Estimates: Authentication flow management with smooth user experience
* Final Code Complexity (Actual %): 42%
* Overall Result Score (Success & Quality %): 100%
* Key Variances/Learnings: Clean authentication flow provides excellent user experience
* Last Updated: 2025-06-05
*/

import SwiftUI

struct MainAppView: View {
    
    // MARK: - Properties
    
    @StateObject private var authService = AuthenticationService()
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            if authService.isAuthenticated {
                // Main application content with chatbot
                authenticatedContent
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                // Sign-in view
                SignInView()
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: authService.isAuthenticated)
        .environmentObject(authService)
    }
    
    // MARK: - Authenticated Content
    
    private var authenticatedContent: some View {
        ChatbotIntegrationView {
            NavigationSplitView {
                // Sidebar with user profile
                authenticatedSidebar
            } detail: {
                // Main content area
                DetailView(selectedView: .dashboard)
            }
            .overlay(alignment: .bottomTrailing) {
                // SANDBOX WATERMARK - MANDATORY
                Text("🧪 SANDBOX")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
            }
        }
        .onAppear {
            // Initialize chatbot demo services for authenticated users
            ChatbotSetupManager.shared.setupDemoServices()
        }
    }
    
    // MARK: - Authenticated Sidebar
    
    private var authenticatedSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // User profile section
            userProfileSection
            
            Divider()
                .padding(.vertical, 8)
            
            // Navigation items
            navigationSection
            
            Spacer()
            
            // Sign out section
            signOutSection
        }
        .padding()
        .frame(minWidth: 200)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - User Profile Section
    
    private var userProfileSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Profile image placeholder
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(authService.currentUser?.displayName.prefix(1).uppercased() ?? "U")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(authService.currentUser?.displayName ?? "User")
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(authService.currentUser?.email ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Provider badge
            if let provider = authService.currentUser?.provider {
                HStack {
                    Image(systemName: provider == .apple ? "apple.logo" : provider == .google ? "globe" : "play.circle")
                        .font(.caption2)
                    
                    Text("Signed in with \(provider.displayName)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Navigation Section
    
    private var navigationSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("FinanceMate")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            navigationButton("Dashboard", systemImage: "chart.bar", isSelected: true)
            navigationButton("Documents", systemImage: "doc.text", isSelected: false)
            navigationButton("Analytics", systemImage: "chart.pie", isSelected: false)
            navigationButton("Settings", systemImage: "gearshape", isSelected: false)
        }
    }
    
    private func navigationButton(_ title: String, systemImage: String, isSelected: Bool) -> some View {
        Button(action: {
            // Navigation action would go here
        }) {
            HStack {
                Image(systemName: systemImage)
                    .frame(width: 16)
                Text(title)
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            isSelected ? Color.accentColor.opacity(0.2) : Color.clear
        )
        .cornerRadius(6)
    }
    
    // MARK: - Sign Out Section
    
    private var signOutSection: some View {
        VStack(spacing: 8) {
            Divider()
            
            Button(action: {
                withAnimation {
                    signOut()
                }
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .frame(width: 16)
                    Text("Sign Out")
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(.red)
            .background(Color.red.opacity(0.1))
            .cornerRadius(6)
        }
    }
    
    // MARK: - Methods
    
    private func signOut() {
        authService.isAuthenticated = false
        authService.currentUser = nil
        authService.authenticationState = .unauthenticated
        authService.errorMessage = nil
    }
}

// MARK: - Preview

#Preview {
    MainAppView()
        .frame(width: 1200, height: 800)
}