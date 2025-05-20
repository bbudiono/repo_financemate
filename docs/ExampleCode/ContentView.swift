import SwiftUI

enum SidebarItem: String, Hashable, CaseIterable, Identifiable {
    case home = "Home"
    case about = "About Us"
    case profile = "Profile"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .about: return "info.circle"
        case .profile: return "person.crop.circle"
        }
    }
}

struct ContentView: View {
    @State private var selection: SidebarItem? = .home
    @State private var currentUser: MockUser? = MockUser(name: "Test User", email: "test@example.com")
    
    var body: some View {
        NavigationSplitView {
            // Left sidebar
            List(SidebarItem.allCases, selection: $selection) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.icon)
                        .accessibilityIdentifier(item.rawValue)
                }
            }
            .navigationTitle("Picketmate")
            .accessibilityIdentifier("SidebarList")
        } detail: {
            // Main detail view
            switch selection {
            case .home:
                LandingView()
                    .accessibilityIdentifier("LandingView")
            case .about:
                AboutUsView()
                    .accessibilityIdentifier("AboutUsView")
            case .profile:
                ProfileView(
                    user: currentUser,
                    onGoogleSignIn: signIn,
                    onSignOut: signOut
                )
                .accessibilityIdentifier("ProfileView")
            case nil:
                Text("Select an item from the sidebar")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityIdentifier("EmptySelectionView")
            }
        }
        .frame(minWidth: 700, minHeight: 400)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ContentView")
    }
    
    private func signIn() {
        // In a real app, this would authenticate with Google
        currentUser = MockUser(name: "Test User", email: "test@example.com")
    }
    
    private func signOut() {
        // In a real app, this would sign the user out and clear credentials
        currentUser = nil
    }
}

#Preview {
    ContentView()
}
