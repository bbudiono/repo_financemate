# Build Failures Log

## Navigation Structure

### Routes/Pages

#### Build Failure Views
| Route | Component | Purpose | Status | Resolution Path |
|-------|-----------|---------|--------|-----------------|
| `/build-failures` | BuildFailuresView | Display build failure log | Active | See BF-001 to BF-010 |
| `/build-diagnostics` | BuildDiagnosticsView | Automated build diagnostics | Planned | Future development |
| `/build-recovery` | BuildRecoveryView | Build recovery procedures | Active | Automated scripts |

#### Error Resolution Flow
| Step | Component | Purpose | Navigation | Required Access |
|------|-----------|---------|------------|----------------|
| 1. Detection | Build Monitor | Continuous build monitoring | Automatic | CI/CD System |
| 2. Analysis | Error Classifier | Categorize build failures | Manual | Developer Access |
| 3. Resolution | Solution Database | Access to known solutions | Manual/Manual | Developer Access |
| 4. Validation | Build Verification | Confirm resolution success | Automatic | CI/CD System |

### Authentication Requirements

#### Build System Access
- **Developer Authentication**: Required for build diagnostics access
- **CI/CD Integration**: Automated build monitoring with secure tokens
- **Error Database Access**: Role-based access to resolution procedures
- **Build Artifact Access**: Secure storage for build logs and diagnostics

#### API Integration Security
- **Build Monitoring**: Integration with Xcode Server and GitHub Actions
- **Error Reporting**: Secure transmission of build failure data
- **Solution Database**: Encrypted storage of known failure patterns
- **Recovery Scripts**: Verified automation for common issues

## Summary of Common Failures/Errors
*   **Signing Error:** Code Signing Issues - Key Cause: Missing Developer Team Assignment - Solution Pointer: See BF-001
*   **Core Data Error:** Model Not Found - Key Cause: Missing .xcdatamodeld in Build Phase - Solution Pointer: See BF-002
*   **SwiftUI Preview Error:** Missing Bundle Identifier - Key Cause: Incomplete Xcode Configuration - Solution Pointer: See BF-003
*   **Build Dependency Error:** Package Resolution Failed - Key Cause: Network/Package Manager Issues - Solution Pointer: See BF-004
*   **Runtime Crash:** Force Unwrap Nil - Common Location: `ViewModel.loadData()` - Solution Pointer: Use optional binding, see BF-005
*   **OAuth Integration Error:** Invalid Redirect URI - Key Cause: Google Console Configuration - Solution Pointer: See BF-006

---

## Detailed Log

---

**Failure ID:** BF-001
**Date:** 2025-10-05
**Task/Context:** Production Build Configuration
**Symptoms:** "Code signing error: No signing certificate found" during Archive
**Investigation:** Checked Xcode project settings, found no Developer Team assigned
**Root Cause:** Manual Xcode configuration step missed during automated setup
**Solution:**
1. Open FinanceMate.xcodeproj in Xcode
2. Select FinanceMate target → Signing & Capabilities
3. Choose Team from Apple Developer account
4. Enable "Automatically manage signing"
**Status:** Resolved

---

**Failure ID:** BF-002
**Date:** 2025-10-05
**Task/Context:** Core Data Integration
**Symptoms:** "Could not find NSManagedObjectModel for entity name" at app launch
**Investigation:** Core Data model file exists but not included in build phase
**Root Cause:** FinanceMateModel.xcdatamodeld not added to Target → Build Phases → Compile Sources
**Solution:**
1. Select FinanceMate target → Build Phases → Compile Sources
2. Click + and add FinanceMateModel.xcdatamodeld
3. Clean and rebuild project
**Status:** Resolved

---

**Failure ID:** BF-003
**Date:** 2025-10-04
**Task/Context:** SwiftUI Development
**Symptoms:** "Cannot preview in this file — Failed to load bundle"
**Investigation:** Bundle identifier not configured for preview scheme
**Root Cause:** Incomplete Xcode project configuration for preview scheme
**Solution:**
1. Select FinanceMate-Sandbox scheme → Edit Scheme
2. Set Build Configuration to Debug
3. Ensure bundle identifier matches entitlements
**Status:** Resolved

---

