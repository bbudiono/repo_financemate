import CreateML
import Foundation
import NaturalLanguage

// MARK: - Subscription Detection Engine

@Observable
public class SubscriptionDetectionEngine {
    // MARK: - Properties

    public var isTraining = false
    public var confidence: Double = 0.0
    private var subscriptionPatterns: [SubscriptionPattern] = []
    private var knownSubscriptions: [String: SubscriptionInfo] = [:]

    // MARK: - Initialization

    public init() {
        loadKnownSubscriptions()
        setupSubscriptionPatterns()
    }

    // MARK: - Public Methods

    public func detectSubscription(from description: String, amount: Double, date: Date) -> SubscriptionDetection? {
        // Clean and normalize the description
        let cleanDescription = cleanDescription(description)

        // Check against known subscription services
        if let knownService = detectKnownService(from: cleanDescription) {
            return createDetection(
                serviceName: knownService.name,
                category: knownService.category,
                predictedCycle: predictBillingCycle(amount: amount, serviceName: knownService.name),
                confidence: 0.95,
                icon: knownService.icon,
                color: knownService.color
            )
        }

        // Use pattern matching for unknown services
        if let patternMatch = detectByPattern(description: cleanDescription, amount: amount) {
            return patternMatch
        }

        // Use ML-based detection if available
        return detectUsingML(description: cleanDescription, amount: amount)
    }

    public func analyzeRecurringTransactions(_ transactions: [TransactionData]) -> [RecurringPattern] {
        var patterns: [RecurringPattern] = []
        let groupedTransactions = groupTransactionsByMerchant(transactions)

        for (merchant, merchantTransactions) in groupedTransactions {
            if let pattern = analyzeTransactionPattern(merchant: merchant, transactions: merchantTransactions) {
                patterns.append(pattern)
            }
        }

        return patterns.sorted { $0.confidence > $1.confidence }
    }

    public func optimizeSubscriptions(_ subscriptions: [Subscription]) -> [OptimizationSuggestion] {
        var suggestions: [OptimizationSuggestion] = []

        // Find duplicate services
        suggestions.append(contentsOf: findDuplicateServices(subscriptions))

        // Find underutilized subscriptions
        suggestions.append(contentsOf: findUnderutilizedSubscriptions(subscriptions))

        // Find better pricing options
        suggestions.append(contentsOf: findBetterPricingOptions(subscriptions))

        // Find bundle opportunities
        suggestions.append(contentsOf: findBundleOpportunities(subscriptions))

        return suggestions.sorted { $0.potentialSavings > $1.potentialSavings }
    }

    // MARK: - Private Methods

