import Foundation
import CoreData

/**
 * Purpose: Core Data entity for User Automation Memory - AI training foundation
 * Issues & Complexity Summary: Atomic TDD implementation for AI learning data structure
 * Key Complexity Drivers:
 * - Logic Scope (Est. LoC): ~20
 * - Core Algorithm Complexity: Low (data model with basic properties)
 * - Dependencies: 1 New (CoreData), 0 Mod
 * - State Management Complexity: Low (managed object with basic lifecycle)
 * - Novelty/Uncertainty Factor: Low (standard Core Data pattern)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 55%
 * Final Code Complexity: 58%
 * Overall Result Score: 98%
 * Key Variances/Learnings: Simplified entity enables cleaner service layer
 * Last Updated: 2025-10-08
 */

@objc(UserAutomationMemory)
public class UserAutomationMemory: NSManagedObject, Identifiable {

    // MARK: - Core Attributes
    @NSManaged public var id: UUID
    @NSManaged public var merchantPatterns: String
    @NSManaged public var userCategory: String
    @NSManaged public var splitTemplate: String
    @NSManaged public var confidence: Double
    @NSManaged public var usageCount: Int32
    @NSManaged public var lastUsed: Date?
    @NSManaged public var trainingData: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // MARK: - Lifecycle
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue("", forKey: "merchantPatterns")
        setPrimitiveValue("", forKey: "userCategory")
        setPrimitiveValue("", forKey: "splitTemplate")
        setPrimitiveValue(0.0, forKey: "confidence")
        setPrimitiveValue(0, forKey: "usageCount")
        setPrimitiveValue("{}", forKey: "trainingData")
        setPrimitiveValue(Date(), forKey: "createdAt")
        setPrimitiveValue(Date(), forKey: "updatedAt")
    }

    public override func willSave() {
        super.willSave()
        setPrimitiveValue(Date(), forKey: "updatedAt")
    }
}

// MARK: - Basic AI Training Data Support

extension UserAutomationMemory {

    /// Validates if the automation memory meets minimum confidence threshold
    public var isValidAutomationRule: Bool {
        return confidence >= 0.7 && usageCount >= 3
    }

    /// Extracts merchant patterns as array for matching
    public var merchantPatternArray: [String] {
        return merchantPatterns
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Records usage of this automation rule
    public func recordUsage() {
        usageCount += 1
        lastUsed = Date()
        updateConfidence()
    }

    /// Updates confidence based on usage pattern
    private func updateConfidence() {
        if usageCount >= 10 {
            confidence = min(confidence + 0.05, 1.0)
        } else if usageCount >= 5 {
            confidence = min(confidence + 0.02, 0.95)
        }
    }
}

// MARK: - Error Types

public enum UserAutomationMemoryError: Error, LocalizedError {
    case invalidTrainingData

    public var errorDescription: String? {
        switch self {
        case .invalidTrainingData:
            return "Invalid training data format"
        }
    }
}