import CreateML
import Foundation
import NaturalLanguage
import SwiftUI

// MARK: - AI-Powered Categorization Engine

@MainActor
public class AICategorizationEngine: ObservableObject {
    @Published public var isTraining = false
    @Published public var confidence: Double = 0.0
    @Published public var lastProcessedCount = 0

    private var mlModel: NLModel?
    private var categoryLearning: [String: [String]] = [:]
    private let modelURL: URL

    public init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        modelURL = documentsPath.appendingPathComponent("FinancialCategorizationModel.mlmodel")
        loadExistingModel()
        setupDefaultLearningData()
    }

    // MARK: - Public Interface

    public func categorizeTransaction(_ description: String, amount: Double, merchant: String? = nil) -> CategoryPrediction {
        let features = extractFeatures(description: description, amount: amount, merchant: merchant)

        // Try ML model first
        if let mlModel = mlModel {
            let prediction = predictWithMLModel(features: features, model: mlModel)
            if prediction.confidence > 0.7 {
                return prediction
            }
        }

        // Fallback to enhanced rule-based system
        return predictWithRules(features: features)
    }

    public func bulkCategorize(_ transactions: [TransactionData]) async -> [CategoryPrediction] {
        var predictions: [CategoryPrediction] = []

        for transaction in transactions {
            let prediction = categorizeTransaction(
                transaction.description,
                amount: transaction.amount,
                merchant: transaction.merchant
            )
            predictions.append(prediction)

            // Update progress
            await MainActor.run {
                lastProcessedCount = predictions.count
            }
        }

        return predictions
    }

    public func learnFromUserFeedback(description: String, amount: Double, userSelectedCategory: BudgetCategoryType) {
        let key = userSelectedCategory.rawValue

        if categoryLearning[key] == nil {
            categoryLearning[key] = []
        }

        let learningPattern = createLearningPattern(description: description, amount: amount)
        categoryLearning[key]?.append(learningPattern)

        // Trigger retraining if we have enough new data
        let totalPatterns = categoryLearning.values.flatMap { $0 }.count
        if totalPatterns > 50 && !isTraining {
            Task {
                await retrainModel()
            }
        }

        saveLearningData()
    }

    public func trainInitialModel() async {
        await MainActor.run {
            isTraining = true
        }

        do {
            let trainingData = generateTrainingData()
            let classifier = try MLClassifier(trainingData: trainingData)

            try classifier.write(to: modelURL)
            loadExistingModel()

            await MainActor.run {
                isTraining = false
                confidence = 0.95
            }
        } catch {
            print("Failed to train model: \(error)")
            await MainActor.run {
                isTraining = false
                confidence = 0.0
            }
        }
    }

    // MARK: - Feature Extraction

    private func extractFeatures(description: String, amount: Double, merchant: String?) -> TransactionFeatures {
        let cleanDescription = description.lowercased()
        let tokens = tokenize(cleanDescription)

        return TransactionFeatures(
            description: cleanDescription,
            amount: amount,
            merchant: merchant?.lowercased(),
            tokens: tokens,
            amountCategory: categorizeAmount(amount),
            dayOfWeek: Calendar.current.component(.weekday, from: Date()),
            hasKeywords: extractKeywords(tokens),
            merchantType: classifyMerchant(merchant ?? description)
        )
    }

    private func tokenize(_ text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text

        var tokens: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let token = String(text[tokenRange])
            if token.count > 2 && !["the", "and", "for", "with", "from"].contains(token) {
                tokens.append(token)
            }
            return true
        }

        return tokens
    }

    private func extractKeywords(_ tokens: [String]) -> [String] {
        let financialKeywords = [
            // Food & Dining
            "restaurant", "coffee", "starbucks", "mcdonalds", "food", "dining", "cafe", "pizza",
            // Transportation
            "gas", "fuel", "uber", "lyft", "taxi", "parking", "metro", "bus", "train",
            // Shopping
            "amazon", "target", "walmart", "shop", "store", "purchase", "buy",
            // Entertainment
            "netflix", "spotify", "movie", "cinema", "theater", "concert", "game",
            // Utilities
            "electric", "water", "internet", "phone", "cable", "utility", "bill",
            // Healthcare
            "doctor", "pharmacy", "medical", "hospital", "clinic", "prescription",
            // Housing
            "rent", "mortgage", "insurance", "property", "home", "apartment",
            // Business
            "office", "supplies", "software", "conference", "meeting", "travel"
        ]

        return tokens.filter { financialKeywords.contains($0) }
    }

    private func categorizeAmount(_ amount: Double) -> AmountCategory {
        let absAmount = abs(amount)
        if absAmount < 10 { return .micro }
        if absAmount < 50 { return .small }
        if absAmount < 200 { return .medium }
        if absAmount < 1000 { return .large }
        return .xlarge
    }

    private func classifyMerchant(_ merchant: String) -> MerchantType {
        let merchant = merchant.lowercased()

        if merchant.contains("restaurant") || merchant.contains("cafe") || merchant.contains("food") {
            return .restaurant
        } else if merchant.contains("gas") || merchant.contains("fuel") || merchant.contains("shell") {
            return .gasStation
        } else if merchant.contains("amazon") || merchant.contains("shop") || merchant.contains("store") {
            return .retailStore
        } else if merchant.contains("streaming") || merchant.contains("netflix") || merchant.contains("spotify") {
            return .subscription
        } else if merchant.contains("utility") || merchant.contains("electric") || merchant.contains("water") {
            return .utility
        } else {
            return .other
        }
    }

    // MARK: - ML Model Operations

    private func predictWithMLModel(features: TransactionFeatures, model: NLModel) -> CategoryPrediction {
        let inputText = "\(features.description) \(features.amountCategory.rawValue) \(features.merchantType.rawValue)"

        let prediction = model.predictedLabel(for: inputText)
        let confidence = model.predictedLabelHypotheses(for: inputText, maximumCount: 1).first?.second ?? 0.5

        let category = BudgetCategoryType(rawValue: prediction ?? "miscellaneous") ?? .miscellaneous

        return CategoryPrediction(
            category: category,
            confidence: confidence,
            reasoning: "ML model prediction based on transaction patterns",
            alternativeCategories: getAlternativeMLPredictions(features: features, model: model)
        )
    }

    private func getAlternativeMLPredictions(features: TransactionFeatures, model: NLModel) -> [BudgetCategoryType] {
        let inputText = "\(features.description) \(features.amountCategory.rawValue) \(features.merchantType.rawValue)"
        let hypotheses = model.predictedLabelHypotheses(for: inputText, maximumCount: 3)

        return hypotheses.compactMap { hypothesis in
            BudgetCategoryType(rawValue: hypothesis.first)
        }
    }

    // MARK: - Rule-Based Fallback

    private func predictWithRules(features: TransactionFeatures) -> CategoryPrediction {
        let description = features.description
        let keywords = features.hasKeywords
        let merchantType = features.merchantType
        let amount = features.amount

        // Enhanced rule-based classification
        var category: BudgetCategoryType = .miscellaneous
        var confidence: Double = 0.6
        var reasoning = ""

        // Merchant type rules
        switch merchantType {
        case .restaurant:
            category = .food
            confidence = 0.85
            reasoning = "Identified as restaurant/food merchant"
        case .gasStation:
            category = .transportation
            confidence = 0.90
            reasoning = "Identified as gas station"
        case .retailStore:
            category = .shopping
            confidence = 0.75
            reasoning = "Identified as retail store"
        case .subscription:
            category = .entertainment
            confidence = 0.80
            reasoning = "Identified as subscription service"
        case .utility:
            category = .utilities
            confidence = 0.95
            reasoning = "Identified as utility service"
        case .other:
            // Use keyword-based rules
            category = categorizeByKeywords(keywords, description: description)
            confidence = 0.65
            reasoning = "Categorized using keyword analysis"
        }

        // Amount-based adjustments
        if abs(amount) > 1000 {
            if category == .miscellaneous {
                category = .housing
                confidence = 0.70
                reasoning = "Large amount suggests housing/major expense"
            }
        }

        // Subscription pattern detection
        if description.contains("monthly") || description.contains("subscription") {
            category = .entertainment
            confidence = 0.80
            reasoning = "Detected subscription pattern"
        }

        return CategoryPrediction(
            category: category,
            confidence: confidence,
            reasoning: reasoning,
            alternativeCategories: generateAlternatives(for: category)
        )
    }

    private func categorizeByKeywords(_ keywords: [String], description: String) -> BudgetCategoryType {
        if keywords.contains("coffee") || keywords.contains("restaurant") || keywords.contains("food") {
            return .food
        } else if keywords.contains("gas") || keywords.contains("uber") || keywords.contains("taxi") {
            return .transportation
        } else if keywords.contains("amazon") || keywords.contains("shop") || keywords.contains("store") {
            return .shopping
        } else if keywords.contains("netflix") || keywords.contains("spotify") || keywords.contains("movie") {
            return .entertainment
        } else if keywords.contains("electric") || keywords.contains("water") || keywords.contains("utility") {
            return .utilities
        } else if keywords.contains("doctor") || keywords.contains("pharmacy") || keywords.contains("medical") {
            return .healthcare
        } else if keywords.contains("rent") || keywords.contains("mortgage") || keywords.contains("insurance") {
            return .housing
        } else {
            return .miscellaneous
        }
    }

    private func generateAlternatives(for category: BudgetCategoryType) -> [BudgetCategoryType] {
        switch category {
        case .food:
            return [.entertainment, .shopping]
        case .transportation:
            return [.miscellaneous, .business]
        case .shopping:
            return [.entertainment, .miscellaneous]
        case .entertainment:
            return [.food, .shopping]
        case .utilities:
            return [.housing, .miscellaneous]
        case .healthcare:
            return [.insurance, .miscellaneous]
        case .housing:
            return [.utilities, .insurance]
        default:
            return [.food, .shopping, .entertainment]
        }
    }

    // MARK: - Model Training & Learning

    private func generateTrainingData() -> MLDataTable {
        var examples: [[String: MLDataValueConvertible]] = []

        // Add default training examples
        let defaultExamples = [
            ["text": "starbucks coffee morning", "category": "food"],
            ["text": "netflix monthly subscription", "category": "entertainment"],
            ["text": "shell gas station fuel", "category": "transportation"],
            ["text": "amazon purchase shopping", "category": "shopping"],
            ["text": "electric bill utility payment", "category": "utilities"],
            ["text": "doctor visit medical payment", "category": "healthcare"],
            ["text": "rent payment housing", "category": "housing"],
            ["text": "spotify music streaming", "category": "entertainment"],
            ["text": "uber ride transportation", "category": "transportation"],
            ["text": "target shopping retail", "category": "shopping"]
        ]

        examples.append(contentsOf: defaultExamples)

        // Add learned examples
        for (category, patterns) in categoryLearning {
            for pattern in patterns {
                examples.append(["text": pattern, "category": category])
            }
        }

        return try! MLDataTable(dictionary: [
            "text": examples.map { $0["text"]! },
            "category": examples.map { $0["category"]! }
        ])
    }

    private func retrainModel() async {
        await trainInitialModel()
    }

    private func createLearningPattern(description: String, amount: Double) -> String {
        let features = extractFeatures(description: description, amount: amount, merchant: nil)
        return "\(features.description) \(features.amountCategory.rawValue) \(features.merchantType.rawValue)"
    }

    // MARK: - Persistence

    private func loadExistingModel() {
        guard FileManager.default.fileExists(atPath: modelURL.path) else { return }

        do {
            mlModel = try NLModel(contentsOf: modelURL)
            confidence = 0.85
        } catch {
            print("Failed to load model: \(error)")
        }
    }

    private func setupDefaultLearningData() {
        // Initialize with basic patterns if no learning data exists
        if categoryLearning.isEmpty {
            categoryLearning = [
                "food": ["starbucks coffee", "restaurant dining", "mcdonalds fast food"],
                "transportation": ["gas station fuel", "uber ride", "parking fee"],
                "entertainment": ["netflix streaming", "movie theater", "spotify music"],
                "shopping": ["amazon purchase", "target retail", "online shopping"],
                "utilities": ["electric bill", "water payment", "internet service"]
            ]
        }
    }

    private func saveLearningData() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let learningDataURL = documentsPath.appendingPathComponent("categoryLearning.json")

        do {
            let data = try JSONEncoder().encode(categoryLearning)
            try data.write(to: learningDataURL)
        } catch {
            print("Failed to save learning data: \(error)")
        }
    }

    private func loadLearningData() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let learningDataURL = documentsPath.appendingPathComponent("categoryLearning.json")

        guard FileManager.default.fileExists(atPath: learningDataURL.path) else { return }

        do {
            let data = try Data(contentsOf: learningDataURL)
            categoryLearning = try JSONDecoder().decode([String: [String]].self, from: data)
        } catch {
            print("Failed to load learning data: \(error)")
        }
    }
}

