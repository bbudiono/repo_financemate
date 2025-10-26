//
//  NetworkMonitor.swift
//  FinanceMate
//
//  Purpose: Monitors network connectivity status using Apple's Network framework
//  BLUEPRINT Requirement: Line 298 - Offline Functionality
//  Architecture: Simple singleton ObservableObject for SwiftUI integration
//

import Foundation
import Network
import Combine

/// Monitors network connectivity status and connection type
/// Uses Apple's NWPathMonitor for reliable network state detection
final class NetworkMonitor: ObservableObject {
    // MARK: - Published Properties

    /// Current network connectivity status
    @Published private(set) var isConnected: Bool = true

    /// Current connection type (wifi, cellular, ethernet, etc.)
    @Published private(set) var connectionType: NWInterface.InterfaceType?

    /// User-friendly connection status description
    @Published private(set) var connectionDescription: String = "Connected"

    // MARK: - Private Properties

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.financemate.networkmonitor")
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    /// Starts network monitoring
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                // Update connection status
                self.isConnected = path.status == .satisfied

                // Update connection type
                if let interface = path.availableInterfaces.first {
                    self.connectionType = interface.type
                } else {
                    self.connectionType = nil
                }

                // Update user-friendly description
                self.updateConnectionDescription(path: path)
            }
        }

        monitor.start(queue: queue)
    }

    /// Stops network monitoring
    func stopMonitoring() {
        monitor.cancel()
    }

    // MARK: - Private Methods

    private func updateConnectionDescription(path: NWPath) {
        if !isConnected {
            connectionDescription = "Offline"
            return
        }

        guard let type = connectionType else {
            connectionDescription = "Connected"
            return
        }

        switch type {
        case .wifi:
            connectionDescription = "Connected via WiFi"
        case .cellular:
            connectionDescription = "Connected via Cellular"
        case .wiredEthernet:
            connectionDescription = "Connected via Ethernet"
        case .loopback:
            connectionDescription = "Local Connection"
        case .other:
            connectionDescription = "Connected"
        @unknown default:
            connectionDescription = "Connected"
        }
    }
}
