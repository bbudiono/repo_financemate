// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  FinancialDataClassificationServiceTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/6/25.
//

import XCTest
@testable import FinanceMate_Sandbox

class FinancialDataClassificationServiceTests: XCTestCase {
    
    var service: FinancialDataClassificationService!
    
    override func setUp() {
        super.setUp()
        service = FinancialDataClassificationService()
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Expense Category Classification Tests
    
    func testClassifyOfficeSupplies() {
        let text = "Purchase of office supplies including paper, pens, and stapler"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.office), "Should classify as office supplies")
    }
    
    func testClassifyTravelExpenses() {
        let text = "Flight booking and hotel reservation for business trip"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.travel), "Should classify as travel expense")
    }
    
    func testClassifyMealsAndEntertainment() {
        let text = "Restaurant dinner with client and coffee meeting"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.meals), "Should classify as meals and entertainment")
    }
    
    func testClassifyUtilities() {
        let text = "Monthly electric bill and internet service payment"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.utilities), "Should classify as utilities")
    }
    
    func testClassifySoftwareSubscription() {
        let text = "Monthly software subscription and cloud hosting license"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.software), "Should classify as software expense")
    }
    
    func testClassifyMarketingExpenses() {
        let text = "Advertising campaign and social media promotion costs"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.marketing), "Should classify as marketing expense")
    }
    
    func testClassifyProfessionalServices() {
        let text = "Legal consultation and accounting services"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.professional), "Should classify as professional services")
    }
    
    func testClassifyEquipment() {
        let text = "Computer purchase and printer equipment"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.equipment), "Should classify as equipment")
    }
    
    func testClassifyMaintenanceServices() {
        let text = "Office cleaning service and repair maintenance"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.maintenance), "Should classify as maintenance")
    }
    
    func testClassifyInsurance() {
        let text = "Insurance premium payment and coverage policy"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.insurance), "Should classify as insurance")
    }
    
    func testClassifyMultipleCategories() {
        let text = "Business trip including flight, hotel, and restaurant meals with client"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertTrue(categories.contains(.travel), "Should classify as travel")
        XCTAssertTrue(categories.contains(.meals), "Should classify as meals")
        XCTAssertGreaterThan(categories.count, 1, "Should identify multiple categories")
    }
    
    func testClassifyUnknownCategory() {
        let text = "Miscellaneous expense with no specific category keywords"
        let categories = service.classifyExpenseCategories(from: text)
        
        XCTAssertEqual(categories, [.other], "Should default to 'other' category")
    }
    
    // MARK: - Individual Item Classification Tests
    
    func testClassifyItemCategories() {
        let testCases = [
            ("Microsoft Office license", ExtractedExpenseCategory.software),
            ("Airplane ticket to New York", ExtractedExpenseCategory.travel),
            ("Lunch with business partner", ExtractedExpenseCategory.meals),
            ("Office paper and pens", ExtractedExpenseCategory.office),
            ("Legal consultation fees", ExtractedExpenseCategory.professional),
            ("Computer equipment", ExtractedExpenseCategory.equipment),
            ("Random unrelated item", ExtractedExpenseCategory.other)
        ]
        
        for (description, expectedCategory) in testCases {
            let category = service.classifyItemCategory(description: description)
            XCTAssertEqual(category, expectedCategory, "Should classify '\(description)' as \(expectedCategory.rawValue)")
        }
    }
    
    // MARK: - Line Item Extraction Tests
    
    func testExtractDetailedLineItems() {
        let text = """
        Consulting Services    10.0    $150.00    $1,500.00
        Travel Expenses        1.0     $500.00    $500.00
        Office Supplies        5.0     $25.00     $125.00
        """
        
        let lineItems = service.extractLineItems(from: text)
        
        XCTAssertEqual(lineItems.count, 3, "Should extract 3 line items")
        
        let consultingItem = lineItems.first { $0.description.contains("Consulting") }
        XCTAssertNotNil(consultingItem, "Should extract consulting line item")
        XCTAssertEqual(consultingItem!.quantity, 10.0, accuracy: 0.01, "Should extract correct quantity")
        XCTAssertEqual(consultingItem!.unitPrice, 150.00, accuracy: 0.01, "Should extract correct unit price")
        XCTAssertEqual(consultingItem!.totalAmount.value, 1500.00, accuracy: 0.01, "Should extract correct total")
        XCTAssertEqual(consultingItem!.category, .professional, "Should classify as professional services")
    }
    
    func testExtractSimpleLineItems() {
        let text = """
        Software License    $299.99
        Office Rent         $2,500.00
        Internet Service    $89.95
        """
        
        let lineItems = service.extractLineItems(from: text)
        
        XCTAssertEqual(lineItems.count, 3, "Should extract 3 simple line items")
        
        let softwareItem = lineItems.first { $0.description.contains("Software") }
        XCTAssertNotNil(softwareItem, "Should extract software line item")
        XCTAssertEqual(softwareItem!.quantity, 1.0, accuracy: 0.01, "Should default quantity to 1.0")
        XCTAssertEqual(softwareItem!.totalAmount.value, 299.99, accuracy: 0.01, "Should extract correct amount")
        XCTAssertEqual(softwareItem!.category, .software, "Should classify as software")
    }
    
    func testIgnoreInvalidLineItems() {
        let text = """
        DESCRIPTION    QTY    PRICE    AMOUNT
        ================================
        Valid Item     1.0    $100.00  $100.00
        Total:                          $100.00
        Tax:                            $8.00
        Subtotal                        $92.00
        """
        
        let lineItems = service.extractLineItems(from: text)
        
        XCTAssertEqual(lineItems.count, 1, "Should extract only valid line items")
        XCTAssertEqual(lineItems[0].description, "Valid Item", "Should extract the valid item")
    }
    
    // MARK: - Line Item Validation Tests
    
    func testValidLineItemValidation() {
        let validLines = [
            "Consulting Services    10.0    $150.00    $1,500.00",
            "Office Supplies    $125.00",
            "Travel Expense        1        $500.00    $500.00"
        ]
        
        for line in validLines {
            XCTAssertTrue(service.isValidLineItem(line), "Should validate as valid line item: \(line)")
        }
    }
    
    func testInvalidLineItemValidation() {
        let invalidLines = [
            "TOTAL: $1,500.00",
            "Tax: $120.00",
            "Description",
            "",
            "QTY",
            "AMOUNT",
            "Subtotal calculation"
        ]
        
        for line in invalidLines {
            XCTAssertFalse(service.isValidLineItem(line), "Should validate as invalid line item: \(line)")
        }
    }
    
    // MARK: - Vendor Category Suggestions Tests
    
    func testVendorCategorySuggestions() {
        let vendorTests = [
            ("Delta Airlines", [ExtractedExpenseCategory.travel]),
            ("Marriott Hotel", [ExtractedExpenseCategory.travel]),
            ("Microsoft Corporation", [ExtractedExpenseCategory.software]),
            ("Starbucks Coffee", [ExtractedExpenseCategory.meals]),
            ("Electric Company", [ExtractedExpenseCategory.utilities]),
            ("Law Firm LLP", [ExtractedExpenseCategory.professional]),
            ("Best Buy Electronics", [ExtractedExpenseCategory.equipment]),
            ("State Farm Insurance", [ExtractedExpenseCategory.insurance])
        ]
        
        for (vendorName, expectedCategories) in vendorTests {
            let suggestions = service.suggestCategoriesForVendor(vendorName)
            for expectedCategory in expectedCategories {
                XCTAssertTrue(suggestions.contains(expectedCategory), 
                             "Should suggest \(expectedCategory.rawValue) for vendor: \(vendorName)")
            }
        }
    }
    
    func testUnknownVendorSuggestion() {
        let unknownVendor = "Random Unknown Business"
        let suggestions = service.suggestCategoriesForVendor(unknownVendor)
        
        XCTAssertEqual(suggestions, [.other], "Should suggest 'other' category for unknown vendor")
    }
    
    // MARK: - Confidence Level Tests
    
    func testHighConfidenceCategorizationText() {
        let richText = """
        Business travel expenses including:
        - Flight tickets for conference
        - Hotel accommodation 
        - Restaurant meals with clients
        - Taxi rides and transportation
        - Conference registration fee
        - Office supplies purchased during trip
        """
        
        let confidence = service.getCategorizationConfidence(for: richText)
        XCTAssertGreaterThan(confidence, 0.7, "Should have high confidence for rich categorization text")
    }
    
    func testMediumConfidenceCategorizationText() {
        let mediumText = "Travel expenses for business trip including flight and hotel"
        
        let confidence = service.getCategorizationConfidence(for: mediumText)
        XCTAssertGreaterThan(confidence, 0.4, "Should have medium confidence")
        XCTAssertLessThan(confidence, 0.8, "Should not have very high confidence")
    }
    
    func testLowConfidenceCategorizationText() {
        let poorText = "Expense"
        
        let confidence = service.getCategorizationConfidence(for: poorText)
        XCTAssertLessThan(confidence, 0.5, "Should have low confidence for minimal text")
    }
    
    // MARK: - Keyword Detection Tests
    
    func testFoundKeywordsDetection() {
        let text = "Office supplies including paper, pens, and desk accessories"
        let foundKeywords = service.getFoundKeywords(in: text, for: .office)
        
        XCTAssertTrue(foundKeywords.contains("office"), "Should find 'office' keyword")
        XCTAssertTrue(foundKeywords.contains("supplies"), "Should find 'supplies' keyword")
        XCTAssertTrue(foundKeywords.contains("paper"), "Should find 'paper' keyword")
        XCTAssertTrue(foundKeywords.contains("pen"), "Should find 'pen' keyword")
        XCTAssertTrue(foundKeywords.contains("desk"), "Should find 'desk' keyword")
    }
    
    func testNoKeywordsFound() {
        let text = "Random text with no relevant keywords"
        let foundKeywords = service.getFoundKeywords(in: text, for: .software)
        
        XCTAssertTrue(foundKeywords.isEmpty, "Should find no keywords for unrelated text")
    }
    
    // MARK: - Edge Cases and Error Handling Tests
    
    func testEmptyTextClassification() {
        let categories = service.classifyExpenseCategories(from: "")
        let lineItems = service.extractLineItems(from: "")
        let confidence = service.getCategorizationConfidence(for: "")
        
        XCTAssertEqual(categories, [.other], "Should default to 'other' for empty text")
        XCTAssertTrue(lineItems.isEmpty, "Should return empty array for empty text")
        XCTAssertEqual(confidence, 0.0, accuracy: 0.01, "Should have zero confidence for empty text")
    }
    
    func testCaseInsensitiveClassification() {
        let upperCaseText = "OFFICE SUPPLIES AND SOFTWARE LICENSE"
        let lowerCaseText = "office supplies and software license"
        let mixedCaseText = "Office Supplies and Software License"
        
        let upperCategories = service.classifyExpenseCategories(from: upperCaseText)
        let lowerCategories = service.classifyExpenseCategories(from: lowerCaseText)
        let mixedCategories = service.classifyExpenseCategories(from: mixedCaseText)
        
        XCTAssertEqual(Set(upperCategories), Set(lowerCategories), "Should be case insensitive")
        XCTAssertEqual(Set(lowerCategories), Set(mixedCategories), "Should be case insensitive")
    }
    
    func testComplexFinancialDocument() {
        let complexText = """
        EXPENSE REPORT - BUSINESS TRIP
        
        Flight to Conference    1    $450.00    $450.00
        Hotel Accommodation     3    $150.00    $450.00
        Restaurant Meals        4    $75.00     $300.00
        Taxi Transportation     6    $25.00     $150.00
        Office Supplies         1    $50.00     $50.00
        Software License        1    $99.00     $99.00
        Conference Registration 1    $200.00    $200.00
        
        Total Business Expenses: $1,699.00
        """
        
        let categories = service.classifyExpenseCategories(from: complexText)
        let lineItems = service.extractLineItems(from: complexText)
        let confidence = service.getCategorizationConfidence(for: complexText)
        
        // Should identify multiple categories
        XCTAssertTrue(categories.contains(.travel), "Should identify travel expenses")
        XCTAssertTrue(categories.contains(.meals), "Should identify meal expenses")
        XCTAssertTrue(categories.contains(.office), "Should identify office supplies")
        XCTAssertTrue(categories.contains(.software), "Should identify software expenses")
        
        // Should extract line items
        XCTAssertGreaterThan(lineItems.count, 5, "Should extract multiple line items")
        
        // Should have high confidence
        XCTAssertGreaterThan(confidence, 0.8, "Should have high confidence for complex document")
        
        // Verify specific line item details
        let flightItem = lineItems.first { $0.description.contains("Flight") }
        XCTAssertNotNil(flightItem, "Should extract flight line item")
        XCTAssertEqual(flightItem!.category, .travel, "Should classify flight as travel")
        
        let mealItem = lineItems.first { $0.description.contains("Restaurant") }
        XCTAssertNotNil(mealItem, "Should extract restaurant line item")
        XCTAssertEqual(mealItem!.category, .meals, "Should classify restaurant as meals")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceCategoryClassification() {
        let text = "Business travel expenses including flight, hotel, and restaurant meals"
        
        measure {
            for _ in 0..<1000 {
                _ = service.classifyExpenseCategories(from: text)
            }
        }
    }
    
    func testPerformanceLineItemExtraction() {
        let text = """
        Consulting Services    10.0    $150.00    $1,500.00
        Travel Expenses        1.0     $500.00    $500.00
        Office Supplies        5.0     $25.00     $125.00
        """
        
        measure {
            for _ in 0..<1000 {
                _ = service.extractLineItems(from: text)
            }
        }
    }
    
    func testPerformanceVendorSuggestions() {
        let vendorName = "Microsoft Corporation"
        
        measure {
            for _ in 0..<1000 {
                _ = service.suggestCategoriesForVendor(vendorName)
            }
        }
    }
}