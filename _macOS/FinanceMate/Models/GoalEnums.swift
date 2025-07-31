import Foundation
import SwiftUI

/**
 * GoalEnums.swift
 *
 * Purpose: Defines enums and supporting types for financial goals
 * Issues & Complexity Summary: Simple enum definitions with computed properties
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~150+
 *   - Core Algorithm Complexity: Low
 *   - Dependencies: 1 (SwiftUI)
 *   - State Management Complexity: Low
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 82%
 * Problem Estimate: 84%
 * Initial Code Complexity Estimate: 83%
 * Final Code Complexity: 85%
 * Overall Result Score: 84%
 * Key Variances/Learnings: Comprehensive enum definitions with display properties
 * Last Updated: 2025-07-11
 */

// MARK: - Goal Category

enum GoalCategory: String, CaseIterable, Identifiable, Codable {
  case emergencyFund = "emergency_fund"
  case houseDeposit = "house_deposit"
  case carPurchase = "car_purchase"
  case education = "education"
  case travel = "travel"
  case retirement = "retirement"
  case investment = "investment"
  case debtRepayment = "debt_repayment"
  case wedding = "wedding"
  case business = "business"
  case other = "other"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .emergencyFund:
      return "Emergency Fund"
    case .houseDeposit:
      return "House Deposit"
    case .carPurchase:
      return "Car Purchase"
    case .education:
      return "Education"
    case .travel:
      return "Travel"
    case .retirement:
      return "Retirement"
    case .investment:
      return "Investment"
    case .debtRepayment:
      return "Debt Repayment"
    case .wedding:
      return "Wedding"
    case .business:
      return "Business"
    case .other:
      return "Other"
    }
  }

  var icon: String {
    switch self {
    case .emergencyFund:
      return "shield.fill"
    case .houseDeposit:
      return "house.fill"
    case .carPurchase:
      return "car.fill"
    case .education:
      return "book.fill"
    case .travel:
      return "airplane"
    case .retirement:
      return "figure.walk"
    case .investment:
      return "chart.line.uptrend.xyaxis"
    case .debtRepayment:
      return "creditcard.fill"
    case .wedding:
      return "heart.fill"
    case .business:
      return "briefcase.fill"
    case .other:
      return "star.fill"
    }
  }

  var color: String {
    switch self {
    case .emergencyFund:
      return "blue"
    case .houseDeposit:
      return "green"
    case .carPurchase:
      return "purple"
    case .education:
      return "orange"
    case .travel:
      return "pink"
    case .retirement:
      return "indigo"
    case .investment:
      return "teal"
    case .debtRepayment:
      return "red"
    case .wedding:
      return "pink"
    case .business:
      return "gray"
    case .other:
      return "gray"
    }
  }
}

// MARK: - Goal Priority

enum GoalPriority: String, CaseIterable, Identifiable, Codable {
  case low = "low"
  case medium = "medium"
  case high = "high"
  case critical = "critical"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .low:
      return "Low"
    case .medium:
      return "Medium"
    case .high:
      return "High"
    case .critical:
      return "Critical"
    }
  }

  var icon: String {
    switch self {
    case .low:
      return "arrow.down"
    case .medium:
      return "minus"
    case .high:
      return "arrow.up"
    case .critical:
      return "exclamationmark.triangle.fill"
    }
  }

  var color: String {
    switch self {
    case .low:
      return "green"
    case .medium:
      return "yellow"
    case .high:
      return "orange"
    case .critical:
      return "red"
    }
  }
}

// MARK: - Goal Status

enum GoalStatus: String, CaseIterable, Identifiable, Codable {
  case active = "active"
  case completed = "completed"
  case paused = "paused"
  case overdue = "overdue"
  case cancelled = "cancelled"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .active:
      return "Active"
    case .completed:
      return "Completed"
    case .paused:
      return "Paused"
    case .overdue:
      return "Overdue"
    case .cancelled:
      return "Cancelled"
    }
  }

  var icon: String {
    switch self {
    case .active:
      return "play.fill"
    case .completed:
      return "checkmark.circle.fill"
    case .paused:
      return "pause.fill"
    case .overdue:
      return "exclamationmark.triangle.fill"
    case .cancelled:
      return "xmark.circle.fill"
    }
  }

  var color: String {
    switch self {
    case .active:
      return "blue"
    case .completed:
      return "green"
    case .paused:
      return "yellow"
    case .overdue:
      return "red"
    case .cancelled:
      return "gray"
    }
  }
}

// MARK: - Progress Period

enum ProgressPeriod: String, CaseIterable, Identifiable, Codable {
  case week = "week"
  case month = "month"
  case quarter = "quarter"
  case year = "year"
  case all = "all"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .week:
      return "Week"
    case .month:
      return "Month"
    case .quarter:
      return "Quarter"
    case .year:
      return "Year"
    case .all:
      return "All Time"
    }
  }

  var days: Int {
    switch self {
    case .week:
      return 7
    case .month:
      return 30
    case .quarter:
      return 90
    case .year:
      return 365
    case .all:
      return Int.max
    }
  }
}

// MARK: - Supporting Views

struct CategorySelectionButton: View {
  let category: GoalCategory
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: category.icon)
          .font(.title3)
          .foregroundColor(isSelected ? .white : Color(category.color))

        Text(category.displayName)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(isSelected ? .white : .primary)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(isSelected ? Color(category.color) : Color.gray.opacity(0.2))
      )
    }
  }
}

struct PrioritySelectionButton: View {
  let priority: GoalPriority
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: priority.icon)
          .font(.title3)
          .foregroundColor(isSelected ? .white : Color(priority.color))

        Text(priority.displayName)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(isSelected ? .white : .primary)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(isSelected ? Color(priority.color) : Color.gray.opacity(0.2))
      )
    }
  }
}

// MARK: - Extensions

extension Color {
  init(_ string: String) {
    switch string {
    case "blue":
      self = .blue
    case "green":
      self = .green
    case "yellow":
      self = .yellow
    case "orange":
      self = .orange
    case "red":
      self = .red
    case "purple":
      self = .purple
    case "pink":
      self = .pink
    case "indigo":
      self = .indigo
    case "teal":
      self = .teal
    case "gray":
      self = .gray
    default:
      self = .gray
    }
  }
}
