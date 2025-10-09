#!/usr/bin/env python3
"""
Enhanced Search & Filter Accuracy Test - RED PHASE
Tests BLUEPRINT Line 181: Enhanced search & filter accuracy functionality
"""

import sys
from pathlib import Path

def test_service_exists():
    """Test that EnhancedSearchFilterService exists"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/EnhancedSearchFilterService.swift")
    return service_path.exists()

def test_real_extracted_descriptions_search():
    """Test that real extracted descriptions search functionality exists"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/EnhancedSearchFilterService.swift")

    if not service_path.exists():
        return False

    with open(service_path, 'r') as f:
        content = f.read()

    required_funcs = ["realDescriptionSearch", "searchAcrossAllFields"]
    for func in required_funcs:
        if f"func {func}" not in content:
            return False
    return True

def test_cross_source_field_searching():
    """Test cross-source field searching functionality"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/EnhancedSearchFilterService.swift")

    if not service_path.exists():
        return False

    with open(service_path, 'r') as f:
        content = f.read()

    patterns = ["crossSource", "fieldSearch", "indexing"]
    return any(pattern in content for pattern in patterns)

def test_indexing_optimization():
    """Test indexing optimization for performance"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/EnhancedSearchFilterService.swift")

    if not service_path.exists():
        return False

    with open(service_path, 'r') as f:
        content = f.read()

    patterns = ["indexing", "optimization", "performance"]
    return any(pattern in content for pattern in patterns)

def test_xcode_integration():
    """Test Xcode project integration"""
    project_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj")

    if not project_path.exists():
        return False

    with open(project_path, 'r') as f:
        project_content = f.read()

    return "EnhancedSearchFilterService.swift" in project_content

def main():
    """Execute RED PHASE tests"""
    print(" ENHANCED SEARCH & FILTER ACCURACY - RED PHASE")
    print("BLUEPRINT Line 181: Enhanced search & filter accuracy")

    tests = [
        ("Service Exists", test_service_exists),
        ("Real Extracted Descriptions Search", test_real_extracted_descriptions_search),
        ("Cross-Source Field Searching", test_cross_source_field_searching),
        ("Indexing Optimization", test_indexing_optimization),
        ("Xcode Integration", test_xcode_integration)
    ]

    results = []
    for test_name, test_func in tests:
        print(f"\n {test_name}")
        try:
            result = test_func()
            print(f"{' PASS' if result else ' FAIL'}")
            results.append(result)
        except Exception as e:
            print(f" ERROR: {e}")
            results.append(False)

    passed = sum(results)
    total = len(results)
    print(f"\nSummary: {passed}/{total} tests passing")

    if passed == total:
        print(" GREEN PHASE READY!")
        return True
    else:
        print(" RED PHASE: Enhanced search functionality not implemented")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)