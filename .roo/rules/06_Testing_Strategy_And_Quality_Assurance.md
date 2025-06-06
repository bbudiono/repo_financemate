---
description: Implementing new features, bug fixes, or refactors—ensures all changes are tested in isolation, validated, and only merged after passing all tests.
globs: 
alwaysApply: false
---
---
description: 
globs: testing,build,tasks,TDD,test-driven,sandbox,production
alwaysApply: false
---
# Recent Lessons Learned & Continuous Improvement

- **Automated Checks & Programmatic Execution:** Always use automated scripts and programmatic tools for test, build, and QA verification before any manual intervention.
- **TDD & Sandbox-First Workflow:** All new features and bug fixes must be developed using TDD and validated in a sandbox before production.
- **Comprehensive Logging & Documentation:** Log all test failures, fixes, protocol deviations, and significant actions in canonical logs for audit and continuous improvement. Update all relevant documentation and protocols after each incident or improvement.
- **Backup/Restore Automation:** Maintain regular, automated backups of all critical files, configurations, and documentation. Use restoration scripts for recovery.
- **Automation Script Review:** Regularly review and refine automation scripts for all workflows (build, test, task, code quality, documentation, tooling, governance).
- **Directory Hygiene:** Enforce strict directory cleanliness and backup rotation to prevent stray files and ensure recoverability.
- **Granular Task Breakdown & Status Automation:** Always break down high-level tasks to granular, testable sub-tasks before implementation. Use automated tools to update task status and trigger workflow automation.
- **Comprehensive Test Coverage & Code Review:** Ensure high coverage for all critical modules and perform rigorous code reviews for all changes, focusing on clarity, maintainability, and adherence to standards.
- **Regular Rule Review & Improvement:** Schedule and enforce periodic reviews of all rule files and automation scripts to ensure relevance, clarity, and effectiveness.

## (CRITICAL AND MANDATORY) Pre-Refactoring and Coding Protocol

**BEFORE REFACTORING OR CODING ANY FILES, ENSURE YOU:**
1. Pause, think, analyse, plan – use `sequential-thinking`, `memory`, and `puppeteer` MCP Group tools to structure your thoughts, draw on memory, and perform web analysis as needed.
2. Ensure there is a task created, and `taskmaster-ai` MCP has effectively broken down the task to level 5-6 and also provided suitable information about the task.
3. Use `sequential-thinking` MCP Server and do a quick web search_files to get as much information about similar applications, rival apps, etc, and get as much information from the `BLUEPRINT.md`.
4. Review 'ExampleCode/' folder and understand the context of how to best write Swift Code, using examples. Use `sequential-thinking` and `context7` MCP to research and plan the design based on example. Use `memory` MCP to store this knowledge.
5. Under the Sandbox/Testing Environment: Write the following tests: failing, unit, integration, end-to-end, automation, performance, security, acceptance.
6. Test and adjust testing until all of these tests are passing.
7. Then write the code for the view and ensure it is the best written piece of code you can make it and fulfills the user's requirements.
8. Check Both Sandbox and Production Tests and ensure that any failures are documented and you go back to Step 5.
9. Completed Cycle – attempt to finish in 1 cycle.

Reference: See .cursorrules for enforcement and compliance.

# 06. Testing Strategy & Quality Assurance

## 1. Core Testing Principles

*   **(CRITICAL AND MANDATORY) Test-Driven Development (TDD) as Default:**
    *   TDD is the preferred approach for all new feature development and bug fixing.
    *   **Procedure:**
        1.  Write a failing test (unit, integration, or UI) that clearly defines the desired functionality or reproduces the bug.
        2.  Write the minimal amount of production code necessary to make the failing test pass.
        3.  Verify the build is green (see `@04_Build_Integrity_Xcode_And_SweetPad_Management.md`).
        4.  Run all relevant tests. If they pass, proceed to refactor.
        5.  Refactor the production code and test code for clarity, performance, and maintainability, ensuring all tests continue to pass.
        6.  Repeat the cycle for the next piece of functionality.
