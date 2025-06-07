// PRODUCTION FILE: Migrated from sandbox for FinanceMate production

//
//  LocalModelRecommendationEngine.swift
//  FinanceMate
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Intelligent local model recommendation engine for MLACS
* Features: Hardware-optimized model suggestions, performance estimation, use-case matching
* NO MOCK DATA: Uses real model database and system analysis for recommendations
*/

import Foundation

// MARK: - Local Model Recommendation Engine

public class LocalModelRecommendationEngine {
    
    // MARK: - Dependencies
    
    private let systemAnalyzer: SystemCapabilityAnalyzer
    private let modelDatabase: LocalModelDatabase
    
    // MARK: - Initialization
    
    public init(systemAnalyzer: SystemCapabilityAnalyzer) {
        self.systemAnalyzer = systemAnalyzer
        self.modelDatabase = LocalModelDatabase()
    }
    
    // MARK: - Public Methods
    
    public func recommendOptimalModels(systemProfile: SystemCapabilityProfile) throws -> [ModelRecommendation] {
        let availableModels = modelDatabase.getAllModels()
        var recommendations: [ModelRecommendation] = []
        
        for model in availableModels {
            let suitabilityScore = calculateSuitabilityScore(model: model, system: systemProfile)
            
            // Only include models that are reasonably suitable (score > 0.3)
            if suitabilityScore > 0.3 {
                let recommendation = ModelRecommendation(
                    model: model,
                    suitabilityScore: suitabilityScore,
                    expectedPerformance: estimatePerformance(model: model, system: systemProfile),
                    downloadTime: estimateDownloadTime(model: model, internetSpeed: systemProfile.internetSpeed),
                    useCases: getModelUseCases(model: model),
                    pros: getModelPros(model: model, system: systemProfile),
                    limitations: getModelLimitations(model: model, system: systemProfile),
                    alternativeOptions: []
                )
                recommendations.append(recommendation)
            }
        }
        
        // Sort by suitability score (descending)
        recommendations.sort { $0.suitabilityScore > $1.suitabilityScore }
        
        // Add alternative options to top recommendations
        for i in 0..<min(3, recommendations.count) {
            recommendations[i] = addAlternativeOptions(to: recommendations[i], from: recommendations)
        }
        
        return recommendations
    }
    
    public func getCategorizedModels() throws -> CategorizedModels {
        let allModels = modelDatabase.getAllModels()
        
        let ultraLight = allModels.filter { $0.parameterCount <= 3_000_000_000 }
        let lightweight = allModels.filter { $0.parameterCount > 3_000_000_000 && $0.parameterCount <= 7_000_000_000 }
        let balanced = allModels.filter { $0.parameterCount > 7_000_000_000 && $0.parameterCount <= 15_000_000_000 }
        let highPerformance = allModels.filter { $0.parameterCount > 15_000_000_000 }
        
        return CategorizedModels(
            ultraLight: ModelCategory(
                recommended: Array(ultraLight.prefix(3)),
                description: "Fast responses, basic capabilities, minimal resources",
                systemRequirements: "4GB RAM, any CPU",
                useCases: ["simple Q&A", "basic writing", "quick help"]
            ),
            lightweight: ModelCategory(
                recommended: Array(lightweight.prefix(3)),
                description: "Good balance of capability and speed",
                systemRequirements: "8GB RAM, modern CPU",
                useCases: ["general chat", "writing assistance", "simple coding"]
            ),
            balanced: ModelCategory(
                recommended: Array(balanced.prefix(3)),
                description: "High capability, moderate resource usage",
                systemRequirements: "16GB RAM, good CPU/GPU",
                useCases: ["complex reasoning", "coding", "research"]
            ),
            highPerformance: ModelCategory(
                recommended: Array(highPerformance.prefix(3)),
                description: "Maximum capability, requires powerful hardware",
                systemRequirements: "32GB+ RAM, GPU recommended",
                useCases: ["advanced reasoning", "complex coding", "research"]
            )
        )
    }
    
