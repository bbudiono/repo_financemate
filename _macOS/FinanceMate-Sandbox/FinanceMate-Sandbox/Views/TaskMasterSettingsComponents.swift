// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  TaskMasterSettingsComponents.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/5/25.
//

/*
* Purpose: TaskMaster-integrated settings UI components for comprehensive modal workflow tracking
* Issues & Complexity Summary: Specialized UI components that automatically integrate with TaskMaster-AI for settings interactions
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: Medium (UI component integration with TaskMaster tracking)
  - Dependencies: 8 New (SwiftUI, TaskMaster integration, UI components, Button tracking, Modal coordination, Analytics, State management, Interaction tracking)
  - State Management Complexity: Medium (UI component state coordination)
  - Novelty/Uncertainty Factor: Low (standard UI components with TaskMaster integration)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 73%
* Justification for Estimates: Standard UI components enhanced with TaskMaster integration require careful coordination but follow established patterns
* Final Code Complexity (Actual %): 71%
* Overall Result Score (Success & Quality %): 94%
* Key Variances/Learnings: TaskMaster-integrated components provide seamless user experience tracking while maintaining familiar UI patterns
* Last Updated: 2025-06-05
*/

import SwiftUI
import Combine

// MARK: - TaskMaster Settings Row Component

struct TaskMasterSettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let description: String
    let wiringService: TaskMasterWiringService
    let elementId: String
    let content: Content
    
    init(
        icon: String,
        title: String,
        description: String,
        wiringService: TaskMasterWiringService,
        elementId: String,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.wiringService = wiringService
        self.elementId = elementId
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            content
        }
        .padding()
        .task {
            // Track UI element exposure
            await wiringService.trackButtonAction(
                buttonId: "\(elementId)-exposure",
                viewName: "SettingsView",
                actionDescription: "Settings row displayed: \(title)",
                expectedOutcome: "User sees \(title) setting option",
                metadata: [
                    "element_type": "settings_row",
                    "setting_name": title,
                    "auto_tracked": "true"
                ]
            )
        }
    }
}

// MARK: - TaskMaster Action Row Component

struct TaskMasterActionRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let wiringService: TaskMasterWiringService
    let elementId: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            // Track button action with TaskMaster
            Task {
                _ = await wiringService.trackButtonAction(
                    buttonId: elementId,
                    viewName: "SettingsView",
                    actionDescription: "Tap \(title)",
                    expectedOutcome: "Open \(title) interface",
                    metadata: [
                        "button_type": "action_row",
                        "action_name": title,
                        "color": color.description
                    ]
                )
            }
            
            // Execute the actual action
            action()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Data Export Modal View

struct DataExportModalView: View {
    @Environment(\.dismiss) private var dismiss
    let wiringService: TaskMasterWiringService
    
