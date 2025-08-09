import Foundation
import Combine

/**
 * Purpose: High-performance caching system for wealth calculations with real-time invalidation
 * Issues & Complexity Summary: Complex cache management with expiration, invalidation, and performance optimization
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~200
 *   - Core Algorithm Complexity: Medium-High (cache strategies, invalidation, thread safety)
 *   - Dependencies: Foundation, Combine, thread-safe collections
 *   - State Management Complexity: High (cache invalidation, expiration, concurrent access)
 *   - Novelty/Uncertainty Factor: Low (established caching patterns)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 87%
 * Target Coverage: ≥90%
 * Last Updated: 2025-08-08
 */

/// Cache key for wealth calculation results
public struct WealthCacheKey: Hashable {
    let entityId: String?
    let calculationType: WealthCalculationType
    let dateRange: DateRange?
    let parameters: [String: String]
    
    public init(entityId: String? = nil, 
                calculationType: WealthCalculationType, 
                dateRange: DateRange? = nil,
                parameters: [String: String] = [:]) {
        self.entityId = entityId
        self.calculationType = calculationType
        self.dateRange = dateRange
        self.parameters = parameters
    }
}

/// Types of wealth calculations that can be cached
public enum WealthCalculationType: String, CaseIterable {
    case netWealth = "net_wealth"
    case assetBreakdown = "asset_breakdown"
    case liabilityBreakdown = "liability_breakdown"
    case multiEntityAnalysis = "multi_entity_analysis"
    case performanceMetrics = "performance_metrics"
    case riskAnalysis = "risk_analysis"
}

/// Cached wealth calculation result with metadata
public struct CachedWealthResult {
    let data: Any
    let cacheKey: WealthCacheKey
    let cachedAt: Date
    let expiresAt: Date
    let size: Int
    
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    var age: TimeInterval {
        Date().timeIntervalSince(cachedAt)
    }
}

/// High-performance wealth calculation cache with intelligent invalidation
// EMERGENCY FIX: Removed to eliminate Swift Concurrency crashes
// COMPREHENSIVE FIX: Removed ALL Swift Concurrency patterns to eliminate TaskLocal crashes
public class WealthCalculationCache: ObservableObject {
    
    // MARK: - Configuration
    
    /// Maximum number of cached items (LRU eviction when exceeded)
    private let maxCacheSize: Int
    
    /// Default cache expiration time (5 minutes for financial data)
    private let defaultExpirationInterval: TimeInterval
    
    /// Maximum memory usage for cache (in bytes)
    private let maxMemoryUsage: Int
    
    // MARK: - Cache Storage
    
    /// Thread-safe cache storage with concurrent access
    private let cacheQueue = DispatchQueue(label: "wealth.cache", attributes: .concurrent)
    private var cache: [WealthCacheKey: CachedWealthResult] = [:]
    private var accessOrder: [WealthCacheKey] = [] // For LRU eviction
    private var currentMemoryUsage: Int = 0
    
    // MARK: - Performance Metrics
    
    @Published public private(set) var hitRate: Double = 0.0
    @Published public private(set) var memoryUsage: Int = 0
    @Published public private(set) var cacheSize: Int = 0
    
    private var hitCount: Int = 0
    private var missCount: Int = 0
    
    // MARK: - Cache Invalidation
    
    private var cancellables = Set<AnyCancellable>()
    private let invalidationPublisher = PassthroughSubject<WealthCacheKey, Never>()
    
    // MARK: - Initialization
    
    public init(maxCacheSize: Int = 100, 
                expirationInterval: TimeInterval = 300, // 5 minutes
                maxMemoryUsage: Int = 50 * 1024 * 1024) { // 50MB
        self.maxCacheSize = maxCacheSize
        self.defaultExpirationInterval = expirationInterval
        self.maxMemoryUsage = maxMemoryUsage
        
        setupPeriodicCleanup()
    }
    
    // MARK: - Cache Operations
    
    /// Retrieve cached result if available and not expired
    public func getCachedResult<T>(for key: WealthCacheKey, as type: T.Type) -> T? {
        return cacheQueue.sync {
            guard let cachedResult = cache[key], !cachedResult.isExpired else {
                incrementMissCount()
                return nil
            }
            
            // Update access order for LRU
            updateAccessOrder(key: key)
            incrementHitCount()
            
            return cachedResult.data as? T
        }
    }
    
    /// Store calculation result in cache
    public func setCachedResult<T>(_ result: T, 
                                   for key: WealthCacheKey, 
                                   expirationInterval: TimeInterval? = nil) {
        let expiration = expirationInterval ?? defaultExpirationInterval
        let expiresAt = Date().addingTimeInterval(expiration)
        
        // Estimate size (rough approximation)
        let estimatedSize = estimateObjectSize(result)
        
        let cachedResult = CachedWealthResult(
            data: result,
            cacheKey: key,
            cachedAt: Date(),
            expiresAt: expiresAt,
            size: estimatedSize
        )
        
        cacheQueue.async(flags: .barrier) { [weak self] in
            self?.storeCachedResult(cachedResult)
        }
    }
    
