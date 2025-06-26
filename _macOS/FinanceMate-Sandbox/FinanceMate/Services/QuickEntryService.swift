import Foundation
import NaturalLanguage
import Speech

// MARK: - Quick Entry Service

@MainActor
public class QuickEntryService: ObservableObject {
    // MARK: - Published Properties

    @Published public var isProcessing = false
    @Published public var lastParsedTransaction: ParsedTransaction?
    @Published public var suggestions: [TransactionSuggestion] = []
    @Published public var recentEntries: [QuickEntryHistory] = []

    // MARK: - Private Properties

    private let nlpProcessor: NaturalLanguageProcessor
    private let suggestionEngine: SuggestionEngine
    private let voiceProcessor: VoiceInputProcessor
    private let historyManager: EntryHistoryManager

    // MARK: - Initialization

    public init() {
        self.nlpProcessor = NaturalLanguageProcessor()
        self.suggestionEngine = SuggestionEngine()
        self.voiceProcessor = VoiceInputProcessor()
        self.historyManager = EntryHistoryManager()

        loadRecentEntries()
        loadSuggestions()
    }

    // MARK: - Public Methods

    /// Process natural language input and extract transaction details
    public func processNaturalLanguageInput(_ input: String) async -> ParsedTransaction {
        isProcessing = true
        defer { isProcessing = false }

        let processed = await nlpProcessor.parseTransactionText(input)
        await MainActor.run {
            self.lastParsedTransaction = processed
            self.addToHistory(input: input, parsed: processed)
        }

        return processed
    }

    /// Get smart suggestions based on input
    public func getSuggestions(for partialInput: String) async -> [TransactionSuggestion] {
        let newSuggestions = await suggestionEngine.generateSuggestions(
            partialInput: partialInput,
            history: recentEntries
        )

        await MainActor.run {
            self.suggestions = newSuggestions
        }

        return newSuggestions
    }

    /// Start voice input processing
    public func startVoiceInput() async throws -> String {
        try await voiceProcessor.startRecording()
    }

    /// Stop voice input processing
    public func stopVoiceInput() {
        voiceProcessor.stopRecording()
    }

    /// Create transaction from parsed data
    public func createTransaction(from parsed: ParsedTransaction) -> FinancialTransaction {
        let transaction = FinancialTransaction(
            amount: parsed.amount,
            description: parsed.description,
            category: parsed.category,
            merchant: parsed.merchant ?? "Unknown",
            date: parsed.date
        )

        // Update suggestions based on successful entry
        Task {
            await suggestionEngine.learnFromTransaction(transaction)
        }

        return transaction
    }

    // MARK: - Private Methods

    private func loadRecentEntries() {
        recentEntries = historyManager.getRecentEntries()
    }

    private func loadSuggestions() {
        Task {
            let commonSuggestions = await suggestionEngine.getCommonSuggestions()
            await MainActor.run {
                self.suggestions = commonSuggestions
            }
        }
    }

    private func addToHistory(input: String, parsed: ParsedTransaction) {
        let historyEntry = QuickEntryHistory(
            originalInput: input,
            parsedTransaction: parsed,
            timestamp: Date(),
            wasSuccessful: true
        )

        historyManager.addEntry(historyEntry)
        recentEntries = historyManager.getRecentEntries()
    }
}

// MARK: - Natural Language Processor

public class NaturalLanguageProcessor {
    private let tagger: NLTagger
    private let categoryClassifier: CategoryClassifier

    public init() {
        self.tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        self.categoryClassifier = CategoryClassifier()
    }

    public func parseTransactionText(_ text: String) async -> ParsedTransaction {
        tagger.string = text

        // Extract amount
        let amount = extractAmount(from: text)

        // Extract merchant/description
        let (merchant, description) = extractMerchantAndDescription(from: text)

        // Extract date
        let date = extractDate(from: text) ?? Date()

        // Classify category
        let category = await categoryClassifier.classifyCategory(
            description: description,
            merchant: merchant,
            amount: amount
        )

        return ParsedTransaction(
            amount: amount,
            description: description,
            merchant: merchant,
            category: category,
            date: date,
            confidence: calculateConfidence(text: text, amount: amount, description: description)
        )
    }

