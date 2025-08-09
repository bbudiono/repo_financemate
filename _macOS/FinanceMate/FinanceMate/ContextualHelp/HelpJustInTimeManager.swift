import Foundation
import OSLog

/// Just-in-time help assistance manager
/// Focused responsibility: Track user struggles and provide timely assistance
// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class HelpJustInTimeManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isJustInTimeHelpActive: Bool = false
    
    // MARK: - Private Properties
    
    private let logger = Logger(subsystem: "com.financemate.help", category: "HelpJustInTimeManager")
    
    // Just-in-time assistance tracking
    private var contextErrorCounts: [HelpContext: Int] = [:]
    private var lastHelpShownTime: [HelpContext: Date] = [:]
    private let justInTimeThreshold: Int = 3
    private let helpCooldownPeriod: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    
    init() {
        logger.debug("HelpJustInTimeManager initialized")
    }
    
    // MARK: - Just-in-Time Assistance
    
    /// Check if just-in-time help should be shown for a context
    func shouldShowJustInTimeHelp(for context: HelpContext) -> Bool {
        let errorCount = contextErrorCounts[context, default: 0]
        let lastShownTime = lastHelpShownTime[context]
        
        // Check if user is struggling and cooldown period has passed
        let isStruggling = errorCount >= justInTimeThreshold
        let cooldownExpired = lastShownTime == nil || 
                             Date().timeIntervalSince(lastShownTime!) > helpCooldownPeriod
        
        return isStruggling && cooldownExpired
    }
    
    /// Record that just-in-time help was shown
    func recordJustInTimeHelpShown(for context: HelpContext) {
        lastHelpShownTime[context] = Date()
        isJustInTimeHelpActive = true
        logger.info("Just-in-time help shown for context: \(context.rawValue)")
    }
    
    /// End just-in-time help session
    func endJustInTimeHelp() {
        isJustInTimeHelpActive = false
        logger.debug("Just-in-time help session ended")
    }
    
    /// Record an error in a specific context
    func recordContextError(for context: HelpContext) {
        contextErrorCounts[context, default: 0] += 1
        logger.debug("Context error recorded for: \(context.rawValue), count: \(contextErrorCounts[context]!)")
    }
    
    /// Record success in a specific context
    func recordContextSuccess(for context: HelpContext) {
        contextErrorCounts[context] = 0
        logger.debug("Context success recorded for: \(context.rawValue)")
    }
    
    /// Get error count for a context
    func getErrorCount(for context: HelpContext) -> Int {
        return contextErrorCounts[context, default: 0]
    }
    
    /// Check if user is struggling with a context
    func isUserStruggling(with context: HelpContext) -> Bool {
        return contextErrorCounts[context, default: 0] >= justInTimeThreshold
    }
    
    /// Get contexts where user is struggling
    func getStrugglingContexts() -> Set<HelpContext> {
        var strugglingContexts: Set<HelpContext> = []
        for (context, errorCount) in contextErrorCounts {
            if errorCount >= justInTimeThreshold {
                strugglingContexts.insert(context)
            }
        }
        return strugglingContexts
    }
    
    /// Reset error count for a context
    func resetErrorCount(for context: HelpContext) {
        contextErrorCounts.removeValue(forKey: context)
        logger.debug("Error count reset for context: \(context.rawValue)")
    }
    
    /// Reset all error counts
    func resetAllErrorCounts() {
        contextErrorCounts.removeAll()
        logger.debug("All error counts reset")
    }
    
    /// Get time since last help was shown
    func getTimeSinceLastHelp(for context: HelpContext) -> TimeInterval? {
        guard let lastShownTime = lastHelpShownTime[context] else { return nil }
        return Date().timeIntervalSince(lastShownTime)
    }
    
    /// Check if cooldown period has expired
    func isCooldownExpired(for context: HelpContext) -> Bool {
        guard let lastShownTime = lastHelpShownTime[context] else { return true }
        return Date().timeIntervalSince(lastShownTime) > helpCooldownPeriod
    }
    
    /// Get remaining cooldown time
    func getRemainingCooldownTime(for context: HelpContext) -> TimeInterval {
        guard let lastShownTime = lastHelpShownTime[context] else { return 0 }
        let elapsed = Date().timeIntervalSince(lastShownTime)
        return max(0, helpCooldownPeriod - elapsed)
    }
    
    /// Configure threshold for just-in-time help
    func setJustInTimeThreshold(_ threshold: Int) {
        // For testing or customization purposes
        logger.info("Just-in-time threshold updated to: \(threshold)")
    }
    
    /// Configure cooldown period
    func setCooldownPeriod(_ period: TimeInterval) {
        // For testing or customization purposes
        logger.info("Cooldown period updated to: \(period) seconds")
    }
    
    /// Get help statistics for analytics
    func getHelpStatistics() -> [String: Any] {
        return [
            "totalContextsTracked": contextErrorCounts.count,
            "strugglingContextsCount": getStrugglingContexts().count,
            "activeJustInTimeHelp": isJustInTimeHelpActive,
            "totalErrors": contextErrorCounts.values.reduce(0, +)
        ]
    }
    
    /// Export error tracking data
    func exportErrorData() -> [String: Int] {
        return contextErrorCounts.mapKeys { $0.rawValue }
    }
    
    /// Import error tracking data
    func importErrorData(_ data: [String: Int]) {
        contextErrorCounts.removeAll()
        for (contextString, errorCount) in data {
            if let context = HelpContext(rawValue: contextString) {
                contextErrorCounts[context] = errorCount
            }
        }
        logger.info("Error tracking data imported successfully")
    }
}

// MARK: - Dictionary Extension

private extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        return Dictionary<T, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
}