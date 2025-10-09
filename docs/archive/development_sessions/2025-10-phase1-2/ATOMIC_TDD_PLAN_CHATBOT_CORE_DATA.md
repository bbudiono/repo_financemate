# ATOMIC TDD PLAN: Connect Chatbot to Core Data

**Priority:** P0 CRITICAL
**Complexity:** Level 2 (Simple/Standard) - NO USER APPROVAL NEEDED
**Estimated Time:** 4-6 hours
**BLUEPRINT Violation:** Line 52 - "Context Aware Chatbot: Access dashboard data"

---

## CURRENT STATE (VERIFIED):

**File:** `ChatbotViewModel.swift`
- Line 20: `private let context: NSManagedObjectContext` - STORED BUT NEVER USED
- Line 44: `FinancialKnowledgeService.processQuestion(content)` - NO CONTEXT PASSED

**Problem:** Chatbot is BLIND to user's financial data (balance, transactions, spending)

**Evidence:**
```swift
func sendMessage(_ content: String) async {
    // ...
    let result = FinancialKnowledgeService.processQuestion(content)  // ← NO CONTEXT
    // ...
}
```

---

## ATOMIC TDD IMPLEMENTATION (KISS COMPLIANT):

### STEP 1: Create Query Helper (NEW FILE - 45 lines)

**File:** `FinanceMate/TransactionQueryHelper.swift`

**Purpose:** Simple Core Data query functions

**Implementation:**
```swift
import Foundation
import CoreData

struct TransactionQueryHelper {

    /// Get total balance from all transactions
    static func getTotalBalance(context: NSManagedObjectContext) -> Double {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        do {
            let transactions = try context.fetch(request)
            return transactions.reduce(0.0) { $0 + $1.amount }
        } catch {
            return 0.0
        }
    }

    /// Get transaction count
    static func getTransactionCount(context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        do {
            return try context.count(for: request)
        } catch {
            return 0
        }
    }

    /// Get recent transactions (last 5)
    static func getRecentTransactions(context: NSManagedObjectContext, limit: Int = 5) -> [Transaction] {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = limit
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }

    /// Get spending by category
    static func getCategorySpending(context: NSManagedObjectContext, category: String) -> Double {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSPredicate(format: "category == %@", category)
        do {
            let transactions = try context.fetch(request)
            return transactions.reduce(0.0) { $0 + abs($1.amount) }
        } catch {
            return 0.0
        }
    }
}
```

**Lines:** ~45 (✅ KISS COMPLIANT <200)

---

### STEP 2: Modify FinancialKnowledgeService (MODIFY EXISTING)

**File:** `FinanceMate/FinancialKnowledgeService.swift`

**Change 1:** Add context parameter to processQuestion

**OLD (Line 36):**
```swift
static func processQuestion(_ question: String) -> (content: String, hasData: Bool, actionType: ActionType, questionType: FinancialQuestionType?, qualityScore: Double) {
```

**NEW:**
```swift
static func processQuestion(_ question: String, context: NSManagedObjectContext?) -> (content: String, hasData: Bool, actionType: ActionType, questionType: FinancialQuestionType?, qualityScore: Double) {
```

**Change 2:** Add data-aware responses (insert after line 37)

```swift
// Check for data-specific questions FIRST (before keyword matching)
if let context = context {
    if questionLower.contains("balance") || questionLower.contains("total") {
        let balance = TransactionQueryHelper.getTotalBalance(context: context)
        let count = TransactionQueryHelper.getTransactionCount(context: context)
        response = "Your current balance is $\(String(format: "%.2f", balance)) across \(count) transactions. \(balance > 0 ? "You're in a positive position!" : "Consider reviewing your expenses to improve your balance.")"
        hasData = true
        actionType = .showDashboard
        let qualityScore = calculateQualityScore(response: response, question: question)
        return (response, hasData, actionType, .financeMateSpecific, qualityScore)
    }

    if questionLower.contains("spending") || questionLower.contains("spent") {
        let recentTransactions = TransactionQueryHelper.getRecentTransactions(context: context)
        if !recentTransactions.isEmpty {
            let totalSpent = recentTransactions.reduce(0.0) { $0 + abs($1.amount) }
            response = "Your recent spending totals $\(String(format: "%.2f", totalSpent)) across \(recentTransactions.count) transactions. The most recent was \(recentTransactions.first?.merchant ?? "Unknown") for $\(String(format: "%.2f", recentTransactions.first?.amount ?? 0))."
            hasData = true
            actionType = .analyzeExpenses
            let qualityScore = calculateQualityScore(response: response, question: question)
            return (response, hasData, actionType, .personalFinance, qualityScore)
        }
    }

    if questionLower.contains("category") || questionLower.contains("groceries") || questionLower.contains("dining") {
        for category in ["Groceries", "Dining", "Transport", "Utilities", "Entertainment"] {
            if questionLower.contains(category.lowercased()) {
                let categorySpending = TransactionQueryHelper.getCategorySpending(context: context, category: category)
                response = "You've spent $\(String(format: "%.2f", categorySpending)) on \(category). \(categorySpending > 0 ? "This represents a significant expense category." : "No transactions found in this category yet.")"
                hasData = true
                actionType = .analyzeExpenses
                let qualityScore = calculateQualityScore(response: response, question: question)
                return (response, hasData, actionType, .personalFinance, qualityScore)
            }
        }
    }
}
```

