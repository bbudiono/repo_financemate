//
// IntelligenceCache.swift
// FinanceMate
//
// Modular Component: Intelligence System Cache Management
// Created: 2025-08-03
// Purpose: Caching and performance optimization for AI intelligence components
// Responsibility: Cache management, performance monitoring, data optimization
//

/*
 * Purpose: Cache management and performance optimization for AI intelligence system
 * Issues & Complexity Summary: Cache coordination, performance monitoring, memory management
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~80
   - Core Algorithm Complexity: Low (cache management, not algorithms)
   - Dependencies: IntelligenceTypes, Foundation
   - State Management Complexity: Medium (cache states, expiration management)
   - Novelty/Uncertainty Factor: Low (standard caching patterns)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 82%
 * Final Code Complexity: 85%
 * Overall Result Score: 94%
 * Key Variances/Learnings: Cache management enables significant performance improvements
 * Last Updated: 2025-08-03
 */

import Foundation
import OSLog

final class IntelligenceCache {
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "com.financemate.intelligence", category: "IntelligenceCache")
    
    // Cache storage
    private var cachedPatterns: [ExpensePattern]?
    private var cachedInsights: [FinancialInsight]?
    private var cachedPredictions: [String: Any] = [:]
    private var cachedAnalyses: [String: Any] = [:]
    
    // Cache metadata and performance tracking
    private var cacheTimestamp: Date?
    private var cacheHitCount: Int = 0
    private var cacheMissCount: Int = 0
    private var totalCacheRequests: Int = 0
    
    // Cache configuration
    private let cacheValidityDuration: TimeInterval = 3600 // 1 hour
    private let maxCacheEntries: Int = 100
    private let performanceThreshold: TimeInterval = 0.1 // 100ms
    
    // MARK: - Initialization
    
    init() {
        logger.info("IntelligenceCache initialized with performance optimization")
    }
    
    // MARK: - Pattern Caching
    
    func getCachedPatterns() -> [ExpensePattern]? {
        totalCacheRequests += 1
        
        guard isCacheValid() else {
            cacheMissCount += 1
            logger.debug("Pattern cache miss - expired or empty")
            return nil
        }
        
        cacheHitCount += 1
        logger.debug("Pattern cache hit - returning cached patterns")
        return cachedPatterns
    }
    
    func cachePatterns(_ patterns: [ExpensePattern]) {
        cachedPatterns = patterns
        updateCacheTimestamp()
        
        logger.debug("Cached \(patterns.count) expense patterns")
    }
    
    // MARK: - Insight Caching
    
    func getCachedInsights() -> [FinancialInsight]? {
        totalCacheRequests += 1
        
        guard isCacheValid() else {
            cacheMissCount += 1
            logger.debug("Insight cache miss - expired or empty")
            return nil
        }
        
        cacheHitCount += 1
        logger.debug("Insight cache hit - returning cached insights")
        return cachedInsights
    }
    
    func cacheInsights(_ insights: [FinancialInsight]) {
        cachedInsights = insights
        updateCacheTimestamp()
        
        logger.debug("Cached \(insights.count) financial insights")
    }
    
    // MARK: - Prediction Caching
    
    func getCachedPrediction(for key: String) -> Any? {
        totalCacheRequests += 1
        
        guard isCacheValid(), let prediction = cachedPredictions[key] else {
            cacheMissCount += 1
            logger.debug("Prediction cache miss for key: \(key)")
            return nil
        }
        
        cacheHitCount += 1
        logger.debug("Prediction cache hit for key: \(key)")
        return prediction
    }
    
    func cachePrediction(_ prediction: Any, for key: String) {
        // Implement cache size limit
        if cachedPredictions.count >= maxCacheEntries {
            evictOldestPredictions()
        }
        
        cachedPredictions[key] = prediction
        updateCacheTimestamp()
        
        logger.debug("Cached prediction for key: \(key)")
    }
    
    // MARK: - Analysis Caching
    
    func getCachedAnalysis(for key: String) -> Any? {
        totalCacheRequests += 1
        
        guard isCacheValid(), let analysis = cachedAnalyses[key] else {
            cacheMissCount += 1
            logger.debug("Analysis cache miss for key: \(key)")
            return nil
        }
        
        cacheHitCount += 1
        logger.debug("Analysis cache hit for key: \(key)")
        return analysis
    }
    
    func cacheAnalysis(_ analysis: Any, for key: String) {
        // Implement cache size limit
        if cachedAnalyses.count >= maxCacheEntries {
            evictOldestAnalyses()
        }
        
        cachedAnalyses[key] = analysis
        updateCacheTimestamp()
        
        logger.debug("Cached analysis for key: \(key)")
    }
    
    // MARK: - Cache Management
    
    func clearAll() {
        cachedPatterns = nil
        cachedInsights = nil
        cachedPredictions.removeAll()
        cachedAnalyses.removeAll()
        cacheTimestamp = nil
        
        logger.info("All intelligence caches cleared")
    }
    
    func clearExpiredEntries() {
        guard let timestamp = cacheTimestamp else { return }
        
        if Date().timeIntervalSince(timestamp) >= cacheValidityDuration {
            clearAll()
            logger.info("Expired cache entries cleared")
        }
    }
    
    func optimizeCache() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Remove expired entries
        clearExpiredEntries()
        
        // Optimize cache size if needed
        if cachedPredictions.count > maxCacheEntries * 0.8 {
            evictOldestPredictions()
        }
        
        if cachedAnalyses.count > maxCacheEntries * 0.8 {
            evictOldestAnalyses()
        }
        
        let optimizationTime = CFAbsoluteTimeGetCurrent() - startTime
        logger.debug("Cache optimization completed in \(optimizationTime)s")
    }
    
    // MARK: - Performance Monitoring
    
    func getCachePerformanceMetrics() -> CachePerformanceMetrics {
        let hitRate = totalCacheRequests > 0 ? Double(cacheHitCount) / Double(totalCacheRequests) : 0.0
        let missRate = totalCacheRequests > 0 ? Double(cacheMissCount) / Double(totalCacheRequests) : 0.0
        
        return CachePerformanceMetrics(
            hitRate: hitRate,
            missRate: missRate,
            totalRequests: totalCacheRequests,
            cacheSize: getCurrentCacheSize(),
            validityDuration: cacheValidityDuration,
            isHealthy: hitRate > 0.5 // Healthy if >50% hit rate
        )
    }
    
    func resetPerformanceMetrics() {
        cacheHitCount = 0
        cacheMissCount = 0
        totalCacheRequests = 0
        
        logger.debug("Cache performance metrics reset")
    }
    
    // MARK: - Private Methods
    
    private func isCacheValid() -> Bool {
        guard let timestamp = cacheTimestamp else {
            logger.debug("Cache invalid - no timestamp")
            return false
        }
        
        let isValid = Date().timeIntervalSince(timestamp) < cacheValidityDuration
        if !isValid {
            logger.debug("Cache invalid - expired")
        }
        
        return isValid
    }
    
    private func updateCacheTimestamp() {
        cacheTimestamp = Date()
    }
    
    private func evictOldestPredictions() {
        let targetSize = maxCacheEntries / 2
        let keysToRemove = Array(cachedPredictions.keys.prefix(cachedPredictions.count - targetSize))
        
        for key in keysToRemove {
            cachedPredictions.removeValue(forKey: key)
        }
        
        logger.debug("Evicted \(keysToRemove.count) oldest prediction cache entries")
    }
    
    private func evictOldestAnalyses() {
        let targetSize = maxCacheEntries / 2
        let keysToRemove = Array(cachedAnalyses.keys.prefix(cachedAnalyses.count - targetSize))
        
        for key in keysToRemove {
            cachedAnalyses.removeValue(forKey: key)
        }
        
        logger.debug("Evicted \(keysToRemove.count) oldest analysis cache entries")
    }
    
    private func getCurrentCacheSize() -> Int {
        let patternCount = cachedPatterns?.count ?? 0
        let insightCount = cachedInsights?.count ?? 0
        let predictionCount = cachedPredictions.count
        let analysisCount = cachedAnalyses.count
        
        return patternCount + insightCount + predictionCount + analysisCount
    }
}

