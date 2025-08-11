import Foundation
import os.log

/**
 * GmailAPIService.swift
 * 
 * Purpose: Gmail API integration for receipt and expense extraction
 * Issues & Complexity Summary: API integration, receipt parsing, expense extraction
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400 (Gmail API + receipt parsing + data extraction)
 *   - Core Algorithm Complexity: High (API pagination, receipt text extraction, expense parsing)
 *   - Dependencies: 3 New (Gmail API, text processing, Core Data integration)
 *   - State Management Complexity: High (API responses, async processing, error handling)
 *   - Novelty/Uncertainty Factor: High (Receipt parsing accuracy, expense categorization)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 90%
 * Target Coverage: Real Gmail data processing for expense table population
 * User Acceptance Criteria: Display expense table from bernhardbudiono@gmail.com receipts
 * Last Updated: 2025-08-10
 */

/// Gmail API service for retrieving and processing email receipts for expense extraction
@MainActor
final class GmailAPIService: ObservableObject {
    
    // MARK: - Error Types
    
    enum GmailError: Error, LocalizedError {
        case authenticationRequired
        case apiRequestFailed(String)
        case messageParsingFailed(String)
        case receiptProcessingFailed(String)
        case expenseExtractionFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .authenticationRequired:
                return "Gmail authentication required"
            case .apiRequestFailed(let reason):
                return "Gmail API request failed: \(reason)"
            case .messageParsingFailed(let reason):
                return "Failed to parse Gmail message: \(reason)"
            case .receiptProcessingFailed(let reason):
                return "Receipt processing failed: \(reason)"
            case .expenseExtractionFailed(let reason):
                return "Expense extraction failed: \(reason)"
            }
        }
    }
    
    // MARK: - Data Models
    
    struct ExpenseItem: Identifiable, Codable {
        var id = UUID()
        let amount: Double
        let currency: String
        let date: Date
        let vendor: String
        let category: ExpenseCategory
        let paymentMethod: String?
        let description: String
        let emailSubject: String
        let emailDate: Date
        let emailId: String
        
        // Location data for receipt verification
        var extractedFromEmail: Bool = true
        let confidenceScore: Double // 0.0 to 1.0
    }
    
    enum ExpenseCategory: String, CaseIterable, Codable {
        case food = "Food & Dining"
        case shopping = "Shopping"
        case transportation = "Transportation"
        case utilities = "Utilities"
        case healthcare = "Healthcare"
        case entertainment = "Entertainment"
        case business = "Business"
        case travel = "Travel"
        case subscription = "Subscriptions"
        case other = "Other"
        
        // AI-based category detection keywords
        var keywords: [String] {
            switch self {
            case .food:
                return ["restaurant", "cafe", "food", "dining", "uber eats", "doordash", "grubhub", "takeaway"]
            case .shopping:
                return ["amazon", "store", "retail", "purchase", "buy", "shop", "target", "walmart"]
            case .transportation:
                return ["uber", "lyft", "taxi", "gas", "fuel", "parking", "toll", "metro", "bus"]
            case .utilities:
                return ["electric", "water", "gas", "internet", "phone", "utility", "bill"]
            case .healthcare:
                return ["doctor", "medical", "pharmacy", "hospital", "health", "medicine"]
            case .entertainment:
                return ["movie", "concert", "game", "netflix", "spotify", "entertainment"]
            case .business:
                return ["office", "business", "meeting", "conference", "supplies"]
            case .travel:
                return ["hotel", "flight", "airbnb", "travel", "booking", "airline"]
            case .subscription:
                return ["subscription", "monthly", "annual", "membership", "premium"]
            case .other:
                return []
            }
        }
    }
    
    // MARK: - Gmail API Response Models
    
    struct MessageResponse: Codable {
        let id: String
        let payload: MessagePayload
        let internalDate: String
        
        struct MessagePayload: Codable {
            let headers: [Header]
            let body: Body?
            let parts: [Part]?
            
            struct Header: Codable {
                let name: String
                let value: String
            }
            
            struct Body: Codable {
                let data: String?
            }
            
            struct Part: Codable {
                let body: Body?
                let parts: [Part]?
            }
        }
    }
    
    // MARK: - Published Properties
    
    @Published private(set) var expenses: [ExpenseItem] = []
    @Published private(set) var isProcessing: Bool = false
    @Published private(set) var processingStatus: String = ""
    @Published private(set) var lastUpdateDate: Date?
    @Published private(set) var totalExpenses: Double = 0.0
    @Published private(set) var expenseCount: Int = 0
    
    // MARK: - Private Properties
    
    private let logger = Logger(subsystem: "FinanceMate", category: "GmailAPIService")
    private let oauthManager: EmailOAuthManager
    private let urlSession: URLSession
    private let gmailBaseURL = "https://gmail.googleapis.com/gmail/v1"
    
    // Receipt detection patterns
    private let receiptKeywords = [
        "receipt", "invoice", "purchase", "payment", "order", "transaction",
        "paid", "total", "subtotal", "tax", "charge", "bill"
    ]
    
    // Currency detection patterns
    private let currencyPatterns = [
        "USD": ["$", "USD", "dollar"],
        "AUD": ["AUD", "A$", "australian dollar"],
        "EUR": ["€", "EUR", "euro"],
        "GBP": ["£", "GBP", "pound"]
    ]
    
    // Amount extraction regex patterns
    private let amountPatterns = [
        #"\$\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)"#, // $123.45, $1,234.56
        #"(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)\s*USD"#, // 123.45 USD
        #"AUD\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)"#, // AUD 123.45
        #"total[:\s]*\$?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)"#, // Total: $123.45
        #"amount[:\s]*\$?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)"#  // Amount: $123.45
    ]
    
    // MARK: - Initialization
    
    init(oauthManager: EmailOAuthManager) {
        self.oauthManager = oauthManager
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60.0 // Longer timeout for API calls
        self.urlSession = URLSession(configuration: config)
        
        logger.info("GmailAPIService initialized for expense processing")
    }
    
    // MARK: - Public Interface
    
    /// Fetch and process receipts from Gmail for expense extraction
    func fetchAndProcessReceipts() async throws {
        guard oauthManager.isProviderAuthenticated("gmail") else {
            throw GmailError.authenticationRequired
        }
        
        isProcessing = true
        processingStatus = "Connecting to Gmail..."
        
        defer {
            isProcessing = false
            processingStatus = ""
        }
        
        do {
            // Get valid access token
            let accessToken = try await oauthManager.getValidAccessToken(for: "gmail")
            
            processingStatus = "Searching for receipt emails..."
            
            // Search for receipt-related emails
            let messageIds = try await searchReceiptEmails(accessToken: accessToken)
            
            processingStatus = "Found \(messageIds.count) potential receipt emails"
            logger.info("Found \(messageIds.count) potential receipt emails")
            
            // Process messages in batches to avoid rate limiting
            var processedExpenses: [ExpenseItem] = []
            let batchSize = 10
            
            for batch in messageIds.chunked(into: batchSize) {
                processingStatus = "Processing batch of \(batch.count) emails..."
                
                let batchExpenses = try await processBatchMessages(
                    messageIds: batch,
                    accessToken: accessToken
                )
                
                processedExpenses.append(contentsOf: batchExpenses)
                
                // Small delay to respect API rate limits
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
            
            // Update published properties
            expenses = processedExpenses.sorted { $0.date > $1.date }
            totalExpenses = processedExpenses.reduce(0) { $0 + $1.amount }
            expenseCount = processedExpenses.count
            lastUpdateDate = Date()
            
            logger.info("Successfully processed \(self.expenseCount) expenses totaling \(String(format: "%.2f", self.totalExpenses))")
            
        } catch {
            logger.error("Failed to fetch and process receipts: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
    
    /// Get expense summary by category
    func getExpensesByCategory() -> [ExpenseCategory: [ExpenseItem]] {
        return Dictionary(grouping: expenses) { $0.category }
    }
    
    /// Get total expenses for a specific category
    func getTotalForCategory(_ category: ExpenseCategory) -> Double {
        return expenses
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Gmail API Methods
    
    private func searchReceiptEmails(accessToken: String) async throws -> [String] {
        // Build search query for receipt-related emails
        let searchQuery = [
            "has:attachment OR (from:receipts OR from:noreply OR from:orders)",
            "subject:(receipt OR invoice OR purchase OR payment OR order)",
            "newer_than:30d" // Last 30 days
        ].joined(separator: " AND ")
        
        // URL encode the query
        guard let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw GmailError.apiRequestFailed("Failed to encode search query")
        }
        
        let urlString = "\(gmailBaseURL)/users/me/messages?q=\(encodedQuery)&maxResults=100"
        
        guard let url = URL(string: urlString) else {
            throw GmailError.apiRequestFailed("Invalid Gmail API URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GmailError.apiRequestFailed("Invalid response type")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GmailError.apiRequestFailed("HTTP \(httpResponse.statusCode)")
        }
        
        struct SearchResponse: Codable {
            let messages: [Message]?
            let resultSizeEstimate: Int?
            
            struct Message: Codable {
                let id: String
            }
        }
        
        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse.messages?.map { $0.id } ?? []
    }
    
    private func processBatchMessages(messageIds: [String], accessToken: String) async throws -> [ExpenseItem] {
        var expenses: [ExpenseItem] = []
        
        for messageId in messageIds {
            do {
                if let expense = try await processMessage(id: messageId, accessToken: accessToken) {
                    expenses.append(expense)
                }
            } catch {
                logger.warning("Failed to process message \(messageId): \(error.localizedDescription)")
                // Continue processing other messages
            }
        }
        
        return expenses
    }
    
    private func processMessage(id: String, accessToken: String) async throws -> ExpenseItem? {
        let urlString = "\(gmailBaseURL)/users/me/messages/\(id)"
        
        guard let url = URL(string: urlString) else {
            throw GmailError.apiRequestFailed("Invalid message URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GmailError.apiRequestFailed("Failed to fetch message")
        }
        
        let messageResponse = try JSONDecoder().decode(MessageResponse.self, from: data)
        
        // Extract email metadata
        let headers = messageResponse.payload.headers
        let subject = headers.first { $0.name.lowercased() == "subject" }?.value ?? "No Subject"
        let fromAddress = headers.first { $0.name.lowercased() == "from" }?.value ?? "Unknown Sender"
        
        // Convert internal date to Date
        guard let timestamp = Double(messageResponse.internalDate) else {
            throw GmailError.messageParsingFailed("Invalid timestamp")
        }
        let emailDate = Date(timeIntervalSince1970: timestamp / 1000)
        
        // Extract email body text
        let bodyText = extractMessageText(from: messageResponse.payload)
        
        // Process for receipt content
        return try extractExpenseFromText(
            text: bodyText,
            subject: subject,
            fromAddress: fromAddress,
            emailDate: emailDate,
            emailId: id
        )
    }
    
    private func extractMessageText(from payload: MessageResponse.MessagePayload) -> String {
        var text = ""
        
        // Try to get text from main body
        if let bodyData = payload.body?.data {
            if let decodedText = decodeBase64URLString(bodyData) {
                text += decodedText
            }
        }
        
        // Process parts recursively
        if let parts = payload.parts {
            text += extractTextFromParts(parts)
        }
        
        return text
    }
    
    private func extractTextFromParts(_ parts: [MessageResponse.MessagePayload.Part]) -> String {
        var text = ""
        
        for part in parts {
            if let bodyData = part.body?.data {
                if let decodedText = decodeBase64URLString(bodyData) {
                    text += decodedText + "\n"
                }
            }
            
            if let subParts = part.parts {
                text += extractTextFromParts(subParts)
            }
        }
        
        return text
    }
    
    private func decodeBase64URLString(_ encoded: String) -> String? {
        // Convert base64url to base64
        var base64 = encoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        let paddingLength = 4 - (base64.count % 4)
        if paddingLength < 4 {
            base64 += String(repeating: "=", count: paddingLength)
        }
        
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Expense Extraction
    
    private func extractExpenseFromText(
        text: String,
        subject: String,
        fromAddress: String,
        emailDate: Date,
        emailId: String
    ) throws -> ExpenseItem? {
        
        let combinedText = "\(subject) \(text)".lowercased()
        
        // Check if this looks like a receipt/invoice
        let hasReceiptKeywords = receiptKeywords.contains { combinedText.contains($0) }
        guard hasReceiptKeywords else {
            return nil // Not a receipt email
        }
        
        // Extract amount
        guard let (amount, currency) = extractAmount(from: text) else {
            logger.debug("Could not extract amount from email: \(subject)")
            return nil
        }
        
        // Extract vendor name
        let vendor = extractVendor(from: subject, fromAddress: fromAddress, text: text)
        
        // Determine category
        let category = determineCategory(from: combinedText, vendor: vendor)
        
        // Extract payment method (if available)
        let paymentMethod = extractPaymentMethod(from: text)
        
        // Create expense item
        let expense = ExpenseItem(
            amount: amount,
            currency: currency,
            date: emailDate,
            vendor: vendor,
            category: category,
            paymentMethod: paymentMethod,
            description: subject,
            emailSubject: subject,
            emailDate: emailDate,
            emailId: emailId,
            confidenceScore: calculateConfidenceScore(
                hasAmount: true,
                hasVendor: !vendor.isEmpty,
                hasReceiptKeywords: hasReceiptKeywords,
                textLength: text.count
            )
        )
        
        logger.info("Extracted expense: \(vendor) - \(currency)\(String(format: "%.2f", amount))")
        return expense
    }
    
    private func extractAmount(from text: String) -> (amount: Double, currency: String)? {
        for pattern in amountPatterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(text.startIndex..., in: text)
            
            if let match = regex.firstMatch(in: text, options: [], range: range) {
                let matchRange = Range(match.range(at: 1), in: text)!
                let amountString = String(text[matchRange])
                    .replacingOccurrences(of: ",", with: "")
                
                if let amount = Double(amountString) {
                    let currency = detectCurrency(from: text)
                    return (amount: amount, currency: currency)
                }
            }
        }
        
        return nil
    }
    
    private func detectCurrency(from text: String) -> String {
        for (currency, patterns) in currencyPatterns {
            for pattern in patterns {
                if text.lowercased().contains(pattern.lowercased()) {
                    return currency
                }
            }
        }
        return "USD" // Default currency
    }
    
    private func extractVendor(from subject: String, fromAddress: String, text: String) -> String {
        // Try to extract from email address domain
        if let domain = fromAddress.split(separator: "@").last {
            let domainName = String(domain).split(separator: ".").first ?? ""
            if !domainName.isEmpty {
                return String(domainName).capitalized
            }
        }
        
        // Try to extract from subject
        let subjectWords = subject.split(separator: " ")
        if let firstWord = subjectWords.first, firstWord.count > 3 {
            return String(firstWord).capitalized
        }
        
        return "Unknown Merchant"
    }
    
    private func determineCategory(from text: String, vendor: String) -> ExpenseCategory {
        let searchText = "\(text) \(vendor)".lowercased()
        
        for category in ExpenseCategory.allCases {
            for keyword in category.keywords {
                if searchText.contains(keyword) {
                    return category
                }
            }
        }
        
        return .other
    }
    
    private func extractPaymentMethod(from text: String) -> String? {
        let paymentMethods = ["visa", "mastercard", "amex", "paypal", "apple pay", "google pay"]
        let lowerText = text.lowercased()
        
        for method in paymentMethods {
            if lowerText.contains(method) {
                return method.capitalized
            }
        }
        
        return nil
    }
    
    private func calculateConfidenceScore(
        hasAmount: Bool,
        hasVendor: Bool,
        hasReceiptKeywords: Bool,
        textLength: Int
    ) -> Double {
        var score = 0.0
        
        if hasAmount { score += 0.4 }
        if hasVendor { score += 0.2 }
        if hasReceiptKeywords { score += 0.3 }
        if textLength > 100 { score += 0.1 } // More detailed emails likely more accurate
        
        return min(score, 1.0)
    }
}

// MARK: - Array Extension for Batching

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}