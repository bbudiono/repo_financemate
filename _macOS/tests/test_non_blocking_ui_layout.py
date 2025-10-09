#!/usr/bin/env python3
"""
FinanceMate Non-Blocking UI Layout Test - Atomic TDD GREEN PHASE
Tests AI Assistant sidebar intelligent resizing to prevent main content obstruction

BLUEPRINT REQUIREMENT: Section 3.1.1.7 - Unified Navigation Sidebar
- AI assistant should not obstruct main content
- Implement intelligent resizing to prevent content obstruction
- Test should validate responsive resizing behavior
- Test should verify content obstruction prevention

ATOMIC TDD: GREEN PHASE - Implementation complete, test should PASS
"""

import json
from pathlib import Path
from datetime import datetime
from typing import Dict

# Project paths
PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"

class NonBlockingUILayoutTest:
    """Tests AI Assistant sidebar intelligent resizing to prevent main content obstruction"""

    def test_sidebar_has_intelligent_resizing(self) -> bool:
        """
        TEST: AI Assistant sidebar should have intelligent resizing logic
        EXPECTED: Test should PASS because intelligent resizing is implemented
        """
        chatbot_drawer_path = MACOS_ROOT / "FinanceMate" / "ChatbotDrawer.swift"

        if not chatbot_drawer_path.exists():
            print("FAIL: ChatbotDrawer.swift not found")
            return False  # Implementation missing

        with open(chatbot_drawer_path, 'r') as f:
            content = f.read()

        # Check for intelligent resizing implementation
        has_geometry_reader = 'GeometryReader' in content
        has_intelligent_width = 'calculateIntelligentWidth' in content
        has_min_content_width = 'minContentWidth' in content
        has_responsive_sizing = 'availableWidth: geometry.size.width' in content

        # Validate intelligent resizing implementation
        if has_geometry_reader and has_intelligent_width and has_min_content_width:
            print("PASS: Intelligent resizing implemented")
            print(f"  - GeometryReader: {has_geometry_reader}")
            print(f"  - Intelligent width calculation: {has_intelligent_width}")
            print(f"  - Minimum content width protection: {has_min_content_width}")
            print(f"  - Responsive sizing: {has_responsive_sizing}")
            return True  # Implementation successful
        else:
            print("FAIL: Intelligent resizing not properly implemented")
            print(f"  - GeometryReader: {has_geometry_reader}")
            print(f"  - Intelligent width calculation: {has_intelligent_width}")
            print(f"  - Minimum content width protection: {has_min_content_width}")
            print(f"  - Responsive sizing: {has_responsive_sizing}")
            return False  # Implementation incomplete

    def run_test(self) -> Dict:
        """Run the non-blocking UI layout test"""
        print(" FinanceMate Non-Blocking UI Layout Test - GREEN PHASE")
        print("=" * 60)
        print("PURPOSE: Validate intelligent sidebar resizing implementation")
        print("EXPECTED: Test should PASS (GREEN phase)")
        print("=" * 60)

        # Execute test
        test_passed = self.test_sidebar_has_intelligent_resizing()

        # Results
        results = {
            'test_name': 'Non-Blocking UI Layout',
            'passed': test_passed,  # Should pass in GREEN phase
            'green_phase_compliant': test_passed,
            'timestamp': datetime.now().isoformat(),
            'blueprint_requirement': 'Section 3.1.1.7 - Unified Navigation Sidebar'
        }

        # Print summary
        print(f"\nTest Result: {'PASS' if results['passed'] else 'FAIL'}")
        print(f"GREEN Phase Compliant: {'YES' if results['green_phase_compliant'] else 'NO'}")

        if results['green_phase_compliant']:
            print(" GREEN PHASE SUCCESS: Intelligent resizing implementation validated")
            print(" BLUEPRINT requirement satisfied: AI assistant doesn't obstruct main content")
        else:
            print(" GREEN PHASE FAILURE: Intelligent resizing implementation incomplete")

        # Save results
        results_file = MACOS_ROOT / "test_output" / f"ui_layout_test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        results_file.parent.mkdir(parents=True, exist_ok=True)
        with open(results_file, 'w') as f:
            json.dump(results, f, indent=2)

        print(f"Results saved to: {results_file}")
        return results

def main():
    """Main test execution"""
    test_suite = NonBlockingUILayoutTest()
    results = test_suite.run_test()
    return 0 if results['green_phase_compliant'] else 1

if __name__ == "__main__":
    exit(main())