# FINANCEMATE MVP TASKS - PRODUCTION ROADMAP

**Version**: 1.0.0-MVP-FOUNDATION
**Last Updated**: 2025-10-02
**Status**: Quality assessment complete - 4 P0 BLUEPRINT blockers identified
**Code Quality**: 92/100 (A) | **UX Quality**: 82/100 (B+)
**BLUEPRINT Compliance**: 62% complete
**Coordination**: technical-project-lead agent

---

## ✅ COMPLETED (2025-10-02)

### **Foundation + Quality Assessment** (Commit: 15a00a07)
- [x] Core app structure (776 lines, 15 Swift files)
- [x] 100% KISS compliance (all files <200 lines, largest 85)
- [x] Build: GREEN with Apple code signing
- [x] E2E tests: 7/7 passing
- [x] Security: 9.5/10 (zero critical violations)
- [x] Apple Sign In SSO implemented
- [x] Gmail OAuth with browser code exchange
- [x] Settings tab with user preferences
- [x] Code review: 92/100 (EXCELLENT)
- [x] UX review: 82/100 (GOOD)

---

## 🚨 P0 BLOCKERS (4 Critical Gaps - 5-7 Days Total Effort)

### **BLOCKER 1: Gmail Transaction Extraction**
**Priority:** P0 CRITICAL - HIGHEST PRIORITY
**BLUEPRINT:** Lines 62-66 - "Pull expenses from gmail, every line item captured"
**Current Status:** Email fetching works, but NO transaction/receipt extraction
**Effort:** 2-3 days (16-24 hours)
**Quality Gap:** Blocks 38% of BLUEPRINT compliance

**Required Implementation:**
- [ ] Add receipt/invoice OCR parsing to GmailAPI.swift
- [ ] Implement line item extraction logic
- [ ] Create transaction mapping in GmailViewModel.swift
- [ ] Parse email dates from headers (fix hardcoded Date())
- [ ] Add confidence scoring for extractions
- [ ] Implement transaction creation from parsed data
- [ ] Add manual review UI for low-confidence matches

**Success Criteria:**
- Extract receipts from bernhardbudiono@gmail.com
- Parse line items (description, amount, date, merchant)
- Create Transaction entities with proper categories
- 80%+ extraction accuracy on test emails
- User can review/approve extracted transactions

**Files to Modify:**
- GmailAPI.swift (add parsing methods, keep <200 lines)
- GmailViewModel.swift (add extraction logic)
- GmailView.swift (add review UI)
- Transaction.swift (add source field)

**Agents:** data-engineer, engineer-swift

---

### **BLOCKER 2: Tax Category Support**
**Priority:** P0 CRITICAL
**BLUEPRINT:** Line 63 - "Every line item must have tax categories field"
**Current Status:** Transaction entity has NO tax category field
**Effort:** 1 day (8 hours)
**Quality Gap:** Core financial compliance feature missing

**Required Implementation:**
- [ ] Add taxCategory field to Transaction entity
- [ ] Update PersistenceController with migration
- [ ] Create TaxCategory enum (Personal, Business, Investment, etc.)
- [ ] Update TransactionsView to display/edit tax categories
- [ ] Add tax category picker to transaction creation
- [ ] Implement percentage-based split allocation UI (future)

**Success Criteria:**
- Transaction entity has taxCategory field
- Core Data migration completes without data loss
- UI allows tax category selection
- Filtering by tax category works
- Australian compliance (ATO categories supported)

**Files to Modify:**
- Transaction.swift (add taxCategory field)
- PersistenceController.swift (add migration)
- TransactionsView.swift (add category display/edit)
- DashboardView.swift (add category filtering)

**Agents:** data-engineer, engineer-swift

---

### **BLOCKER 3: Google Sign In SSO**
**Priority:** P0 CRITICAL
**BLUEPRINT:** Line 81 - "SSO REQUIRED: Functional Apple and Google SSO"
**Current Status:** Apple SSO implemented, Google missing
**Effort:** 4 hours
**Quality Gap:** User authentication options incomplete

**Required Implementation:**
- [ ] Add Google Sign In SDK dependency (Swift Package Manager)
- [ ] Extend AuthenticationManager (add Google auth methods)
- [ ] Add Google Sign In button to LoginView
- [ ] Implement OAuth 2.0 callback handling
- [ ] Test with real Google account

