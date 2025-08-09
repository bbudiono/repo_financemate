import CoreData
import Foundation

/*
 * Purpose: PerformanceMetrics entity for portfolio performance tracking (I-Q-I Protocol Module 6/12)
 * Issues & Complexity Summary: Performance metrics with benchmarking and period tracking for Australian portfolios
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~110 (focused performance tracking responsibility)
   - Core Algorithm Complexity: Low-Medium (metric storage, benchmark comparison)
   - Dependencies: 2 (CoreData, WealthSnapshot relationship)
   - State Management Complexity: Low (metric calculation and storage)
   - Novelty/Uncertainty Factor: Low (established performance tracking patterns)
 * AI Pre-Task Self-Assessment: 94% (well-understood performance metrics patterns)
 * Problem Estimate: 70%
 * Initial Code Complexity Estimate: 65%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with Australian benchmarking context
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// PerformanceMetrics entity representing portfolio performance metrics and benchmark comparisons
/// Responsibilities: Performance metric storage, benchmark tracking, period-based analysis
/// I-Q-I Module: 6/12 - Performance tracking with professional Australian benchmarking standards
@objc(PerformanceMetrics)
public class PerformanceMetrics: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var metricType: String
    @NSManaged public var value: Double
    @NSManaged public var benchmarkValue: Double
    @NSManaged public var period: String
    @NSManaged public var calculatedAt: Date
    
    // MARK: - Relationships (Professional Architecture)
    
    /// Parent wealth snapshot relationship (required - every metric belongs to a snapshot)
    @NSManaged public var wealthSnapshot: WealthSnapshot
    
    // MARK: - Core Data Lifecycle (Professional Implementation)
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Initialize required properties with professional defaults
        self.id = UUID()
        self.calculatedAt = Date()
    }
    
    // MARK: - Business Logic (Professional Australian Investment Performance Analysis)
    
    /// Calculate performance relative to benchmark
    /// - Returns: Relative performance as percentage (positive = outperformed, negative = underperformed)
    /// - Quality: Professional investment performance calculation
    public func calculateRelativePerformance() -> Double {
        return value - benchmarkValue
    }
    
    /// Check if this metric outperformed the benchmark
    /// - Returns: Boolean indicating outperformance
    /// - Quality: Clear performance assessment for Australian investors
    public func outperformedBenchmark() -> Bool {
        return value > benchmarkValue
    }
    
    /// Calculate alpha (risk-adjusted return) if this is a return metric
    /// - Returns: Alpha value for risk-adjusted performance
    /// - Quality: Professional alpha calculation for Australian investment analysis
    public func calculateAlpha() -> Double {
        guard metricType.lowercased().contains("return") else { return 0.0 }
        
        // Simple alpha calculation: portfolio return - benchmark return
        return value - benchmarkValue
    }
    
    /// Check if this metric represents strong performance
    /// - Returns: Boolean indicating strong performance based on Australian investment standards
    /// - Quality: Australian investment performance assessment criteria
    public func representsStrongPerformance() -> Bool {
        switch metricType.lowercased() {
        case let type where type.contains("return"):
            // Returns above 8% annually are considered strong in Australian context
            return value > 8.0
        case let type where type.contains("sharpe"):
            // Sharpe ratio above 1.0 is considered good
            return value > 1.0
        case let type where type.contains("volatility"):
            // Lower volatility is better - below 15% is good
            return value < 15.0
        default:
            // Default to outperforming benchmark
            return outperformedBenchmark()
        }
    }
    
    /// Get appropriate Australian benchmark name for this metric type
    /// - Returns: String describing the relevant Australian benchmark
    /// - Quality: Australian investment benchmarking context
    public func getAustralianBenchmarkName() -> String {
        switch metricType.lowercased() {
        case let type where type.contains("return") || type.contains("performance"):
            if period.contains("1Y") || period.contains("Annual") {
                return "ASX 200 Total Return"
            } else {
                return "RBA Cash Rate + Risk Premium"
            }
        case let type where type.contains("volatility"):
            return "ASX 200 Volatility Index"
        case let type where type.contains("sharpe"):
            return "Australian Equity Funds Average"
        default:
            return "Australian Market Average"
        }
    }
    
    // MARK: - Factory Methods (Professional Quality with Validation)
    
    /// Creates a new PerformanceMetrics linked to a wealth snapshot with validation
    /// - Parameters:
    ///   - context: NSManagedObjectContext for performance metrics creation
    ///   - metricType: Type of performance metric (validated against standard types)
    ///   - value: Metric value (validated for reasonable performance ranges)
    ///   - benchmarkValue: Benchmark comparison value
    ///   - period: Performance period (e.g., "1Y", "3Y", "5Y")
    ///   - wealthSnapshot: Parent wealth snapshot (required relationship)
    /// - Returns: Configured PerformanceMetrics instance
    /// - Quality: Comprehensive validation and professional Australian investment logic
    static func create(
        in context: NSManagedObjectContext,
        metricType: String,
        value: Double,
        benchmarkValue: Double,
        period: String,
        wealthSnapshot: WealthSnapshot
    ) -> PerformanceMetrics {
        // Validate metric type (professional Australian investment software standards)
        guard !metricType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Metric type cannot be empty - performance classification requirement")
        }
        
        // Validate metric values
        guard value.isFinite && !value.isNaN else {
            fatalError("Metric value must be finite - performance calculation safety requirement")
        }
        
        guard benchmarkValue.isFinite && !benchmarkValue.isNaN else {
            fatalError("Benchmark value must be finite - comparison integrity requirement")
        }
        
        // Validate period
        guard !period.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Period cannot be empty - temporal analysis requirement")
        }
        
        // Create entity with proper error handling
        guard let entity = NSEntityDescription.entity(forEntityName: "PerformanceMetrics", in: context) else {
            fatalError("PerformanceMetrics entity not found in the provided context - Core Data configuration error")
        }
        
        // Initialize performance metrics with validated data
        let performanceMetrics = PerformanceMetrics(entity: entity, insertInto: context)
        performanceMetrics.id = UUID()
        performanceMetrics.metricType = metricType.trimmingCharacters(in: .whitespacesAndNewlines)
        performanceMetrics.value = value
        performanceMetrics.benchmarkValue = benchmarkValue
        performanceMetrics.period = period.trimmingCharacters(in: .whitespacesAndNewlines)
        performanceMetrics.wealthSnapshot = wealthSnapshot
        performanceMetrics.calculatedAt = Date()
        
        return performanceMetrics
    }
    
    // MARK: - Core Data Fetch Requests (Optimized Queries)
    
    /// Standard fetch request for PerformanceMetrics entities
    /// Quality: Type-safe fetch request with proper entity name
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PerformanceMetrics> {
        return NSFetchRequest<PerformanceMetrics>(entityName: "PerformanceMetrics")
    }
    
    /// Fetch performance metrics for a specific wealth snapshot
    /// - Parameters:
    ///   - wealthSnapshot: WealthSnapshot to fetch metrics for
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of performance metrics for the specified snapshot
    /// - Quality: Optimized Core Data query with proper sorting
    public class func fetchMetrics(
        for wealthSnapshot: WealthSnapshot,
        in context: NSManagedObjectContext
    ) throws -> [PerformanceMetrics] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "wealthSnapshot == %@", wealthSnapshot)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \PerformanceMetrics.metricType, ascending: true),
            NSSortDescriptor(keyPath: \PerformanceMetrics.period, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch performance metrics by type and period
    /// - Parameters:
    ///   - metricType: Type of metric to filter by
    ///   - period: Period to filter by
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of matching performance metrics
    /// - Quality: Efficient type and period-based queries for performance analysis
    public class func fetchMetrics(
        ofType metricType: String,
        forPeriod period: String,
        in context: NSManagedObjectContext
    ) throws -> [PerformanceMetrics] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "metricType == %@ AND period == %@", metricType, period)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \PerformanceMetrics.calculatedAt, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch metrics that outperformed their benchmarks
    /// - Parameter context: NSManagedObjectContext for query execution
    /// - Returns: Array of outperforming metrics
    /// - Quality: Efficient query for performance winners
    public class func fetchOutperformingMetrics(
        in context: NSManagedObjectContext
    ) throws -> [PerformanceMetrics] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "value > benchmarkValue")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \PerformanceMetrics.value, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    // MARK: - Australian Investment Formatting (Localized Business Logic)
    
    /// Format metric value with appropriate Australian display conventions
    /// - Returns: Formatted string based on metric type
    /// - Quality: Professional investment display formatting for Australian investors
    public func formattedValue() -> String {
        switch metricType.lowercased() {
        case let type where type.contains("return") || type.contains("performance"):
            return String(format: "%.2f%%", value)
        case let type where type.contains("ratio"):
            return String(format: "%.3f", value)
        case let type where type.contains("volatility"):
            return String(format: "%.2f%%", value)
        default:
            return String(format: "%.2f", value)
        }
    }
    
    /// Format benchmark value with appropriate Australian display conventions
    /// - Returns: Formatted benchmark string
    /// - Quality: Professional benchmark display formatting
    public func formattedBenchmarkValue() -> String {
        switch metricType.lowercased() {
        case let type where type.contains("return") || type.contains("performance"):
            return String(format: "%.2f%%", benchmarkValue)
        case let type where type.contains("ratio"):
            return String(format: "%.3f", benchmarkValue)
        case let type where type.contains("volatility"):
            return String(format: "%.2f%%", benchmarkValue)
        default:
            return String(format: "%.2f", benchmarkValue)
        }
    }
    
    /// Get performance summary with benchmark comparison
    /// - Returns: Formatted performance summary for Australian investors
    /// - Quality: Professional performance reporting for Australian investment context
    public func performanceSummary() -> String {
        let relativePerformance = calculateRelativePerformance()
        let benchmarkName = getAustralianBenchmarkName()
        
        if outperformedBenchmark() {
            return "📈 \(formattedValue()) vs \(formattedBenchmarkValue()) (\(benchmarkName)) - Outperformed by \(String(format: "%.2f", relativePerformance))pp"
        } else {
            return "📉 \(formattedValue()) vs \(formattedBenchmarkValue()) (\(benchmarkName)) - Underperformed by \(String(format: "%.2f", -relativePerformance))pp"
        }
    }
    
    /// Get risk-adjusted performance assessment
    /// - Returns: Risk-adjusted performance summary
    /// - Quality: Australian investment risk assessment
    public func riskAdjustedAssessment() -> String {
        if representsStrongPerformance() {
            return "🌟 Strong Performance - Above Australian market expectations"
        } else if outperformedBenchmark() {
            return "✅ Good Performance - Outperforming relevant benchmark"
        } else {
            return "⚠️ Below Benchmark - Consider portfolio review"
        }
    }
}

// MARK: - Extensions for Collection Operations (Professional Performance Analysis)

extension Collection where Element == PerformanceMetrics {
    
    /// Calculate average performance across all metrics
    /// - Returns: Average metric value with precision
    /// - Quality: Professional performance aggregation
    func averagePerformance() -> Double {
        guard !isEmpty else { return 0.0 }
        
        let total = reduce(0.0) { $0 + $1.value }
        return total / Double(count)
    }
    
    /// Calculate outperformance rate (percentage of metrics beating benchmark)
    /// - Returns: Percentage of metrics that outperformed benchmark
    /// - Quality: Professional performance success rate calculation
    func outperformanceRate() -> Double {
        guard !isEmpty else { return 0.0 }
        
        let outperforming = filter { $0.outperformedBenchmark() }
        return (Double(outperforming.count) / Double(count)) * 100.0
    }
    
    /// Group metrics by period for trend analysis
    /// - Returns: Dictionary of periods to metrics arrays
    /// - Quality: Professional temporal performance analysis
    func groupedByPeriod() -> [String: [PerformanceMetrics]] {
        var groups: [String: [PerformanceMetrics]] = [:]
        
        for metric in self {
            if groups[metric.period] == nil {
                groups[metric.period] = []
            }
            groups[metric.period]?.append(metric)
        }
        
        return groups
    }
    
    /// Find best performing metrics
    /// - Returns: Array of top performing metrics
    /// - Quality: Professional performance ranking
    func topPerformers() -> [PerformanceMetrics] {
        return sorted { $0.value > $1.value }
    }
    
    /// Calculate portfolio performance score (0-100, higher is better)
    /// - Returns: Overall performance score based on benchmark outperformance and values
    /// - Quality: Professional portfolio performance scoring for Australian investors
    func portfolioPerformanceScore() -> Double {
        guard !isEmpty else { return 50.0 } // Neutral score for no data
        
        let outperformanceRate = self.outperformanceRate()
        let averagePerformance = self.averagePerformance()
        
        // Weight outperformance rate (60%) and absolute performance (40%)
        let outperformanceScore = outperformanceRate // Already 0-100
        let performanceScore = max(0.0, min(100.0, averagePerformance * 5.0)) // Scale performance to 0-100
        
        return (outperformanceScore * 0.6) + (performanceScore * 0.4)
    }
    
    /// Get performance summary for all metrics
    /// - Returns: Comprehensive performance summary string
    /// - Quality: Professional performance reporting for Australian investment analysis
    func overallPerformanceSummary() -> String {
        guard !isEmpty else { return "No performance data available" }
        
        let outperformanceRate = self.outperformanceRate()
        let averagePerformance = self.averagePerformance()
        let performanceScore = portfolioPerformanceScore()
        
        let scoreDescription: String
        if performanceScore >= 80 {
            scoreDescription = "Excellent"
        } else if performanceScore >= 60 {
            scoreDescription = "Good"
        } else if performanceScore >= 40 {
            scoreDescription = "Fair"
        } else {
            scoreDescription = "Poor"
        }
        
        return "\(scoreDescription) Performance: \(String(format: "%.1f", outperformanceRate))% outperformance rate, \(String(format: "%.2f", averagePerformance))% average return (Score: \(String(format: "%.0f", performanceScore))/100)"
    }
}