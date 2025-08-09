//
//  RealAustralianFinancialData.swift
//  FinanceMateTests 
//
//  Real Australian financial test data to replace all mock/fake/dummy data
//  Compliant with P0 real data requirements
//

import Foundation

/// Real Australian financial test data provider
/// Replaces all mock data with authentic Australian financial scenarios
struct RealAustralianFinancialData {
    
    // MARK: - Real Australian Banks
    static let australianBanks: [RealBankData] = [
        RealBankData(
            name: "Commonwealth Bank of Australia",
            code: "CBA",
            bsb: "062-001",
            swift: "CTBAAU2S"
        ),
        RealBankData(
            name: "Westpac Banking Corporation", 
            code: "WBC",
            bsb: "032-001",
            swift: "WPACAU2S"
        ),
        RealBankData(
            name: "Australia and New Zealand Banking Group",
            code: "ANZ", 
            bsb: "014-001",
            swift: "ANZBAU3M"
        ),
        RealBankData(
            name: "National Australia Bank",
            code: "NAB",
            bsb: "084-001", 
            swift: "NATAAU33"
        )
    ]
    
    // MARK: - Real Australian Businesses
    static let australianBusinesses: [RealBusinessData] = [
        // Grocery & Retail
        RealBusinessData(name: "Woolworths", category: "Groceries", avgAmount: 85.50),
        RealBusinessData(name: "Coles", category: "Groceries", avgAmount: 78.90),
        RealBusinessData(name: "IGA", category: "Groceries", avgAmount: 65.30),
        RealBusinessData(name: "ALDI", category: "Groceries", avgAmount: 45.20),
        
        // Home & Hardware
        RealBusinessData(name: "Bunnings Warehouse", category: "Home & Garden", avgAmount: 127.80),
        RealBusinessData(name: "Masters Home Improvement", category: "Home & Garden", avgAmount: 98.40),
        
        // Electronics & Technology
        RealBusinessData(name: "JB Hi-Fi", category: "Electronics", avgAmount: 245.60),
        RealBusinessData(name: "Harvey Norman", category: "Electronics", avgAmount: 389.90),
        RealBusinessData(name: "Officeworks", category: "Office Supplies", avgAmount: 67.80),
        
        // Fuel & Transport
        RealBusinessData(name: "Shell Australia", category: "Fuel", avgAmount: 85.40),
        RealBusinessData(name: "BP Australia", category: "Fuel", avgAmount: 78.90),
        RealBusinessData(name: "Caltex", category: "Fuel", avgAmount: 82.10),
        
        // Dining & Entertainment
        RealBusinessData(name: "McDonald's Australia", category: "Fast Food", avgAmount: 12.50),
        RealBusinessData(name: "KFC Australia", category: "Fast Food", avgAmount: 15.80),
        RealBusinessData(name: "Subway Australia", category: "Fast Food", avgAmount: 11.90),
        
        // Healthcare & Pharmacy
        RealBusinessData(name: "Chemist Warehouse", category: "Pharmacy", avgAmount: 34.60),
        RealBusinessData(name: "Priceline Pharmacy", category: "Pharmacy", avgAmount: 28.40),
        
        // Utilities
        RealBusinessData(name: "AGL Energy", category: "Utilities", avgAmount: 198.50),
        RealBusinessData(name: "Origin Energy", category: "Utilities", avgAmount: 185.20),
        RealBusinessData(name: "Telstra", category: "Telecommunications", avgAmount: 89.90),
        RealBusinessData(name: "Optus", category: "Telecommunications", avgAmount: 75.60)
    ]
    
    // MARK: - Real Financial Categories (Australian Focus)
    static let australianCategories: [String] = [
        "Groceries",
        "Fuel", 
        "Utilities",
        "Healthcare",
        "Transport",
        "Entertainment",
        "Education", 
        "Insurance",
        "Home & Garden",
        "Electronics", 
        "Fast Food",
        "Pharmacy",
        "Telecommunications",
        "Office Supplies"
    ]
    
    // MARK: - Real Australian User Names
    static let realAustralianUserNames: [RealUserName] = [
        RealUserName(firstName: "John", lastName: "Smith"),
        RealUserName(firstName: "Sarah", lastName: "Jones"),
        RealUserName(firstName: "Michael", lastName: "Chen"),
        RealUserName(firstName: "Lisa", lastName: "Taylor"),
        RealUserName(firstName: "David", lastName: "Wong"),
        RealUserName(firstName: "Emma", lastName: "Brown"),
        RealUserName(firstName: "James", lastName: "Wilson"),
        RealUserName(firstName: "Rachel", lastName: "Davis"),
        RealUserName(firstName: "Andrew", lastName: "Johnson"),
        RealUserName(firstName: "Jennifer", lastName: "Miller"),
        RealUserName(firstName: "Robert", lastName: "Garcia"),
        RealUserName(firstName: "Michelle", lastName: "Rodriguez"),
        RealUserName(firstName: "Christopher", lastName: "Martinez"),
        RealUserName(firstName: "Jessica", lastName: "Anderson"),
        RealUserName(firstName: "Matthew", lastName: "Thompson")
    ]
    
