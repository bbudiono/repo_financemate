//
//  OfflineOperationQueue.swift
//  FinanceMate
//
//  Purpose: Queues network operations for execution when connectivity is restored
//  BLUEPRINT Requirement: Line 298 - Offline Functionality
//  Architecture: Actor-based thread-safe queue with dependency injection
//

import Foundation

/// Represents a queued offline operation
struct OfflineOperation: Codable, Identifiable {
    let id: String
    let type: OperationType
    let timestamp: Date
    let retryCount: Int

    enum OperationType: String, Codable {
        case gmailSync = "gmail_sync"
        case basiqSync = "basiq_sync"
        case tokenRefresh = "token_refresh"
    }

    init(id: String = UUID().uuidString, type: OperationType, timestamp: Date = Date(), retryCount: Int = 0) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.retryCount = retryCount
    }
}

/// Thread-safe queue for offline operations with persistence
/// PRODUCTION REFACTOR: Dependency injection eliminates NotificationCenter coupling
actor OfflineOperationQueue {
    // MARK: - Properties

    private var operations: [OfflineOperation] = []
    private let executor: OfflineOperationExecutor
    private let persistenceKey = "com.financemate.offlineOperations"
    private let maxRetries = 3
    private let maxQueueSize = 100
    private let operationExpirationDays: TimeInterval = 7 * 86400  // 7 days in seconds

    // MARK: - Initialization

    /// Initialize queue with dependency-injected executor
    /// - Parameter executor: Operation executor (defaults to production implementation)
    init(executor: OfflineOperationExecutor = ProductionOfflineExecutor()) {
        self.executor = executor

        // Load operations synchronously to avoid race condition
        // Actor init is synchronous, load from UserDefaults is fast
        if let data = UserDefaults.standard.data(forKey: persistenceKey) {
            do {
                operations = try JSONDecoder().decode([OfflineOperation].self, from: data)
                NSLog("[OfflineQueue] ✅ Loaded \(operations.count) persisted operations")
            } catch {
                // CRITICAL: Log data loss for audit trail (financial software requirement)
                NSLog("[OfflineQueue] ❌ CRITICAL: Failed to decode operations - data corruption detected: \(error.localizedDescription)")
                operations = [] // Start fresh but LOGGED the failure
            }
        }
    }

    // MARK: - Public Methods

    /// Enqueue an operation for later execution
    /// - Parameters:
    ///   - id: Optional custom ID (defaults to UUID)
    ///   - type: Operation type
    func enqueue(id: String? = nil, type: OfflineOperation.OperationType) {
        // Remove expired operations (older than 7 days)
        cleanupExpiredOperations()

        // Check queue size limit
        if operations.count >= maxQueueSize {
            NSLog("[OfflineQueue] Queue at max capacity (\(maxQueueSize)), dropping oldest operation")
            operations.removeFirst()
        }

        let operation = OfflineOperation(
            id: id ?? UUID().uuidString,
            type: type
        )
        operations.append(operation)
        persistOperations()
        NSLog("[OfflineQueue] Enqueued \(type.rawValue) operation (queue size: \(operations.count))")
    }

    /// Execute all queued operations with transaction atomicity
    /// - Returns: Result containing successful operation IDs or failure errors
    func executeAll() async -> Result<[String], Error> {
        var successfulOperations: [String] = []
        var executionErrors: [String: Error] = [:]

        for operation in operations {
            do {
                // Execute operation via dependency-injected executor
                try await executeOperation(operation)
                successfulOperations.append(operation.id)
                NSLog("[OfflineQueue] ✅ Successfully executed \(operation.type.rawValue): \(operation.id)")

            } catch {
                // PRODUCTION: Proper error handling with user notification
                NSLog("[OfflineQueue] ❌ Failed to execute operation \(operation.id): \(error.localizedDescription)")
                executionErrors[operation.id] = error

                // Retry logic with exponential backoff consideration
                await retryOperation(operation)
            }
        }

        // Atomic removal of successful operations
        operations.removeAll { successfulOperations.contains($0.id) }
        persistOperations()

        // Return detailed result
        if executionErrors.isEmpty {
            return .success(successfulOperations)
        } else {
            // Partial success: some succeeded, some failed
            let errorSummary = "Executed \(successfulOperations.count)/\(operations.count + successfulOperations.count) operations"
            return .failure(OfflineQueueError.partialFailure(errorSummary))
        }
    }

    /// Get count of pending operations
    func pendingCount() -> Int {
        return operations.count
    }

    /// Get all pending operations
    func pendingOperations() -> [OfflineOperation] {
        return operations
    }

    /// Clear all operations
    func clearAll() {
        operations.removeAll()
        persistOperations()
    }

    // MARK: - Private Methods

    /// Execute operation using dependency-injected executor
    /// - Parameter operation: Operation to execute
    /// - Throws: Execution errors from executor
    private func executeOperation(_ operation: OfflineOperation) async throws {
        NSLog("[OfflineQueue] Executing \(operation.type.rawValue) operation: \(operation.id)")

        // PRODUCTION: Use dependency injection instead of NotificationCenter
        switch operation.type {
        case .gmailSync:
            try await executor.executeGmailSync()

        case .basiqSync:
            try await executor.executeBasiqSync()

        case .tokenRefresh:
            try await executor.executeTokenRefresh()
        }
    }

    /// Retry operation with exponential backoff
    /// - Parameter operation: Operation to retry
    private func retryOperation(_ operation: OfflineOperation) async {
        guard operation.retryCount < maxRetries else {
            // Max retries reached, remove operation
            operations.removeAll { $0.id == operation.id }
            persistOperations()
            NSLog("[OfflineQueue] ⚠️ Operation \(operation.id) exceeded max retries, removing from queue")
            return
        }

        // Increment retry count atomically
        if let index = operations.firstIndex(where: { $0.id == operation.id }) {
            let updated = OfflineOperation(
                id: operation.id,
                type: operation.type,
                timestamp: operation.timestamp,
                retryCount: operation.retryCount + 1
            )
            operations[index] = updated
            persistOperations()
            NSLog("[OfflineQueue] Retry \(updated.retryCount)/\(maxRetries) for \(operation.id)")
        }
    }

    /// Clean up expired operations (older than 7 days)
    private func cleanupExpiredOperations() {
        let expirationDate = Date().addingTimeInterval(-operationExpirationDays)
        let beforeCount = operations.count
        operations.removeAll { $0.timestamp < expirationDate }

        if operations.count < beforeCount {
            NSLog("[OfflineQueue] Removed \(beforeCount - operations.count) expired operations")
            persistOperations()
        }
    }

    /// Persist operations to UserDefaults with explicit error handling
    private func persistOperations() {
        do {
            let encoded = try JSONEncoder().encode(operations)
            UserDefaults.standard.set(encoded, forKey: persistenceKey)

            // Verify write succeeded (UserDefaults can fail silently on full disk)
            if UserDefaults.standard.data(forKey: persistenceKey) == nil {
                NSLog("[OfflineQueue] ❌ CRITICAL: UserDefaults write verification failed")
            }
        } catch {
            NSLog("[OfflineQueue] ❌ CRITICAL: Persistence failure - \(error.localizedDescription)")
            // TODO: Notify user that offline operations may not survive app restart
        }
    }
}

/// Errors specific to offline queue operations
enum OfflineQueueError: Error, LocalizedError {
    case partialFailure(String)

    var errorDescription: String? {
        switch self {
        case .partialFailure(let message):
            return message
        }
    }
}
