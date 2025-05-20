//
//  WelcomePopupViewModel.swift
//  EduTrackQLD
//
//  Created by AI Assistant on 2025-05-12.
//

import Foundation
import SwiftUI

class WelcomePopupViewModel: ObservableObject {
    private let appLaunchManager = AppLaunchManager.shared
    
    // Check if welcome popup should be shown
    func shouldShowWelcomePopup() -> Bool {
        return appLaunchManager.shouldShowWelcomePopup()
    }
    
    // Mark welcome popup as shown to prevent showing it again
    func markWelcomePopupAsShown() {
        appLaunchManager.markWelcomePopupAsShown()
    }
} 