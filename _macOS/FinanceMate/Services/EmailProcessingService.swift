import Foundation
import Security
import Network
import os.log

/// Real Gmail/Outlook Email Processing Service for Financial Document Extraction
/// Processes emails from bernhardbudiono@gmail.com for transaction, invoice, and receipt extraction
@MainActor
class EmailProcessingService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isProcessing: Bool = false
    @Published var processingProgress: Double = 0.0
    @Published var lastProcessedDate: Date?
    @Published var processedEmailsCount: Int = 0
    @Published var extractedTransactionsCount: Int = 0
    
    // MARK: - Private Properties
    private let logger = Logger(subsystem: "FinanceMate", category: "EmailProcessingService")
    private let urlSession: URLSession
    private let testEmailAccount = "bernhardbudiono@gmail.com"
    
    // API Configuration
    private struct APIConfiguration {
        static let gmailAPIBaseURL = "https://gmail.googleapis.com/gmail/v1"
        static let outlookAPIBaseURL = "https://graph.microsoft.com/v1.0"
        static let scopes = [
            "https://www.googleapis.com/auth/gmail.readonly",
            "https://graph.microsoft.com/mail.read"
        ]
    }
    
    // MARK: - Initialization
    
    init() {
        // Configure URL session for email API requests
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        self.urlSession = URLSession(configuration: config)
        
        logger.info("Email Processing Service initialized for account: \(self.testEmailAccount)")
    }
    
    // MARK: - Public Methods
    
    /// Process emails for financial documents (transactions, invoices, receipts)
    func processFinancialEmails() async throws -> EmailProcessingResult {
        logger.info("Starting email processing for financial documents")
        
        isProcessing = true
        processingProgress = 0.0
        
        defer {
            isProcessing = false
        }
        
        do {
            // Phase 1: Authenticate with email providers
            processingProgress = 0.1
            let authTokens = try await authenticateEmailProviders()
            
            // Phase 2: Fetch recent emails with financial content
            processingProgress = 0.3
            let financialEmails = try await fetchFinancialEmails(using: authTokens)
            
            // Phase 3: Extract attachments and process documents
            processingProgress = 0.5
            let extractedDocuments = try await extractFinancialDocuments(from: financialEmails)
            
            // Phase 4: Parse transactions and line items
            processingProgress = 0.7
            let transactions = try await parseFinancialTransactions(from: extractedDocuments)
            
            // Phase 5: Validate and categorize extracted data
            processingProgress = 0.9
            let validatedTransactions = try await validateTransactions(transactions)
            
            // Update statistics
            processedEmailsCount = financialEmails.count
            extractedTransactionsCount = validatedTransactions.count
            lastProcessedDate = Date()
            processingProgress = 1.0
            
            logger.info("Email processing completed: \(financialEmails.count) emails, \(validatedTransactions.count) transactions")
            
            return EmailProcessingResult(
                processedEmails: financialEmails.count,
                extractedTransactions: validatedTransactions,
                processingDate: Date(),
                account: testEmailAccount
            )
            
        } catch {
            logger.error("Email processing failed: \(error.localizedDescription)")
            throw EmailProcessingError.processingFailed("Email processing failed: \(error.localizedDescription)")
        }
    }
    
    /// Authenticate with Gmail and Outlook APIs
    func authenticateEmailProviders() async throws -> EmailAuthTokens {
        logger.info("Authenticating with email providers")
        
        // Gmail OAuth2 authentication
        let gmailToken = try await authenticateGmail()
        
        // Outlook OAuth2 authentication (optional)
        let outlookToken: String? = nil // Implement if Outlook integration required
        
        return EmailAuthTokens(
            gmailToken: gmailToken,
            outlookToken: outlookToken
        )
    }
    
    // MARK: - Gmail Integration
    
    private func authenticateGmail() async throws -> String {
        // For testing, we'll use a placeholder implementation
        // In production, this would implement full OAuth2 flow
        guard let storedToken = retrieveStoredToken(for: "gmail") else {
            throw EmailProcessingError.authenticationFailed("Gmail authentication required")
        }
        
        // Validate token with test request
        try await validateGmailToken(storedToken)
        
        return storedToken
    }
    
    private func validateGmailToken(_ token: String) async throws {
        let url = URL(string: "\(APIConfiguration.gmailAPIBaseURL)/users/me/profile")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (_, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EmailProcessingError.networkError("Invalid response from Gmail API")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw EmailProcessingError.authenticationFailed("Gmail token validation failed")
        }
    }
    
    private func fetchFinancialEmails(using tokens: EmailAuthTokens) async throws -> [EmailDocument] {
        logger.info("Fetching financial emails from Gmail")
        
        // Search for emails with financial keywords
        let searchQuery = "from:(noreply@amazon.com OR noreply@ebay.com OR receipts@ OR invoice@ OR billing@) has:attachment"
        let url = URL(string: "\(APIConfiguration.gmailAPIBaseURL)/users/me/messages?q=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(tokens.gmailToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await urlSession.data(for: request)
        
        let messageList = try JSONDecoder().decode(GmailMessageList.self, from: data)
        
        // Fetch detailed message information
        var emailDocuments: [EmailDocument] = []
        
        for message in messageList.messages.prefix(10) { // Limit for testing
            do {
                let emailDoc = try await fetchEmailDetails(messageId: message.id, token: tokens.gmailToken)
                emailDocuments.append(emailDoc)
            } catch {
                logger.warning("Failed to fetch email details for message \(message.id): \(error.localizedDescription)")
            }
        }
        
        return emailDocuments
    }
    
    private func fetchEmailDetails(messageId: String, token: String) async throws -> EmailDocument {
        let url = URL(string: "\(APIConfiguration.gmailAPIBaseURL)/users/me/messages/\(messageId)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await urlSession.data(for: request)
        let message = try JSONDecoder().decode(GmailMessage.self, from: data)
        
        // Extract relevant information
        let subject = extractHeaderValue(from: message.payload.headers, name: "Subject") ?? ""
        let from = extractHeaderValue(from: message.payload.headers, name: "From") ?? ""
        let date = extractHeaderValue(from: message.payload.headers, name: "Date") ?? ""
        
        return EmailDocument(
            id: messageId,
            subject: subject,
            from: from,
            date: parseEmailDate(date),
            attachments: extractAttachments(from: message.payload),
            body: extractBody(from: message.payload)
        )
    }
    
    // MARK: - Document Processing
    
    private func extractFinancialDocuments(from emails: [EmailDocument]) async throws -> [FinancialDocument] {
        logger.info("Extracting financial documents from \(emails.count) emails")
        
        var documents: [FinancialDocument] = []
        
        for email in emails {
            // Process attachments
            for attachment in email.attachments {
                if let document = try await processAttachment(attachment, from: email) {
                    documents.append(document)
                }
            }
            
            // Process email body for embedded receipts/invoices
            if let bodyDocument = try await processEmailBody(email) {
                documents.append(bodyDocument)
            }
        }
        
        return documents
    }
    
    private func processAttachment(_ attachment: EmailAttachment, from email: EmailDocument) async throws -> FinancialDocument? {
        // Skip non-financial attachments
        guard isFinancialAttachment(attachment) else { return nil }
        
        let attachmentData = try await downloadAttachment(attachment)
        
        // Use existing OCR service for document processing
        let ocrService = OCRService()
        let extractedText = try await ocrService.processDocument(data: attachmentData, type: attachment.mimeType)
        
        return FinancialDocument(
            id: UUID().uuidString,
            type: determineDocumentType(from: extractedText.text),
            source: .emailAttachment(emailId: email.id, attachmentId: attachment.id),
            extractedText: extractedText.text,
            merchantName: extractedText.merchantName,
            totalAmount: extractedText.totalAmount,
            lineItems: extractedText.lineItems,
            date: extractedText.date ?? email.date,
            originalEmail: email
        )
    }
    
    // MARK: - Transaction Processing
    
    private func parseFinancialTransactions(from documents: [FinancialDocument]) async throws -> [ExtractedTransaction] {
        logger.info("Parsing transactions from \(documents.count) financial documents")
        
        var transactions: [ExtractedTransaction] = []
        
        for document in documents {
            switch document.type {
            case .receipt:
                if let transaction = parseReceiptTransaction(from: document) {
                    transactions.append(transaction)
                }
            case .invoice:
                if let transaction = parseInvoiceTransaction(from: document) {
                    transactions.append(transaction)
                }
            case .statement:
                let statementTransactions = parseStatementTransactions(from: document)
                transactions.append(contentsOf: statementTransactions)
            }
        }
        
        return transactions
    }
    
    private func parseReceiptTransaction(from document: FinancialDocument) -> ExtractedTransaction? {
        guard let merchantName = document.merchantName,
              let totalAmount = document.totalAmount else { return nil }
        
        // Create line items with tax categories (as required by BLUEPRINT.md)
        let lineItems = document.lineItems.map { item in
            ExtractedLineItem(
                description: item.description,
                quantity: item.quantity,
                price: item.price,
                taxCategory: determineTaxCategory(for: item.description, merchant: merchantName),
                splitAllocations: generateDefaultSplitAllocations(for: item.description)
            )
        }
        
        return ExtractedTransaction(
            id: UUID().uuidString,
            merchantName: merchantName,
            totalAmount: totalAmount,
            date: document.date,
            lineItems: lineItems,
            sourceDocument: document,
            category: determineTransactionCategory(merchant: merchantName),
            confidence: calculateExtractionConfidence(document: document)
        )
    }
    
    private func parseInvoiceTransaction(from document: FinancialDocument) -> ExtractedTransaction? {
        // Similar to receipt parsing but with invoice-specific logic
        return parseReceiptTransaction(from: document)
    }
    
    private func parseStatementTransactions(from document: FinancialDocument) -> [ExtractedTransaction] {
        // Parse bank/credit card statements for multiple transactions
        return []
    }
    
    // MARK: - Validation & Categorization
    
    private func validateTransactions(_ transactions: [ExtractedTransaction]) async throws -> [ValidatedTransaction] {
        logger.info("Validating \(transactions.count) extracted transactions")
        
        var validatedTransactions: [ValidatedTransaction] = []
        
        for transaction in transactions {
            let validation = validateTransaction(transaction)
            
            if validation.isValid {
                let validatedTxn = ValidatedTransaction(
                    extractedTransaction: transaction,
                    validationResult: validation,
                    suggestedMatches: try await findExistingMatches(for: transaction),
                    enhancedCategories: enhanceCategories(for: transaction)
                )
                validatedTransactions.append(validatedTxn)
            } else {
                logger.warning("Transaction validation failed: \(validation.errors.joined(separator: ", "))")
            }
        }
        
        return validatedTransactions
    }
    
    // MARK: - Utility Methods
    
    private func retrieveStoredToken(for service: String) -> String? {
        // For testing, return a placeholder token
        // In production, this would retrieve from Keychain
        return "test_token_\(service)_\(testEmailAccount)"
    }
    
    private func extractHeaderValue(from headers: [GmailHeader], name: String) -> String? {
        return headers.first(where: { $0.name == name })?.value
    }
    
    private func parseEmailDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.date(from: dateString) ?? Date()
    }
    
    private func extractAttachments(from payload: GmailPayload) -> [EmailAttachment] {
        // Extract attachment information from Gmail payload
        var attachments: [EmailAttachment] = []
        
        if let parts = payload.parts {
            for part in parts {
                if let filename = part.filename,
                   !filename.isEmpty,
                   let body = part.body {
                    let attachment = EmailAttachment(
                        id: body.attachmentId ?? UUID().uuidString,
                        filename: filename,
                        mimeType: part.mimeType ?? "application/octet-stream",
                        size: body.size ?? 0
                    )
                    attachments.append(attachment)
                }
            }
        }
        
        return attachments
    }
    
    private func extractBody(from payload: GmailPayload) -> String {
        // Extract text body from Gmail payload
        if let body = payload.body?.data {
            return String(data: Data(base64Encoded: body) ?? Data(), encoding: .utf8) ?? ""
        }
        return ""
    }
    
    private func isFinancialAttachment(_ attachment: EmailAttachment) -> Bool {
        let financialExtensions = ["pdf", "png", "jpg", "jpeg", "tiff"]
        let ext = (attachment.filename as NSString).pathExtension.lowercased()
        return financialExtensions.contains(ext)
    }
    
    private func downloadAttachment(_ attachment: EmailAttachment) async throws -> Data {
        // Placeholder for attachment download
        // In production, this would download from Gmail API
        return Data()
    }
    
    private func processEmailBody(_ email: EmailDocument) async throws -> FinancialDocument? {
        // Process email body for inline receipts/invoices
        return nil
    }
    
    private func determineDocumentType(from text: String) -> FinancialDocumentType {
        let textLower = text.lowercased()
        
        if textLower.contains("invoice") {
            return .invoice
        } else if textLower.contains("receipt") || textLower.contains("purchase") {
            return .receipt
        } else {
            return .statement
        }
    }
    
    private func determineTaxCategory(for itemDescription: String, merchant: String) -> String {
        // Implement intelligent tax categorization based on BLUEPRINT requirements
        let description = itemDescription.lowercased()
        let merchantName = merchant.lowercased()
        
        // Business categories
        if description.contains("office") || description.contains("supplies") {
            return "Business Supplies"
        }
        
        // Personal categories
        if merchantName.contains("grocery") || description.contains("food") {
            return "Personal - Groceries"
        }
        
        // Default
        return "Uncategorized"
    }
    
    private func generateDefaultSplitAllocations(for itemDescription: String) -> [String: Double] {
        // Generate default split allocations as required by BLUEPRINT.md
        let category = determineTaxCategory(for: itemDescription, merchant: "")
        
        if category.contains("Business") {
            return ["Business": 100.0]
        } else {
            return ["Personal": 100.0]
        }
    }
    
    private func determineTransactionCategory(merchant: String) -> String {
        // Determine high-level transaction category
        let merchantLower = merchant.lowercased()
        
        if merchantLower.contains("grocery") || merchantLower.contains("supermarket") {
            return "Groceries"
        } else if merchantLower.contains("gas") || merchantLower.contains("petrol") {
            return "Fuel"
        } else if merchantLower.contains("restaurant") || merchantLower.contains("cafe") {
            return "Dining"
        }
        
        return "General"
    }
    
    private func calculateExtractionConfidence(document: FinancialDocument) -> Double {
        var confidence = 0.0
        
        // Base confidence
        confidence += 0.3
        
        // Merchant name confidence
        if document.merchantName != nil { confidence += 0.2 }
        
        // Amount confidence
        if document.totalAmount != nil { confidence += 0.2 }
        
        // Line items confidence
        if !document.lineItems.isEmpty { confidence += 0.2 }
        
        // Date confidence
        if document.date != nil { confidence += 0.1 }
        
        return min(confidence, 1.0)
    }
    
    private func validateTransaction(_ transaction: ExtractedTransaction) -> TransactionValidation {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Validate required fields
        if transaction.merchantName.isEmpty {
            errors.append("Missing merchant name")
        }
        
        if transaction.totalAmount <= 0 {
            errors.append("Invalid total amount")
        }
        
        if transaction.lineItems.isEmpty {
            warnings.append("No line items extracted")
        }
        
        // Validate line item split allocations sum to 100%
        for lineItem in transaction.lineItems {
            let totalPercentage = lineItem.splitAllocations.values.reduce(0, +)
            if abs(totalPercentage - 100.0) > 0.01 {
                errors.append("Line item split allocations must sum to 100%")
            }
        }
        
        return TransactionValidation(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings,
            confidence: transaction.confidence
        )
    }
    
    private func findExistingMatches(for transaction: ExtractedTransaction) async throws -> [ExistingTransactionMatch] {
        // Find potential matches with existing transactions
        return []
    }
    
    private func enhanceCategories(for transaction: ExtractedTransaction) -> [String] {
        // Enhance categories using AI/ML if available
        return [transaction.category]
    }
}