**Success Criteria:**
- Google Sign In button appears on LoginView
- OAuth flow completes successfully
- User credentials stored in Keychain
- Auth state persists across app restarts
- 100% feature parity with Apple Sign In

**Files to Modify:**
- AuthenticationManager.swift (add Google methods)
- LoginView.swift (add Google button)
- Package dependencies (add GoogleSignIn SDK)

**Agents:** security-analyzer, engineer-swift

---

### **BLOCKER 4: AI Chatbot Drawer Integration**
**Priority:** P0 CRITICAL
**BLUEPRINT:** Lines 52, 60 - "Persistent Chatbot on right side via collapsible drawer"
**Current Status:** ❌ KISS VIOLATION DISCOVERED - Cannot deploy from Sandbox
**Effort:** 1-2 days (8-16 hours) - **REVISED FROM 2 HOURS**
**Quality Gap:** Core AI assistant feature not accessible + KISS violations

**CRITICAL DISCOVERY (2025-10-02):**
- ChatbotDrawerView.swift: 436 lines (VIOLATES <200 line limit)
- ChatbotViewModel.swift: 425 lines (VIOLATES <200 line limit)
- Files exist ONLY in Sandbox, NOT in Production
- **Cannot copy directly** - requires ATOMIC TDD refactoring first

**Required Refactoring (MANDATORY):**
- [ ] Split ChatbotDrawerView into modular components:
  - ChatbotDrawer.swift (<100 lines) - Main container
  - MessageBubble.swift (<50 lines) - Message display
  - TypingIndicator.swift (<30 lines) - Animation component
  - QuickActions.swift (<50 lines) - Quick action buttons
- [ ] Split ChatbotViewModel into focused components:
  - ChatbotViewModel.swift (<100 lines) - Core state
  - MessageService.swift (<80 lines) - Message handling
  - MCPClient.swift (<80 lines) - MCP integration
- [ ] Create ChatMessage.swift model (<30 lines)
- [ ] Integrate refactored components into Production ContentView
- [ ] Test with E2E validation

**Success Criteria:**
- ALL files <200 lines (KISS compliance)
- Chatbot drawer functional from all tabs
- Smooth animations with spring physics
- MCP integration or graceful fallback
- 100% E2E test passage

**Files to Create/Modify:**
- ChatbotDrawer.swift (NEW - <100 lines)
- ChatbotViewModel.swift (NEW - <100 lines)
- MessageBubble.swift (NEW - <50 lines)
- MessageService.swift (NEW - <80 lines)
- ChatMessage.swift (NEW - <30 lines)
- ContentView.swift (MODIFY - add ZStack integration)

**Agents:** refactor, code-reviewer, engineer-swift, ui-ux-architect

**RECOMMENDATION:** Defer to after BLOCKER 3 (Google SSO) - simpler 4-hour task

---

## 📈 TIMELINE & MILESTONES

**Week 1: Authentication Foundation**
- Days 1-2: TASK 1 (Apple SSO)
- Days 2-3: TASK 2 (Google SSO)
- **Milestone:** SSO Complete ✅

**Week 2: Gmail Integration**
- Days 4-5: TASK 3 (Gmail OAuth)
- Days 6-7: TASK 4 (Email Parsing)
- Day 8: TASK 5 (Auto Transactions)
- **Milestone:** Gmail Integration Complete ✅

**Week 3: AI & Polish**
- Days 9-10: TASK 6 (AI Chatbot)
- Days 11-12: User acceptance testing
- Days 13-14: Bug fixes and polish
- **Milestone:** MVP PRODUCTION READY ✅

**Total:** 2-3 weeks to production deployment

---

## 🔒 VALIDATION REQUIREMENTS (A-V-A Protocol)

**Every task requires:**
1. Build: GREEN (zero warnings)
2. E2E tests: 100% passing
3. Screenshot proof: Functionality visible
4. Code review: ≥8.5/10 quality score
5. User acceptance: Explicit approval before next task

**Quality Gates (NON-NEGOTIABLE):**
- All files <200 lines (KISS)
- Zero force unwraps
- Zero fatalError calls
- Proper error handling
- Real data only (no mocks)

---

**Current Status:** Foundation solid, ready for SSO implementation
**Next Action:** Await user approval to begin TASK 1 (Apple Sign In)