**Failure ID:** BF-004
**Date:** 2025-10-04
**Task/Context:** Package Management
**Symptoms:** "Source control error: Failed to resolve package dependencies"
**Investigation:** Network connectivity issues and package registry timeouts
**Root Cause:** Package resolution timeouts during dependency fetch
**Solution:**
1. Check network connectivity
2. Clear package cache: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Reset package resolutions in Xcode → File → Packages → Reset Package Caches
4. Retry package resolution
**Status:** Resolved

---

**Failure ID:** BF-005
**Date:** 2025-10-06
**Task/Context:** ViewModel Development
**Symptoms:** Runtime crash: "Fatal error: Unexpectedly found nil while unwrapping an Optional value"
**Investigation:** Force unwrapping Core Data results without nil checking
**Root Cause:** Unsafe optional handling in ViewModel data loading
**Solution:** Replace force unwraps (`!`) with optional binding:
```swift
// Before (unsafe)
let transactions = fetchedResults![indexPath.row]

// After (safe)
guard let transactions = fetchedResults?[indexPath.row] else { return }
```
**Status:** Resolved

---

**Failure ID:** BF-006
**Date:** 2025-10-06
**Task/Context:** Google OAuth Integration
**Symptoms:** "redirect_uri_mismatch" error during OAuth flow
**Investigation:** Google Cloud Console OAuth configuration mismatch
**Root Cause:** Redirect URI in Google Console doesn't match application configuration
**Solution:**
1. Go to Google Cloud Console → APIs & Services → Credentials
2. Edit OAuth 2.0 Client ID
3. Add authorized redirect URIs:
   - `http://localhost:8080/oauth/callback`
   - `com.ablankcanvas.financemate://oauth/callback`
4. Update environment configuration
**Status:** Resolved

---

**Failure ID:** BF-007
**Date:** 2025-10-06
**Task/Context:** Gmail API Integration
**Symptoms:** "Invalid Credentials" error when accessing Gmail API
**Investigation:** OAuth token refresh failure
**Root Cause:** Access token expired, refresh token not properly stored/retrieved
**Solution:**
1. Implement proper token refresh logic in EmailOAuthManager
2. Store refresh token securely in Keychain
3. Handle token refresh before API calls
4. Re-authenticate user if refresh token invalid
**Status:** Resolved

---

**Failure ID:** BF-008
**Date:** 2025-10-06
**Task/Context:** Anthropic API Integration
**Symptoms:** "Invalid API Key" error from Claude API
**Investigation:** API key not properly loaded from environment variables
**Root Cause:** .env file not found or malformed environment configuration
**Solution:**
1. Ensure .env file exists in project root
2. Verify ANTHROPIC_API_KEY is properly formatted
3. Check .env file is added to .gitignore
4. Restart Xcode after .env changes
**Status:** Resolved

---

**Failure ID:** BF-009
**Date:** 2025-10-06
**Task/Context:** App Sandbox Configuration
**Symptoms:** "Operation not permitted" errors when accessing file system
**Investigation:** App Sandbox entitlements not properly configured
**Root Cause:** Missing sandbox entitlements for required file access
**Solution:**
1. Enable App Sandbox in Signing & Capabilities
2. Add required entitlements:
   - Network Outgoing (for API calls)
   - File System Read/Write Access (user selected files)
3. Request appropriate permissions at runtime
**Status:** Resolved

---

**Failure ID:** BF-010
**Date:** 2025-10-06
**Task/Context:** Test Execution
**Symptoms:** "Test target FinanceMateTests not found" during xcodebuild test
**Investigation:** Test target not properly configured in Xcode project
**Root Cause:** Missing test scheme configuration
**Solution:**
1. Check test target exists in Xcode project
2. Create test scheme: Product → Scheme → Manage Schemes → +
3. Enable shared test scheme
4. Verify test target in scheme settings
**Status:** Resolved

---

## **TROUBLESHOOTING WORKFLOW**

### **Before Opening Issues**
1. **Clean Build**: Product → Clean Build Folder
2. **Clear Derived Data**: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. **Restart Xcode**: Complete application restart
4. **Check Environment**: Verify .env file configuration
5. **Network Check**: Ensure internet connectivity for API integrations

