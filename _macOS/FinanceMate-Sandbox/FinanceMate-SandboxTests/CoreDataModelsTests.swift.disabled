// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: TDD tests for Core Data models in FinanceMate Sandbox environment
* Issues & Complexity Summary: Comprehensive test coverage for financial document data models
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: Medium
  - Dependencies: 4 New (CoreData, XCTest, Foundation, Testing framework)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
* Problem Estimate (Inherent Problem Difficulty %): 75%
* Initial Code Complexity Estimate %: 78%
* Justification for Estimates: Standard Core Data testing with financial domain complexity
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import XCTest
import CoreData
@testable import FinanceMate_Sandbox

class CoreDataModelsTests: XCTestCase {
    
    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create in-memory Core Data stack for testing
        persistentContainer = NSPersistentContainer(name: "FinanceMateDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        context = persistentContainer.viewContext
    }
    
    override func tearDownWithError() throws {
        context = nil
        persistentContainer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Document Model Tests
    
    func testDocumentCreation() throws {
        // Test: Create a Document entity with all required properties
        let document = Document(context: context)
        document.id = UUID()
        document.fileName = "test_invoice.pdf"
        document.filePath = "/path/to/test_invoice.pdf"
        document.fileSize = 1024
        document.mimeType = "application/pdf"
        document.dateCreated = Date()
        document.dateModified = Date()
        document.documentType = DocumentType.invoice.rawValue
        document.processingStatus = ProcessingStatus.pending.rawValue
        
        try context.save()
        
        XCTAssertNotNil(document.id)
        XCTAssertEqual(document.fileName, "test_invoice.pdf")
        XCTAssertEqual(document.documentType, DocumentType.invoice.rawValue)
        XCTAssertEqual(document.processingStatus, ProcessingStatus.pending.rawValue)
    }
    
    func testDocumentValidation() throws {
        // Test: Document validation rules
        let document = Document(context: context)
        
        // Test required fields validation
        XCTAssertThrowsError(try context.save()) {
            XCTAssertTrue($0 is NSError)
        }
        
        // Fill required fields
        document.id = UUID()
        document.fileName = "test.pdf"
        document.filePath = "/test.pdf"
        document.dateCreated = Date()
        document.documentType = DocumentType.receipt.rawValue
        document.processingStatus = ProcessingStatus.pending.rawValue
        
        XCTAssertNoThrow(try context.save())
    }
    
    // MARK: - FinancialData Model Tests
    
    func testFinancialDataCreation() throws {
        // Test: Create FinancialData with extracted information
        let financialData = FinancialData(context: context)
        financialData.id = UUID()
        financialData.vendorName = "Apple Inc."
        financialData.totalAmount = NSDecimalNumber(string: "1299.99")
        financialData.currency = "USD"
        financialData.invoiceNumber = "INV-2024-001"
        financialData.invoiceDate = Date()
        financialData.dueDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
        financialData.taxAmount = NSDecimalNumber(string: "120.00")
        financialData.taxRate = 0.092 // 9.2%
        financialData.dateExtracted = Date()
        financialData.extractionConfidence = 0.95
        
        try context.save()
        
        XCTAssertNotNil(financialData.id)
        XCTAssertEqual(financialData.vendorName, "Apple Inc.")
        XCTAssertEqual(financialData.totalAmount, NSDecimalNumber(string: "1299.99"))
        XCTAssertEqual(financialData.currency, "USD")
        XCTAssertEqual(financialData.extractionConfidence, 0.95, accuracy: 0.001)
    }
    
    func testFinancialDataValidation() throws {
        // Test: FinancialData business rule validation
        let financialData = FinancialData(context: context)
        financialData.id = UUID()
        financialData.totalAmount = NSDecimalNumber(string: "-100.00") // Invalid negative amount
        
        // Should validate that total amount is positive
        XCTAssertThrowsError(try context.save())
    }
    
    // MARK: - Client Model Tests
    
    func testClientCreation() throws {
        // Test: Create Client entity
        let client = Client(context: context)
        client.id = UUID()
        client.name = "Acme Corporation"
        client.email = "billing@acme.corp"
        client.phone = "+1-555-0123"
        client.address = "123 Business St, Suite 100"
        client.city = "San Francisco"
        client.state = "CA"
        client.zipCode = "94105"
        client.country = "USA"
        client.dateCreated = Date()
        client.isActive = true
        
        try context.save()
        
        XCTAssertNotNil(client.id)
        XCTAssertEqual(client.name, "Acme Corporation")
        XCTAssertEqual(client.email, "billing@acme.corp")
        XCTAssertTrue(client.isActive)
    }
    
    func testClientEmailValidation() throws {
        // Test: Client email format validation
        let client = Client(context: context)
        client.id = UUID()
        client.name = "Test Client"
        client.email = "invalid-email" // Invalid email format
        client.dateCreated = Date()
        
        // Should validate email format
        XCTAssertThrowsError(try context.save())
    }
    
    // MARK: - Category Model Tests
    
    func testCategoryCreation() throws {
        // Test: Create Category for expense classification
        let category = Category(context: context)
        category.id = UUID()
        category.name = "Office Supplies"
        category.colorHex = "#FF6B6B"
        category.iconName = "paperclip"
        category.isDefault = false
        category.dateCreated = Date()
        
        try context.save()
        
        XCTAssertNotNil(category.id)
        XCTAssertEqual(category.name, "Office Supplies")
        XCTAssertEqual(category.colorHex, "#FF6B6B")
        XCTAssertFalse(category.isDefault)
    }
    
    // MARK: - Project Model Tests
    
    func testProjectCreation() throws {
        // Test: Create Project for expense tracking
        let project = Project(context: context)
        project.id = UUID()
        project.name = "Q4 Marketing Campaign"
        project.projectDescription = "Holiday marketing campaign for Q4 2024"
        project.budget = NSDecimalNumber(string: "50000.00")
        project.startDate = Date()
        project.endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
        project.status = ProjectStatus.active.rawValue
        project.dateCreated = Date()
        
        try context.save()
        
        XCTAssertNotNil(project.id)
        XCTAssertEqual(project.name, "Q4 Marketing Campaign")
        XCTAssertEqual(project.budget, NSDecimalNumber(string: "50000.00"))
        XCTAssertEqual(project.status, ProjectStatus.active.rawValue)
    }
    
    // MARK: - Relationship Tests
    
    func testDocumentFinancialDataRelationship() throws {
        // Test: Document to FinancialData one-to-one relationship
        let document = Document(context: context)
        document.id = UUID()
        document.fileName = "invoice_001.pdf"
        document.filePath = "/invoices/invoice_001.pdf"
        document.dateCreated = Date()
        document.documentType = DocumentType.invoice.rawValue
        document.processingStatus = ProcessingStatus.completed.rawValue
        
        let financialData = FinancialData(context: context)
        financialData.id = UUID()
        financialData.vendorName = "Tech Supplies Inc."
        financialData.totalAmount = NSDecimalNumber(string: "549.99")
        financialData.currency = "USD"
        financialData.dateExtracted = Date()
        financialData.extractionConfidence = 0.89
        
        // Establish relationship
        document.financialData = financialData
        financialData.document = document
        
        try context.save()
        
        XCTAssertEqual(document.financialData, financialData)
        XCTAssertEqual(financialData.document, document)
    }
    
    func testClientDocumentsRelationship() throws {
        // Test: Client to Documents one-to-many relationship
        let client = Client(context: context)
        client.id = UUID()
        client.name = "Regular Customer LLC"
        client.email = "accounts@regularcustomer.com"
        client.dateCreated = Date()
        client.isActive = true
        
        let document1 = Document(context: context)
        document1.id = UUID()
        document1.fileName = "invoice_001.pdf"
        document1.filePath = "/path/invoice_001.pdf"
        document1.dateCreated = Date()
        document1.documentType = DocumentType.invoice.rawValue
        document1.processingStatus = ProcessingStatus.completed.rawValue
        
        let document2 = Document(context: context)
        document2.id = UUID()
        document2.fileName = "receipt_002.pdf"
        document2.filePath = "/path/receipt_002.pdf"
        document2.dateCreated = Date()
        document2.documentType = DocumentType.receipt.rawValue
        document2.processingStatus = ProcessingStatus.completed.rawValue
        
        // Establish relationships
        document1.client = client
        document2.client = client
        client.addToDocuments(document1)
        client.addToDocuments(document2)
        
        try context.save()
        
        XCTAssertEqual(client.documents?.count, 2)
        XCTAssertTrue(client.documents?.contains(document1) ?? false)
        XCTAssertTrue(client.documents?.contains(document2) ?? false)
        XCTAssertEqual(document1.client, client)
        XCTAssertEqual(document2.client, client)
    }
    
    // MARK: - Query Tests
    
    func testDocumentFetchRequest() throws {
        // Test: Fetch documents by type
        let document1 = Document(context: context)
        document1.id = UUID()
        document1.fileName = "invoice.pdf"
        document1.filePath = "/path/invoice.pdf"
        document1.dateCreated = Date()
        document1.documentType = DocumentType.invoice.rawValue
        document1.processingStatus = ProcessingStatus.completed.rawValue
        
        let document2 = Document(context: context)
        document2.id = UUID()
        document2.fileName = "receipt.pdf"
        document2.filePath = "/path/receipt.pdf"
        document2.dateCreated = Date()
        document2.documentType = DocumentType.receipt.rawValue
        document2.processingStatus = ProcessingStatus.completed.rawValue
        
        try context.save()
        
        // Fetch only invoices
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "documentType == %@", DocumentType.invoice.rawValue)
        
        let invoices = try context.fetch(fetchRequest)
        
        XCTAssertEqual(invoices.count, 1)
        XCTAssertEqual(invoices.first?.documentType, DocumentType.invoice.rawValue)
    }
    
    func testFinancialDataDateRangeQuery() throws {
        // Test: Query financial data by date range
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let endDate = Date()
        
        let financialData1 = FinancialData(context: context)
        financialData1.id = UUID()
        financialData1.totalAmount = NSDecimalNumber(string: "100.00")
        financialData1.currency = "USD"
        financialData1.invoiceDate = startDate
        financialData1.dateExtracted = Date()
        
        let financialData2 = FinancialData(context: context)
        financialData2.id = UUID()
        financialData2.totalAmount = NSDecimalNumber(string: "200.00")
        financialData2.currency = "USD"
        financialData2.invoiceDate = Calendar.current.date(byAdding: .month, value: -2, to: Date())! // Outside range
        financialData2.dateExtracted = Date()
        
        try context.save()
        
        let fetchRequest: NSFetchRequest<FinancialData> = FinancialData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "invoiceDate >= %@ AND invoiceDate <= %@", startDate as NSDate, endDate as NSDate)
        
        let results = try context.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.totalAmount, NSDecimalNumber(string: "100.00"))
    }
}