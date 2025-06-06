---
description: Project setup, onboarding, environment consistency, breaking down features into granular tasks, and ensuring all work is traceable and validated before merging to production.
globs: 
alwaysApply: false
---
---
description: 
globs: 
alwaysApply: true
---
# Recent Lessons Learned & Continuous Improvement

- **Automated Checks & Programmatic Execution:** Always use automated scripts and programmatic tools for environment, structure, and workflow verification before any manual intervention.
- **TDD & Sandbox-First Workflow:** All new features and bug fixes must be developed using TDD and validated in a sandbox before production.
- **Comprehensive Logging & Documentation:** Log all failures, fixes, protocol deviations, and significant actions in canonical logs for audit and continuous improvement. Update all relevant documentation and protocols after each incident or improvement.
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

# 02. Project Lifecycle & Methodology

## 1. Initial Project & Environment Setup

*   **(CRITICAL AND MANDATORY) Adherence to Setup Guides:**
    *   All initial project setup **MUST** strictly follow the procedures outlined in `@XCODE_BUILD_GUIDE.MD` (for macOS/iOS projects) or the equivalent primary build and environment setup guide for the target platform.
    *   This includes programmatic creation of the application skeleton, directory structure, and initial configuration files.
*   **(CRITICAL AND MANDATORY) Initial Document Verification & Generation (Initialise Mode):**
    *   At the start of a new project interaction or onboarding, **verify** the existence of all documents listed under "Mandatory Context Acquisition & Prioritization" (see `@01_Core_AI_Agent_Principles.md`).
    *   **IF** any MANDATORY documents are missing (especially `@XCODE_BUILD_GUIDE.MD`, `@BLUEPRINT.MD`), **propose** their creation or acquisition as a prerequisite step. Report inability to proceed without core guides if needed for the task.
    *   **EXECUTE** creation using the "File Operation Troubleshooting Hierarchy" (see `@09_Tooling_Automation_And_Integrations_Protocol.md`) if needed, after user/team confirmation.
    *   Populate newly created documents with standard templates and initial content as defined in project rules (e.g., basic headings for `@TASKS.MD`, `@BLUEPRINT.MD` initial sections).
*   **(CRITICAL AND MANDATORY) Environment Consistency:**
    *   Ensure the development environment (tool versions, SDKs, dependencies) aligns with project standards, as potentially defined in `@XCODE_BUILD_GUIDE.MD` or `@README.MD`.
    *   Propose and execute automated steps to achieve consistency if discrepancies are found.
    *   All necessary tools, linters (e.g., SwiftLint as per `@07_Coding_Standards_Security_And_UX_Guidelines.md`), and dependencies **MUST** be correctly installed and configured programmatically where possible.

## 2. Iterative & Incremental Development Workflow

*   **(CRITICAL AND MANDATORY) Task-Driven Code Change Enforcement:**
    - It is STRICTLY FORBIDDEN to directly edit, create, or delete any code file (e.g., .swift, .js, .ts, etc.) unless:
        1. A corresponding actionable task exists in both @TASKS.MD and tasks/tasks.json,
        2. The change is fully traceable to that task (task ID must be referenced in code comments, commit messages, and documentation),
        3. The change follows TDD and feature development protocols (see @07_Coding_Standards_Security_And_UX_Guidelines.md and @06_Testing_Strategy_And_Quality_Assurance.md).
    - Any violation is a CRITICAL PROTOCOL BREACH: halt, log, escalate, and self-correct per .cursorrules Section 4.0.
    - This rule applies to all environments and contributors (AI Agent, human, scripts).
*   **(CRITICAL AND MANDATORY) Task-Driven Increments:**
    *   All development work **MUST** be broken down into and driven by tasks defined in `@TASKS.MD`.
    *   No code file may be edited, created, or deleted unless a corresponding actionable task exists and is referenced in all related changes. See .cursorrules Section 4.0 for enforcement.
    *   Select the highest priority "Not Started" task (Level 4+, ideally Level 5-6) from `@TASKS.MD` for each work increment.
    *   If a selected task is too high-level, **FIRST** break it down into smaller, specific, testable sub-tasks within `@TASKS.MD` as per rules in `@03_Task_Management_And_Workflow_Automation.md`.
