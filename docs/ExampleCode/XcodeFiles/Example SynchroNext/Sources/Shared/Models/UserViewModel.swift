// Copyright (c) $(date +\"%Y\") {CompanyName}
// Version: 1.0.0
// Purpose: User data model for the SynchroNext app. 
// Issues & Complexity: Moderate abstraction. Low complexity.
// Ranking/Rating: 85% (Code), a standard Observable object for user state.
// Last Updated: 2024-07-15

import SwiftUI
import Combine

/// Represents a user in the system
struct User {
    let id: String
    let displayName: String
    let email: String
    let profileImageURL: URL?
}

/// Manages user authentication state and profile data
class UserViewModel: ObservableObject {
    @Published var user: User
    @Published var isAuthenticated: Bool = false
    private var apiToken: String
    private var cancellables = Set<AnyCancellable>()
    
    init(key: String) {
        self.apiToken = key
        self.user = User(
            id: "user123",
            displayName: "Demo User",
            email: "demo@example.com",
            profileImageURL: nil
        )
        
        // Set authenticated if we have a valid API token
        self.isAuthenticated = !key.isEmpty
        
        // In a real app, validate the token and fetch user details
        if !key.isEmpty {
            fetchUserProfile()
        }
    }
    
    func signOut() {
        self.isAuthenticated = false
        self.apiToken = ""
        UserDefaults.standard.set("", forKey: "SyncAPIToken")
    }
    
    func signIn(withToken token: String) {
        self.apiToken = token
        self.isAuthenticated = true
        UserDefaults.standard.set(token, forKey: "SyncAPIToken")
        fetchUserProfile()
    }
    
    private func fetchUserProfile() {
        // In a real app, make API call to fetch user profile
        print("Fetching user profile with token: \(apiToken)")
        
        // Simulate API call with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Update user info
            self.user = User(
                id: "user123",
                displayName: "Authenticated User",
                email: "user@example.com",
                profileImageURL: URL(string: "https://example.com/avatar.jpg")
            )
        }
    }
} 