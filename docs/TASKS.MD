# FINANCEMATE MVP TASKS - CLEAN START

**Version**: 1.0.0-NUCLEAR-RESET
**Last Updated**: 2025-09-30
**Status**: Fresh rebuild from scratch - ZERO code, ZERO debt

---

## 🎯 MVP REBUILD PRIORITIES (KISS-First, <200 lines/file)

### **P0: Core App Foundation** (Day 1 - 4 hours)

- [ ] Create FinanceMateApp.swift (50 lines - app entry point)
- [ ] Create ContentView.swift (100 lines - simple TabView with 3 tabs)
- [ ] Implement DashboardView.swift (120 lines - balance cards)
- [ ] Setup Core Data with Transaction entity (80 lines - PersistenceController)
- [ ] Verify: App launches, shows Dashboard, tabs switch correctly

### **P1: Gmail Integration** (Day 2 - 6 hours)

- [ ] Create GmailViewModel.swift (150 lines - OAuth + email fetching)
- [ ] Create GmailView.swift (180 lines - connect button + email list)
- [ ] Implement OAuth flow using .env credentials (GOOGLE_OAUTH_CLIENT_ID/SECRET)
- [ ] Store tokens in Keychain (simple KeychainHelper.swift - 80 lines)
- [ ] Fetch 10 emails from Gmail API
- [ ] Display emails in List (sender, subject, date)
- [ ] **VERIFY MANUALLY**: See emails in app UI (screenshot proof)

### **P2: Transaction Creation** (Day 3 - 2 hours)

- [ ] Click email → create Transaction (TransactionsViewModel.swift - 120 lines)
- [ ] Save to Core Data
- [ ] Display in Transactions tab (TransactionsView.swift - 150 lines)
- [ ] **VERIFY MANUALLY**: Transaction appears in list

---

## 📋 VALIDATION REQUIREMENTS (NO FALSE CLAIMS)

**Every task requires:**
1. Build: GREEN
2. Manual verification: Screenshot showing it works
3. E2E test: Validates the actual functionality (not just files exist)
4. NO "completed" until USER confirms it works

**File Size Limits:**
- Maximum: 200 lines per file (KISS principle)
- If >200 lines: BLOCKED - must split into smaller files

**Quality Target:**
- Start: 9.0/10 minimum (vs previous 6.8/10)
- Maintain throughout rebuild

---

## 🚫 LESSONS FROM FAILED ATTEMPT

**What Went Wrong (Sessions 1-6):**
- 116,000 lines of code
- 183 KISS violations (61.6% files >200 lines)
- 628 force unwraps
- E2E tests passed but Gmail didn't work
- False completion claims

**What We're Doing Different:**
- KISS from day 1 (<200 lines/file)
- Manual verification BEFORE claiming completion
- E2E tests validate ACTUAL functionality
- No force unwraps (use guard/if-let)
- Honest assessment only

---

**Current Status**: Branch `rebuild/mvp-from-scratch` - Clean slate, ready to build
