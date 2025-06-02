// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  FinancialDocumentProcessor.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Core financial document processing engine with AI-powered OCR and intelligent data extraction
* Issues & Complexity Summary: Advanced document analysis with financial data classification and structured output
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~500
  - Core Algorithm Complexity: High
  - Dependencies: 6 New (OCRService, Financial patterns, Data classification, Currency parsing, Date extraction, AI inference)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 85%
* Problem Estimate (Inherent Problem Difficulty %): 80%
* Initial Code Complexity Estimate %: 82%
* Justification for Estimates: Complex financial data extraction requiring pattern recognition and AI classification
* Final Code Complexity (Actual %): TBD - Implementation in progress
* Overall Result Score (Success & Quality %): TBD - TDD development
* Key Variances/Learnings: Focus on accuracy and structured data output for financial analysis
* Last Updated: 2025-06-02
*/

import Foundation
import Vision
import SwiftUI
import Combine
import PDFKit

// MARK: - Financial Document Processor

@MainActor
public class FinancialDocumentProcessor: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var isProcessing: Bool = false
    @Published public var processingProgress: Double = 0.0
    @Published public var lastProcessedDocument: ProcessedFinancialDocument?
    @Published public var processingError: String?
    
    // MARK: - Private Properties
    
    private let ocrService: OCRService
    private let currencyFormatter: NumberFormatter
    private let dateDetector: NSDataDetector
    
    // MARK: - Initialization
    
    public init() {
        self.ocrService = OCRService()
        
        // Configure currency formatter
        self.currencyFormatter = NumberFormatter()
        self.currencyFormatter.numberStyle = .currency
        self.currencyFormatter.currencyCode = "USD"
        
        // Configure date detector
        self.dateDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
    }
    
    // MARK: - Public Processing Methods
    
    public func processFinancialDocument(url: URL) async -> Result<ProcessedFinancialDocument, FinancialProcessingError> {
        isProcessing = true
        processingProgress = 0.0
        processingError = nil
        
        defer {
            Task { @MainActor in
                isProcessing = false
                processingProgress = 0.0
            }
        }
        
        do {
            // Step 1: Detect document type (10%)
            await updateProgress(0.1)
            let documentType = detectFinancialDocumentType(from: url)
            
            // Step 2: Extract text via OCR (40%)
            await updateProgress(0.4)
            let extractedText = try await extractTextFromDocument(url: url)
            
            // Step 3: Classify and extract financial data (30%)
            await updateProgress(0.7)
            let financialData = await classifyFinancialData(text: extractedText, documentType: documentType)
            
            // Step 4: Structure and validate results (20%)
            await updateProgress(0.9)
            let financialDocument = await createFinancialDocument(
                url: url,
                documentType: documentType,
                extractedText: extractedText,
                financialData: financialData
            )
            
            await updateProgress(1.0)
            lastProcessedDocument = financialDocument
            
            return .success(financialDocument)
            
        } catch {
            let processingError = FinancialProcessingError.processingFailed(error)
            self.processingError = processingError.localizedDescription
            return .failure(processingError)
        }
    }
    
    public func batchProcessDocuments(urls: [URL]) async -> [Result<ProcessedFinancialDocument, FinancialProcessingError>] {
        var results: [Result<ProcessedFinancialDocument, FinancialProcessingError>] = []
        let totalDocuments = urls.count
        
        for (index, url) in urls.enumerated() {
            let result = await processFinancialDocument(url: url)
            results.append(result)
            
            // Update overall batch progress
            let batchProgress = Double(index + 1) / Double(totalDocuments)
            await updateProgress(batchProgress)
        }
        
        return results
    }
    
    // MARK: - Document Type Detection
    
    private func detectFinancialDocumentType(from url: URL) -> ProcessedDocumentType {
        let fileName = url.lastPathComponent.lowercased()
        let pathExtension = url.pathExtension.lowercased()
        
        // Check filename patterns first
        if fileName.contains("invoice") {
            return .invoice
        } else if fileName.contains("receipt") {
            return .receipt
        } else if fileName.contains("statement") || fileName.contains("bank") {
            return .bankStatement
        } else if fileName.contains("tax") || fileName.contains("1099") || fileName.contains("w2") {
            return .taxDocument
        } else if fileName.contains("expense") || fileName.contains("report") {
            return .expenseReport
        }
        
        // Default based on file type
        switch pathExtension {
        case "pdf":
            return .invoice // Most common financial PDF
        case "jpg", "jpeg", "png", "heic":
            return .receipt // Most common financial image
        default:
            return .unknown
        }
    }
    
    // MARK: - Text Extraction
    
    private func extractTextFromDocument(url: URL) async throws -> String {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return extractTextFromPDF(url: url)
        case "jpg", "jpeg", "png", "tiff", "heic":
            return try await extractTextFromImage(url: url)
        case "txt", "rtf":
            return try String(contentsOf: url, encoding: .utf8)
        default:
            throw FinancialProcessingError.unsupportedFormat
        }
    }
    
    private func extractTextFromPDF(url: URL) -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            return ""
        }
        
        var extractedText = ""
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                extractedText += page.string ?? ""
                extractedText += "\n"
            }
        }
        
        return extractedText
    }
    
    private func extractTextFromImage(url: URL) async throws -> String {
        do {
            let text = try await ocrService.extractText(from: url)
            return text
        } catch {
            throw FinancialProcessingError.ocrFailed(error)
        }
    }
    
    // MARK: - Financial Data Classification
    
    private func classifyFinancialData(text: String, documentType: ProcessedDocumentType) async -> ExtractedFinancialData {
        let amounts = extractAmounts(from: text)
        let dates = extractDates(from: text)
        let vendors = extractVendors(from: text, documentType: documentType)
        let categories = classifyExpenseCategories(from: text)
        let lineItems = extractLineItems(from: text)
        let taxInfo = extractTaxInformation(from: text)
        
        return ExtractedFinancialData(
            totalAmount: amounts.first,
            subTotal: findSubTotal(in: amounts),
            taxAmount: taxInfo.taxAmount,
            discountAmount: findDiscount(in: text),
            currencyCode: extractCurrency(from: text) ?? "USD",
            invoiceNumber: extractInvoiceNumber(from: text),
            vendor: vendors.first,
            customerInfo: extractCustomerInfo(from: text),
            dates: dates,
            lineItems: lineItems,
            categories: categories,
            paymentTerms: extractPaymentTerms(from: text),
            confidence: calculateConfidence(text: text, extractedData: amounts.count + dates.count)
        )
    }
    
    // MARK: - Data Extraction Methods
    
    private func extractAmounts(from text: String) -> [ExtractedAmount] {
        var amounts: [ExtractedAmount] = []
        
        // Regular expressions for different currency patterns
        let patterns = [
            #"\$[\d,]+\.?\d*"#,  // $1,234.56
            #"USD\s*[\d,]+\.?\d*"#,  // USD 1234.56
            #"[\d,]+\.?\d*\s*USD"#,  // 1234.56 USD
            #"\b\d{1,3}(?:,\d{3})*(?:\.\d{2})?\b"#  // 1,234.56
        ]
        
        for pattern in patterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches {
                if let range = Range(match.range, in: text) {
                    let amountString = String(text[range])
                    if let amount = parseAmount(from: amountString) {
                        amounts.append(amount)
                    }
                }
            }
        }
        
        return amounts.sorted { $0.value > $1.value } // Largest amounts first
    }
    
    private func parseAmount(from string: String) -> ExtractedAmount? {
        let cleanedString = string
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "USD", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        guard let value = Double(cleanedString) else { return nil }
        
        return ExtractedAmount(
            value: value,
            currency: "USD",
            formattedString: string.trimmingCharacters(in: .whitespaces)
        )
    }
    
    private func extractDates(from text: String) -> [ExtractedDate] {
        var financialDates: [ExtractedDate] = []
        let matches = dateDetector.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        for match in matches {
            if let date = match.date,
               let range = Range(match.range, in: text) {
                let context = String(text[range])
                let dateType = classifyDateType(context: context, text: text)
                
                financialDates.append(ExtractedDate(
                    date: date,
                    type: dateType,
                    context: context
                ))
            }
        }
        
        return financialDates
    }
    
    private func classifyDateType(context: String, text: String) -> ExtractedDateType {
        let lowerContext = context.lowercased()
        let surroundingText = text.lowercased()
        
        if lowerContext.contains("due") || surroundingText.contains("due date") {
            return .dueDate
        } else if lowerContext.contains("invoice") || surroundingText.contains("invoice date") {
            return .invoiceDate
        } else if lowerContext.contains("service") || surroundingText.contains("service date") {
            return .serviceDate
        } else if lowerContext.contains("payment") {
            return .paymentDate
        } else {
            return .transactionDate
        }
    }
    
    private func extractVendors(from text: String, documentType: ProcessedDocumentType) -> [ExtractedVendor] {
        var vendors: [ExtractedVendor] = []
        
        // Common vendor patterns
        let patterns = [
            #"(?:FROM|BILL TO|VENDOR):\s*([^\n]+)"#,
            #"^([A-Z][A-Za-z\s&]+(?:LLC|Inc|Corp|Co\.)?)"#
        ]
        
        for pattern in patterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .caseInsensitive])
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches {
                if match.numberOfRanges > 1,
                   let range = Range(match.range(at: 1), in: text) {
                    let vendorName = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !vendorName.isEmpty && vendorName.count > 2 {
                        vendors.append(ExtractedVendor(
                            name: vendorName,
                            address: extractVendorAddress(near: vendorName, in: text),
                            taxId: extractTaxId(near: vendorName, in: text)
                        ))
                    }
                }
            }
        }
        
        return vendors
    }
    
    private func extractVendorAddress(near vendorName: String, in text: String) -> String? {
        // Simple address extraction - look for lines after vendor name
        let lines = text.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            if line.contains(vendorName) && index + 1 < lines.count {
                let nextLine = lines[index + 1].trimmingCharacters(in: .whitespaces)
                let addressPattern = #"\d+.*(?:St|Ave|Rd|Dr|Blvd)"#
                let regex = try! NSRegularExpression(pattern: addressPattern, options: .caseInsensitive)
                let range = NSRange(nextLine.startIndex..., in: nextLine)
                if regex.firstMatch(in: nextLine, range: range) != nil {
                    return nextLine
                }
            }
        }
        
        return nil
    }
    
    private func extractTaxId(near vendorName: String, in text: String) -> String? {
        let taxIdPattern = #"(?:Tax ID|TIN|EIN):\s*(\d{2}-\d{7})"#
        let regex = try! NSRegularExpression(pattern: taxIdPattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        for match in matches {
            if match.numberOfRanges > 1,
               let range = Range(match.range(at: 1), in: text) {
                return String(text[range])
            }
        }
        
        return nil
    }
    
    private func classifyExpenseCategories(from text: String) -> [ExtractedExpenseCategory] {
        let categoryKeywords: [ExtractedExpenseCategory: [String]] = [
            .office: ["office", "supplies", "paper", "pen", "stapler", "desk"],
            .travel: ["flight", "hotel", "uber", "taxi", "mileage", "airfare", "lodging"],
            .meals: ["restaurant", "lunch", "dinner", "coffee", "food", "catering"],
            .utilities: ["electric", "gas", "water", "internet", "phone", "utility"],
            .software: ["software", "subscription", "saas", "license", "app"],
            .marketing: ["advertising", "marketing", "promotion", "campaign", "social media"],
            .professional: ["legal", "accounting", "consulting", "professional services"],
            .equipment: ["computer", "laptop", "printer", "equipment", "hardware"],
            .maintenance: ["repair", "maintenance", "cleaning", "service"],
            .insurance: ["insurance", "premium", "coverage", "policy"]
        ]
        
        var detectedCategories: [ExtractedExpenseCategory] = []
        let lowerText = text.lowercased()
        
        for (category, keywords) in categoryKeywords {
            for keyword in keywords {
                if lowerText.contains(keyword) {
                    detectedCategories.append(category)
                    break
                }
            }
        }
        
        return detectedCategories.isEmpty ? [.other] : Array(Set(detectedCategories))
    }
    
    private func extractLineItems(from text: String) -> [ExtractedLineItem] {
        var lineItems: [ExtractedLineItem] = []
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            // Look for lines with quantities, descriptions, and amounts
            let lineItemPattern = #"(.+?)\s+(\d+(?:\.\d+)?)\s+(\$?[\d,]+\.?\d*)"#
            let regex = try! NSRegularExpression(pattern: lineItemPattern)
            let matches = regex.matches(in: line, range: NSRange(line.startIndex..., in: line))
            
            for match in matches {
                if match.numberOfRanges == 4 {
                    let descriptionRange = Range(match.range(at: 1), in: line)!
                    let quantityRange = Range(match.range(at: 2), in: line)!
                    let amountRange = Range(match.range(at: 3), in: line)!
                    
                    let description = String(line[descriptionRange]).trimmingCharacters(in: .whitespaces)
                    let quantityString = String(line[quantityRange])
                    let amountString = String(line[amountRange])
                    
                    if let quantity = Double(quantityString),
                       let amount = parseAmount(from: amountString) {
                        lineItems.append(ExtractedLineItem(
                            description: description,
                            quantity: quantity,
                            unitPrice: amount.value / quantity,
                            totalAmount: amount,
                            category: classifyItemCategory(description: description)
                        ))
                    }
                }
            }
        }
        
        return lineItems
    }
    
    private func classifyItemCategory(description: String) -> ExtractedExpenseCategory {
        let lowerDescription = description.lowercased()
        
        if lowerDescription.contains("software") || lowerDescription.contains("license") {
            return .software
        } else if lowerDescription.contains("travel") || lowerDescription.contains("flight") {
            return .travel
        } else if lowerDescription.contains("office") || lowerDescription.contains("supplies") {
            return .office
        } else if lowerDescription.contains("food") || lowerDescription.contains("meal") {
            return .meals
        } else {
            return .other
        }
    }
    
    private func extractTaxInformation(from text: String) -> ExtractedTaxInfo {
        var taxAmount: ExtractedAmount?
        var taxRate: Double?
        let taxId: String? = nil
        
        // Extract tax amount
        let taxAmountPattern = #"(?:Tax|VAT|GST):\s*\$?([\d,]+\.?\d*)"#
        let taxRegex = try! NSRegularExpression(pattern: taxAmountPattern, options: .caseInsensitive)
        let taxMatches = taxRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = taxMatches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            let amountString = String(text[range])
            taxAmount = parseAmount(from: amountString)
        }
        
        // Extract tax rate
        let taxRatePattern = #"(\d+(?:\.\d+)?)\s*%"#
        let rateRegex = try! NSRegularExpression(pattern: taxRatePattern)
        let rateMatches = rateRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = rateMatches.first,
           let range = Range(match.range(at: 1), in: text) {
            let rateString = String(text[range])
            taxRate = Double(rateString)
        }
        
        return ExtractedTaxInfo(
            taxAmount: taxAmount,
            taxRate: taxRate,
            taxId: taxId,
            isTaxExempt: text.lowercased().contains("tax exempt")
        )
    }
    
    // MARK: - Helper Methods
    
    private func findSubTotal(in amounts: [ExtractedAmount]) -> ExtractedAmount? {
        // Usually the second largest amount is subtotal
        return amounts.count > 1 ? amounts[1] : nil
    }
    
    private func findDiscount(in text: String) -> ExtractedAmount? {
        let discountPattern = #"(?:Discount|Savings):\s*\$?([\d,]+\.?\d*)"#
        let regex = try! NSRegularExpression(pattern: discountPattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            let amountString = String(text[range])
            return parseAmount(from: amountString)
        }
        
        return nil
    }
    
    private func extractCurrency(from text: String) -> String? {
        let currencyPattern = #"([A-Z]{3})\s*[\d,]+"#
        let regex = try! NSRegularExpression(pattern: currencyPattern)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            return String(text[range])
        }
        
        return nil
    }
    
    private func extractInvoiceNumber(from text: String) -> String? {
        let invoicePattern = #"(?:Invoice|INV)(?:\s*#?):\s*([A-Z0-9-]+)"#
        let regex = try! NSRegularExpression(pattern: invoicePattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            return String(text[range])
        }
        
        return nil
    }
    
    private func extractCustomerInfo(from text: String) -> ExtractedCustomer? {
        let customerPattern = #"(?:Bill To|Customer):\s*([^\n]+)"#
        let regex = try! NSRegularExpression(pattern: customerPattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            let customerName = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            return ExtractedCustomer(name: customerName, address: nil, email: nil)
        }
        
        return nil
    }
    
    private func extractPaymentTerms(from text: String) -> String? {
        let termsPattern = #"(?:Payment Terms|Terms):\s*([^\n]+)"#
        let regex = try! NSRegularExpression(pattern: termsPattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
    
    private func calculateConfidence(text: String, extractedData: Int) -> Double {
        let textLength = text.count
        let hasAmounts = extractedData > 0
        let hasVendor = text.lowercased().contains("invoice") || text.lowercased().contains("receipt")
        
        var confidence = 0.3 // Base confidence
        
        if hasAmounts { confidence += 0.3 }
        if hasVendor { confidence += 0.2 }
        if textLength > 200 { confidence += 0.2 }
        
        return min(confidence, 1.0)
    }
    
    private func createFinancialDocument(
        url: URL,
        documentType: ProcessedDocumentType,
        extractedText: String,
        financialData: ExtractedFinancialData
    ) async -> ProcessedFinancialDocument {
        return ProcessedFinancialDocument(
            id: UUID(),
            originalURL: url,
            documentType: documentType,
            extractedText: extractedText,
            financialData: financialData,
            processingStatus: .completed,
            processedDate: Date(),
            lastModified: Date()
        )
    }
    
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            self.processingProgress = progress
        }
    }
}

