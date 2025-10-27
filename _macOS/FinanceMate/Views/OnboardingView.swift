//
// OnboardingView.swift
// FinanceMate
//
// Purpose: 3-step progressive disclosure onboarding with glassmorphism design
// KISS-compliant: <200 lines, native TabView, simple state management
// Last Updated: 2025-10-28

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Gradient background matching app aesthetic
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.14, blue: 0.49).opacity(0.8),
                    Color(red: 0.16, green: 0.21, blue: 0.58).opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentStep)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 16)

                // Step content
                TabView(selection: $currentStep) {
                    ForEach(OnboardingStep.steps) { step in
                        OnboardingStepView(step: step)
                            .tag(step.id)
                    }
                }
                .tabViewStyle(.automatic)
                .animation(.easeInOut, value: currentStep)

                // Navigation controls
                HStack(spacing: 24) {
                    // Skip button
                    Button(action: { isPresented = false }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(minWidth: 80)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                            )
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Next/Get Started button
                    Button(action: {
                        if currentStep < 2 {
                            withAnimation {
                                currentStep += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentStep < 2 ? "Next" : "Get Started")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(minWidth: 120)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                Capsule()
                                    .fill(Color.blue)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: 600, maxHeight: 700)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .padding(40)
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isPresented = false
    }
}

/// Individual step view with feature list
private struct OnboardingStepView: View {
    let step: OnboardingStep
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: step.systemImage)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundColor(.blue)
            }
            .padding(.top, 32)

            // Title and description
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(step.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }

            // Feature list
            VStack(alignment: .leading, spacing: 16) {
                ForEach(step.features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)

                        Text(feature)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 16)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
