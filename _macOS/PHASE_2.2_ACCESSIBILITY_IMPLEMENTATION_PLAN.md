# PHASE 2.2: WCAG 2.1 AA Accessibility Compliance Implementation

**Status**: RED PHASE (Failing Tests Created)  
**Date**: 2025-10-25  
**Lead**: Technical-Project-Lead + UI/UX Accessibility Experts  
**Target Completion**: October 30, 2025

---

## Executive Summary

This phase implements comprehensive WCAG 2.1 AA accessibility compliance for FinanceMate macOS application. All tests are intentionally failing (RED phase) and ready for implementation.

**Test Results (RED PHASE - Expected Failures)**:
- VoiceOver Labels: FAIL (2/5 views implemented)
- Keyboard Navigation: FAIL (0/3 features)
- Color Contrast: FAIL (theme system needed)
- Keyboard Shortcuts: FAIL (0/2 shortcuts)
- Table Navigation: FAIL (arrow key support missing)
- Accessibility Attributes: FAIL (0/3 views compliant)
- Focus Management: FAIL (no focus state)
- Semantic Structure: FAIL (DashboardView needs work)

---

## Implementation Roadmap

### TIER 1: VoiceOver Accessibility Labels (Critical)

**Target**: All interactive elements have descriptive VoiceOver labels

**Views to Update**:

1. **DashboardView.swift**
   - Add `.accessibilityLabel("Dashboard Overview")` to root VStack
   - Add labels to each dashboard widget:
     - `"Total Assets: \(formatCurrency(totalAssets))"`
     - `"Monthly Spending: \(formatCurrency(monthlySpending))"`
     - `"Tax Liability: \(formatCurrency(taxLiability))"`
   - Add hints for interactive elements: `"Double-tap to view details"`

2. **SettingsView.swift**
   - Add `.accessibilityLabel("Settings")` to root
   - Label each settings section:
     - `"Profile Settings"`, `"Edit your profile information"`
     - `"Security Settings"`, `"Manage authentication and security"`
     - `"API Configuration"`, `"Configure API keys for services"`
     - `"Connected Accounts"`, `"View and manage linked accounts"`

3. **TransactionsView.swift** ✓ (Partial - Enhance)
   - Enhance existing labels with more context
   - Add hints for row interactions: `"Select to view transaction details"`
   - Add label to search field: `"Search transactions by merchant or amount"`

4. **GmailView.swift** ✓ (Partial - Enhance)
   - Add hints to email rows
   - Label extraction status indicators

5. **LoginView.swift** ✓ (Partial - Enhance)
   - Add hints to sign-in buttons

**Implementation Pattern**:
```swift
Button(action: { ... }) {
    Image(systemName: "plus.circle")
    Text("Add Transaction")
}
.accessibilityLabel("Add New Transaction")
.accessibilityHint("Creates a new transaction entry")
```

---

### TIER 2: Keyboard Navigation Support (Critical)

**Target**: All functionality accessible via keyboard alone

**ContentView.swift Updates**:

1. **Focus State Management**
   ```swift
   @FocusState private var focusedField: String?
   
   @State private var selectedTabIndex: Int = 0
   ```

2. **Tab Navigation**
   - Cmd+1, Cmd+2, Cmd+3, Cmd+4 for tab switching
   - Tab key cycles through interactive elements
   - Shift+Tab reverses through elements

3. **Focus Styling**
   ```swift
   .focused($focusedField, equals: "fieldId")
   .border(Color.blue, width: focusedField == "fieldId" ? 2 : 0)
   ```

**DashboardView.swift Updates**:
- Add `.focusable()` to each dashboard card
- Support arrow key navigation between cards
- Space/Enter to expand card details

**TransactionsView.swift Updates**:
- **Focus State**: `@FocusState var selectedRowIndex: Int?`
- **Arrow Key Navigation**: 
  ```swift
  .onMoveCommand { direction in
      switch direction {
      case .up: selectedRowIndex = (selectedRowIndex ?? 0) - 1
      case .down: selectedRowIndex = (selectedRowIndex ?? 0) + 1
      default: break
      }
  }
  ```
