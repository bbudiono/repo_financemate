//
// GuidanceOverlayTypes.swift
// FinanceMate
//
// Guidance Overlay Types and Data Structures
// Created: 2025-08-03
// Target: FinanceMate
//

/*
 * Purpose: Type definitions and data structures for guidance overlay system
 * Issues & Complexity Summary: Swift enums, structs, type definitions
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~50
   - Core Algorithm Complexity: Low
   - Dependencies: Foundation, SwiftUI
   - State Management Complexity: Low (type definitions only)
   - Novelty/Uncertainty Factor: Low (standard Swift types)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 95%
 * Initial Code Complexity Estimate: 95%
 * Final Code Complexity: 95%
 * Overall Result Score: 95%
 * Key Variances/Learnings: Simple type definitions - no complexity variances
 * Last Updated: 2025-08-03
 */

import Foundation

// MARK: - Presentation Style Types

enum OverlayPresentationStyle: String {
    case minimal = "minimal"
    case detailed = "detailed"
    case immersive = "immersive"
}

enum OverlayLayoutMode: String {
    case modal = "modal"
    case sidebar = "sidebar"
    case tooltip = "tooltip"
    case banner = "banner"
}

enum ScreenSize: String {
    case small = "small"
    case medium = "medium"
    case large = "large"
}

// MARK: - Interaction Tracking

enum InteractionType: String {
    case helpButtonTap = "help_button_tap"
    case nextButtonTap = "next_button_tap"
    case previousButtonTap = "previous_button_tap"
    case dismissTap = "dismiss_tap"
    case contentTap = "content_tap"
}

struct UserInteraction {
    let id: UUID
    let type: InteractionType
    let timestamp: Date
    let context: HelpContext
    
    init(type: InteractionType, context: HelpContext) {
        self.id = UUID()
        self.type = type
        self.timestamp = Date()
        self.context = context
    }
}