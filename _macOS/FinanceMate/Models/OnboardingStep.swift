//
// OnboardingStep.swift
// FinanceMate
//
// Purpose: Data model for onboarding flow steps
// KISS-compliant: Simple struct with no business logic
// Last Updated: 2025-10-28

import SwiftUI

/// Represents a single step in the onboarding flow
struct OnboardingStep: Identifiable {
    let id: Int
    let title: String
    let description: String
    let systemImage: String
    let features: [String]

    /// Pre-defined onboarding steps
    static let steps: [OnboardingStep] = [
        OnboardingStep(
            id: 0,
            title: "Welcome to FinanceMate",
            description: "Your intelligent personal finance companion for smarter money management",
            systemImage: "chart.bar.fill",
            features: [
                "Track income, expenses, and investments",
                "Smart receipt extraction from Gmail",
                "AI-powered financial insights",
                "Australian tax compliance (GST, SMSF, ABN)"
            ]
        ),
        OnboardingStep(
            id: 1,
            title: "Connect Your Gmail",
            description: "Automatically extract receipts and transactions from your email",
            systemImage: "envelope.fill",
            features: [
                "Secure OAuth 2.0 authentication",
                "Automatic receipt detection",
                "Smart transaction categorization",
                "Foreign currency conversion to AUD"
            ]
        ),
        OnboardingStep(
            id: 2,
            title: "Explore Your Features",
            description: "Discover the powerful tools at your fingertips",
            systemImage: "star.fill",
            features: [
                "Dashboard: Real-time financial overview",
                "Transactions: Detailed expense tracking",
                "Gmail: Receipt processing center",
                "AI Assistant: Ask financial questions"
            ]
        )
    ]
}
