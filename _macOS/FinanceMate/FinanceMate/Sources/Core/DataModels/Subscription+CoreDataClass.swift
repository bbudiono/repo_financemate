//
//  Subscription+CoreDataClass.swift
//  FinanceMate
//
//  Created by Assistant on 6/24/25.
//

import CoreData
import Foundation

@objc(Subscription)
public class Subscription: NSManagedObject {
    // MARK: - Computed Properties

    /// Monthly cost calculated based on billing cycle
    public var monthlyCost: Double {
        switch billingCycle {
        case "monthly":
            return cost
        case "yearly":
            return cost / 12.0
        case "weekly":
            return cost * 4.33 // Average weeks per month
        default:
            return cost
        }
    }

    /// Annual cost calculated based on billing cycle
    public var annualCost: Double {
        switch billingCycle {
        case "monthly":
            return cost * 12.0
        case "yearly":
            return cost
        case "weekly":
            return cost * 52.0
        default:
            return cost * 12.0
        }
    }

    /// Formatted cost string with billing cycle
    public var formattedCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let costString = formatter.string(from: NSNumber(value: cost)) ?? "$0.00"
        let cycleShortName = billingCycleShortName
        return "\(costString)/\(cycleShortName)"
    }

    /// Days until next billing
    public var daysUntilNextBilling: Int {
        guard let nextBilling = nextBillingDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: nextBilling).day ?? 0
    }

    /// Short name for billing cycle
    private var billingCycleShortName: String {
        switch billingCycle {
        case "weekly": return "wk"
        case "monthly": return "mo"
        case "yearly": return "yr"
        default: return "mo"
        }
    }

    /// System icon based on service name
    public var systemIcon: String {
        guard let serviceName = serviceName else { return "circle.fill" }

        switch serviceName.lowercased() {
        case "netflix":
            return "tv.fill"
        case "spotify":
            return "music.note"
        case "adobe creative cloud", "adobe":
            return "paintbrush.fill"
        case "icloud storage", "icloud":
            return "icloud.fill"
        case "gym membership", "gym":
            return "figure.strengthtraining.traditional"
        case "microsoft office", "office365":
            return "doc.text.fill"
        case "google drive":
            return "externaldrive.fill"
        case "dropbox":
            return "folder.fill"
        default:
            return "circle.fill"
        }
    }

    // MARK: - Lifecycle

    override public func awakeFromInsert() {
        super.awakeFromInsert()

        // Set default values
        if id == nil {
            id = UUID()
        }

        if dateCreated == nil {
            dateCreated = Date()
        }

        dateModified = Date()

        if brandColorHex == nil {
            brandColorHex = "#007AFF" // Default blue
        }

        if billingCycle == nil {
            billingCycle = "monthly"
        }

        if status == nil {
            status = "active"
        }

        isActive = true
    }

    override public func willSave() {
        super.willSave()

        // Update dateModified whenever the object is saved
        if !isDeleted {
            dateModified = Date()
        }
    }
}

// MARK: - Factory Methods

extension Subscription {
    /// Creates a new subscription with the given parameters
    /// - Parameters:
    ///   - serviceName: Name of the service
    ///   - plan: Subscription plan name
    ///   - cost: Cost amount
    ///   - billingCycle: Billing cycle (monthly, yearly, weekly)
    ///   - context: Core Data managed object context
    /// - Returns: New Subscription instance
    @discardableResult
    public static func create(
        serviceName: String,
        plan: String,
        cost: Double,
        billingCycle: String,
        in context: NSManagedObjectContext
    ) -> Subscription {
        let subscription = Subscription(context: context)
        subscription.serviceName = serviceName
        subscription.plan = plan
        subscription.cost = cost
        subscription.billingCycle = billingCycle
        subscription.startDate = Date()
        subscription.nextBillingDate = Calendar.current.date(byAdding: billingCycle == "yearly" ? .year : (billingCycle == "weekly" ? .weekOfYear : .month), value: 1, to: Date())
        return subscription
    }
}