    private func extractAmount(from text: String) -> Double {
        let patterns = [
            #"\$(\d+(?:\.\d{2})?)"#,  // $123.45
            #"(\d+(?:\.\d{2})?) dollars?"#,  // 123.45 dollars
            #"(\d+(?:\.\d{2})?) bucks?"#,  // 123.45 bucks
            #"(\d+(?:,\d{3})*(?:\.\d{2})?)"#  // 1,234.56
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    let matchRange = Range(match.range(at: 1), in: text)!
                    let amountString = String(text[matchRange]).replacingOccurrences(of: ",", with: "")
                    if let amount = Double(amountString) {
                        // Determine if it's an expense or income
                        let isExpense = text.lowercased().contains("spent") ||
                                       text.lowercased().contains("paid") ||
                                       text.lowercased().contains("bought") ||
                                       text.lowercased().contains("cost")
                        return isExpense ? -amount : amount
                    }
                }
            }
        }

        return 0.0
    }

    private func extractMerchantAndDescription(from text: String) -> (merchant: String?, description: String) {
        // Look for prepositions that indicate merchant/location
        let merchantPatterns = [
            #"(?:at|from)\s+([A-Z][A-Za-z\s&]+?)(?:\s|$|,|\.|!|\?)"#,  // "at Starbucks"
            #"(?:paid|spent at)\s+([A-Z][A-Za-z\s&]+?)(?:\s|$|,|\.|!|\?)"#  // "paid Uber"
        ]

        var extractedMerchant: String?

        for pattern in merchantPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    let matchRange = Range(match.range(at: 1), in: text)!
                    extractedMerchant = String(text[matchRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    break
                }
            }
        }

        // Use the original text as description, cleaned up
        let description = text
            .replacingOccurrences(of: #"\$\d+(?:\.\d{2})?"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return (merchant: extractedMerchant, description: description.isEmpty ? text : description)
    }

    private func extractDate(from text: String) -> Date? {
        let datePatterns = [
            #"today"#,
            #"yesterday"#,
            #"(\d{1,2})/(\d{1,2})/(\d{4})"#,  // MM/dd/yyyy
            #"(\d{1,2})/(\d{1,2})"#,  // MM/dd (current year)
            #"(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2})"#
        ]

        let calendar = Calendar.current
        let now = Date()

        for pattern in datePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    let matchedText = String(text[Range(match.range, in: text)!])

                    switch matchedText.lowercased() {
                    case "today":
                        return now
                    case "yesterday":
                        return calendar.date(byAdding: .day, value: -1, to: now)
                    default:
                        // Try to parse specific dates
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MM/dd/yyyy"
                        if let date = formatter.date(from: matchedText) {
                            return date
                        }

                        formatter.dateFormat = "MM/dd"
                        if let date = formatter.date(from: matchedText) {
                            return date
                        }
                    }
                }
            }
        }

        return nil
    }

    private func calculateConfidence(text: String, amount: Double, description: String) -> Double {
        var confidence: Double = 0.0

        // Amount found
        if amount != 0.0 {
            confidence += 0.4
        }

        // Description quality
        if !description.isEmpty && description.count > 3 {
            confidence += 0.3
        }

        // Text quality
        if text.count > 5 {
            confidence += 0.2
        }

        // Contains transaction keywords
        let transactionKeywords = ["spent", "paid", "bought", "cost", "charged", "earned", "received"]
        if transactionKeywords.contains(where: { text.lowercased().contains($0) }) {
            confidence += 0.1
        }

        return min(1.0, confidence)
    }
}

// MARK: - Category Classifier