    // MARK: - Private Methods
    
    private func calculateSuitabilityScore(model: LocalAIModel, system: SystemCapabilityProfile) -> Double {
        var score = 0.0
        
        // Memory compatibility (40% weight)
        let memoryScore = calculateMemoryCompatibility(model: model, system: system)
        score += memoryScore * 0.4
        
        // Performance class compatibility (30% weight)
        let performanceScore = calculatePerformanceCompatibility(model: model, system: system)
        score += performanceScore * 0.3
        
        // Download feasibility (15% weight)
        let downloadScore = calculateDownloadFeasibility(model: model, system: system)
        score += downloadScore * 0.15
        
        // Use case alignment (15% weight)
        let useCaseScore = calculateUseCaseAlignment(model: model)
        score += useCaseScore * 0.15
        
        return min(1.0, max(0.0, score))
    }
    
    private func calculateMemoryCompatibility(model: LocalAIModel, system: SystemCapabilityProfile) -> Double {
        let memoryRatio = Double(model.memoryRequirement) / Double(system.availableRAM)
        
        if memoryRatio <= 0.6 {
            return 1.0 // Excellent memory fit
        } else if memoryRatio <= 0.8 {
            return 0.8 // Good memory fit
        } else if memoryRatio <= 1.0 {
            return 0.4 // Tight but workable
        } else {
            return 0.0 // Won't fit
        }
    }
    
    private func calculatePerformanceCompatibility(model: LocalAIModel, system: SystemCapabilityProfile) -> Double {
        let modelComplexity = getModelComplexity(parameterCount: model.parameterCount)
        
        switch system.performanceClass {
        case .low:
            switch modelComplexity {
            case .simple: return 1.0
            case .moderate: return 0.6
            case .complex: return 0.2
            case .veryComplex: return 0.0
            }
        case .medium:
            switch modelComplexity {
            case .simple: return 0.8
            case .moderate: return 1.0
            case .complex: return 0.7
            case .veryComplex: return 0.3
            }
        case .high:
            switch modelComplexity {
            case .simple: return 0.7
            case .moderate: return 0.9
            case .complex: return 1.0
            case .veryComplex: return 0.8
            }
        case .extreme:
            return 1.0 // Can handle any model
        }
    }
    
    private func calculateDownloadFeasibility(model: LocalAIModel, system: SystemCapabilityProfile) -> Double {
        let downloadSizeGB = Double(model.downloadSizeMB) / 1024.0
        let storageGB = Double(system.storageSpace) / 1024.0
        
        // Check if there's enough storage (need 2x model size for extraction)
        if downloadSizeGB * 2 > storageGB {
            return 0.0
        }
        
        // Score based on internet speed and download size
        if system.internetSpeed == 0 {
            return 0.3 // Offline installation possible but limited
        }
        
        let downloadTimeMinutes = (downloadSizeGB * 1024 * 8) / Double(system.internetSpeed) / 60
        
        if downloadTimeMinutes <= 5 {
            return 1.0
        } else if downloadTimeMinutes <= 15 {
            return 0.8
        } else if downloadTimeMinutes <= 30 {
            return 0.6
        } else {
            return 0.4
        }
    }
    
    private func calculateUseCaseAlignment(model: LocalAIModel) -> Double {
        // Score based on model capabilities and general usefulness
        let capabilityCount = model.capabilities.count
        let maxCapabilities = 8.0 // Assume max 8 capabilities
        
        return min(1.0, Double(capabilityCount) / maxCapabilities)
    }
    
    private func estimatePerformance(model: LocalAIModel, system: SystemCapabilityProfile) -> PerformanceEstimate {
        let tokensPerSecond = estimateTokensPerSecond(model: model, system: system)
        let memoryUsage = model.memoryRequirement
        let cpuUsage = estimateCPUUsage(model: model, system: system)
        
        return PerformanceEstimate(
            tokensPerSecond: tokensPerSecond,
            memoryUsageMB: memoryUsage,
            cpuUsagePercent: cpuUsage,
            qualityScore: getModelQualityScore(model: model)
        )
    }
    
