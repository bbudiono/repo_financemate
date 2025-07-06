import SwiftUI
import Foundation

/*
* Purpose: LineItemEntryView for adding and managing line items with glassmorphism styling and Australian locale formatting
* Issues & Complexity Summary: SwiftUI form with real-time validation, accessibility support, and LineItemViewModel integration
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~350
  - Core Algorithm Complexity: Medium (Form validation, real-time feedback)
  - Dependencies: 4 (SwiftUI, Foundation, LineItemViewModel, GlassmorphismModifier)
  - State Management Complexity: Medium (@State properties with validation)
  - Novelty/Uncertainty Factor: Medium (Complex form with real-time validation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
* Problem Estimate (Inherent Problem Difficulty %): 85%
* Initial Code Complexity Estimate %: 80%
* Justification for Estimates: SwiftUI form with glassmorphism styling, real-time validation, and accessibility compliance
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-07-07
*/

/// SwiftUI view for entering and managing line items with comprehensive validation and accessibility support
struct LineItemEntryView: View {
    @ObservedObject var viewModel: LineItemViewModel
    let transaction: Transaction
    @Binding var isPresented: Bool
    
    @State private var itemDescription: String = ""
    @State private var amount: String = ""
    @State private var showingValidationError: Bool = false
    @State private var validationMessage: String = ""
    @State private var isEditing: Bool = false
    
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case description
        case amount
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient for glassmorphism effect
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.05),
                        Color.blue.opacity(0.03),
                        Color.clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Line Items List Section
                        if !viewModel.lineItems.isEmpty {
                            lineItemsListSection
                        }
                        
                        // Add New Line Item Section
                        addLineItemSection
                        
                        // Summary Section
                        summarySection
                        
                        // Action Buttons
                        actionButtonsSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Line Items")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                    .accessibilityLabel("Close line items view")
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        isPresented = false
                    }
                    .accessibilityLabel("Finish editing line items")
                }
            }
            .task {
                await viewModel.fetchLineItems(for: transaction)
            }
            .alert("Validation Error", isPresented: $showingValidationError) {
                Button("OK") { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transaction Line Items")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Split \(viewModel.formatCurrency(transaction.amount)) across multiple items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .accessibilityLabel("Loading line items")
                }
            }
            
            if let errorMessage = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .accessibilityLabel("Error: \(errorMessage)")
            }
        }
        .modifier(GlassmorphismModifier(style: .secondary, cornerRadius: 16))
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Line Items List Section
    
    private var lineItemsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Line Items")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.lineItems, id: \.id) { lineItem in
                    lineItemRow(lineItem)
                }
            }
        }
        .modifier(GlassmorphismModifier(style: .secondary, cornerRadius: 16))
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
    
    private func lineItemRow(_ lineItem: LineItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lineItem.itemDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("Amount: \(viewModel.formatCurrency(lineItem.amount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if lineItem.splitAllocations.count > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "chart.pie.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("\(lineItem.splitAllocations.count) splits")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Button(action: {
                Task {
                    await viewModel.deleteLineItem(lineItem)
                }
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Delete \(lineItem.itemDescription)")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Add Line Item Section
    
    private var addLineItemSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Line Item")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                // Description Field
                descriptionField
                
                // Amount Field
                amountField
                
                // Add Button
                addButton
            }
        }
        .modifier(GlassmorphismModifier(style: .secondary, cornerRadius: 16))
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
    
    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Description")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(itemDescription.count)/200")
                    .font(.caption)
                    .foregroundColor(itemDescription.count > 200 ? .red : .secondary)
            }
            
            TextField("Enter item description...", text: $itemDescription)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .description)
                .onSubmit {
                    focusedField = .amount
                }
                .onChange(of: itemDescription) { _ in
                    validateInput()
                }
                .accessibilityLabel("Item description")
                .accessibilityHint("Enter a description for this line item")
        }
    }
    
    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Amount (AUD)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !amount.isEmpty, let amountValue = Double(amount) {
                    Text(viewModel.formatCurrency(amountValue))
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            TextField("0.00", text: $amount)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .amount)
                .onChange(of: amount) { _ in
                    validateInput()
                }
                .accessibilityLabel("Amount in Australian dollars")
                .accessibilityHint("Enter the amount for this line item")
        }
    }
    
    private var addButton: some View {
        Button(action: {
            Task {
                await addLineItem()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "plus.circle.fill")
                }
                
                Text("Add Line Item")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isFormValid ? Color.blue : Color.gray.opacity(0.3))
            .foregroundColor(isFormValid ? .white : .gray)
            .cornerRadius(10)
        }
        .disabled(!isFormValid || viewModel.isLoading)
        .accessibilityLabel("Add new line item")
        .accessibilityHint("Adds the line item with entered description and amount")
    }
    
    // MARK: - Summary Section
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                summaryRow(
                    label: "Transaction Total",
                    value: viewModel.formatCurrency(transaction.amount),
                    isTotal: true
                )
                
                summaryRow(
                    label: "Line Items Total",
                    value: viewModel.formatCurrency(viewModel.calculateTotalAmount()),
                    isHighlighted: !isBalanced
                )
                
                summaryRow(
                    label: "Remaining",
                    value: viewModel.formatCurrency(transaction.amount - viewModel.calculateTotalAmount()),
                    isRemaining: true
                )
                
                if !isBalanced {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        Text("Line items don't match transaction total")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .accessibilityLabel("Warning: Line items total does not match transaction amount")
                }
            }
        }
        .modifier(GlassmorphismModifier(style: .secondary, cornerRadius: 16))
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
    
    private func summaryRow(label: String, value: String, isTotal: Bool = false, isHighlighted: Bool = false, isRemaining: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(isTotal ? .subheadline.weight(.semibold) : .subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(isTotal ? .subheadline.weight(.bold) : .subheadline)
                .foregroundColor(
                    isHighlighted ? .orange :
                    isRemaining ? (transaction.amount - viewModel.calculateTotalAmount() < 0 ? .red : .green) :
                    .primary
                )
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                // TODO: Navigate to split allocation view
            }) {
                HStack {
                    Image(systemName: "chart.pie")
                    Text("Manage Split Allocations")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(10)
            }
            .disabled(viewModel.lineItems.isEmpty)
            .accessibilityLabel("Manage split allocations")
            .accessibilityHint("Opens split allocation management for line items")
            
            Button(action: {
                Task {
                    await clearAllLineItems()
                }
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear All Line Items")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(10)
            }
            .disabled(viewModel.lineItems.isEmpty)
            .accessibilityLabel("Clear all line items")
            .accessibilityHint("Removes all line items from this transaction")
        }
        .modifier(GlassmorphismModifier(style: .minimal, cornerRadius: 12))
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        return !itemDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               itemDescription.count <= 200 &&
               !amount.isEmpty &&
               Double(amount) != nil &&
               (Double(amount) ?? 0) > 0
    }
    
    private var isBalanced: Bool {
        let tolerance = 0.01
        return abs(transaction.amount - viewModel.calculateTotalAmount()) < tolerance
    }
    
    // MARK: - Methods
    
    private func validateInput() {
        if !itemDescription.isEmpty && itemDescription.count > 200 {
            validationMessage = "Description must be 200 characters or less"
            showingValidationError = true
            return
        }
        
        if !amount.isEmpty {
            if Double(amount) == nil {
                validationMessage = "Please enter a valid amount"
                showingValidationError = true
                return
            }
            
            if let amountValue = Double(amount), amountValue <= 0 {
                validationMessage = "Amount must be greater than zero"
                showingValidationError = true
                return
            }
        }
    }
    
    private func addLineItem() async {
        guard isFormValid else { return }
        
        guard let amountValue = Double(amount) else {
            validationMessage = "Please enter a valid amount"
            showingValidationError = true
            return
        }
        
        // Check if adding this amount would exceed transaction total
        let newTotal = viewModel.calculateTotalAmount() + amountValue
        if newTotal > transaction.amount {
            validationMessage = "Line items total cannot exceed transaction amount of \(viewModel.formatCurrency(transaction.amount))"
            showingValidationError = true
            return
        }
        
        // Set the view model's new line item data
        viewModel.newLineItem.itemDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.newLineItem.amount = amountValue
        
        // Add the line item
        await viewModel.addLineItem(to: transaction)
        
        // Check for errors
        if let errorMessage = viewModel.errorMessage {
            validationMessage = errorMessage
            showingValidationError = true
            return
        }
        
        // Clear form on success
        itemDescription = ""
        amount = ""
        focusedField = .description
    }
    
    private func clearAllLineItems() async {
        // Delete all line items
        for lineItem in viewModel.lineItems {
            await viewModel.deleteLineItem(lineItem)
        }
    }
}