*   **(CRITICAL AND MANDATORY) Implementation & Validation Loop per Sub-Task:**
    1.  **Update Task Status:** Mark the selected sub-task "In Progress" in `@TASKS.MD`, adding initial approach notes.
    2.  **Context & Planning:** Review requirements, outline implementation steps in `@TASKS.MD` (ensuring required detail level), and verify prerequisites.
    3.  **Implement (TDD):** Write code for the *single* sub-task, adhering to `@07_Coding_Standards_Security_And_UX_Guidelines.md` and Test-Driven Development principles (see `@06_Testing_Strategy_And_Quality_Assurance.md`).
        - **MANDATORY:** No code file may be changed unless the above task-driven enforcement is satisfied. Reference .cursorrules Section 4.0.
    4.  **Self-Review & Pre-Commit Checks:** Perform self-review against requirements, coding standards, security guidelines, and UI/UX standards. Run linters and formatters.
    5.  **Build & Test Validation:** Perform a local build (SweetPad compatible) and run all relevant tests (unit, integration, UI). ALL tests **MUST** pass. See `@04_Build_Integrity_Xcode_And_SweetPad_Management.md` and `@06_Testing_Strategy_And_Quality_Assurance.md`.
    6.  **Documentation Update:** Update inline comments and any impacted project documentation (e.g., `@README.MD`, API docs).
    7.  **Task Completion:** Update the sub-task status to "Done" in `@TASKS.MD`, adding detailed completion notes (outcomes, decisions, links to commits).
    8.  **Checkpoint & Commit:** Request validation/checkpoint as per `@01_Core_AI_Agent_Principles.md`. Propose/execute a Git commit with a descriptive message.
    9.  **Repeat:** Select the next priority sub-task.
*   **(CRITICAL AND MANDATORY) Sandboxed Development:**
    *   For significant features, bug fixes, or refactors, all modifications **MUST** first be developed and validated in an isolated sandbox environment as per `@06_Testing_Strategy_And_Quality_Assurance.md` (referencing `environment-sandboxed-development.md` rules).
    *   Only after successful build and comprehensive testing in the sandbox should changes be propagated to production files.

## 3. Modular Development Principle

*   **(CRITICAL AND MANDATORY) Design for Modularity:**
    *   Strive to design and implement features and components in a modular fashion, promoting separation of concerns, reusability, and independent testability.
    *   Follow architectural patterns defined in `@ARCHITECTURE_GUIDE.MD` that support modularity.
*   **(CRITICAL AND MANDATORY) Module-Focused Implementation:**
    1.  **Identify Module:** Clearly define the module or component the current task pertains to.
    2.  **Review Module Context:** Understand the module's existing responsibilities, APIs, and interactions with other parts of the system.
    3.  **Implement Within Module:** Confine changes primarily to the identified module, minimizing direct dependencies on other concrete modules where possible (prefer interfaces/protocols).
    4.  **Ensure Testability:** Design module internals and interfaces to be easily testable in isolation.

## 4. Smart Sequencing of Tasks

*   **(CRITICAL AND MANDATORY) Dependency Analysis:**
    *   Before planning a sequence of tasks, thoroughly analyze dependencies listed in `@TASKS.MD`.
    *   Utilize `taskmaster-ai` tools (if available and applicable, see `@03_Task_Management_And_Workflow_Automation.md`) or manual review to identify critical paths and potential blockers.
*   **(CRITICAL AND MANDATORY) Efficient Order Proposal:**
    *   Based on dependency analysis, identify any tasks that are blocking significant downstream work or critical path features.
    *   If the current task prioritization does not seem optimal for overall project velocity, propose a more efficient order of execution to the user or Taskmaster, clearly stating the rationale (e.g., "Addressing Task X now will unblock Tasks Y and Z, accelerating Feature A delivery.").
    *   Prioritize tasks that resolve known blockers or enable parallel development streams where appropriate.