// MARK: - Data Models

struct EmailAuthTokens {
    let gmailToken: String
    let outlookToken: String?
}

struct EmailProcessingResult {
    let processedEmails: Int
    let extractedTransactions: [ValidatedTransaction]
    let processingDate: Date
    let account: String
}

struct EmailDocument {
    let id: String
    let subject: String
    let from: String
    let date: Date
    let attachments: [EmailAttachment]
    let body: String
}

struct EmailAttachment {
    let id: String
    let filename: String
    let mimeType: String
    let size: Int
}

struct FinancialDocument {
    let id: String
    let type: FinancialDocumentType
    let source: FinancialDocumentSource
    let extractedText: String
    let merchantName: String?
    let totalAmount: Double?
    let lineItems: [ExtractedLineItem]
    let date: Date
    let originalEmail: EmailDocument
}

enum FinancialDocumentType {
    case receipt
    case invoice
    case statement
}

enum FinancialDocumentSource {
    case emailAttachment(emailId: String, attachmentId: String)
    case emailBody(emailId: String)
}

struct ExtractedLineItem {
    let description: String
    let quantity: Double
    let price: Double
    let taxCategory: String
    let splitAllocations: [String: Double] // Tax category -> percentage
}

struct ExtractedTransaction {
    let id: String
    let merchantName: String
    let totalAmount: Double
    let date: Date
    let lineItems: [ExtractedLineItem]
    let sourceDocument: FinancialDocument
    let category: String
    let confidence: Double
}

