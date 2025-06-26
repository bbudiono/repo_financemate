import Combine
import CoreData
import Foundation
import SwiftUI

@MainActor
public class SubscriptionViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    @Published var selectedFilter: SubscriptionFilter = .all
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let coreDataStack = CoreDataStack.shared

    public var filteredSubscriptions: [Subscription] {
        switch selectedFilter {
        case .all:
            return subscriptions
        case .active:
            return subscriptions.filter { $0.status == "active" }
        case .paused:
            return subscriptions.filter { $0.status == "paused" }
        case .cancelled:
            return subscriptions.filter { $0.status == "cancelled" }
        }
    }

    public var monthlyTotal: String {
        let total = subscriptions
            .filter { $0.status == "active" }
            .reduce(0.0) { sum, subscription in
                sum + subscription.monthlyCost
            }
        return formatCurrency(total)
    }

    public var annualTotal: String {
        let total = subscriptions
            .filter { $0.status == "active" }
            .reduce(0.0) { sum, subscription in
                sum + subscription.annualCost
            }
        return formatCurrency(total)
    }

    public var activeSubscriptions: Int {
        subscriptions.filter { $0.status == "active" }.count
    }

    init() {
        loadSubscriptions()
    }

    // MARK: - Public Methods

    public func addSubscription(serviceName: String, plan: String, cost: Double, billingCycle: String, category: String = "other", notes: String = "") {
        let subscription = Subscription.create(
            serviceName: serviceName,
            plan: plan,
            cost: cost,
            billingCycle: billingCycle,
            in: coreDataStack.mainContext
        )

        subscription.category = category
        subscription.notes = notes

        saveContext()
        loadSubscriptions()
    }

    public func updateSubscription(_ subscription: Subscription) {
        subscription.dateModified = Date()
        saveContext()
        loadSubscriptions()
    }

    public func deleteSubscription(_ subscription: Subscription) {
        coreDataStack.mainContext.delete(subscription)
        saveContext()
        loadSubscriptions()
    }

    public func pauseSubscription(_ subscription: Subscription) {
        subscription.status = "paused"
        subscription.isActive = false
        updateSubscription(subscription)
    }

    public func resumeSubscription(_ subscription: Subscription) {
        subscription.status = "active"
        subscription.isActive = true
        updateSubscription(subscription)
    }

    public func cancelSubscription(_ subscription: Subscription) {
        subscription.status = "cancelled"
        subscription.isActive = false
        subscription.cancelledDate = Date()
        updateSubscription(subscription)
    }

    // MARK: - Private Methods

    private func loadSubscriptions() {
        let request: NSFetchRequest<Subscription> = Subscription.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Subscription.isActive, ascending: false),
            NSSortDescriptor(keyPath: \Subscription.serviceName, ascending: true)
        ]

        do {
            subscriptions = try coreDataStack.mainContext.fetch(request)
        } catch {
            errorMessage = "Failed to load subscriptions: \(error.localizedDescription)"
            print("❌ Failed to load subscriptions: \(error)")
        }
    }

    private func saveContext() {
        do {
            try coreDataStack.saveMainContext()
        } catch {
            errorMessage = "Failed to save subscriptions: \(error.localizedDescription)"
            print("❌ Failed to save subscriptions: \(error)")
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Types

public enum SubscriptionFilter: CaseIterable {
    case all, active, paused, cancelled

    public var displayName: String {
        switch self {
        case .all: return "All"
        case .active: return "Active"
        case .paused: return "Paused"
        case .cancelled: return "Cancelled"
        }
    }
}
