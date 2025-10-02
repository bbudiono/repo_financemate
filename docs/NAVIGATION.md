# Navigation & Sitemap Documentation

**Project**: FinanceMate
**Type**: Native macOS Application (SwiftUI)
**Framework**: SwiftUI with MVVM Architecture
**Last Updated**: 2025-10-02
**Total Views**: 6 (Dashboard, Transactions, Gmail, Settings, Login, Chatbot)
**Status**: ✅ Complete

---

## 1. View Hierarchy

### Public Views (No Authentication Required)

| View | Component | File Path | Purpose | Authentication |
|------|-----------|-----------|---------|----------------|
| Login | LoginView | FinanceMate/LoginView.swift | SSO authentication (Apple + Google) | None |

### Protected Views (Authentication Required)

| View | Component | File Path | Purpose | Data Source | Tab Navigation |
|------|-----------|-----------|---------|-------------|----------------|
| Dashboard | DashboardView | FinanceMate/DashboardView.swift | Financial overview with balance/transactions summary | Core Data | Tab 1 |
| Transactions | TransactionsView | FinanceMate/TransactionsView.swift | Transaction management with CRUD operations | Core Data (Transaction entity) | Tab 2 |
| Gmail | GmailView | FinanceMate/GmailView.swift | Gmail integration for receipt/invoice extraction | Gmail API + Core Data | Tab 3 |
| Settings | SettingsView | FinanceMate/SettingsView.swift | User preferences and account settings | UserDefaults + Keychain | Tab 4 |
| Chatbot | ChatbotDrawer | FinanceMate/ChatbotDrawer.swift | AI financial assistant (collapsible right drawer) | Core Data + LLM API | Overlay |

### Content Container

| View | Component | File Path | Purpose |
|------|-----------|-----------|---------|
| Main Container | ContentView | FinanceMate/ContentView.swift | TabView navigation + Chatbot overlay |

---

## 2. Navigation Flows

### Flow 1: First Launch & Authentication
```
Step 1: LoginView (SSO Screen)
  ↓ User selects "Sign in with Apple" OR "Sign in with Google"
Step 2: System OAuth Flow
  ↓ OAuth authorization completes
Step 3: ContentView → DashboardView (Tab 1)
  ✅ User Authenticated - Lands on Dashboard
```

### Flow 2: Transaction Management
```
Step 1: ContentView → DashboardView (Tab 1)
  ↓ User clicks "Transactions" tab
Step 2: TransactionsView (Tab 2)
  ↓ View all transactions (filterable, searchable, sortable)
Step 3a: Add Transaction (+ button)
  ↓ Create new transaction manually
Step 3b: Edit Transaction (click row)
  ↓ Modify existing transaction
Step 3c: Delete Transaction (swipe left)
  ↓ Remove transaction
  ✅ Transaction CRUD Complete
```

### Flow 3: Gmail Receipt Extraction
```
Step 1: ContentView → DashboardView (Tab 1)
  ↓ User clicks "Gmail" tab
Step 2: GmailView (Tab 3)
  ↓ User clicks "Authorize Gmail"
Step 3: Google OAuth Consent Screen (Browser)
  ↓ User grants Gmail access
Step 4: GmailView - Shows email list
  ↓ User clicks "Extract Transactions"
Step 5: Email parsing & transaction extraction
  ↓ Extracted transactions saved to Core Data
Step 6: TransactionsView → See Gmail-sourced transactions
  ✅ Gmail Integration Complete (source="gmail")
```

### Flow 4: AI Chatbot Interaction
```
Step 1: Any authenticated view
  ↓ User clicks chatbot icon (right side)
Step 2: ChatbotDrawer slides in from right
  ↓ User types financial question
Step 3: Chatbot processes query
  ↓ Accesses Core Data context for dashboard data
  ↓ Calls LLM API for natural language response
Step 4: Response displayed with quality score
  ↓ User can ask follow-up questions
Step 5: User clicks close or clicks outside drawer
  ✅ Chatbot Session Complete
```

### Flow 5: Settings Management
```
Step 1: ContentView → DashboardView (Tab 1)
  ↓ User clicks "Settings" tab
Step 2: SettingsView (Tab 4)
  ↓ User views authentication status (Apple/Google)
  ↓ User can sign out
Step 3a: Sign Out
  ↓ Clear session, return to LoginView
Step 3b: Modify Preferences
  ↓ Change app settings (saved to UserDefaults)
  ✅ Settings Updated
```