public class CategoryClassifier {
    private let categoryPatterns: [String: [String]] = [
        "Food": ["restaurant", "coffee", "starbucks", "mcdonald", "pizza", "food", "lunch", "dinner", "breakfast", "cafe"],
        "Transportation": ["uber", "lyft", "gas", "fuel", "parking", "taxi", "metro", "bus", "train", "car"],
        "Shopping": ["amazon", "target", "walmart", "store", "shop", "mall", "retail", "clothes", "clothing"],
        "Entertainment": ["movie", "cinema", "netflix", "spotify", "concert", "game", "entertainment", "fun"],
        "Utilities": ["electric", "gas bill", "water", "internet", "phone", "utility", "bill"],
        "Healthcare": ["doctor", "hospital", "pharmacy", "medical", "health", "dentist", "clinic"],
        "Income": ["salary", "paycheck", "earned", "received", "income", "payment", "bonus", "refund"]
    ]

    public func classifyCategory(description: String, merchant: String?, amount: Double) async -> String {
        let text = "\(description) \(merchant ?? "")".lowercased()

        // Income classification
        if amount > 0 {
            if categoryPatterns["Income"]?.contains(where: { text.contains($0) }) == true {
                return "Income"
            }
        }

        // Expense classification
        for (category, keywords) in categoryPatterns {
            if category == "Income" { continue }

            if keywords.contains(where: { text.contains($0) }) {
                return category
            }
        }

        return "Other"
    }
}

// MARK: - Suggestion Engine

public class SuggestionEngine {
    private var learnedPatterns: [String: String] = [:]
    private var merchantCategories: [String: String] = [:]

    public func generateSuggestions(partialInput: String, history: [QuickEntryHistory]) async -> [TransactionSuggestion] {
        var suggestions: [TransactionSuggestion] = []

        // Common transaction patterns
        let commonPatterns = [
            "Spent $X at Y",
            "Paid $X for Y",
            "Bought Y for $X",
            "Earned $X from Y",
            "Received $X for Y"
        ]

        for pattern in commonPatterns {
            suggestions.append(TransactionSuggestion(
                text: pattern,
                type: .template,
                category: "Template",
                confidence: 0.7
            ))
        }

        // Recent merchants
        let recentMerchants = Set(history.compactMap { $0.parsedTransaction.merchant })
        for merchant in recentMerchants.prefix(5) {
            suggestions.append(TransactionSuggestion(
                text: "Spent $ at \(merchant)",
                type: .merchant,
                category: merchantCategories[merchant] ?? "Other",
                confidence: 0.8
            ))
        }

        // Partial input matching
        if !partialInput.isEmpty {
            let matchingSuggestions = generateMatchingSuggestions(for: partialInput, history: history)
            suggestions.append(contentsOf: matchingSuggestions)
        }

        return suggestions.prefix(8).map { $0 }
    }

    public func getCommonSuggestions() async -> [TransactionSuggestion] {
        [
            TransactionSuggestion(text: "Coffee at Starbucks $5.50", type: .common, category: "Food", confidence: 0.9),
            TransactionSuggestion(text: "Lunch $12.99", type: .common, category: "Food", confidence: 0.8),
            TransactionSuggestion(text: "Gas $45.00", type: .common, category: "Transportation", confidence: 0.8),
            TransactionSuggestion(text: "Grocery shopping $89.50", type: .common, category: "Food", confidence: 0.7),
            TransactionSuggestion(text: "Uber ride $18.25", type: .common, category: "Transportation", confidence: 0.8)
        ]
    }

    public func learnFromTransaction(_ transaction: FinancialTransaction) async {
        // Learn merchant-category associations
        merchantCategories[transaction.merchant] = transaction.category

        // Learn description patterns
        let pattern = extractPattern(from: transaction.description)
        if !pattern.isEmpty {
            learnedPatterns[pattern] = transaction.category
        }
    }

    private func generateMatchingSuggestions(for input: String, history: [QuickEntryHistory]) -> [TransactionSuggestion] {
        let lowercasedInput = input.lowercased()
        var suggestions: [TransactionSuggestion] = []

        // Match against history
        for entry in history {
            if entry.parsedTransaction.description.lowercased().contains(lowercasedInput) ||
               entry.parsedTransaction.merchant?.lowercased().contains(lowercasedInput) == true {
                suggestions.append(TransactionSuggestion(
                    text: entry.originalInput,
                    type: .history,
                    category: entry.parsedTransaction.category,
                    confidence: 0.9
                ))
            }
        }

        return suggestions
    }