## 5. Refactoring Approach

*   **(CRITICAL AND MANDATORY) Functionality First, Then Refactor:**
    1.  Prioritize delivering working, tested functionality that meets the core requirements of the task.
    2.  Once functionality is confirmed and all tests pass, identify areas for refactoring (improving code clarity, performance, maintainability, or adherence to design patterns).
*   **(CRITICAL AND MANDATORY) Refactoring as Separate, Testable Tasks:**
    *   Significant refactoring efforts **SHOULD** be proposed and tracked as distinct tasks or sub-tasks in `@TASKS.MD`.
    *   Each refactoring task **MUST** have clear objectives and acceptance criteria (e.g., "Improve performance of DataProcessingModule by X%", "Adhere to Strategy Pattern in PaymentService").
*   **(CRITICAL AND MANDATORY) Verify After Refactoring:**
    *   After refactoring, **ALL** existing tests related to the modified code **MUST** still pass. If necessary, update existing tests or add new ones to cover the refactored code adequately.
    *   A full build and test cycle is mandatory post-refactoring.
*   **(CRITICAL AND MANDATORY) Document Refactoring Decisions:**
    *   Document the rationale and outcomes of significant refactoring efforts in `@DEVELOPMENT_LOG.MD` and within the comments of the refactoring task in `@TASKS.MD`.
    *   If refactoring addresses technical debt, update `@TECH_DEBT_LOG.MD`.

## 6. Canonical Process for Pushing Features into Production

*This section defines the mandatory, step-by-step process for pushing features from development to production, ensuring consistent quality, proper validation, and comprehensive documentation.*

### 6.1. Feature Readiness Assessment (Pre-Production)

*   **(CRITICAL AND MANDATORY) Task Completeness Verification:**
    1.  **Task Status Check:** Verify ALL subtasks for the feature are marked as "Done" in `@TASKS.MD` and `tasks/tasks.json`.
    2.  **Acceptance Criteria Validation:** Confirm all acceptance criteria defined in the original task are demonstrably met.
    3.  **Dependencies Audit:** Ensure all task dependencies are properly resolved and completed.
    4.  **Feature Documentation Review:** Verify that ALL feature documentation (inline code comments, public API docs, user-facing docs) is complete and accurate.

*   **(CRITICAL AND MANDATORY) Quality Assurance Gates:**
    1.  **Test Coverage Verification:**
        * Unit tests covering all core logic and edge cases (minimum 90% coverage for feature-specific code).
        * Integration tests for all cross-module interactions.
        * UI/UX tests for all user-facing components, including accessibility validation.
        * VERIFY ALL TESTS PASS in BOTH sandbox and production environments.
    2.  **Code Quality Validation:**
        * Complete SwiftLint (or equivalent) pass with zero errors and all warnings addressed or documented.
        * Self-review of code against `@07_Coding_Standards_Security_And_UX_Guidelines.md`.
        * Security vulnerabilities assessment for sensitive features (e.g., authentication, data storage).
    3.  **Comprehensive Build Verification:**
        * Perform clean build using `XcodeBuildMCP` or equivalent.
        * Verify successful build on all target platforms (e.g., iOS, macOS) and required deployment targets (minimum OS versions).
        * Confirm SweetPad compatibility as per `@04_Build_Integrity_Xcode_And_SweetPad_Management.md`.
    4.  **UI/UX Compliance Verification:**
        * Execute the complete UI/UX OCR Validation Protocol (see Section "UI/UX OCR Validation Protocol").
        * Verify all UI elements conform to `@XCODE_STYLE_GUIDE.MD` or equivalent.
        * Accessibility compliance check (dynamic type, VoiceOver support, proper contrast ratios).

### 6.2. Feature Integration Process