**Lines After Modification:** ~220 (⚠️ VIOLATES KISS - REQUIRES REFACTORING)

**SOLUTION:** Extract data-aware logic to separate function:

```swift
private static func generateDataAwareResponse(question: String, context: NSManagedObjectContext) -> (content: String, hasData: Bool, actionType: ActionType, questionType: FinancialQuestionType?)? {
    let questionLower = question.lowercased()

    if questionLower.contains("balance") || questionLower.contains("total") {
        let balance = TransactionQueryHelper.getTotalBalance(context: context)
        let count = TransactionQueryHelper.getTransactionCount(context: context)
        let response = "Your current balance is $\(String(format: "%.2f", balance)) across \(count) transactions. \(balance > 0 ? "You're in a positive position!" : "Consider reviewing your expenses to improve your balance.")"
        return (response, true, .showDashboard, .financeMateSpecific)
    }

    if questionLower.contains("spending") || questionLower.contains("spent") {
        let recentTransactions = TransactionQueryHelper.getRecentTransactions(context: context)
        if !recentTransactions.isEmpty {
            let totalSpent = recentTransactions.reduce(0.0) { $0 + abs($1.amount) }
            let response = "Your recent spending totals $\(String(format: "%.2f", totalSpent)) across \(recentTransactions.count) transactions. The most recent was \(recentTransactions.first?.merchant ?? "Unknown") for $\(String(format: "%.2f", recentTransactions.first?.amount ?? 0))."
            return (response, true, .analyzeExpenses, .personalFinance)
        }
    }

    return nil
}
```

**Then modify processQuestion to call it first:**

```swift
static func processQuestion(_ question: String, context: NSManagedObjectContext?) -> (...) {
    let questionLower = question.lowercased()
    let questionType = classifyQuestion(question)

    // PRIORITY 1: Check user's actual data FIRST
    if let context = context, let dataResponse = generateDataAwareResponse(question: question, context: context) {
        let qualityScore = calculateQualityScore(response: dataResponse.content, question: question)
        return (dataResponse.content, dataResponse.hasData, dataResponse.actionType, dataResponse.questionType, qualityScore)
    }

    // PRIORITY 2: Fall back to knowledge base...
    // (existing keyword matching logic)
}
```

**Final File Size:** ~210 lines (⚠️ STILL OVER - NEEDS SPLIT)

**BETTER SOLUTION:** Create separate `DataAwareResponseGenerator.swift` (55 lines):

---

### STEP 3: Create DataAwareResponseGenerator (NEW FILE - 55 lines)

**File:** `FinanceMate/DataAwareResponseGenerator.swift`

```swift
import Foundation
import CoreData

struct DataAwareResponseGenerator {

    static func generate(question: String, context: NSManagedObjectContext) -> (content: String, actionType: ActionType, questionType: FinancialQuestionType)? {
        let questionLower = question.lowercased()

        if questionLower.contains("balance") || questionLower.contains("total") {
            return generateBalanceResponse(context: context)
        }

        if questionLower.contains("spending") || questionLower.contains("spent") {
            return generateSpendingResponse(context: context)
        }

        if questionLower.contains("category") {
            return generateCategoryResponse(question: questionLower, context: context)
        }

        return nil
    }

    private static func generateBalanceResponse(context: NSManagedObjectContext) -> (String, ActionType, FinancialQuestionType) {
        let balance = TransactionQueryHelper.getTotalBalance(context: context)
        let count = TransactionQueryHelper.getTransactionCount(context: context)
        let content = "Your current balance is $\(String(format: "%.2f", balance)) across \(count) transactions. \(balance > 0 ? "You're in a positive position!" : "Consider reviewing your expenses.")"
        return (content, .showDashboard, .financeMateSpecific)
    }

    private static func generateSpendingResponse(context: NSManagedObjectContext) -> (String, ActionType, FinancialQuestionType)? {
        let recent = TransactionQueryHelper.getRecentTransactions(context: context)
        guard !recent.isEmpty else { return nil }

        let total = recent.reduce(0.0) { $0 + abs($1.amount) }
        let content = "Your recent spending totals $\(String(format: "%.2f", total)) across \(recent.count) transactions. Most recent: \(recent.first?.merchant ?? "Unknown") for $\(String(format: "%.2f", recent.first?.amount ?? 0))."
        return (content, .analyzeExpenses, .personalFinance)
    }

    private static func generateCategoryResponse(question: String, context: NSManagedObjectContext) -> (String, ActionType, FinancialQuestionType)? {
        let categories = ["groceries", "dining", "transport", "utilities", "entertainment"]
        for category in categories {
            if question.contains(category) {
                let spending = TransactionQueryHelper.getCategorySpending(context: context, category: category.capitalized)
                let content = "You've spent $\(String(format: "%.2f", spending)) on \(category.capitalized). \(spending > 0 ? "This is a significant expense category." : "No transactions found yet.")"
                return (content, .analyzeExpenses, .personalFinance)
            }
        }
        return nil
    }
}
```

