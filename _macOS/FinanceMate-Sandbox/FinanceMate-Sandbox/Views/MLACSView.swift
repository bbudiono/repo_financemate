// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  MLACSView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: MLACS (Multi-LLM Agent Coordination System) main user interface
* Features: Model discovery, agent management, system capabilities, setup wizard
* UX Focus: Intuitive navigation, clear status indicators, accessible controls
*/

import SwiftUI

struct MLACSView: View {
    @StateObject private var singleAgentMode = MLACSSingleAgentMode(
        systemAnalyzer: SystemCapabilityAnalyzer(),
        modelEngine: LocalModelRecommendationEngine(systemAnalyzer: SystemCapabilityAnalyzer()),
        upgradeEngine: UpgradeSuggestionEngine()
    )
    @StateObject private var modelDiscovery = MLACSModelDiscovery()
    @State private var selectedTab: MLACSTab = .overview
    @State private var showingSetupWizard = false
    @State private var discoveryResults: ModelDiscoveryResults?
    @State private var systemCapabilities: SystemCapabilityProfile?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            // Sidebar with MLACS sections
            List(MLACSTab.allCases, id: \.self, selection: $selectedTab) { tab in
                NavigationLink(value: tab) {
                    Label(tab.title, systemImage: tab.systemImage)
                }
                .help(tab.description)
            }
            .navigationTitle("MLACS")
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
            
