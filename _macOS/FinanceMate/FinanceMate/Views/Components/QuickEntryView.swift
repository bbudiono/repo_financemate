import Speech
import SwiftUI

struct QuickEntryView: View {
    @StateObject private var quickEntryService = QuickEntryService()
    @State private var inputText = ""
    @State private var showingSuggestions = false
    @State private var showingVoiceRecording = false
    @State private var isRecording = false
    @State private var showingConfirmation = false
    @State private var parsedTransaction: ParsedTransaction?
    @State private var showingHistory = false

    let onTransactionCreated: (FinancialTransaction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView

            inputView

            if showingSuggestions && !quickEntryService.suggestions.isEmpty {
                suggestionsView
            }

            if let parsed = parsedTransaction {
                parsedTransactionView(parsed)
            }

            if showingHistory {
                historyView
            }

            actionsView
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onAppear {
            loadSuggestions()
        }
        .onChange(of: inputText) { _, newValue in
            if !newValue.isEmpty {
                loadSuggestionsForInput(newValue)
            } else {
                showingSuggestions = false
            }
        }
        .sheet(isPresented: $showingVoiceRecording) {
            VoiceRecordingSheet(
                quickEntryService: quickEntryService
            ) { text in
                    inputText = text
                    showingVoiceRecording = false
                    processInput()
                }
        }
        .alert("Confirm Transaction", isPresented: $showingConfirmation) {
            if let parsed = parsedTransaction {
                Button("Cancel", role: .cancel) {
                    showingConfirmation = false
                }
                Button("Create Transaction") {
                    createTransaction(from: parsed)
                    showingConfirmation = false
                }
            }
        } message: {
            if let parsed = parsedTransaction {
                Text("Amount: \(formatCurrency(parsed.amount))\nCategory: \(parsed.category)\nMerchant: \(parsed.merchant ?? "Unknown")")
            }
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.green)

            VStack(alignment: .leading) {
                Text("Quick Entry")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Enter transactions using natural language")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { showingHistory.toggle() }) {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .help("View recent entries")
        }
    }

    private var inputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transaction Details")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack {
                TextField("e.g., \"Spent $5.50 at Starbucks for coffee\"", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        processInput()
                    }

