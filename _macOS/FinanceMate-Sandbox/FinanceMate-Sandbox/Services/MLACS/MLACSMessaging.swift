//
//  MLACSMessaging.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

import Foundation
import Combine

// MARK: - MLACS Message

public struct MLACSMessage: Identifiable, Codable {
    public let id: String
    public let senderId: String
    public let receiverId: String
    public let type: MLACSMessageType
    public let payload: [String: AnyCodable]
    public let timestamp: Date
    public let priority: MLACSMessagePriority
    public var attempts: Int = 0
    
    public init(id: String, senderId: String, receiverId: String, type: MLACSMessageType, payload: [String: Any], timestamp: Date, priority: MLACSMessagePriority) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.type = type
        self.payload = payload.mapValues { AnyCodable($0) }
        self.timestamp = timestamp
        self.priority = priority
    }
}

public enum MLACSMessageType: String, Codable, CaseIterable {
    case heartbeat = "heartbeat"
    case heartbeatResponse = "heartbeat_response"
    case status = "status"
    case statusResponse = "status_response"
    case task = "task"
    case taskResponse = "task_response"
    case data = "data"
    case command = "command"
    case notification = "notification"
    case error = "error"
    case shutdown = "shutdown"
    case broadcast = "broadcast"
    case custom = "custom"
}

public enum MLACSMessagePriority: Int, Codable, CaseIterable {
    case low = 1
    case normal = 2
    case high = 3
    case critical = 4
}

// MARK: - MLACS Message Queue

public class MLACSMessageQueue: ObservableObject {
    
    private var queue: [MLACSMessage] = []
    private let lock = NSLock()
    private let processingQueue = DispatchQueue(label: "com.mlacs.messagequeue", qos: .userInitiated)
    
    public let messageProcessed = PassthroughSubject<MLACSMessage, Never>()
    
    public var size: Int {
        lock.lock()
        defer { lock.unlock() }
        return queue.count
    }
    
    public func enqueue(_ message: MLACSMessage) async {
        await withCheckedContinuation { continuation in
            processingQueue.async { [weak self] in
                self?.lock.lock()
                defer { self?.lock.unlock() }
                
                // Insert based on priority
                let insertIndex = self?.queue.firstIndex { $0.priority.rawValue < message.priority.rawValue } ?? self?.queue.count ?? 0
                self?.queue.insert(message, at: insertIndex)
                
                continuation.resume()
            }
        }
    }
    
    public func dequeue() async -> MLACSMessage? {
        return await withCheckedContinuation { continuation in
            processingQueue.async { [weak self] in
                self?.lock.lock()
                defer { self?.lock.unlock() }
                
                let message = self?.queue.isEmpty == false ? self?.queue.removeFirst() : nil
                continuation.resume(returning: message)
            }
        }
    }
    
    public func peek() async -> MLACSMessage? {
        return await withCheckedContinuation { continuation in
            processingQueue.async { [weak self] in
                self?.lock.lock()
                defer { self?.lock.unlock() }
                
                continuation.resume(returning: self?.queue.first)
            }
        }
    }
    
    public func clear() async {
        await withCheckedContinuation { continuation in
            processingQueue.async { [weak self] in
                self?.lock.lock()
                defer { self?.lock.unlock() }
                
                self?.queue.removeAll()
                continuation.resume()
            }
        }
    }
    
    public func processMessage(_ message: MLACSMessage) {
        messageProcessed.send(message)
    }
}

// MARK: - MLACS Channel

public struct MLACSChannel: Identifiable, Codable {
    public let id: String
    public let name: String
    public let participants: [String]
    public let createdAt: Date
    public var lastActivity: Date = Date()
    public var messageCount: Int = 0
    
    public init(id: String, name: String, participants: [String], createdAt: Date) {
        self.id = id
        self.name = name
        self.participants = participants
        self.createdAt = createdAt
    }
}

// MARK: - MLACS Coordination Engine

@MainActor
public class MLACSCoordinationEngine: ObservableObject {
    
    // MARK: - Properties
    
    @Published public var isInitialized: Bool = false
    @Published public var registeredAgents: [String: MLACSAgent] = [:]
    @Published public var activeChannels: [String: MLACSChannel] = [:]
    