// MARK: - Supporting Types

public struct TransactionData {
    public let description: String
    public let amount: Double
    public let merchant: String?

    public init(description: String, amount: Double, merchant: String? = nil) {
        self.description = description
        self.amount = amount
        self.merchant = merchant
    }
}

public struct CategoryPrediction {
    public let category: BudgetCategoryType
    public let confidence: Double
    public let reasoning: String
    public let alternativeCategories: [BudgetCategoryType]

    public init(category: BudgetCategoryType, confidence: Double, reasoning: String, alternativeCategories: [BudgetCategoryType] = []) {
        self.category = category
        self.confidence = confidence
        self.reasoning = reasoning
        self.alternativeCategories = alternativeCategories
    }
}

private struct TransactionFeatures {
    let description: String
    let amount: Double
    let merchant: String?
    let tokens: [String]
    let amountCategory: AmountCategory
    let dayOfWeek: Int
    let hasKeywords: [String]
    let merchantType: MerchantType
}

private enum AmountCategory: String, CaseIterable {
    case micro = "micro"     // < $10
    case small = "small"     // $10-50
    case medium = "medium"   // $50-200
    case large = "large"     // $200-1000
    case xlarge = "xlarge"   // > $1000
}

private enum MerchantType: String, CaseIterable {
    case restaurant = "restaurant"
    case gasStation = "gas_station"
    case retailStore = "retail_store"
    case subscription = "subscription"
    case utility = "utility"
    case other = "other"
}