### **Common Debug Commands**
```bash
# Clean build
xcodebuild clean -project FinanceMate.xcodeproj -scheme FinanceMate

# Full rebuild
xcodebuild build -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug

# Run tests with detailed output
xcodebuild test -project FinanceMate.xcodeproj -scheme FinanceMate -destination 'platform=macOS' -verbose

# Check signing configuration
xcodebuild -showBuildSettings -project FinanceMate.xcodeproj -scheme FinanceMate | grep -i sign
```

### **Log Locations**
- **Build Logs**: Xcode → Report Navigator → Build
- **Test Logs**: Xcode → Report Navigator → Test
- **Console Logs**: Console.app → FinanceMate process
- **Crash Reports**: `~/Library/Logs/DiagnosticReports/FinanceMate*.crash`

---

## **NAVIGATION & TROUBLESHOOTING FLOWS**

### **Project Navigation Overview**
**Type**: Native macOS Application
**Framework**: SwiftUI
**Architecture**: MVVM + TabView + HSplitView
**Authentication**: SSO (Apple/Google) + Session Management
**Last Updated**: 2025-10-06

---

### **1. Route Hierarchy & Navigation Structure**

#### Authentication Flow
| Screen | Component | File Path | Purpose | Auth Required |
|--------|-----------|-----------|---------|----------------|
| Login | LoginView | FinanceMate/LoginView.swift | SSO authentication (Apple/Google) | No |
| Main App | ContentView | FinanceMate/ContentView.swift | Authenticated app container | Yes |

#### Primary Navigation (Authenticated Users)
| Tab | Component | File Path | Purpose | Data Source |
|-----|-----------|-----------|---------|-------------|
| Dashboard | DashboardView | FinanceMate/DashboardView.swift | Financial overview & insights | Core Data + API Services |
| Transactions | TransactionsView | FinanceMate/TransactionsView.swift | Transaction management | Core Data |
| Gmail | GmailView | FinanceMate/GmailView.swift | Email receipt processing | Gmail API |
| Settings | SettingsView | FinanceMate/SettingsView.swift | App configuration | Core Data |

#### Modal/Sheet Navigation
| Modal | Trigger | Component | File Path | Purpose |
|-------|---------|-----------|-----------|---------|
| Transaction Detail | Click transaction | TransactionDetailView | FinanceMate/Views/TransactionDetailView.swift | Edit transaction details |
| Split Allocation | "Split" button | SplitAllocationView | FinanceMate/Views/SplitAllocationView.swift | Allocate tax percentages |
| Add Transaction | "+" button | AddTransactionForm | FinanceMate/AddTransactionForm.swift | Create new transaction |

---

### **2. Build Failure Navigation Flows**

#### Flow 1: Code Signing Issues (BF-001)
```
Step 1: Build Failure → "No signing certificate found"
  ↓ Open BUILD_FAILURES.md → BF-001
Step 2: Navigate to Xcode Project Settings
  ↓ FinanceMate.xcodeproj → FinanceMate Target → Signing & Capabilities
Step 3: Configure Team
  ↓ Select Apple Developer Team → Enable "Automatically manage signing"
Step 4: Rebuild
  ↓ xcodebuild build -scheme FinanceMate
  ✅ Build Success
```

#### Flow 2: Core Data Model Issues (BF-002)
```
Step 1: Runtime Crash → "Could not find NSManagedObjectModel"
  ↓ Check BUILD_FAILURES.md → BF-002
Step 2: Navigate to Xcode Build Phases
  ↓ FinanceMate Target → Build Phases → Compile Sources
Step 3: Add Core Data Model
  ↓ Click "+" → Add FinanceMateModel.xcdatamodeld
Step 4: Clean & Rebuild
  ↓ xcodebuild clean → xcodebuild build
  ✅ Model Loaded Successfully
```

#### Flow 3: Package Resolution Failures (BF-004)
```
Step 1: Build Error → "Failed to resolve package dependencies"
  ↓ Navigate to BUILD_FAILURES.md → BF-004
Step 2: Clear Package Cache
  ↓ rm -rf ~/Library/Developer/Xcode/DerivedData
Step 3: Reset Package Caches
  ↓ Xcode → File → Packages → Reset Package Caches
Step 4: Retry Resolution
  ↓ Xcode → File → Packages → Resolve Package Versions
Step 5: Rebuild
  ↓ xcodebuild build
  ✅ Dependencies Resolved
```

