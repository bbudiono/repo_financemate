//
//  SampleDataService.swift
//  FinanceMate
//
//  Purpose: Populates Core Data with realistic sample financial data for production demonstration
//

import Foundation
import CoreData

class SampleDataService {
    static let shared = SampleDataService()
    
    private init() {}
    
    func populateSampleDataIfNeeded(context: NSManagedObjectContext) {
        // Check if we already have data
        let request: NSFetchRequest<FinancialData> = FinancialData.fetchRequest()
        do {
            let count = try context.count(for: request)
            if count > 0 {
                return // Already have data, don't populate
            }
        } catch {
            print("Error checking existing data: \(error)")
            return
        }
        
        // Create sample categories
        let businessCategory = createCategory(name: "Business", context: context)
        let personalCategory = createCategory(name: "Personal", context: context)
        let investmentCategory = createCategory(name: "Investment", context: context)
        
        // Create sample clients
        let techCorpClient = createClient(name: "TechCorp Solutions", context: context)
        let startupClient = createClient(name: "Startup Innovations", context: context)
        let personalClient = createClient(name: "Personal", context: context)
        
        // Create sample financial data for the last 3 months
        let calendar = Calendar.current
        let now = Date()
        
        // Income transactions
        let incomeData = [
            (amount: 5200.0, description: "Software Consulting - Q1 Project", daysAgo: 5, client: techCorpClient, category: businessCategory),
            (amount: 3800.0, description: "Mobile App Development", daysAgo: 12, client: startupClient, category: businessCategory),
            (amount: 2600.0, description: "Website Redesign Project", daysAgo: 18, client: techCorpClient, category: businessCategory),
            (amount: 4100.0, description: "API Integration Services", daysAgo: 25, client: startupClient, category: businessCategory),
            (amount: 1500.0, description: "Code Review & Optimization", daysAgo: 32, client: techCorpClient, category: businessCategory),
            (amount: 3200.0, description: "Database Migration Project", daysAgo: 38, client: startupClient, category: businessCategory),
            (amount: 2800.0, description: "Security Audit Consulting", daysAgo: 45, client: techCorpClient, category: businessCategory),
            (amount: 800.0, description: "Investment Returns - AAPL", daysAgo: 15, client: personalClient, category: investmentCategory),
            (amount: 450.0, description: "Dividend - Index Fund", daysAgo: 30, client: personalClient, category: investmentCategory),
            (amount: 650.0, description: "Investment Returns - MSFT", daysAgo: 60, client: personalClient, category: investmentCategory)
        ]
        
        // Expense transactions (negative amounts)
        let expenseData = [
            (amount: -1200.0, description: "Office Rent", daysAgo: 3, client: personalClient, category: businessCategory),
            (amount: -450.0, description: "Software Licenses & Subscriptions", daysAgo: 7, client: personalClient, category: businessCategory),
            (amount: -285.50, description: "Office Supplies & Equipment", daysAgo: 10, client: personalClient, category: businessCategory),
            (amount: -125.35, description: "Business Meals & Entertainment", daysAgo: 14, client: personalClient, category: businessCategory),
            (amount: -89.99, description: "Internet & Phone Services", daysAgo: 20, client: personalClient, category: businessCategory),
            (amount: -850.0, description: "Professional Development Course", daysAgo: 28, client: personalClient, category: businessCategory),
            (amount: -320.0, description: "Accounting Software", daysAgo: 35, client: personalClient, category: businessCategory),
            (amount: -75.00, description: "Cloud Storage Services", daysAgo: 42, client: personalClient, category: businessCategory),
            (amount: -200.0, description: "Marketing & Advertising", daysAgo: 50, client: personalClient, category: businessCategory),
            (amount: -150.0, description: "Business Insurance", daysAgo: 55, client: personalClient, category: businessCategory)
        ]
        
        // Create financial data entries
        for income in incomeData {
            createFinancialData(
                amount: income.amount,
                description: income.description,
                daysAgo: income.daysAgo,
                client: income.client,
                category: income.category,
                context: context
            )
        }
        
        for expense in expenseData {
            createFinancialData(
                amount: expense.amount,
                description: expense.description,
                daysAgo: expense.daysAgo,
                client: expense.client,
                category: expense.category,
                context: context
            )
        }
        
        // Save the context
        do {
            try context.save()
            print("✅ Sample financial data populated successfully")
        } catch {
            print("❌ Error saving sample data: \(error)")
        }
    }
    
    private func createCategory(name: String, context: NSManagedObjectContext) -> Category {
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.dateCreated = Date()
        category.dateModified = Date()
        category.isActive = true
        category.isDefault = false
        category.sortOrder = 0
        category.colorHex = "#007AFF" // Default blue color
        category.iconName = "folder"
        category.categoryDescription = "\(name) category"
        return category
    }
    
    private func createClient(name: String, context: NSManagedObjectContext) -> Client {
        let client = Client(context: context)
        client.id = UUID()
        client.name = name
        client.dateCreated = Date()
        client.dateModified = Date()
        client.isActive = true
        client.clientType = "customer"
        client.email = "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@example.com"
        client.currentBalance = NSDecimalNumber(value: 0.0)
        client.creditLimit = NSDecimalNumber(value: 10000.0)
        return client
    }
    
    private func createFinancialData(
        amount: Double,
        description: String,
        daysAgo: Int,
        client: Client,
        category: Category,
        context: NSManagedObjectContext
    ) {
        let financialData = FinancialData(context: context)
        financialData.id = UUID()
        financialData.totalAmount = NSDecimalNumber(value: amount)
        financialData.currency = "USD"
        financialData.vendorName = client.name
        financialData.invoiceNumber = "INV-\(Int.random(in: 1000...9999))"
        financialData.invoiceDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())
        financialData.dateExtracted = Date()
        financialData.extractionConfidence = Double.random(in: 0.85...0.98)
        financialData.taxRate = 0.0825 // Default 8.25% tax rate
        financialData.taxAmount = NSDecimalNumber(value: abs(amount) * 0.0825)
        
        // Create document
        let document = Document(context: context)
        document.id = UUID()
        document.fileName = "\(description.replacingOccurrences(of: " ", with: "_")).pdf"
        document.filePath = "/sample/documents/\(document.fileName ?? "unknown.pdf")"
        document.fileSize = Int64.random(in: 50000...500000) // Random file size 50KB-500KB
        document.mimeType = "application/pdf"
        document.dateCreated = financialData.invoiceDate
        document.dateModified = Date()
        document.documentType = amount > 0 ? "invoice" : "receipt"
        document.processingStatus = "completed"
        document.notes = "Sample financial document"
        document.fileHash = "sha256-\(UUID().uuidString.prefix(16))"
        document.ocrConfidence = Double.random(in: 0.9...0.99)
        document.rawOCRText = "Extracted text for \(description)"
        document.metadata = "{\"source\":\"sample\"}"
        document.isArchived = false
        document.isFavorite = false
        document.category = category
        document.client = client
        
        // Link financial data to document
        financialData.document = document
    }
}