import SwiftUI

/// # Complex Layout with Settings Sidebar (Conceptual)
/// Demonstrates a complex window layout with a resizable sidebar containing a detailed settings form.
/// Combines:
/// - HSplitView for layout
/// - Form, Section, Pickers, Toggles, Sliders, TextFields for settings
struct ComplexLayoutWithSettingsSidebar: View {
    // MARK: - State for Settings
    @State private var language: String = "English"
    @State private var workMode: String = "International"
    @State private var showHints: Bool = true
    @State private var theme: String = "Light"
    @State private var distanceUnit: String = "metric"
    @State private var angularUnit: String = "Degree"
    @State private var geoFormat: String = "decimal"
    @State private var brightness: Double = 0.5
    @State private var hue: Double = 0.0
    @State private var chroma: Double = 1.0
    
    // MARK: - Body
    var body: some View {
        HSplitView {
            // MARK: - Sidebar: Settings Form
            Form {
                Section(header: Text("General")) {
                    Picker("Language", selection: $language) {
                        Text("English").tag("English")
                        Text("Spanish").tag("Spanish")
                        Text("French").tag("French")
                    }
                    Picker("Work Mode", selection: $workMode) {
                        Text("International").tag("International")
                        Text("Domestic").tag("Domestic")
                    }
                    Toggle("Show Hints", isON: $showHints)
                    Picker("Theme", selection: $theme) {
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                }
                
                Section(header: Text("Unit Settings")) {
                    Picker("Distance Unit", selection: $distanceUnit) {
                        Text("metric").tag("metric")
                        Text("imperial").tag("imperial")
                    }
                    Picker("Angular Unit", selection: $angularUnit) {
                        Text("Degree").tag("Degree")
                        Text("Radians").tag("Radians")
                    }
                     Picker("Geo. Degree Format", selection: $geoFormat) {
                         Text("decimal").tag("decimal")
                         Text("DMS").tag("DMS")
                     }
                }
                
                Section(header: Text("Map Settings")) {
                    Text("Brightness")
                    Slider(value: $brightness)
                    Text("Hue")
                    Slider(value: $hue)
                    Text("Chroma")
                    Slider(value: $chroma)
                }
            }
            .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
            
            // MARK: - Main Content Area (Placeholder)
            VStack {
                Spacer()
                Text("Main Content Area")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("(e.g., Map, 3D Model, Document Editor)")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(minWidth: 400)
        }
        .navigationTitle("Application")
    }
}

// MARK: - Preview
struct ComplexLayoutWithSettingsSidebar_Previews: PreviewProvider {
    static var previews: some View {
        ComplexLayoutWithSettingsSidebar()
    }
} 