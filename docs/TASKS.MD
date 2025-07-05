# FinanceMate - Task List
**Version:** 0.2.0
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
*   **Task-1.1.6:** [✅] Create all other canonical documentation files (`DEVELOPMENT_LOG.md`, `ARCHITECTURE.md`, etc.) as empty placeholders.

### 1.2: Create Buildable Application & Sandbox Shell

*   **Task-1.2.1:** [✅] Create basic Swift files (`FinanceMateApp.swift`, `ContentView.swift`).
*   **Task-1.2.2:** [✅] Generate `FinanceMate.xcodeproj` using `XcodeGen` with a `project.yml` definition.
*   **Task-1.2.3:** [✅] Add minimal `Info.plist` with necessary keys.
*   **Task-1.2.4:** [✅] Successfully build the empty application shell using `xcodebuild`.
*   **Task-1.2.5:** [✅] Create `_macOS/FinanceMate-Sandbox` directory and copy source files.
*   **Task-1.2.6:** [✅] Modify the Sandbox `ContentView.swift` to display "FinanceMate Sandbox" and include the mandatory file header.
*   **Task-1.2.7:** [✅] Update `project.yml` to define the `FinanceMate-Sandbox` target.
*   **Task-1.2.8:** [✅] Regenerate the Xcode project and build both `FinanceMate` and `FinanceMate-Sandbox` targets successfully.

### 1.3: Establish Functional Test Suite

*   **Task-1.3.1:** [ ] Create a new UI Test target (`FinanceMateUITests`) linked to the `FinanceMate` application.
*   **Task-1.3.2:** [ ] Write a single UI test that launches the `FinanceMate` application and verifies that the "FinanceMate Production" text is visible.
*   **Task-1.3.3:** [ ] Execute the UI test and confirm that it passes. This will be the first, verifiable, end-to-end test of the new application.

---
## Backlog - Future Milestones

*   **Milestone 2: Core Feature Implementation**
*   **Milestone 3: Authentication & Security** 