    private func estimateTokensPerSecond(model: LocalAIModel, system: SystemCapabilityProfile) -> Double {
        // Base tokens per second estimation based on model size and system capability
        let baseRate = 20.0 // Base rate for small models on medium systems
        
        // Adjust for model complexity
        let complexityMultiplier: Double
        switch getModelComplexity(parameterCount: model.parameterCount) {
        case .simple: complexityMultiplier = 2.0
        case .moderate: complexityMultiplier = 1.0
        case .complex: complexityMultiplier = 0.5
        case .veryComplex: complexityMultiplier = 0.2
        }
        
        // Adjust for system performance
        let systemMultiplier: Double
        switch system.performanceClass {
        case .low: systemMultiplier = 0.5
        case .medium: systemMultiplier = 1.0
        case .high: systemMultiplier = 2.0
        case .extreme: systemMultiplier = 4.0
        }
        
        return baseRate * complexityMultiplier * systemMultiplier
    }
    
    private func estimateCPUUsage(model: LocalAIModel, system: SystemCapabilityProfile) -> Double {
        // Estimate CPU usage percentage
        let baseUsage = 30.0 // Base CPU usage
        
        let modelComplexityMultiplier: Double
        switch getModelComplexity(parameterCount: model.parameterCount) {
        case .simple: modelComplexityMultiplier = 0.5
        case .moderate: modelComplexityMultiplier = 1.0
        case .complex: modelComplexityMultiplier = 1.5
        case .veryComplex: modelComplexityMultiplier = 2.0
        }
        
        let systemMultiplier = max(0.2, 1.0 / Double(system.cpuCores))
        
        return min(100.0, baseUsage * modelComplexityMultiplier * systemMultiplier)
    }
    
    private func estimateDownloadTime(model: LocalAIModel, internetSpeed: Int) -> TimeEstimate {
        if internetSpeed == 0 {
            return TimeEstimate(estimatedMinutes: 0, description: "Offline installation")
        }
        
        let downloadSizeGB = Double(model.downloadSizeMB) / 1024.0
        let downloadTimeMins = (downloadSizeGB * 1024 * 8) / Double(internetSpeed) / 60
        
        let description: String
        if downloadTimeMins <= 5 {
            description = "Very fast"
        } else if downloadTimeMins <= 15 {
            description = "Fast"
        } else if downloadTimeMins <= 30 {
            description = "Moderate"
        } else {
            description = "Slow"
        }
        
        return TimeEstimate(estimatedMinutes: Int(downloadTimeMins), description: description)
    }
    
    private func getModelUseCases(model: LocalAIModel) -> [String] {
        var useCases: [String] = []
        
        for capability in model.capabilities {
            switch capability {
            case "general":
                useCases.append("General conversation")
            case "coding":
                useCases.append("Code assistance")
            case "writing":
                useCases.append("Writing help")
            case "analysis":
                useCases.append("Data analysis")
            case "research":
                useCases.append("Research support")
            case "creative":
                useCases.append("Creative writing")
            case "math":
                useCases.append("Mathematical reasoning")
            case "translation":
                useCases.append("Language translation")
            default:
                useCases.append(capability.capitalized)
            }
        }
        
        return useCases
    }
    
    private func getModelPros(model: LocalAIModel, system: SystemCapabilityProfile) -> [String] {
        var pros: [String] = []
        
        // Memory efficiency
        let memoryRatio = Double(model.memoryRequirement) / Double(system.availableRAM)
        if memoryRatio <= 0.6 {
            pros.append("Efficient memory usage")
        }
        
        // Download size
        if model.downloadSizeMB <= 2000 {
            pros.append("Quick download")
        }
        
        // Performance
        let complexity = getModelComplexity(parameterCount: model.parameterCount)
        if complexity == .simple || complexity == .moderate {
            pros.append("Fast responses")
        }
        
        // Capabilities
        if model.capabilities.count >= 5 {
            pros.append("Versatile capabilities")
        }
        
        // Quality
        if getModelQualityScore(model: model) >= 0.8 {
            pros.append("High quality responses")
        }
        
        return pros
    }
    
