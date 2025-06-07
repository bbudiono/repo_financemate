//
//  MLACSView.swift
//  FinanceMate
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
                    MLACSAgentManagementView(
                        currentAgent: singleAgentMode.currentAgent,
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

// MARK: - Agent Management View

struct MLACSAgentManagementView: View {
    let currentAgent: LocalAIAgent?
    let onConfigureAgent: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Agent Management")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let agent = currentAgent {
                AgentStatusView(agent: agent)
            } else {
                EmptyAgentView(onConfigureAgent: onConfigureAgent)
            }
        }
        .padding()
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

struct EmptyAgentView: View {
    let onConfigureAgent: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No agent configured")
                .font(.title3)
            Button("Configure Agent") {
                onConfigureAgent()
            }
            .buttonStyle(.borderedProminent)
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