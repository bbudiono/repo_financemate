import SwiftUI

/// Warning banner for devices lacking Foundation Models capability (BLUEPRINT Line 161)
struct CapabilityWarningBanner: View {
    let capabilities: ExtractionCapabilityDetector.Capabilities
    @State private var isDismissed = false

    var body: some View {
        if !capabilities.foundationModelsAvailable && !isDismissed {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Limited Extraction Capability")
                        .font(.headline)

                    Text("Advanced extraction requires macOS 26+ with Apple Intelligence. Using basic regex (54% accuracy).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button("Remind Me Later") {
                        isDismissed = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)

                    Button("Open System Settings") {
                        openSystemSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }

    private func openSystemSettings() {
        // Try Apple Intelligence settings first, fallback to General
        if let url = URL(string: "x-apple.systempreferences:com.apple.AppleIntelligence-Settings.extension") {
            NSWorkspace.shared.open(url)
        } else if let url = URL(string: "x-apple.systempreferences:com.apple.preferences.general") {
            NSWorkspace.shared.open(url)
        }
    }
}
