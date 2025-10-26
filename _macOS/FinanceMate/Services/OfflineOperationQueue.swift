//
//  OfflineOperationQueue.swift
//  FinanceMate
//
//  Purpose: Queues network operations for execution when connectivity is restored
//  BLUEPRINT Requirement: Line 298 - Offline Functionality
//  Architecture: Actor-based thread-safe operation queue with persistence
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
actor OfflineOperationQueue {
    // MARK: - Properties

    private var operations: [OfflineOperation] = []
    private let persistenceKey = "com.financemate.offlineOperations"
    private let maxRetries = 3

    // MARK: - Initialization

    init() {
        // Load operations synchronously to avoid race condition
        // Actor init is synchronous, load from UserDefaults is fast
        if let data = UserDefaults.standard.data(forKey: persistenceKey),
           let decoded = try? JSONDecoder().decode([OfflineOperation].self, from: data) {
            operations = decoded
            NSLog("[OfflineQueue] Loaded \(decoded.count) persisted operations")
        }
    }

    // MARK: - Public Methods

    /// Enqueue an operation for later execution
    /// - Parameters:
    ///   - id: Optional custom ID (defaults to UUID)
    ///   - type: Operation type
    // Maximum queue size to prevent unbounded growth
    private let maxQueueSize = 100
    private let operationExpirationDays: TimeInterval = 7 * 86400  // 7 days in seconds

    func enqueue(id: String? = nil, type: OfflineOperation.OperationType) {
        // Remove expired operations (older than 7 days)
        let expirationDate = Date().addingTimeInterval(-operationExpirationDays)
        let beforeCount = operations.count
        operations.removeAll { $0.timestamp < expirationDate }
        if operations.count < beforeCount {
            NSLog("[OfflineQueue] Removed \(beforeCount - operations.count) expired operations")
        }

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

    /// Execute all queued operations
    /// - Returns: Array of operation IDs that succeeded
    func executeAll() async -> [String] {
        var successfulOperations: [String] = []

        for operation in operations {
            do {
                let success = try await executeOperation(operation)
                if success {
                    successfulOperations.append(operation.id)
                } else {
                    // Increment retry count
                    await retryOperation(operation)
                }
            } catch {
                // PROPER ERROR HANDLING: Log and notify user
                NSLog("❌ [OfflineQueue] Failed to execute operation \(operation.id): \(error.localizedDescription)")

                // Notify UI of failure
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OfflineOperationFailed"),
                        object: nil,
                        userInfo: ["error": error.localizedDescription, "operationType": operation.type.rawValue]
                    )
                }

                await retryOperation(operation)
            }
        }

        // Remove successful operations
        operations.removeAll { successfulOperations.contains($0.id) }
        persistOperations()

        return successfulOperations
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

    /// Execute actual operation using NotificationCenter pattern (decoupled from services)
    /// - Parameter operation: Operation to execute
    /// - Returns: True if notification posted successfully (actual execution happens in listeners)
    private func executeOperation(_ operation: OfflineOperation) async throws -> Bool {
        NSLog("[OfflineQueue] Executing \(operation.type.rawValue) operation: \(operation.id)")

        // REAL IMPLEMENTATION: Post notifications for services to handle
        // This decouples the queue from service implementations (KISS principle)
        await MainActor.run {
            switch operation.type {
            case .gmailSync:
                NotificationCenter.default.post(
                    name: NSNotification.Name("OfflineGmailSyncRequested"),
                    object: nil,
                    userInfo: ["operationId": operation.id]
                )
                NSLog("[OfflineQueue] Posted Gmail sync notification")

            case .basiqSync:
                NotificationCenter.default.post(
                    name: NSNotification.Name("OfflineBasiqSyncRequested"),
                    object: nil,
                    userInfo: ["operationId": operation.id]
                )
                NSLog("[OfflineQueue] Posted Basiq sync notification")

            case .tokenRefresh:
                NotificationCenter.default.post(
                    name: NSNotification.Name("OfflineTokenRefreshRequested"),
                    object: nil,
                    userInfo: ["operationId": operation.id]
                )
                NSLog("[OfflineQueue] Posted token refresh notification")
            }
        }

        return true  // Notification posted successfully (services will handle execution)
    }

    private func retryOperation(_ operation: OfflineOperation) async {
        guard operation.retryCount < maxRetries else {
            // Max retries reached, remove operation
            operations.removeAll { $0.id == operation.id }
            persistOperations()
            NSLog("⚠️ [OfflineQueue] Operation \(operation.id) exceeded max retries, removing from queue")
            return
        }

        // Increment retry count
        if let index = operations.firstIndex(where: { $0.id == operation.id }) {
            let updated = OfflineOperation(
                id: operation.id,
                type: operation.type,
                timestamp: operation.timestamp,
                retryCount: operation.retryCount + 1
            )
            operations[index] = updated
            persistOperations()
        }
    }

    private func persistOperations() {
        guard let encoded = try? JSONEncoder().encode(operations) else {
            NSLog("❌ [OfflineQueue] Failed to encode operations for persistence")
            return
        }
        UserDefaults.standard.set(encoded, forKey: persistenceKey)
    }

    private func loadPersistedOperations() {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey),
              let decoded = try? JSONDecoder().decode([OfflineOperation].self, from: data) else {
            return
        }
        operations = decoded
    }
}
