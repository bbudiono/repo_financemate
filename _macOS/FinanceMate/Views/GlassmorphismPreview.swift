// SANDBOX FILE: For testing/development. See .cursorrules.
//
// GlassmorphismPreview.swift
// FinanceMate Sandbox
//
// Purpose: Preview components and demo UI for glassmorphism effects
// Issues & Complexity Summary: Preview system extracted for modular testing
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~40
//   - Core Algorithm Complexity: Low
//   - Dependencies: 1 Standard (SwiftUI preview system)
//   - State Management Complexity: Low
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 92%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 75%
// Final Code Complexity: 80%
// Overall Result Score: 96%
// Key Variances/Learnings: Modular preview system for better development workflow
// Last Updated: 2025-08-22 (Modular refactoring for KISS compliance)

import SwiftUI

/// Preview container for testing glassmorphism effects across different styles
struct GlassmorphismPreviewContainer: View {
    var body: some View {
        ZStack {
            // Background gradient for better visibility
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                glassmorphismDemoCard(
                    title: "Primary",
                    subtitle: "Main containers",
                    style: .primary,
                    cornerRadius: 16
                )

                glassmorphismDemoCard(
                    title: "Secondary",
                    subtitle: "Nested elements",
                    style: .secondary,
                    cornerRadius: 12
                )

                glassmorphismDemoCard(
                    title: "Accent",
                    subtitle: "Highlights",
                    style: .accent,
                    cornerRadius: 8
                )

                glassmorphismDemoCard(
                    title: "Minimal",
                    subtitle: "Subtle overlays",
                    style: .minimal,
                    cornerRadius: 6
                )

                glassmorphismDemoCard(
                    title: "Ultra Thin",
                    subtitle: "Maximum transparency",
                    style: .ultraThin,
                    cornerRadius: 10
                )

                glassmorphismDemoCard(
                    title: "Thick",
                    subtitle: "Heavy glass effect",
                    style: .thick,
                    cornerRadius: 14
                )

                glassmorphismDemoCard(
                    title: "Vibrant",
                    subtitle: "Enhanced colors",
                    style: .vibrant,
                    cornerRadius: 12
                )
            }
            .padding()
        }
    }

    /// Creates a demo card for a specific glassmorphism style
    private func glassmorphismDemoCard(
        title: String,
        subtitle: String,
        style: GlassmorphismStyle,
        cornerRadius: CGFloat
    ) -> some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .glassmorphism(style, cornerRadius: cornerRadius)
    }
}

/// Preview providers for different color schemes
#Preview("Light Mode") {
    GlassmorphismPreviewContainer()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    GlassmorphismPreviewContainer()
        .preferredColorScheme(.dark)
}

/// Individual style preview for focused testing
#Preview("Primary Style Focus") {
    ZStack {
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack {
            Text("Primary Glassmorphism")
                .font(.title)
                .fontWeight(.bold)
            Text("Main container style with strong visual effect")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .glassmorphism(.primary, cornerRadius: 20)
    }
    .padding()
}

/// Comparison preview for style hierarchy
#Preview("Style Hierarchy Comparison") {
    ZStack {
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 20) {
            Text("Glassmorphism Hierarchy")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 16) {
                Text("Primary")
                    .padding()
                    .glassmorphism(.primary, cornerRadius: 12)

                Text("Secondary")
                    .padding()
                    .glassmorphism(.secondary, cornerRadius: 12)
            }

            HStack(spacing: 16) {
                Text("Accent")
                    .padding()
                    .glassmorphism(.accent, cornerRadius: 12)

                Text("Minimal")
                    .padding()
                    .glassmorphism(.minimal, cornerRadius: 12)
            }
        }
        .padding()
    }
}