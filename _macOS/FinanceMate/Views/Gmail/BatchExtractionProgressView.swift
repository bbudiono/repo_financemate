import SwiftUI

/// BLUEPRINT Line 150: Real-time batch extraction progress UI
/// Shows progress bar, processed/total count, error count, ETA, and cancel capability
struct BatchExtractionProgressView: View {
    @ObservedObject var viewModel: GmailViewModel

    var body: some View {
        if viewModel.isBatchProcessing {
            VStack(spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "envelope.arrow.triangle.branch")
                        .foregroundColor(.blue)
                    Text("Processing Emails")
                        .font(.headline)
                    Spacer()
                }

                // Progress Bar
                ProgressView(value: progressPercentage, total: 1.0) {
                    HStack {
                        Text(progressText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(progressPercentageText)
                            .font(.caption.monospaced())
                            .foregroundColor(.blue)
                    }
                }

                // Details Row
                HStack(spacing: 20) {
                    // Processed Count
                    DetailLabel(
                        icon: "checkmark.circle.fill",
                        color: .green,
                        text: "\(viewModel.batchProgressProcessed)/\(viewModel.batchProgressTotal)",
                        label: "Processed"
                    )

                    // Error Count
                    if viewModel.batchErrorCount > 0 {
                        DetailLabel(
                            icon: "exclamationmark.triangle.fill",
                            color: .orange,
                            text: "\(viewModel.batchErrorCount)",
                            label: "Errors"
                        )
                    }

                    // ETA
                    if let eta = viewModel.estimatedTimeRemaining, eta > 0 {
                        DetailLabel(
                            icon: "clock.fill",
                            color: .blue,
                            text: formatTimeRemaining(eta),
                            label: "ETA"
                        )
                    }

                    Spacer()
                }
                .font(.caption)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .padding(.horizontal)
        }
    }

    // MARK: - Computed Properties

    private var progressPercentage: Double {
        guard viewModel.batchProgressTotal > 0 else { return 0.0 }
        return Double(viewModel.batchProgressProcessed) / Double(viewModel.batchProgressTotal)
    }

    private var progressText: String {
        "Processing email \(viewModel.batchProgressProcessed) of \(viewModel.batchProgressTotal)"
    }

    private var progressPercentageText: String {
        let percentage = Int(progressPercentage * 100)
        return "\(percentage)%"
    }

    // MARK: - Helper Functions

    private func formatTimeRemaining(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return "\(Int(seconds))s"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            let remainingSeconds = Int(seconds.truncatingRemainder(dividingBy: 60))
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            let hours = Int(seconds / 3600)
            let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)h \(minutes)m"
        }
    }
}

/// Reusable detail label component for progress metrics
private struct DetailLabel: View {
    let icon: String
    let color: Color
    let text: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption2)
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.caption.monospaced())
                    .fontWeight(.semibold)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview("Processing") {
    @Previewable @StateObject var viewModel: GmailViewModel = {
        let vm = GmailViewModel(context: PersistenceController.preview.container.viewContext)
        vm.isBatchProcessing = true
        vm.batchProgressProcessed = 45
        vm.batchProgressTotal = 100
        vm.batchErrorCount = 2
        vm.estimatedTimeRemaining = 125.0
        return vm
    }()

    return VStack {
        BatchExtractionProgressView(viewModel: viewModel)
        Spacer()
    }
    .frame(width: 600, height: 200)
}

#Preview("Complete") {
    @Previewable @StateObject var viewModel: GmailViewModel = {
        let vm = GmailViewModel(context: PersistenceController.preview.container.viewContext)
        vm.isBatchProcessing = false
        vm.batchProgressProcessed = 100
        vm.batchProgressTotal = 100
        return vm
    }()

    return VStack {
        BatchExtractionProgressView(viewModel: viewModel)
        Text("Progress complete - component hidden")
            .foregroundColor(.secondary)
        Spacer()
    }
    .frame(width: 600, height: 200)
}
