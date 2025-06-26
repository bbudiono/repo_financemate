# FinanceMate - Canonical Test Plan

This is the single source of truth for all testing. No feature is 'done' until its corresponding tests here are implemented and passing.

## 1. macOS Platform Requirements

### 1.1 UI Automation (XCTest)
- **Goal:** Verify core workflows and visual states.
- **[✅] Test Case 1.1.1:** App Launch & Dashboard Render. (Verifies the app doesn't crash on start and the main view appears). **EVIDENCE: [Screenshot](../docs/UX_Snapshots/TC_1.1.1_Dashboard_Launch_20240629.png)** - COMPLETED 2024-06-29
- **[✅] Test Case 1.1.2:** Navigate to All Primary Views. (Verifies all sidebar/tab bar navigation links work). **EVIDENCE: [Navigation Screenshots](../docs/UX_Snapshots/) - TC_1.1.2_Navigate_To_*.png** - COMPLETED 2024-06-29

### 1.2 Accessibility Compliance (XCTest Accessibility)
- **Goal:** Ensure the app is usable by everyone.
- **[✅] Test Case 1.2.1:** Full Application Audit. (Runs Xcode's accessibility inspector and reports violations). **EVIDENCE: [Accessibility Audit Log](../docs/logs/Accessibility_Audit_2024-06-29_20-25-00.log)** - COMPLETED 2024-06-29

### 1.3 Code Signing & Notarization Validation
- **Goal:** Verify the app is ready for distribution.
- **[✅] Test Case 1.3.1:** Production Build Archive & Notarization Check. (A script that archives the app and runs `spctl -a -vvv` on the .app bundle). **EVIDENCE: [Code Signing Validation Log](../docs/logs/CodeSign_Validation_20250626_203335.log)** - COMPLETED 2024-06-29

### 1.4 SweetPad Compatibility
- **Goal:** Ensure the project is stable in the primary development environment.
- **[ ] Test Case 1.4.1:** Project Opens & Builds in SweetPad without errors. (Manual check for now, to be automated).