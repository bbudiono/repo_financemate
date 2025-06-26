//
//  CommonTypes.swift
//  FinanceMate
//
//  Created by Assistant on 6/5/25.
//

/*
* Purpose: Shared type definitions to prevent duplicate enum conflicts
* Issues & Complexity Summary: Central type definitions for LLM providers and authentication
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Low
  - Dependencies: 0 New (Foundation types only)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 30%
* Problem Estimate (Inherent Problem Difficulty %): 25%
* Initial Code Complexity Estimate %: 28%
* Justification for Estimates: Simple enum definitions with string mappings
* Final Code Complexity (Actual %): 28%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Centralized type definitions prevent compilation conflicts
* Last Updated: 2025-06-05
*/

import Foundation

// MARK: - Document Type Definitions

/// Document type enumeration used across financial processing services
public enum ProcessedDocumentType: String, CaseIterable, Codable {
    case invoice = "Invoice"
    case receipt = "Receipt"
    case bankStatement = "Bank Statement"
    case taxDocument = "Tax Document"
    case expenseReport = "Expense Report"
    case contract = "Contract"
    case unknown = "Unknown"

    public var icon: String {
        switch self {
        case .invoice: return "doc.text.fill"
        case .receipt: return "receipt"
        case .bankStatement: return "building.columns"
        case .taxDocument: return "doc.badge.plus"
        case .expenseReport: return "chart.line.uptrend.xyaxis"
        case .contract: return "doc.badge.gearshape"
        case .unknown: return "questionmark.square"
        }
    }

    public var color: String {
        switch self {
        case .invoice: return "blue"
        case .receipt: return "green"
        case .bankStatement: return "indigo"
        case .taxDocument: return "red"
        case .expenseReport: return "orange"
        case .contract: return "purple"
        case .unknown: return "gray"
        }
    }
}

// MARK: - Financial Data Models

/// Extracted expense category enumeration used across financial processing services
public enum ExtractedExpenseCategory: String, CaseIterable, Codable, Comparable {
    case office = "Office Supplies"
    case travel = "Travel"
    case meals = "Meals & Entertainment"
    case utilities = "Utilities"
    case software = "Software"
    case marketing = "Marketing"
    case professional = "Professional Services"
    case equipment = "Equipment"
    case maintenance = "Maintenance"
    case insurance = "Insurance"
    case other = "Other"

    public static func < (lhs: ExtractedExpenseCategory, rhs: ExtractedExpenseCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var icon: String {
        switch self {
        case .office: return "pencil.and.outline"
        case .travel: return "airplane"
        case .meals: return "fork.knife"
        case .utilities: return "bolt"
        case .software: return "app.badge"
        case .marketing: return "megaphone"
        case .professional: return "briefcase"
        case .equipment: return "desktopcomputer"
        case .maintenance: return "wrench.and.screwdriver"
        case .insurance: return "shield"
        case .other: return "questionmark.circle"
        }
    }

    public var color: String {
        switch self {
        case .office: return "blue"
        case .travel: return "green"
        case .meals: return "orange"
        case .utilities: return "yellow"
        case .software: return "purple"
        case .marketing: return "pink"
        case .professional: return "indigo"
        case .equipment: return "gray"
        case .maintenance: return "brown"
        case .insurance: return "red"
        case .other: return "secondary"
        }
    }
}

/// Extracted amount structure used across financial processing services
public struct ExtractedAmount: Codable, Equatable {
    public let value: Double
    public let currency: String
    public let formattedString: String

    public init(value: Double, currency: String, formattedString: String) {
        self.value = value
        self.currency = currency
        self.formattedString = formattedString
    }
}

/// Extracted line item structure used across financial processing services
public struct ExtractedLineItem: Codable, Equatable {
    public let description: String
    public let quantity: Double
    public let unitPrice: Double
    public let totalAmount: ExtractedAmount
    public let category: ExtractedExpenseCategory

    public init(description: String, quantity: Double, unitPrice: Double, totalAmount: ExtractedAmount, category: ExtractedExpenseCategory) {
        self.description = description
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalAmount = totalAmount
        self.category = category
    }
}

/// Extracted vendor structure used across financial processing services
public struct ExtractedVendor: Codable, Equatable {
    public let name: String
    public let address: String?
    public let taxId: String?

