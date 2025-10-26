//
//  OfflineBanner.swift
//  FinanceMate
//
//  Purpose: Displays offline status banner with pending operations count
//  BLUEPRINT Requirement: Line 298 - Offline Functionality UI indicator
//  Architecture: Simple SwiftUI view with glassmorphism design
//

import SwiftUI
import Network

/// Banner displayed when app is offline showing connection status
struct OfflineBanner: View {
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @State private var pendingOperationsCount: Int = 0

    var body: some View {
        HStack(spacing: 12) {
            // Offline icon
            Image(systemName: "wifi.slash")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            // Status text
            VStack(alignment: .leading, spacing: 2) {
                Text("Offline Mode")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)

                if pendingOperationsCount > 0 {
                    Text("\(pendingOperationsCount) operations queued for sync")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                } else {
                    Text("All changes will sync when online")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Spacer()

            // Connection type indicator
            if let connectionType = networkMonitor.connectionType {
                connectionTypeIcon(connectionType)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.orange.gradient)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func connectionTypeIcon(_ type: NWInterface.InterfaceType) -> some View {
        let iconName: String
        switch type {
        case .wifi:
            iconName = "wifi"
        case .cellular:
            iconName = "antenna.radiowaves.left.and.right"
        case .wiredEthernet:
            iconName = "cable.connector"
        default:
            iconName = "network"
        }

        return Image(systemName: iconName)
            .font(.system(size: 14))
            .foregroundStyle(.white.opacity(0.8))
    }
}

#Preview {
    OfflineBanner()
        .environmentObject(NetworkMonitor())
}