// MARK: - Supporting Data Models

public struct ProcessedFinancialDocument: Identifiable, Codable {
    public let id: UUID
    public let originalURL: URL
    public let documentType: ProcessedDocumentType
    public let extractedText: String
    public let financialData: ExtractedFinancialData
    public let processingStatus: DocumentProcessingStatus
    public let processedDate: Date
    public let lastModified: Date
    
    public init(id: UUID, originalURL: URL, documentType: ProcessedDocumentType, extractedText: String, financialData: ExtractedFinancialData, processingStatus: DocumentProcessingStatus, processedDate: Date, lastModified: Date) {
        self.id = id
        self.originalURL = originalURL
        self.documentType = documentType
        self.extractedText = extractedText
        self.financialData = financialData
        self.processingStatus = processingStatus
        self.processedDate = processedDate
        self.lastModified = lastModified
    }
}

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
    
    public var color: Color {
        switch self {
        case .invoice: return .orange
        case .receipt: return .purple
        case .bankStatement: return .blue
        case .taxDocument: return .red
        case .expenseReport: return .green
        case .contract: return .indigo
        case .unknown: return .gray
        }
    }
}

public struct ExtractedFinancialData: Codable {
    public let totalAmount: ExtractedAmount?
    public let subTotal: ExtractedAmount?
    public let taxAmount: ExtractedAmount?
    public let discountAmount: ExtractedAmount?
    public let currencyCode: String
    public let invoiceNumber: String?
    public let vendor: ExtractedVendor?
    public let customerInfo: ExtractedCustomer?
    public let dates: [ExtractedDate]
    public let lineItems: [ExtractedLineItem]
    public let categories: [ExtractedExpenseCategory]
    public let paymentTerms: String?
    public let confidence: Double
    
