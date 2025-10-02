# ATOMIC TDD PLAN: LLM API Integration (Anthropic Claude)

**Priority:** P0 CRITICAL
**Complexity:** Level 4 (Complex/Advanced) - **REQUIRES USER APPROVAL**
**Estimated Time:** 2-3 days
**BLUEPRINT Violations:** Lines 49 (Mock Data), 51 (Frontier Model Capable)

---

## CURRENT STATE (CRITICAL VIOLATIONS):

### **BLOCKER:** Static Dictionary Masquerading as AI

**File:** `FinancialKnowledgeService.swift:8-32`

**Violation Evidence:**
```swift
private static let australianFinancialKnowledge: [String: String] = [...]
private static let financeMateFeatures: [String: String] = [...]
private static let basicFinancialConcepts: [String: String] = [...]
```

**BLUEPRINT Line 49:** "No Mock Data: Only functional, real data sources allowed **MANDATORY**"
**BLUEPRINT Line 51:** "Fully Functional Frontier Model Capable: Claude Sonnet 4, Gemini 2.5 Pro, GPT-4.1... **MANDATORY**"

**Reality:** Chatbot uses keyword matching against static dictionaries, NOT AI

---

## TARGET STATE (100% BLUEPRINT COMPLIANCE):

### **Anthropic Claude API Integration**

- ✅ Real LLM API calls (Claude Sonnet 4)
- ✅ Streaming responses for better UX
- ✅ Context injection from Core Data
- ✅ Remove ALL static dictionaries
- ✅ Natural language understanding
- ✅ Australian financial expertise via prompt engineering

---

## ATOMIC TDD IMPLEMENTATION:

### PHASE 1: API Client Foundation (Day 1 - 6-8 hours)

#### STEP 1.1: Create Anthropic API Client (NEW FILE - 180 lines)

**File:** `FinanceMate/AnthropicAPIClient.swift`

**Purpose:** Swift client for Anthropic Messages API with streaming support

**Key Components:**
```swift
import Foundation

struct AnthropicAPIClient {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1"
    private let model = "claude-sonnet-4-20250514"

    // Send message with streaming
    func sendMessage(messages: [Message], systemPrompt: String?, stream: Bool = true) async throws -> AsyncThrowingStream<String, Error>

    // Non-streaming for simple queries
    func sendMessageSync(messages: [Message], systemPrompt: String?) async throws -> String

    // Error handling
    enum APIError: Error {
        case invalidAPIKey
        case rateLimitExceeded
        case networkError(Error)
        case invalidResponse
    }
}

struct Message {
    let role: String  // "user" or "assistant"
    let content: String
}
```

**Lines:** ~180 (✅ KISS COMPLIANT)

**Testing:**
- Test with invalid API key (should throw)
- Test with valid API key (should return response)
- Test streaming mode
- Test rate limit handling

---

#### STEP 1.2: Configure API Key in .env (SECURITY CRITICAL)

**File:** `.env` (local only, never commit)

```bash
# Add to .env
ANTHROPIC_API_KEY=sk-ant-api03-...your-key-here...
```

**File:** `.env.template`

```bash
# Add to .env.template (for documentation)
ANTHROPIC_API_KEY=your_anthropic_api_key_here
```

**Security:**
- ✅ API key stored in .env (already gitignored)
- ✅ Read via `ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]`
- ✅ Validate key exists at app launch
- ✅ Never log API key

---

#### STEP 1.3: Create Keychain Storage for API Key (OPTIONAL - 45 lines)

**File:** `FinanceMate/APIKeyManager.swift`

**Purpose:** Secure API key storage (alternative to .env)

**Key Functions:**
```swift
struct APIKeyManager {
    static func saveAnthropicAPIKey(_ key: String) throws
    static func getAnthropicAPIKey() -> String?
    static func deleteAnthropicAPIKey() throws
}
```

**Lines:** ~45 (✅ KISS COMPLIANT)

**Benefit:** More secure than .env for production builds

---

### PHASE 2: Service Layer Integration (Day 2 - 4-6 hours)

#### STEP 2.1: Create LLM Service (NEW FILE - 150 lines)

**File:** `FinanceMate/LLMFinancialAdvisorService.swift`

**Purpose:** High-level service for financial Q&A with context injection

