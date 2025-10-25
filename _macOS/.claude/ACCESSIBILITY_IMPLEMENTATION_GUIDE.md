# Accessibility Implementation Guide for FinanceMate UI/UX Team

**Target**: WCAG 2.1 AA Compliance  
**Test Status**: 8 test suites created, all failing (RED phase)  
**Test File**: `tests/test_accessibility_wcag_compliance.py`

---

## Quick Reference

### VoiceOver Labels (Most Critical)

Every interactive element needs:
```swift
Button("Action") { }
    .accessibilityLabel("Clear, descriptive label")
    .accessibilityHint("What happens when activated")
```

### Keyboard Shortcuts (Easy Wins)

```swift
Button("New") { }
    .keyboardShortcut("n", modifiers: .command)
```

### Focus Management

```swift
@FocusState var focusedField: String?

TextField("Enter", text: $text)
    .focused($focusedField, equals: "textField")
    .border(focusedField == "textField" ? Color.blue : Color.clear)
```

### Color Contrast (Must Be 4.5:1)

Test using: `contrastRatio(foreground: Color, background: Color) -> Double`
Must return ≥4.5 for AA compliance.

---

## Test Categories (8 Total)

1. ✗ VoiceOver Labels - Missing on DashboardView, SettingsView
2. ✗ Keyboard Navigation - No focus/arrow/tab support
3. ✗ Color Contrast - No theme system with WCAG validation
4. ✗ Keyboard Shortcuts - Cmd+N, Cmd+F not implemented
5. ✗ Table Navigation - Arrow keys not functional
6. ✗ Accessibility Attributes - Missing on 3 main views
7. ✗ Focus Management - No focus state tracking
8. ✗ Semantic Structure - DashboardView needs semantics

---

## Implementation Priority

**Critical** (Week 1):
- VoiceOver labels on all interactive elements
- Keyboard shortcuts (Cmd+N, Cmd+F)
- Focus management with clear indicators

**High** (Week 1):
- Keyboard navigation in TransactionsView
- Color contrast verification
- Accessibility attributes

**Medium** (Week 2):
- Arrow key support in tables
- Semantic structure improvements
- Focus ring styling refinement

---

## Files Requiring Changes

### 1. DashboardView.swift (CRITICAL - No labels)
Add `.accessibilityLabel()` and `.accessibilityHint()` to all sections

### 2. SettingsView.swift (CRITICAL - No labels)
Add `.accessibilityLabel()` and `.accessibilityHint()` to settings sections

### 3. ContentView.swift (CRITICAL - No focus/keyboard)
Add `@FocusState`, `.keyboardShortcut()`, focus styling

### 4. TransactionsView.swift (Enhance existing)
Enhance labels, add arrow key navigation, add keyboard shortcuts

### 5. (New) UnifiedThemeSystem.swift (MEDIUM)
Create color system with WCAG AA contrast validation

---

## Testing Commands

Run accessibility tests:
```bash
python3 tests/test_accessibility_wcag_compliance.py
```

Expected output shows which features are missing.

---

## WCAG 2.1 AA Key Requirements

- **Text Contrast**: 4.5:1 (normal text), 3:1 (large text)
- **Focus Indicator**: Visible, minimum 2px width
- **Keyboard Accessible**: All functions via keyboard
- **Screen Reader**: All content announced clearly
- **Color Alone**: Don't use color as only differentiator
- **Motion**: No auto-playing animations >5 seconds

---

## Code Review Checklist

Before submitting code for review:

- [ ] All interactive elements have `.accessibilityLabel()`
- [ ] Clear, descriptive labels (not technical)
- [ ] All functions accessible via keyboard
- [ ] Focus indicators visible (2px+ border)
- [ ] Color contrast ≥4.5:1
- [ ] No more than 50 lines changed per commit
- [ ] Tests pass: `python3 tests/test_accessibility_wcag_compliance.py`
- [ ] Code quality >95%

---

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Apple Accessibility Guidelines](https://developer.apple.com/accessibility/)
- [macOS Accessibility Testing](https://developer.apple.com/accessibility/macos/)