    public init(name: String, address: String?, taxId: String?) {
        self.name = name
        self.address = address
        self.taxId = taxId
    }
}

/// Extracted customer structure used across financial processing services
public struct ExtractedCustomer: Codable, Equatable {
    public let name: String
    public let address: String?
    public let email: String?

    public init(name: String, address: String?, email: String?) {
        self.name = name
        self.address = address
        self.email = email
    }
}

/// Extracted date structure used across financial processing services
public struct ExtractedDate: Codable, Equatable {
    public let date: Date
    public let type: ExtractedDateType
    public let context: String

    public init(date: Date, type: ExtractedDateType, context: String) {
        self.date = date
        self.type = type
        self.context = context
    }
}

/// Extracted date type enumeration used across financial processing services
public enum ExtractedDateType: String, CaseIterable, Codable {
    case invoiceDate = "Invoice Date"
    case dueDate = "Due Date"
    case serviceDate = "Service Date"
    case paymentDate = "Payment Date"
    case transactionDate = "Transaction Date"
}

/// Extracted tax information structure used across financial processing services
public struct ExtractedTaxInfo: Codable, Equatable {
    public let taxAmount: ExtractedAmount?
    public let taxRate: Double?
    public let taxId: String?
    public let isTaxExempt: Bool

    public init(taxAmount: ExtractedAmount?, taxRate: Double?, taxId: String?, isTaxExempt: Bool) {
        self.taxAmount = taxAmount
        self.taxRate = taxRate
        self.taxId = taxId
        self.isTaxExempt = isTaxExempt
    }
}

// MARK: - LLM Provider Types

/// Shared LLM Provider enumeration used across all services
public enum LLMProvider: String, CaseIterable, Codable {
    case openai = "openai"
    case anthropic = "anthropic"
    case googleai = "googleai"

    public var displayName: String {
        switch self {
        case .openai: return "OpenAI"
        case .anthropic: return "Anthropic"
        case .googleai: return "Google AI"
        }
    }

    public var apiKeyEnvironmentVariable: String {
        switch self {
        case .openai: return "OPENAI_API_KEY"
        case .anthropic: return "ANTHROPIC_API_KEY"
        case .googleai: return "GOOGLE_AI_API_KEY"
        }
    }
}

// MARK: - Authentication Types

public enum AuthenticationProvider: String, CaseIterable, Codable {
    case apple = "apple"
    case google = "google"

    public var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        }
    }
}

public enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated
    case error(AuthenticationError)

    public static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthenticated, .unauthenticated),
             (.authenticating, .authenticating),
             (.authenticated, .authenticated):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.errorDescription == rhsError.errorDescription
        default:
            return false
        }
    }
}

public enum AuthenticationError: LocalizedError, Equatable {
    case appleSignInFailed(Error)
    case googleSignInFailed(Error)
    case invalidAppleCredential
    case invalidGoogleCredential
    case appleCredentialsRevoked
    case appleCredentialsTransferred
    case unknownAppleCredentialState
    case googleTokenExpired
    case noCurrentUser
    case keychainError(String)
    case tokenManagerError(String)
    case networkError(String)
    case invalidGoogleCallback
    case oauthServerError(String)

    public var errorDescription: String? {
        switch self {
        case .appleSignInFailed(let error):
            return "Apple Sign In failed: \(error.localizedDescription)"
        case .googleSignInFailed(let error):
            return "Google Sign In failed: \(error.localizedDescription)"
        case .invalidAppleCredential:
            return "Invalid Apple credential received"
        case .invalidGoogleCredential:
            return "Invalid Google credential received"
        case .appleCredentialsRevoked:
            return "Apple credentials have been revoked"
        case .appleCredentialsTransferred:
            return "Apple credentials have been transferred"
        case .unknownAppleCredentialState:
            return "Unknown Apple credential state"
        case .googleTokenExpired:
            return "Google authentication token has expired"
        case .noCurrentUser:
            return "No authenticated user found"
        case .keychainError(let message):
            return "Keychain error: \(message)"
        case .tokenManagerError(let message):
            return "Token manager error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidGoogleCallback:
            return "Invalid callback received from Google OAuth"
        case .oauthServerError(let message):
            return "OAuth server error: \(message)"
        }
    }

