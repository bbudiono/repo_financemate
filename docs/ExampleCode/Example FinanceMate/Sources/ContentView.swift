import SwiftUI

struct ContentView: View {
    @State private var selectedSidebarItem: SidebarItem? = .dashboard
    
    var body: some View {
        NavigationView {
            SidebarView(selection: $selectedSidebarItem)
                .frame(minWidth: 200)
            
            mainContent
                .frame(minWidth: 600, idealWidth: 800)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        switch selectedSidebarItem {
        case .dashboard:
            DashboardView()
        case .documents:
            DocumentsView()
        case .upload:
            DocumentUploadView()
        case .settings:
            SettingsView()
        case .profile:
            ProfileView()
        case nil:
            EmptyView()
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

enum SidebarItem: String, Identifiable, CaseIterable {
    case dashboard
    case documents
    case upload
    case settings
    case profile
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .dashboard: return "gauge"
        case .documents: return "folder"
        case .upload: return "arrow.up.doc"
        case .settings: return "gear"
        case .profile: return "person.crop.circle"
        }
    }
    
    var name: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .documents: return "Documents"
        case .upload: return "Upload"
        case .settings: return "Settings"
        case .profile: return "Profile"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 