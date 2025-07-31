//
// Holding+CoreDataClass.swift
// FinanceMate
//
// Created: 2025-07-31
// Temporary mock implementation for PortfolioManager dependency
//

import Foundation
import CoreData

@objc(Holding)
public class Holding: NSManagedObject {
    
    // MARK: - Mock Properties
    @objc dynamic var id: UUID?
    @objc dynamic var symbol: String?
    @objc dynamic var name: String?
    @objc dynamic var quantity: Double = 0.0
    @objc dynamic var purchasePrice: Double = 0.0
    @objc dynamic var currentPrice: Double = 0.0
    @objc dynamic var assetType: String?
    
    // MARK: - Mock Methods
    static func create(in context: NSManagedObjectContext, symbol: String, name: String, quantity: Double, purchasePrice: Double) -> Holding {
        let holding = Holding(context: context)
        holding.id = UUID()
        holding.symbol = symbol
        holding.name = name
        holding.quantity = quantity
        holding.purchasePrice = purchasePrice
        holding.currentPrice = purchasePrice
        holding.assetType = "Stock"
        return holding
    }
}