**Key Components:**
```swift
import Foundation
import CoreData

struct LLMFinancialAdvisorService {
    private let client: AnthropicAPIClient
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext, apiKey: String) {
        self.context = context
        self.client = AnthropicAPIClient(apiKey: apiKey)
    }

    // Answer financial question with context
    func answerQuestion(_ question: String) async throws -> String {
        let systemPrompt = buildSystemPrompt()
        let userContext = buildUserContext()

        let fullQuestion = """
        \(userContext)

        User Question: \(question)
        """

        let messages = [Message(role: "user", content: fullQuestion)]
        return try await client.sendMessageSync(messages: messages, systemPrompt: systemPrompt)
    }

    // Build system prompt with Australian expertise
    private func buildSystemPrompt() -> String {
        return """
        You are a professional Australian financial advisor assistant integrated into FinanceMate,
        a wealth management application. You have expertise in:

        - Australian taxation (ATO compliance, CGT, negative gearing, SMSF)
        - Personal budgeting and expense management
        - Investment strategies (shares, property, crypto)
        - Financial goal setting and tracking

        Provide concise, actionable advice. Always consider Australian tax implications.
        Be professional but friendly. If asked about specific user data, use the context provided.
        """
    }

    // Inject user's financial data into prompt
    private func buildUserContext() -> String {
        let balance = TransactionQueryHelper.getTotalBalance(context: context)
        let count = TransactionQueryHelper.getTransactionCount(context: context)
        let recent = TransactionQueryHelper.getRecentTransactions(context: context, limit: 5)

        var context = """
        User Financial Context:
        - Total Balance: $\(String(format: "%.2f", balance))
        - Transaction Count: \(count)
        """

        if !recent.isEmpty {
            context += "\n- Recent Transactions:\n"
            for tx in recent {
                context += "  * \(tx.itemDescription): $\(String(format: "%.2f", tx.amount)) on \(tx.date.formatted())\n"
            }
        }

        return context
    }
}
```

**Lines:** ~150 (✅ KISS COMPLIANT)

**Testing:**
- Test with mock context (no transactions)
- Test with real transactions
- Test system prompt quality
- Test context injection

---

#### STEP 2.2: Modify FinancialKnowledgeService (MAJOR REFACTOR - 120 lines)

**File:** `FinancialKnowledgeService.swift`

**Changes:**
1. **REMOVE** all 3 static dictionaries (lines 8-32) - **DELETE 25 LINES**
2. **ADD** LLM service integration
3. **KEEP** fallback for network failures

**New Architecture:**
```swift
struct FinancialKnowledgeService {

    static func processQuestion(_ question: String, context: NSManagedObjectContext?, apiKey: String?) async -> (content: String, hasData: Bool, actionType: ActionType, questionType: FinancialQuestionType?, qualityScore: Double) {

        let questionType = classifyQuestion(question)

        // PRIORITY 1: Try Core Data + LLM
        if let context = context, let apiKey = apiKey {
            do {
                let service = LLMFinancialAdvisorService(context: context, apiKey: apiKey)
                let response = try await service.answerQuestion(question)
                let qualityScore = calculateQualityScore(response: response, question: question)
                return (response, true, .analyzeExpenses, questionType, qualityScore)
            } catch {
                // Log error, fall through to fallback
                print("LLM API failed: \(error.localizedDescription), using fallback")
            }
        }

        // PRIORITY 2: Try data-aware responses (no LLM needed)
        if let context = context, let dataResponse = DataAwareResponseGenerator.generate(question: question, context: context) {
            let qualityScore = calculateQualityScore(response: dataResponse.content, question: question)
            return (dataResponse.content, true, dataResponse.actionType, dataResponse.questionType, qualityScore)
        }

        // PRIORITY 3: Generic fallback (network failure or no API key)
        let fallbackResponse = generateGenericFallback(questionType: questionType)
        let qualityScore = calculateQualityScore(response: fallbackResponse, question: question)
        return (fallbackResponse, false, .none, questionType, qualityScore)
    }

    private static func generateGenericFallback(questionType: FinancialQuestionType) -> String {
        switch questionType {
        case .basicLiteracy:
            return "This is a fundamental financial concept. Consider using FinanceMate's transaction tracking to better understand your money management."
        case .personalFinance:
            return "This requires balancing multiple financial factors. FinanceMate can help you track and analyze your financial situation."
        case .australianTax:
            return "This involves Australian tax regulations. FinanceMate supports Australian tax categories. Consult a professional tax advisor for personalized advice."
        case .financeMateSpecific:
            return "FinanceMate provides tools for tracking transactions, analyzing spending, and managing your finances. Explore the Dashboard and Transactions tabs."
        default:
            return "I'd be happy to help with your financial questions. Try asking about your balance, spending, or specific financial topics."
        }
    }
}
```

**Lines After Refactor:** ~120 (✅ KISS COMPLIANT - DOWN from 184)

**Impact:**
- ✅ Removes ALL mock data (BLUEPRINT line 49 compliant)
- ✅ Integrates real LLM (BLUEPRINT line 51 compliant)
- ✅ Maintains fallback for reliability
- ✅ Reduces file size by 64 lines