    private func loadKnownSubscriptions() {
        knownSubscriptions = [
            // Streaming Services
            "netflix": SubscriptionInfo(name: "Netflix", category: "Entertainment", icon: "tv.fill", color: .red, typicalPricing: [8.99, 13.99, 17.99]),
            "spotify": SubscriptionInfo(name: "Spotify", category: "Music", icon: "music.note", color: .green, typicalPricing: [9.99, 14.99]),
            "apple music": SubscriptionInfo(name: "Apple Music", category: "Music", icon: "music.note", color: .pink, typicalPricing: [9.99, 14.99]),
            "youtube premium": SubscriptionInfo(name: "YouTube Premium", category: "Entertainment", icon: "play.rectangle.fill", color: .red, typicalPricing: [11.99, 17.99]),
            "hulu": SubscriptionInfo(name: "Hulu", category: "Entertainment", icon: "tv.fill", color: .green, typicalPricing: [7.99, 14.99]),
            "disney plus": SubscriptionInfo(name: "Disney+", category: "Entertainment", icon: "tv.fill", color: .blue, typicalPricing: [7.99, 13.99]),
            "amazon prime": SubscriptionInfo(name: "Amazon Prime", category: "Shopping", icon: "shippingbox.fill", color: .orange, typicalPricing: [12.99, 139.00]),

            // Software & Productivity
            "adobe": SubscriptionInfo(name: "Adobe Creative Cloud", category: "Software", icon: "paintbrush.fill", color: .purple, typicalPricing: [20.99, 52.99]),
            "microsoft office": SubscriptionInfo(name: "Microsoft 365", category: "Software", icon: "doc.fill", color: .blue, typicalPricing: [6.99, 9.99]),
            "dropbox": SubscriptionInfo(name: "Dropbox", category: "Storage", icon: "icloud.fill", color: .blue, typicalPricing: [9.99, 16.58]),
            "icloud": SubscriptionInfo(name: "iCloud+", category: "Storage", icon: "icloud.fill", color: .blue, typicalPricing: [0.99, 2.99, 9.99]),
            "google one": SubscriptionInfo(name: "Google One", category: "Storage", icon: "icloud.fill", color: .blue, typicalPricing: [1.99, 2.99, 9.99]),

            // News & Media
            "new york times": SubscriptionInfo(name: "New York Times", category: "News", icon: "newspaper.fill", color: .black, typicalPricing: [4.25, 17.00]),
            "wall street journal": SubscriptionInfo(name: "Wall Street Journal", category: "News", icon: "newspaper.fill", color: .blue, typicalPricing: [19.50, 38.99]),
            "medium": SubscriptionInfo(name: "Medium", category: "News", icon: "doc.text.fill", color: .green, typicalPricing: [5.00]),

            // Fitness & Health
            "peloton": SubscriptionInfo(name: "Peloton", category: "Fitness", icon: "figure.run", color: .red, typicalPricing: [12.99, 39.00]),
            "apple fitness": SubscriptionInfo(name: "Apple Fitness+", category: "Fitness", icon: "figure.run", color: .orange, typicalPricing: [9.99]),
            "headspace": SubscriptionInfo(name: "Headspace", category: "Health", icon: "brain.head.profile", color: .orange, typicalPricing: [12.99]),

            // Gaming
            "xbox game pass": SubscriptionInfo(name: "Xbox Game Pass", category: "Gaming", icon: "gamecontroller.fill", color: .green, typicalPricing: [9.99, 14.99]),
            "playstation plus": SubscriptionInfo(name: "PlayStation Plus", category: "Gaming", icon: "gamecontroller.fill", color: .blue, typicalPricing: [9.99, 14.99]),
            "nintendo switch online": SubscriptionInfo(name: "Nintendo Switch Online", category: "Gaming", icon: "gamecontroller.fill", color: .red, typicalPricing: [3.99, 7.99])
        ]
    }

    private func setupSubscriptionPatterns() {
        subscriptionPatterns = [
            SubscriptionPattern(keywords: ["monthly", "subscription", "recurring"], category: "Subscription", confidence: 0.7),
            SubscriptionPattern(keywords: ["premium", "plus", "pro"], category: "Premium Service", confidence: 0.6),
            SubscriptionPattern(keywords: ["membership", "plan"], category: "Membership", confidence: 0.6),
            SubscriptionPattern(keywords: ["auto-renewal", "autopay"], category: "Auto-Renewal", confidence: 0.8),
            SubscriptionPattern(keywords: ["streaming", "media"], category: "Entertainment", confidence: 0.7),
            SubscriptionPattern(keywords: ["cloud", "storage"], category: "Storage", confidence: 0.7),
            SubscriptionPattern(keywords: ["software", "app", "saas"], category: "Software", confidence: 0.7)
        ]
    }

