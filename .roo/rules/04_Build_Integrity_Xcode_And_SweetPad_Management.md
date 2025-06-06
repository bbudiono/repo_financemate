---
description: Build/test validation, Xcode project/workspace management, preventing and resolving build configuration errors, and ensuring only one canonical project/workspace exists.
globs: 
alwaysApply: false
---
---
description: 
globs: 
alwaysApply: true
---
# Recent Lessons Learned & Continuous Improvement

- **Automated Checks & Programmatic Execution:** Always use automated scripts and programmatic tools for build verification, project structure, and workflow operations before any manual intervention.
- **TDD & Sandbox-First Workflow:** All new features and bug fixes must be developed using TDD and validated in a sandbox before production.
- **Comprehensive Logging & Documentation:** Log all build failures, fixes, protocol deviations, and significant actions in canonical logs for audit and continuous improvement. Update all relevant documentation and protocols after each incident or improvement.
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

# 04. Build Integrity, Xcode & SweetPad Management

## 1. Foundational Principle: Keep The Build Green (P0)

*   **(CRITICAL AND MANDATORY) Absolute Priority - Green Build:**
    *   The absolute, non-negotiable priority is maintaining a constantly buildable state of the application, specifically compatible with SweetPad (as per `@XCODE_BUILD_GUIDE.md`).
    *   **DO NOT EDIT CODE IN THE PRODUCTION/WORKING STATE IF TESTS ARE FAILING OR THE BUILD IS BROKEN.**
    *   The main development branch (e.g., `main`, `develop`) **MUST** always be in a buildable and runnable state.
*   **(CRITICAL AND MANDATORY) Failure to Maintain Green Build:**
    *   This is a CRITICAL FAILURE. Immediate P0 priority **MUST** be given to fixing any build breakage.
    *   All other development work **MUST** cease until the build is restored to a green state.
    *   Refer to `@05_Build_Failure_Resolution_And_Prevention_Framework.md` for resolution protocols and `@XCODE_BUILD_GUIDE.md` (especially the Build Stability Enhancement Guide section) for `.xcodeproj` restoration and SweetPad configuration recovery.
*   **(CRITICAL AND MANDATORY) Constant Buildability & Verification (SweetPad):**
    *   The project **MUST** remain buildable and SweetPad-compatible at all times.
    *   Programmatic build verification (`XcodeBuildMCP` or `Bash` `xcodebuild`) **MUST** occur after EVERY significant code or project file change. See Section 3.
    *   Failed builds immediately become P0 priority.

## 2. Xcode Project & Workspace Integrity

*   **(CRITICAL AND MANDATORY) `.xcodeproj` Integrity:**
    *   Under no circumstances should the `.xcodeproj` file (or its internal `project.pbxproj` file) be manually edited in a way that introduces corruption or instability if automated or scripted methods are available and safer.
    *   Automated and script-based modifications are strongly preferred (see `@09_Tooling_Automation_And_Integrations_Protocol.md` for Patching Tool Selection Protocol, e.g., using the `xcodeproj` gem for Ruby scripts).
*   **(CRITICAL AND MANDATORY) Pre-Task/Pre-Merge Verification:**
    *   Always verify that the Xcode project builds successfully and all critical functionalities are operational before considering a task complete or merging code.
*   **(CRITICAL AND MANDATORY) `.xcodeproj` Corruption Protocol:**
    1.  If the `.xcodeproj` file becomes corrupted, immediately attempt to revert to the last known working version from version control.
    2.  Document the incident in detail in `@BUILD_FAILURES.MD`, including suspected causes, actions taken, and preventative measures considered.
    3.  Consult the **Build Stability Enhancement Guide** in `@XCODE_BUILD_GUIDE.md` for structured restoration procedures.
*   **(CRITICAL AND MANDATORY) Single Canonical Project/Workspace:**
    *   Maintain only one canonical Xcode project (`.xcodeproj`) and workspace (`.xcworkspace`) for production builds within the designated platform directory (e.g., `_macOS/`).
    *   All other sandbox, temporary, or duplicate project/workspace files **MUST** be strictly managed under sandboxed directories (e.g., `_macOS/sandbox/`) or `temp/` and regularly cleaned up. See `@08_Documentation_Directory_And_Configuration_Management.md`.
