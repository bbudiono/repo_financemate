import SwiftUI
import CoreData

/**
 * EmailReceiptProcessingView.swift
 * 
 * Purpose: PHASE 3.3 - Modular email receipt processing interface using extracted components
 * Issues & Complexity Summary: Orchestration view using modular components for maintainability
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~180 (orchestration only, components handle complexity)
 *   - Core Algorithm Complexity: Low (component coordination and state management)
 *   - Dependencies: 6 Modular (3 extracted components + EmailReceiptViewModel + SwiftUI + glassmorphism)
 *   - State Management Complexity: Medium (reduced through component extraction)
 *   - Novelty/Uncertainty Factor: Low (modular architecture patterns)
 * AI Pre-Task Self-Assessment: 95% (simplified through modular breakdown)
 * Problem Estimate: 82% (reduced complexity through component extraction)
 * Initial Code Complexity Estimate: 78% (modular architecture benefits)
 * Target Coverage: Component integration testing with glassmorphism compliance
 * Australian Compliance: Privacy UI through PrivacyConsentView component
 * Last Updated: 2025-08-08
 */

/// Modular email receipt processing interface implementing BLUEPRINT "HIGHEST PRIORITY" requirement
/// Orchestrates PrivacyConsentView, EmailProviderConfigurationView, and EmailProcessingResultsView components
struct EmailReceiptProcessingView: View {
    
    // MARK: - Dependencies
    
    @StateObject private var viewModel: EmailReceiptViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - UI State
    
    @State private var showingHelpSheet = false
    @State private var selectedTransactions: Set<UUID> = []
    @State private var showingExportOptions = false
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        let processor = EmailReceiptProcessor(
            context: context,
            visionOCREngine: VisionOCREngine(),
            ocrService: OCRService(),
            transactionMatcher: OCRTransactionMatcher(context: context)
        )
        
        self._viewModel = StateObject(wrappedValue: EmailReceiptViewModel(
            context: context,
            emailProcessor: processor
        ))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header section
                    headerSection
                    
                    // Privacy consent component (modular)
                    if !viewModel.privacyConsentGiven {
                        PrivacyConsentView(
                            privacyConsentGiven: $viewModel.privacyConsentGiven,
                            privacyOptionalConsents: $viewModel.privacyOptionalConsents,
                            onConsentUpdate: {
                                // Handle consent updates if needed
                            }
                        )
                    } else {
                        // Email provider configuration component (modular)
                        EmailProviderConfigurationView(
                            selectedProvider: $viewModel.selectedProvider,
                            customSearchTerms: $viewModel.customSearchTerms,
                            selectedDateRange: $viewModel.selectedDateRange,
                            includeAttachments: $viewModel.includeAttachments,
                            autoCategorizationEnabled: $viewModel.autoCategorizationEnabled,
                            onConfigurationChanged: {
                                // Handle configuration updates if needed
                            }
                        )
                        
                        // Processing section (simplified)
                        processingSection
                        
                        // Results component (modular)
                        if viewModel.showingResults {
                            EmailProcessingResultsView(
                                processingResult: viewModel.processingResult,
                                selectedTransactions: $selectedTransactions,
                                showingExportOptions: $showingExportOptions,
                                onTransactionSelection: { receipt in
                                    // Handle transaction selection
                                },
                                onBulkAction: { action in
                                    handleBulkAction(action)
                                }
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Email Receipts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Help") {
                        showingHelpSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingHelpSheet) {
            helpSheet
        }
        .sheet(isPresented: $showingExportOptions) {
            exportOptionsSheet
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") {
                viewModel.successMessage = nil
            }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "envelope.open")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("Email Receipt Processing")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("HIGHEST PRIORITY FEATURE")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            
            Text("Automatically extract receipts and invoices from your emails and match them with existing transactions.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .modifier(GlassmorphismModifier(.primary))
    }
    
    // MARK: - Processing Section (Simplified)
    
    private var processingSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Processing")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if viewModel.isProcessing {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            
            if viewModel.isProcessing {
                VStack(spacing: 12) {
                    ProgressView(value: viewModel.processingProgress)
                        .progressViewStyle(.linear)
                    
                    Text("Processing emails... \(Int(viewModel.processingProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Button("Start Processing") {
                    Task {
                        await viewModel.startProcessing()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canStartProcessing)
            }
        }
        .modifier(GlassmorphismModifier(.accent))
    }
    
    // MARK: - Bulk Action Handler
    
    private func handleBulkAction(_ action: EmailProcessingResultsView.BulkAction) {
        switch action {
        case .createTransactions:
            createSelectedTransactions()
        case .exportSelected:
            showingExportOptions = true
        case .reviewAll:
            // Handle review all action
            break
        case .deleteSelected:
            deleteSelectedReceipts()
        }
    }
    
    private func createSelectedTransactions() {
        // Implementation for creating transactions from selected receipts
        Task {
            await viewModel.createTransactions(for: selectedTransactions)
        }
    }
    
    private func deleteSelectedReceipts() {
        // Implementation for deleting selected receipts
        selectedTransactions.removeAll()
    }
    
    // MARK: - Sheet Views
    
    private var helpSheet: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Email Receipt Processing Help")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This feature automatically extracts financial information from your email receipts and creates transaction records in FinanceMate.")
                        .font(.body)
                    
                    Text("Features:")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Automatic OCR text extraction from receipt images")
                        Text("• Intelligent transaction matching and categorization")
                        Text("• Privacy-compliant email processing")
                        Text("• Support for Gmail, Outlook, and iCloud Mail")
                        Text("• Bulk transaction creation and export")
                    }
                    .font(.body)
                }
                .padding()
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingHelpSheet = false
                    }
                }
            }
        }
    }
    
    private var exportOptionsSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Options")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose how you'd like to export your processed receipts:")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Button("Export as CSV") {
                    // Handle CSV export
                    showingExportOptions = false
                }
                .buttonStyle(.borderedProminent)
                
                Button("Export as PDF Report") {
                    // Handle PDF export
                    showingExportOptions = false
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingExportOptions = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    EmailReceiptProcessingView(context: PersistenceController.preview.container.viewContext)
}