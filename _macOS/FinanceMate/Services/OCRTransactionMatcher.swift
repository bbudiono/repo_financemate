//
// OCRTransactionMatcher.swift
// FinanceMate
//
// Created by AI Agent on 2025-07-08.
// TASK-3.1.1.C: OCR-Transaction Integration - TDD Implementation
//

/*
 * Purpose: Smart transaction matching engine using fuzzy matching algorithms
 * Issues & Complexity Summary: Complex pattern matching with confidence scoring
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~400 (fuzzy matching + confidence algorithms)
   - Core Algorithm Complexity: High (multi-factor matching with scoring)
   - Dependencies: Core Data, Foundation, NaturalLanguage
   - State Management Complexity: Medium (matching result management)
   - Novelty/Uncertainty Factor: Medium (fuzzy matching patterns)
 * AI Pre-Task Self-Assessment: 89%
 * Problem Estimate: 91%
 * Initial Code Complexity Estimate: 93%
 * Final Code Complexity: 94%
 * Overall Result Score: 92%
 * Key Variances/Learnings: Fuzzy string matching crucial for transaction correlation
 * Last Updated: 2025-07-08
 */

import Foundation
import CoreData
import NaturalLanguage

/// Advanced transaction matching engine that correlates OCR results with existing transactions
/// Uses fuzzy matching, date proximity, and amount comparison for intelligent transaction identification
// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class OCRTransactionMatcher: ObservableObject {
    
    // MARK: - Match Types
    enum MatchType: String, CaseIterable {
        case exact = "exact"
        case fuzzyMerchant = "fuzzy_merchant"
        case dateRange = "date_range"
        case amountOnly = "amount_only"
        case partial = "partial"
        
        var displayName: String {
            switch self {
            case .exact: return "Exact Match"
            case .fuzzyMerchant: return "Similar Merchant"
            case .dateRange: return "Date Range Match"
            case .amountOnly: return "Amount Match"
            case .partial: return "Partial Match"
            }
        }
        
        var baseConfidence: Double {
            switch self {
            case .exact: return 0.95
            case .fuzzyMerchant: return 0.80
            case .dateRange: return 0.75
            case .amountOnly: return 0.60
            case .partial: return 0.50
            }
        }
    }
    
    // MARK: - Match Result
    struct TransactionMatch {
        let transaction: Transaction
        let matchType: MatchType
        let confidence: Double
        let matchingFactors: [MatchingFactor]
        let similarityScore: Double
        
        struct MatchingFactor {
            let type: String
            let score: Double
            let details: String
        }
    }
    
    // MARK: - Configuration
    struct MatchingConfiguration {
        let dateToleranceHours: Int = 48
        let amountTolerancePercentage: Double = 0.05 // 5%
        let minimumConfidenceThreshold: Double = 0.50
        let fuzzyMatchThreshold: Double = 0.70
        let maxResultsPerQuery: Int = 10
        let enableLearning: Bool = true
    }
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private let configuration: MatchingConfiguration
    private let nlTagger: NLTagger
    
    // Fuzzy matching components
    private let merchantNormalizer: MerchantNameNormalizer
    private var learningCache: [String: Double] = [:]
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext, configuration: MatchingConfiguration = MatchingConfiguration()) {
        self.context = context
        self.configuration = configuration
        self.nlTagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass, .tokenType])
        self.merchantNormalizer = MerchantNameNormalizer()
    }
    
    // MARK: - Public Interface
    
    /// Find matching transactions for OCR result using comprehensive matching algorithms
    /// - Parameter ocrResult: Financial document OCR result
    /// - Returns: Array of transaction matches sorted by confidence
    func findMatchingTransactions() throws -> [TransactionMatch] {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        // Build predicate for initial filtering
        var predicates: [NSPredicate] = []
        
        // Date range filtering
        if let ocrDate = ocrResult.date {
            let dateRange = createDateRange(around: ocrDate)
            predicates.append(NSPredicate(format: "date >= %@ AND date <= %@", dateRange.start as NSDate, dateRange.end as NSDate))
        }
        
        // Amount range filtering
        if let ocrAmount = ocrResult.totalAmount {
            let amountRange = createAmountRange(around: ocrAmount)
            predicates.append(NSPredicate(format: "amount >= %@ AND amount <= %@", 
                                        NSNumber(value: amountRange.min), 
                                        NSNumber(value: amountRange.max)))
        }
        
        // Combine predicates
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        // Fetch potentially matching transactions
        let potentialMatches = try context.fetch(fetchRequest)
        
        // Score and rank matches
        let scoredMatches = scoreTransactionMatches(ocrResult: ocrResult, transactions: potentialMatches)
        
        // Filter by minimum confidence and limit results
        let filteredMatches = scoredMatches
            .filter { $0.confidence >= configuration.minimumConfidenceThreshold }
            .prefix(configuration.maxResultsPerQuery)
        
        return Array(filteredMatches)
    }
    
    /// Record user confirmation of match for learning purposes
    /// - Parameters:
    ///   - match: The confirmed transaction match
    ///   - ocrResult: Original OCR result
    func recordMatchConfirmation(_ match: TransactionMatch, for ocrResult: VisionOCREngine.FinancialDocumentResult) {
        guard configuration.enableLearning else { return }
        
        // Update learning cache with confirmed matches
        if let merchantName = ocrResult.merchantName {
            let normalizedMerchant = merchantNormalizer.normalize(merchantName)
            let transactionNote = match.transaction.note ?? ""
            let learningKey = "\(normalizedMerchant):\(transactionNote)"
            
            // Increase confidence for this merchant-transaction pair
            let currentConfidence = learningCache[learningKey] ?? 0.0
            learningCache[learningKey] = min(1.0, currentConfidence + 0.1)
        }
    }
    
    /// Get matching statistics for analytics
    var matchingStatistics: [String: Any] {
        return [
            "total_learning_entries": learningCache.count,
            "average_learning_confidence": learningCache.isEmpty ? 0.0 : learningCache.values.reduce(0, +) / Double(learningCache.count),
            "configuration": [
                "date_tolerance_hours": configuration.dateToleranceHours,
                "amount_tolerance_percentage": configuration.amountTolerancePercentage,
                "minimum_confidence": configuration.minimumConfidenceThreshold
            ]
        ]
    }
    
    // MARK: - Private Implementation
    
    private func scoreTransactionMatches() -> [TransactionMatch] {
        var matches: [TransactionMatch] = []
        
        for transaction in transactions {
            let matchResult = scoreIndividualMatch(ocrResult: ocrResult, transaction: transaction)
            if let match = matchResult {
                matches.append(match)
            }
        }
        
        // Sort by confidence descending
        return matches.sorted { $0.confidence > $1.confidence }
    }
    
    private func scoreIndividualMatch() -> TransactionMatch? {
        var matchingFactors: [TransactionMatch.MatchingFactor] = []
        var totalScore: Double = 0.0
        var matchType: MatchType = .partial
        var factorCount: Int = 0
        
        // 1. Merchant Name Matching
        if let ocrMerchant = ocrResult.merchantName, 
           let transactionNote = transaction.note {
            let merchantScore = scoreMerchantMatch(ocr: ocrMerchant, transaction: transactionNote)
            matchingFactors.append(TransactionMatch.MatchingFactor(
                type: "merchant",
                score: merchantScore,
                details: "OCR: '\(ocrMerchant)' vs Transaction: '\(transactionNote)'"
            ))
            totalScore += merchantScore * 0.4 // 40% weight
            factorCount += 1
            
            if merchantScore > 0.95 {
                matchType = .exact
            } else if merchantScore > configuration.fuzzyMatchThreshold {
                matchType = .fuzzyMerchant
            }
        }
        
        // 2. Amount Matching
        if let ocrAmount = ocrResult.totalAmount {
            let amountScore = scoreAmountMatch(ocr: ocrAmount, transaction: transaction.amount)
            matchingFactors.append(TransactionMatch.MatchingFactor(
                type: "amount",
                score: amountScore,
                details: "OCR: $\(ocrAmount) vs Transaction: $\(transaction.amount)"
            ))
            totalScore += amountScore * 0.35 // 35% weight
            factorCount += 1
        }
        
        // 3. Date Matching
        if let ocrDate = ocrResult.date {
            let dateScore = scoreDateMatch(ocr: ocrDate, transaction: transaction.date ?? Date())
            matchingFactors.append(TransactionMatch.MatchingFactor(
                type: "date",
                score: dateScore,
                details: "OCR: \(ocrDate) vs Transaction: \(transaction.date ?? Date())"
            ))
            totalScore += dateScore * 0.20 // 20% weight
            factorCount += 1
            
            if dateScore > 0.8 && matchType == .partial {
                matchType = .dateRange
            }
        }
        
        // 4. Learning Boost
        if let ocrMerchant = ocrResult.merchantName,
           let transactionNote = transaction.note {
            let learningKey = "\(merchantNormalizer.normalize(ocrMerchant)):\(transactionNote)"
            if let learningBoost = learningCache[learningKey] {
                matchingFactors.append(TransactionMatch.MatchingFactor(
                    type: "learning",
                    score: learningBoost,
                    details: "Previous user confirmations boost confidence"
                ))
                totalScore += learningBoost * 0.05 // 5% weight
                factorCount += 1
            }
        }
        
        // Calculate final confidence
        let averageScore = factorCount > 0 ? totalScore / Double(factorCount) : 0.0
        let finalConfidence = min(1.0, averageScore + matchType.baseConfidence * 0.1)
        
        // Only return matches above minimum threshold
        guard finalConfidence >= configuration.minimumConfidenceThreshold else { return nil }
        
        return TransactionMatch(
            transaction: transaction,
            matchType: matchType,
            confidence: finalConfidence,
            matchingFactors: matchingFactors,
            similarityScore: averageScore
        )
    }
    
    private func scoreMerchantMatch() -> Double {
        let normalizedOCR = merchantNormalizer.normalize(ocr)
        let normalizedTransaction = merchantNormalizer.normalize(transaction)
        
        // Exact match
        if normalizedOCR == normalizedTransaction {
            return 1.0
        }
        
        // Fuzzy string matching using Levenshtein distance
        let similarity = calculateStringSimilarity(normalizedOCR, normalizedTransaction)
        
        // Boost score for known merchant variations
        let variationBoost = checkMerchantVariations(ocr: normalizedOCR, transaction: normalizedTransaction)
        
        return min(1.0, similarity + variationBoost)
    }
    
    private func scoreAmountMatch(ocr: Double, transaction: Double) -> Double {
        let difference = abs(ocr - transaction)
        let tolerance = transaction * configuration.amountTolerancePercentage
        
        if difference == 0.0 {
            return 1.0
        } else if difference <= tolerance {
            return 1.0 - (difference / tolerance) * 0.2 // 20% penalty within tolerance
        } else {
            // Exponential decay for amounts outside tolerance
            let excessRatio = difference / transaction
            return max(0.0, exp(-excessRatio * 5.0))
        }
    }
    
    private func scoreDateMatch(ocr: Date, transaction: Date) -> Double {
        let timeDifference = abs(ocr.timeIntervalSince(transaction))
        let toleranceSeconds = Double(configuration.dateToleranceHours * 3600)
        
        if timeDifference == 0.0 {
            return 1.0
        } else if timeDifference <= toleranceSeconds {
            return 1.0 - (timeDifference / toleranceSeconds) * 0.3 // 30% penalty within tolerance
        } else {
            // Exponential decay for dates outside tolerance
            let excessRatio = timeDifference / toleranceSeconds
            return max(0.0, exp(-excessRatio * 2.0))
        }
    }
    
    private func calculateStringSimilarity(_ string1: String, _ string2: String) -> Double {
        let longer = string1.count > string2.count ? string1 : string2
        let shorter = string1.count > string2.count ? string2 : string1
        
        if longer.isEmpty {
            return 1.0
        }
        
        let editDistance = levenshteinDistance(longer, shorter)
        return 1.0 - Double(editDistance) / Double(longer.count)
    }
    
    private func levenshteinDistance(_ string1: String, _ string2: String) -> Int {
        let string1Array = Array(string1)
        let string2Array = Array(string2)
        let string1Count = string1Array.count
        let string2Count = string2Array.count
        
        if string1Count == 0 { return string2Count }
        if string2Count == 0 { return string1Count }
        
        var matrix = Array(repeating: Array(repeating: 0, count: string2Count + 1), count: string1Count + 1)
        
        for i in 0...string1Count {
            matrix[i][0] = i
        }
        
        for j in 0...string2Count {
            matrix[0][j] = j
        }
        
        for i in 1...string1Count {
            for j in 1...string2Count {
                let cost = string1Array[i-1] == string2Array[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,      // deletion
                    matrix[i][j-1] + 1,      // insertion
                    matrix[i-1][j-1] + cost  // substitution
                )
            }
        }
        
        return matrix[string1Count][string2Count]
    }
    
    private func checkMerchantVariations(ocr: String, transaction: String) -> Double {
        // Common Australian merchant variations
        let merchantVariations: [String: [String]] = [
            "woolworths": ["woolies", "ww", "woolworth"],
            "coles": ["coles supermarket", "coles group"],
            "bunnings": ["bunnings warehouse", "bunnings wh"],
            "kmart": ["k mart", "kmart australia"],
            "target": ["target australia", "target store"],
            "jb": ["jb hi-fi", "jb hifi", "jbhifi"]
        ]
        
        for (canonical, variations) in merchantVariations {
            if (ocr.contains(canonical) && variations.contains { transaction.contains($0) }) ||
               (transaction.contains(canonical) && variations.contains { ocr.contains($0) }) {
                return 0.3 // 30% boost for known variations
            }
        }
        
        return 0.0
    }
    
    private func createDateRange(around date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let toleranceHours = configuration.dateToleranceHours
        
        let startDate = calendar.date(byAdding: .hour, value: -toleranceHours, to: date) ?? date
        let endDate = calendar.date(byAdding: .hour, value: toleranceHours, to: date) ?? date
        
        return (start: startDate, end: endDate)
    }
    
    private func createAmountRange(around amount: Double) -> (min: Double, max: Double) {
        let tolerance = amount * configuration.amountTolerancePercentage
        return (min: amount - tolerance, max: amount + tolerance)
    }
}

// MARK: - Merchant Name Normalizer

private class MerchantNameNormalizer {
    func normalize(_ merchantName: String) -> String {
        return merchantName
            .uppercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "[^A-Z0-9 ]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Test Support Extensions

#if DEBUG
extension OCRTransactionMatcher {
    /// Test helper to access learning cache
    var testLearningCache: [String: Double] {
        return learningCache
    }
    
    /// Test helper to manually set learning data
    func setTestLearningData(_ data: [String: Double]) {
        learningCache = data
    }
}
#endif