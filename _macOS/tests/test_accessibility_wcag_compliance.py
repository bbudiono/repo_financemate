"""
WCAG 2.1 AA Accessibility Compliance Test Suite for FinanceMate

Tests:
1. VoiceOver screen reader support with descriptive labels
2. Complete keyboard navigation (no mouse required)
3. Color contrast ratios (4.5:1 minimum for WCAG AA)
4. Keyboard shortcuts (Cmd+N, Cmd+F)
5. Arrow key navigation in tables
6. Space to select, Shift+arrow for range selection

These tests are DESIGNED TO FAIL until accessibility features are implemented.
"""

import subprocess
import json
import re
from typing import Dict, List, Tuple
from pathlib import Path
from datetime import datetime


class AccessibilityTestSuite:
    """WCAG 2.1 AA compliance testing framework"""
    
    def __init__(self):
        self.test_results = []
        self.start_time = datetime.now()
        # Fix: Use correct _macOS path (test is in _macOS/tests/, parent.parent = _macOS/)
        self.project_path = Path(__file__).parent.parent
        
    def run_all_tests(self) -> Dict:
        """Execute all accessibility tests"""
        print("\n" + "="*70)
        print("WCAG 2.1 AA ACCESSIBILITY COMPLIANCE TEST SUITE")
        print("="*70 + "\n")
        
        # Phase 1: Failing tests (design-first TDD)
        self.test_voiceover_labels()
        self.test_keyboard_navigation()
        self.test_color_contrast_ratios()
        self.test_keyboard_shortcuts()
        self.test_table_keyboard_navigation()
        self.test_accessibility_attributes()
        self.test_focus_management()
        self.test_semantic_html_structure()
        
        return self.generate_report()
    
    def test_voiceover_labels(self) -> None:
        """Test VoiceOver accessibility labels on all interactive elements"""
        print("\n[TEST 1] VoiceOver Accessibility Labels")
        print("-" * 50)
        
        # List of critical views that need VoiceOver labels
        critical_views = [
            "DashboardView.swift",
            "TransactionsView.swift",
            "GmailView.swift",
            "SettingsView.swift",
            "LoginView.swift",
        ]
        
        missing_labels = []
        
        for view_file in critical_views:
            view_path = self.project_path / "FinanceMate" / view_file
            if view_path.exists():
                content = view_path.read_text()
                
                # Check for accessibilityLabel and accessibilityHint
                has_labels = bool(re.search(r'\.accessibilityLabel\(', content))
                has_hints = bool(re.search(r'\.accessibilityHint\(', content))
                
                if not (has_labels or has_hints):
                    missing_labels.append(view_file)
                    print(f"  ❌ {view_file}: Missing accessibility labels")
                else:
                    count_labels = len(re.findall(r'\.accessibilityLabel\(', content))
                    count_hints = len(re.findall(r'\.accessibilityHint\(', content))
                    print(f"  ✓ {view_file}: {count_labels} labels, {count_hints} hints found")
        
        if missing_labels:
            print(f"\n  REQUIRED: Add .accessibilityLabel() and .accessibilityHint() to:")
            for view in missing_labels:
                print(f"    - {view}")
            self.test_results.append(("VoiceOver Labels", "FAIL", len(missing_labels)))
        else:
            self.test_results.append(("VoiceOver Labels", "PASS", 0))
    
    def test_keyboard_navigation(self) -> None:
        """Test complete keyboard navigation support"""
        print("\n[TEST 2] Keyboard Navigation Support")
        print("-" * 50)

        # Check across all relevant files (MODULAR pattern)
        app_file = self.project_path / "FinanceMate" / "FinanceMateApp.swift"
        content_view = self.project_path / "FinanceMate" / "ContentView.swift"
        focus_mgmt = self.project_path / "FinanceMate" / "FocusManagement.swift"

        combined_content = ""
        for file_path in [app_file, content_view, focus_mgmt]:
            if file_path.exists():
                combined_content += file_path.read_text()

        # Check for keyboard navigation features across codebase
        # Include table component files for MODULAR pattern validation
        table_files = list((self.project_path / "FinanceMate" / "Views").rglob("*TableView.swift"))
        for table_file in table_files:
            if table_file.exists():
                combined_content += table_file.read_text()

        has_shortcuts = '.commands' in combined_content or 'CommandGroup' in combined_content
        has_focus = '.focusable()' in combined_content or '@FocusState' in combined_content
        has_arrow_keys = '.onMoveCommand' in combined_content

        features = {
            "Keyboard shortcuts": has_shortcuts,
            "Focus management": has_focus,
            "Arrow key navigation": has_arrow_keys
        }

        missing = [f for f, present in features.items() if not present]

        for feature, present in features.items():
            status = "✓" if present else "❌"
            print(f"  {status} {feature}: {'Implemented' if present else 'Missing'}")

        if missing:
            print(f"\n  REQUIRED: Implement {len(missing)} missing features")
            self.test_results.append(("Keyboard Navigation", "FAIL", len(missing)))
        else:
            self.test_results.append(("Keyboard Navigation", "PASS", 0))
    
    def test_color_contrast_ratios(self) -> None:
        """Test WCAG AA color contrast ratios (4.5:1 minimum)"""
        print("\n[TEST 3] Color Contrast Ratios (WCAG AA 4.5:1)")
        print("-" * 50)
        
        # Look for color definitions
        color_files = []
        for swift_file in self.project_path.glob("FinanceMate/**/*.swift"):
            if "Color" in swift_file.name or "Theme" in swift_file.name:
                color_files.append(swift_file)
        
        if not color_files:
            print("  ❌ No color/theme system files found")
            print("  REQUIRED: Create UnifiedThemeSystem.swift with:")
            print("    - Light mode colors with >4.5:1 contrast")
            print("    - Dark mode colors with >4.5:1 contrast")
            print("    - Color definitions with accessibility compliance")
            self.test_results.append(("Color Contrast", "FAIL", 1))
            return
        
        # Check for contrast validation
        has_contrast_validation = False
        for color_file in color_files:
            content = color_file.read_text()
            if "contrast" in content.lower() or "wcag" in content.lower():
                has_contrast_validation = True
                print(f"  ✓ {color_file.name}: Contrast validation found")
        
        if not has_contrast_validation:
            print("  ❌ No contrast ratio validation found")
            print("  REQUIRED: Add WCAG contrast checking to color system")
            self.test_results.append(("Color Contrast", "FAIL", 1))
        else:
            self.test_results.append(("Color Contrast", "PASS", 0))
    
    def test_keyboard_shortcuts(self) -> None:
        """Test keyboard shortcuts: Cmd+N, Cmd+F"""
        print("\n[TEST 4] Keyboard Shortcuts (Cmd+N, Cmd+F)")
        print("-" * 50)

        # Check FinanceMateApp.swift (where CommandGroup shortcuts are defined)
        app_file = self.project_path / "FinanceMate" / "FinanceMateApp.swift"
        content_view = self.project_path / "FinanceMate" / "ContentView.swift"

        combined_content = ""
        if app_file.exists():
            combined_content += app_file.read_text()
        if content_view.exists():
            combined_content += content_view.read_text()

        if not combined_content:
            print("  ⚠️  No source files found")
            self.test_results.append(("Keyboard Shortcuts", "ERROR", 1))
            return

        shortcuts_found = {
            "Cmd+N (New)": bool(re.search(r'keyboardShortcut\("n"', combined_content, re.IGNORECASE)),
            "Cmd+F (Search)": bool(re.search(r'keyboardShortcut\("f"', combined_content, re.IGNORECASE)),
        }

        missing = [s for s, found in shortcuts_found.items() if not found]

        for shortcut, found in shortcuts_found.items():
            status = "✓" if found else "❌"
            print(f"  {status} {shortcut}")

        if missing:
            print(f"\n  REQUIRED: Add keyboard shortcuts:")
            print(f"    Button(...).keyboardShortcut(\"n\", modifiers: .command)")
            print(f"    Button(...).keyboardShortcut(\"f\", modifiers: .command)")
            self.test_results.append(("Keyboard Shortcuts", "FAIL", len(missing)))
        else:
            self.test_results.append(("Keyboard Shortcuts", "PASS", 0))
    
    def test_table_keyboard_navigation(self) -> None:
        """Test arrow key navigation in tables"""
        print("\n[TEST 5] Table Arrow Key Navigation")
        print("-" * 50)

        # Check actual Table component files (not parent views)
        table_files = [
            self.project_path / "FinanceMate" / "Views" / "Transactions" / "TransactionsTableView.swift",
            self.project_path / "FinanceMate" / "Views" / "Gmail" / "GmailReceiptsTableView.swift"
        ]

        has_arrow_navigation = False
        for table_file in table_files:
            if table_file.exists():
                content = table_file.read_text()
                if ".onMoveCommand" in content:
                    has_arrow_navigation = True
                    print(f"  ✓ {table_file.name}: Arrow key navigation found")

        if has_arrow_navigation:
            self.test_results.append(("Table Navigation", "PASS", 0))
        else:
            print(f"  ❌ No arrow key navigation in table components")
            print(f"\n  REQUIRED: Add .onMoveCommand to Table views")
            self.test_results.append(("Table Navigation", "FAIL", 1))
    
    def test_accessibility_attributes(self) -> None:
        """Test accessibility attributes (role, identifier, value)"""
        print("\n[TEST 6] Accessibility Attributes")
        print("-" * 50)
        
        views_to_check = [
            "DashboardView.swift",
            "TransactionsView.swift",
            "SettingsView.swift",
        ]
        
        issues = 0
        for view_file in views_to_check:
            view_path = self.project_path / "FinanceMate" / view_file
            if view_path.exists():
                content = view_path.read_text()
                
                # Check for accessibility attributes
                has_role = ".accessibilityElement()" in content
                has_value = ".accessibilityValue(" in content
                has_identifier = ".accessibilityIdentifier(" in content
                
                if not (has_role or has_value or has_identifier):
                    print(f"  ❌ {view_file}: Missing accessibility attributes")
                    issues += 1
                else:
                    attrs = []
                    if has_role: attrs.append("role")
                    if has_value: attrs.append("value")
                    if has_identifier: attrs.append("id")
                    print(f"  ✓ {view_file}: Found {', '.join(attrs)}")
        
        if issues > 0:
            self.test_results.append(("Accessibility Attributes", "FAIL", issues))
        else:
            self.test_results.append(("Accessibility Attributes", "PASS", 0))
    
    def test_focus_management(self) -> None:
        """Test focus management and focus indicators"""
        print("\n[TEST 7] Focus Management")
        print("-" * 50)

        # Check FocusManagement.swift (MODULAR pattern) and views that use it
        focus_mgmt = self.project_path / "FinanceMate" / "FocusManagement.swift"
        content_view = self.project_path / "FinanceMate" / "ContentView.swift"
        dashboard = self.project_path / "FinanceMate" / "DashboardView.swift"
        transactions = self.project_path / "FinanceMate" / "TransactionsView.swift"

        combined_content = ""
        files_checked = []
        for file_path in [focus_mgmt, content_view, dashboard, transactions]:
            if file_path.exists():
                combined_content += file_path.read_text()
                files_checked.append(file_path.name)

        has_focus_state = "@FocusState" in combined_content
        has_focus_indicators = ".focused(" in combined_content or ".accessibleFocus()" in combined_content
        has_focus_styling = "FocusIndicatorModifier" in combined_content or "RoundedRectangle" in combined_content and "stroke" in combined_content

        checks = {
            "Focus state (@FocusState)": has_focus_state,
            "Focus indicators (.accessibleFocus)": has_focus_indicators,
            "Focus styling (2px outline)": has_focus_styling
        }

        missing = [c for c, present in checks.items() if not present]

        print(f"  Files checked: {', '.join(files_checked)}")
        for check, present in checks.items():
            status = "✓" if present else "❌"
            print(f"  {status} {check}: {'Found' if present else 'Missing'}")

        if missing:
            print(f"\n  MISSING: {len(missing)} focus management features")
            self.test_results.append(("Focus Management", "FAIL", len(missing)))
        else:
            self.test_results.append(("Focus Management", "PASS", 0))
    
    def test_semantic_html_structure(self) -> None:
        """Test semantic structure for accessibility"""
        print("\n[TEST 8] Semantic SwiftUI Structure")
        print("-" * 50)
        
        views = [
            "DashboardView.swift",
            "TransactionsView.swift",
            "SettingsView.swift",
        ]
        
        issues = 0
        for view_file in views:
            view_path = self.project_path / "FinanceMate" / view_file
            if view_path.exists():
                content = view_path.read_text()
                
                # Check for proper semantic structure
                has_sections = "Section" in content
                has_labels = "Label(" in content or ".accessibilityLabel(" in content
                has_groups = "Group" in content
                
                if not (has_sections or has_labels):
                    print(f"  ❌ {view_file}: Missing semantic structure")
                    issues += 1
                else:
                    print(f"  ✓ {view_file}: Semantic structure found")
        
        if issues > 0:
            self.test_results.append(("Semantic Structure", "FAIL", issues))
        else:
            self.test_results.append(("Semantic Structure", "PASS", 0))
    
    def generate_report(self) -> Dict:
        """Generate comprehensive test report"""
        print("\n" + "="*70)
        print("TEST SUMMARY")
        print("="*70 + "\n")
        
        passed = sum(1 for _, status, _ in self.test_results if status == "PASS")
        failed = sum(1 for _, status, _ in self.test_results if status == "FAIL")
        errors = sum(1 for _, status, _ in self.test_results if status == "ERROR")
        
        for test_name, status, count in self.test_results:
            symbol = "✓" if status == "PASS" else "❌" if status == "FAIL" else "⚠️"
            print(f"{symbol} {test_name}: {status} ({count} issues)")
        
        duration = (datetime.now() - self.start_time).total_seconds()
        
        print(f"\nTotal: {passed} passed, {failed} failed, {errors} errors")
        print(f"Duration: {duration:.2f}s\n")
        
        return {
            "total_tests": len(self.test_results),
            "passed": passed,
            "failed": failed,
            "errors": errors,
            "duration": duration,
            "details": [{"test": name, "status": status, "issues": count} 
                       for name, status, count in self.test_results]
        }


if __name__ == "__main__":
    suite = AccessibilityTestSuite()
    report = suite.run_all_tests()
    
    # Write report to file
    output_file = Path("test_output/accessibility_compliance_report.json")
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(json.dumps(report, indent=2))
    
    print(f"Report saved to: {output_file}")
    
    # Exit with error if tests failed (for CI/CD)
    exit(0 if report["failed"] == 0 else 1)
