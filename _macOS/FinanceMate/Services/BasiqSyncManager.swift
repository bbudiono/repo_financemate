import Foundation
import Combine
import CoreData
import os.log

/// Basiq sync manager for background synchronization and Core Data integration
@MainActor
class BasiqSyncManager: ObservableObject {

    // MARK: - Properties

    @Published var syncStatus: BasiqConnectionStatus = .disconnected
    @Published var lastSyncDate: Date?
    @Published var errorMessage: String?

    private let logger = Logger(subsystem: "FinanceMate", category: "BasiqSyncManager")
    private let apiClient: BasiqAPIClient
    private let authManager: BasiqAuthManager

    // MARK: - Initialization

    init(apiClient: BasiqAPIClient, authManager: BasiqAuthManager) {
        self.apiClient = apiClient
        self.authManager = authManager
        logger.info("BasiqSyncManager initialized")
    }

    // MARK: - Public Interface

    /// Perform background synchronization of all connections
    func performBackgroundSync() async {
        logger.info("Starting background sync")

        guard authManager.isTokenValid() else {
            logger.info("Not authenticated, skipping background sync")
            return
        }

        await MainActor.run {
            syncStatus = .syncing
            errorMessage = nil
        }

        do {
            let connections = try await apiClient.fetchConnections()

            for connection in connections {
                logger.info("Syncing transactions for \(connection.institution.name)")
                let transactions = try await apiClient.fetchTransactions(for: connection.id)
                await processTransactions(transactions, for: connection)
            }

            await MainActor.run {
                syncStatus = .connected
                lastSyncDate = Date()
            }

            logger.info("Background sync completed successfully")
        } catch {
            await MainActor.run {
                errorMessage = "Background sync failed: \(error.localizedDescription)"
                syncStatus = .error(error.localizedDescription)
            }
            logger.error("Background sync failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Publishers

    var syncStatusPublisher: Published<BasiqConnectionStatus>.Publisher { $syncStatus }

    // MARK: - Private Methods

    private func processTransactions(_ transactions: [BasiqTransaction], for connection: BasiqConnection) async {
        logger.info("Processing \(transactions.count) transactions for \(connection.institution.name)")

        let context = PersistenceController.shared.container.viewContext

        // PERFORMANCE OPTIMIZATION: Batch fetch existing external IDs once (not in loop)
        let existingIds = await fetchExistingExternalIds(in: context)
        logger.debug("Found \(existingIds.count) existing external transaction IDs")

        // Filter out duplicates in-memory (O(n) instead of O(n²))
        let newTransactions = transactions.filter { !existingIds.contains($0.id) }
        logger.info("New transactions to import: \(newTransactions.count) of \(transactions.count)")

        if newTransactions.isEmpty {
            logger.info("No new transactions to import (all duplicates)")
            return
        }

        // MAP all transactions BEFORE saving (batch operation)
        await context.perform {
            for basiqTx in newTransactions {
                let transaction = Transaction(context: context)
                transaction.id = UUID()
                transaction.amount = Double(basiqTx.amount) ?? 0.0
                transaction.itemDescription = basiqTx.description
                transaction.date = self.parseDate(basiqTx.postDate) ?? Date()
                transaction.category = self.inferCategory(from: basiqTx)
                transaction.source = "bank:\(connection.institution.shortName)"
                transaction.externalTransactionId = basiqTx.id  // For duplicate detection
                transaction.transactionType = basiqTx.direction == "debit" ? "expense" : "income"
                transaction.importedDate = Date()

                // Store merchant info in note if available
                if let merchant = basiqTx.enrich?.merchant?.businessName {
                    transaction.note = "Merchant: \(merchant)"
                }
            }

            // BATCH SAVE: Single save after all mapping (performance + atomicity)
            do {
                try context.save()
                self.logger.info("Successfully saved \(newTransactions.count) bank transactions")
            } catch {
                context.rollback()  // ATOMIC: Rollback ALL on error
                self.logger.error("Failed to save transactions (rolled back): \(error.localizedDescription)")
            }
        }

        logger.debug("Transaction processing completed")
    }

    /// Batch fetch all existing external transaction IDs (O(1) database query)
    private func fetchExistingExternalIds(in context: NSManagedObjectContext) async -> Set<String> {
        await context.perform {
            let request = NSFetchRequest<Transaction>(entityName: "Transaction")
            request.predicate = NSPredicate(format: "externalTransactionId != nil")
            request.propertiesToFetch = ["externalTransactionId"]
            request.returnsObjectsAsFaults = false

            guard let results = try? context.fetch(request) else {
                return Set()
            }

            return Set(results.compactMap { $0.externalTransactionId })
        }
    }

    private func inferCategory(from basiqTx: BasiqTransaction) -> String {
        // Use Basiq enrichment data for categorization
        if let anzsic = basiqTx.enrich?.category?.anzsic {
            if let division = anzsic.division {
                return division
            }
        }

        // Fallback categorization
        return basiqTx.direction == "debit" ? "Expense" : "Income"
    }

    /// Robust date parsing with multiple format support
    private func parseDate(_ dateString: String) -> Date? {
        // Try ISO8601 first (Basiq standard: "2024-01-15T10:30:00Z")
        let iso8601 = ISO8601DateFormatter()
        if let date = iso8601.date(from: dateString) {
            return date
        }

        // Try short date format ("2024-01-15")
        let shortFormatter = DateFormatter()
        shortFormatter.dateFormat = "yyyy-MM-dd"
        if let date = shortFormatter.date(from: dateString) {
            return date
        }

        // Try timestamp format
        if let timestamp = Double(dateString) {
            return Date(timeIntervalSince1970: timestamp)
        }

        logger.warning("Unknown date format from Basiq: \(dateString)")
        return nil  // Let caller handle with ?? Date() fallback
    }
}