*   **(CRITICAL AND MANDATORY) Pre-Integration Preparation:**
    1.  **Create Integration Ticket:** Create a dedicated integration task in `@TASKS.MD` with ID format `INT-<FeatureTaskID>` that references the feature task.
    2.  **Update CHANGELOG:** Add feature details to `@CHANGELOG.MD` under the appropriate upcoming version section.
    3.  **Feature Branch Preparation:**
        * Ensure feature branch is up-to-date with latest `develop` or main development branch.
        * Resolve any merge conflicts.
        * Rerun ALL tests after syncing to verify no regressions.

*   **(CRITICAL AND MANDATORY) Integration Execution:**
    1.  **Create Pull Request/Merge Request:**
        * Using `github` MCP or equivalent, create a PR from feature branch to the main development branch.
        * Title format: `feat: <Feature Name> (Task #<TaskID>)`.
        * Include comprehensive description detailing:
            - Feature purpose and benefits
            - Implementation highlights
            - Testing approach and results
            - Screenshots/recordings for UI features
            - Any notable technical decisions or trade-offs
            - Migration steps if existing functionality is changed
    2.  **Automated CI Validation:**
        * Verify all CI checks pass (builds, tests, linting).
        * Address any failures immediately as P0 priority.
    3.  **Peer Review Process:**
        * Request review from at least one team member (or perform self-review using structured checklist if solo development).
        * Address ALL review feedback with appropriate changes or documented justifications.
        * Request final approval after addressing feedback.
    4.  **Merge to Development Branch:**
        * Upon approval, merge the feature branch to the main development branch.
        * Use `github` MCP or equivalent to perform merge.
        * Preferred merge strategy: squash merge with concise, descriptive commit message that references the task ID.

### 6.3. Pre-Release Validation

*   **(CRITICAL AND MANDATORY) Integration Testing:**
    1.  **Post-Merge Build Verification:**
        * Perform clean build of development branch after merge.
        * Run full test suite to ensure no regressions.
    2.  **Cross-Feature Integration Testing:**
        * Test interactions with other recently merged features.
        * Verify no conflicts in shared resources, styling, or functionality.
    3.  **Performance Testing:**
        * Validate feature meets performance standards (response times, animation smoothness, resource usage).
        * Profile the application to detect any performance regressions.

*   **(CRITICAL AND MANDATORY) Pre-Release Documentation:**
    1.  **Update Release Notes:**
        * Ensure feature is properly documented in `@RELEASE_NOTES.MD` with:
            - User-facing description
            - Any usage instructions
            - Known limitations (if applicable)
    2.  **Documentation Synchronization:**
        * Update ALL relevant documentation including:
            - User documentation
            - Developer documentation
            - API references
            - Architectural diagrams (if applicable)
    3.  **Version Management:**
        * Update version numbers in all relevant files:
            - `Info.plist` or equivalent
            - Build configuration files
            - Documentation references
        * Follow Semantic Versioning principles

### 6.4. Production Deployment Process

*   **(CRITICAL AND MANDATORY) Release Branch Creation:**
    1.  **Create Release Branch:**
        * Create a dedicated release branch from the development branch:
            - Format: `release/v{MAJOR}.{MINOR}.{PATCH}`
        * Freeze feature additions to this branch; only accept bug fixes.
    2.  **Final Build Verification:**
        * Perform production build on release branch.
        * Execute full test suite on production build.
        * Verify all metadata (app icons, version numbers, bundle IDs) is correct.

*   **(CRITICAL AND MANDATORY) Release Approval & Tagging:**
    1.  **Release Candidate Approval:**
        * Generate release candidate build.
        * Document approval from project stakeholders for release.
    2.  **Version Tagging:**
        * Tag the approved commit on the release branch:
            - Tag format: `v{MAJOR}.{MINOR}.{PATCH}`
            - Include detailed release notes in tag description.

