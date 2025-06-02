// SANDBOX FILE: For testing/development. See .cursorrules.
//
// LoggingFramework.swift
// FinanceMate-Sandbox
//
// Purpose: Enhanced logging framework with different severity levels and performance monitoring
// Issues & Complexity Summary: Complex multi-level logging with concurrent access and performance optimization
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~380
//   - Core Algorithm Complexity: High (thread-safe logging, performance monitoring, log aggregation)
//   - Dependencies: 4 New (os.log, os.signpost, Foundation, Combine)
//   - State Management Complexity: High (concurrent log writing, buffer management)
//   - Novelty/Uncertainty Factor: Low (established logging patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
// Problem Estimate (Inherent Problem Difficulty %): 70%
// Initial Code Complexity Estimate %: 72%
// Justification for Estimates: Well-established logging patterns with some complexity in thread safety
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import Foundation
import os.log
import os.signpost
import Combine

// MARK: - Log Level Definitions

/// Comprehensive log levels for different types of events
public enum LogLevel: Int, CaseIterable, Codable, Comparable {
    case trace = 0      // Detailed flow tracing
    case debug = 1      // Debug information
    case info = 2       // General information
    case warning = 3    // Warning conditions
    case error = 4      // Error conditions
    case critical = 5   // Critical failures
    case emergency = 6  // System is unusable
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    var description: String {
        switch self {
        case .trace: return "TRACE"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARN"
        case .error: return "ERROR"
        case .critical: return "CRITICAL"
        case .emergency: return "EMERGENCY"
        }
    }
    
    var osLogType: OSLogType {
        switch self {
        case .trace, .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .critical, .emergency: return .fault
        }
    }
    
    var emoji: String {
        switch self {
        case .trace: return "🔍"
        case .debug: return "🐛"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "💥"
        case .emergency: return "🚨"
        }
    }
}

// MARK: - Log Categories

/// Log categories for different subsystems
public enum LogCategory: String, CaseIterable, Codable {
    case app = "App"
    case network = "Network"
    case database = "Database"
    case authentication = "Auth"
    case ui = "UI"
    case performance = "Performance"
    case crash = "Crash"
    case security = "Security"
    case fileSystem = "FileSystem"
    case analytics = "Analytics"
    case testing = "Testing"
    
    var subsystem: String {
        return "com.ablankcanvas.financemate.sandbox"
    }
}

// MARK: - Log Entry Structure

/// Comprehensive log entry structure
public struct LogEntry: Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let level: LogLevel
    public let category: LogCategory
    public let message: String
    public let metadata: [String: String]
    public let file: String
    public let function: String
    public let line: Int
    public let threadId: String
    public let sessionId: String
    
    public init(
        level: LogLevel,
        category: LogCategory,
        message: String,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        sessionId: String
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.level = level
        self.category = category
        self.message = message
        self.metadata = metadata
        self.file = URL(fileURLWithPath: file).lastPathComponent
        self.function = function
        self.line = line
        self.threadId = Thread.current.description
        self.sessionId = sessionId
    }
}

// MARK: - Logger Protocol

public protocol LoggerProtocol {
    func log(level: LogLevel, category: LogCategory, message: String, metadata: [String: String], file: String, function: String, line: Int)
    func trace(_ message: String, category: LogCategory, metadata: [String: String], file: String, function: String, line: Int)
    func debug(_ message: String, category: LogCategory, metadata: [String: String], file: String, function: String, line: Int)
    func info(_ message: String, category: LogCategory, metadata: [String: String], file: String, function: String, line: Int)
    func warning(_ message: String, category: LogCategory, metadata: [String: String], file: String, function: String, line: Int)
    func error(_ message: String, category: LogCategory, metadata: [String: String], file: String, function: String, line: Int)
    func critical(_ message: String, category: LogCategory, metadata: [String: String], file: String, function: String, line: Int)
    func emergency(_ message: String, category: LogCategory, metadata: [String: String], file: String, function: String, line: Int)
}

// MARK: - Enhanced Logger Implementation