    /// Clear specific cached result
    public func clearCache(for key: WealthCacheKey) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            if let cachedResult = self?.cache.removeValue(forKey: key) {
                self?.currentMemoryUsage -= cachedResult.size
                self?.accessOrder.removeAll { $0 == key }
                self?.updateMetrics()
            }
        }
    }
    
    /// Clear all cached results for specific entity
    public func clearEntityCache(entityId: String) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            let keysToRemove = self?.cache.keys.filter { $0.entityId == entityId } ?? []
            
            for key in keysToRemove {
                if let cachedResult = self?.cache.removeValue(forKey: key) {
                    self?.currentMemoryUsage -= cachedResult.size
                    self?.accessOrder.removeAll { $0 == key }
                }
            }
            
            self?.updateMetrics()
        }
    }
    
    /// Clear all cached results for specific calculation type
    public func clearCalculationTypeCache(_ type: WealthCalculationType) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            let keysToRemove = self?.cache.keys.filter { $0.calculationType == type } ?? []
            
            for key in keysToRemove {
                if let cachedResult = self?.cache.removeValue(forKey: key) {
                    self?.currentMemoryUsage -= cachedResult.size
                    self?.accessOrder.removeAll { $0 == key }
                }
            }
            
            self?.updateMetrics()
        }
    }
    
    /// Clear all cached results
    public func clearAllCache() {
        cacheQueue.async(flags: .barrier) { [weak self] in
            self?.cache.removeAll()
            self?.accessOrder.removeAll()
            self?.currentMemoryUsage = 0
            self?.updateMetrics()
        }
    }
    
    // MARK: - Cache Management
    
    private func storeCachedResult(_ result: CachedWealthResult) {
        // Check if we need to evict items due to memory pressure
        while currentMemoryUsage + result.size > maxMemoryUsage && !cache.isEmpty {
            evictLeastRecentlyUsed()
        }
        
        // Check if we need to evict items due to count limit
        while cache.count >= maxCacheSize && !cache.isEmpty {
            evictLeastRecentlyUsed()
        }
        
        // Store new result
        cache[result.cacheKey] = result
        currentMemoryUsage += result.size
        updateAccessOrder(key: result.cacheKey)
        updateMetrics()
    }
    
    private func evictLeastRecentlyUsed() {
        guard let oldestKey = accessOrder.first else { return }
        
        if let cachedResult = cache.removeValue(forKey: oldestKey) {
            currentMemoryUsage -= cachedResult.size
            accessOrder.removeFirst()
        }
    }
    
    private func updateAccessOrder(key: WealthCacheKey) {
        // Remove existing position if present
        accessOrder.removeAll { $0 == key }
        
        // Add to end (most recently used)
        accessOrder.append(key)
    }
    
    private func cleanupExpiredEntries() {
        let expiredKeys = cache.compactMap { (key, result) in
            result.isExpired ? key : nil
        }
        
        for key in expiredKeys {
            if let cachedResult = cache.removeValue(forKey: key) {
                currentMemoryUsage -= cachedResult.size
                accessOrder.removeAll { $0 == key }
            }
        }
        
        if !expiredKeys.isEmpty {
            updateMetrics()
        }
    }
    
    // MARK: - Performance Monitoring
    
    private func incrementHitCount() {
        hitCount += 1
        updateHitRate()
    }
    
    private func incrementMissCount() {
        missCount += 1
        updateHitRate()
    }
    
    private func updateHitRate() {
        let total = hitCount + missCount
        hitRate = total > 0 ? Double(hitCount) / Double(total) : 0.0
    }
    
    private func updateMetrics() {
        DispatchQueue.main.{ [weak self] in
            guard let self = self else { return }
            self.memoryUsage = self.currentMemoryUsage
            self.cacheSize = self.cache.count
        }
    }
    
    // MARK: - Size Estimation
    
    private func estimateObjectSize<T>(_ object: T) -> Int {
        // Rough size estimation - could be improved with more sophisticated measurement
        switch object {
        case let data as Data:
            return data.count
        case let string as String:
            return string.utf8.count
        case let array as [Any]:
            return array.count * 64 // Rough estimate per item
        case let dict as [AnyHashable: Any]:
            return dict.count * 128 // Rough estimate per key-value pair
        default:
            return 256 // Default estimate for complex objects
        }
    }
    
    // MARK: - Periodic Cleanup
    
    private func setupPeriodicCleanup() {
        // Clean up expired entries every 2 minutes
        Timer.publish(every: 120, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.cacheQueue.async(flags: .barrier) {
                    self?.cleanupExpiredEntries()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Cache Statistics
    
    /// Get comprehensive cache statistics for monitoring
    public func getCacheStatistics() -> CacheStatistics {
        return cacheQueue.sync {
            let totalRequests = hitCount + missCount
            let averageAge = cache.values.reduce(0) { $0 + $1.age } / Double(max(1, cache.count))
            let expiredCount = cache.values.filter { $0.isExpired }.count
            
            return CacheStatistics(
                hitRate: hitRate,
                hitCount: hitCount,
                missCount: missCount,
                totalRequests: totalRequests,
                cacheSize: cache.count,
                memoryUsage: currentMemoryUsage,
                maxMemoryUsage: maxMemoryUsage,
                averageAge: averageAge,
                expiredEntries: expiredCount
            )
        }
    }
    
    /// Reset performance counters
    public func resetStatistics() {
        hitCount = 0
        missCount = 0
        hitRate = 0.0
        updateMetrics()
    }
}

// MARK: - Supporting Types

public struct CacheStatistics {
    let hitRate: Double
    let hitCount: Int
    let missCount: Int
    let totalRequests: Int
    let cacheSize: Int
    let memoryUsage: Int
    let maxMemoryUsage: Int
    let averageAge: TimeInterval
    let expiredEntries: Int
    
    var memoryUsagePercentage: Double {
        maxMemoryUsage > 0 ? Double(memoryUsage) / Double(maxMemoryUsage) * 100 : 0
    }
}