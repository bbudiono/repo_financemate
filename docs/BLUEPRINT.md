# FinanceMate - BLUEPRINT.md
**Version:** 0.1.0 (Alpha)
**Last Updated:** 2025-07-05
**Project Status:** ALPHA - Project Reset

---

## 1. Project Overview

**FinanceMate** is a macOS application designed to provide users with a comprehensive suite of tools for managing their personal finances. It aims to automate expense tracking, provide insightful analytics, and offer AI-driven financial advice.

*   **Project Name:** FinanceMate
*   **Platform:** macOS (SwiftUI, AppKit)
*   **Current Phase:** Alpha Development - Foundational Reset
*   **Deployment Readiness:** **NOT READY FOR PRODUCTION**
*   **Primary Objective:** Establish a stable, buildable, and testable foundation for the application.

## 2. Core Architecture & Technology

*   **Architecture:** MVVM (Model-View-ViewModel)
*   **Language:** Swift 5.10+
*   **UI Framework:** SwiftUI
*   **Core Data:** For local persistence.
*   **Testing:** XCTest for unit and UI testing. TDD is mandatory.
*   **AI/ML:** All AI/ML modules are **NOT IMPLEMENTED**. The initial focus is on building non-AI core features. The `TaskMaster-AI` MCP is to be used as a development tool, not a user-facing feature.
*   **Authentication:** Local-only authentication will be implemented first. OAuth2/SSO integration is a future milestone.

## 3. Project Configuration & Environment

*   **Project Root:** `{repo_root}` (This repository)
*   **Production App:** `_macOS/FinanceMate/`
*   **Sandbox App:** `_macOS/FinanceMate-Sandbox/`
*   **Xcode Project:** `_macOS/FinanceMate.xcodeproj`
*   **Build Tools:** Xcode 16+, Swift Package Manager

## 4. Key Milestones & Roadmap

### Milestone 1: Foundational Reset (Current)

*   [x] Purge repository of all non-compliant files.
*   [x] Establish a clean, compliant directory structure.
*   [x] Create foundational documentation (`.cursorrules`, `BLUEPRINT.md`, `TASKS.MD`).
*   [ ] Create a minimal, buildable SwiftUI application shell for both Production and Sandbox targets.
*   [ ] Establish a functional, TDD-driven test suite that successfully runs against the app shell.

### Milestone 2: Core Feature Implementation

*   [ ] Implement local data persistence using Core Data.
*   [ ] Develop core UI views (Dashboard, Transactions, Settings) based on the Glassmorphism theme.
*   [ ] Implement basic, manual transaction entry.

### Milestone 3: Authentication & Security

*   [ ] Implement a secure, local-only user authentication system.
*   [ ] Integrate Keychain for secure credential storage.

---

## 5. Non-Negotiable Compliance Points

*   **Documentation:** All documentation must be kept up-to-date and reflect the *actual* state of the project.
*   **Testing:** No code is to be committed without corresponding, passing tests. The test suite must remain in a runnable state at all times.
*   **Builds:** Both Production and Sandbox builds must succeed at all times. A broken build is a P0 issue.
*   **No Placeholders:** All implemented code must be functional. No simulated or fake implementations are permitted. 