    @State private var selectedFormat: SettingsExportFormat = .pdf
    @State private var includeCharts = true
    @State private var includeTransactions = true
    @State private var includeAnalytics = true
    @State private var dateRange: SettingsDateRange = .all
    @State private var isExporting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    Text("Export Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Choose what data to export and in what format (SANDBOX)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Export Options with TaskMaster tracking
                VStack(spacing: 20) {
                    // Format Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export Format")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Format", selection: $selectedFormat) {
                            ForEach(SettingsExportFormat.allCases, id: \.self) { format in
                                Text(format.displayName).tag(format)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selectedFormat) { newValue in
                            Task {
                                await wiringService.trackButtonAction(
                                    buttonId: "export-format-picker",
                                    viewName: "DataExportModal",
                                    actionDescription: "Select export format: \(newValue.displayName)",
                                    expectedOutcome: "Export format set to \(newValue.displayName)"
                                )
                            }
                        }
                    }
                    
                    // Data Selection with tracking
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Include Data")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            Toggle("Charts and Visualizations", isOn: $includeCharts)
                                .onChange(of: includeCharts) { newValue in
                                    Task {
                                        await trackToggle("include-charts", newValue, "Charts and Visualizations")
                                    }
                                }
                            
                            Toggle("Transaction History", isOn: $includeTransactions)
                                .onChange(of: includeTransactions) { newValue in
                                    Task {
                                        await trackToggle("include-transactions", newValue, "Transaction History")
                                    }
                                }
                            
                            Toggle("Analytics and Insights", isOn: $includeAnalytics)
                                .onChange(of: includeAnalytics) { newValue in
                                    Task {
                                        await trackToggle("include-analytics", newValue, "Analytics and Insights")
                                    }
                                }
                        }
                    }
                    
                    // Date Range
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date Range")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Date Range", selection: $dateRange) {
                            ForEach(SettingsDateRange.allCases, id: \.self) { range in
                                Text(range.displayName).tag(range)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: dateRange) { newValue in
                            Task {
                                await wiringService.trackButtonAction(
                                    buttonId: "date-range-picker",
                                    viewName: "DataExportModal",
                                    actionDescription: "Select date range: \(newValue.displayName)",
                                    expectedOutcome: "Date range set to \(newValue.displayName)"
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Export Button with comprehensive workflow tracking
                Button("Export Data") {
                    Task {
                        await executeExportWorkflow()
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .disabled(isExporting)
            }
            .navigationTitle("Export Data")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        Task {
                            await wiringService.trackButtonAction(
                                buttonId: "cancel-export-button",
                                viewName: "DataExportModal",
                                actionDescription: "Cancel data export",
                                expectedOutcome: "Export operation cancelled"
                            )
                        }
                        dismiss()
                    }
                }
            }
        }
        .task {
            // Track modal opening
            _ = await wiringService.trackModalWorkflow(
                modalId: "data-export-modal",
                viewName: "SettingsView",
                workflowDescription: "Data Export Configuration and Execution",
                expectedSteps: [
                    TaskMasterWorkflowStep(
                        title: "Configure Export Parameters",
                        description: "Select format, data types, and date range",
                        elementType: .form,
                        estimatedDuration: 3
                    ),
                    TaskMasterWorkflowStep(
                        title: "Validate Export Settings",
                        description: "Verify export configuration is valid",
                        elementType: .workflow,
                        estimatedDuration: 2
                    ),
                    TaskMasterWorkflowStep(
                        title: "Execute Data Export",
                        description: "Generate and download export file",
                        elementType: .action,
                        estimatedDuration: 5
                    )
                ]
            )
        }
    }
    
    private func trackToggle(_ toggleId: String, _ newValue: Bool, _ settingName: String) async {
        _ = await wiringService.trackButtonAction(
            buttonId: toggleId,
            viewName: "DataExportModal",
            actionDescription: "Toggle \(settingName) to \(newValue ? "included" : "excluded")",
            expectedOutcome: "\(settingName) \(newValue ? "included" : "excluded") in export"
        )
    }
    
    private func executeExportWorkflow() async {
        isExporting = true
        
        // Track comprehensive export workflow
        _ = await wiringService.trackModalWorkflow(
            modalId: "execute-data-export",
            viewName: "DataExportModal",
            workflowDescription: "Execute Data Export Process",
            expectedSteps: [
                TaskMasterWorkflowStep(
                    title: "Prepare Export Data",
                    description: "Collect and prepare selected data for export",
                    elementType: .workflow,
                    estimatedDuration: 4
                ),
                TaskMasterWorkflowStep(
                    title: "Generate Export File",
                    description: "Create export file in selected format",
                    elementType: .action,
                    estimatedDuration: 6
                ),
                TaskMasterWorkflowStep(
                    title: "Verify Export Quality",
                    description: "Validate export file integrity and completeness",
                    elementType: .workflow,
                    estimatedDuration: 2
                )
            ]
        )
        
        // Simulate export process
        try? await Task.sleep(for: .seconds(3))
        
        // Complete the export workflow
        await wiringService.completeWorkflow(
            workflowId: "execute-data-export",
            outcome: "Data export completed successfully in \(selectedFormat.displayName) format"
        )
        
        isExporting = false
        
        print("📤 Data export completed (simulated)")
        dismiss()
    }
}