    private func extractPattern(from description: String) -> String {
        // Simple pattern extraction - could be enhanced with ML
        description.lowercased()
            .replacingOccurrences(of: #"\d+"#, with: "X", options: .regularExpression)
            .replacingOccurrences(of: #"\$[\d\.]+"#, with: "$X", options: .regularExpression)
    }
}

// MARK: - Voice Input Processor

public class VoiceInputProcessor: NSObject, ObservableObject {
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published public var isRecording = false
    @Published public var transcribedText = ""

    override public init() {
        super.init()
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }

    public func startRecording() async throws -> String {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw VoiceInputError.speechRecognitionUnavailable
        }

        // Request authorization
        let authStatus = await SFSpeechRecognizer.requestAuthorization()
        guard authStatus == .authorized else {
            throw VoiceInputError.authorizationDenied
        }

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceInputError.recognitionRequestFailed
        }

        recognitionRequest.shouldReportPartialResults = true

        // Start recording
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        await MainActor.run {
            isRecording = true
        }

        return try await withCheckedThrowingContinuation { continuation in
            recognitionTask = speechRecognizer.recognizeRequest(recognitionRequest) { [weak self] result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self?.transcribedText = result.bestTranscription.formattedString
                    }

                    if result.isFinal {
                        continuation.resume(returning: result.bestTranscription.formattedString)
                    }
                } else if let error = error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest = nil
        recognitionTask = nil

        isRecording = false
    }
}

// MARK: - Entry History Manager

public class EntryHistoryManager {
    private let maxHistoryCount = 50
    private var entries: [QuickEntryHistory] = []

    public init() {
        loadHistory()
    }

    public func addEntry(_ entry: QuickEntryHistory) {
        entries.append(entry)

        // Keep only recent entries
        if entries.count > maxHistoryCount {
            entries.removeFirst(entries.count - maxHistoryCount)
        }

        saveHistory()
    }

    public func getRecentEntries() -> [QuickEntryHistory] {
        Array(entries.suffix(20))
    }

    private func loadHistory() {
        // Load from UserDefaults or Core Data in real implementation
        // For now, using in-memory storage
    }

    private func saveHistory() {
        // Save to UserDefaults or Core Data in real implementation
    }
}

// MARK: - Supporting Types

public struct ParsedTransaction {
    public let amount: Double
    public let description: String
    public let merchant: String?
    public let category: String
    public let date: Date
    public let confidence: Double

    public init(amount: Double, description: String, merchant: String?, category: String, date: Date, confidence: Double) {
        self.amount = amount
        self.description = description
        self.merchant = merchant
        self.category = category
        self.date = date
        self.confidence = confidence
    }
}

public struct TransactionSuggestion: Identifiable, Equatable {
    public let id = UUID()
    public let text: String
    public let type: SuggestionType
    public let category: String
    public let confidence: Double

    public enum SuggestionType {
        case template
        case merchant
        case common
        case history
    }
}

public struct QuickEntryHistory: Identifiable {
    public let id = UUID()
    public let originalInput: String
    public let parsedTransaction: ParsedTransaction
    public let timestamp: Date
    public let wasSuccessful: Bool
}

public enum VoiceInputError: Error, LocalizedError {
    case speechRecognitionUnavailable
    case authorizationDenied
    case recognitionRequestFailed
    case recordingFailed

    public var errorDescription: String? {
        switch self {
        case .speechRecognitionUnavailable:
            return "Speech recognition is not available on this device"
        case .authorizationDenied:
            return "Speech recognition authorization was denied"
        case .recognitionRequestFailed:
            return "Failed to create speech recognition request"
        case .recordingFailed:
            return "Failed to start audio recording"
        }
    }
}
