---
description: Documentation updates, directory cleanup, configuration changes, and ensuring all files and docs are in their correct locations and up to date.
globs: 
alwaysApply: false
---
---
description: MANDATORY requirement if the agent is looking to create, edit or refactor any code.
globs: 
alwaysApply: false
---
# Recent Lessons Learned & Continuous Improvement

- **Automated Checks & Programmatic Execution:** Always use automated scripts and programmatic tools for directory hygiene, documentation completeness, and configuration management before any manual intervention.
- **TDD & Sandbox-First Workflow:** All new features and bug fixes must be developed using TDD and validated in a sandbox before production.
- **Comprehensive Logging & Documentation:** Log all documentation changes, protocol deviations, and directory hygiene actions in canonical logs for audit and continuous improvement. Update all relevant documentation and protocols after each incident or improvement.
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

Reference: See .cursorrules for enforcement.

# 08. Documentation, Directory & Configuration Management

## 1. Key Document Interaction & Management

*   **(CRITICAL AND MANDATORY) Document Interaction Summary Adherence:** All interactions with key project documents **MUST** follow the `primary_interaction`, `update_frequency`, `reference_frequency`, `update_actions`, and `reference_purpose` as defined in the structured JSON guide within the "Consolidated Project Development Rules (v1.0)" (Section: "Document Interaction Summary (Structured)") or its successor section in `@10_Project_Rules_Governance_And_Evolution.md`.
*   **(CRITICAL AND MANDATORY) Document Locations & Naming:**
    *   All key project document filenames **MUST** use uppercase for the base name (e.g., `TASKS.MD`, `BLUEPRINT.MD`).
    *   Standard documents **MUST** reside in their designated locations (primarily `docs/`) as per the mandated repository structure (see Section 2).
