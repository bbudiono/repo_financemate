// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  FinancialGoal+CoreDataClass.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: FinancialGoal Core Data model for user financial goals and progress tracking
* Real Functionality: Enables TestFlight users to set and track financial goals
*/

import Foundation
import CoreData

@objc(FinancialGoal)
public class FinancialGoal: NSManagedObject {
    
    // MARK: - Convenience Initializer
    
    convenience init(context: NSManagedObjectContext, name: String, targetAmount: NSDecimalNumber, targetDate: Date) {
        self.init(context: context)
        
        self.id = UUID()
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = NSDecimalNumber.zero
        self.targetDate = targetDate
        self.createdDate = Date()
        self.isActive = true
    }
    
    // MARK: - Computed Properties
    
    public var progressPercentage: Double {
        guard let target = targetAmount?.doubleValue,
              let current = currentAmount?.doubleValue,
              target > 0 else { return 0 }
        
        return min(100, max(0, (current / target) * 100))
    }
    
    public var remainingAmount: NSDecimalNumber {
        guard let target = targetAmount,
              let current = currentAmount else { return NSDecimalNumber.zero }
        
        let remaining = target.subtracting(current)
        return remaining.compare(NSDecimalNumber.zero) == .orderedAscending ? NSDecimalNumber.zero : remaining
    }
    
    public var daysRemaining: Int? {
        guard let targetDate = targetDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day
    }
    
    public var isCompleted: Bool {
        return progressPercentage >= 100
    }
    
    public var isOverdue: Bool {
        guard let targetDate = targetDate else { return false }
        return Date() > targetDate && !isCompleted
    }
    
    // MARK: - Methods
    
    public func updateProgress(newAmount: NSDecimalNumber) {
        currentAmount = newAmount
        lastUpdated = Date()
    }
    
    public func addProgress(amount: NSDecimalNumber) {
        let current = currentAmount ?? NSDecimalNumber.zero
        currentAmount = current.adding(amount)
        lastUpdated = Date()
    }
}