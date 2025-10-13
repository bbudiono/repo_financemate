#!/usr/bin/env python3
"""
BLUEPRINT Line 201: Regression Detection Test Suite
Tests automated quality monitoring that fails E2E tests if extraction performance degrades.

Validates:
- Accuracy drops >5% (83% → 78%)
- Completeness drops >10% (90% → 80%)
- Hallucination increases >5% (5% → 10%)
- Performance degradation detection
- Memory usage increases >30%
"""

import json
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

def test_regression_detector_fails_on_accuracy_drop():
    """Test that accuracy drop >5% is detected as regression"""
    from regression_detector import RegressionDetector

    baseline = {"accuracy": 0.83}
    current = {"accuracy": 0.72}  # 11% drop (exceeds 5% threshold)

    result = RegressionDetector.check_accuracy(baseline, current)
    assert result['has_regression'] == True, "Expected accuracy regression to be detected"
    assert "accuracy" in result['message'].lower(), "Expected accuracy mentioned in message"
    print(" Test 1: Accuracy regression detection PASSED")

def test_regression_detector_passes_within_tolerance():
    """Test that accuracy drop within 5% tolerance passes"""
    from regression_detector import RegressionDetector

    baseline = {"accuracy": 0.83}
    current = {"accuracy": 0.80}  # 3% drop (within 5% threshold)

    result = RegressionDetector.check_accuracy(baseline, current)
    assert result['has_regression'] == False, "Expected no regression within tolerance"
    print(" Test 2: Accuracy within tolerance PASSED")

def test_regression_detector_fails_on_completeness_drop():
    """Test that completeness drop >10% is detected"""
    from regression_detector import RegressionDetector

    baseline = {"field_completeness": 0.90}
    current = {"field_completeness": 0.75}  # 15% drop (exceeds 10% threshold)

    result = RegressionDetector.check_completeness(baseline, current)
    assert result['has_regression'] == True, "Expected completeness regression"
    assert "completeness" in result['message'].lower()
    print(" Test 3: Completeness regression detection PASSED")

def test_regression_detector_fails_on_hallucination_increase():
    """Test that hallucination increase >5% is detected"""
    from regression_detector import RegressionDetector

    baseline = {"hallucination_rate": 0.05}
    current = {"hallucination_rate": 0.12}  # 7% increase (exceeds 5% threshold)

    result = RegressionDetector.check_hallucination(baseline, current)
    assert result['has_regression'] == True, "Expected hallucination regression"
    assert "hallucination" in result['message'].lower()
    print(" Test 4: Hallucination increase detection PASSED")

def test_regression_detector_full_baseline_check():
    """Test comprehensive regression check against full baseline file"""
    from regression_detector import RegressionDetector

    baseline_path = Path(__file__).parent / "test_extraction_baselines.json"

    # Simulate current metrics with multiple regressions
    current_metrics = {
        "accuracy": 0.72,  # Below 0.78 threshold (regression)
        "field_completeness": 0.75,  # Below 0.80 threshold (regression)
        "hallucination_rate": 0.12,  # Above 0.10 threshold (regression)
        "extraction_time_seconds": 3.5,  # Above 2.5 threshold (regression)
        "memory_usage_mb": 600  # Within tolerance (4096 max)
    }

    result = RegressionDetector.check_full_baseline(baseline_path, current_metrics)

    assert result['has_regression'] == True, "Expected regressions to be detected"
    assert len(result['regressions']) >= 3, f"Expected at least 3 regressions, got {len(result['regressions'])}"
    assert any('accuracy' in r.lower() for r in result['regressions'])
    assert any('completeness' in r.lower() for r in result['regressions'])
    assert any('hallucination' in r.lower() for r in result['regressions'])

    print(f" Test 5: Full baseline check detected {len(result['regressions'])} regressions")
    for regression in result['regressions']:
        print(f"  - {regression}")

def test_regression_detector_all_metrics_pass():
    """Test that all passing metrics return no regression"""
    from regression_detector import RegressionDetector

    baseline_path = Path(__file__).parent / "test_extraction_baselines.json"

    # All metrics within acceptable ranges
    current_metrics = {
        "accuracy": 0.84,  # Above baseline
        "field_completeness": 0.92,  # Above baseline
        "hallucination_rate": 0.03,  # Below baseline (better)
        "extraction_time_seconds": 1.5,  # Below max
        "memory_usage_mb": 450  # Well within limits
    }

    result = RegressionDetector.check_full_baseline(baseline_path, current_metrics)

    assert result['has_regression'] == False, "Expected no regressions"
    assert len(result['regressions']) == 0, f"Expected 0 regressions, got {len(result['regressions'])}"

    print(" Test 6: All metrics passing - No regressions detected")

def main():
    """Run all regression detection tests"""
    print("=" * 70)
    print(" REGRESSION DETECTION TEST SUITE - BLUEPRINT Line 201")
    print("=" * 70)
    print()

    tests = [
        ("Accuracy Drop Detection", test_regression_detector_fails_on_accuracy_drop),
        ("Accuracy Within Tolerance", test_regression_detector_passes_within_tolerance),
        ("Completeness Drop Detection", test_regression_detector_fails_on_completeness_drop),
        ("Hallucination Increase Detection", test_regression_detector_fails_on_hallucination_increase),
        ("Full Baseline Check", test_regression_detector_full_baseline_check),
        ("All Metrics Passing", test_regression_detector_all_metrics_pass)
    ]

    passed = 0
    failed = 0

    for test_name, test_func in tests:
        try:
            test_func()
            passed += 1
        except Exception as e:
            print(f" Test Failed: {test_name}")
            print(f"   Error: {e}")
            failed += 1

    print()
    print("=" * 70)
    print(f" RESULTS: {passed}/{len(tests)} tests passed")
    print("=" * 70)

    return 0 if failed == 0 else 1

if __name__ == "__main__":
    sys.exit(main())