---

#### STEP 2.3: Update ChatbotViewModel (ASYNC CHANGES - 110 lines)

**File:** `ChatbotViewModel.swift`

**Change:** Make `sendMessage()` async to support LLM streaming

**Current (Line 34):**
```swift
func sendMessage(_ content: String) async {
```

**Modified:**
```swift
func sendMessage(_ content: String) async {
    guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

    let userMessage = ChatMessage(content: content, role: .user)
    messages.append(userMessage)

    isProcessing = true
    defer { isProcessing = false }

    let startTime = Date()

    // Get API key from environment/keychain
    let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]

    // Call async LLM service
    let result = await FinancialKnowledgeService.processQuestion(content, context: context, apiKey: apiKey)
    let responseTime = Date().timeIntervalSince(startTime)

    let assistantMessage = ChatMessage(
        content: result.content,
        role: .assistant,
        hasData: result.hasData,
        actionType: result.actionType,
        questionType: result.questionType,
        qualityScore: result.qualityScore,
        responseTime: responseTime
    )

    messages.append(assistantMessage)
    updateQualityMetrics(result.qualityScore)
}
```

**Lines:** ~110 (✅ KISS COMPLIANT)

---

### PHASE 3: Testing & Validation (Day 3 - 4-6 hours)

#### STEP 3.1: Create LLM Integration Tests (NEW FILE - 95 lines)

**File:** `FinanceMateTests/LLMFinancialAdvisorServiceTests.swift`

**Test Coverage:**
```swift
class LLMFinancialAdvisorServiceTests: XCTestCase {
    // MARK: - API Client Tests
    func testAnthropicAPIClient_InvalidKey_ThrowsError()
    func testAnthropicAPIClient_ValidKey_ReturnsResponse()
    func testAnthropicAPIClient_NetworkFailure_ThrowsError()

    // MARK: - Service Tests
    func testLLMService_WithContext_InjectsUserData()
    func testLLMService_SystemPrompt_IncludesAustralianExpertise()
    func testLLMService_AnswerQuestion_ReturnsNaturalLanguage()

    // MARK: - Integration Tests
    func testChatbot_WithLLM_UsesRealAPI()
    func testChatbot_NetworkFailure_FallsBackGracefully()
    func testChatbot_NoAPIKey_UsesFallback()
}
```

**Lines:** ~95 (✅ KISS COMPLIANT)

---

#### STEP 3.2: Manual Validation Checklist

**Test Scenarios:**

1. **Real LLM Response Test:**
   - **Question:** "Should I invest in property or shares in the current Australian market?"
   - **Expected:** Natural language response with Australian market context (NOT keyword match)
   - **Success:** Response length >50 words, mentions specific Australian factors

2. **Context Injection Test:**
   - **Question:** "Based on my spending, am I on track?"
   - **Expected:** Response references actual balance and transactions from Core Data
   - **Success:** Response contains "$X.XX" matching actual balance

3. **Fallback Test:**
   - **Setup:** Remove ANTHROPIC_API_KEY from .env
   - **Question:** "What is negative gearing?"
   - **Expected:** Generic fallback response (not crash)
   - **Success:** App continues functioning, shows helpful fallback

4. **Streaming UI Test:**
   - **Question:** "Explain capital gains tax in detail"
   - **Expected:** Response appears word-by-word (streaming)
   - **Success:** Typing indicator shows, text streams in

---

## RISK ASSESSMENT & MITIGATION:

### **Risk 1: API Costs** 💰 **HIGH**

**Issue:** Claude API charges per token (input + output)
- Estimated: $0.03 per chatbot interaction (100k input + 2k output tokens)
- With 100 queries/day: ~$3/day = $90/month

**Mitigation:**
- Set daily spending limit ($5/day)
- Implement request caching (identical questions)
- Prompt optimization (reduce input tokens)
- Show cost to user (opt-in for expensive queries)

---

### **Risk 2: Rate Limiting** ⚠️ **MEDIUM**

**Issue:** Anthropic API has rate limits (50 requests/min for paid tier)

**Mitigation:**
- Implement exponential backoff (3 retries)
- Queue requests during high load
- Show "Please wait" message to user
- Fall back to data-aware responses if rate limited

---

### **Risk 3: Network Failures** ⚠️ **MEDIUM**

**Issue:** API calls fail offline or with poor connectivity

**Mitigation:**
- Detect network status before API call
- Fall back to DataAwareResponseGenerator
- Show offline indicator
- Cache recent responses

---

### **Risk 4: Response Quality Inconsistency** ⚠️ **MEDIUM**

