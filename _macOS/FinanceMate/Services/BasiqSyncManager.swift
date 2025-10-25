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

        for basiqTx in transactions {
            // DUPLICATE DETECTION: Check if Basiq transaction already imported
            if await transactionExists(basiqTransactionId: basiqTx.id, in: context) {
                continue  // Skip duplicates
            }

            // MAP Basiq → Transaction
            await context.perform {
                let transaction = Transaction(context: context)
                transaction.id = UUID()
                transaction.amount = Double(basiqTx.amount) ?? 0.0
                transaction.itemDescription = basiqTx.description
                transaction.date = self.parseDate(basiqTx.postDate) ?? Date()
                transaction.category = self.inferCategory(from: basiqTx)
                transaction.source = "bank:\(connection.institution.shortName)"
                transaction.externalTransactionId = basiqTx.id
                transaction.transactionType = basiqTx.direction == "debit" ? "expense" : "income"
                transaction.importedDate = Date()

                // Store merchant info in note if available
                if let merchant = basiqTx.enrich?.merchant?.businessName {
                    transaction.note = "Merchant: \(merchant)"
                }

                do {
                    try context.save()
                } catch {
                    self.logger.error("Failed to save transaction: \(error.localizedDescription)")
                }
            }
        }

        logger.debug("Transaction processing completed")
    }

    private func transactionExists(basiqTransactionId: String, in context: NSManagedObjectContext) async -> Bool {
        await context.perform {
            let request = NSFetchRequest<Transaction>(entityName: "Transaction")
            request.predicate = NSPredicate(format: "externalTransactionId == %@", basiqTransactionId)
            return (try? context.count(for: request)) ?? 0 > 0
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

    private func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}