    public let errorOccurred = PassthroughSubject<Error, Never>()
    
    // MARK: - Private Properties
    
    private let configuration: MLACSConfiguration
    private let messageRouter: MLACSMessageRouter
    private let taskScheduler: MLACSTaskScheduler
    private var routingTable: [String: String] = [:]
    
    // MARK: - Initialization
    
    public init(config: MLACSConfiguration) {
        self.configuration = config
        self.messageRouter = MLACSMessageRouter()
        self.taskScheduler = MLACSTaskScheduler()
    }
    
    // MARK: - Public Methods
    
    public func initialize() async throws {
        try await messageRouter.initialize()
        try await taskScheduler.initialize()
        
        isInitialized = true
        print("MLACS Coordination Engine initialized")
    }
    
    public func registerAgent(_ agent: MLACSAgent) async throws {
        registeredAgents[agent.id] = agent
        routingTable[agent.id] = agent.id
        
        try await agent.activate()
        print("Agent registered in coordination engine: \(agent.id)")
    }
    
    public func unregisterAgent(_ agent: MLACSAgent) async throws {
        await agent.deactivate()
        
        registeredAgents.removeValue(forKey: agent.id)
        routingTable.removeValue(forKey: agent.id)
        
        print("Agent unregistered from coordination engine: \(agent.id)")
    }
    
    public func routeMessage(_ message: MLACSMessage) async throws {
        guard let recipientAgent = registeredAgents[message.receiverId] else {
            throw MLACSError.agentNotFound(message.receiverId)
        }
        
        do {
            try await messageRouter.routeMessage(message, to: recipientAgent)
        } catch {
            errorOccurred.send(error)
            throw error
        }
    }
    
    public func createChannel(_ channel: MLACSChannel) async throws {
        // Validate all participants exist
        for participantId in channel.participants {
            guard registeredAgents[participantId] != nil else {
                throw MLACSError.agentNotFound(participantId)
            }
        }
        
        activeChannels[channel.id] = channel
        print("Channel created: \(channel.name)")
    }
    
    public func updateConfiguration(_ config: MLACSConfiguration) async throws {
        // Update configuration and restart if necessary
        print("Coordination engine configuration updated")
    }
}

// MARK: - MLACS Message Router

public class MLACSMessageRouter {
    
    private let routingQueue = DispatchQueue(label: "com.mlacs.router", qos: .userInitiated)
    
    public func initialize() async throws {
        print("Message router initialized")
    }
    
    public func routeMessage(_ message: MLACSMessage, to agent: MLACSAgent) async throws {
        await withCheckedContinuation { continuation in
            routingQueue.async {
                Task { @MainActor in
                    do {
                        try await agent.handleMessage(message)
                        continuation.resume()
                    } catch {
                        continuation.resume()
                        throw error
                    }
                }
            }
        }
    }
}

// MARK: - MLACS Task Scheduler

public class MLACSTaskScheduler {
    
    private var scheduledTasks: [String: MLACSTask] = [:]
    private let schedulerQueue = DispatchQueue(label: "com.mlacs.scheduler", qos: .userInitiated)
    
    public func initialize() async throws {
        print("Task scheduler initialized")
    }
    
    public func scheduleTask(_ task: MLACSTask) async throws {
        scheduledTasks[task.id] = task
        print("Task scheduled: \(task.id)")
    }
    
    public func cancelTask(_ taskId: String) async throws {
        scheduledTasks.removeValue(forKey: taskId)
        print("Task cancelled: \(taskId)")
    }
}

// MARK: - MLACS Task

public struct MLACSTask: Identifiable, Codable {
    public let id: String
    public let agentId: String
    public let type: String
    public let payload: [String: AnyCodable]
    public let scheduledAt: Date
    public let priority: MLACSMessagePriority
    
    public init(id: String, agentId: String, type: String, payload: [String: Any], scheduledAt: Date, priority: MLACSMessagePriority) {
        self.id = id
        self.agentId = agentId
        self.type = type
        self.payload = payload.mapValues { AnyCodable($0) }
        self.scheduledAt = scheduledAt
        self.priority = priority
    }
}

// MARK: - AnyCodable Helper

public struct AnyCodable: Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else {
            value = "unknown"
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else {
            try container.encode("unknown")
        }
    }
}