**Issue:** LLM may give inaccurate or inconsistent advice

**Mitigation:**
- Include disclaimer: "AI-generated advice, consult professional"
- System prompt emphasizes Australian compliance
- Quality scoring with thresholds (reject <5/10)
- User feedback mechanism ("Was this helpful?")

---

### **Risk 5: Prompt Injection Attacks** 🔒 **LOW**

**Issue:** User could manipulate prompts to extract sensitive data

**Mitigation:**
- Sanitize user input (remove control characters)
- Don't include PII in prompts
- Use Anthropic's safety features
- Monitor for unusual queries

---

## FILES TO CREATE/MODIFY:

### **Created (3 new files, ~425 lines total):**
1. `AnthropicAPIClient.swift` (180 lines) - API client with streaming
2. `LLMFinancialAdvisorService.swift` (150 lines) - Financial Q&A service
3. `LLMFinancialAdvisorServiceTests.swift` (95 lines) - Test suite

### **Modified (2 files, -25 lines total):**
1. `FinancialKnowledgeService.swift` (-64 lines, +39 lines = 120 total)
2. `ChatbotViewModel.swift` (+8 lines = 110 total)

### **Configuration:**
1. `.env.template` (+1 line for ANTHROPIC_API_KEY)
2. `.env` (local only - add actual API key)

**Total New Code:** ~425 lines (all files <200 lines ✅ KISS COMPLIANT)

---

## TESTING STRATEGY:

### **Unit Tests (95 test lines):**
- API client error handling
- Service layer context injection
- System prompt quality
- Fallback mechanisms

### **Integration Tests:**
- End-to-end LLM query flow
- Context data injection verification
- Streaming response handling
- Network failure resilience

### **Manual Tests (CRITICAL for A-V-A Protocol):**
- Ask complex financial questions
- Verify responses are AI-generated (not keyword matched)
- Test with real user financial data
- Capture screenshots for proof

---

## DEPLOYMENT STEPS:

### **Day 1: Foundation**
1. Create `AnthropicAPIClient.swift` with streaming support
2. Configure API key in .env (user provides key)
3. Create basic unit tests for API client
4. Validate with simple "Hello" query

### **Day 2: Integration**
1. Create `LLMFinancialAdvisorService.swift` with context injection
2. Refactor `FinancialKnowledgeService.swift` to use LLM
3. Update `ChatbotViewModel.swift` for async flow
4. Remove static dictionaries (BLUEPRINT compliance)

### **Day 3: Testing & Validation**
1. Create comprehensive test suite
2. Manual testing with real API key
3. Screenshot campaign (A-V-A protocol proof)
4. Code review with `code-reviewer` agent
5. User acceptance testing

---

## SUCCESS METRICS:

### **Code Quality:**
- ✅ All files remain <200 lines (KISS)
- ✅ Comprehensive error handling
- ✅ Security: No API keys in code/logs
- ✅ Target quality: >85/100 (up from 78/100)

### **BLUEPRINT Compliance:**
- ✅ Line 49: NO mock data (static dictionaries removed)
- ✅ Line 51: Frontier model capable (Claude Sonnet 4 integrated)
- ✅ Line 52: Context-aware (user data injected into prompts)

### **Functional:**
- ✅ Natural language understanding (not keyword matching)
- ✅ Australian financial expertise (via prompt engineering)
- ✅ Personalized responses (uses user's actual data)
- ✅ Graceful degradation (fallback when offline)

---

## ESTIMATED COSTS:

### **Development:**
- **Time:** 2-3 days (16-24 hours)
- **Complexity:** Level 4 (requires user approval)
- **Agent:** ai-engineer + security-analyzer

### **Ongoing API Costs:**
- **Claude API:** ~$3/day with moderate use (100 queries)
- **Monthly:** ~$90/month (API costs)
- **Optimization:** Caching could reduce to ~$30-50/month

---

## USER APPROVAL REQUIRED:

**This plan requires explicit user approval because:**
1. **Complexity Level 4** - Complex/Advanced changes
2. **API costs** - Ongoing expenses ($30-90/month)
3. **Major refactoring** - Removes 64 lines, adds 425 lines
4. **Network dependency** - Requires internet connectivity
5. **Security considerations** - API key management

**User Decision Needed:**
- ✅ **APPROVE**: Proceed with LLM integration (2-3 days)
- ❌ **REJECT**: Keep current keyword matching (0 cost, offline-capable)
- 🔄 **MODIFY**: Alternative approach (different LLM, different architecture)

---

**Current Status:** ⏳ **AWAITING USER APPROVAL**

**Alternative Option:** Use local LLM (Ollama with Llama 3) for $0 API costs but lower quality responses