    public init(totalAmount: ExtractedAmount?, subTotal: ExtractedAmount?, taxAmount: ExtractedAmount?, discountAmount: ExtractedAmount?, currencyCode: String, invoiceNumber: String?, vendor: ExtractedVendor?, customerInfo: ExtractedCustomer?, dates: [ExtractedDate], lineItems: [ExtractedLineItem], categories: [ExtractedExpenseCategory], paymentTerms: String?, confidence: Double) {
        self.totalAmount = totalAmount
        self.subTotal = subTotal
        self.taxAmount = taxAmount
        self.discountAmount = discountAmount
        self.currencyCode = currencyCode
        self.invoiceNumber = invoiceNumber
        self.vendor = vendor
        self.customerInfo = customerInfo
        self.dates = dates
        self.lineItems = lineItems
        self.categories = categories
        self.paymentTerms = paymentTerms
        self.confidence = confidence
    }
}

public struct ExtractedAmount: Codable {
    public let value: Double
    public let currency: String
    public let formattedString: String
    
    public init(value: Double, currency: String, formattedString: String) {
        self.value = value
        self.currency = currency
        self.formattedString = formattedString
    }
}

public struct ExtractedVendor: Codable {
    public let name: String
    public let address: String?
    public let taxId: String?
    
    public init(name: String, address: String?, taxId: String?) {
        self.name = name
        self.address = address
        self.taxId = taxId
    }
}

