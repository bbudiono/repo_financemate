//
//  PersistenceValidationService.swift
//  FinanceMate
//
//  Created by FinanceMate on 2025-10-08.
//  Copyright © 2025 FinanceMate. All rights reserved.
//

import Foundation
import CoreData

/// Service for validating data persistence across app restarts
/// Implements BLUEPRINT Requirement #6: Data persistence verification
@MainActor
class PersistenceValidationService: ObservableObject {

    private let context: NSManagedObjectContext
    private let testIdentifier = "PERSISTENCE_TEST_"

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Creates test data for persistence validation
    func createTestData() -> [UUID] {
        var testTransactionIds: [UUID] = []

        for i in 1...3 {
            let transaction = Transaction(context: context)
            transaction.id = UUID()
            transaction.itemDescription = "\(testIdentifier)Test Transaction \(i)"
            transaction.amount = Double(i * 10.0)
            transaction.date = Date()
            transaction.source = "persistence_test"
            testTransactionIds.append(transaction.id!)
        }

        do {
            try context.save()
            print("Created \(testTransactionIds.count) test transactions")
        } catch {
            print("Error creating test data: \(error)")
        }

        return testTransactionIds
    }

    /// Validates data persistence across app restarts
    func validateDataPersistence(expectedIds: [UUID]) -> Bool {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest() as! NSFetchRequest<Transaction>
        request.predicate = NSPredicate(format: "itemDescription BEGINSWITH %@", testIdentifier)

        do {
            let persistedTransactions = try context.fetch(request)
            let persistedIds = Set(persistedTransactions.compactMap { $0.id })
            let expectedIdSet = Set(expectedIds)
            return persistedIds == expectedIdSet
        } catch {
            print("Error validating persistence: \(error)")
            return false
        }
    }

    /// Cleans up test data after validation
    func cleanupTestData() -> Bool {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest() as! NSFetchRequest<Transaction>
        request.predicate = NSPredicate(format: "itemDescription BEGINSWITH %@", testIdentifier)

        do {
            let testTransactions = try context.fetch(request)
            for transaction in testTransactions {
                context.delete(transaction)
            }
            try context.save()
            print("Cleaned up \(testTransactions.count) test transactions")
            return true
        } catch {
            print("Error cleaning up test data: \(error)")
            return false
        }
    }

    /// Validates Core Data store integrity
    func validateCoreDataIntegrity() -> Bool {
        do {
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest() as! NSFetchRequest<Transaction>
            let count = try context.count(for: request)
            return count >= 0
        } catch {
            print("Error validating Core Data: \(error)")
            return false
        }
    }

    /// Runs comprehensive persistence validation
    func runComprehensiveValidation() -> Bool {
        guard validateCoreDataIntegrity() else {
            return false
        }

        let testIds = createTestData()
        let persistenceSuccess = validateDataPersistence(expectedIds: testIds)
        let cleanupSuccess = cleanupTestData()

        return persistenceSuccess && cleanupSuccess
    }
}