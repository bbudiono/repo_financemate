//
//  MLACSManager.swift
//  FinanceMate
//
//  Created by Assistant on 6/9/25.
//

/*
* Purpose: MLACS (Multi-LLM Agent Coordination System) Manager
* Part of monolithic file refactoring following Manager pattern
* Handles: State management, business logic, and coordination for MLACS system
*/

import Combine
import SwiftUI

@MainActor
class MLACSManager: ObservableObject {
    // MARK: - Published Properties

    @Published var selectedTab: MLACSTab = .overview
    @Published var showingSetupWizard = false
    @Published var discoveryResults: ModelDiscoveryResults?
    @Published var systemCapabilities: SystemCapabilityProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let singleAgentMode: MLACSSingleAgentMode
    private let modelDiscovery: MLACSModelDiscovery
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        self.singleAgentMode = MLACSSingleAgentMode(
            systemAnalyzer: SystemCapabilityAnalyzer(),
            modelEngine: LocalModelRecommendationEngine(systemAnalyzer: SystemCapabilityAnalyzer()),
            upgradeEngine: UpgradeSuggestionEngine()
        )
        self.modelDiscovery = MLACSModelDiscovery()

        setupBindings()
    }

    // MARK: - Public Methods

    func startDiscovery() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let results = try await modelDiscovery.discoverModels()
                await MainActor.run {
                    self.discoveryResults = results
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Discovery failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    func performSystemAnalysis() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let capabilities = try await singleAgentMode.systemAnalyzer.analyzeSystem()
                await MainActor.run {
                    self.systemCapabilities = capabilities
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "System analysis failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    func launchSetupWizard() {
        showingSetupWizard = true
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Future: Add any necessary bindings between components
    }
}

// MARK: - MLACSTab Enum

enum MLACSTab: String, CaseIterable {
    case overview = "overview"
    case modelDiscovery = "modelDiscovery"
    case systemAnalysis = "systemAnalysis"
    case setupWizard = "setupWizard"
    case agentManagement = "agentManagement"

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .modelDiscovery: return "Model Discovery"
        case .systemAnalysis: return "System Analysis"
        case .setupWizard: return "Setup Wizard"
        case .agentManagement: return "Agent Management"
        }
    }

    var icon: String {
        switch self {
        case .overview: return "chart.line.uptrend.xyaxis"
        case .modelDiscovery: return "magnifyingglass.circle"
        case .systemAnalysis: return "chart.bar.xaxis"
        case .setupWizard: return "wand.and.stars"
        case .agentManagement: return "person.3.fill"
        }
    }
}
