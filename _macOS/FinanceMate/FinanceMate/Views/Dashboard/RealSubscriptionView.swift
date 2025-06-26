//
//  RealSubscriptionView.swift
//  FinanceMate
//
//  Purpose: Real subscription detection from Core Data - NO MOCK DATA
//

import CoreData
import SwiftUI

struct RealSubscriptionView: View {
    @StateObject private var dataService = DashboardDataService()
    @StateObject private var themeManager = GlobalTheme
    @State private var subscriptions: [DetectedSubscription] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var totalMonthly: Double {
        subscriptions
            .filter { $0.isActive && $0.frequency == .monthly }
            .map { $0.amount }
            .reduce(0, +)
    }

    private var totalAnnual: Double {
        subscriptions
            .filter { $0.isActive }
            .map { subscription in
                switch subscription.frequency {
                case .weekly: return subscription.amount * 52
                case .monthly: return subscription.amount * 12
                case .quarterly: return subscription.amount * 4
                case .annual: return subscription.amount
                }
            }
            .reduce(0, +)
    }

    var body: some View {
        VStack(spacing: ThemeConstants.spacingLarge) {
            Text("Subscription Tracker")
                .standardFont(.title2)
                .fontWeight(.semibold)
                .primaryColor()

            if isLoading {
                ProgressView("Detecting recurring payments...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: ThemeConstants.spacingMedium) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .warningColor()
                    Text("Error detecting subscriptions")
                        .standardFont(.headline)
                        .errorColor()
                    Text(error)
                        .standardFont(.caption)
                        .foregroundColor(themeManager.isDarkMode ? .secondary : .secondary)
                    GlassButton(theme: themeManager, action: {
                        loadSubscriptions()
                    }) {
                        Text("Retry")
                            .standardFont(.body)
                            .fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if subscriptions.isEmpty {
                VStack(spacing: ThemeConstants.spacingMedium) {
                    Image(systemName: "repeat.circle")
                        .font(.largeTitle)
                        .foregroundColor(themeManager.isDarkMode ? .secondary : .secondary)
                    Text("No subscriptions detected")
                        .standardFont(.headline)
                        .primaryColor()
                    Text("We'll identify recurring payments as you add more financial data")
                        .standardFont(.caption)
                        .foregroundColor(themeManager.isDarkMode ? .secondary : .secondary)
                        .multilineTextAlignment(.center)
                        .standardPadding(.small)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: ThemeConstants.spacingMedium) {
                        ForEach(subscriptions, id: \.name) { subscription in
                            RealSubscriptionRow(subscription: subscription, themeManager: themeManager)
                        }
                    }
                }
                .frame(maxHeight: 300)

                Divider()
                    .background(themeManager.isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.2))

                // Summary
                VStack(spacing: ThemeConstants.spacingSmall) {
                    HStack {
                        Text("Active Subscriptions:")
                            .standardFont(.body)
                            .foregroundColor(themeManager.isDarkMode ? .secondary : .secondary)
                        Spacer()
                        Text("\(subscriptions.filter { $0.isActive }.count)")
                            .standardFont(.body)
                            .fontWeight(.semibold)
                            .primaryColor()
                    }

                    HStack {
                        Text("Total Monthly:")
                            .standardFont(.body)
                            .foregroundColor(themeManager.isDarkMode ? .secondary : .secondary)
                        Spacer()
                        Text("$\(totalMonthly, specifier: "%.2f")")
                            .standardFont(.headline)
                            .primaryColor()
                    }

                    HStack {
                        Text("Annual Cost:")
                            .standardFont(.body)
                            .foregroundColor(themeManager.isDarkMode ? .secondary : .secondary)
                        Spacer()
                        Text("$\(totalAnnual, specifier: "%.2f")")
                            .standardFont(.caption)
                            .foregroundColor(themeManager.isDarkMode ? .secondary : .secondary)
                    }
                }
                .standardPadding(.small)

                GlassButton(theme: themeManager, action: {
                    // Navigate to subscription management
                }) {
                    Text("Manage Subscriptions")
                        .standardFont(.body)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .standardPadding(.large)
        .glassCard(theme: themeManager)
        .applyTheme(themeManager)
        .onAppear {
            loadSubscriptions()
        }
    }

    private func loadSubscriptions() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let detected = try await dataService.detectSubscriptions()
                await MainActor.run {
                    self.subscriptions = detected
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct RealSubscriptionRow: View {
    let subscription: DetectedSubscription
    let themeManager: CentralizedThemeManager

    private var nextBillingText: String {
        guard let nextDate = subscription.nextBillingDate else { return "Unknown" }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: nextDate)
    }

    private var frequencyText: String {
        switch subscription.frequency {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .annual: return "Annual"
        }
    }

    var body: some View {
        HStack {
            Circle()
                .fill(subscription.isActive ? ThemeConstants.successGreen : Color.gray)
                .frame(width: ThemeConstants.spacingSmall, height: ThemeConstants.spacingSmall)

            VStack(alignment: .leading, spacing: ThemeConstants.spacingTiny) {
                Text(subscription.name)
                    .standardFont(.headline)
                    .primaryColor()
                    .lineLimit(1)
                HStack(spacing: ThemeConstants.spacingSmall) {
                    Text(frequencyText)
                        .standardFont(.caption)
                        .standardPadding(.tiny)
                        .background(ThemeConstants.primaryBlue.opacity(0.1))
                        .standardCornerRadius(.small)

                    if subscription.isActive {
                        Text("Next: \(nextBillingText)")
                            .standardFont(.caption)
                            .foregroundColor(themeManager.isDarkMode ? .secondary : .secondary)
                    } else {
                        Text("Inactive")
                            .standardFont(.caption)
                            .warningColor()
                    }
                }
            }

            Spacer()

            Text("$\(subscription.amount, specifier: "%.2f")")
                .standardFont(.headline)
                .fontWeight(.semibold)
                .primaryColor()
        }
        .standardPadding(.medium)
        .glassBackground(theme: themeManager, intensity: .subtle)
        .standardCornerRadius(.medium)
        .applyTheme(themeManager)
    }
}
