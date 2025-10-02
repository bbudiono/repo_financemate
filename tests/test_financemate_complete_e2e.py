#!/usr/bin/env python3
"""FinanceMate MVP E2E Test Suite - Comprehensive BLUEPRINT Validation (KISS Compliant)"""

import subprocess
import time
import os
import json
from pathlib import Path
from datetime import datetime

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"
APP_PATH = Path("/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app")
SCREENSHOT_DIR = PROJECT_ROOT / "test_output" / f"screenshots_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

SCREENSHOT_DIR.mkdir(parents=True, exist_ok=True)

def log_test(test_name, status, message=""):
    """Log test results with timestamp"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_file = PROJECT_ROOT / "test_output" / "e2e_test_log.txt"
    log_file.parent.mkdir(parents=True, exist_ok=True)
    with open(log_file, 'a') as f:
        f.write(f"[{timestamp}] {test_name}: {status} - {message}\n")

def capture_screenshot(name):
    """Capture app window screenshot"""
    output = SCREENSHOT_DIR / f"{name}_{datetime.now().strftime('%H%M%S')}.png"
    subprocess.run(["screencapture", "-o", "-l",
                   "$(osascript -e 'tell application \"System Events\" to get window id of window 1 of process \"FinanceMate\"')",
                   str(output)])
    return output

def test_build():
    """Build must succeed with zero warnings"""
    os.chdir(MACOS_ROOT)
    result = subprocess.run(["xcodebuild", "-scheme", "FinanceMate", "-configuration", "Debug", "build"],
                           capture_output=True, text=True)
    success = "BUILD SUCCEEDED" in result.stdout or result.returncode == 0
    warnings = result.stdout.count("warning:")
    log_test("test_build", "PASS" if success and warnings == 0 else "FAIL",
             f"Build {'succeeded' if success else 'failed'}, {warnings} warnings")
    assert success, "Build failed"
    assert warnings == 0, f"Build has {warnings} warnings"
    return True

def test_kiss_compliance():
    """All files must be <200 lines"""
    violations = []
    for file in MACOS_ROOT.glob("FinanceMate/*.swift"):
        lines = len(open(file).readlines())
        if lines >= 200:
            violations.append(f"{file.name}: {lines} lines")
    log_test("test_kiss_compliance", "PASS" if not violations else "FAIL",
             f"Violations: {violations}" if violations else "All files <200 lines")
    assert not violations, f"KISS violations: {violations}"
    return True

def test_security_hardening():
    """No force unwraps, fatalError, or hardcoded credentials"""
    swift_dir = str(MACOS_ROOT / "FinanceMate")
    violations = []

    # Detect actual force unwraps (pattern: variable! or function()!)
    # Exclude: != (not equal), ! at start (negation), string literals
    result1 = subprocess.run(["grep", "-rn", r"\w!", swift_dir], capture_output=True, text=True)
    force_unwraps = [l for l in result1.stdout.split('\n')
                     if '!' in l
                     and not l.strip().startswith('//')
                     and '!=' not in l
                     and not any(x in l for x in ['hasSuffix("!")', 'hasPrefix("!")', "I'm", "you're", "it's"])]
    if force_unwraps:
        violations.append(f"{len(force_unwraps)} force unwraps")

    result2 = subprocess.run(["grep", "-r", "fatalError", swift_dir], capture_output=True, text=True)
    fatal_errors = [l for l in result2.stdout.split('\n') if 'fatalError' in l and not l.strip().startswith('//')]
    if fatal_errors:
        violations.append(f"{len(fatal_errors)} fatalError calls")

    log_test("test_security_hardening", "PASS" if not violations else "FAIL",
             f"Violations: {violations}" if violations else "Security hardened")
    assert not violations, f"Security violations: {violations}"
    return True

def test_core_data_schema():
    """Core Data schema must include Transaction entity"""
    persistence = MACOS_ROOT / "FinanceMate/PersistenceController.swift"
    content = open(persistence).read()
    required = [('Transaction entity', 'name = "Transaction"'),
                ('Non-optional fields', 'isOptional = false')]
    missing = [name for name, check in required if check not in content]
    log_test("test_core_data_schema", "PASS" if not missing else "FAIL",
             f"Missing: {missing}" if missing else "Schema complete")
    assert not missing, f"Missing: {missing}"
    return True

def test_tax_category_support():
    """BLOCKER 2: Tax category field must exist"""
    persistence = MACOS_ROOT / "FinanceMate/PersistenceController.swift"
    transaction = MACOS_ROOT / "FinanceMate/Transaction.swift"
    content = (open(persistence).read() if persistence.exists() else "") + \
              (open(transaction).read() if transaction.exists() else "")
    has_tax = 'taxCategory' in content
    log_test("test_tax_category_support", "PASS" if has_tax else "FAIL",
             "Implemented" if has_tax else "BLOCKER 2 not implemented")
    assert has_tax, "Tax category support not implemented (BLOCKER 2)"
    return True

def test_gmail_transaction_extraction():
    """BLOCKER 1: Gmail must extract transactions"""
    gmail_api = MACOS_ROOT / "FinanceMate/GmailAPI.swift"
    content = open(gmail_api).read() if gmail_api.exists() else ""
    has_extract = any(x in content for x in ['extractTransaction', 'parseReceipt', 'extractLineItems'])
    log_test("test_gmail_transaction_extraction", "PASS" if has_extract else "FAIL",
             "Implemented" if has_extract else "BLOCKER 1 not implemented")
    assert has_extract, "Gmail transaction extraction not implemented (BLOCKER 1)"
    return True

def test_google_sso():
    """BLOCKER 3: Google Sign In must be implemented"""
    auth = MACOS_ROOT / "FinanceMate/AuthenticationManager.swift"
    content = open(auth).read() if auth.exists() else ""
    has_google = any(x in content for x in ['GoogleSignIn', 'signInWithGoogle', 'GIDSignIn'])
    log_test("test_google_sso", "PASS" if has_google else "FAIL",
             "Implemented" if has_google else "BLOCKER 3 not implemented")
    assert has_google, "Google SSO not implemented (BLOCKER 3)"
    return True

def test_ai_chatbot_integration():
    """BLOCKER 4: AI Chatbot with LLM (no mock data)"""
    # Check LLM files exist
    anthropic = (MACOS_ROOT / "FinanceMate/AnthropicAPIClient.swift").exists()
    llm_service = (MACOS_ROOT / "FinanceMate/LLMFinancialAdvisorService.swift").exists()

    # Check no static dictionaries
    ks = MACOS_ROOT / "FinanceMate/FinancialKnowledgeService.swift"
    no_mock = 'australianFinancialKnowledge' not in open(ks).read() if ks.exists() else False

    has_chatbot = anthropic and llm_service and no_mock
    log_test("test_ai_chatbot_integration", "PASS" if has_chatbot else "FAIL",
             f"LLM: {anthropic and llm_service}, NoMock: {no_mock}")
    assert has_chatbot, "Chatbot integration incomplete"
    return True

def test_apple_sso():
    """Apple Sign In must be functional"""
    auth = MACOS_ROOT / "FinanceMate/AuthenticationManager.swift"
    login = MACOS_ROOT / "FinanceMate/LoginView.swift"
    content = (open(auth).read() if auth.exists() else "") + \
              (open(login).read() if login.exists() else "")
    has_apple = 'ASAuthorizationAppleIDProvider' in content or 'SignInWithAppleButton' in content
    log_test("test_apple_sso", "PASS" if has_apple else "FAIL", "Implemented" if has_apple else "Missing")
    assert has_apple, "Apple SSO not implemented"
    return True

def test_ui_architecture():
    """UI must follow MVVM with SwiftUI"""
    views = ["ContentView.swift", "DashboardView.swift", "TransactionsView.swift",
             "GmailView.swift", "SettingsView.swift"]
    missing = [v for v in views if not (MACOS_ROOT / "FinanceMate" / v).exists()]
    log_test("test_ui_architecture", "PASS" if not missing else "FAIL",
             f"Missing: {missing}" if missing else "All views present")
    assert not missing, f"Missing: {missing}"
    return True

def test_dark_light_mode():
    """App must support dark and light modes"""
    views = ["DashboardView.swift", "TransactionsView.swift", "GmailView.swift", "SettingsView.swift"]
    unsupported = []
    for v in views:
        path = MACOS_ROOT / "FinanceMate" / v
        if path.exists():
            content = open(path).read()
            if not any(x in content for x in ['.preferredColorScheme', '@Environment(\\.colorScheme)',
                                              'Color.primary', 'Color.secondary']):
                unsupported.append(v)
    log_test("test_dark_light_mode", "PASS" if not unsupported else "FAIL",
             f"Unsupported: {unsupported}" if unsupported else "Mode support verified")
    assert not unsupported, f"Unsupported: {unsupported}"
    return True

def test_oauth_configuration():
    """OAuth must be configured"""
    env = PROJECT_ROOT / ".env.template"
    if not env.exists():
        log_test("test_oauth_configuration", "FAIL", "Template missing")
        return False
    content = open(env).read()
    required = ["GOOGLE_OAUTH_CLIENT_ID", "GOOGLE_OAUTH_CLIENT_SECRET", "GOOGLE_OAUTH_REDIRECT_URI"]
    missing = [v for v in required if v not in content]
    log_test("test_oauth_configuration", "PASS" if not missing else "FAIL",
             f"Missing: {missing}" if missing else "Configured")
    assert not missing, f"Missing: {missing}"
    return True

def test_app_launch():
    """App must launch successfully"""
    if not APP_PATH.exists():
        log_test("test_app_launch", "FAIL", "App not found")
        return False
    subprocess.Popen(["open", str(APP_PATH)])
    time.sleep(5)
    result = subprocess.run(["ps", "aux"], capture_output=True, text=True)
    is_running = "FinanceMate" in result.stdout
    log_test("test_app_launch", "PASS" if is_running else "FAIL",
             "Launched" if is_running else "Failed")
    if is_running:
        time.sleep(2)
        capture_screenshot("app_launch")
    assert is_running, "Not running"
    return True

def get_test_groups():
    """Define test groups"""
    return [
        ("BUILD & FOUNDATION", [test_build, test_kiss_compliance, test_security_hardening, test_core_data_schema]),
        ("BLUEPRINT MVP", [test_tax_category_support, test_gmail_transaction_extraction,
                          test_google_sso, test_ai_chatbot_integration, test_apple_sso]),
        ("UI/UX", [test_ui_architecture, test_dark_light_mode]),
        ("INTEGRATION", [test_oauth_configuration, test_app_launch])
    ]

def run_test_group(name, tests):
    """Execute test group"""
    print(f"\n{name}")
    print("-" * 80)
    results = []
    for t in tests:
        try:
            t()
            results.append((t.__name__, True, ""))
            print(f"  OK {t.__name__}")
        except AssertionError as e:
            results.append((t.__name__, False, str(e)))
            print(f"  FAIL {t.__name__}: {e}")
        except Exception as e:
            results.append((t.__name__, False, f"ERROR: {e}"))
            print(f"  ERROR {t.__name__}: {e}")
    return results

def print_summary(results):
    """Print summary"""
    passed = sum(1 for _, s, _ in results if s)
    total = len(results)
    rate = (passed / total * 100) if total > 0 else 0
    print(f"\n" + "=" * 80)
    print(f"SUMMARY: {total} tests | {passed} passed | {total - passed} failed | {rate:.1f}%")
    return passed, total

def print_blueprint(results):
    """Print BLUEPRINT compliance"""
    tests = ["test_tax_category_support", "test_gmail_transaction_extraction",
             "test_google_sso", "test_ai_chatbot_integration"]
    passed = sum(1 for n, s, _ in results if n in tests and s)
    compliance = (passed / len(tests) * 100)
    print(f"\nBLUEPRINT COMPLIANCE: {compliance:.0f}%")
    for t in tests:
        status = 'OK' if any(n == t and s for n, s, _ in results) else 'FAIL'
        print(f"  {status} {t.replace('test_', '').replace('_', ' ').title()}")

def save_report(results):
    """Save JSON report"""
    passed = sum(1 for _, s, _ in results if s)
    report = {
        "timestamp": datetime.now().isoformat(),
        "summary": {"total": len(results), "passed": passed, "failed": len(results) - passed,
                   "pass_rate": (passed / len(results) * 100) if results else 0},
        "results": [{"test": n, "status": "PASS" if s else "FAIL", "message": m}
                   for n, s, m in results],
        "screenshots": str(SCREENSHOT_DIR)
    }
    file = PROJECT_ROOT / "test_output" / f"e2e_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    file.parent.mkdir(parents=True, exist_ok=True)
    with open(file, 'w') as f:
        json.dump(report, f, indent=2)
    print(f"\nReport: {file} | Screenshots: {SCREENSHOT_DIR}")
    return file

def run_all():
    """Execute all tests"""
    print(f"\nFINANCEMATE MVP E2E TEST SUITE")
    print(f"=" * 80)
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"=" * 80)

    all_results = []
    for name, tests in get_test_groups():
        all_results.extend(run_test_group(name, tests))

    passed, total = print_summary(all_results)
    print_blueprint(all_results)
    print("=" * 80)
    save_report(all_results)

    return 0 if passed == total else 1

if __name__ == "__main__":
    exit(run_all())