#### Flow 4: OAuth Integration Issues (BF-006, BF-007)
```
Step 1: OAuth Error → "redirect_uri_mismatch" or "Invalid Credentials"
  ↓ Check BUILD_FAILURES.md → BF-006/BF-007
Step 2: Navigate to Google Cloud Console
  ↓ APIs & Services → Credentials → OAuth 2.0 Client ID
Step 3: Update Redirect URIs
  ↓ Add: http://localhost:8080/oauth/callback
  ↓ Add: com.ablankcanvas.financemate://oauth/callback
Step 4: Update Environment Configuration
  ↓ Verify .env file → Restart Xcode
Step 5: Test OAuth Flow
  ↓ LoginView → Authenticate → Verify tokens
  ✅ OAuth Integration Working
```

#### Flow 5: Test Target Issues (BF-010)
```
Step 1: Test Error → "Test target not found"
  ↓ Navigate to BUILD_FAILURES.md → BF-010
Step 2: Check Xcode Project
  ↓ FinanceMate.xcodeproj → Verify FinanceMateTests target exists
Step 3: Create Test Scheme
  ↓ Product → Scheme → Manage Schemes → + → FinanceMateTests
Step 4: Enable Shared Scheme
  ↓ Check "Shared" checkbox for test scheme
Step 5: Run Tests
  ↓ xcodebuild test -scheme FinanceMate
  ✅ Tests Executing Successfully
```

---

### **3. Component Authentication Requirements**

#### Public Components (No Auth Required)
- `LoginView.swift` - SSO authentication interface
- Authentication splash screens
- Error pages for unauthorized access

#### Authenticated Components (Auth Required)
- `DashboardView.swift` - Main financial dashboard
- `TransactionsView.swift` - Transaction management
- `GmailView.swift` - Email receipt processing
- `SettingsView.swift` - App configuration
- All modal sheets and detail views

#### API Integration Authentication
| Service | Auth Method | Token Storage | Refresh Logic |
|---------|-------------|---------------|---------------|
| Gmail API | OAuth 2.0 | Keychain | Automatic refresh |
| Anthropic API | API Key | .env file | Static key |
| Basiq API | OAuth 2.0 | Secure storage | Token refresh |

---

### **4. State Management & Data Flow**

#### Authentication State
```swift
@StateObject private var authManager = AuthenticationManager()
// Routes: LoginView ↔ ContentView (based on authManager.isAuthenticated)
```

#### Navigation State
```swift
@State private var selectedTab = 0
// TabView tags: 0=Dashboard, 1=Transactions, 2=Gmail, 3=Settings
```

#### Chatbot State
```swift
@StateObject private var chatbotVM: ChatbotViewModel
// HSplitView: Main Content | ChatbotDrawer (collapsible)
```

---

### **5. Error Handling Navigation**

#### Build-Time Errors
1. **Check BUILD_FAILURES.md** for relevant error ID
2. **Navigate to Xcode settings** as documented
3. **Apply solution** steps in order
4. **Verify fix** with rebuild

#### Runtime Errors
1. **Check Console.app** for FinanceMate process logs
2. **Review crash reports** in `~/Library/Logs/DiagnosticReports/`
3. **Apply corresponding fix** from BUILD_FAILURES.md
4. **Test solution** with affected feature

#### Authentication Errors
1. **Clear auth state** in Keychain Access
2. **Re-authenticate** through LoginView
3. **Verify token storage** in Keychain
4. **Test API access** with fresh credentials

---

### **6. Development Workflow Navigation**

#### Sandbox Development Flow
```
Step 1: Navigate to Sandbox Directory
  ↓ cd FinanceMate-Sandbox/
Step 2: Build Sandbox Version
  ↓ xcodebuild -scheme FinanceMate-Sandbox build
Step 3: Test in Sandbox
  ↓ Run app → Verify watermark displayed
Step 4: Validate Features
  ↓ Test all navigation flows in sandbox
Step 5: Promote to Production
  ↓ Apply changes to FinanceMate/ directory
```

