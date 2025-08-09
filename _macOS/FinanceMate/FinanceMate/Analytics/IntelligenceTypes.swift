//
// IntelligenceTypes.swift
// FinanceMate
//
// Modular Component: Intelligence Data Models & Type Definitions
// Created: 2025-08-03
// Purpose: Centralized type definitions for AI/ML intelligence system
// Responsibility: Type definitions, enums, and data structures only
//

/*
 * Purpose: Centralized type definitions and data structures for AI intelligence system
 * Issues & Complexity Summary: Type definitions and data models for intelligence components
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~150
   - Core Algorithm Complexity: Low (data structures only)
   - Dependencies: Foundation only
   - State Management Complexity: None (types only)
   - Novelty/Uncertainty Factor: Low (standard Swift types)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 88%
 * Overall Result Score: 94%
 * Key Variances/Learnings: Type-focused module enables clean separation of data models
 * Last Updated: 2025-08-03
 */

import Foundation

// MARK: - Core Intelligence Types

enum IntelligenceCapability: String, CaseIterable {
    case expensePatternRecognition = "expensePatternRecognition"
    case smartCategorization = "smartCategorization"
    case predictiveAnalytics = "predictiveAnalytics"
    case anomalyDetection = "anomalyDetection"
    case insightGeneration = "insightGeneration"
    case continuousLearning = "continuousLearning"
    case behaviorAnalysis = "behaviorAnalysis"
    case taxOptimization = "taxOptimization"
    case fraudDetection = "fraudDetection"
}

struct TransactionData {
    let amount: Double
    let category: String
    let date: Date
    let note: String
}

// MARK: - Pattern Recognition Types

struct ExpensePattern {
    let category: String
    let frequency: Double
    let averageAmount: Double
    let confidence: Double
}

struct SeasonalPattern {
    let month: Int
    let totalAmount: Double
    let transactionCount: Int
}

struct SeasonalPatternAnalysis {
    let patterns: [SeasonalPattern]
}

struct QuarterlyData {
    let quarter: Int
    let totalAmount: Double
    let transactionCount: Int
}

struct QuarterlySpendingAnalysis {
    let quarters: [QuarterlyData]
}

enum RecurringTransactionType {
    case subscription
    case bill
    case salary
}

struct RecurringTransaction {
    let type: RecurringTransactionType
    let amount: Double
    let frequency: Double
    let confidence: Double
    let description: String
}

struct SpendingHabit {
    let description: String
    let frequency: Double
    let averageAmount: Double
}

struct SpendingHabitsAnalysis {
    let habits: [SpendingHabit]
}

// MARK: - Categorization Types

enum ReasoningFactor {
    case transactionAmount
    case merchantName
    case timeOfDay
    case dayOfWeek
}

struct CategorySuggestion {
    let category: String
    let confidence: Double
    let reasoningFactors: Set<ReasoningFactor>
}

struct SplitSuggestion {
    let category: String
    let percentage: Double
}

enum ContextualFactor {
    case workingHours
    case weekend
    case holiday
}

struct ContextualCategorySuggestion {
    let category: String
    let confidence: Double
    let reasoningFactors: Set<ReasoningFactor>
    let contextualFactors: [ContextualFactor]
}

// MARK: - Predictive Analytics Types

struct MonthlyPrediction {
    let month: Int
    let expectedIncome: Double
    let expectedExpenses: Double
    let netCashFlow: Double
    let confidence: Double
}

struct CashFlowPrediction {
    let predictions: [MonthlyPrediction]
}

struct BudgetOptimization {
    let category: String
    let currentSpending: Double
    let recommendedSpending: Double
    let potentialSavings: Double
    let feasibilityScore: Double
    let description: String
}

struct MonthlyExpenseProjection {
    let month: Int
    let expectedAmount: Double
    let confidence: Double
}

struct ExpenseProjection {
    let monthlyProjections: [MonthlyExpenseProjection]
}

enum TaxOptimizationType {
    case gstOptimization
    case deductionMaximization
    case entityStructuring
}

struct TaxOptimizationRecommendation {
    let type: TaxOptimizationType
    let description: String
    let potentialSaving: Double
    let confidence: Double
    let isAustralianCompliant: Bool
}

// MARK: - Anomaly Detection Types

struct AnomalyAnalysis {
    let severityScore: Double
    let reasons: [String]
    let recommendation: String
}

enum FraudRiskLevel {
    case low
    case medium
    case high
}

struct FraudRiskAssessment {
    let riskScore: Double
    let riskLevel: FraudRiskLevel
    let riskFactors: [String]
}

enum BehaviorDeviationType {
    case unusualSpending
    case frequencyChange
    case categoryShift
}

struct BehaviorDeviation {
    let type: BehaviorDeviationType
    let significanceScore: Double
    let description: String
}

struct BehaviorDeviationAnalysis {
    let deviations: [BehaviorDeviation]
}

// MARK: - Insight Generation Types

enum InsightCategory {
    case spendingAnalysis
    case cashFlowAnalysis
    case businessOptimization
    case taxOptimization
    case savingsOpportunity
}

struct FinancialInsight {
    let id: String
    let title: String
    let description: String
    let category: InsightCategory
    let relevanceScore: Double
    let actionableRecommendation: String
    let isPersonalized: Bool
}

enum TrendTimeframe {
    case monthly
    case quarterly
    case yearly
    case unknown
}

enum TrendDirection {
    case increasing
    case decreasing
    case stable
}

struct TrendDataPoint {
    let period: Int
    let value: Double
}

struct TrendInsight {
    let title: String
    let description: String
    let timeframe: TrendTimeframe
    let dataPoints: [TrendDataPoint]
    let trendDirection: TrendDirection
}

struct ActionableRecommendation {
    let title: String
    let description: String
    let priority: Int
    let estimatedImpact: Double
    let actionSteps: [String]
}

// MARK: - User Profile Types

enum UserSegment: String, Codable {
    case businessOwner = "businessOwner"
    case investor = "investor"
    case individual = "individual"
    case freelancer = "freelancer"
}

enum Industry: String, Codable {
    case consulting = "consulting"
    case construction = "construction"
    case technology = "technology"
    case healthcare = "healthcare"
    case retail = "retail"
}

enum ExperienceLevel: String, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
}

struct UserProfile: Codable {
    let segment: UserSegment
    let industry: Industry
    let experienceLevel: ExperienceLevel
}

// MARK: - Learning System Types

enum UserFeedbackType: String {
    case categoryCorrection = "categoryCorrection"
    case splitAdjustment = "splitAdjustment"
    case insightRating = "insightRating"
}

struct UserFeedback {
    let type: UserFeedbackType
    let originalPrediction: String
    let correctedValue: String
    let confidence: Double
}

struct LearningMetrics {
    var feedbackCount: Int
    var accuracyImprovement: Double
}

struct ModelMetric {
    let modelName: String
    let accuracy: Double
}

struct ModelPerformanceMetrics {
    let metrics: [ModelMetric]
}