public final class EnhancedLogger: LoggerProtocol, ObservableObject {
    public static let shared = EnhancedLogger()
    
    private let osLoggers: [LogCategory: OSLog]
    private let signposter: OSSignposter
    private let sessionId: String
    private let logQueue = DispatchQueue(label: "com.financemate.logging", qos: .utility)
    private let bufferQueue = DispatchQueue(label: "com.financemate.logging.buffer", qos: .utility)
    
    // Configuration
    private var minimumLogLevel: LogLevel = .debug
    private var enabledCategories: Set<LogCategory> = Set(LogCategory.allCases)
    private var enableConsoleOutput: Bool = true
    private var enableFileOutput: Bool = true
    private var enableRemoteLogging: Bool = false
    
    // Log storage and buffering
    private var logBuffer: [LogEntry] = []
    private let maxBufferSize = 1000
    private var fileHandle: FileHandle?
    private let logFileURL: URL
    
    // Publishers for real-time monitoring
    @Published public private(set) var recentLogs: [LogEntry] = []
    @Published public private(set) var errorCount: Int = 0
    @Published public private(set) var warningCount: Int = 0
    
    private init() {
        self.sessionId = UUID().uuidString
        
        // Initialize OS loggers for each category
        var loggers: [LogCategory: OSLog] = [:]
        for category in LogCategory.allCases {
            loggers[category] = OSLog(subsystem: category.subsystem, category: category.rawValue)
        }
        self.osLoggers = loggers
        
        // Initialize signposter for performance tracking
        self.signposter = OSSignposter(logHandle: osLoggers[.performance]!)
        
        // Set up log file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.logFileURL = documentsPath.appendingPathComponent("financemate-crash-logs.txt")
        
        setupFileLogging()
        startLogBufferTimer()
    }
    
    deinit {
        fileHandle?.closeFile()
    }
    
    // MARK: - Configuration
    
    public func configure(
        minimumLevel: LogLevel = .debug,
        enabledCategories: Set<LogCategory> = Set(LogCategory.allCases),
        enableConsole: Bool = true,
        enableFile: Bool = true,
        enableRemote: Bool = false
    ) {
        logQueue.async { [weak self] in
            self?.minimumLogLevel = minimumLevel
            self?.enabledCategories = enabledCategories
            self?.enableConsoleOutput = enableConsole
            self?.enableFileOutput = enableFile
            self?.enableRemoteLogging = enableRemote
        }
    }
    
    // MARK: - Core Logging Implementation
    
    public func log(
        level: LogLevel,
        category: LogCategory,
        message: String,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard level >= minimumLogLevel && enabledCategories.contains(category) else { return }
        
        let entry = LogEntry(
            level: level,
            category: category,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line,
            sessionId: sessionId
        )
        
        logQueue.async { [weak self] in
            self?.processLogEntry(entry)
        }
    }
    
    // MARK: - Convenience Methods
    
