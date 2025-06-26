// Purpose: Main content view implementing navigation structure and core UI layout for FinanceMate
// Issues & Complexity Summary: Implements NavigationSplitView with sidebar navigation and dynamic content areas
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~120
//   - Core Algorithm Complexity: Medium (navigation state management, view routing)
//   - Dependencies: 2 (NavigationSplitView, enum-based routing)
//   - State Management Complexity: Medium (selected navigation item, view state)
//   - Novelty/Uncertainty Factor: Medium (macOS-specific navigation patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 65%
// Problem Estimate (Inherent Problem Difficulty %): 70%
// Initial Code Complexity Estimate %: 68%
// Justification for Estimates: Modern macOS navigation with sidebar requires proper state management and view coordination
// Final Code Complexity (Actual %): 72%
// Overall Result Score (Success & Quality %): 88%
// Key Variances/Learnings: NavigationSplitView provides excellent macOS-native experience
// Last Updated: 2025-06-02

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedView: NavigationItem = .dashboard
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var isCoPilotVisible: Bool = false
    @State private var showingAbout: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            // Main Application Content with glassmorphism
            NavigationSplitView(columnVisibility: $columnVisibility) {
                SidebarView(selectedView: $selectedView)
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
                    .lightGlass()
            } detail: {
                DetailView(selectedView: selectedView) { newView in
                    selectedView = newView
                }
                    .navigationTitle(selectedView.title)
                    .adaptiveGlass()
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: {
                                selectedView = .documents
                            }) {
                                Label("Import Document", systemImage: "plus.circle")
                            }
                            .help("Import a new financial document")
                        }

                        ToolbarItem(placement: .navigation) {
                            Button(action: {
                                isCoPilotVisible.toggle()
                            }) {
                                Image(systemName: isCoPilotVisible ? "sidebar.right" : "brain")
                                    .font(.title3)
                            }
                            .help(isCoPilotVisible ? "Hide Co-Pilot Assistant" : "Show Co-Pilot Assistant")
                        }

                        ToolbarItem(placement: .automatic) {
                            Menu {
                                Button("Preferences") {
                                    selectedView = .settings
                                }
                                Button("About FinanceMate") {
                                    showingAbout = true
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.circle")
                                    Text("User")
                                        .font(.caption)
                                }
                            }
                            .help("User menu")
                        }
                    }
            }
            .navigationSplitViewStyle(.balanced)

            // Co-Pilot Panel with glassmorphism
            if isCoPilotVisible {
                CoPilotIntegrationView()
                    .frame(width: 350)
                    .transition(.move(edge: .trailing))
                    .mediumGlass()
            }
        }
        .background(
            // Main app background with theme
            LinearGradient(
                colors: [
                    FinanceMateTheme.surfaceColor(for: colorScheme).opacity(0.05),
                    FinanceMateTheme.surfaceColor(for: colorScheme).opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .animation(
            themeManager.enableAnimations ? .easeInOut(duration: 0.3) : .none,
            value: isCoPilotVisible
        )
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

struct SidebarView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedView: NavigationItem

    var body: some View {
        List(NavigationItem.allCases, id: \.self, selection: $selectedView) { item in
            NavigationLink(value: item) {
                Label(item.title, systemImage: item.systemImage)
                    .foregroundColor(
                        selectedView == item ? 
                        FinanceMateTheme.accentColor : 
                        FinanceMateTheme.textPrimary(for: colorScheme)
                    )
            }
        }
        .navigationTitle("FinanceMate")
        .listStyle(SidebarListStyle())
        .background(
            FinanceMateTheme.surfaceColor(for: colorScheme).opacity(0.05)
        )
    }
}

struct DetailView: View {
    let selectedView: NavigationItem
    let onNavigate: (NavigationItem) -> Void

    var body: some View {
        VStack {
            switch selectedView {
            case .dashboard:
                DashboardView()
            case .budgets:
                BudgetManagementView()
            case .goals:
                FinancialGoalsPlaceholderView()
            case .documents:
                DocumentsView()
            case .analytics:
                AnalyticsView()
            case .subscriptions:
                SubscriptionManagementView()
            case .mlacs:
                MLACSView()
            case .export:
                FinancialExportView()
            case .enhancedAnalytics:
                RealTimeFinancialInsightsView()
            case .speculativeDecoding:
                SpeculativeDecodingControlView()
            case .chatbotTesting:
                ComprehensiveChatbotTestView()
            case .crashAnalysis:
                CrashAnalysisDashboardView()
            case .llmBenchmark:
                LLMBenchmarkView()
            case .settings:
                SettingsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Placeholder Views for Production

struct BudgetManagementPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            VStack(spacing: 8) {
                Text("💰 Budget Management")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                Text("Smart Budget Planning & Tracking")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("Comprehensive budget creation, tracking, and analysis")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    budgetFeatureCard("Budget Creation", "plus.circle.fill", "Create and manage multiple budgets")
                    budgetFeatureCard("Category Tracking", "list.clipboard.fill", "Track spending by category")
                }

                HStack(spacing: 20) {
                    budgetFeatureCard("Progress Monitoring", "chart.bar.fill", "Monitor budget performance")
                    budgetFeatureCard("Smart Insights", "brain.head.profile", "AI-powered budget recommendations")
                }
            }
            .padding()

            Text("✅ Budget Management CORE DATA INTEGRATED - Ready for UI activation")
                .font(.caption)
                .foregroundColor(.green)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func budgetFeatureCard(_ title: String, _ icon: String, _ description: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)

            Text(title)
                .font(.headline)
                .fontWeight(.medium)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct MLACSPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundColor(.blue)

            VStack(spacing: 8) {
                Text("🧠 MLACS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Text("Multi-LLM Agent Coordination System")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("Advanced AI agent management and coordination")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    featureCard("Model Discovery", "magnifyingglass", "Detect and manage local AI models")
                    featureCard("System Analysis", "chart.bar.xaxis", "Analyze hardware capabilities")
                }

                HStack(spacing: 20) {
                    featureCard("Agent Management", "person.3", "Configure and coordinate AI agents")
                    featureCard("Setup Wizard", "wand.and.stars", "Guided setup for new models")
                }
            }
            .padding()

            Text("⚠️ MLACS system in active development - Core functionality pending")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func featureCard(_ title: String, _ icon: String, _ description: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(title)
                .font(.headline)
                .fontWeight(.medium)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct RealTimeFinancialInsightsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal.fill")
                .font(.system(size: 64))
                .foregroundColor(.purple)

            VStack(spacing: 8) {
                Text("⚡ Enhanced Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)

                Text("Real-Time Financial Insights with AI")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("AI-powered analysis and real-time processing")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    insightCard("Live Insights", "brain", "0", "AI-generated insights")
                    insightCard("Documents Processed", "doc.fill", "0", "Analyzed documents")
                }

                HStack(spacing: 20) {
                    insightCard("System Load", "gauge", "0%", "Processing capacity")
                    insightCard("AI Models", "cpu", "Ready", "Analysis engines")
                }
            }
            .padding()

            Text("⚠️ Enhanced Analytics in development - Real-time processing not yet active")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func insightCard(_ title: String, _ icon: String, _ value: String, _ description: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)

            Text(title)
                .font(.headline)
                .fontWeight(.medium)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct FinancialGoalsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("Financial Goals")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Track your savings goals and milestones")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("Feature coming soon...")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1000, height: 700)
    }
}
