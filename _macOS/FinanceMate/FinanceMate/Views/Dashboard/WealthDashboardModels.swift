//
// WealthDashboardModels.swift
// FinanceMate
//
// Purpose: Supporting types, enums, and data models for wealth dashboard components
// Issues & Complexity Summary: Clean separation of data structures from UI logic
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~100
//   - Core Algorithm Complexity: Low (data structures only)
//   - Dependencies: 1 (Foundation for formatting)
//   - State Management Complexity: None
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 80%
// Final Code Complexity: 82%
// Overall Result Score: 96%
// Key Variances/Learnings: Clean data model separation enables modular architecture
// Last Updated: 2025-08-04

import Foundation
import SwiftUI

// MARK: - Chart Types

enum ChartTab: String, CaseIterable {
    case assetPie = "asset_pie"
    case liabilityPie = "liability_pie" 
    case comparisonBar = "comparison_bar"
    case netWealthTrend = "net_wealth_trend"
    
    var title: String {
        switch self {
        case .assetPie: return "Assets"
        case .liabilityPie: return "Liabilities"
        case .comparisonBar: return "Compare"
        case .netWealthTrend: return "Trends"
        }
    }
    
    var icon: String {
        switch self {
        case .assetPie: return "chart.pie"
        case .liabilityPie: return "chart.pie.fill"
        case .comparisonBar: return "chart.bar"
        case .netWealthTrend: return "chart.line.uptrend.xyaxis"
        }
    }
}

// TimeRange enum moved to WealthDashboardViewModel.swift to avoid conflicts

// MARK: - Data Models

struct WealthHistoryPoint {
    let date: Date
    let netWealth: Double
    let totalAssets: Double
    let totalLiabilities: Double
}

struct AssetCategoryData {
    let category: String
    let totalValue: Double
    let assetCount: Int
    let assets: [AssetItemData]
    
    var formattedTotal: String {
        return NumberFormatter.currency.string(from: NSNumber(value: totalValue)) ?? "$0.00"
    }
}

struct AssetItemData {
    let id: UUID
    let name: String
    let description: String?
    let value: Double
    
    var formattedValue: String {
        return NumberFormatter.currency.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

struct LiabilityTypeData {
    let type: String
    let totalBalance: Double
    let liabilityCount: Int
    let liabilities: [LiabilityItemData]
    
    var formattedTotal: String {
        return NumberFormatter.currency.string(from: NSNumber(value: totalBalance)) ?? "$0.00"
    }
}

struct LiabilityItemData {
    let id: UUID
    let name: String
    let balance: Double
    let interestRate: Double?
    let nextPaymentAmount: String?
    
    var formattedBalance: String {
        return NumberFormatter.currency.string(from: NSNumber(value: balance)) ?? "$0.00"
    }
}