            // Main content area
            Group {
                switch selectedTab {
                case .overview:
                    MLACSOverviewView(
                        systemCapabilities: systemCapabilities,
                        discoveryResults: discoveryResults,
                        onRefresh: refreshSystemData
                    )
                case .modelDiscovery:
                    MLACSModelDiscoveryView(
                        discoveryResults: discoveryResults,
                        onRefresh: refreshModelDiscovery,
                        onSetupModel: { showingSetupWizard = true }
                    )
                case .systemAnalysis:
                    MLACSSystemAnalysisView(
                        systemCapabilities: systemCapabilities,
                        onRefresh: refreshSystemCapabilities
                    )
                case .setupWizard:
                    MLACSSetupWizardView(
                        systemCapabilities: systemCapabilities,
                        availableModels: discoveryResults?.availableModels ?? [],
                        onComplete: handleSetupComplete
                    )
                case .agentManagement:
                    MLACSAgentManagementSandboxView(
                        systemCapabilities: systemCapabilities,
                        availableModels: discoveryResults?.availableModels ?? [],
                        onConfigureAgent: configureAgent
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(selectedTab.title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                        
                        Button("Refresh") {
                            refreshSystemData()
                        }
                        .help("Refresh MLACS data")
                        
                        Button("Setup Wizard") {
                            showingSetupWizard = true
                        }
                        .help("Launch model setup wizard")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSetupWizard) {
            MLACSSetupWizardView(
                systemCapabilities: systemCapabilities,
                availableModels: discoveryResults?.availableModels ?? [],
                onComplete: handleSetupComplete
            )
        }
        .alert("MLACS Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            refreshSystemData()
        }
    }
    
    // MARK: - Actions
    
    private func refreshSystemData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                async let capabilities = try SystemCapabilityAnalyzer().analyzeSystemCapabilities()
                async let discovery = try modelDiscovery.discoverAllAvailableModels()
                
                let (cap, disc) = try await (capabilities, discovery)
                
                await MainActor.run {
                    systemCapabilities = cap
                    discoveryResults = disc
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to refresh system data: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func refreshSystemCapabilities() {
        Task {
            do {
                let capabilities = try SystemCapabilityAnalyzer().analyzeSystemCapabilities()
                await MainActor.run {
                    systemCapabilities = capabilities
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to refresh system capabilities: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func refreshModelDiscovery() {
        Task {
            do {
                let discovery = try modelDiscovery.discoverAllAvailableModels()
                await MainActor.run {
                    discoveryResults = discovery
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to refresh model discovery: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func configureAgent() {
        // Navigate to agent configuration
        selectedTab = .agentManagement
    }
    
    private func handleSetupComplete() {
        showingSetupWizard = false
        refreshSystemData()
    }
}

// MARK: - Overview View

struct MLACSOverviewView: View {
    let systemCapabilities: SystemCapabilityProfile?
    let discoveryResults: ModelDiscoveryResults?
    let onRefresh: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Welcome section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.title)
                            .foregroundColor(.blue)
                        Text("Multi-LLM Agent Coordination System")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Text("MLACS provides intelligent local AI model management with hardware optimization and seamless upgrade paths to multi-agent collaboration.")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(10)
                
                // System status cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    SystemStatusCard(
                        title: "System Capabilities",
                        value: systemCapabilities != nil ? "Analyzed" : "Loading...",
                        icon: "cpu",
                        color: .green,
                        details: systemCapabilities.map { formatSystemDetails($0) }
                    )
                    
                    ModelStatusCard(
                        title: "Local Models",
                        installedCount: discoveryResults?.installedModels.count ?? 0,
                        availableCount: discoveryResults?.availableModels.count ?? 0,
                        icon: "externaldrive.connected",
                        color: .blue
                    )
                    
                    ProviderStatusCard(
                        title: "LLM Providers",
                        providerCount: discoveryResults?.installedProviders.count ?? 0,
                        icon: "network",
                        color: .purple
                    )
                    
                    RecommendationCard(
                        title: "Recommendations",
                        count: discoveryResults?.recommendedModels.count ?? 0,
                        icon: "star",
                        color: .orange
                    )
                }
                
                // Quick actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        MLACSQuickActionButton(
                            title: "Discover Models",
                            icon: "magnifyingglass",
                            action: onRefresh
                        )
                        
                        MLACSQuickActionButton(
                            title: "Setup Wizard",
                            icon: "wand.and.stars",
                            action: { /* Will be handled by parent */ }
                        )
                        
                        MLACSQuickActionButton(
                            title: "System Analysis",
                            icon: "chart.bar.xaxis",
                            action: onRefresh
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private func formatSystemDetails(_ capabilities: SystemCapabilityProfile) -> String {
        return "\(capabilities.cpuCores) cores, \(capabilities.totalRAM/1024)GB RAM, \(capabilities.storageSpace/1024)GB storage"
    }
}

// MARK: - Model Discovery View

struct MLACSModelDiscoveryView: View {
    let discoveryResults: ModelDiscoveryResults?
    let onRefresh: () -> Void
    let onSetupModel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Model Discovery")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Refresh Discovery") {
                    onRefresh()
                }
                .help("Refresh model discovery")
            }
            
            if let results = discoveryResults {
                // Tabs for different model categories
                TabView {
                    ModelListView(
                        title: "Installed Models",
                        models: results.installedModels,
                        emptyMessage: "No models installed. Use the setup wizard to install your first model.",
                        onSetupModel: onSetupModel
                    )
                    .tabItem {
                        Label("Installed", systemImage: "checkmark.circle")
                    }
                    
                    ModelListView(
                        title: "Available Models", 
                        models: results.availableModels.filter { !$0.isInstalled },
                        emptyMessage: "No additional models available for installation.",
                        onSetupModel: onSetupModel
                    )
                    .tabItem {
                        Label("Available", systemImage: "arrow.down.circle")
                    }
                    
                    ModelListView(
                        title: "Recommended Models",
                        models: results.recommendedModels,
                        emptyMessage: "No model recommendations available. Check system capabilities.",
                        onSetupModel: onSetupModel
                    )
                    .tabItem {
                        Label("Recommended", systemImage: "star.circle")
                    }
                }
                .frame(minHeight: 400)
            } else {
                VStack {
                    ProgressView("Discovering models...")
                    Text("Scanning for local LLM providers and available models")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }
}

// MARK: - System Analysis View

struct MLACSSystemAnalysisView: View {
    let systemCapabilities: SystemCapabilityProfile?
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("System Analysis")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Refresh Analysis") {
                    onRefresh()
                }
            }
            
            if let capabilities = systemCapabilities {
                SystemCapabilitiesDetailView(capabilities: capabilities)
            } else {
                VStack {
                    ProgressView("Analyzing system...")
                    Text("Detecting hardware capabilities and performance profile")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }
}

// MARK: - Setup Wizard View

struct MLACSSetupWizardView: View {
    let systemCapabilities: SystemCapabilityProfile?
    let availableModels: [DiscoveredModel]
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedModel: DiscoveredModel?
    @State private var setupStep: MLACSSetupStep = .modelSelection
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress indicator
                ProgressIndicatorView(currentStep: setupStep)
                
                // Step content
                switch setupStep {
                case .modelSelection:
                    ModelSelectionStepView(
                        availableModels: availableModels,
                        systemCapabilities: systemCapabilities,
                        selectedModel: $selectedModel
                    )
                case .systemCheck:
                    SystemCheckStepView(
                        selectedModel: selectedModel,
                        systemCapabilities: systemCapabilities
                    )
                case .installation:
                    InstallationStepView(selectedModel: selectedModel)
                case .completion:
                    CompletionStepView()
                }
                
                // Navigation buttons
                HStack {
                    Button("Back") {
                        previousStep()
                    }
                    .disabled(setupStep == .modelSelection)
                    
                    Spacer()
                    
                    Button(setupStep == .completion ? "Done" : "Next") {
                        if setupStep == .completion {
                            onComplete()
                            dismiss()
                        } else {
                            nextStep()
                        }
                    }
                    .disabled(setupStep == .modelSelection && selectedModel == nil)
                }
                .padding()
            }
            .navigationTitle("MLACS Setup Wizard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func nextStep() {
        switch setupStep {
        case .modelSelection:
            setupStep = .systemCheck
        case .systemCheck:
            setupStep = .installation
        case .installation:
            setupStep = .completion
        case .completion:
            break
        }
    }
    
    private func previousStep() {
        switch setupStep {
        case .modelSelection:
            break
        case .systemCheck:
            setupStep = .modelSelection
        case .installation:
            setupStep = .systemCheck
        case .completion:
            setupStep = .installation
        }
    }
}

// MARK: - Agent Management Sandbox View

struct MLACSAgentManagementSandboxView: View {
    let systemCapabilities: SystemCapabilityProfile?
    let availableModels: [DiscoveredModel]
    let onConfigureAgent: () -> Void
    
    @StateObject private var agentManager = MLACSAgentManager()
    @State private var showingCreateAgent = false
    @State private var showingAgentDetails = false
    @State private var selectedAgent: ManagedAgent?
    @State private var showingConfiguration = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Agent Management")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Create Agent") {
                    showingCreateAgent = true
                }
                .help("Create a new AI agent")
                .disabled(availableModels.filter { $0.isInstalled }.isEmpty)
            }
            
            // Content
            if agentManager.agents.isEmpty {
                EmptyAgentManagementView(
                    onCreateAgent: { showingCreateAgent = true },
                    hasInstalledModels: !availableModels.filter { $0.isInstalled }.isEmpty
                )
            } else {
                AgentListView(
                    agents: Array(agentManager.agents.values).sorted { $0.createdDate > $1.createdDate },
                    onSelectAgent: { agent in
                        selectedAgent = agent
                        showingAgentDetails = true
                    },
                    onConfigureAgent: { agent in
                        selectedAgent = agent
                        showingConfiguration = true
                    },
                    agentManager: agentManager
                )
            }
        }
        .padding()
        .sheet(isPresented: $showingCreateAgent) {
            CreateAgentView(
                availableModels: availableModels.filter { $0.isInstalled },
                systemCapabilities: systemCapabilities,
                agentManager: agentManager,
                onComplete: {
                    showingCreateAgent = false
                }
            )
        }
        .sheet(isPresented: $showingAgentDetails) {
            if let agent = selectedAgent {
                AgentDetailView(
                    agent: agent,
                    agentManager: agentManager,
                    onDismiss: {
                        showingAgentDetails = false
                        selectedAgent = nil
                    }
                )
            }
        }
        .sheet(isPresented: $showingConfiguration) {
            if let agent = selectedAgent {
                AgentConfigurationView(
                    agent: agent,
                    agentManager: agentManager,
                    onComplete: {
                        showingConfiguration = false
                        selectedAgent = nil
                    }
                )
            }
        }
        .alert("Agent Management Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

// MARK: - Supporting Views

struct SystemStatusCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let details: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            if let details = details {
                Text(details)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct ModelStatusCard: View {
    let title: String
    let installedCount: Int
    let availableCount: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(installedCount)/\(availableCount)")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Installed / Available")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct ProviderStatusCard: View {
    let title: String
    let providerCount: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(providerCount)")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(providerCount == 1 ? "Provider detected" : "Providers detected")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct RecommendationCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(count)")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Available")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct MLACSQuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .help(title)
    }
}

// MARK: - Tab Definition

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
    
    var systemImage: String {
        switch self {
        case .overview: return "house"
        case .modelDiscovery: return "magnifyingglass"
        case .systemAnalysis: return "chart.bar.xaxis"
        case .setupWizard: return "wand.and.stars"
        case .agentManagement: return "person.3"
        }
    }
    
    var description: String {
        switch self {
        case .overview: return "MLACS system overview and quick actions"
        case .modelDiscovery: return "Discover and manage local AI models"
        case .systemAnalysis: return "Analyze system capabilities and performance"
        case .setupWizard: return "Guided setup for new models and agents"
        case .agentManagement: return "Configure and manage AI agents"
        }
    }
}

// MARK: - Placeholder Views

struct ModelListView: View {
    let title: String
    let models: [DiscoveredModel]
    let emptyMessage: String
    let onSetupModel: () -> Void
    
    var body: some View {
        VStack {
            if models.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "externaldrive.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(emptyMessage)
                        .foregroundColor(.secondary)
                    Button("Launch Setup Wizard") {
                        onSetupModel()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(models, id: \.modelId) { model in
                    ModelRowView(model: model)
                }
            }
        }
    }
}

struct ModelRowView: View {
    let model: DiscoveredModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.name)
                    .fontWeight(.medium)
                Text(model.provider)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(model.parameterCount / 1_000_000_000)B params")
                    .font(.caption)
                Text("\(model.memoryRequirementMB)MB")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if model.isInstalled {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SystemCapabilitiesDetailView: View {
    let capabilities: SystemCapabilityProfile
    
    var body: some View {
        // Placeholder for system capabilities detail view
        VStack {
            Text("System capabilities details will be shown here")
                .foregroundColor(.secondary)
        }
    }
}

struct ProgressIndicatorView: View {
    let currentStep: MLACSSetupStep
    
    var body: some View {
        // Placeholder for progress indicator
        HStack {
            ForEach(MLACSSetupStep.allCases, id: \.self) { step in
                Circle()
                    .fill(step.rawValue <= currentStep.rawValue ? Color.blue : Color.gray)
                    .frame(width: 12, height: 12)
                if step != MLACSSetupStep.allCases.last {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 2)
                }
            }
        }
    }
}

struct ModelSelectionStepView: View {
    let availableModels: [DiscoveredModel]
    let systemCapabilities: SystemCapabilityProfile?
    @Binding var selectedModel: DiscoveredModel?
    
    var body: some View {
        VStack {
            Text("Select a model to install")
                .font(.title3)
            // Model selection UI
        }
    }
}

struct SystemCheckStepView: View {
    let selectedModel: DiscoveredModel?
    let systemCapabilities: SystemCapabilityProfile?
    
    var body: some View {
        VStack {
            Text("System compatibility check")
                .font(.title3)
            // System check UI
        }
    }
}

struct InstallationStepView: View {
    let selectedModel: DiscoveredModel?
    
    var body: some View {
        VStack {
            Text("Installing model...")
                .font(.title3)
            ProgressView()
        }
    }
}

struct CompletionStepView: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            Text("Setup Complete!")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}

struct AgentStatusView: View {
    let agent: LocalAIAgent
    