*   **(CRITICAL AND MANDATORY) Workspace Data File Integrity (`contents.xcworkspacedata`):**
    *   Every `.xcworkspace` **MUST** contain a valid `contents.xcworkspacedata` file.
    *   **Required Checks (Automated):**
        *   Workspace directory exists at the expected path.
        *   `contents.xcworkspacedata` file exists and is valid XML.
        *   The file contains at least one `<FileRef>` referencing a valid `.xcodeproj`.
    *   Failure of these checks should block commits/merges (see `@06_Testing_Strategy_And_Quality_Assurance.md` for CI enforcement).

## 3. Build Verification Process

*   **(CRITICAL AND MANDATORY) Build After EVERY Change:**
    *   A full, clean build **MUST** be performed after every substantive code modification, configuration change, or project file adjustment.
    *   This includes changes to `Package.swift`, `.xcconfig` files, asset catalogs, or any file referenced by the build system.
*   **(CRITICAL AND MANDATORY) Programmatic Build Invocation:**
    *   Builds **MUST** be invoked programmatically:
        *   Using `XcodeBuildMCP` for `.xcodeproj` based projects (preferred).
        *   Using `Bash swift build` for Swift Package Manager (SPM) based logic or packages.
        *   Commands should be sourced from `@BUILDING.MD` or `@XCODE_BUILD_CONFIGURATION.MD`.
*   **(CRITICAL AND MANDATORY) SweetPad Compatibility Check:**
    *   All builds, especially for macOS targets, **MUST** be verified for SweetPad compatibility as defined in `@XCODE_BUILD_GUIDE.md`.
    *   This may involve specific build schemes, configurations, or post-build checks.

## 4. Preventing Common Build Configuration Errors

*These rules are derived from `build_failure_prevention_tests.md` and **MUST** be enforced through automated checks (e.g., pre-commit hooks, CI scripts, dedicated test suites).*

*   **(CRITICAL AND MANDATORY) No Duplicate Asset Catalog References:**
    *   **Rule:** Each build target in the `.xcodeproj` **MUST** reference each asset catalog (e.g., `Assets.xcassets`) at most once.
    *   **Rationale:** Prevents "multiple commands produce" build errors related to asset compilation.
    *   **Required Checks (Automated):** Scan `project.pbxproj` for duplicate asset catalog entries within any single target's build phases (especially `PBXResourcesBuildPhase`).
*   **(CRITICAL AND MANDATORY) All Project File References Must Exist:**
    *   **Rule:** Every file referenced in `project.pbxproj` (Swift, Storyboard, XIB, Asset Catalog, plists, etc.) **MUST** exist on disk at the referenced path relative to the project file.
    *   **Rationale:** Prevents "file not found" build errors and ensures project integrity.
    *   **Required Checks (Automated):** Scan `project.pbxproj` for all `PBXFileReference` entries and verify that the `path` attribute for each corresponds to an existing file on disk.
*   **(CRITICAL AND MANDATORY) Build Phase Section Integrity (`project.pbxproj`):**
    *   **Rule:** All required build phase sections **MUST** exist and be properly structured/paired in `project.pbxproj`.
    *   **Rationale:** Prevents build failures due to corrupted, incomplete, or malformed project configurations.
    *   **Required Checks (Automated):**
        *   Validate that essential sections (e.g., `PBXBuildFile`, `PBXFileReference`, `PBXSourcesBuildPhase`, `PBXResourcesBuildPhase`, `PBXFrameworksBuildPhase`, `PBXNativeTarget`, `XCConfigurationList`) are present.
        *   Ensure proper ISA types and structural integrity for these sections.
        *   Verify each build target has appropriate and complete build phases assigned.
