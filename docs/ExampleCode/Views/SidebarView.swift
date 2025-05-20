import SwiftUI

/**
 * SidebarView
 *
 * The primary navigation sidebar for EduTrackQLD.
 * Provides navigation links to all main sections of the application.
 *
 * Version: 0.5.3 (Build 8)
 */
@available(macOS 13.0, *)
struct SidebarView: View {
    /// Binding to the currently selected navigation item
    @Binding var selection: NavigationItemTag
    
    /// Environment object for app state access
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        List(selection: $selection) {
            // Navigation links using the enum values for consistency
            ForEach(NavigationItemTag.allCases, id: \.self) { item in
                NavigationLink(value: item) {
                    Label(item.displayName, systemImage: item.iconName)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
        .onChange(of: selection) { newValue in
            // Log navigation change when selection changes
            appState.logNavigationChange(to: newValue)
        }
    }
}

// Preview
struct SidebarView_Previews: PreviewProvider {
    @State static var selection = NavigationItemTag.dashboard
    
    static var previews: some View {
        SidebarView(selection: $selection)
            .environmentObject(AppState())
    }
}
