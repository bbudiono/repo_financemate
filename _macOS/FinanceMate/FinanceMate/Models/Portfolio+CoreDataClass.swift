//
// Portfolio+CoreDataClass.swift
// FinanceMate
//
// Created: 2025-07-31
// Temporary mock implementation for WealthDashboard dependency
//

import Foundation
import CoreData

@objc(Portfolio)
public class Portfolio: NSManagedObject {
    
    // MARK: - Mock Properties
    @objc dynamic var id: UUID?
    @objc dynamic var name: String?
    @objc dynamic var totalValue: Double = 0.0
    @objc dynamic var riskProfile: String?
    @objc dynamic var lastUpdated: Date?
    
    // MARK: - Mock Methods
    static func create(in context: NSManagedObjectContext, name: String, totalValue: Double = 0.0) -> Portfolio {
        let portfolio = Portfolio(context: context)
        portfolio.id = UUID()
        portfolio.name = name
        portfolio.totalValue = totalValue
        portfolio.riskProfile = "Moderate"
        portfolio.lastUpdated = Date()
        return portfolio
    }
}