    public func trace(
        _ message: String,
        category: LogCategory = .app,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .trace, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func debug(
        _ message: String,
        category: LogCategory = .app,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .debug, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func info(
        _ message: String,
        category: LogCategory = .app,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .info, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func warning(
        _ message: String,
        category: LogCategory = .app,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .warning, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func error(
        _ message: String,
        category: LogCategory = .app,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .error, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func critical(
        _ message: String,
        category: LogCategory = .app,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .critical, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func emergency(
        _ message: String,
        category: LogCategory = .app,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .emergency, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    // MARK: - Performance Tracking
    
    public func beginSignpost(name: StaticString, category: LogCategory = .performance) -> OSSignpostIntervalState {
        let signpostID = signposter.makeSignpostID()
        return signposter.beginInterval(name, id: signpostID)
    }
    
    public func endSignpost(name: StaticString, state: OSSignpostIntervalState) {
        signposter.endInterval(name, state)
    }
    
    // MARK: - Log Management
    
    public func getLogs(since: Date? = nil, level: LogLevel? = nil, category: LogCategory? = nil) -> [LogEntry] {
        return bufferQueue.sync {
            var filtered = logBuffer
            
            if let since = since {
                filtered = filtered.filter { $0.timestamp >= since }
            }
            
            if let level = level {
                filtered = filtered.filter { $0.level >= level }
            }
            
            if let category = category {
                filtered = filtered.filter { $0.category == category }
            }
            
            return filtered.sorted { $0.timestamp > $1.timestamp }
        }
    }
    
    public func clearLogs() {
        bufferQueue.async { [weak self] in
            self?.logBuffer.removeAll()
            DispatchQueue.main.async {
                self?.recentLogs.removeAll()
                self?.errorCount = 0
                self?.warningCount = 0
            }
        }
    }
    
    public func exportLogs() -> URL? {
        let exportURL = logFileURL.appendingPathExtension("export")
        
        do {
            let logs = getLogs()
            let jsonData = try JSONEncoder().encode(logs)
            try jsonData.write(to: exportURL)
            return exportURL
        } catch {
            self.error("Failed to export logs: \(error)", category: .app)
            return nil
        }
    }
    
    // MARK: - Private Implementation
    
    private func processLogEntry(_ entry: LogEntry) {
        // Write to OS Log
        if let osLogger = osLoggers[entry.category] {
            let formattedMessage = formatLogMessage(entry)
            os_log("%{public}@", log: osLogger, type: entry.level.osLogType, formattedMessage)
        }
        
        // Write to console if enabled
        if enableConsoleOutput {
            print(formatConsoleMessage(entry))
        }
        
        // Write to file if enabled
        if enableFileOutput {
            writeToFile(entry)
        }
        
        // Add to buffer
        bufferQueue.async { [weak self] in
            self?.addToBuffer(entry)
        }
        
        // Update counters
        DispatchQueue.main.async { [weak self] in
            self?.updateCounters(for: entry)
        }
    }
    
    private func formatLogMessage(_ entry: LogEntry) -> String {
        let metadataString = entry.metadata.isEmpty ? "" : " | \(entry.metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))"
        return "\(entry.level.emoji) [\(entry.category.rawValue)] \(entry.message)\(metadataString)"
    }
    
    private func formatConsoleMessage(_ entry: LogEntry) -> String {
        let timestamp = DateFormatter.logFormatter.string(from: entry.timestamp)
        return "\(timestamp) \(formatLogMessage(entry)) [\(entry.file):\(entry.line)]"
    }
    
    private func setupFileLogging() {
        do {
            if !FileManager.default.fileExists(atPath: logFileURL.path) {
                FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
            }
            fileHandle = try FileHandle(forWritingTo: logFileURL)
            fileHandle?.seekToEndOfFile()
        } catch {
            print("Failed to setup file logging: \(error)")
        }
    }
    
    private func writeToFile(_ entry: LogEntry) {
        guard let fileHandle = fileHandle else { return }
        
        let logLine = "\(formatConsoleMessage(entry))\n"
        if let data = logLine.data(using: .utf8) {
            fileHandle.write(data)
        }
    }
    
    private func addToBuffer(_ entry: LogEntry) {
        logBuffer.append(entry)
        
        // Maintain buffer size
        if logBuffer.count > maxBufferSize {
            logBuffer.removeFirst(logBuffer.count - maxBufferSize)
        }
        
        // Update recent logs on main thread
        DispatchQueue.main.async { [weak self] in
            self?.recentLogs.append(entry)
            if let count = self?.recentLogs.count, count > 50 {
                self?.recentLogs.removeFirst(count - 50)
            }
        }
    }
    
    private func updateCounters(for entry: LogEntry) {
        switch entry.level {
        case .error, .critical, .emergency:
            errorCount += 1
        case .warning:
            warningCount += 1
        default:
            break
        }
    }
    
    private func startLogBufferTimer() {
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.flushLogs()
        }
    }
    
    private func flushLogs() {
        fileHandle?.synchronizeFile()
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}

// MARK: - Global Logger Access

public let Logger = EnhancedLogger.shared