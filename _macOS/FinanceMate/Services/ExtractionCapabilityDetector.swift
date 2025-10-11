import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Detects device capabilities for intelligent extraction
/// BLUEPRINT Section 3.1.1.4: Device Capability Detection
struct ExtractionCapabilityDetector {

    struct Capabilities {
        let macOSVersion: String
        let appleIntelligenceEnabled: Bool
        let foundationModelsAvailable: Bool
        let chipType: String
        let strategy: ExtractionStrategy
    }

    enum ExtractionStrategy: String {
        case foundationModels = "Foundation Models (83% accuracy)"
        case regexOnly = "Regex Only (54% accuracy)"
    }

    /// Detect extraction capabilities on current device
    static func detect() -> Capabilities {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let macOSVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"

        var appleIntelligenceEnabled = false
        var foundationModelsAvailable = false

        // Check Foundation Models availability (macOS 26+ only)
        if #available(macOS 26.0, *) {
            #if canImport(FoundationModels)
            switch SystemLanguageModel.default.availability {
            case .available:
                appleIntelligenceEnabled = true
                foundationModelsAvailable = true
            case .unavailable(.appleIntelligenceNotEnabled):
                appleIntelligenceEnabled = false
            case .unavailable(.deviceNotEligible):
                appleIntelligenceEnabled = false
            case .unavailable(.modelNotReady):
                appleIntelligenceEnabled = true  // Enabled but not ready
            @unknown default:
                appleIntelligenceEnabled = false
            }
            #endif
        }

        // Get chip type
        let chipType = getChipType()

        // Determine strategy
        let strategy: ExtractionStrategy = foundationModelsAvailable ? .foundationModels : .regexOnly

        return Capabilities(
            macOSVersion: macOSVersionString,
            appleIntelligenceEnabled: appleIntelligenceEnabled,
            foundationModelsAvailable: foundationModelsAvailable,
            chipType: chipType,
            strategy: strategy
        )
    }

    private static func getChipType() -> String {
        var size = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var value = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &value, &size, nil, 0)
        let chipString = String(cString: value)

        if chipString.contains("M1") { return "M1" }
        if chipString.contains("M2") { return "M2" }
        if chipString.contains("M3") { return "M3" }
        if chipString.contains("M4") { return "M4" }
        return "Unknown"
    }

    /// Persist detection results (BLUEPRINT Line 161: Store alert shown flag)
    static func persistDetectionResults(_ capabilities: Capabilities) {
        UserDefaults.standard.set(true, forKey: "HasShownCapabilityAlert")
    }

    /// Check if capability alert has been shown
    static func hasShownCapabilityAlert() -> Bool {
        return UserDefaults.standard.bool(forKey: "HasShownCapabilityAlert")
    }
}
