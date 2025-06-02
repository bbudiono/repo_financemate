// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  UserProfileView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: User profile management interface with authentication controls in Sandbox environment
* Issues & Complexity Summary: User profile editing, session management, and account controls
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~350
  - Core Algorithm Complexity: Medium
  - Dependencies: 4 New (ProfileEditing, SessionDisplay, AccountManagement, UserExperience)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 67%
* Justification for Estimates: Standard profile UI with authentication integration
* Final Code Complexity (Actual %): TBD - Implementation in progress
* Overall Result Score (Success & Quality %): TBD - TDD development
* Key Variances/Learnings: Focus on user control and authentication state display
* Last Updated: 2025-06-02
*/

import SwiftUI

// MARK: - User Profile View

struct UserProfileView: View {
    
    // MARK: - State Properties
    
    @StateObject private var authService = AuthenticationService()
    @StateObject private var sessionManager = UserSessionManager()
    
    @State private var editingDisplayName = false
    @State private var editingEmail = false
    @State private var displayNameText = ""
    @State private var emailText = ""
    @State private var showingSignOutAlert = false
    @State private var showingSessionInfo = false
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header with Sandbox indicator
                    headerSection
                    
                    // User Information Card
                    if let user = authService.currentUser {
                        userInfoCard(user: user)
                    }
                    
                    // Session Information
                    sessionInfoSection
                    
                    // Account Actions
                    accountActionsSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await authService.signOut()
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to sign out? You'll need to sign in again to access your account.")
        }
        .sheet(isPresented: $showingSessionInfo) {
            sessionDetailsSheet
        }
        .onAppear {
            loadUserData()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Account Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Manage your profile and preferences")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("🧪 SANDBOX")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(8)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
        }
    }
    
    private func userInfoCard(user: AuthenticatedUser) -> some View {
        VStack(spacing: 20) {
            // Profile Avatar
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(user.provider == .apple ? Color.black : Color.blue)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: user.provider == .apple ? "applelogo" : "globe")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text("Signed in with \(user.provider.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if user.isEmailVerified {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("Verified Account")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Divider()
            
            // User Details
            VStack(spacing: 16) {
                // Display Name
                profileField(
                    label: "Display Name",
                    value: user.displayName,
                    isEditing: editingDisplayName,
                    editText: $displayNameText,
                    onEdit: { editingDisplayName = true },
                    onSave: { saveDisplayName() },
                    onCancel: { cancelDisplayNameEdit() }
                )
                
                // Email
                profileField(
                    label: "Email",
                    value: user.email,
                    isEditing: editingEmail,
                    editText: $emailText,
                    onEdit: { editingEmail = true },
                    onSave: { saveEmail() },
                    onCancel: { cancelEmailEdit() }
                )
                
                // Account Created
                HStack {
                    Text("Member since")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(user.createdAt, style: .date)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(20)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var sessionInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Session Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Details") {
                    showingSessionInfo = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Session Status")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(sessionManager.isSessionActive ? .green : .red)
                            .frame(width: 8, height: 8)
                        
                        Text(sessionManager.isSessionActive ? "Active" : "Inactive")
                            .fontWeight(.medium)
                            .foregroundColor(sessionManager.isSessionActive ? .green : .red)
                    }
                }
                
                if sessionManager.isSessionActive {
                    HStack {
                        Text("Session Duration")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatDuration(sessionManager.sessionDuration))
                            .fontWeight(.medium)
                    }
                    
                    if let lastActivity = sessionManager.lastActivityDate {
                        HStack {
                            Text("Last Activity")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(lastActivity, style: .relative)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var accountActionsSection: some View {
        VStack(spacing: 12) {
            Text("Account Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                Button(action: {
                    Task {
                        do {
                            try await authService.refreshAuthentication()
                        } catch {
                            print("Failed to refresh authentication: \(error)")
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Authentication")
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                .disabled(authService.isLoading)
                
                Button(action: {
                    sessionManager.extendSession()
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Extend Session")
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
                .disabled(!sessionManager.isSessionActive)
                
                Button(action: {
                    showingSignOutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var sessionDetailsSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let analytics = sessionManager.getSessionAnalytics() {
                    VStack(spacing: 16) {
                        Text("Session Analytics")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            analyticsRow("Session ID", analytics.sessionId)
                            analyticsRow("Total Duration", formatDuration(analytics.totalDuration))
                            analyticsRow("Activity Count", "\(analytics.activityCount)")
                            analyticsRow("Extensions", "\(analytics.extensionCount)")
                            analyticsRow("Avg Activity Interval", formatDuration(analytics.averageActivityInterval))
                            analyticsRow("Status", analytics.isActive ? "Active" : "Inactive")
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Session Details")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Close") {
                        showingSessionInfo = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func profileField(
        label: String,
        value: String,
        isEditing: Bool,
        editText: Binding<String>,
        onEdit: @escaping () -> Void,
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            if isEditing {
                TextField(label, text: editText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Save") {
                    onSave()
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                Button("Cancel") {
                    onCancel()
                }
                .font(.caption)
                .foregroundColor(.red)
            } else {
                Text(value)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button("Edit") {
                    onEdit()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
    }
    
    private func analyticsRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func loadUserData() {
        if let user = authService.currentUser {
            displayNameText = user.displayName
            emailText = user.email
        }
    }
    
    private func saveDisplayName() {
        Task {
            do {
                let update = UserProfileUpdate(displayName: displayNameText)
                try await authService.updateUserProfile(update)
                editingDisplayName = false
            } catch {
                print("Failed to update display name: \(error)")
            }
        }
    }
    
    private func saveEmail() {
        Task {
            do {
                let update = UserProfileUpdate(email: emailText)
                try await authService.updateUserProfile(update)
                editingEmail = false
            } catch {
                print("Failed to update email: \(error)")
            }
        }
    }
    
    private func cancelDisplayNameEdit() {
        editingDisplayName = false
        if let user = authService.currentUser {
            displayNameText = user.displayName
        }
    }
    
    private func cancelEmailEdit() {
        editingEmail = false
        if let user = authService.currentUser {
            emailText = user.email
        }
    }
}

// MARK: - Preview

#Preview {
    UserProfileView()
}