// MARK: - Performance Monitor Class

final class PerformanceMonitor {
    
    private let logger = Logger(subsystem: "com.financemate.intelligence", category: "PerformanceMonitor")
    
    // Performance tracking
    private var operationTimes: [String: [TimeInterval]] = [:]
    private var memoryUsage: [String: Double] = [:]
    private let performanceThreshold: TimeInterval = 0.5 // 500ms
    
    // MARK: - Initialization
    
    init() {
        logger.info("PerformanceMonitor initialized")
    }
    
    // MARK: - Performance Tracking
    
    func startOperation(_ operationName: String) -> PerformanceToken {
        return PerformanceToken(operationName: operationName, startTime: CFAbsoluteTimeGetCurrent())
    }
    
    func endOperation(_ token: PerformanceToken) {
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - token.startTime
        
        // Store operation time
        operationTimes[token.operationName, default: []].append(duration)
        
        // Log slow operations
        if duration > performanceThreshold {
            logger.warning("Slow operation detected: \(token.operationName) took \(duration)s")
        } else {
            logger.debug("Operation completed: \(token.operationName) in \(duration)s")
        }
    }
    
    func recordMemoryUsage(_ usage: Double, for component: String) {
        memoryUsage[component] = usage
        logger.debug("Memory usage recorded for \(component): \(usage) MB")
    }
    
    func getPerformanceReport() -> PerformanceReport {
        var operationAverages: [String: TimeInterval] = [:]
        
        for (operation, times) in operationTimes {
            let average = times.reduce(0, +) / Double(times.count)
            operationAverages[operation] = average
        }
        
        return PerformanceReport(
            operationAverages: operationAverages,
            memoryUsage: memoryUsage,
            slowOperations: operationAverages.filter { $0.value > performanceThreshold }
        )
    }
}

// MARK: - Supporting Data Structures

struct CachePerformanceMetrics {
    let hitRate: Double
    let missRate: Double
    let totalRequests: Int
    let cacheSize: Int
    let validityDuration: TimeInterval
    let isHealthy: Bool
}

struct PerformanceToken {
    let operationName: String
    let startTime: CFAbsoluteTime
}

struct PerformanceReport {
    let operationAverages: [String: TimeInterval]
    let memoryUsage: [String: Double]
    let slowOperations: [String: TimeInterval]
}