    var body: some View {
        VStack {
            Text("Agent: \(agent.modelName)")
                .font(.title3)
            // Agent status UI
        }
    }
}

struct EmptyAgentManagementView: View {
    let onCreateAgent: () -> Void
    let hasInstalledModels: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Agents Created")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(hasInstalledModels ? 
                     "Create your first AI agent to get started with MLACS." :
                     "Install a local model first, then create your first AI agent.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if hasInstalledModels {
                Button("Create First Agent") {
                    onCreateAgent()
                }
                .buttonStyle(.borderedProminent)
                .help("Create your first AI agent")
            } else {
                VStack(spacing: 12) {
                    Text("No installed models available")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("Visit Model Discovery to install a model first")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AgentListView: View {
    let agents: [ManagedAgent]
    let onSelectAgent: (ManagedAgent) -> Void
    let onConfigureAgent: (ManagedAgent) -> Void
    let agentManager: MLACSAgentManager
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(agents, id: \.id) { agent in
                    AgentCardView(
                        agent: agent,
                        onSelect: { onSelectAgent(agent) },
                        onConfigure: { onConfigureAgent(agent) },
                        onToggleActive: {
                            do {
                                if agent.isActive {
                                    try agentManager.deactivateAgent(id: agent.id)
                                } else {
                                    try agentManager.activateAgent(id: agent.id)
                                }
                            } catch {
                                print("Failed to toggle agent: \(error)")
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
}

struct AgentCardView: View {
    let agent: ManagedAgent
    let onSelect: () -> Void
    let onConfigure: () -> Void
    let onToggleActive: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(agent.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(agent.modelName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(agent.isActive ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
            }
            
            // Configuration details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Specialization:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(agent.configuration.specialization.rawValue.capitalized)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Memory:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(agent.configuration.memoryLimit)MB")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Created:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(agent.createdDate, style: .date)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
            }
            
            // Action buttons
            HStack(spacing: 8) {
                Button(agent.isActive ? "Deactivate" : "Activate") {
                    onToggleActive()
                }
                .buttonStyle(.bordered)
                .font(.caption)
                
                Button("Configure") {
                    onConfigure()
                }
                .buttonStyle(.bordered)
                .font(.caption)
                
                Spacer()
                
                Button("Details") {
                    onSelect()
                }
                .buttonStyle(.borderedProminent)
                .font(.caption)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(agent.isActive ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}

// Placeholder views for sheet presentations
struct CreateAgentView: View {
    let availableModels: [DiscoveredModel]
    let systemCapabilities: SystemCapabilityProfile?
    let agentManager: MLACSAgentManager
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedModel: DiscoveredModel?
    @State private var agentName = ""
    @State private var selectedPersonality: AgentPersonality = .professional
    @State private var selectedSpecialization: AgentSpecialization = .general
    @State private var creativityLevel: Double = 0.5
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Agent Details")) {
                    TextField("Agent Name", text: $agentName)
                    
                    Picker("Model", selection: $selectedModel) {
                        Text("Select Model").tag(nil as DiscoveredModel?)
                        ForEach(availableModels, id: \.modelId) { model in
                            Text("\(model.name) - \(model.provider)").tag(model as DiscoveredModel?)
                        }
                    }
                    
                    Picker("Personality", selection: $selectedPersonality) {
                        ForEach(AgentPersonality.allCases, id: \.self) { personality in
                            Text(personality.rawValue.capitalized).tag(personality)
                        }
                    }
                    
                    Picker("Specialization", selection: $selectedSpecialization) {
                        ForEach(AgentSpecialization.allCases, id: \.self) { specialization in
                            Text(specialization.rawValue.capitalized).tag(specialization)
                        }
                    }
                }
                
                Section(header: Text("Configuration")) {
                    VStack(alignment: .leading) {
                        Text("Creativity Level: \(creativityLevel, specifier: "%.1f")")
                        Slider(value: $creativityLevel, in: 0...1)
                    }
                }
            }
            .navigationTitle("Create Agent")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createAgent()
                    }
                    .disabled(agentName.isEmpty || selectedModel == nil || isCreating)
                }
            }
        }
    }
    
    private func createAgent() {
        guard let model = selectedModel,
              let capabilities = systemCapabilities else { return }
        
        isCreating = true
        
        do {
            let configuration = AgentConfiguration(
                name: agentName,
                personality: selectedPersonality,
                specialization: selectedSpecialization,
                responseStyle: .balanced,
                creativityLevel: creativityLevel,
                safetyLevel: .high,
                memoryLimit: min(model.memoryRequirementMB, capabilities.availableRAM),
                contextWindowSize: 4096,
                customInstructions: ""
            )
            
            _ = try agentManager.createAgent(
                from: model,
                configuration: configuration,
                systemCapabilities: capabilities
            )
            
            onComplete()
            dismiss()
        } catch {
            print("Failed to create agent: \(error)")
        }
        
        isCreating = false
    }
}

struct AgentDetailView: View {
    let agent: ManagedAgent
    let agentManager: MLACSAgentManager
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Agent Details Placeholder")
                        .font(.title2)
                    Text("Detailed agent information will be shown here")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle(agent.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct AgentConfigurationView: View {
    let agent: ManagedAgent
    let agentManager: MLACSAgentManager
    let onComplete: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Agent Configuration Placeholder")
                        .font(.title2)
                    Text("Agent configuration options will be shown here")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Configure \(agent.name)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        onComplete()
                    }
                }
            }
        }
    }
}

enum MLACSSetupStep: Int, CaseIterable {
    case modelSelection = 0
    case systemCheck = 1
    case installation = 2
    case completion = 3
}

// MARK: - Preview

struct MLACSView_Previews: PreviewProvider {
    static var previews: some View {
        MLACSView()
            .frame(width: 1000, height: 700)
    }
}