#### Testing Workflow
```
Step 1: Navigate to Test Directory
  ↓ cd _macOS/
Step 2: Run Unit Tests
  ↓ xcodebuild test -scheme FinanceMate
Step 3: Run E2E Tests
  ↓ python3 tests/test_financemate_complete_e2e.py
Step 4: Verify Test Coverage
  ↓ Check test results → Ensure >80% coverage
Step 5: Validate Build
  ↓ xcodebuild build -scheme FinanceMate
```

---

### **7. API Integration Navigation**

#### Gmail API Integration
```
Step 1: Navigate to GmailView
  ↓ Tab: Gmail → Click "Connect Gmail"
Step 2: OAuth Flow
  ↓ LoginView → Google SSO → Token storage
Step 3: API Access
  ↓ GmailAPIService → Fetch emails → Parse receipts
Step 4: Display Results
  ↓ GmailReceiptsTableView → Filter/Sort/Process
Step 5: Error Handling
  ↓ BUILD_FAILURES.md → BF-006/BF-007
```

#### Anthropic API Integration
```
Step 1: Navigate to Settings → API Keys
  ↓ Configure ANTHROPIC_API_KEY in .env
Step 2: Test API Access
  ↓ ChatbotDrawer → Send message → Verify response
Step 3: Error Handling
  ↓ BUILD_FAILURES.md → BF-008 (API Key issues)
```

---

### **8. Troubleshooting Quick Reference**

#### Common Navigation Paths for Issues
| Issue Type | Navigation Path | BUILD_FAILURES ID |
|------------|----------------|-------------------|
| Build won't compile | Xcode → Build Settings → Signing | BF-001 |
| App crashes on launch | Console.app → FinanceMate process | BF-002, BF-005 |
| Can't authenticate | LoginView → SSO flow | BF-006, BF-007 |
| Gmail not working | Gmail tab → Connect button | BF-006, BF-007 |
| Tests won't run | Xcode → Test Navigator | BF-010 |
| API calls failing | Settings → API Keys | BF-008 |

#### Debug Navigation Shortcuts
```bash
# Navigate to project directory
cd /Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps \(Working\)/repos_github/Working/repo_financemate/_macOS/

# Quick build check
xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate build

# Quick test run
xcodebuild test -project FinanceMate.xcodeproj -scheme FinanceMate -destination 'platform=macOS'

# Open documentation for reference
open docs/BUILD_FAILURES.md
```

---

### **9. Component Integration Map**

#### Core Component Dependencies
```
AuthenticationManager
├── LoginView (SSO interface)
├── ContentView (main container)
└── All authenticated views

PersistenceController
├── DashboardView (financial data)
├── TransactionsView (transaction management)
├── GmailView (receipt processing)
└── SettingsView (configuration)

ChatbotViewModel
├── ChatbotDrawer (AI assistant)
└── All views (contextual help)
```

#### Service Layer Navigation
```
GmailAPIService
├── GmailView (email processing)
├── GmailViewModel (data management)
└── GmailReceiptsTableView (display)

AnthropicAPIClient
├── ChatbotViewModel (AI responses)
├── ChatbotDrawer (user interface)
└── MessageBubble (message display)
```

---

### **10. Maintenance & Updates**

#### When to Update Navigation Documentation
- ✅ New views/components added
- ✅ Authentication flow modified
- ✅ Tab structure changed
- ✅ Modal presentations updated
- ✅ API integrations added/modified
- ✅ Build failure solutions updated

#### Navigation Validation Checklist
- [ ] All views accessible from ContentView
- [ ] Authentication flow works correctly
- [ ] Tab navigation functions properly
- [ ] Modal sheets present/dismiss correctly
- [ ] Error states handled appropriately
- [ ] Build failure solutions are current
- [ ] API integrations documented
- [ ] Test workflows are functional

---

## Blueprint Compliance

This build failure documentation complies with the requirements specified in [BLUEPRINT.md](BLUEPRINT.md), ensuring all build processes, error handling, and recovery procedures align with the product specifications and quality standards.

*Last Updated: 2025-10-06 - Comprehensive build failure documentation with navigation structure and troubleshooting flows*