*   **(CRITICAL AND MANDATORY) Comprehensive Test Coverage:**
    *   All new non-trivial functions, methods, classes, and UI components **MUST** have corresponding automated tests.
    *   Aim for high code coverage, especially for critical modules and complex business logic.
*   **(CRITICAL AND MANDATORY) Tests MUST Be Non-Destructive:** Automated tests should not alter the system state in a way that affects subsequent tests or requires manual cleanup. Tests should manage their own setup and teardown.

## 2. Types of Tests & Their Application

*   **(CRITICAL AND MANDATORY) Unit Tests:**
    *   Focus on testing individual units of code (functions, methods, classes) in isolation.
    *   Mock or stub dependencies to ensure isolation.
    *   These should be fast and form the largest part of the test suite.
*   **(CRITICAL AND MANDATORY) Integration Tests:**
    *   Verify the interaction between two or more modules, services, or components of the application.
    *   Focus on data flow, API contracts, and communication between parts of the system.
    *   Key interactions between modules or services **MUST** be covered by integration tests.
*   **(CRITICAL AND MANDATORY) UI Tests (including Visual Validation):
    *   **Functional UI Tests:** Verify that critical user flows and interactions within the UI behave as expected. (e.g., using XCUITest for macOS/iOS).
    *   **Visual Snapshot Testing (If Implemented - see `@behaviours_visual-ai-snapshot.md`):**
        *   Utilize snapshot testing libraries (e.g., Point-Free's `SnapshotTesting`) or custom mechanisms to capture images of SwiftUI views, `NSView`/`UIView`s, or `CALayer`s.
        *   Compare these snapshots against approved "baseline" or "golden master" images to detect unintended visual regressions in layout, appearance, or style.
        *   These tests are particularly important for UI components and screens with complex visual requirements.
        *   If vision-based AI is used for analysis (as per `@behaviours_visual-ai-snapshot.md`), integrate AI findings into UI test assertions or reports.
    *   Critical user flows in UI-based applications **SHOULD** have automated UI tests covering both functionality and key visual aspects.
*   **(RECOMMENDED) Performance Tests:**
    *   Where applicable, implement performance tests to measure and assert on execution time, resource usage (CPU, memory), or response times for critical operations.
*   **(RECOMMENDED) Security Tests:**
    *   Implement tests to verify security controls, input validation, authentication/authorization mechanisms, and protection against common vulnerabilities, as guided by `@07_Coding_Standards_Security_And_UX_Guidelines.md`.

## 3. Sandboxed Development & Testing Protocol

*This section consolidates rules from `environment-sandboxed-development.md`.*

*   **(CRITICAL AND MANDATORY) Isolate Changes in Sandbox:**
    *   All high-value features, significant bug fixes, and substantial refactors **MUST** be initially developed and validated in an isolated sandbox environment before changes are propagated to the main production codebase.
*   **(CRITICAL AND MANDATORY) Sandbox Environment Setup:**
    1.  **Identify Target Files:** Determine all production source files and project configuration files (e.g., `.xcodeproj`, `project.yml` if using xcodegen) that require modification.
    2.  **Create Temporary Copies:**
        *   For each production source file to be edited, create a temporary copy (e.g., `Main.swift` -> `Main_temp.swift`).
        *   For project configuration:
            *   **If using xcodegen:** Create a temporary copy of `project.yml` (e.g., `project_temp.yml`). Modify `project_temp.yml` to use the temporary source file copies (ensuring all production views have equivalent temp/test views). Generate a temporary project file (e.g., `xcodegen --spec project_temp.yml --project App_temp`).
            *   **If NOT using xcodegen:** Create a temporary copy of the main project file (e.g., `App.xcodeproj` -> `App_temp.xcodeproj`). Programmatically modify this temporary project file to reference the temporary source files.
    3.  **Isolation Mandate:** All code modifications for the current task **MUST** be performed ONLY on the temporary source files within this sandboxed project. Original production files **MUST** remain untouched during this phase.
    4.  **Logging:** Log the creation of the sandbox environment and all files involved in `@DEVELOPMENT_LOG.MD`.
*   **(CRITICAL AND MANDATORY) Sandboxed Build & Test Execution:**
    1.  Perform a clean build and run the complete test suite (unit, integration, UI) within the sandboxed project environment (e.g., `xcodebuild clean build -project App_temp.xcodeproj -scheme YOUR_SCHEME_NAME test`).
    2.  All tests **MUST** pass in the sandbox.
*   **(CRITICAL AND MANDATORY) Sandbox Test Result Evaluation & Action:**
    *   **IF SANDBOX BUILD & ALL TESTS SUCCEED:**
        1.  **Propagate Changes:** Carefully copy the content from the successfully tested temporary source files back to their original production counterparts. If new files were added, integrate them into the main project configuration (e.g., main `project.yml` and regenerate, or add to main `.xcodeproj`).
        2.  Log all production files updated/added in `@DEVELOPMENT_LOG.MD`.
        3.  **Cleanup Sandbox:** Delete all temporary files and build artifacts from the sandbox.
        4.  Proceed to post-successful actions (final production build/test, commit, sync, backup as per `@04_Build_Integrity_Xcode_And_SweetPad_Management.md` and `@08_Documentation_Directory_And_Configuration_Management.md`).
    *   **IF SANDBOX BUILD OR ANY TEST FAILS:**
        1.  **Document Initial Sandbox Failure:** Log the exact error, temporary files/changes involved, and attempted operation in `@BUILD_FAILURES.MD` (or a sandbox-specific log if preferred for initial attempts, then summarized to `@BUILD_FAILURES.MD`).
        2.  **Automated Fix & Retry Sequence (Iterative, within Sandbox ONLY):**
            *   Set a maximum of 9-10 iterative fix attempts on the *temporary files*.
            *   For each attempt: Apply a distinct automated fixing strategy, re-run sandbox build & test.
            *   If successful, proceed as per "IF SANDBOX BUILD & ALL TESTS SUCCEED".
            *   If still failing: Revert the current fix attempt's changes on temporary files, log the failed fix attempt, and proceed to the next iteration if within limits.
        3.  **If All Automated Sandbox Fix Attempts Fail:**
            *   **Discard All Sandbox Changes:** Delete all temporary sandbox files. Production codebase remains untouched.
            *   **Document Final Sandbox Failure & Discard:** Update `@BUILD_FAILURES.MD` that all sandbox attempts failed and changes were discarded. Analyze root cause and document lessons learned to inform future approaches.
            *   **Consider GitHub Restoration (Last Resort):** If the AI determines previous production states might have been compromised or the task strategy needs a complete reset, propose GitHub MCP restoration of production to the last known good state (user confirmation required).

## 4. Mandatory Build and Test After Every Change (Production & Sandbox)

*   **(CRITICAL AND MANDATORY) Universal Application:** This rule applies to changes in *both* the sandboxed environment and the main production codebase (after successful sandbox validation and propagation).
*   **(CRITICAL AND MANDATORY) Procedure:**
    1.  After *every* substantive code change, configuration adjustment, or project file modification:
        *   Execute a full, clean build of the application for the relevant target(s) (see `@04_Build_Integrity_Xcode_And_SweetPad_Management.md`).
        *   Run all non-destructive automated tests (unit, integration, critical path UI/visual tests).
    2.  **Failure Protocol:**
        *   If any build or test failure occurs: Halt further development. Document in `@BUILD_FAILURES.MD`. Prioritize fixing as P0.
        *   Do not proceed until the build is green and all essential tests pass.

## 5. Quality Assurance Measures

*   **(CRITICAL AND MANDATORY) Self-Review & Pre-Commit Checks:**
    *   Developers and AI agents **MUST** perform self-reviews of all changes against task requirements, `@07_Coding_Standards_Security_And_UX_Guidelines.md`, and general best practices.
    *   Run linters and formatters (e.g., SwiftLint).
    *   Utilize pre-commit hooks for automated checks where possible (e.g., running linters, basic syntax checks, quick local tests).
*   **(CRITICAL AND MANDATORY) Continuous Test Suite Enhancement:**
    *   Any failures (in sandbox or production) **MUST** inform improvements to the test suite. If a bug is found, a test that reproduces the bug should be written first, then the fix applied.
    *   Regularly review test coverage and add tests for areas that are complex, critical, or historically prone to errors.
*   **(CRITICAL AND MANDATORY) Visual Validation Feedback Loop (Iterative UX/UI Improvement - if applicable, see `@behaviours_visual-ai-snapshot.md`):
    *   If visual AI analysis is part of the QA process:
        1.  **Post-Change Verification:** After UI modifications, re-capture screenshot(s).
        2.  **Re-analysis by AI:** Have the AI re-analyze the visuals to confirm issue resolution and that no new visual regressions were introduced.
        3.  **Iterate or Log:** If validated, log before/after state (or AI confirmation). If issues persist, iterate the UI modification and re-verification process.
        4.  This loop is crucial for continuously enhancing UI/UX based on visual AI feedback.

## 6. UI/UX Testing & Validation

*   **(CRITICAL AND MANDATORY) In-Memory OCR Processing:**
    *   All OCR analysis of UI screenshots **MUST** be performed in-memory.
    *   OCR results **MUST NOT** be stored as .txt files or any other persistent format.
    *   If any temporary .txt files are generated during the OCR process, they **MUST** be deleted immediately after use.
    *   When documenting OCR validation in reports, reference only the screenshot and validation results, not OCR text files.

*   **(CRITICAL AND MANDATORY) Screenshot Capture Protocol:**
    *   Screenshots must be saved to `docs/UX_Snapshots/` using the naming convention `YYYYMMDD_HHMMSS_<TaskID>_<ShortTaskName>.png`.
    *   Each screenshot must be referenced in task documentation and SMEAC/VALIDATION REQUEST.
    *   The navigation path to reach the captured screen state must be documented.
    *   Maintain clean organization of screenshots (by date, feature, or task ID).
    *   Ensure screenshots are captured in a consistent environment (window size, theme, etc.).

*   **(CRITICAL AND MANDATORY) Navigation Tree Documentation:**
    *   Before capturing screenshots, programmatically extract and visualize the app's navigation tree.
    *   Save the navigation tree as a diagram in `docs/UX_Snapshots/navigation_tree.md` or `.png`.
    *   Store a machine-readable version of the navigation structure in `docs/UX_Snapshots/navigation_tree.json`.
    *   Document step-by-step paths to reach each view in `docs/UX_Snapshots/ui_navigation_paths.md`.
    *   Keep a development log of navigation implementation and validation in `docs/UX_Snapshots/navigation_dev_log.md`.

*   **(CRITICAL AND MANDATORY) UI Element Validation:**
    *   Text extracted from screenshots must be validated against expected UI elements and text.
    *   All validation must follow the Autonomous Execution Protocol per `.cursorrules` §1.16.
    *   The agent MUST attempt to resolve any discrepancies programmatically before considering escalation.
    *   Only escalate true P0 issues that cannot be resolved after at least 5 distinct resolution attempts.
    *   UI validation results must be logged in task documentation and the development log.
    *   Compare layout, color schemes, and styling against project style guides.
    *   Check for visual anomalies or unexpected states.

*   **(CRITICAL AND MANDATORY) Required Tooling & Environment Setup:**
    *   Ensure all prerequisite tools are installed:
        * Python 3.x with venv support
        * clickclick (or equivalent screen capture library)
        * Pillow for image processing
        * pytesseract and tesseract-ocr for OCR capabilities
    *   Before any visual testing, run verification script to confirm all tools are working properly.
    *   Log all tool installation and verification steps in `DEVELOPMENT_LOG.MD`.
    *   Block visual testing if any prerequisite check fails.

*   **(CRITICAL AND MANDATORY) Closed-Loop Validation Process:**
    1.  **Navigate** to the target screen/state in the app (follow documented navigation path).
    2.  **Capture Screenshot** using appropriate tooling.
    3.  **Process In-Memory:**
        * Extract text from screenshot using OCR.
        * Perform all analysis in-memory without persisting intermediate results.
        * Delete any temporary files immediately after use.
    4.  **Validate** against expected UI elements and text.
    5.  **Log** results in task documentation and `DEVELOPMENT_LOG.MD`.
    6.  **Escalate** any discrepancies via SMEAC/VALIDATION REQUEST.
    7.  If issues are found, iterate on the UI and repeat the validation process.

## UI/UX OCR Validation Protocol (2025-05-17 Update)

### Prerequisites & Tooling
- Homebrew (macOS package manager)
- Python 3.x (system or Homebrew)
- Python venv (project-specific, e.g., venv/ or temp/venv/)
- clickclick (Python snapshot automation tool)
- Pillow (Python Imaging Library)
- pytesseract (Python Tesseract OCR binding)
- tesseract-ocr (system binary for OCR)
- Diagnostic script: scripts/diagnostics/check_snaptools.sh must verify all prerequisites before any snapshotting task. If any check fails, the process is blocked and escalated.

### Mandatory Steps for UI/UX Changes
1. **Navigation Tree Extraction**: Programmatically extract/update the app's navigation tree before any UI/UX checkpoint. Save as docs/UX_Snapshots/navigation_tree.md and .json.
2. **App Window Screenshot**: Capture only the app window (not desktop/partial). Validate screenshot contains app window chrome/title bar and expected UI region.
3. **OCR Validation**: Use pytesseract to extract visible text from the screenshot in-memory. No OCR .txt files are stored; all transient files are deleted.
4. **Documentation Synchronization**: Update all relevant docs: navigation_tree.md, navigation_tree.json, navigation_dev_log.md, ui_navigation_paths.md. Reference each screenshot with filename, timestamp, navigation path, OCR result, and manual verification if required.
5. **Escalation & User Acceptance**: If OCR fails, escalate as P0, block further progress, and require explicit user decision.
6. **Automation & Auditability**: Automate as much as possible; log all actions and decisions for traceability.

### Enhanced Autonomy in Redundancy & Escalation
- If OCR validation fails (expected UI text not detected, ambiguous result, or screenshot is not of the app window), the agent MUST:
  1. Document the initial failure comprehensively in the logs
  2. Use MCP tools (sequential-thinking, perplexity-ask, context7, memory) to analyze the issue
  3. Attempt at least 5 distinct programmatic resolutions including:
     - Retaking screenshots from different angles/states
     - Adjusting OCR parameters and sensitivity
     - Comparing against known good UI patterns
     - Investigating regressions against previous screenshots
     - Programmatically fixing UI elements if issues are identified
  4. Only after exhausting ALL programmatic resolution approaches should the agent consider escalation
- If, and ONLY if, all programmatic approaches fail after extensive documented attempts:
  - A SMEAC/VALIDATION REQUEST may be generated, including the screenshot, OCR output, navigation path, a detailed failure summary, and documented resolution attempts
  - The agent MUST reference `.cursorrules` §1.16 and Core AI Agent Principles §3.5 to justify the escalation
- All actions, resolution attempts, and automated decisions MUST be logged in docs/DEVELOPMENT_LOG.MD, docs/UX_Snapshots/navigation_dev_log.md
- Escalation to user is a LAST RESORT, not the default response to validation failures

### Blockage & Enforcement
- If any prerequisite is missing or fails, or if any step fails and cannot be remediated, the process is blocked and escalated.
- All failures, escalations, and user decisions are logged for auditability.

## CRITICAL AND MANDATORY: Summary & Recommendation Protocol (2024-05-18 Update)

- All user-facing outputs (including SMEAC/VALIDATION REQUEST, checkpoint, and major status updates) MUST include:
  - A **Summary** section at the bottom, immediately before the **Recommendation/Next Steps** section.
  - The **Recommendation** must be clear, actionable, and mandatory.
- **Before writing the Recommendation, the AI agent MUST:**
  1. Use the `sequential-thinking` MCP server to plan the response and next steps.
  2. Use the `context7` MCP to retrieve or cross-reference any additional documentation or context required.
  3. Use the `perplexity` MCP to finalize research and ensure the recommendation is up-to-date and comprehensive.
- The SMEAC/VALIDATION REQUEST template MUST be updated to include these requirements, with the Summary and Recommendation sections at the bottom.

## 7. Standardized Test Failure Post-Mortem Process

*   **(CRITICAL AND MANDATORY P0) Standardized Post-Mortem Process:**
    * EVERY test failure MUST undergo a comprehensive post-mortem process following this exact sequence:
      1. Use MCP server `memory` to recall any similar test failures, past solutions, and relevant context from previous incidents.
      2. Use MCP server `sequential-thinking` to structure analysis and plan investigation approach in a logical, stepwise manner.
      3. Use MCP server `perplexity-ask` combined with web search_files to research the issue and discover industry solutions, best practices, and similar test failure patterns.
      4. Use MCP server `context7` to retrieve the latest Apple/platform documentation relevant to test frameworks and test methodology.
      5. Document comprehensive findings in `@TEST_FAILURES.MD` and `@AI_MODEL_STM.MD` with complete details, including exact error messages, test environment state, and initial hypotheses.
      6. Use MCP server `memory` to store a new plan of attack for addressing the test failure for future reference and pattern identification.
      7. This sequence is MANDATORY before attempting any fixes and cannot be skipped or reordered for any reason.
    * All test failures are considered P0 until properly assessed through this process and explicitly downgraded based on impact analysis.
    * Every test failure must be traced to root cause using "Five Whys" analysis before attempting fixes.
    * Programmatic fixes must be attempted before any test modification is considered.

## 8. Enforcement

*   **(CRITICAL AND MANDATORY) Automated Enforcement:** Testing requirements, including TDD adherence (where verifiable by process), build-after-change, and sandbox protocols, should be enforced through CI/CD pipelines, pre-commit hooks, and automated review tools where feasible.
*   **(CRITICAL AND MANDATORY) Code Review:** Code reviews (manual or AI-assisted) **MUST** verify adherence to these testing and QA standards.

### MANDATORY Enforcement of Automated UX/UI Snapshotting & OCR Checks

All UI/UX changes (including in sandbox) MUST be accompanied by:
- Programmatic screenshot capture (saved in `docs/UX_Snapshots/` with required naming)
- Automated in-memory OCR extraction and validation (NO persistent .txt files)
- Comprehensive navigation documentation (navigation tree, paths, and logs)
- Validation of extracted text against expected UI elements
- If any step fails or is missing, task completion MUST be blocked and SMEAC/VALIDATION escalation is required

Refer to the canonical protocol in `.cursorrules` for full details.

## 6.8. MCP Server/Tool Utilization (CRITICAL AND MANDATORY)
- All testing strategy and quality assurance processes MUST utilize:
    - `puppeteer` for web analysis
    - `perplexity-ask` for research
    - `momory` for information storage/recall
    - `context7` for latest documentation
    - `sequential-thinking` for planning/analysis
- These are REQUIRED for all test planning, execution, and analysis. Violation triggers P0 STOP EVERYTHING.

## 6.9. (CRITICAL AND MANDATORY) Mock/Fake Data & Integration Prohibition and Enforcement

- Mock/fake data, services, or integrations are permitted ONLY for development, testing, or sandbox environments.
- Every instance MUST be explicitly logged as technical debt in @TASKS.MD and trigger an update to @BLUEPRINT.MD, documenting the current state and plan for real integration.
- It is STRICTLY FORBIDDEN to ship any milestone (Alpha, Beta, Production, App Store, etc.) with features that use mock/fake data, services, or integrations.
- All milestone definitions MUST explicitly prohibit shipping features with mock/fake dependencies.
- Any use of mock/fake data/services/integrations MUST create subtasks for real integration and user validation, tracked to completion before release.
- This rule is compulsory and enforced at every milestone checkpoint and release process. Reference .cursorrules for full enforcement protocol.

---
*A robust testing strategy and stringent quality assurance processes are vital for delivering reliable and high-quality software. Adherence to these protocols is mandatory for all development activities.*
