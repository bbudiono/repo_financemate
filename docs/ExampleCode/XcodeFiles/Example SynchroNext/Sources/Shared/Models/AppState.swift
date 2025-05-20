// Copyright (c) $(date +\"%Y\") {CompanyName}
// Version: 1.0.0
// Purpose: Global application state management for SynchroNext.
// Issues & Complexity: Moderate abstraction, sharing across views. Low complexity.
// Ranking/Rating: 80% (Code), standard ObservableObject for app state.
// Last Updated: 2024-07-15

import SwiftUI
import Combine

/// Manages global application state for SynchroNext
class AppState: ObservableObject {
    // UI state
    @Published var isNewDocumentSheetPresented = false
    @Published var isSettingsSheetPresented = false
    @Published var selectedSidebarItem: String? = "inbox"
    
    // Sync state
    @Published var isSyncing = false
    @Published var lastSyncDate: Date? = nil
    @Published var syncProgress: Double = 0.0
    
    // Error handling
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert = false
    
    init() {
        // Load last sync date from UserDefaults
        if let lastSyncTimeInterval = UserDefaults.standard.object(forKey: "LastSyncDate") as? TimeInterval {
            lastSyncDate = Date(timeIntervalSince1970: lastSyncTimeInterval)
        }
    }
    
    // MARK: - Methods
    
    func sync() {
        guard !isSyncing else { return }
        
        isSyncing = true
        syncProgress = 0.0
        
        // Simulate sync process
        let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        
        var cancellable: AnyCancellable?
        cancellable = timer.sink { [weak self] _ in
            guard let self = self else {
                cancellable?.cancel()
                return
            }
            
            if self.syncProgress < 1.0 {
                self.syncProgress += 0.2
            } else {
                self.isSyncing = false
                self.lastSyncDate = Date()
                
                // Save last sync date to UserDefaults
                UserDefaults.standard.set(self.lastSyncDate?.timeIntervalSince1970, forKey: "LastSyncDate")
                
                cancellable?.cancel()
            }
        }
    }
    
    func showError(_ message: String) {
        self.errorMessage = message
        self.showErrorAlert = true
    }
    
    func clearError() {
        self.errorMessage = nil
        self.showErrorAlert = false
    }
} 