import Foundation
import CoreData
import os.log

/**
 * Purpose: GREEN PHASE - Business Rules Engine service implementation
 * Requirements: Core business rule management functionality
 * Complexity: Optimized for KISS compliance and atomic implementation
 * Last Updated: 2025-10-08
 */

/// Service for managing business rules for semantic mappings and categorization
class BusinessRulesEngine {

    static let shared = BusinessRulesEngine()

    private static let logger = Logger(subsystem: "FinanceMate", category: "BusinessRulesEngine")

    private init() {}

    // MARK: - Rule Creation

    /// Creates a new business rule with the specified parameters
    func createRule(
        name: String,
        condition: BusinessRuleCondition,
        action: BusinessRuleAction,
        priority: Int,
        enabled: Bool
    ) -> BusinessRule {
        let rule = BusinessRule()
        rule.id = UUID()
        rule.name = name
        rule.conditionType = condition.type
        rule.conditionValue = condition.value
        rule.actionType = action.type
        rule.actionValue = action.value
        rule.priority = Int32(priority)
        rule.enabled = enabled
        rule.confidenceBoost = 0.0
        rule.confidenceThreshold = 0.5
        rule.ruleType = "custom"
        rule.createdAt = Date()
        rule.updatedAt = Date()

        logger.info("Created business rule: \(name)")
        return rule
    }

    /// Creates a semantic mapping rule for email domain to merchant mapping
    func createSemanticMappingRule(
        emailDomain: String,
        targetMerchant: String,
        confidenceBoost: Double,
        priority: Int,
        requireContentMatch: Bool = false
    ) -> BusinessRule {
        let condition = requireContentMatch ?
            BusinessRuleCondition.custom("email_domain_with_content", "\(emailDomain)|\(targetMerchant)") :
            BusinessRuleCondition.emailDomainEquals(emailDomain)

        let rule = createRule(
            name: "\(emailDomain.capitalized) to \(targetMerchant) Mapping",
            condition: condition,
            action: .setMerchant(targetMerchant),
            priority: priority,
            enabled: true
        )

        rule.confidenceBoost = confidenceBoost
        rule.ruleType = "semantic_mapping"

        return rule
    }

    /// Creates a categorization rule for merchant to category mapping
    func createCategorizationRule(
        name: String,
        condition: BusinessRuleCondition,
        action: BusinessRuleAction,
        priority: Int
    ) -> BusinessRule {
        let rule = createRule(
            name: name,
            condition: condition,
            action: action,
            priority: priority,
            enabled: true
        )

        rule.ruleType = "categorization"
        return rule
    }

    /// Creates a rule from UserAutomationMemory data
    func createRuleFromAutomationMemory(_ memory: UserAutomationMemory) -> BusinessRule {
        let condition = BusinessRuleCondition.merchantContains(memory.merchantPatterns)
        let action = BusinessRuleAction.setCategory(memory.userCategory)

        let rule = createRule(
            name: "Auto: \(memory.userCategory) Pattern",
            condition: condition,
            action: action,
            priority: Int(memory.confidence * 100),
            enabled: memory.isValidAutomationRule
        )

        rule.confidenceThreshold = memory.confidence
        rule.ruleType = "automation_memory"
        return rule
    }

    // MARK: - Rule Persistence

    /// Saves a rule to the persistent store
    func saveRule(_ rule: BusinessRule, in context: NSManagedObjectContext) throws {
        rule.updatedAt = Date()
        try context.save()
        logger.info("Saved business rule: \(rule.name)")
    }

    /// Loads all rules from the persistent store
    func loadRules(from context: NSManagedObjectContext) -> [BusinessRule] {
        let request: NSFetchRequest<BusinessRule> = BusinessRule.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \BusinessRule.priority, ascending: false)
        ]

        do {
            return try context.fetch(request)
        } catch {
            logger.error("Failed to load business rules: \(error)")
            return []
        }
    }

    /// Loads all enabled rules
    func loadEnabledRules() -> [BusinessRule] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<BusinessRule> = BusinessRule.fetchRequest()
        request.predicate = NSPredicate(format: "enabled == true")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \BusinessRule.priority, ascending: false)
        ]

        do {
            return try context.fetch(request)
        } catch {
            logger.error("Failed to load enabled rules: \(error)")
            return []
        }
    }
}