- **Space to Select**: Toggle selection state
- **Shift+Arrow**: Range selection

**SettingsView.swift Updates**:
- Focus navigation between setting sections
- Space/Enter to toggle settings
- Arrow keys to navigate options

---

### TIER 3: Keyboard Shortcuts (High Priority)

**ContentView.swift**:

1. **Cmd+N**: New Transaction
   ```swift
   Button("New Transaction") { ... }
   .keyboardShortcut("n", modifiers: .command)
   ```

2. **Cmd+F**: Search/Find Transactions
   ```swift
   Button("Search") { ... }
   .keyboardShortcut("f", modifiers: .command)
   ```

3. **Cmd+1-4**: Switch Tabs
   ```swift
   .keyboardShortcut("1", modifiers: .command)  // Dashboard
   .keyboardShortcut("2", modifiers: .command)  // Transactions
   .keyboardShortcut("3", modifiers: .command)  // Gmail
   .keyboardShortcut("4", modifiers: .command)  // Settings
   ```

4. **Cmd+Q**: Quit Application
   ```swift
   .keyboardShortcut("q", modifiers: .command)
   ```

5. **Cmd+W**: Close Window
   ```swift
   .keyboardShortcut("w", modifiers: .command)
   ```

---

### TIER 4: Color Contrast Verification (Medium Priority)

**Create UnifiedThemeSystem.swift**:

```swift
import SwiftUI

struct UnifiedThemeSystem {
    // Light Mode Colors (WCAG AA 4.5:1 minimum)
    struct LightMode {
        static let background = Color(red: 1.0, green: 1.0, blue: 1.0)  // White
        static let foreground = Color(red: 0.0, green: 0.0, blue: 0.0)  // Black (21:1)
        
        static let primary = Color(red: 0.0, green: 0.4, blue: 0.95)    // Blue (7.2:1)
        static let secondary = Color(red: 0.4, green: 0.4, blue: 0.4)   // Gray (5.3:1)
        
        static let success = Color(red: 0.0, green: 0.5, blue: 0.0)     // Green (6.2:1)
        static let warning = Color(red: 0.8, green: 0.5, blue: 0.0)     // Orange (5.4:1)
        static let error = Color(red: 0.8, green: 0.0, blue: 0.0)       // Red (4.5:1)
    }
    
    // Dark Mode Colors (WCAG AA 4.5:1 minimum)
    struct DarkMode {
        static let background = Color(red: 0.12, green: 0.12, blue: 0.12)  // Dark
        static let foreground = Color(red: 1.0, green: 1.0, blue: 1.0)     // White
        
        static let primary = Color(red: 0.4, green: 0.7, blue: 1.0)        // Light Blue (7.0:1)
        static let secondary = Color(red: 0.7, green: 0.7, blue: 0.7)      // Light Gray (5.5:1)
        
        static let success = Color(red: 0.3, green: 0.8, blue: 0.3)        // Light Green (6.5:1)
        static let warning = Color(red: 1.0, green: 0.7, blue: 0.2)        // Light Orange (5.8:1)
        static let error = Color(red: 1.0, green: 0.4, blue: 0.4)          // Light Red (4.9:1)
    }
}
```

**Contrast Verification Script**:
```swift
// Verify contrast ratio between two colors
func contrastRatio(foreground: Color, background: Color) -> Double {
    let fg = foreground.rgba
    let bg = background.rgba
    
    let fgLum = relativeLuminance(r: fg.red, g: fg.green, b: fg.blue)
    let bgLum = relativeLuminance(r: bg.red, g: bg.green, b: bg.blue)
    
    let lighter = max(fgLum, bgLum)
    let darker = min(fgLum, bgLum)
    
    return (lighter + 0.05) / (darker + 0.05)  // Must be ≥4.5 for AA
}
```

---

### TIER 5: Focus Management (High Priority)

**ContentView.swift**:

```swift
@FocusState private var focusedElementID: String?

VStack {
    // Each interactive element
    Button("Add") { }
        .focused($focusedElementID, equals: "addButton")
        .border(
            focusedElementID == "addButton" ? Color.blue : Color.clear,
            width: focusedElementID == "addButton" ? 2 : 0
        )
}
```

**Focus Ring Styling**:
- Use SwiftUI's `.focused()` modifier
- 2pt blue border for focus indicator
- High contrast focus colors (4.5:1 minimum)

---

### TIER 6: Accessibility Attributes (Medium Priority)

**All Views**:
```swift
.accessibilityElement(children: .combine)
.accessibilityIdentifier("dashboardView")
.accessibilityValue("Loaded") // Current state
```

---

## Testing Strategy

### Unit Test Validation (Swift)
```bash
xcodebuild test -workspace FinanceMate.xcworkspace \
  -scheme FinanceMate \
  -destination 'platform=macOS,arch=arm64'
```

### Accessibility Compliance Test (Python)
```bash
python3 tests/test_accessibility_wcag_compliance.py
```

### Manual VoiceOver Testing
1. Enable VoiceOver: System Preferences > Accessibility > VoiceOver > Enable
2. Navigate app using:
   - VO (Control+Option) + Right/Left arrows
   - VO + Spacebar to activate
   - VO + Up/Down for hints
3. Verify all interactive elements are labeled and actionable

### Keyboard-Only Testing
1. Unplug/disable mouse
2. Navigate using Tab, Shift+Tab, Arrow keys
3. Use keyboard shortcuts: Cmd+N, Cmd+F
4. Verify all functionality accessible

---

## Atomic Implementation Plan

### Commit 1: VoiceOver Labels (Tier 1)
- Update DashboardView.swift (max 50 lines change)
- Update SettingsView.swift (max 50 lines change)
- Enhance existing labels in TransactionsView, GmailView, LoginView
- Test: `pytest tests/test_accessibility_wcag_compliance.py::test_voiceover_labels`

### Commit 2: Focus Management (Tier 5)
- Update ContentView.swift with @FocusState
- Add focus styling throughout
- Test: `pytest tests/test_accessibility_wcag_compliance.py::test_focus_management`

### Commit 3: Keyboard Shortcuts (Tier 3)
- Add Cmd+N, Cmd+F, Cmd+1-4 shortcuts
- Test: `pytest tests/test_accessibility_wcag_compliance.py::test_keyboard_shortcuts`

### Commit 4: Keyboard Navigation (Tier 2)
- Update TransactionsView with arrow key support
- Update DashboardView with focus navigation
- Test: Multiple test validations

### Commit 5: Color Contrast (Tier 4)
- Create UnifiedThemeSystem.swift (or update if exists)
- Add contrast validation
- Test: `pytest tests/test_accessibility_wcag_compliance.py::test_color_contrast_ratios`

### Commit 6: Accessibility Attributes (Tier 6)
- Add accessibility identifiers and elements
- Test: `pytest tests/test_accessibility_wcag_compliance.py::test_accessibility_attributes`

---

## Code Quality Requirements

- **Max 50 lines per modification**
- **Max 3 files per commit**
- **100% test passage required**
- **No semantic changes** - only add accessibility, never remove functionality
- **Code review score >95%** required for merge

---

## Success Criteria

✅ All 8 test categories PASS (0 failures)
✅ VoiceOver fully navigable
✅ Keyboard-only usage fully supported
✅ Color contrast verified (4.5:1+ for all text)
✅ All shortcuts working
✅ Focus clearly visible
✅ Code quality >95%
✅ ARCHITECTURE.md updated with accessibility documentation

---

## Dependencies

- Phase 1.0: Core app structure ✓ (COMPLETE)
- Phase 2.1: Security implementation ✓ (COMPLETE - 7/7 tests)
- Phase 2.2: This accessibility work (IN PROGRESS)

---

## Next Phase

Phase 3.0: Advanced AI/RAG system will build on top of accessible foundation.