*   **(CRITICAL AND MANDATORY) Meticulous Documentation (Automated & Verbose):**
    *   Log ALL steps, analysis, decisions, tool calls, and results verbosely in `@DEVELOPMENT_LOG.MD` (typically via `filesystem` MCP `Edit` append).
    *   Document failures/resolutions comprehensively in `@BUILD_FAILURES.MD` (typically via `filesystem` MCP `Edit`). See `@05_Build_Failure_Resolution_And_Prevention_Framework.md`.
    *   Update `@TASKS.MD` (or the project's task management system) constantly with detailed task information, status changes, and implementation notes. See `@03_Task_Management_And_Workflow_Automation.md`.
    *   Update `@AI_MODEL_STM.MD` and `@TASK_<ID>_EXECUTION_LOG.MD` as per `@01_Core_AI_Agent_Principles.md`.
*   **(CRITICAL AND MANDATORY) No Duplicates & Cleanup:**
    *   Regularly scan for and propose the cleanup or integration of duplicate or redundant documentation.
    *   Core project documents (e.g., `@BLUEPRINT.MD`, `@TASKS.MD`) **MUST NOT** be duplicated. Point to the canonical version.

## 2. Mandated Repository Structure & Directory Cleanliness

*This section consolidates rules from `consolidated_project_rules` (v3.8) Section 7 and `build_stability_and_task_protocol.md`.*

*   **(CRITICAL AND MANDATORY) Strict Adherence to Mandated Structure:** The project **MUST** strictly adhere to the repository structure defined in Section 7.1 of `consolidated_project_rules` (v3.8) or its successor definition in this document if updated. The AI Agent **MUST** programmatically enforce these standards using the `filesystem` MCP server AT ALL TIMES.
    *   **Key Structure Elements (Summary - Refer to full definition for details):**
        *   `{repo_ProjectNamePlaceholder}/`: Root folder - **NO STRAY AGENT FILES HERE.**
        *   `.gitignore`, `.cursorrules`, `.env` (ignored), `.env.example`, `LICENSE`, `CLAUDE.md` (if applicable).
        *   `claude/`: For Anthropic Claude code recommendations.
        *   `docs/`: **ALL** project documentation (Markdown files like `BLUEPRINT.MD`, `TASKS.MD`, `ARCHITECTURE.MD`, `BUILD_FAILURES.MD`, `XCODE_BUILD_GUIDE.MD`, `XCODE_STYLE_GUIDE.md`, etc.).
        *   `docs/TestData/`: All relevant test data.
        *   `scripts/`: General utility, build, fix scripts.
        *   `shared/`: Code shared across platforms/modules.
        *   `_{PlatformDir}/` (e.g., `_macOS/`, `_iOS/`): Platform-specific root.
            *   Contains `{ProjectFileNamePlaceholder}.xcodeproj` (SweetPad buildable).
            *   `{PlatformSourceRoot}/`: Platform source code (App, Models, Views, ViewModels, Services, Resources, Assets.xcassets).
            *   `Tests/`: Platform tests (Unit, UI).
            *   `build/` (ignored), `logs/` (ignored), `scripts/` (platform-specific).
        *   `temp/`: Temporary files (ignored). Includes `temp/backup/` and `temp/review_placement/`.
        *   `logs/`: General project logs (ignored).
        *   `SwiftLint.yml` (or path defined in `@CODE_QUALITY.MD`).
*   **(CRITICAL AND MANDATORY) Directory & File Cleanliness Enforcement (Housekeeping):**
    *   **Production Xcode Project/Workspace:** Only ONE canonical set in the platform directory (e.g., `_macOS/`). All others **MUST** be deleted or moved to `temp/backup/`.
    *   **Sandbox Projects:** All sandboxed builds/projects **MUST** be under `_{PlatformDir}/sandbox/`. Never mix with production. Batch delete any old/random sandbox projects not in this folder.
    *   **Backups:** Store ONLY in `temp/backup/`. Maximum 3 backups; rotate oldest out. Use batch deletion. Never keep backups in root or platform directories.
    *   **Temp/Review:** Use `temp/review_placement/` for ambiguous files pending review. Do not delete unless confirmed obsolete by user.
    *   **No Stray Files/Folders in Root:** The project root **MUST** remain clean. No logs, build artifacts, or random files/folders. Enforce batch deletion of any found.
    *   **Logs/Build Artifacts:** All logs and build artifacts **MUST** be in their respective `logs/` and `build/` subdirectories and be included in `.gitignore`.
    *   **Scripts:** All scripts in `scripts/` or platform-specific `_{PlatformDir}/scripts/`. Cataloged in `@SCRIPTS.MD`.
    *   **Strict Enforcement:** Directory hygiene is CRITICAL & MANDATORY for build/test/commit. Programmatic checks, batch deletion, and backup rotation are required for compliance. This is a part of AUTO ITERATE Mode steps (see `@03_Task_Management_And_Workflow_Automation.md`).
    *   **Conflicted Files:** Identify and immediately delete any files containing "Conflicted Copy" (or similar conflict markers from synchronization tools). Utilize bulk operations for removal.

## 3. Version Control (Git) Protocol

*   **(CRITICAL AND MANDATORY) Branching Strategy:**
    *   NEVER commit directly to `main`/`master` except for fully completed, tested, and milestone-aligned L3 features (or equivalent major features).
    *   Level 4-6 tasks (sub-tasks) **MUST** be developed on their own dedicated feature/fix branches, branching from their parent task's branch or the main development branch (e.g., `develop`).
    *   Feature branches for L3 tasks (or equivalent) are merged to the main development branch (e.g., `develop`) only after all sub-tasks are complete, all tests pass, and the build is stable and verified.
    *   `develop` is periodically merged to `main`/`master` for releases.
*   **(CRITICAL AND MANDATORY) Commit Messages:**
    *   Write clear, concise, and informative commit messages.
    *   Follow conventional commit formats if specified by the project (e.g., `feat: Implement user login screen (closes #123)`).
    *   Reference relevant task IDs from `@TASKS.MD`.
*   **(CRITICAL AND MANDATORY) Commit Frequency & Checkpoints:**
    *   After every successful build and significant, stable state (e.g., completion of a sub-task), commit changes to the version control system.
    *   Regularly push local branches to the remote repository to back up work and facilitate collaboration.
*   **(CRITICAL AND MANDATORY) GitHub Backup & Sync (via MCP or Bash):**
    *   After every successful production build (all tests pass), or after significant documentation updates, the AI Agent **MUST** use GitHub MCP (if available) or `Bash` Git commands to commit and push changes.
    *   The commit message **MUST** reflect the successfully tested changes, features added, or documentation updates, referencing build/test status and current version number.
    *   Update project documentation (e.g., `@DEVELOPMENT_LOG.MD`, `@BUILD_FAILURES.MD`) with every major change, restoration, or fix *before* committing.
*   **(CRITICAL AND MANDATORY) Version Number Management:**
    *   Consistently update the application's version number in designated project configuration files (e.g., `Info.plist`, build scripts, `@BLUEPRINT.MD`) following significant changes or releases.
    *   Ensure this updated version number is accurately reflected and prominently displayed where necessary (e.g., within `MainContentView.swift` or an equivalent About/Info section of the app).

## 4. Configuration Management

*   **(CRITICAL AND MANDATORY) No Hardcoding of Configurable Values:**
    *   Configuration values (e.g., API endpoints, feature flags, timeouts, external service URLs) **MUST NOT** be hardcoded directly in source code.
*   **(CRITICAL AND MANDATORY) External Configuration Files:**
    *   Store configurable values in external configuration files (e.g., `.env` files, `.xcconfig` for Xcode, JSON, YAML) as specified by `@ARCHITECTURE_GUIDE.MD`.
    *   Provide sensible, non-sensitive default values if appropriate, often in an example configuration file (e.g., `.env.example`).
*   **(CRITICAL AND MANDATORY) Secure Secret Management:**
    *   Sensitive configuration values (API keys, passwords, private certificates) **MUST NOT** be committed to version control.
    *   Such files (e.g., `.env` containing actual secrets) **MUST** be listed in `.gitignore`.
    *   Employ environment variables, vault solutions (like HashiCorp Vault), or platform-specific secure storage mechanisms (like macOS/iOS Keychain) as defined in `@SECURITY_GUIDELINES.MD` and specified by the `{SecurityMethod}` in `@BLUEPRINT.MD`.
*   **(CRITICAL AND MANDATORY) Runtime Loading:** Implement code to load configuration values at runtime from these external sources.
*   **(CRITICAL AND MANDATORY) Documentation in `@README.MD`:** Document all required environment variables and configuration settings necessary to run the project in `@README.MD`.

## 5. Dependency Management

*   **(CRITICAL AND MANDATORY) Manifest Files:**
    *   All external project dependencies (libraries, frameworks) **MUST** be managed through a standard manifest file appropriate for the platform/language (e.g., `Package.swift` for Swift Package Manager, `Podfile` for CocoaPods, `build.gradle`/`pom.xml` for Java/Kotlin, `package.json` for Node.js, `requirements.txt`/`Pipfile`/`pyproject.toml` for Python).
    *   This manifest file **MUST** be committed to version control.
*   **(CRITICAL AND MANDATORY) Specify Versions Clearly:**
    *   Specify dependency versions precisely (e.g., `1.2.3`) or use narrow, well-defined version ranges (e.g., `~> 1.2.0` meaning >= 1.2.0 and < 1.3.0) to ensure reproducible builds and avoid unexpected breaking changes from transitive dependencies. Avoid open-ended versions (e.g., `*` or `latest`) for production dependencies.
*   **(CRITICAL AND MANDATORY) Regular Review & Updates:**
    *   Periodically review project dependencies for updates, especially security patches.
    *   Before updating a dependency, assess its impact on the project (breaking changes, new features, deprecations) and test thoroughly in a sandboxed environment.
    *   Utilize tools for scanning dependencies for known vulnerabilities (e.g., `npm audit`, `pip-audit`, Snyk, GitHub Dependabot). Address identified vulnerabilities promptly based on severity.
    *   Log significant dependency updates or vulnerability mitigations in `@DEVELOPMENT_LOG.MD`.

## 6. Initial Document Generation Templates (Minimal)

*   **(CRITICAL AND MANDATORY) Programmatic Generation:** During "Initialise Mode" (see `@02_Project_Lifecycle_And_Methodology.md`), if core documents are missing, they **MUST** be proposed for creation using the following minimal templates. Proposed filenames **MUST** use uppercase base names.

*   **`@docs/TASKS.MD` Template:**
    ```markdown
    # Tasks

    | ID | Task/Subtask Name | Status      | Priority | Dependencies | Comments/Notes |
    |----|-------------------|-------------|----------|--------------|----------------|
    | 1  | Initial Setup     | pending     | P0       |              | Basic project scaffolding |
    ```

*   **`@docs/BUGS.MD` Template:**
    ```markdown
    # Bugs Log

    | ID | Bug Description | Status      | Priority | Assigned To | Reported Date | Resolved Date | Resolution Notes |
    |----|-----------------|-------------|----------|-------------|---------------|---------------|------------------|
    | B001| Example Bug Entry| Open        | High     |             | YYYY-MM-DD    |               |                  |
    ```

*   **`@docs/DEVELOPMENT_LOG.MD` Template:**
    ```markdown
    # Development Log

    ## YYYY-MM-DD

    *   **Decision/Event:** Project Initialized.
        *   **Rationale:** Starting new project development.
        *   **Outcome:** Core directory structure and initial documents created.
        *   **Participants/Author:** AI Agent
    ```

*   **`@docs/CODING_STANDARDS.MD` Minimal Template:**
    ```markdown
    # Coding Standards

    ## 1. General Principles
    - Code should be clear, readable, and maintainable.
    - Follow the DRY (Don't Repeat Yourself) principle.
    - Follow the KISS (Keep It Simple, Stupid) principle.

    ## 2. Naming Conventions
    - (Specify for variables, functions, classes, etc. e.g., camelCase for functions, PascalCase for classes for Swift/Kotlin/Java; snake_case for Python/Ruby variables & functions, PascalCase for classes)

    ## 3. Formatting
    - (Specify indentation [e.g., 2 spaces, 4 spaces, tabs], line length [e.g., 120 chars], braces style, etc. Or refer to an auto-formatter configuration like .swiftformat, .prettierrc, black)

    ## 4. Comments
    - Comment complex logic, non-obvious decisions, and public APIs.
    - Use language-standard documentation comment syntax (e.g., `///` for SwiftDoc, `/** ... */` for JavaDoc/JSDoc).

    ## 5. Language-Specific Guidelines
    - (Add sections for specific languages used in the project, e.g., Swift, Python, JavaScript)

    ## 6. Error Handling
    - (Specify preferred error handling mechanisms, e.g., exceptions, error codes, Result types)
    ```

*   **`@docs/SECURITY_GUIDELINES.MD` Minimal Template:**
    ```markdown
    # Security Guidelines

    ## 1. Data Handling
    - Classify data (e.g., Public, Internal, Confidential, Secret).
    - Specify encryption requirements for data at rest and in transit for each classification.
    - Rules for handling Personally Identifiable Information (PII) in compliance with relevant regulations (e.g., GDPR, CCPA).

    ## 2. Authentication & Authorization
    - Minimum password complexity rules (length, character types).
    - Multi-Factor Authentication (MFA) requirements for user and admin accounts.
    - Principle of Least Privilege for access control: Grant only necessary permissions.

    ## 3. Input Validation & Output Encoding
    - All external input (user forms, API requests, file uploads) MUST be validated and sanitized on the server-side.
    - Encode output appropriately to prevent XSS (Cross-Site Scripting) and other injection attacks when rendering data in UIs or APIs.

    ## 4. Dependency Management
    - Regularly scan dependencies for known vulnerabilities using automated tools (e.g., Snyk, Dependabot, `npm audit`).
    - Policy for using third-party libraries: Define approved licenses, process for evaluating new dependencies, and criteria for vulnerability status.

    ## 5. Secret Management
    - API keys, database credentials, passwords, and other secrets MUST NOT be hardcoded or committed to version control.
    - Specify approved methods for storing and accessing secrets (e.g., environment variables via `.env` files [ignored by Git], HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, GCP Secret Manager, Kubernetes Secrets, platform Keychain services).

    ## 6. Logging & Monitoring
    - Do not log sensitive information (passwords, API keys, PII) in plain text in application logs.
    - Ensure adequate logging for security event monitoring, audit trails, and incident response.

    ## 7. Secure Development Lifecycle (SDL)
    - (Reference any SDL processes, e.g., threat modeling during design, security code reviews, penetration testing schedule).
    ```

### UX/UI Change Checkpoint Rule (Updated)
- At the first implementation of any new UI code (or any significant UX/UI change), a checkpoint **MUST** be made to capture and save relevant screenshots/images in `docs/UX_Snapshots/`.
- **Naming convention:** `YYYYMMDD_HHMMSS_<TaskID>_<ShortTaskName>.png`
- This folder is mandatory and must be kept organized (e.g., by date, feature, or task ID).
- After saving, a user notification **MUST** be issued (in SMEAC/VALIDATION REQUEST, commit message, or UI alert) specifying the filenames and location.
- Screenshots/images should be referenced in SMEAC/VALIDATION REQUESTS and documentation for traceability and review.

## Cross-Reference: Automated UX/UI Screenshot Navigation & Validation

All documentation and automation for UX/UI screenshots must follow the generic, project-agnostic process described in `docs/SCRIPTS.MD` and `.cursorrules`. This includes:
- Programmatic navigation to the relevant screen/state before capture
- Post-mortem analysis and logging
- Use of the checkpoint and post-mortem templates

### MANDATORY Enforcement of UX/UI Snapshotting & OCR Directory Protocol

- All UI/UX changes must result in new screenshots and OCR logs in `docs/UX_Snapshots/`.
- Directory hygiene checks must verify the presence and correct naming of these files for every UI/UX change.
- If missing, block task completion and escalate via SMEAC/VALIDATION.
- Refer to `.cursorrules` and `behaviours_visual-ai-snapshot.md` for the canonical protocol.

## 3. Key Documentation Reference Table (MANDATORY)

This table defines the canonical documentation files for the project, their purpose, when to update, and when to use them in the workflow. All automation, compliance, and development processes must reference this table for correct document usage.

| Document | Purpose | When to Update | When to Use (Processes/Phases) |
|----------|---------|---------------|-------------------------------|
| **AI_MODEL_STM.md** | Logs AI agent short-term memory (STM) snapshots at major decision points, context loads, and reasoning. | After every major decision, context load, or reasoning step by AI/automation. | During AI/automation, task selection, build/test, error handling, and context acquisition. |
| **ARCHITECTURE_GUIDE.MD** | Outlines architectural decisions, patterns, and guidelines for the project. | When architecture changes, new patterns are adopted, or major refactors occur. | At the start of new features, refactoring, onboarding, and code reviews. |
| **BLUEPRINT.md** | Canonical project specification, configuration, and root definition. | When requirements, configuration, or project root change. | At project initialization, onboarding, automation, and whenever referencing project root or configuration. |
| **BUGS.md** | Tracks all identified bugs, their status, and resolution. | When new bugs are found, resolved, or prevention notes are added. | During bug triage, resolution, and post-mortem analysis. |
| **BUILD_FAILURES.MD** | Logs all build failures, analysis, and resolution methods. | After any build failure or resolution. | During troubleshooting, build/test, and post-mortem. |
| **BUILD_FIXES.md** | Documents specific build issues that have been resolved and preventative measures. | After resolving a build issue or implementing a fix. | During build troubleshooting, after fixes, and for future prevention. |
| **DEVELOPMENT_GUIDE.md** | Comprehensive guide to the development workflow, processes, and best practices. | When workflow, process, or best practices change. | At onboarding, before starting tasks, and during process reviews. |
| **DEVELOPMENT_LOG.MD** | Chronological log of all development activities, decisions, and issues. | After every significant action, decision, or issue. | Throughout development, for traceability and audits. |
| **DEVELOPMENT_TESTING_GUIDE.md** | Outlines the comprehensive testing approach, including UI/UX validation and automated testing. | When testing strategy, tools, or workflow changes. | Before/after implementing tests, during QA, and for onboarding. |
| **QUICK_REF_GUIDE_DEVELOPMENT.md** | Condensed reference of the complete development workflow and checklists. | When workflow or checklists change. | As a quick reference before/during any development phase. |
| **README.md** | Primary entry point to the project, overview, structure, and essential resources. | When project overview, structure, or setup changes. | At onboarding, setup, and for external communication. |
| **SCRIPTS.md** | Overview and usage guide for all scripts and automation tools. | When scripts are added, changed, or removed. | Before running scripts, automation, or troubleshooting. |
| **TASKS.md** | Central hub for tracking all tasks, subtasks, and their status. | When tasks are created, updated, or completed. | During planning, execution, and review of all work. |
| **UI_UX_TESTING_GUIDE.md** | Comprehensive approach to UI/UX testing, screenshot capture, OCR validation, and automation. | When UI/UX testing process or tools change. | Before/after UI/UX changes, during validation, and for onboarding. |
| **VIEW_STATE_UI_BEST_PRACTICES.md** | Best practices for view state management, naming, navigation, and documentation. | When best practices or UI patterns change. | During UI implementation, review, and onboarding. |
| **XCODE_BUILD_CONFIGURATION.MD** | Details Xcode project configuration, structure, and build requirements. | When build settings, structure, or configuration change. | During build setup, troubleshooting, and CI/CD configuration. |
| **XCODE_BUILD_GUIDE.md** | Definitive reference for building, configuring, and maintaining Xcode projects. | When build process, standards, or troubleshooting steps change. | During build, test, troubleshooting, and onboarding. |
| **XCODE_STYLE_GUIDE.md** | Defines the visual design system, UI components, and interaction patterns. | When design system, UI components, or patterns change. | During UI/UX implementation, review, and onboarding. |

**MANDATE:** All contributors (AI or human) must reference this table for correct document usage. All automation and compliance checks must validate against this table. Any changes to document names, locations, or purposes must be reflected here and in all related rules.

## 4. Standard Directory Structure

All projects must follow this canonical directory structure:

```plaintext
{repo_ProjectNamePlaceholder}/ # Root - NO STRAY FILES HERE
+-- .gitignore, .cursorrules, .build, .roo, .git, .vscode, .env, .env.example
+-- CLAUDE.md, LICENSE
+-- claude/               # Claude Code Recommendations
+-- docs/                 # ALL documentation goes here
|   +-- README.MD, ARCHITECTURE.MD, ARCHITECTURE_GUIDE.MD
|   +-- BLUEPRINT.MD      # SPECIFICATION & CONFIGURATION
|   +-- TASKS.MD          # Workflow hub (L4+ sub-tasks)
|   +-- BUGS.MD, DEVELOPMENT_LOG.MD, BUILD_FAILURES.MD
|   +-- BUILDING.MD, CODE_QUALITY.MD, COMMON_ERRORS.MD
|   +-- XCODE_BUILD_GUIDE.md, XCODE_STYLE_GUIDE.md
|   +-- (Additional documentation)
|   +-- ExampleCode/     # Example Code files and inspiration
|   +-- TestData/        # Test data here
|   +-- UX_Snapshots/    # Screenshots/images of UI/UX changes (MANDATORY)
+-- scripts/             # All utility scripts
+-- shared/              # Cross-platform shared code
+-- _{PlatformDir}/      # Platform code (e.g., _macOS/, _iOS/)
|   +-- {ProjectFileNamePlaceholder}.xcodeproj # MUST BE SWEETPAD BUILDABLE
|   +-- {PlatformSourceRoot}/  # Platform source code
|   +-- {PlatformSourceRootSandbox}/  # Platform Sandbox source code
|   +-- Tests/           # Platform tests
|   +-- build/, logs/    # Build artifacts & logs (gitignored)
|   +-- scripts/         # Platform-specific scripts
+-- {TestDataDirectoryPath}/ # Multiplatform Test data & mocks
+-- temp/                # Temporary files (gitignored)
+-- logs/                # General logs (gitignored)
```

## 5. Key Directory Principles
- **Production Project:** Only ONE canonical set in platform directory.
- **Sandbox:** All sandbox projects in `_{PlatformDir}/sandbox/`
- **Backups:** Only in `temp/backup/`, max 3, rotate oldest out.
- **No Stray Files:** Root must remain clean. Enforce batch deletion.
- **Documentation:** All docs in `docs/` only.
- **Rule Files:** Rule definition files in `.roo/rules/`
- **Scripts:** In `scripts/` or platform-specific `_{PlatformDir}/scripts/`
- **Logs:** All logs in appropriate `logs/` folders and gitignored.

---
*Effective management of project documentation, directory structure, configurations, and dependencies is crucial for maintainability, collaboration, and reproducibility.*

## CRITICAL AND MANDATORY: Summary & Recommendation Protocol (2024-05-18 Update)

- All user-facing outputs (including SMEAC/VALIDATION REQUEST, checkpoint, and major status updates) MUST include:
  - A **Summary** section at the bottom, immediately before the **Recommendation/Next Steps** section.
  - The **Recommendation** must be clear, actionable, and mandatory.
- **Before writing the Recommendation, the AI agent MUST:**
  1. Use the `sequential-thinking` MCP server to plan the response and next steps.
  2. Use the `context7` MCP to retrieve or cross-reference any additional documentation or context required.
  3. Use the `perplexity` MCP to finalize research and ensure the recommendation is up-to-date and comprehensive.
- The SMEAC/VALIDATION REQUEST template MUST be updated to include these requirements, with the Summary and Recommendation sections at the bottom.

## 8.7. MCP Server/Tool Utilization (CRITICAL AND MANDATORY)
- All documentation, directory, and configuration management processes MUST utilize:
    - `puppeteer` for web analysis
    - `perplexity-ask` for research
    - `momory` for information storage/recall
    - `context7` for latest documentation
    - `sequential-thinking` for planning/analysis
- These are REQUIRED for all documentation review, update, and configuration analysis. Violation triggers P0 STOP EVERYTHING.

## 8.9. (CRITICAL AND MANDATORY) Mock/Fake Data & Integration Prohibition and Enforcement

- Mock/fake data, services, or integrations are permitted ONLY for development, testing, or sandbox environments.
- Every instance MUST be explicitly logged as technical debt in @TASKS.MD and trigger an update to @BLUEPRINT.MD, documenting the current state and plan for real integration.
- It is STRICTLY FORBIDDEN to ship any milestone (Alpha, Beta, Production, App Store, etc.) with features that use mock/fake data, services, or integrations.
- All milestone definitions MUST explicitly prohibit shipping features with mock/fake dependencies.
- Any use of mock/fake data/services/integrations MUST create subtasks for real integration and user validation, tracked to completion before release.
- This rule is compulsory and enforced at every milestone checkpoint and release process. Reference .cursorrules for full enforcement protocol.