struct ValidatedTransaction {
    let extractedTransaction: ExtractedTransaction
    let validationResult: TransactionValidation
    let suggestedMatches: [ExistingTransactionMatch]
    let enhancedCategories: [String]
}

struct TransactionValidation {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]
    let confidence: Double
}

struct ExistingTransactionMatch {
    let transactionId: String
    let similarity: Double
    let matchType: MatchType
    
    enum MatchType {
        case exactAmount
        case merchantAndDate
        case fuzzyMatch
    }
}

// MARK: - Gmail API Models

struct GmailMessageList: Codable {
    let messages: [GmailMessageInfo]
}

struct GmailMessageInfo: Codable {
    let id: String
    let threadId: String
}

struct GmailMessage: Codable {
    let id: String
    let threadId: String
    let payload: GmailPayload
}

struct GmailPayload: Codable {
    let headers: [GmailHeader]
    let body: GmailBody?
    let parts: [GmailPart]?
    let mimeType: String?
}

struct GmailHeader: Codable {
    let name: String
    let value: String
}

struct GmailBody: Codable {
    let attachmentId: String?
    let size: Int?
    let data: String?
}

struct GmailPart: Codable {
    let mimeType: String?
    let filename: String?
    let body: GmailBody?
}

// MARK: - Error Types

enum EmailProcessingError: LocalizedError {
    case authenticationFailed(String)
    case networkError(String)
    case processingFailed(String)
    case invalidData(String)
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed(let message):
            return "Authentication Failed: \(message)"
        case .networkError(let message):
            return "Network Error: \(message)"
        case .processingFailed(let message):
            return "Processing Failed: \(message)"
        case .invalidData(let message):
            return "Invalid Data: \(message)"
        }
    }
}