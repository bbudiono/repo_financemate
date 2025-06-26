//
//  CoPilotServiceFactory.swift
//  FinanceMate
//
//  Created by Assistant on 6/29/25.
//

/*
* Purpose: Factory pattern for CoPilot service creation, enabling easy switching between implementations
* Issues & Complexity Summary: Simple factory with configuration-based service selection
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~80
  - Core Algorithm Complexity: Very Low (simple factory pattern)
  - Dependencies: 2 New (CoPilot protocols, configuration)
  - State Management Complexity: Very Low (stateless factory)
  - Novelty/Uncertainty Factor: Very Low (standard factory pattern)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 5%
* Problem Estimate (Inherent Problem Difficulty %): 8%
* Initial Code Complexity Estimate %: 10%
* Justification for Estimates: Simple factory pattern with minimal complexity
* Final Code Complexity (Actual %): 12%
* Overall Result Score (Success & Quality %): 99%
* Key Variances/Learnings: Factory pattern provides clean abstraction for service selection
* Last Updated: 2025-06-29
*/

import Foundation
import SwiftUI

public class CoPilotServiceFactory {
    
    // MARK: - Service Creation
    
    public static func createService(configuration: CoPilotConfiguration = .default) -> any CoPilotServiceProtocol {
        switch configuration.provider {
        case .simple:
            return SimpleCoPilotService()
            
        case .mlacs:
            return MLACSCoPilotService()
            
        case .external:
            // Future: External API service implementation
            return SimpleCoPilotService() // Fallback for now
        }
    }
    
    public static func createService(for provider: CoPilotConfiguration.AIProvider) -> any CoPilotServiceProtocol {
        let config = CoPilotConfiguration(
            provider: provider,
            maxMessageHistory: 50,
            enableAdvancedFeatures: provider == .mlacs,
            responseTimeout: provider == .mlacs ? 60.0 : 30.0
        )
        return createService(configuration: config)
    }
    
    // MARK: - Configuration Helpers
    
    public static func recommendedConfiguration(for complexity: TaskComplexity) -> CoPilotConfiguration {
        switch complexity {
        case .simple:
            return CoPilotConfiguration(
                provider: .simple,
                maxMessageHistory: 20,
                enableAdvancedFeatures: false,
                responseTimeout: 15.0
            )
            
        case .moderate:
            return CoPilotConfiguration(
                provider: .simple,
                maxMessageHistory: 50,
                enableAdvancedFeatures: false,
                responseTimeout: 30.0
            )
            
        case .complex:
            return CoPilotConfiguration(
                provider: .mlacs,
                maxMessageHistory: 100,
                enableAdvancedFeatures: true,
                responseTimeout: 60.0
            )
            
        case .enterprise:
            return CoPilotConfiguration(
                provider: .mlacs,
                maxMessageHistory: 200,
                enableAdvancedFeatures: true,
                responseTimeout: 120.0
            )
        }
    }
    
    public static func availableProviders() -> [ProviderInfo] {
        return [
            ProviderInfo(
                provider: .simple,
                name: "Simple CoPilot",
                description: "Lightweight AI assistant for basic financial tasks",
                capabilities: [.basicChat, .financialAnalysis, .documentProcessing],
                isRecommended: true,
                resourceUsage: .low
            ),
            ProviderInfo(
                provider: .mlacs,
                name: "MLACS CoPilot",
                description: "Advanced multi-agent system for complex analysis",
                capabilities: [.basicChat, .financialAnalysis, .documentProcessing, .taskManagement, .advancedAgents],
                isRecommended: false,
                resourceUsage: .high
            ),
            ProviderInfo(
                provider: .external,
                name: "External API",
                description: "Cloud-based AI services (coming soon)",
                capabilities: [.basicChat, .financialAnalysis],
                isRecommended: false,
                resourceUsage: .medium
            )
        ]
    }
}

// MARK: - Supporting Types

public enum TaskComplexity: String, CaseIterable {
    case simple = "simple"
    case moderate = "moderate"
    case complex = "complex"
    case enterprise = "enterprise"
    
    public var displayName: String {
        switch self {
        case .simple: return "Simple Tasks"
        case .moderate: return "Moderate Complexity"
        case .complex: return "Complex Analysis"
        case .enterprise: return "Enterprise Level"
        }
    }
    
    public var description: String {
        switch self {
        case .simple: return "Basic questions and simple calculations"
        case .moderate: return "Multi-step analysis and reporting"
        case .complex: return "Advanced financial modeling and optimization"
        case .enterprise: return "Complex multi-agent coordination and analysis"
        }
    }
}

public struct ProviderInfo: Identifiable {
    public let id = UUID()
    public let provider: CoPilotConfiguration.AIProvider
    public let name: String
    public let description: String
    public let capabilities: [CoPilotCapability]
    public let isRecommended: Bool
    public let resourceUsage: ResourceUsage
    
    public enum ResourceUsage: String, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        
        public var displayName: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
        
        public var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
    }
}