**Lines:** ~55 (✅ KISS COMPLIANT)

---

### STEP 4: Update FinancialKnowledgeService (MINIMAL CHANGE)

**File:** `FinanceMate/FinancialKnowledgeService.swift`

**Line 36 - Modify signature:**
```swift
static func processQuestion(_ question: String, context: NSManagedObjectContext?) -> (content: String, hasData: Bool, actionType: ActionType, questionType: FinancialQuestionType?, qualityScore: Double) {
```

**Line 37-42 - Add data-aware check FIRST:**
```swift
    let questionLower = question.lowercased()
    let questionType = classifyQuestion(question)

    // PRIORITY 1: Check user's actual data FIRST
    if let context = context, let dataResponse = DataAwareResponseGenerator.generate(question: question, context: context) {
        let qualityScore = calculateQualityScore(response: dataResponse.content, question: question)
        return (dataResponse.content, true, dataResponse.actionType, dataResponse.questionType, qualityScore)
    }

    // PRIORITY 2: Knowledge base (existing logic continues...)
    var response = ""
    // ... rest of existing code unchanged ...
```

**Lines After Modification:** ~180 (✅ KISS COMPLIANT)

---

### STEP 5: Update ChatbotViewModel (PASS CONTEXT)

**File:** `FinanceMate/ChatbotViewModel.swift`

**Line 44 - CHANGE FROM:**
```swift
let result = FinancialKnowledgeService.processQuestion(content)
```

**TO:**
```swift
let result = FinancialKnowledgeService.processQuestion(content, context: context)
```

**Lines:** ~102 (✅ STILL KISS COMPLIANT)

---

## TESTING PLAN:

### Test 1: Balance Query
**Input:** "What's my balance?"
**Expected:** "Your current balance is $X.XX across Y transactions..."
**Success Criteria:** Uses REAL Core Data, not static response

### Test 2: Spending Query
**Input:** "How much did I spend recently?"
**Expected:** "Your recent spending totals $X.XX across Y transactions. Most recent: [merchant] for $X.XX"
**Success Criteria:** Shows REAL transaction data

### Test 3: Category Query
**Input:** "How much did I spend on groceries?"
**Expected:** "You've spent $X.XX on Groceries. This is a significant expense category."
**Success Criteria:** Queries actual category spending

### Test 4: Fallback (No Data)
**Input:** "What is capital gains tax?"
**Expected:** Falls back to static knowledge base (existing behavior)
**Success Criteria:** Still works for general questions

---

## FILES CREATED/MODIFIED:

**Created:**
1. `TransactionQueryHelper.swift` (45 lines)
2. `DataAwareResponseGenerator.swift` (55 lines)

**Modified:**
1. `FinancialKnowledgeService.swift` (+8 lines = 185 total)
2. `ChatbotViewModel.swift` (1 line change = 102 total)

**Total New Code:** 100 lines
**All Files KISS Compliant:** ✅ YES (all <200 lines)

---

## DEPLOYMENT STEPS:

1. Create `TransactionQueryHelper.swift` with Core Data queries
2. Create `DataAwareResponseGenerator.swift` with response logic
3. Modify `FinancialKnowledgeService.swift` to check data first
4. Update `ChatbotViewModel.swift` to pass context
5. Build and test with real transactions
6. Capture visual proof (screenshot showing data-aware response)
7. Update E2E tests to validate Core Data integration

---

## SUCCESS METRICS:

- ✅ Chatbot can answer balance questions with REAL data
- ✅ Chatbot can answer spending questions with REAL data
- ✅ Chatbot can answer category questions with REAL data
- ✅ All files remain <200 lines (KISS compliant)
- ✅ No breaking changes to existing functionality
- ✅ Visual proof via screenshot

---

**ESTIMATED TIME:** 4-6 hours (atomic TDD implementation)
**COMPLEXITY:** Level 2 (Simple/Standard)
**USER APPROVAL:** NOT REQUIRED (enhancement, not major refactor)
**BLUEPRINT COMPLIANCE:** ✅ FIXES Line 52 violation

---

**STATUS:** READY TO EXECUTE
