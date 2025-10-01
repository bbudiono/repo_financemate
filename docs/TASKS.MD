# FINANCEMATE MVP TASKS - PRODUCTION ROADMAP

**Version**: 1.0.0-MVP-FOUNDATION
**Last Updated**: 2025-10-02
**Status**: Foundation complete, P0 fixes applied, ready for feature implementation
**Coordination**: technical-project-lead agent

---

## ✅ COMPLETED (2025-10-02)

### **Foundation Complete** (Commit: 1e7d7eb1)
- [x] Core app structure (501 lines, 11 files)
- [x] 100% KISS compliance (all files <200 lines)
- [x] Build: SUCCESS
- [x] App launches with 3 tabs functional
- [x] E2E test suite created (6/6 passing)
- [x] P0 security fixes (0 force unwraps, 0 fatalError)
- [x] Quality: 8.0/10 (up from 6.2/10)

---

## 🎯 P0 BLOCKERS (Required for MVP Production Release)

### **TASK 1: Apple Sign In SSO**
**Priority:** P0 BLOCKER
**BLUEPRINT:** Line 64 - "SSO REQUIRED: THIS IS FUCKING MANDATORY"
**Effort:** 4-6 hours (2 TDD cycles)
**Status:** Not started

**Atomic Changes:**
- [ ] Create AuthenticationManager.swift (≤50 lines)
- [ ] Add Sign in with Apple button to ContentView
- [ ] Implement secure token storage
- [ ] Add authentication state management
- [ ] Test with real Apple ID (sandbox)

**Success Criteria:**
- Apple Sign In button functional
- Token persists in Keychain
- Auth state survives app restart
- 5/5 unit tests passing

**Agents:** security-analyzer, engineer-swift

---

### **TASK 2: Google Sign In SSO**
**Priority:** P0 BLOCKER
**BLUEPRINT:** Line 64 - SSO requirement
**Effort:** 4-6 hours (2 TDD cycles)
**Status:** Not started
**Depends on:** TASK 1

**Atomic Changes:**
- [ ] Add GoogleSignIn SDK dependency
- [ ] Extend AuthenticationManager (≤40 lines)
- [ ] Implement OAuth callback handling
- [ ] Add Google Sign In button
- [ ] Test with real Google account

**Success Criteria:**
- Google OAuth flow completes
- Refresh token managed automatically
- 5/5 Google auth tests passing

**Agents:** security-analyzer, engineer-swift

---

### **TASK 3: Gmail API OAuth Flow**
**Priority:** P0 BLOCKER
**BLUEPRINT:** Line 45 - "Pull expenses from gmail"
**Effort:** 6-9 hours (3 TDD cycles)
**Status:** Partial (UI exists, needs OAuth connection)
**Depends on:** TASK 2

**Atomic Changes:**
- [ ] Implement OAuth authorization in GmailViewModel (≤40 lines)
- [ ] Add automatic token refresh (≤30 lines)
- [ ] Test with bernhardbudiono@gmail.com
- [ ] Verify emails display in app UI
- [ ] Add refresh button and error handling

**Success Criteria:**
- OAuth completes with real Gmail account
- Emails visible in UI (screenshot proof)
- Token refresh automatic
- 6/6 Gmail tests passing

**Agents:** api-tester, security-analyzer, engineer-swift

---

### **TASK 4: Email Receipt Parsing**
**Priority:** P0 BLOCKER
**BLUEPRINT:** Line 46 - "Every line item captured"
**Effort:** 6-9 hours (3 TDD cycles)
**Status:** Not started
**Depends on:** TASK 3

**Atomic Changes:**
- [ ] Create EmailParser.swift (≤50 lines)
- [ ] Implement regex for common receipt formats
- [ ] Create TransactionExtractor.swift (≤50 lines)
- [ ] Add confidence scoring (≥80% threshold)
- [ ] Test with real emails from Gmail

**Success Criteria:**
- Parse 5+ common receipt formats
- Extract amount, date, merchant, category
- 10/10 parsing tests with real email data

**Agents:** data-engineer, test-writer, engineer-swift

---

### **TASK 5: Auto Transaction Creation**
**Priority:** P0 BLOCKER
**BLUEPRINT:** Line 50 - "Single table of expenses"
**Effort:** 4-6 hours (2 TDD cycles)
**Status:** Not started
**Depends on:** TASK 4

**Atomic Changes:**
- [ ] Extend TransactionsViewModel (≤40 lines)
- [ ] Implement createFromEmail() method
- [ ] Add duplicate detection (amount + date + merchant)
- [ ] Add user confirmation dialog
- [ ] Save to Core Data

**Success Criteria:**
- Email creates transaction automatically
- Duplicates prevented
- User can confirm/reject
- 8/8 tests passing

**Agents:** code-reviewer, engineer-swift

---

### **TASK 6: AI Financial Chatbot**
**Priority:** P0 BLOCKER
**BLUEPRINT:** Line 60 - "Persistent Chatbot on right side"
**Effort:** 6-8 hours (3 TDD cycles)
**Status:** Not started
**Depends on:** TASK 2

**Atomic Changes:**
- [ ] Create MCPClient.swift (≤50 lines)
- [ ] Implement HTTP 404 fallback handling
- [ ] Create ChatbotView.swift (≤50 lines)
- [ ] Add ChatMessage model (≤20 lines)
- [ ] Test with MCP server or local responses

**Success Criteria:**
- Chat interface renders correctly
- User can ask financial questions
- Responses from MCP or fallback
- 13/13 chatbot tests passing

**Agents:** api-tester, ui-ux-architect, backend-architect

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