*   **(CRITICAL AND MANDATORY) CoreData Model Consistency (if applicable):**
    *   **Rule:** Every referenced CoreData model (`.xcdatamodeld` bundle) **MUST** exist, contain at least one version (`.xcdatamodel`), and be correctly referenced in `project.pbxproj` and included in a build target's resources.
    *   **Rationale:** Prevents build-time or runtime errors due to missing, corrupt, or inconsistent data models.
    *   **Required Checks (Automated):**
        *   Verify the `.xcdatamodeld` directory exists and contains at least one versioned `.xcdatamodel` file.
        *   Ensure the model is correctly referenced as a `PBXFileReference` in `project.pbxproj` and included in the `PBXResourcesBuildPhase` of the relevant target(s).
        *   Optionally, parse the model to ensure expected entities and attributes are present.
*   **(CRITICAL AND MANDATORY) Swift Package Manager (SPM) Consistency (if applicable):**
    *   **Rule:** If SPM is used, `Package.swift` **MUST** be valid, and all declared dependencies **MUST** resolve correctly. The project file (`.xcodeproj`) **MUST** be consistent with `Package.swift` if it integrates SPM packages (e.g., `XCSwiftPackageProductDependency` entries in `project.pbxproj` must align).
    *   **Rationale:** Prevents dependency resolution errors and inconsistencies between SPM and Xcode build systems.
    *   **Required Checks (Automated):**
        *   Run `swift package resolve` (or `swift package update`) to check dependency resolution.
        *   If using an `.xcodeproj`, compare its linked SPM products against `Package.swift`.

## 4.8. MCP Server/Tool Utilization (CRITICAL AND MANDATORY)
- All build integrity, Xcode, and SweetPad management processes MUST utilize:
    - `puppeteer` for web analysis
    - `perplexity-ask` for research
    - `momory` for information storage/recall
    - `context7` for latest documentation
    - `sequential-thinking` for planning/analysis
- These are REQUIRED for all build analysis, troubleshooting, and planning. Violation triggers P0 STOP EVERYTHING.

## 4.9. (CRITICAL AND MANDATORY) Mock/Fake Data & Integration Prohibition and Enforcement

- Mock/fake data, services, or integrations are permitted ONLY for development, testing, or sandbox environments.
- Every instance MUST be explicitly logged as technical debt in @TASKS.MD and trigger an update to @BLUEPRINT.MD, documenting the current state and plan for real integration.
- It is STRICTLY FORBIDDEN to ship any milestone (Alpha, Beta, Production, App Store, etc.) with features that use mock/fake data, services, or integrations.
- All milestone definitions MUST explicitly prohibit shipping features with mock/fake dependencies.
- Any use of mock/fake data/services/integrations MUST create subtasks for real integration and user validation, tracked to completion before release.
- This rule is compulsory and enforced at every milestone checkpoint and release process. Reference .cursorrules for full enforcement protocol.

## 5. Continuous Improvement & Enforcement

*   **(CRITICAL AND MANDATORY) Update Rules from Failures:** These build integrity rules **MUST** be updated and expanded as new build failure patterns are discovered and documented in `@BUILD_FAILURES.MD`.
*   **(CRITICAL AND MANDATORY) Automated Enforcement:** All checks defined in this document, especially in Section 4, **MUST** be automated and integrated into pre-commit hooks, CI pipelines, and/or dedicated test suites to prevent build-breaking changes from entering the main codebase. See `@06_Testing_Strategy_And_Quality_Assurance.md`.

## CRITICAL AND MANDATORY: Summary & Recommendation Protocol (2024-05-18 Update)

- All user-facing outputs (including SMEAC/VALIDATION REQUEST, checkpoint, and major status updates) MUST include:
  - A **Summary** section at the bottom, immediately before the **Recommendation/Next Steps** section.
  - The **Recommendation** must be clear, actionable, and mandatory.
- **Before writing the Recommendation, the AI agent MUST:**
  1. Use the `sequential-thinking` MCP server to plan the response and next steps.
  2. Use the `context7` MCP to retrieve or cross-reference any additional documentation or context required.
  3. Use the `perplexity` MCP to finalize research and ensure the recommendation is up-to-date and comprehensive.
- The SMEAC/VALIDATION REQUEST template MUST be updated to include these requirements, with the Summary and Recommendation sections at the bottom.

---
*Maintaining a consistently green and stable build environment, particularly for Xcode and SweetPad projects, is paramount. Strict adherence to these integrity rules is mandatory.*