    public static func == (lhs: AuthenticationError, rhs: AuthenticationError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}

public struct AuthenticatedUser: Codable, Identifiable {
    public let id: String
    public let email: String?
    public let name: String?
    public let pictureURL: String?
}

public struct OAuthTokens: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let idToken: String?
    public let expiresIn: TimeInterval
    public let tokenType: String
    public let scope: String?
    public let createdAt: Date

    public var expiresAt: Date {
        createdAt.addingTimeInterval(expiresIn)
    }

    public var isExpired: Bool {
        Date() > expiresAt
    }
}

public struct SessionToken: Codable {
    public let token: String
    public let expiresAt: Date
}

public struct AppleAuthData {
    let userIdentifier: String
    let email: String?
    let fullName: String?
    let identityToken: Data?
    let authorizationCode: Data?
}

public struct AuthenticationResult {
    public let success: Bool
    public let user: AuthenticatedUser?
    public let provider: AuthenticationProvider
    public let token: String
    public let error: AuthenticationError?

    public init(
        success: Bool,
        user: AuthenticatedUser?,
        provider: AuthenticationProvider,
        token: String,
        error: AuthenticationError? = nil
    ) {
        self.success = success
        self.user = user
        self.provider = provider
        self.token = token
        self.error = error
    }
}

public struct UserProfileUpdate {
    public let displayName: String?
    public let email: String?

    public init(displayName: String? = nil, email: String? = nil) {
        self.displayName = displayName
        self.email = email
    }
}

// MARK: - MLACS Types

/// User tier enumeration for multi-level access control
public enum UserTier: String, CaseIterable, Codable, Comparable {
    case free = "free"
    case basic = "basic"
    case pro = "pro"
    case enterprise = "enterprise"

    public static func < (lhs: UserTier, rhs: UserTier) -> Bool {
        let order = [UserTier.free, UserTier.basic, UserTier.pro, UserTier.enterprise]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }

    public static func >= (lhs: UserTier, rhs: UserTier) -> Bool {
        !(lhs < rhs)
    }
}

/// Agent task structure for MLACS agents
public struct AgentTask {
    public let id: String
    public let type: AgentTaskType
    public let requirements: TaskRequirements
    public let priority: TaskPriority
    public let createdAt: Date

    public init(id: String, type: AgentTaskType, requirements: TaskRequirements, priority: TaskPriority = .normal, createdAt: Date = Date()) {
        self.id = id
        self.type = type
        self.requirements = requirements
        self.priority = priority
        self.createdAt = createdAt
    }
}

public enum AgentTaskType {
    case documentProcessing
    case validation
    case dataExtraction
    case analysis
    case custom(String)
}

public struct TaskRequirements {
    public let requiredCapabilities: Set<String>
    public let minUserTier: UserTier
    public let estimatedDuration: TimeInterval

    public init(requiredCapabilities: Set<String>, minUserTier: UserTier = .free, estimatedDuration: TimeInterval = 60) {
        self.requiredCapabilities = requiredCapabilities
        self.minUserTier = minUserTier
        self.estimatedDuration = estimatedDuration
    }
}

public enum TaskPriority: String, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case critical = "critical"
}

/// OCR result structure for document processing
public struct OCRResult {
    public let documentId: String
    public let extractedText: String
    public let confidence: Double
    public let boundingBoxes: [BoundingBox]
    public let processedAt: Date

    public init(documentId: String, extractedText: String, confidence: Double, boundingBoxes: [BoundingBox] = [], processedAt: Date = Date()) {
        self.documentId = documentId
        self.extractedText = extractedText
        self.confidence = confidence
        self.boundingBoxes = boundingBoxes
        self.processedAt = processedAt
    }
}

public struct BoundingBox {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
    public let text: String?

    public init(x: Double, y: Double, width: Double, height: Double, text: String? = nil) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.text = text
    }
}

/// Validation result structure for document validation
public struct ValidationResult {
    public let documentId: String
    public let isValid: Bool
    public let validationScore: Double
    public let issues: [ValidationIssue]
    public let recommendations: [String]

    public init(documentId: String, isValid: Bool, validationScore: Double, issues: [ValidationIssue] = [], recommendations: [String] = []) {
        self.documentId = documentId
        self.isValid = isValid
        self.validationScore = validationScore
        self.issues = issues
        self.recommendations = recommendations
    }
}

public struct ValidationIssue {
    public let type: ValidationIssueType
    public let severity: IssueSeverity
    public let description: String
    public let location: String?