---

## 3. State Management

### Global Application State

**State Provider**: SwiftUI @StateObject + @EnvironmentObject
**Location**: FinanceMateApp.swift (App entry point)

| State Object | Type | Purpose | Persisted |
|--------------|------|---------|-----------|
| AuthenticationManager | ObservableObject | Apple/Google SSO state, user session | Yes (Keychain) |
| PersistenceController | ObservableObject | Core Data stack management | Yes (SQLite) |

### View-Specific State

| View | Published State | Purpose | Data Source |
|------|-----------------|---------|-------------|
| DashboardView | totalBalance, transactionCount | Financial summary | Core Data query |
| TransactionsView | transactions, isLoading | Transaction list | Core Data fetch |
| GmailView | emails, isAuthorized, authCode | Gmail integration status | Gmail API |
| GmailViewModel | showCodeInput, errorMessage | OAuth flow state | GmailOAuthHelper |
| ChatbotViewModel | messages, isTyping | Chat conversation | Core Data + LLM API |
| SettingsView | theme, notifications | User preferences | UserDefaults |

---

## 4. API Integration Points

### View → API Endpoint Mapping

| View | API Service | Methods | Auth Type | Error Handling |
|------|-------------|---------|-----------|----------------|
| LoginView | AuthenticationManager | Apple SSO, Google OAuth 2.0 | Apple Sign In / Google OAuth | Alert dialog |
| GmailView | GmailAPI + GmailOAuthHelper | OAuth token exchange, email fetch | Google OAuth Bearer token | Error message display |
| GmailView | GmailAPI.extractTransaction() | Transaction extraction from email body | N/A (local parsing) | Confidence scoring |
| ChatbotDrawer | LLM API (Claude/GPT-4.1) | Natural language query processing | API key | Fallback responses |
| All Views | Core Data (PersistenceController) | CRUD operations | N/A (local) | Try-catch with error state |

### API Error Handling by View
- **401 Unauthorized (Gmail)**: Clear OAuth token, prompt re-authorization
- **OAuth Failures**: Show error alert, allow retry
- **Core Data Errors**: Log error, show user-friendly message
- **LLM API Failures**: Fallback to local knowledge base, retry mechanism

---

## 5. Authentication & Authorization

### Authentication Requirements by View

**No Auth Required** (Public Access):
```
LoginView
```

**User Auth Required** (Apple/Google SSO):
```
DashboardView, TransactionsView, GmailView, SettingsView, ChatbotDrawer
```

**OAuth Required** (Gmail):
```
GmailView (email fetching requires separate Gmail OAuth)
```

### Auth Guard Implementation
**Location**: FinanceMateApp.swift
**Strategy**: SwiftUI conditional rendering based on AuthenticationManager.isAuthenticated
**Flow**:
```swift
if authManager.isAuthenticated {
    ContentView() // Show main app
} else {
    LoginView()  // Show login screen
}
```

---

## 6. Tab Navigation Structure

### Main TabView (ContentView.swift)

**Navigation Type**: Bottom Tab Bar (macOS style)
**Tabs**:

| Tab | Icon | View | Badge | Shortcut |
|-----|------|------|-------|----------|
| 1 | Dashboard | DashboardView | None | ⌘1 |
| 2 | Transactions | TransactionsView | Transaction count | ⌘2 |
| 3 | Gmail | GmailView | Unprocessed email count | ⌘3 |
| 4 | Settings | SettingsView | None | ⌘4 |

**Overlay Navigation**:
- Chatbot drawer (ZStack overlay, slides from right)

---

## 7. Navigation Components

### Tab Bar
**Component**: TabView in ContentView.swift
**Style**: macOS native tab bar
**Tabs**: Dashboard, Transactions, Gmail, Settings

### Chatbot Drawer
**Component**: ChatbotDrawer.swift (ZStack overlay)
**Trigger**: Click chatbot icon (right side of screen)
**Animation**: Slide from right, glassmorphism background
**Dismissal**: Click outside drawer or close button

### Navigation State
**Managed By**: SwiftUI @State in ContentView
**Tab Selection**: Binding to selected tab index
**Drawer State**: @State isDrawerOpen boolean

