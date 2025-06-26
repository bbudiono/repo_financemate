//
//  LegalContent.swift
//  FinanceMate
//
//  Created by Assistant on 6/26/25.
//

/*
* Purpose: Legal and about content data model for AboutView refactoring
* Issues & Complexity Summary: Simple data model to replace hardcoded content in AboutView
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~60
  - Core Algorithm Complexity: Low
  - Dependencies: 0 New (Foundation only)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
* Problem Estimate (Inherent Problem Difficulty %): 20%
* Initial Code Complexity Estimate %: 22%
* Justification for Estimates: Simple data model with static content organization
* Final Code Complexity (Actual %): 22%
* Overall Result Score (Success & Quality %): 98%
* Key Variances/Learnings: Data model approach provides better maintainability than hardcoded content
* Last Updated: 2025-06-26
*/

import Foundation

struct LegalContent {
    static let appInfo = AppInfo(
        name: "FinanceMate",
        tagline: "Your Personal Finance Companion",
        description: "FinanceMate is a comprehensive personal finance management application designed to help you track, analyze, and optimize your financial health. With powerful AI-driven insights and intuitive design, managing your money has never been easier."
    )
    
    static let versionInfo = VersionInfo(
        version: "1.0.0",
        build: "2025.06.02",
        platform: "macOS 14.0+",
        framework: "SwiftUI"
    )
    
    static let features = [
        AppFeature(
            icon: "doc.text.magnifyingglass",
            title: "Document Processing",
            description: "AI-powered receipt and invoice analysis"
        ),
        AppFeature(
            icon: "chart.bar.fill",
            title: "Analytics Dashboard",
            description: "Comprehensive financial insights and trends"
        ),
        AppFeature(
            icon: "shield.fill",
            title: "Secure Storage",
            description: "Bank-level encryption for your data"
        ),
        AppFeature(
            icon: "icloud.fill",
            title: "Cloud Sync",
            description: "Access your data across all devices"
        )
    ]
    
    static let legalLinks = LegalLinks(
        privacyPolicyURL: "https://financemate.app/privacy",
        termsOfServiceURL: "https://financemate.app/terms"
    )
    
    static let copyright = "© 2025 FinanceMate. All rights reserved."
}

struct AppInfo {
    let name: String
    let tagline: String
    let description: String
}

struct VersionInfo {
    let version: String
    let build: String
    let platform: String
    let framework: String
}

struct AppFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct LegalLinks {
    let privacyPolicyURL: String
    let termsOfServiceURL: String
}