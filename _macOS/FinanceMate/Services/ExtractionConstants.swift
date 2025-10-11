import Foundation

/// Extraction pipeline configuration constants
/// BLUEPRINT Section 3.1.1.4: Confidence thresholds and performance limits
/// CODE QUALITY: Centralized configuration for all extraction components
struct ExtractionConstants {

    // MARK: - Tier Confidence Thresholds

    /// Tier 1: Regex fast path threshold (>80% = auto-approve)
    /// BLUEPRINT Section 3.1.1.4: High confidence quick extraction
    static let tier1ConfidenceThreshold: Double = 0.8

    /// Tier 2: Foundation Models threshold (>70% = approve)
    /// BLUEPRINT Section 3.1.1.4: Intelligent extraction fallback
    static let tier2ConfidenceThreshold: Double = 0.7

    /// Tier 3: Manual review confidence (low confidence transactions)
    /// BLUEPRINT Section 3.1.1.4: Human review queue
    static let manualReviewConfidence: Double = 0.3

    // MARK: - Badge Thresholds (UI)

    /// Green badge: Auto-approved transactions (>90% confidence)
    /// BLUEPRINT Line 130: Visual confidence indicators
    static let autoApprovedThreshold: Double = 0.9

    /// Yellow badge: Needs review (70-90% confidence)
    /// BLUEPRINT Line 130: Review required indicator
    static let needsReviewThreshold: Double = 0.7

    // Red badge: <70% = Manual review (derived threshold)

    // MARK: - Performance Limits

    /// Maximum concurrent extractions in TaskGroup
    /// Prevents system overload during bulk processing
    static let maxConcurrentExtractions: Int = 5

    /// Extraction timeout per email (seconds)
    /// Prevents hanging operations in Foundation Models
    static let extractionTimeout: TimeInterval = 10.0
}