                Button(action: startVoiceInput) {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .foregroundColor(isRecording ? .red : .blue)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .help("Voice input")
                .disabled(quickEntryService.isProcessing)

                Button(action: processInput) {
                    if quickEntryService.isProcessing {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    }
                }
                .buttonStyle(.plain)
                .help("Process transaction")
                .disabled(inputText.isEmpty || quickEntryService.isProcessing)
            }
        }
    }

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestions")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVStack(spacing: 4) {
                ForEach(quickEntryService.suggestions.prefix(5)) { suggestion in
                    SuggestionRow(suggestion: suggestion) {
                        inputText = suggestion.text
                        showingSuggestions = false
                        processInput()
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func parsedTransactionView(_ parsed: ParsedTransaction) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Parsed Transaction")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("Confidence: \(Int(parsed.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(parsed.confidence > 0.7 ? .green : .orange)
            }

            HStack(spacing: 16) {
                TransactionDetailCard(
                    title: "Amount",
                    value: formatCurrency(parsed.amount),
                    icon: "dollarsign.circle.fill",
                    color: parsed.amount >= 0 ? .green : .red
                )

                TransactionDetailCard(
                    title: "Category",
                    value: parsed.category,
                    icon: "tag.fill",
                    color: .blue
                )

                TransactionDetailCard(
                    title: "Merchant",
                    value: parsed.merchant ?? "Unknown",
                    icon: "storefront.fill",
                    color: .purple
                )

                TransactionDetailCard(
                    title: "Date",
                    value: formatDate(parsed.date),
                    icon: "calendar.circle.fill",
                    color: .orange
                )
            }

            if !parsed.description.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(parsed.description)
                        .font(.body)
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var historyView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Entries")
                .font(.subheadline)
                .fontWeight(.medium)

            if quickEntryService.recentEntries.isEmpty {
                Text("No recent entries")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 6) {
                    ForEach(quickEntryService.recentEntries.prefix(5)) { entry in
                        HistoryRow(entry: entry) {
                            inputText = entry.originalInput
                            showingHistory = false
                            processInput()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private var actionsView: some View {
        HStack {
            Button("Clear") {
                clearAll()
            }
            .buttonStyle(.bordered)

            Spacer()

            if let parsed = parsedTransaction {
                Button("Create Transaction") {
                    if parsed.confidence > 0.5 {
                        createTransaction(from: parsed)
                    } else {
                        showingConfirmation = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - Actions

    private func processInput() {
        guard !inputText.isEmpty else { return }

        Task {
            let parsed = await quickEntryService.processNaturalLanguageInput(inputText)
            await MainActor.run {
                self.parsedTransaction = parsed
                self.showingSuggestions = false
            }
        }
    }

    private func startVoiceInput() {
        showingVoiceRecording = true
    }

    private func loadSuggestions() {
        Task {
            await quickEntryService.getSuggestions(for: "")
        }
    }

    private func loadSuggestionsForInput(_ input: String) {
        Task {
            await quickEntryService.getSuggestions(for: input)
            await MainActor.run {
                showingSuggestions = true
            }
        }
    }

    private func createTransaction(from parsed: ParsedTransaction) {
        let transaction = quickEntryService.createTransaction(from: parsed)
        onTransactionCreated(transaction)
        clearAll()
    }

    private func clearAll() {
        inputText = ""
        parsedTransaction = nil
        showingSuggestions = false
        showingHistory = false
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct SuggestionRow: View {
    let suggestion: TransactionSuggestion
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: iconForSuggestionType(suggestion.type))
                    .foregroundColor(colorForSuggestionType(suggestion.type))
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(suggestion.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(Int(suggestion.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private func iconForSuggestionType(_ type: TransactionSuggestion.SuggestionType) -> String {
        switch type {
        case .template: return "doc.text"
        case .merchant: return "storefront"
        case .common: return "star.fill"
        case .history: return "clock"
        }
    }

    private func colorForSuggestionType(_ type: TransactionSuggestion.SuggestionType) -> Color {
        switch type {
        case .template: return .blue
        case .merchant: return .purple
        case .common: return .orange
        case .history: return .green
        }
    }
}

struct TransactionDetailCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
}

struct HistoryRow: View {
    let entry: QuickEntryHistory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.originalInput)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack {
                        Text(formatCurrency(entry.parsedTransaction.amount))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(entry.parsedTransaction.category)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(timeAgo(entry.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86_400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86_400))d ago"
        }
    }
}

struct VoiceRecordingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var quickEntryService: QuickEntryService
    @State private var isRecording = false
    @State private var transcribedText = ""
    @State private var recordingError: String?

    let onTextRecognized: (String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 64))
                        .foregroundColor(isRecording ? .red : .blue)
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)

                    Text(isRecording ? "Listening..." : "Tap to start recording")
                        .font(.headline)
                        .foregroundColor(.primary)

                    if !transcribedText.isEmpty {
                        Text(transcribedText)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(8)
                    }

                    if let error = recordingError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                Spacer()

                HStack(spacing: 16) {
                    Button("Cancel") {
                        stopRecording()
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Button(isRecording ? "Stop" : "Start") {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    if !transcribedText.isEmpty {
                        Button("Use Text") {
                            onTextRecognized(transcribedText)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
            .navigationTitle("Voice Input")
            .navigationBarTitleDisplayMode(.inline)
        }
        .frame(width: 400, height: 300)
    }

    private func startRecording() {
        recordingError = nil
        isRecording = true

        Task {
            do {
                let result = try await quickEntryService.startVoiceInput()
                await MainActor.run {
                    self.transcribedText = result
                    self.isRecording = false
                }
            } catch {
                await MainActor.run {
                    self.recordingError = error.localizedDescription
                    self.isRecording = false
                }
            }
        }
    }

    private func stopRecording() {
        quickEntryService.stopVoiceInput()
        isRecording = false
    }
}

#Preview {
    QuickEntryView { transaction in
        print("Created transaction: \(transaction.description)")
    }
    .frame(width: 600, height: 400)
    .padding()
}