    public init(type: ValidationIssueType, severity: IssueSeverity, description: String, location: String? = nil) {
        self.type = type
        self.severity = severity
        self.description = description
        self.location = location
    }
}

public enum ValidationIssueType: String, CaseIterable {
    case missingData = "missing_data"
    case invalidFormat = "invalid_format"
    case inconsistentData = "inconsistent_data"
    case outOfRange = "out_of_range"
    case other = "other"
}

public enum IssueSeverity: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

/// Agent status enumeration
public enum AgentStatus: String, CaseIterable {
    case idle = "idle"
    case processing = "processing"
    case completed = "completed"
    case error = "error"
    case suspended = "suspended"
}

/// MLACS Session structure
public struct MLACSSession {
    public let id: String
    public let userId: String
    public let startTime: Date
    public var endTime: Date?
    public var mode: MLACSMode
    public var messages: [MLACSMessage] = []
    public var context: [String: Any] = [:]

    public init(id: String = UUID().uuidString, userId: String, mode: MLACSMode = .single) {
        self.id = id
        self.userId = userId
        self.startTime = Date()
        self.mode = mode
    }
}

/// MLACS Message structure
public struct MLACSMessage {
    public let id: String
    public let senderId: String
    public let receiverId: String
    public let type: MLACSMessageType
    public let payload: [String: Any]
    public let timestamp: Date
    public let priority: MLACSMessagePriority

    public init(id: String, senderId: String, receiverId: String, type: MLACSMessageType, payload: [String: Any], timestamp: Date = Date(), priority: MLACSMessagePriority = .normal) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.type = type
        self.payload = payload
        self.timestamp = timestamp
        self.priority = priority
    }
}

public enum MLACSMessageType: String, CaseIterable {
    case heartbeat = "heartbeat"
    case heartbeatResponse = "heartbeat_response"
    case status = "status"
    case statusResponse = "status_response"
    case shutdown = "shutdown"
    case task = "task"
    case taskResponse = "task_response"
    case error = "error"
    case info = "info"
    case warning = "warning"
}

public enum MLACSMessagePriority: String, CaseIterable, Codable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case critical = "critical"
}

// MARK: - MLACS Configuration Types
public enum MLACSMode: String, CaseIterable, Codable {
    case single = "single"
    case multi = "multi"
    case distributed = "distributed"
    case adaptive = "adaptive"
}

/// MLACS Request structure
public struct MLACSRequest {
    public let id: String
    public let type: MLACSRequestType
    public let payload: [String: Any]
    public let priority: MLACSMessagePriority
    public let userId: String
    public let timestamp: Date

    public init(id: String = UUID().uuidString, type: MLACSRequestType, payload: [String: Any] = [:], priority: MLACSMessagePriority = .normal, userId: String) {
        self.id = id
        self.type = type
        self.payload = payload
        self.priority = priority
        self.userId = userId
        self.timestamp = Date()
    }
}

public enum MLACSRequestType: String, CaseIterable {
    case chat = "chat"
    case analysis = "analysis"
    case coordination = "coordination"
    case task = "task"
    case query = "query"
}

/// Response style enumeration for agent responses
public enum ResponseStyle: String, Codable, CaseIterable {
    case concise = "concise"
    case detailed = "detailed"
    case balanced = "balanced"
    case engaging = "engaging"
    case precise = "precise"
}

/// Safety level enumeration for agent configurations
public enum SafetyLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

// MARK: - API Response Types

public struct APIResponse<T: Codable>: Codable {
    public let data: T?
    public let error: String?
    public let timestamp: Date

    public init(data: T? = nil, error: String? = nil) {
        self.data = data
        self.error = error
        self.timestamp = Date()
    }
}

public struct LLMAuthenticationResult {
    public let provider: LLMProvider
    public let isValid: Bool
    public let error: String?
    public let responseTime: TimeInterval?
    public let success: Bool
    public let userInfo: [String: Any]?
    public let fallbackUsed: String?

    public init(provider: LLMProvider, isValid: Bool, error: String? = nil, responseTime: TimeInterval? = nil) {
        self.provider = provider
        self.isValid = isValid
        self.error = error
        self.responseTime = responseTime
        self.success = isValid
        self.userInfo = nil
        self.fallbackUsed = nil
    }

