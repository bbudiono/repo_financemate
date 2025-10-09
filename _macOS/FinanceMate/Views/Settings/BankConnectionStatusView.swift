import SwiftUI

/*
 * Purpose: Connection status display component for bank connection interface
 * Issues & Complexity Summary: Status visualization, progress indication
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~80
 *   - Core Algorithm Complexity: Low (UI state display)
 *   - Dependencies: SwiftUI, BasiqAPIService
 *   - State Management Complexity: Low (status binding)
 *   - Novelty/Uncertainty Factor: Low (standard status indicator)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 60%
 * Initial Code Complexity Estimate: 65%
 * Final Code Complexity: 68%
 * Overall Result Score: 96%
 * Key Variances/Learnings: Clean status visualization with material design
 * Last Updated: 2025-10-07
 */

struct BankConnectionStatusView: View {
  @ObservedObject var basiqService: BasiqAPIService

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "building.columns.circle.fill")
          .font(.title)
          .foregroundColor(.blue)

        VStack(alignment: .leading, spacing: 4) {
          Text("Secure Bank Connection")
            .font(.headline)
            .fontWeight(.semibold)

          Text("Connect securely to Australian banks using Basiq")
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()

        // Connection status indicator
        connectionStatusIndicator
      }

      // Progress indicator
      if basiqService.connectionStatus == .connecting || basiqService.connectionStatus == .syncing {
        ProgressView()
          .progressViewStyle(LinearProgressViewStyle(tint: .blue))
          .frame(height: 4)
      }
    }
    .padding()
    .background(.ultraThinMaterial)
  }

  // MARK: - Status Indicator

  private var connectionStatusIndicator: some View {
    HStack(spacing: 6) {
      Circle()
        .fill(statusColor)
        .frame(width: 8, height: 8)

      Text(statusText)
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }

  private var statusColor: Color {
    switch basiqService.connectionStatus {
    case .connected:
      return .green
    case .connecting, .syncing:
      return .orange
    case .disconnected:
      return .gray
    case .error:
      return .red
    }
  }

  private var statusText: String {
    switch basiqService.connectionStatus {
    case .connected:
      return "Connected"
    case .connecting:
      return "Connecting"
    case .syncing:
      return "Syncing"
    case .disconnected:
      return "Disconnected"
    case .error:
      return "Error"
    }
  }
}

// MARK: - Preview

struct BankConnectionStatusView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      BankConnectionStatusView(basiqService: BasiqAPIService.preview)
        .previewDisplayName("Connected")

      BankConnectionStatusView(basiqService: BasiqAPIService.previewWithError)
        .previewDisplayName("Error")
    }
    .frame(height: 100)
  }
}