*   **(CRITICAL AND MANDATORY) App Store/Production Deployment:**
    1.  **App Store Submission Process** (if applicable):
        * Generate production-signed build.
        * Submit to App Store using programmatic tools (preferred) or App Store Connect.
        * Complete App Store metadata:
            - Screenshots (generated via automation)
            - App description and what's new
            - Keywords and categorization
    2.  **Enterprise/Internal Deployment** (if applicable):
        * Generate appropriately signed build.
        * Upload to internal distribution platform.
        * Notify stakeholders of availability.
    3.  **Post-Deployment Verification:**
        * Download published app and verify core functionality.
        * Complete "first run" experience to ensure onboarding works correctly.

### 6.5. Post-Release Activities

*   **(CRITICAL AND MANDATORY) Release Documentation:**
    1.  **Publish Release Notes:**
        * Update `@CHANGELOG.MD` to mark version as released with date.
        * Publish release notes to appropriate channels.
    2.  **Update Project Status:**
        * Update `@BLUEPRINT.MD` to reflect completed milestone/features.
        * Mark relevant tasks as completed/released in `@TASKS.MD`.

*   **(CRITICAL AND MANDATORY) Merge Back to Development:**
    1.  **Sync Release Branch:**
        * Merge the release branch (including any hot fixes) back to the main development branch.
        * Resolve any conflicts carefully.
        * Verify build and tests pass after merge.

*   **(CRITICAL AND MANDATORY) Release Retrospective:**
    1.  **Document Lessons Learned:**
        * Record any issues encountered during the release process.
        * Document successful strategies and tactics.
        * Identify areas for improvement in future releases.
    2.  **Update Processes:**
        * Refine release procedures based on retrospective findings.
        * Update documentation and automate manual steps where possible.
        * Share lessons learned with the team for collective improvement.

*   **(CRITICAL AND MANDATORY) GitHub Push for Verified Release:**
    1.  **COMPULSORY P0 Requirement:**
        * After production deployment is verified green, IMMEDIATELY push a commit to GitHub with tag and release notes.
        * This serves as a critical backup of the production-ready state and enables future recovery if needed.
        * Failure to push to GitHub post-release is a P0 STOP EVERYTHING violation.
    2.  **Documentation Requirements:**
        * Document the GitHub commit, tag, and branch information in `@RELEASE_NOTES.MD` and `@DEVELOPMENT_LOG.MD`.
        * Reference this information in the release retrospective.

## 7. File Recovery and Build Restoration Process

*This section provides a concise reference to the canonical file recovery and build restoration protocol defined in `.cursorrules` (Section 1.15) and detailed fully in `@05_Build_Failure_Resolution_And_Prevention_Framework.md` (Section 11).*

*   **(CRITICAL AND MANDATORY) Protocol Overview:**
    *   The comprehensive File Recovery and Build Restoration Protocol is a CRITICAL AND MANDATORY process that must be followed whenever:
        *   File corruption (especially `.xcodeproj`, `.xcworkspace`, configuration files) is detected.
        *   Build failures occur that cannot be immediately resolved through regular troubleshooting.
        *   Project files need to be restored from a previous known-good state.
        *   Recovery from catastrophic development environment issues is required.
    *   This protocol is defined in full in:
        *   `.cursorrules` Section 1.15 (concise process overview)
        *   `@05_Build_Failure_Resolution_And_Prevention_Framework.md` Section 11 (comprehensive step-by-step process)
        *   `@XCODE_BUILD_GUIDE.md` (project-specific implementation details)

*   **(CRITICAL AND MANDATORY) Key Process Components:**
    1.  **Automated Backup Protocol:**
        * Regular automated backups of critical project files before significant changes.
        * Rotation of backups with a maximum of 3 local backups.
        * GitHub stable build branches for remote backup of known-good states.
    2.  **File Recovery Procedures:**
        * Detailed procedures for corrupted Xcode project files.
        * Step-by-step recovery of missing file references.
        * Workspace corruption recovery techniques.
    3.  **Build Restoration Workflow:**
        * Local backup restoration process.
        * GitHub-based restoration process.
        * Dependency restoration for Swift Package Manager and other dependency managers.
    4.  **Required Automation:**
        * Mandatory automation scripts for backup, restoration, and verification.
        * Integration with workflow automation and pre-commit hooks.
        * Documentation requirements for all recovery operations.