    public init(provider: LLMProvider, success: Bool, userInfo: [String: Any]? = nil, error: String? = nil, responseTime: TimeInterval? = nil, fallbackUsed: String? = nil) {
        self.provider = provider
        self.isValid = success
        self.success = success
        self.userInfo = userInfo
        self.error = error
        self.responseTime = responseTime
        self.fallbackUsed = fallbackUsed
    }
}

// MARK: - Dashboard Data Types

/// Category expense structure for dashboard categorization
public struct CategoryExpense: Identifiable {
    public let id = UUID()
    public let name: String
    public let totalAmount: Double
    public let transactionCount: Int
    public let trend: TrendDirection

    public init(name: String, totalAmount: Double, transactionCount: Int, trend: TrendDirection) {
        self.name = name
        self.totalAmount = totalAmount
        self.transactionCount = transactionCount
        self.trend = trend
    }
}

/// Trend direction enumeration for financial data analysis
public enum TrendDirection: String, CaseIterable {
    case up = "up"
    case down = "down"
    case stable = "stable"
}

/// Detected subscription structure for subscription analysis
public struct DetectedSubscription: Identifiable {
    public let id = UUID()
    public let name: String
    public let amount: Double
    public let isActive: Bool
    public let nextBillingDate: Date?

    public init(name: String, amount: Double, isActive: Bool, nextBillingDate: Date?) {
        self.name = name
        self.amount = amount
        self.isActive = isActive
        self.nextBillingDate = nextBillingDate
    }
}

/// Subscription frequency enumeration
public enum SubscriptionFrequency: String, CaseIterable {
    case weekly = "weekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case yearly = "yearly"
    case annual = "annual"
}

/// Financial forecast structure for prediction analysis
public struct FinancialForecast: Identifiable {
    public let id = UUID()
    public let type: ForecastType
    public let projectedAmount: Double
    public let changePercentage: Double
    public let description: String

    public init(type: ForecastType, projectedAmount: Double, changePercentage: Double, description: String) {
        self.type = type
        self.projectedAmount = projectedAmount
        self.changePercentage = changePercentage
        self.description = description
    }
}

/// Forecast type enumeration
public enum ForecastType: String, CaseIterable {
    case nextMonth = "next_month"
    case yearEnd = "year_end"
    case savingsPotential = "savings_potential"
}

// MARK: - Navigation Types

public enum NavigationItem: String, CaseIterable, Codable, Hashable {
    case dashboard = "dashboard"
    case budgets = "budgets"
    case goals = "goals"
    case documents = "documents"
    case analytics = "analytics"
    case subscriptions = "subscriptions"
    case mlacs = "mlacs"
    case export = "export"
    case enhancedAnalytics = "enhancedAnalytics"
    case speculativeDecoding = "speculativeDecoding"
    case chatbotTesting = "chatbotTesting"
    case crashAnalysis = "crashAnalysis"
    case llmBenchmark = "llmBenchmark"
    case settings = "settings"

    public var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .budgets: return "Budget Management"
        case .goals: return "Financial Goals"
        case .documents: return "Documents"
        case .analytics: return "Analytics"
        case .subscriptions: return "Subscriptions"
        case .mlacs: return "MLACS-EOS"
        case .export: return "Financial Export"
        case .enhancedAnalytics: return "Real-time Insights"
        case .speculativeDecoding: return "Speculative Decoding"
        case .chatbotTesting: return "Chatbot Testing"
        case .crashAnalysis: return "Crash Analysis"
        case .llmBenchmark: return "LLM Benchmark"
        case .settings: return "Settings"
        }
    }

    public var systemImage: String {
        switch self {
        case .dashboard: return "chart.line.uptrend.xyaxis"
        case .budgets: return "chart.pie.fill"
        case .goals: return "target"
        case .documents: return "doc.fill"
        case .analytics: return "chart.bar.fill"
        case .subscriptions: return "repeat.circle.fill"
        case .mlacs: return "brain.head.profile"
        case .export: return "square.and.arrow.up.fill"
        case .enhancedAnalytics: return "chart.bar.doc.horizontal.fill"
        case .speculativeDecoding: return "cpu.fill"
        case .chatbotTesting: return "message.badge.waveform"
        case .crashAnalysis: return "exclamationmark.triangle.fill"
        case .llmBenchmark: return "speedometer"
        case .settings: return "gear"
        }
    }
}
