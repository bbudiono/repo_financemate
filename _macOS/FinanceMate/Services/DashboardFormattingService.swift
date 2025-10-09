//
// DashboardFormattingService.swift
// FinanceMate
//
// Purpose: Dashboard UI formatting and display utilities
// Issues & Complexity Summary: Simple formatting service for dashboard display
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~40
//   - Core Algorithm Complexity: Low
//   - Dependencies: 2 (Foundation, SwiftUI)
//   - State Management Complexity: Low
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 98%
// Initial Code Complexity Estimate: 60%
// Final Code Complexity: 62%
// Overall Result Score: 94%
// Key Variances/Learnings: Simple formatting with Australian localization
// Last Updated: 2025-01-04

import Foundation
import SwiftUI

/// Service for dashboard UI formatting and display utilities
class DashboardFormattingService {

    static let shared = DashboardFormattingService()

    private init() {}

    /// Format currency for display
    /// - Parameter amount: Amount to format
    /// - Returns: Formatted currency string
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: amount)) ?? "A$0.00"
    }

    /// Get color for balance display
    /// - Parameter balance: Balance value
    /// - Returns: Color for display
    func getBalanceColor(_ balance: Double) -> Color {
        if balance > 0 {
            return .green
        } else if balance < 0 {
            return .red
        } else {
            return .primary
        }
    }

    /// Get icon for balance state
    /// - Parameter balance: Balance value
    /// - Returns: Icon name
    func getBalanceIcon(_ balance: Double) -> String {
        if balance > 0 {
            return "arrow.up.circle.fill"
        } else if balance < 0 {
            return "arrow.down.circle.fill"
        } else {
            return "equal.circle.fill"
        }
    }

    /// Get transaction count description
    /// - Parameter count: Number of transactions
    /// - Returns: Description string
    func getTransactionCountDescription(_ count: Int) -> String {
        switch count {
        case 0:
            return "No transactions yet"
        case 1:
            return "1 transaction"
        default:
            return "\(count) transactions"
        }
    }

    /// Format date for display
    /// - Parameter date: Date to format
    /// - Returns: Formatted date string
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Format relative date (e.g., "2 days ago")
    /// - Parameter date: Date to format
    /// - Returns: Relative date string
    func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// Dashboard summary data model
struct DashboardSummary {
    let totalBalance: Double
    let transactionCount: Int
    let recentTransactions: [Transaction]
    let lastUpdated: Date

    var isEmpty: Bool {
        transactionCount == 0
    }

    var formattedBalance: String {
        DashboardFormattingService.shared.formatCurrency(totalBalance)
    }

    var balanceColor: Color {
        DashboardFormattingService.shared.getBalanceColor(totalBalance)
    }

    var balanceIcon: String {
        DashboardFormattingService.shared.getBalanceIcon(totalBalance)
    }

    var transactionCountDescription: String {
        DashboardFormattingService.shared.getTransactionCountDescription(transactionCount)
    }
}