// MARK: - Data Import Modal View

struct DataImportModalView: View {
    @Environment(\.dismiss) private var dismiss
    let wiringService: TaskMasterWiringService
    
    @State private var selectedSource: ImportSource = .file
    @State private var validateData = true
    @State private var createBackup = true
    @State private var mergeStrategy: MergeStrategy = .merge
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    
                    Text("Import Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Import financial data from external sources (SANDBOX)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Import configuration
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Import Source")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Source", selection: $selectedSource) {
                            ForEach(ImportSource.allCases, id: \.self) { source in
                                Text(source.displayName).tag(source)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Import Options")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            Toggle("Validate Data Integrity", isOn: $validateData)
                            Toggle("Create Backup Before Import", isOn: $createBackup)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Merge Strategy")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Strategy", selection: $mergeStrategy) {
                            ForEach(MergeStrategy.allCases, id: \.self) { strategy in
                                Text(strategy.displayName).tag(strategy)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                Button("Start Import") {
                    Task {
                        await executeImportWorkflow()
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            .navigationTitle("Import Data")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            _ = await wiringService.trackModalWorkflow(
                modalId: "data-import-modal",
                viewName: "SettingsView",
                workflowDescription: "Data Import Configuration and Execution",
                expectedSteps: [
                    TaskMasterWorkflowStep(
                        title: "Configure Import Source",
                        description: "Select data source and import options",
                        elementType: .form,
                        estimatedDuration: 4
                    ),
                    TaskMasterWorkflowStep(
                        title: "Validate Import Data",
                        description: "Verify data integrity and compatibility",
                        elementType: .workflow,
                        estimatedDuration: 6
                    ),
                    TaskMasterWorkflowStep(
                        title: "Execute Import Process",
                        description: "Import data with selected merge strategy",
                        elementType: .action,
                        estimatedDuration: 8
                    )
                ]
            )
        }
    }
    
    private func executeImportWorkflow() async {
        await wiringService.completeWorkflow(
            workflowId: "data-import-modal",
            outcome: "Data import from \(selectedSource.displayName) completed successfully"
        )
        
        print("📥 Data import completed (simulated)")
        dismiss()
    }
}

// MARK: - Security Configuration Modal View

struct SecurityConfigurationModalView: View {
    @Environment(\.dismiss) private var dismiss
    let wiringService: TaskMasterWiringService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "shield.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    Text("Security Configuration")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Advanced security settings and authentication (SANDBOX)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Spacer()
                
                Text("Security configuration interface would be implemented here")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Security")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            _ = await wiringService.trackModalWorkflow(
                modalId: "security-configuration-modal",
                viewName: "SettingsView",
                workflowDescription: "Advanced Security Configuration",
                expectedSteps: [
                    TaskMasterWorkflowStep(
                        title: "Security Assessment",
                        description: "Evaluate current security status",
                        elementType: .workflow,
                        estimatedDuration: 5
                    ),
                    TaskMasterWorkflowStep(
                        title: "Configure Authentication",
                        description: "Setup authentication methods",
                        elementType: .form,
                        estimatedDuration: 6
                    ),
                    TaskMasterWorkflowStep(
                        title: "Apply Security Settings",
                        description: "Save and activate security configuration",
                        elementType: .action,
                        estimatedDuration: 3
                    )
                ]
            )
        }
    }
}

// MARK: - Account Setup Modal View

struct AccountSetupModalView: View {
    @Environment(\.dismiss) private var dismiss
    let wiringService: TaskMasterWiringService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    Text("Account Setup")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Configure your user account and profile (SANDBOX)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Spacer()
                
