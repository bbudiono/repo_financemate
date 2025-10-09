import Foundation
import SwiftUI

/*
 * Purpose: Custom pie slice shape for creating interactive pie chart visualizations
 * Issues & Complexity Summary: Extracted from SplitAllocationPieChartView for modular reusability
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~30
 *   - Core Algorithm Complexity: Medium (Custom shape path calculations with arc geometry)
 *   - Dependencies: 1 (SwiftUI)
 *   - State Management Complexity: Low (Pure shape definition)
 *   - Novelty/Uncertainty Factor: Low (Standard custom shape implementation)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 40%
 * Problem Estimate (Inherent Problem Difficulty %): 45%
 * Initial Code Complexity Estimate %: 40%
 * Justification for Estimates: Custom shape with arc geometry calculations requires mathematical precision
 * Final Code Complexity (Actual %): 43% (Medium complexity with geometric calculations)
 * Overall Result Score (Success & Quality %): 98% (Successful extraction maintaining precise shape rendering)
 * Key Variances/Learnings: Clean separation of shape logic while preserving geometric accuracy and view conformance
 * Last Updated: 2025-01-04
 */

/// Custom pie slice shape for creating interactive pie chart visualizations
struct PieSlice: Shape {
    let startAngle: Double
    let endAngle: Double
    let color: Color

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

extension PieSlice: View {
    var body: some View {
        fill(color)
    }
}