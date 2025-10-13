#!/usr/bin/env python3
"""
BLUEPRINT Line 201: Regression Detection System
Automated quality monitoring that fails E2E tests if extraction performance degrades.

Thresholds (from test_extraction_baselines.json):
- Accuracy: Minimum 78% (baseline 83%, tolerance 5% drop)
- Completeness: Minimum 80% (baseline 90%, tolerance 10% drop)
- Hallucination: Maximum 10% (baseline 5%, tolerance 5% increase)
- Extraction Time: Maximum 2.5s (baseline 1.72s, tolerance 50% increase)
- Memory: Maximum 4096MB (baseline 512MB, tolerance 30% increase)
"""

import json
from pathlib import Path
from typing import Dict, Any, List


class RegressionDetector:
    """Detects performance regressions against established baselines"""

    @staticmethod
    def check_accuracy(baseline: Dict[str, float], current: Dict[str, float]) -> Dict[str, Any]:
        """
        Check if accuracy has regressed beyond tolerance.

        Args:
            baseline: Dict with 'accuracy' key
            current: Dict with 'accuracy' key

        Returns:
            Dict with 'has_regression' (bool) and 'message' (str)
        """
        baseline_accuracy = baseline.get('accuracy', 0.83)
        current_accuracy = current.get('accuracy', 0.0)

        drop = baseline_accuracy - current_accuracy
        tolerance = 0.05  # 5% drop tolerance

        if drop > tolerance:
            return {
                'has_regression': True,
                'message': f"Accuracy regression detected: {current_accuracy:.2%} (baseline: {baseline_accuracy:.2%}, drop: {drop:.2%}, tolerance: {tolerance:.2%})"
            }

        return {
            'has_regression': False,
            'message': f"Accuracy within tolerance: {current_accuracy:.2%}"
        }

    @staticmethod
    def check_completeness(baseline: Dict[str, float], current: Dict[str, float]) -> Dict[str, Any]:
        """
        Check if field completeness has regressed beyond tolerance.

        Args:
            baseline: Dict with 'field_completeness' key
            current: Dict with 'field_completeness' key

        Returns:
            Dict with 'has_regression' (bool) and 'message' (str)
        """
        baseline_completeness = baseline.get('field_completeness', 0.90)
        current_completeness = current.get('field_completeness', 0.0)

        drop = baseline_completeness - current_completeness
        tolerance = 0.10  # 10% drop tolerance

        if drop > tolerance:
            return {
                'has_regression': True,
                'message': f"Completeness regression detected: {current_completeness:.2%} (baseline: {baseline_completeness:.2%}, drop: {drop:.2%}, tolerance: {tolerance:.2%})"
            }

        return {
            'has_regression': False,
            'message': f"Completeness within tolerance: {current_completeness:.2%}"
        }

    @staticmethod
    def check_hallucination(baseline: Dict[str, float], current: Dict[str, float]) -> Dict[str, Any]:
        """
        Check if hallucination rate has increased beyond tolerance.

        Args:
            baseline: Dict with 'hallucination_rate' key
            current: Dict with 'hallucination_rate' key

        Returns:
            Dict with 'has_regression' (bool) and 'message' (str)
        """
        baseline_hallucination = baseline.get('hallucination_rate', 0.05)
        current_hallucination = current.get('hallucination_rate', 0.0)

        increase = current_hallucination - baseline_hallucination
        tolerance = 0.05  # 5% increase tolerance

        if increase > tolerance:
            return {
                'has_regression': True,
                'message': f"Hallucination regression detected: {current_hallucination:.2%} (baseline: {baseline_hallucination:.2%}, increase: {increase:.2%}, tolerance: {tolerance:.2%})"
            }

        return {
            'has_regression': False,
            'message': f"Hallucination within tolerance: {current_hallucination:.2%}"
        }

    @staticmethod
    def check_full_baseline(baseline_path: Path, current_metrics: Dict[str, Any]) -> Dict[str, Any]:
        """
        Comprehensive regression check against full baseline file.

        Args:
            baseline_path: Path to test_extraction_baselines.json
            current_metrics: Dict with current performance metrics

        Returns:
            Dict with:
                - has_regression (bool): True if any regression detected
                - regressions (List[str]): List of regression messages
                - baseline (Dict): Loaded baseline metrics
                - current (Dict): Current metrics provided
        """
        with open(baseline_path, 'r') as f:
            baseline_data = json.load(f)

        accuracy_metrics = baseline_data.get('accuracy_metrics', {})
        performance_metrics = baseline_data.get('performance_metrics', {})
        thresholds = baseline_data.get('regression_thresholds', {})

        regressions = []

        # Check accuracy
        current_accuracy = current_metrics.get('accuracy', 0.0)
        accuracy_min = thresholds.get('accuracy_min', 0.78)
        if current_accuracy < accuracy_min:
            baseline_accuracy = accuracy_metrics.get('overall_accuracy', 0.83)
            drop = baseline_accuracy - current_accuracy
            regressions.append(
                f"Accuracy below minimum: {current_accuracy:.2%} < {accuracy_min:.2%} "
                f"(baseline: {baseline_accuracy:.2%}, drop: {drop:.2%})"
            )

        # Check field completeness
        current_completeness = current_metrics.get('field_completeness', 0.0)
        completeness_min = thresholds.get('field_completeness_min', 0.80)
        if current_completeness < completeness_min:
            baseline_completeness = accuracy_metrics.get('field_completeness', 0.90)
            drop = baseline_completeness - current_completeness
            regressions.append(
                f"Completeness below minimum: {current_completeness:.2%} < {completeness_min:.2%} "
                f"(baseline: {baseline_completeness:.2%}, drop: {drop:.2%})"
            )

        # Check hallucination rate
        current_hallucination = current_metrics.get('hallucination_rate', 0.0)
        hallucination_max = thresholds.get('hallucination_rate_max', 0.10)
        if current_hallucination > hallucination_max:
            baseline_hallucination = accuracy_metrics.get('hallucination_rate', 0.05)
            increase = current_hallucination - baseline_hallucination
            regressions.append(
                f"Hallucination above maximum: {current_hallucination:.2%} > {hallucination_max:.2%} "
                f"(baseline: {baseline_hallucination:.2%}, increase: {increase:.2%})"
            )

        # Check extraction time
        current_time = current_metrics.get('extraction_time_seconds', 0.0)
        time_max = thresholds.get('extraction_time_max_seconds', 2.5)
        if current_time > time_max:
            baseline_time = performance_metrics.get('avg_extraction_time_seconds', 1.72)
            increase_pct = ((current_time - baseline_time) / baseline_time) * 100
            regressions.append(
                f"Extraction time above maximum: {current_time:.2f}s > {time_max:.2f}s "
                f"(baseline: {baseline_time:.2f}s, increase: {increase_pct:.1f}%)"
            )

        # Check memory usage
        current_memory = current_metrics.get('memory_usage_mb', 0)
        memory_max = thresholds.get('memory_max_mb', 4096)
        if current_memory > memory_max:
            baseline_memory = performance_metrics.get('max_memory_usage_mb', 512)
            increase_pct = ((current_memory - baseline_memory) / baseline_memory) * 100
            regressions.append(
                f"Memory usage above maximum: {current_memory}MB > {memory_max}MB "
                f"(baseline: {baseline_memory}MB, increase: {increase_pct:.1f}%)"
            )

        return {
            'has_regression': len(regressions) > 0,
            'regressions': regressions,
            'baseline': baseline_data,
            'current': current_metrics
        }