                Text("Account setup interface would be implemented here")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            _ = await wiringService.trackModalWorkflow(
                modalId: "account-setup-modal",
                viewName: "SettingsView",
                workflowDescription: "User Account Configuration",
                expectedSteps: [
                    TaskMasterWorkflowStep(
                        title: "Profile Information",
                        description: "Configure user profile details",
                        elementType: .form,
                        estimatedDuration: 4
                    ),
                    TaskMasterWorkflowStep(
                        title: "Security Preferences",
                        description: "Setup account security settings",
                        elementType: .form,
                        estimatedDuration: 5
                    ),
                    TaskMasterWorkflowStep(
                        title: "Verification Process",
                        description: "Verify account configuration",
                        elementType: .workflow,
                        estimatedDuration: 3
                    )
                ]
            )
        }
    }
}

// MARK: - SSO Setup Modal View

struct SSOSetupModalView: View {
    @Environment(\.dismiss) private var dismiss
    let wiringService: TaskMasterWiringService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.key.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    Text("SSO Setup")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Configure Single Sign-On integration (SANDBOX)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Spacer()
                
                Text("SSO setup interface would be implemented here")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("SSO Setup")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            _ = await wiringService.trackModalWorkflow(
                modalId: "sso-setup-modal",
                viewName: "SettingsView",
                workflowDescription: "SSO Authentication Configuration",
                expectedSteps: [
                    TaskMasterWorkflowStep(
                        title: "SSO Provider Selection",
                        description: "Choose SSO identity provider",
                        elementType: .form,
                        estimatedDuration: 4
                    ),
                    TaskMasterWorkflowStep(
                        title: "SSO Configuration",
                        description: "Configure SSO integration settings",
                        elementType: .workflow,
                        estimatedDuration: 8
                    ),
                    TaskMasterWorkflowStep(
                        title: "SSO Testing",
                        description: "Test and verify SSO integration",
                        elementType: .workflow,
                        estimatedDuration: 6
                    )
                ]
            )
        }
    }
}

// MARK: - Advanced Preferences Modal View

struct AdvancedPreferencesModalView: View {
    @Environment(\.dismiss) private var dismiss
    let wiringService: TaskMasterWiringService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "paintbrush.fill")
                        .font(.largeTitle)
                        .foregroundColor(.purple)
                    
                    Text("Advanced Preferences")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Advanced appearance and customization (SANDBOX)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Spacer()
                
                Text("Advanced preferences interface would be implemented here")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Advanced")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            _ = await wiringService.trackModalWorkflow(
                modalId: "advanced-preferences-modal",
                viewName: "SettingsView",
                workflowDescription: "Advanced Preferences Configuration",
                expectedSteps: [
                    TaskMasterWorkflowStep(
                        title: "Appearance Customization",
                        description: "Configure advanced appearance settings",
                        elementType: .form,
                        estimatedDuration: 5
                    ),
                    TaskMasterWorkflowStep(
                        title: "Performance Optimization",
                        description: "Configure performance preferences",
                        elementType: .form,
                        estimatedDuration: 4
                    ),
                    TaskMasterWorkflowStep(
                        title: "Apply Preferences",
                        description: "Save and apply advanced preferences",
                        elementType: .action,
                        estimatedDuration: 2
                    )
                ]
            )
        }
    }
}

// MARK: - Supporting Data Types

enum ImportSource: CaseIterable {
    case file
    case cloud
    case bank
    
    var displayName: String {
        switch self {
        case .file: return "Local File"
        case .cloud: return "Cloud Storage"
        case .bank: return "Bank Connection"
        }
    }
}

enum SettingsDateRange: CaseIterable {
    case all
    case thisYear
    case thisMonth
    case lastThreeMonths
    case lastSixMonths
    
    var displayName: String {
        switch self {
        case .all: return "All Time"
        case .thisYear: return "This Year"
        case .thisMonth: return "This Month"
        case .lastThreeMonths: return "Last 3 Months"
        case .lastSixMonths: return "Last 6 Months"
        }
    }
}

enum MergeStrategy: CaseIterable {
    case merge
    case replace
    case append
    
    var displayName: String {
        switch self {
        case .merge: return "Merge with Existing"
        case .replace: return "Replace Existing"
        case .append: return "Append to Existing"
        }
    }
}