    private func getModelLimitations(model: LocalAIModel, system: SystemCapabilityProfile) -> [String] {
        var limitations: [String] = []
        
        // Memory constraints
        let memoryRatio = Double(model.memoryRequirement) / Double(system.availableRAM)
        if memoryRatio > 0.8 {
            limitations.append("High memory usage")
        }
        
        // Download size
        if model.downloadSizeMB > 5000 {
            limitations.append("Large download size")
        }
        
        // Performance limitations
        let complexity = getModelComplexity(parameterCount: model.parameterCount)
        if complexity == .simple {
            limitations.append("Limited reasoning capability")
        } else if complexity == .veryComplex && system.performanceClass == .low {
            limitations.append("May be slow on this system")
        }
        
        // Capability gaps
        if !model.capabilities.contains("coding") {
            limitations.append("No coding assistance")
        }
        if !model.capabilities.contains("analysis") {
            limitations.append("Limited analytical capabilities")
        }
        
        return limitations
    }
    
    private func addAlternativeOptions(to recommendation: ModelRecommendation, from allRecommendations: [ModelRecommendation]) -> ModelRecommendation {
        let alternatives = allRecommendations
            .filter { $0.model.name != recommendation.model.name }
            .prefix(3)
            .map { $0.model }
        
        return ModelRecommendation(
            model: recommendation.model,
            suitabilityScore: recommendation.suitabilityScore,
            expectedPerformance: recommendation.expectedPerformance,
            downloadTime: recommendation.downloadTime,
            useCases: recommendation.useCases,
            pros: recommendation.pros,
            limitations: recommendation.limitations,
            alternativeOptions: Array(alternatives)
        )
    }
    
    // MARK: - Helper Methods
    
    private func getModelComplexity(parameterCount: Int64) -> ModelComplexity {
        switch parameterCount {
        case 0...3_000_000_000:
            return .simple
        case 3_000_000_001...7_000_000_000:
            return .moderate
        case 7_000_000_001...15_000_000_000:
            return .complex
        default:
            return .veryComplex
        }
    }
    
    private func getModelQualityScore(model: LocalAIModel) -> Double {
        // Simplified quality scoring based on model characteristics
        var score = 0.5 // Base score
        
        // Parameter count contributes to quality
        score += min(0.3, Double(model.parameterCount) / 70_000_000_000.0)
        
        // Capability count contributes to quality
        score += min(0.2, Double(model.capabilities.count) / 10.0)
        
        return min(1.0, score)
    }
}

// MARK: - Supporting Types

public struct ModelRecommendation {
    public let model: LocalAIModel
    public let suitabilityScore: Double
    public let expectedPerformance: PerformanceEstimate
    public let downloadTime: TimeEstimate
    public let useCases: [String]
    public let pros: [String]
    public let limitations: [String]
    public let alternativeOptions: [LocalAIModel]
}

public struct PerformanceEstimate {
    public let tokensPerSecond: Double
    public let memoryUsageMB: Int
    public let cpuUsagePercent: Double
    public let qualityScore: Double
}

public struct TimeEstimate {
    public let estimatedMinutes: Int
    public let description: String
}

public struct CategorizedModels {
    public let ultraLight: ModelCategory
    public let lightweight: ModelCategory
    public let balanced: ModelCategory
    public let highPerformance: ModelCategory
}

public struct ModelCategory {
    public let recommended: [LocalAIModel]
    public let description: String
    public let systemRequirements: String
    public let useCases: [String]
}

public enum ModelComplexity {
    case simple
    case moderate
    case complex
    case veryComplex
}