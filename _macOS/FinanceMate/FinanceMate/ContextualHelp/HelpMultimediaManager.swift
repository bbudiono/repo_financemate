import Foundation
import OSLog

/// Multimedia content coordinator for help system
/// Focused responsibility: Coordinate video and demo managers for unified multimedia experience
// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class HelpMultimediaManager: ObservableObject {
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "com.financemate.help", category: "HelpMultimediaManager")
    private let videoManager: HelpVideoManager
    private let demoManager: HelpDemoManager
    
    // MARK: - Initialization
    
    init() {
        self.videoManager = HelpVideoManager()
        self.demoManager = HelpDemoManager()
        logger.debug("HelpMultimediaManager initialized")
    }
    
    // MARK: - Video Content Management
    
    /// Generate video content for a specific help context
    func generateVideoContent(for context: HelpContext) -> VideoContent? {
        return videoManager.generateVideoContent(for: context)
    }
    
    /// Get all available video content for contexts
    func getAllVideoContent() -> [HelpContext: VideoContent] {
        return videoManager.getAllVideoContent()
    }
    
    /// Check if video content is available for a context
    func isVideoAvailable(for context: HelpContext) -> Bool {
        return videoManager.isVideoAvailable(for: context)
    }
    
    /// Get video duration for a context
    func getVideoDuration(for context: HelpContext) -> TimeInterval {
        return videoManager.getVideoDuration(for: context)
    }
    
    // MARK: - Interactive Demo Management
    
    /// Generate interactive demos for a specific context
    func generateInteractiveDemos(for context: HelpContext) -> [InteractiveDemo] {
        return demoManager.generateInteractiveDemos(for: context)
    }
    
    /// Get all available interactive demos
    func getAllInteractiveDemos() -> [HelpContext: [InteractiveDemo]] {
        return demoManager.getAllInteractiveDemos()
    }
    
    /// Check if demos are available for a context
    func hasDemosAvailable(for context: HelpContext) -> Bool {
        return demoManager.hasDemosAvailable(for: context)
    }
    
    /// Get demo count for a context
    func getDemoCount(for context: HelpContext) -> Int {
        return demoManager.getDemoCount(for: context)
    }
    
    // MARK: - Content Availability
    
    /// Check if multimedia content (video or demos) is available for a context
    func hasMultimediaContent(for context: HelpContext) -> Bool {
        return isVideoAvailable(for: context) || hasDemosAvailable(for: context)
    }
    
    /// Check if content is available offline
    func isContentAvailableOffline(for context: HelpContext) -> Bool {
        return videoManager.isContentAvailableOffline(for: context)
    }
    
    /// Get comprehensive content statistics
    func getContentStatistics() -> [String: Any] {
        let videoStats = videoManager.getVideoStatistics()
        let totalContexts = HelpContext.allCases.count
        let demosAvailable = HelpContext.allCases.filter { hasDemosAvailable(for: $0) }.count
        
        return [
            "totalContexts": totalContexts,
            "videosAvailable": videoStats["videosAvailable"] ?? 0,
            "demosAvailable": demosAvailable,
            "multimediaContexts": HelpContext.allCases.filter { hasMultimediaContent(for: $0) }.count,
            "offlineCapable": videoStats["offlineCapable"] ?? 0,
            "accessibilityEnabled": videoStats["accessibilityEnabled"] ?? false
        ]
    }
    
    // MARK: - Accessibility Features
    
    /// Enable accessibility features for all multimedia content
    func enableAccessibilityMode(_ enabled: Bool) {
        videoManager.enableAccessibilityMode(enabled)
        demoManager.enableAccessibilityMode(enabled)
        logger.info("Accessibility mode \(enabled ? "enabled" : "disabled") for multimedia")
    }
    
    /// Set offline mode for multimedia content
    func setOfflineMode(_ enabled: Bool) {
        videoManager.setOfflineMode(enabled)
        logger.info("Offline mode \(enabled ? "enabled" : "disabled") for multimedia")
    }
    
    /// Get accessibility status across all multimedia components
    func getAccessibilityStatus() -> [String: Bool] {
        let videoStatus = videoManager.getAccessibilityStatus()
        let demoAccessible = demoManager.isAccessibilityEnabled()
        
        return [
            "videoAccessibilityMode": videoStatus["accessibilityMode"] ?? false,
            "videoOfflineMode": videoStatus["offlineMode"] ?? false,
            "videoSubtitlesSupported": videoStatus["subtitlesSupported"] ?? false,
            "videoAudioDescriptionSupported": videoStatus["audioDescriptionSupported"] ?? false,
            "demoAccessibilityMode": demoAccessible
        ]
    }
    
    // MARK: - Content Validation
    
    /// Validate multimedia content accessibility for a context
    func validateContentAccessibility(for context: HelpContext) -> [String: Bool] {
        let videoAccessible = videoManager.validateVideoAccessibility(for: context)
        let demoAccessible = hasDemosAvailable(for: context)
        
        return [
            "videoAccessible": videoAccessible,
            "demoAccessible": demoAccessible,
            "anyAccessible": videoAccessible || demoAccessible
        ]
    }
    
    /// Get content size information for a context
    func getContentSizeInfo(for context: HelpContext) -> [String: Any] {
        let videoSize = videoManager.getVideoFileSize(for: context)
        let demoCount = getDemoCount(for: context)
        
        return [
            "videoFileSize": videoSize ?? 0,
            "demoCount": demoCount,
            "hasVideoContent": videoSize != nil,
            "hasDemoContent": demoCount > 0
        ]
    }
    
    // MARK: - Content Discovery
    
    /// Get recommended content type for a context based on user preferences
    func getRecommendedContentType(for context: HelpContext, userPreference: ContentPreference = .balanced) -> MultimediaContentType? {
        let hasVideo = isVideoAvailable(for: context)
        let hasDemos = hasDemosAvailable(for: context)
        
        switch userPreference {
        case .videoPreferred:
            return hasVideo ? .video : (hasDemos ? .demo : nil)
        case .demoPreferred:
            return hasDemos ? .demo : (hasVideo ? .video : nil)
        case .balanced:
            if hasVideo && hasDemos {
                return .both
            } else if hasVideo {
                return .video
            } else if hasDemos {
                return .demo
            } else {
                return nil
            }
        }
    }
    
    /// Get content priority for help context
    func getContentPriority(for context: HelpContext) -> ContentPriority {
        switch context {
        case .splitAllocation, .transactionEntry:
            return .high
        case .taxCategorySelection, .reporting:
            return .medium
        case .analytics, .dashboard, .settings:
            return .low
        }
    }
}

// MARK: - Supporting Types

enum MultimediaContentType {
    case video
    case demo
    case both
}

enum ContentPreference {
    case videoPreferred
    case demoPreferred
    case balanced
}

enum ContentPriority {
    case high
    case medium
    case low
}