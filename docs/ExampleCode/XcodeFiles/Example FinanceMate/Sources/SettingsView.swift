import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var syncFrequency = "Hourly"
    
    var body: some View {
        Form {
            Section(header: Text("General")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                Toggle("Dark Mode", isOn: $darkModeEnabled)
                
                Picker("Sync Frequency", selection: $syncFrequency) {
                    Text("Hourly").tag("Hourly")
                    Text("Daily").tag("Daily")
                    Text("Weekly").tag("Weekly")
                }
                .pickerStyle(DefaultPickerStyle())
            }
            
            Section(header: Text("Account")) {
                Button("Reset Preferences") {
                    // Reset preferences action
                }
                
                Button("Log Out") {
                    // Log out action
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(maxWidth: 600)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 