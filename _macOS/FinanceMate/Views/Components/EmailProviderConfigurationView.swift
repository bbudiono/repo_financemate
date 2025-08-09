import SwiftUI

/**
 * EmailProviderConfigurationView.swift
 * 
 * Purpose: PHASE 3.3 - Modular email configuration orchestration (now using ProviderSelectionView)
 * Issues & Complexity Summary: Configuration orchestration using ProviderSelectionView and direct controls
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~160 (orchestration only, components handle complexity)
 *   - Core Algorithm Complexity: Low (configuration coordination and date range management)
 *   - Dependencies: 4 (SwiftUI, ProviderSelectionView, date handling, configuration binding)
 *   - State Management Complexity: Medium (configuration state, date ranges, options)
 *   - Novelty/Uncertainty Factor: Low (configuration orchestration patterns)
 * AI Pre-Task Self-Assessment: 95% (simplified through component extraction)
 * Problem Estimate: 84% (reduced complexity through modular architecture)
 * Initial Code Complexity Estimate: 78% (orchestration benefits)
 * Target Coverage: Configuration integration testing with provider coordination
 * Australian Compliance: Email provider security, configuration persistence
 * Last Updated: 2025-08-08
 */

/// Modular email provider configuration orchestration view
/// Uses ProviderSelectionView component to maintain <200 line rule
struct EmailProviderConfigurationView: View {
    
    // MARK: - Properties
    
    @Binding var selectedProvider: SupportedEmailProvider
    @Binding var customSearchTerms: String
    @Binding var selectedDateRange: DateInterval
    @Binding var includeAttachments: Bool
    @Binding var autoCategorizationEnabled: Bool
    
    let onConfigurationChanged: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Provider selection component (modular)
            ProviderSelectionView(selectedProvider: $selectedProvider) {
                onConfigurationChanged()
            }
            
            // Date range configuration
            dateRangeSection
            
            // Search and filtering options
            searchAndFilteringSection
            
            // Processing options
            processingOptionsSection
        }
        .modifier(GlassmorphismModifier(.secondary))
    }
    
    // MARK: - Date Range Section
    
    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Processing Date Range")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                DatePicker("From", selection: Binding(
                    get: { selectedDateRange.start },
                    set: { newDate in
                        selectedDateRange = DateInterval(start: newDate, end: selectedDateRange.end)
                        onConfigurationChanged()
                    }
                ), displayedComponents: .date)
                .datePickerStyle(.compact)
                
                Text("to")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                DatePicker("To", selection: Binding(
                    get: { selectedDateRange.end },
                    set: { newDate in
                        selectedDateRange = DateInterval(start: selectedDateRange.start, end: newDate)
                        onConfigurationChanged()
                    }
                ), displayedComponents: .date)
                .datePickerStyle(.compact)
            }
            
            // Quick date range options
            HStack {
                quickDateRangeButton("Last 30 Days", days: 30)
                quickDateRangeButton("Last 90 Days", days: 90)
                quickDateRangeButton("This Year", isCurrentYear: true)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func quickDateRangeButton(_ title: String, days: Int? = nil, isCurrentYear: Bool = false) -> some View {
        Button(title) {
            let endDate = Date()
            let startDate: Date
            
            if let days = days {
                startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
            } else if isCurrentYear {
                let calendar = Calendar.current
                let year = calendar.component(.year, from: endDate)
                startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? endDate
            } else {
                startDate = endDate
            }
            
            selectedDateRange = DateInterval(start: startDate, end: endDate)
            onConfigurationChanged()
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .font(.caption)
    }
    
    // MARK: - Search and Filtering Section
    
    private var searchAndFilteringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search & Filtering")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("Custom search terms (optional)", text: $customSearchTerms)
                .textFieldStyle(.roundedBorder)
                .onChange(of: customSearchTerms) { _ in
                    onConfigurationChanged()
                }
            
            Text("Examples: \"receipt\", \"invoice\", \"purchase\", \"payment\"")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Filter toggles
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Include email attachments", isOn: $includeAttachments)
                    .onChange(of: includeAttachments) { _ in
                        onConfigurationChanged()
                    }
                
                Toggle("Auto-categorize transactions", isOn: $autoCategorizationEnabled)
                    .onChange(of: autoCategorizationEnabled) { _ in
                        onConfigurationChanged()
                    }
            }
            .font(.caption)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Processing Options Section
    
    private var processingOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Processing Options")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                processingOption("Process up to 100 emails per batch")
                processingOption("Skip emails larger than 5MB")
                processingOption("Timeout after 30 seconds per email")
                processingOption("Maintain processing history for 90 days")
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func processingOption(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.blue)
                .frame(width: 4, height: 4)
                .padding(.top, 4)
            
            Text(text)
                .font(.caption2)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#Preview {
    EmailProviderConfigurationView(
        selectedProvider: .constant(.gmail),
        customSearchTerms: .constant("receipt"),
        selectedDateRange: .constant(DateInterval(start: Date().addingTimeInterval(-30*24*60*60), end: Date())),
        includeAttachments: .constant(true),
        autoCategorizationEnabled: .constant(true)
    ) {
        print("Configuration changed")
    }
}