public struct ExtractedCustomer: Codable {
    public let name: String
    public let address: String?
    public let email: String?
    
    public init(name: String, address: String?, email: String?) {
        self.name = name
        self.address = address
        self.email = email
    }
}

public struct ExtractedDate: Codable {
    public let date: Date
    public let type: ExtractedDateType
    public let context: String
    
    public init(date: Date, type: ExtractedDateType, context: String) {
        self.date = date
        self.type = type
        self.context = context
    }
}

public enum ExtractedDateType: String, CaseIterable, Codable {
    case invoiceDate = "Invoice Date"
    case dueDate = "Due Date"
    case serviceDate = "Service Date"
    case paymentDate = "Payment Date"
    case transactionDate = "Transaction Date"
}

public struct ExtractedLineItem: Codable {
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

public enum ExtractedExpenseCategory: String, CaseIterable, Codable {
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
}

public struct ExtractedTaxInfo: Codable {
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

public enum FinancialProcessingError: Error, LocalizedError {
    case processingFailed(Error)
    case ocrFailed(Error)
    case unsupportedFormat
    case invalidDocument
    case extractionFailed
    
    public var errorDescription: String? {
        switch self {
        case .processingFailed(let error):
            return "Financial document processing failed: \(error.localizedDescription)"
        case .ocrFailed(let error):
            return "OCR processing failed: \(error.localizedDescription)"
        case .unsupportedFormat:
            return "Unsupported financial document format"
        case .invalidDocument:
            return "Invalid financial document"
        case .extractionFailed:
            return "Failed to extract financial data"
        }
    }
}