*   **(CRITICAL AND MANDATORY) Integration with Project Lifecycle:**
    *   The File Recovery and Build Restoration Process integrates with the project lifecycle in these key areas:
        *   **Initialization Mode:** Establishes initial backup and verification scripts.
        *   **Development Workflow:** Creates automated backups at defined checkpoints.
        *   **Pre-Release Procedures:** Ensures stable builds are properly backed up before release.
        *   **Post-Release Activities:** Mandates GitHub backup of verified release builds.
        *   **Disaster Recovery:** Provides the foundation for project recovery when needed.
    *   When implementing new features or making significant changes, every task MUST include consideration of backup procedures and verification steps.

*   **(CRITICAL AND MANDATORY) P0 STOP EVERYTHING Conditions:**
    *   Failure to maintain regular backups of critical project files.
    *   Missing or non-functional recovery automation scripts.
    *   Inability to restore from backup during a build failure situation.
    *   Failure to document recovery operations in appropriate logs.
    *   Missing GitHub backups of verified stable builds.

*For comprehensive implementation details, refer to the full protocol in `@05_Build_Failure_Resolution_And_Prevention_Framework.md` Section 11 and project-specific procedures in `@XCODE_BUILD_GUIDE.md`.*

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

### Redundancy & Escalation
- If OCR validation fails (expected UI text not detected, ambiguous result, or screenshot is not of the app window), the process is blocked and escalated as a P0 Critical - User Acceptance Required.
- A SMEAC/VALIDATION REQUEST is generated, including the screenshot, OCR output, navigation path, and a summary of the failure.
- No further progress is allowed until the user explicitly accepts or rejects the UI as visually correct.
- If accepted, rationale is logged and documentation updated. If rejected, a P0 task is created to remediate and the process is repeated.
- All actions, escalations, and user decisions are logged in docs/DEVELOPMENT_LOG.MD, docs/UX_Snapshots/navigation_dev_log.md, and SMEAC/VALIDATION REQUESTs.
- If automation fails, the protocol requires escalation and user intervention, ensuring no silent failures.

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

## CRITICAL USER INPUT/VALIDATION RESPONSE PROTOCOL (Update)

- In any situation where user input or validation is required, the AI agent MUST provide a clear, actionable, and mandatory recommendation on what the user should do next. This is a CRITICAL AND MANDATORY requirement.
- Reference: See .cursorrules "CRITICAL USER INPUT/VALIDATION RESPONSE PROTOCOL" section.

## 2.7. MCP Server/Tool Utilization (CRITICAL AND MANDATORY)
- All project lifecycle and methodology activities MUST utilize:
    - `puppeteer` for web analysis
    - `perplexity-ask` for research
    - `momory` for information storage/recall
    - `context7` for latest documentation
    - `sequential-thinking` for planning/analysis
- These are REQUIRED for all phases. Violation triggers P0 STOP EVERYTHING.

## 2.8. (CRITICAL AND MANDATORY) Mock/Fake Data & Integration Prohibition and Enforcement

- Mock/fake data, services, or integrations are permitted ONLY for development, testing, or sandbox environments.
- Every instance MUST be explicitly logged as technical debt in @TASKS.MD and trigger an update to @BLUEPRINT.MD, documenting the current state and plan for real integration.
- It is STRICTLY FORBIDDEN to ship any milestone (Alpha, Beta, Production, App Store, etc.) with features that use mock/fake data, services, or integrations.
- All milestone definitions MUST explicitly prohibit shipping features with mock/fake dependencies.
- Any use of mock/fake data/services/integrations MUST create subtasks for real integration and user validation, tracked to completion before release.
- This rule is compulsory and enforced at every milestone checkpoint and release process. Reference .cursorrules for full enforcement protocol.

---
*This document outlines the standard lifecycle and methodologies for project development. Adherence is crucial for consistent, high-quality output and effective collaboration.*