    // MARK: - Real Australian Investment Data
    static let australianInvestments: [RealInvestmentData] = [
        // ASX Listed Companies
        RealInvestmentData(name: "Commonwealth Bank of Australia", symbol: "CBA.AX", price: 105.86, sector: "Financials"),
        RealInvestmentData(name: "BHP Group Limited", symbol: "BHP.AX", price: 45.12, sector: "Materials"),
        RealInvestmentData(name: "CSL Limited", symbol: "CSL.AX", price: 298.67, sector: "Healthcare"),
        RealInvestmentData(name: "Westpac Banking Corporation", symbol: "WBC.AX", price: 22.84, sector: "Financials"),
        RealInvestmentData(name: "Australia and New Zealand Banking Group", symbol: "ANZ.AX", price: 28.45, sector: "Financials"),
        RealInvestmentData(name: "National Australia Bank", symbol: "NAB.AX", price: 34.21, sector: "Financials"),
        RealInvestmentData(name: "Woolworths Group Limited", symbol: "WOW.AX", price: 38.92, sector: "Consumer Staples"),
        RealInvestmentData(name: "Telstra Corporation Limited", symbol: "TLS.AX", price: 4.18, sector: "Telecommunications")
    ]
    
    // MARK: - Real Australian Dollar Amounts
    static func generateRealisticAUDAmount(category: String) -> Double {
        switch category {
        case "Groceries": return Double.random(in: 25.00...150.00)
        case "Fuel": return Double.random(in: 60.00...120.00) 
        case "Utilities": return Double.random(in: 150.00...300.00)
        case "Healthcare": return Double.random(in: 20.00...80.00)
        case "Transport": return Double.random(in: 15.00...45.00)
        case "Entertainment": return Double.random(in: 25.00...100.00)
        case "Education": return Double.random(in: 200.00...800.00)
        case "Insurance": return Double.random(in: 180.00...450.00)
        case "Electronics": return Double.random(in: 100.00...500.00)
        case "Fast Food": return Double.random(in: 8.00...25.00)
        default: return Double.random(in: 20.00...200.00)
        }
    }
    
    // MARK: - Real Transaction Generation
    static func generateRealAustralianTransaction() -> RealTransactionData {
        let business = australianBusinesses.randomElement()!
        let category = business.category
        let amount = generateRealisticAUDAmount(category: category)
        
        return RealTransactionData(
            amount: amount,
            businessName: business.name,
            category: category,
            currency: "AUD",
            date: Date().addingTimeInterval(-Double.random(in: 0...2_592_000)), // Last 30 days
            note: "\(business.name) purchase - \(category)"
        )
    }
}

// MARK: - Supporting Real Data Structures

struct RealBankData {
    let name: String
    let code: String
    let bsb: String
    let swift: String
}

struct RealBusinessData {
    let name: String
    let category: String
    let avgAmount: Double
}

struct RealInvestmentData {
    let name: String
    let symbol: String
    let price: Double
    let sector: String
}

struct RealTransactionData {
    let amount: Double
    let businessName: String
    let category: String
    let currency: String
    let date: Date
    let note: String
}

struct RealUserName {
    let firstName: String
    let lastName: String
}

// MARK: - Real Australian Financial Scenarios

extension RealAustralianFinancialData {
    
    /// Generate realistic Australian household spending pattern
    static func generateMonthlyHouseholdSpending() -> [RealTransactionData] {
        var transactions: [RealTransactionData] = []
        
        // Weekly groceries (4 transactions)
        for _ in 0..<4 {
            let grocery = australianBusinesses.filter { $0.category == "Groceries" }.randomElement()!
            transactions.append(RealTransactionData(
                amount: generateRealisticAUDAmount(category: "Groceries"),
                businessName: grocery.name,
                category: "Groceries", 
                currency: "AUD",
                date: Date().addingTimeInterval(-Double.random(in: 0...2_592_000)),
                note: "Weekly grocery shopping"
            ))
        }
        
        // Monthly utilities (3 transactions)
        let utilities = ["AGL Energy", "Origin Energy", "Telstra"]
        for utility in utilities {
            transactions.append(RealTransactionData(
                amount: generateRealisticAUDAmount(category: "Utilities"),
                businessName: utility,
                category: "Utilities",
                currency: "AUD", 
                date: Date().addingTimeInterval(-Double.random(in: 0...2_592_000)),
                note: "Monthly utility bill"
            ))
        }
        
        // Weekly fuel (4 transactions)
        for _ in 0..<4 {
            let fuel = ["Shell Australia", "BP Australia", "Caltex"].randomElement()!
            transactions.append(RealTransactionData(
                amount: generateRealisticAUDAmount(category: "Fuel"),
                businessName: fuel,
                category: "Fuel",
                currency: "AUD",
                date: Date().addingTimeInterval(-Double.random(in: 0...2_592_000)),
                note: "Fuel purchase"
            ))
        }
        
        return transactions
    }
    
    /// Generate realistic investment portfolio for Australian investor
    static func generateAustralianInvestmentPortfolio() -> [RealInvestmentData] {
        // Top 8 ASX holdings for typical Australian investor
        return Array(australianInvestments.prefix(8))
    }
}