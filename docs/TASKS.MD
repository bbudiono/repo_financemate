# FinanceMate - Task List
**Version:** 0.1.0
**Current Milestone:** Milestone 1 - Foundational Reset

---

## Milestone 1: Foundational Reset

This milestone is focused on creating a stable, verifiable, and compliant starting point for the project. All tasks are P0 and must be completed in order.

### 1.1: Establish Project Structure & Documentation

*   **Task-1.1.1:** [✅] Purge existing repository.
*   **Task-1.1.2:** [✅] Create canonical directory structure (`docs`, `scripts`, `tasks`, `temp`, `_macOS`).
*   **Task-1.1.3:** [✅] Create `.cursorrules` file from the master template.
*   **Task-1.1.4:** [✅] Create `docs/BLUEPRINT.md` with truthful "Alpha" status.
*   **Task-1.1.5:** [✅] Create `docs/TASKS.MD` to track foundational tasks.
*   **Task-1.1.6:** [ ] Create all other canonical documentation files (`DEVELOPMENT_LOG.md`, `ARCHITECTURE.md`, etc.) as empty placeholders.

### 1.2: Create Buildable Application Shell

*   **Task-1.2.1:** [ ] Create a new, empty Xcode project (`FinanceMate.xcodeproj`) within the `_macOS` directory.
*   **Task-1.2.2:** [ ] Configure the Xcode project with two targets: `FinanceMate` (Production) and `FinanceMate-Sandbox`.
*   **Task-1.2.3:** [ ] Create a minimal `ContentView.swift` for the main application target that displays "FinanceMate Production".
*   **Task-1.2.4:** [ ] Create a minimal `ContentView.swift` for the sandbox target that displays "FinanceMate Sandbox" with a visible watermark.
*   **Task-1.2.5:** [ ] Ensure both the `FinanceMate` and `FinanceMate-Sandbox` targets build successfully.

### 1.3: Establish Functional Test Suite

*   **Task-1.3.1:** [ ] Create a new UI Test target (`FinanceMateUITests`) linked to the `FinanceMate` application.
*   **Task-1.3.2:** [ ] Write a single UI test that launches the `FinanceMate` application and verifies that the "FinanceMate Production" text is visible.
*   **Task-1.3.3:** [ ] Execute the UI test and confirm that it passes. This will be the first, verifiable, end-to-end test of the new application.

---
## Backlog - Future Milestones

*   **Milestone 2: Core Feature Implementation**
*   **Milestone 3: Authentication & Security** 