    private func cleanDescription(_ description: String) -> String {
        description.lowercased()
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "inc.", with: "")
            .replacingOccurrences(of: "llc", with: "")
            .replacingOccurrences(of: "corp", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func detectKnownService(from description: String) -> SubscriptionInfo? {
        for (key, service) in knownSubscriptions {
            if description.contains(key) {
                confidence = 0.95
                return service
            }
        }
        return nil
    }

    private func detectByPattern(description: String, amount: Double) -> SubscriptionDetection? {
        for pattern in subscriptionPatterns {
            for keyword in pattern.keywords {
                if description.contains(keyword) {
                    confidence = pattern.confidence
                    return createDetection(
                        serviceName: extractServiceName(from: description),
                        category: pattern.category,
                        predictedCycle: predictBillingCycle(amount: amount),
                        confidence: pattern.confidence,
                        icon: "app.fill",
                        color: .blue
                    )
                }
            }
        }
        return nil
    }

    private func detectUsingML(description: String, amount: Double) -> SubscriptionDetection? {
        // Placeholder for ML-based detection
        // In a real implementation, this would use a trained model
        if description.contains("subscription") || description.contains("monthly") {
            confidence = 0.6
            return createDetection(
                serviceName: extractServiceName(from: description),
                category: "Unknown",
                predictedCycle: predictBillingCycle(amount: amount),
                confidence: 0.6,
                icon: "questionmark.app.fill",
                color: .gray
            )
        }
        return nil
    }

    private func createDetection(
        serviceName: String,
        category: String,
        predictedCycle: BillingCycle,
        confidence: Double,
        icon: String,
        color: Color
    ) -> SubscriptionDetection {
        SubscriptionDetection(
            serviceName: serviceName,
            category: category,
            predictedCycle: predictedCycle,
            confidence: confidence,
            icon: icon,
            color: color,
            suggestedActions: generateSuggestedActions(serviceName: serviceName, category: category)
        )
    }

    private func extractServiceName(from description: String) -> String {
        // Extract potential service name from transaction description
        let components = description.components(separatedBy: CharacterSet.alphanumerics.inverted)
        let filteredComponents = components.filter { $0.count > 2 }
        return filteredComponents.first?.capitalized ?? "Unknown Service"
    }

    private func predictBillingCycle(amount: Double, serviceName: String? = nil) -> BillingCycle {
        // Use known service pricing to predict billing cycle
        if let serviceName = serviceName,
           let knownService = knownSubscriptions[serviceName.lowercased()] {
            for price in knownService.typicalPricing {
                if abs(amount - price) < 1.0 {
                    return amount > 50 ? .yearly : .monthly
                }
            }
        }

        // General heuristics
        if amount > 100 {
            return .yearly
        } else if amount < 5 {
            return .weekly
        } else {
            return .monthly
        }
    }

    private func generateSuggestedActions(serviceName: String, category: String) -> [String] {
        var actions = ["Track this subscription", "Set renewal reminder"]

        if category == "Entertainment" {
            actions.append("Check for bundle deals")
        }

        if category == "Software" {
            actions.append("Check for annual discount")
        }

        return actions
    }

    private func groupTransactionsByMerchant(_ transactions: [TransactionData]) -> [String: [TransactionData]] {
        Dictionary(grouping: transactions) { transaction in
            extractServiceName(from: transaction.description)
        }
    }

    private func analyzeTransactionPattern(merchant: String, transactions: [TransactionData]) -> RecurringPattern? {
        guard transactions.count >= 2 else { return nil }

        let sortedTransactions = transactions.sorted { $0.date < $1.date }
        let intervals = calculateIntervals(sortedTransactions)

        if let dominantInterval = findDominantInterval(intervals) {
            let consistency = calculateConsistency(intervals, dominantInterval: dominantInterval)

            if consistency > 0.7 {
                return RecurringPattern(
                    merchant: merchant,
                    averageAmount: transactions.map { $0.amount }.reduce(0, +) / Double(transactions.count),
                    interval: dominantInterval,
                    consistency: consistency,
                    confidence: consistency,
                    transactionCount: transactions.count,
                    lastTransaction: sortedTransactions.last?.date ?? Date(),
                    predictedNextDate: predictNextDate(lastDate: sortedTransactions.last?.date ?? Date(), interval: dominantInterval)
                )
            }
        }

        return nil
    }

    private func calculateIntervals(_ transactions: [TransactionData]) -> [TimeInterval] {
        var intervals: [TimeInterval] = []

        for i in 1..<transactions.count {
            let interval = transactions[i].date.timeIntervalSince(transactions[i - 1].date)
            intervals.append(interval)
        }

        return intervals
    }

    private func findDominantInterval(_ intervals: [TimeInterval]) -> TimeInterval? {
        guard !intervals.isEmpty else { return nil }

        // Convert to days and round to common intervals
        let daysIntervals = intervals.map { $0 / 86_400 } // Convert to days
        let roundedIntervals = daysIntervals.map { roundToNearestCommonInterval($0) }

        // Find most common interval
        let intervalCounts = Dictionary(grouping: roundedIntervals) { $0 }
        return intervalCounts.max { $0.value.count < $1.value.count }?.key.map { $0 * 86_400 }
    }

    private func roundToNearestCommonInterval(_ days: Double) -> Double {
        let commonIntervals = [7.0, 14.0, 30.0, 90.0, 365.0] // Weekly, bi-weekly, monthly, quarterly, yearly

        return commonIntervals.min { abs($0 - days) < abs($1 - days) } ?? days
    }

    private func calculateConsistency(_ intervals: [TimeInterval], dominantInterval: TimeInterval) -> Double {
        let tolerance = dominantInterval * 0.1 // 10% tolerance
        let consistentIntervals = intervals.filter { abs($0 - dominantInterval) <= tolerance }
        return Double(consistentIntervals.count) / Double(intervals.count)
    }

    private func predictNextDate(lastDate: Date, interval: TimeInterval) -> Date {
        lastDate.addingTimeInterval(interval)
    }

    private func findDuplicateServices(_ subscriptions: [Subscription]) -> [OptimizationSuggestion] {
        var suggestions: [OptimizationSuggestion] = []
        let categorizedServices = Dictionary(grouping: subscriptions) { $0.category }

        for (category, services) in categorizedServices {
            if services.count > 1 && (category == "Music" || category == "Entertainment" || category == "Storage") {
                let totalCost = services.reduce(0) { $0 + $1.monthlyAmount }
                let cheapestService = services.min { $0.monthlyAmount < $1.monthlyAmount }!
                let potentialSavings = totalCost - cheapestService.monthlyAmount

                suggestions.append(OptimizationSuggestion(
                    type: .duplicateServices,
                    title: "Multiple \(category) Services",
                    description: "You have \(services.count) \(category.lowercased()) subscriptions. Consider keeping only \(cheapestService.name).",
                    potentialSavings: potentialSavings,
                    confidence: 0.8,
                    affectedSubscriptions: services.map { $0.name }
                ))
            }
        }

        return suggestions
    }

    private func findUnderutilizedSubscriptions(_ subscriptions: [Subscription]) -> [OptimizationSuggestion] {
        // Placeholder implementation - would need usage data in real app
        var suggestions: [OptimizationSuggestion] = []

        for subscription in subscriptions {
            if subscription.monthlyAmount > 20 && subscription.category == "Software" {
                suggestions.append(OptimizationSuggestion(
                    type: .underutilized,
                    title: "High-Cost Software",
                    description: "\(subscription.name) costs \(subscription.formattedAmount)/month. Consider if you're using all features.",
                    potentialSavings: subscription.monthlyAmount * 0.5,
                    confidence: 0.6,
                    affectedSubscriptions: [subscription.name]
                ))
            }
        }

        return suggestions
    }

    private func findBetterPricingOptions(_ subscriptions: [Subscription]) -> [OptimizationSuggestion] {
        var suggestions: [OptimizationSuggestion] = []

        for subscription in subscriptions {
            if subscription.billingCycle == .monthly && subscription.monthlyAmount > 10 {
                let annualSavings = subscription.monthlyAmount * 2 // Assume 2 months free with annual
                suggestions.append(OptimizationSuggestion(
                    type: .betterPricing,
                    title: "Annual Billing Discount",
                    description: "Switch \(subscription.name) to annual billing to save approximately \(formatCurrency(annualSavings)) per year.",
                    potentialSavings: annualSavings / 12, // Monthly savings
                    confidence: 0.7,
                    affectedSubscriptions: [subscription.name]
                ))
            }
        }

        return suggestions
    }

    private func findBundleOpportunities(_ subscriptions: [Subscription]) -> [OptimizationSuggestion] {
        var suggestions: [OptimizationSuggestion] = []

        // Check for Apple bundle opportunities
        let appleServices = subscriptions.filter { $0.name.lowercased().contains("apple") || $0.name.lowercased().contains("icloud") }
        if appleServices.count >= 2 {
            let totalCost = appleServices.reduce(0) { $0 + $1.monthlyAmount }
            if totalCost > 15 {
                suggestions.append(OptimizationSuggestion(
                    type: .bundleOpportunity,
                    title: "Apple One Bundle",
                    description: "Consider Apple One bundle for \(appleServices.map { $0.name }.joined(separator: ", ")).",
                    potentialSavings: totalCost - 14.95, // Apple One individual plan
                    confidence: 0.8,
                    affectedSubscriptions: appleServices.map { $0.name }
                ))
            }
        }

        return suggestions
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Types

public struct SubscriptionDetection {
    let serviceName: String
    let category: String
    let predictedCycle: BillingCycle
    let confidence: Double
    let icon: String
    let color: Color
    let suggestedActions: [String]
}

public struct SubscriptionInfo {
    let name: String
    let category: String
    let icon: String
    let color: Color
    let typicalPricing: [Double]
}

public struct SubscriptionPattern {
    let keywords: [String]
    let category: String
    let confidence: Double
}

public struct RecurringPattern {
    let merchant: String
    let averageAmount: Double
    let interval: TimeInterval
    let consistency: Double
    let confidence: Double
    let transactionCount: Int
    let lastTransaction: Date
    let predictedNextDate: Date
}

public struct OptimizationSuggestion {
    let type: OptimizationType
    let title: String
    let description: String
    let potentialSavings: Double
    let confidence: Double
    let affectedSubscriptions: [String]
}

public enum OptimizationType {
    case duplicateServices
    case underutilized
    case betterPricing
    case bundleOpportunity
}

public struct TransactionData {
    let description: String
    let amount: Double
    let date: Date
    let merchant: String?
}