---

## 8. Data Flow Architecture

### Transaction Data Flow
```
1. SOURCE: Gmail API (emails) OR Manual Entry (TransactionsView)
   ↓
2. EXTRACTION: GmailAPI.extractTransaction() → TransactionData
   ↓
3. VALIDATION: GmailViewModel validates merchant, amount, line items
   ↓
4. PERSISTENCE: Save to Core Data (Transaction entity)
   ↓
5. DISPLAY: TransactionsView fetch and display
   ↓
6. ANALYSIS: Chatbot can query via Core Data context
```

### Authentication Data Flow
```
1. USER ACTION: Click "Sign in with Apple" or "Sign in with Google"
   ↓
2. OAUTH FLOW: System handles Apple/Google authentication
   ↓
3. TOKEN STORAGE: AuthenticationManager saves to Keychain
   ↓
4. SESSION PERSISTENCE: User remains authenticated across app launches
   ↓
5. SIGN OUT: Clear Keychain, return to LoginView
```

---

## 9. Core Data Schema

### Entities & Relationships

| Entity | Attributes | Relationships | Purpose |
|--------|------------|---------------|---------|
| Transaction | id (UUID), amount (Double), merchant (String), date (Date), category (String), note (String?), source (String), taxCategory (String) | None | Financial transactions |

### Fetch Requests by View

| View | Fetch Request | Predicate | Sort Descriptor |
|------|---------------|-----------|-----------------|
| DashboardView | All transactions | None | date (descending) |
| TransactionsView | All transactions | Optional: source == "gmail" | date (descending) |
| ChatbotViewModel | Context-aware queries | Dynamic based on user question | Varies |

---

## 10. Error Handling Routes

### Error States by View

| View | Error Type | Display Method | Recovery Action |
|------|-----------|----------------|-----------------|
| LoginView | SSO failure | Alert dialog | Retry button |
| GmailView | OAuth failure | Error message | Re-authorize button |
| GmailView | Email fetch failure | Error message | Retry button |
| TransactionsView | Core Data error | Error message | Reload data |
| ChatbotDrawer | LLM API failure | Error message | Fallback to local knowledge |
| All Views | Network error | Alert/error state | Retry mechanism |

---

## 11. Deep Links & External Navigation

### OAuth Callbacks
- **Apple Sign In**: System-handled redirect (no URL scheme required)
- **Google OAuth**: `http://localhost:8080/oauth/callback` (manual code entry currently)
- **Gmail OAuth**: `http://localhost:8080` (redirect URI for token exchange)

### External Links
- Gmail authorization requires browser redirect
- Apple/Google SSO handled by system (no external browser)

---

## 12. Validation Checklist

Navigation Documentation Completeness:

- ✅ All views documented (6/6 views = 100% coverage)
- ✅ All components mapped to views
- ✅ All file paths specified
- ✅ Auth requirements defined for every view
- ✅ API endpoints mapped to views
- ✅ Navigation flows documented (5 complete flows)
- ✅ State management explained
- ✅ Error handling documented
- ✅ Data flow architecture documented
- ✅ Core Data schema explained
- ✅ Tab navigation structure defined
- ✅ Last updated date current (2025-10-02)

**Completeness**: 12/12 items (100%) ✅

---

## 13. Maintenance

### When to Update This Document
✅ New view added to app
✅ Navigation flow changed
✅ Component renamed or relocated
✅ Auth requirements modified
✅ API endpoint added/changed
✅ Core Data schema updated
✅ Tab structure modified

### Validation Commands
```bash
# Verify all Swift files exist
find _macOS/FinanceMate -name "*.swift" | grep -E "(ContentView|DashboardView|TransactionsView|GmailView|SettingsView|ChatbotDrawer|LoginView)"

# Validate NAVIGATION.md against codebase
python3 ~/.claude/hooks/sitemap_structure_validator.py docs/NAVIGATION.md macos
```

### Review Schedule
- **After every view addition**: Immediate update required
- **Weekly**: Verify accuracy matches codebase
- **Before deployment**: Mandatory validation

---

**Document Version**: 1.0
**Last Modified**: 2025-10-02
**Platform**: macOS (SwiftUI)
**Architecture**: MVVM with TabView Navigation + Overlay Drawer
