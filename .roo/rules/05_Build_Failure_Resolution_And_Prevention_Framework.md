---
description: Any build failure or error scenario—ensures failures are logged, analyzed, and resolved systematically, with scripts and documentation updated for future prevention.
globs: 
alwaysApply: false
---
---
description: 
globs: build,fails,failure,block,prevention,recommendation,summary
alwaysApply: false
---
# Recent Lessons Learned & Continuous Improvement

- **Automated Checks & Programmatic Execution:** Always use automated scripts and programmatic tools for build failure detection, prevention, and workflow operations before any manual intervention.
- **TDD & Sandbox-First Workflow:** All new features and bug fixes must be developed using TDD and validated in a sandbox before production.
- **Comprehensive Logging & Documentation:** Document every build failure, fix, and protocol deviation in canonical logs for audit and continuous improvement. Update all relevant documentation and protocols after each incident or improvement.
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

**COMPULSORY MANDATE P0**
Reference tools for Programmatic Xcode Builds:
- Xcodegen: Good for straightforward project generation from YAML/JSON, well-established.
- Tuist: Excellent for those who prefer Swift for project definition, offers more features like caching, graph, plugins, and strong opinions on modularity. Often seen as a more modern and comprehensive successor/alternative to Xcodegen.
- Bazel/Buck: Best for very large monorepos needing extreme build performance, scalability, and correctness across multiple languages/platforms. Higher learning curve.
- CMake: Strong for C/C++ heavy projects or cross-platform needs where Xcode is one of several target IDEs.
- SPM (alone): Suitable for managing Swift packages (libraries/modules) and very simple applications, but not a full project generator for complex apps.



Reference: See .cursorrules for enforcement and compliance.

# 05. Build Failure Resolution & Prevention Framework

## 1. Foundational Principle: Document Every Failure

*   **(CRITICAL AND MANDATORY) All Failures Documented:** Every build failure, without exception, regardless of perceived severity or ease of resolution, **MUST** be meticulously documented in `@BUILD_FAILURES.MD`.
*   **(CRITICAL AND MANDATORY) Immediate Documentation:** Documentation should occur as soon as a build failure is confirmed and before extensive troubleshooting begins (to capture the initial state accurately), and then updated throughout the resolution process.

## 2. Build Failure Classification System

*   **(CRITICAL AND MANDATORY) Standardized Error Categories:** Build failures **MUST** be categorized using the established taxonomy (e.g., compiler errors, linker errors, project configuration errors, runtime errors during test, test failures, dependency errors, resource errors). Refer to Section 15.1 of `@PROJECT_RULES_NATIVE_APP_V3_8.md` (or its new consolidated location if already migrated) for the full JSON-defined taxonomy.
*   **(CRITICAL AND MANDATORY) Severity Levels:** Assign a severity level to each failure:
    *   **SEVERITY 1 (Critical):** Prevents app from building or running at all.
    *   **SEVERITY 2 (High):** App builds but crashes on key functionality or fails critical tests.
    *   **SEVERITY 3 (Medium):** App builds but has non-critical functionality issues or non-critical test failures.
    *   **SEVERITY 4 (Low):** Cosmetic issues, warnings that impede build/test success, or minor tech debt identified through failure.
*   **(CRITICAL AND MANDATORY) Unique Error Codes:** Each documented build failure **MUST** be assigned a unique error code in the format: `PMBE-{CATEGORY}-{COUNTER}` (e.g., `PMBE-LINKER-003`). This aids in tracking and referencing.

## 3. Standardized Build Failure Documentation Template (`@BUILD_FAILURES.MD`)

*   **(CRITICAL AND MANDATORY) Use Standard Template:** All entries in `@BUILD_FAILURES.MD` **MUST** use the following exact Markdown template. A copy of this template should be at the top of `@BUILD_FAILURES.MD` for reference.

    ```markdown
    ---
    ErrorCode: PMBE-CATEGORY-NNN
    Timestamp: YYYY-MM-DD HH:MM:SS UTC
    Category: <Primary Category / Subcategory from defined taxonomy>
    Severity: SEVERITY [1-4]
    TaskID: <ID of task being worked on, if any, e.g., TASKS.MD#1.2.3>
    CommitBeforeFailure: <Full commit hash immediately preceding the failure, if identifiable>
    Environment: <Xcode version, macOS version, Swift/ObjC Version, Device/Simulator, relevant tool/dependency versions>
    ErrorDetails: |
      <PASTE FULL, VERBATIM ERROR MESSAGES AND STACK TRACES HERE.
      Use multi-line block for readability. DO NOT SUMMARIZE OR ALTER.>
    SystemStateAndStepsToReproduce: |
      <Describe the system state (e.g., specific branch, uncommitted changes) and the PRECISE, MINIMAL steps taken leading to this failure.
      Include any recent changes, commands run, or unusual conditions.
      If reproducible, list exact numbered steps.>
    HypothesisOnCause: |
      <Initial thoughts on the potential cause(s) of the failure. Based on error messages and recent changes.>
    AnalysisAndResolutionAttempts: |
      <Detailed chronological log of the diagnostic process and all solution attempts.
      For each attempt:
      1. **Attempt Description:** (e.g., "Modified build setting X", "Reverted file Y.swift to previous version", "Ran diagnostic script Z.sh")
      2. **Rationale:** (Why this attempt was made)
      3. **Outcome:** (e.g., "Same error", "New error: [new verbatim message]", "Partially resolved but issue A remains", "SUCCESS")
      4. **Analysis of Outcome:** (Why it succeeded or failed, what was learned)
      Ensure to detail consultations of KBs like `@COMMON_ERRORS.MD` or existing `@BUILD_FAILURES.MD` entries.>
    SuccessfulResolution: |
      <If resolved, provide a clear, detailed description of the exact solution that worked.
      Include specific code changes (diffs if concise), configuration adjustments, or commands run.
      Reference the commit hash of the fix if applicable.>
    RootCauseAnalysis (Five Whys - for Severity 1 & 2): |
      1. Why did the immediate error occur? <Answer>
      2. Why did that (answer to 1) happen? <Answer>
      3. Why was that (answer to 2) the case? <Answer>
      4. Why did that (answer to 3) exist? <Answer>
      5. Why was the system/process (answer to 4) like that? <Answer>
      (This helps identify deeper systemic issues.)
    PreventionMeasures: |
      <Specific measures to prevent this type of failure from recurring.
      - **Early Detection:** How could this have been caught earlier?
      - **Prevention Mechanisms:** New tests to add (unit, integration, UI), linter rules, validation scripts, CI checks, documentation updates, process changes.
      - **Recommended Checks:** Specific checks developers should perform manually if automation isn't immediately feasible.>
    RelatedDiagnosticScripts: <List any diagnostic scripts used or created, e.g., @scripts/diagnostics/check_linker_paths.sh>
    RelatedFixerScripts: <List any fixer scripts used or created, e.g., @scripts/fixers/correct_plist_value.py>
    RelatedDocumentation: <Links to relevant Apple docs, Stack Overflow, internal guides, etc.>
    ---
    ```

## 4. Diagnostic & Resolution Script Management

*   **(CRITICAL AND MANDATORY) Proactive Script Creation:** For **EVERY** newly identified and understood type of build error or common issue (especially recurring ones):
    1.  **Diagnostic Script:** Create a script (e.g., shell, Python, Ruby) in `@scripts/diagnostics/`. This script **MUST**:
        *   Reliably detect the presence of the specific issue or error pattern.
        *   Collect relevant information (logs, settings, file statuses) to aid analysis.
        *   Report findings in a clear, structured format (machine-readable or human-readable).
        *   Example: `@scripts/diagnostics/check_missing_framework_links.sh`.
    2.  **Resolution Script (If Applicable):** If a programmatic fix is feasible and safe, create a corresponding script in `@scripts/fixers/`. This script **MUST**:
        *   Apply the known, verified solution to fix the issue.
        *   Operate idempotently if possible (running it multiple times has the same effect as running it once).
        *   Include verification steps to confirm the fix was successful.
        *   Example: `@scripts/fixers/add_missing_framework_link.rb --framework SomeFramework`.
*   **(CRITICAL AND MANDATORY) Version Control & Referencing:**
    *   All diagnostic and resolution scripts **MUST** be committed to the project's version control system.
    *   They **MUST** be referenced in the `RelatedDiagnosticScripts` and `RelatedFixerScripts` fields of the relevant `@BUILD_FAILURES.MD` entries.
*   **(CRITICAL AND MANDATORY) Integration with Workflow (Automated First):**
    *   When a known build failure pattern occurs, the AI Agent or developer **MUST FIRST** attempt to use the documented diagnostic script to confirm the issue and then the resolution script to fix it, **BEFORE** attempting manual or novel solutions.
    *   Log the outcome of script execution in the `AnalysisAndResolutionAttempts` section of the `@BUILD_FAILURES.MD` entry.
*   **(CRITICAL AND MANDATORY) Continuous Improvement of Scripts:**
    *   Update and refine these scripts as new variations of issues are discovered, diagnostic methods improve, or more robust fixes are developed.
    *   Ensure scripts are well-commented, easy to understand, and follow project coding standards for scripts.

## 5. Root Cause Analysis (RCA) & Learning from Failures

*   **(CRITICAL AND MANDATORY) Five Whys for Severe Failures:** For ALL SEVERITY 1 and SEVERITY 2 build failures, a "Five Whys" analysis (or similar RCA technique) **MUST** be performed and documented in the `RootCauseAnalysis` section of the `@BUILD_FAILURES.MD` entry.
*   **(CRITICAL AND MANDATORY) Cascade Analysis:** Identify if the failure is a symptom of a deeper issue. Track the chain of related issues to find the originating problem. Update all related error entries with cross-references.
*   **(CRITICAL AND MANDATORY) Consult KBs Before Fixing:** Before attempting fixes for any build failure, the AI Agent/developer **MUST** query `@BUILD_FAILURES.MD` and `@COMMON_ERRORS.MD` (using `filesystem` MCP `Read`/`Grep` or other search_files tools) for existing entries related to similar errors, symptoms, or modules. This is to avoid repeating previously failed solutions and to leverage known successful fixes.
*   **(CRITICAL AND MANDATORY) Update Prevention Measures:** The `PreventionMeasures` section of every `@BUILD_FAILURES.MD` entry **MUST** be thoughtfully completed. This is key to an adaptive learning process. This section should propose concrete actions like:
    *   New automated tests (unit, integration, UI/snapshot).
    *   Updates to linter configurations (`@.swiftlint.yml` or equivalent).
    *   New or updated diagnostic/fixer scripts.
    *   Improvements to CI checks.
    *   Clarifications or additions to project documentation (e.g., `@XCODE_BUILD_GUIDE.MD`).
    *   Process changes for development or review.

## 6. Proactive Build Stability Enhancement & Failure Prevention

*This section integrates principles from `@PROJECT_RULES_NATIVE_APP_V3_8.md` Section 17 (Proactive Build Stability Enhancement) and the Advanced Learning Framework (`@protocol_build_failure.md`).*

*   **(CRITICAL AND MANDATORY) Pre-Task Risk Profiling:**
    *   Before commencing implementation of any Level 4+ task, perform a "Build Stability Risk Assessment" for the targeted code areas/modules.
    *   Query `@BUILD_FAILURES.MD` and `@COMMON_ERRORS.MD` for historical failures related to files, dependencies, or types of changes in the current task.
    *   Analyze code complexity and recency/magnitude of previous changes.
    *   Generate a risk profile (Low/Medium/High) with justifications. For Medium/High risk, identify 1-2 primary potential failure modes.
*   **(CRITICAL AND MANDATORY) Adaptive Pre-emptive Checks & Guarding:**
    *   Based on the risk profile, select and apply relevant pre-emptive checks or temporary "guarding" mechanisms *before* or during sandboxed development (see `@06_Testing_Strategy_And_Quality_Assurance.md`).
    *   Examples: Run specific diagnostic scripts, verify dependency integrity, temporarily enable more stringent static analysis for risky code segments.
*   **(CRITICAL AND MANDATORY) Analyze "Build Churn" & Near-Misses:**
    *   Even if a build (especially in a sandbox) eventually succeeds but required multiple automated fix attempts ("build churn"), this **MUST** be analyzed.
    *   Log this analysis in `@BUILD_FAILURES.MD` (or a dedicated `BUILD_CHURN_ANALYSIS.MD`), focusing on patterns in the initial code that led to multiple fix attempts.
    *   Use this analysis to propose new tests, stricter linting, or refactoring tasks to improve first-pass code quality.
*   **(CRITICAL AND MANDATORY) Periodic Review of Failure & Churn Data:**
    *   At predefined intervals (e.g., after N tasks, weekly), perform a trend analysis of `@BUILD_FAILURES.MD` (including churn analysis).
    *   Identify recurring error categories, common root causes, and frequently failing modules/dependencies.
*   **(CRITICAL AND MANDATORY) Propose Preventative Initiatives & Rule Enhancements:**
    *   Based on trend analysis, proactively generate "Preventative Stability Initiative" tasks in `@TASKS.MD` (e.g., "Develop new diagnostic for recurring error X", "Refactor module Y for robustness", "Update `@XCODE_BUILD_GUIDE.MD` with new learnings").
*   **(CRITICAL AND MANDATORY) Generalize Solutions & Cross-Task Learning:**
    *   When a novel build failure is resolved, consider if the root cause or solution principle could apply to other areas. Note this in the `PreventionMeasures` section and propose broader checks or refactorings if applicable.

## 7. Context Preservation & Reproduction for Failures

*   **(CRITICAL AND MANDATORY) System State Capture:** For every failure, capture and document:
    *   Environment variables at the time of failure.
    *   Exact versions of Xcode, Swift, OS, and critical tools/dependencies.
    *   Relevant configuration files (e.g., a temporary copy of `project.pbxproj`, `Package.swift`, `.xcconfig` files involved).
    *   A minimal, reproducible example or test case if possible and not overly complex to create.
*   **(CRITICAL AND MANDATORY) Precise Reproduction Steps:** Document exact, numbered steps to reproduce the error in the `SystemStateAndStepsToReproduce` section of the `@BUILD_FAILURES.MD` entry. These steps are vital for verification and future analysis.

## 8. Build Failure Resolution Workflow

*   **(CRITICAL AND MANDATORY) Strict Workflow Adherence:**
    1.  **Identify & Document (Initial):** Capture exact error, categorize it, and create/update the entry in `@BUILD_FAILURES.MD` with initial information (Timestamp, ErrorDetails, SystemState, Hypothesis).
    2.  **Consult Knowledge Bases:** Search `@BUILD_FAILURES.MD` and `@COMMON_ERRORS.MD` for existing solutions to similar issues.
    3.  **Apply Known Solutions (Scripts First):** If a match is found with associated diagnostic/fixer scripts, attempt these first. Document outcomes.
    4.  **Diagnose (If New/Unclear):** If no known solution or scripts are directly applicable, run general or relevant diagnostic scripts. Perform manual analysis (code review, log checking, etc.). Document all steps and findings in `AnalysisAndResolutionAttempts`.
    5.  **Root Cause Analysis:** Determine the underlying cause (Five Whys for Sev 1/2).
    6.  **Solution Attempt Planning & Execution:** Document planned solution attempts *before* trying them. Implement solutions iteratively, logging each attempt and outcome in `AnalysisAndResolutionAttempts`.
    7.  **Verification:** After a potential fix, perform a full clean build and run all relevant tests to validate the fix. Document results.
    8.  **Update Documentation (Final):** Complete all sections of the `@BUILD_FAILURES.MD` entry, especially `SuccessfulResolution`, `RootCauseAnalysis`, and `PreventionMeasures`.
    9.  **Knowledge Base Update (Scripts & KBs):** Update or create new diagnostic/resolution scripts. Update `@COMMON_ERRORS.MD` if applicable. Ensure prevention measures are actionable (e.g., new tasks in `@TASKS.MD`).
    10. **Project File Recovery (If Necessary):** For `.xcodeproj` corruption or severe build issues, apply structured restoration procedures from the **Build Stability Enhancement Guide** in `@XCODE_BUILD_GUIDE.MD`.
*   **(CRITICAL AND MANDATORY) Rollback Mechanism Consideration:**
    *   Always identify a "known good state" (e.g., last successful commit) before attempting significant or risky fixes.
    *   Document this state for potential rollback.
    *   Store temporary backups of critical files before modification (e.g., `project.pbxproj`).
*   **(CRITICAL AND MANDATORY) Escalation Protocol:**
    *   If a build failure cannot be resolved within a reasonable timeframe (defined by project context, e.g., 1-2 hours for P0 issues by an AI agent), or if automated attempts are exhausted, escalate according to project communication protocols.
    *   The escalation report **MUST** include a link to the comprehensive `@BUILD_FAILURES.MD` entry for the issue.

## 9. Required Automated Build Integrity Checks

*These rules define required automated checks and validation strategies to proactively prevent common build failures in Xcode/Swift projects. They are to be enforced via pre-commit hooks, CI processes, and/or dedicated test suites.*

*   **(CRITICAL AND MANDATORY) Workspace Data File Integrity:**
    *   **Rule:** Every `.xcworkspace` must contain a valid `contents.xcworkspacedata` file.
    *   **Rationale:** Prevents workspace loading/build failures due to missing or corrupt workspace data.
    *   **Required Checks:**
        *   Workspace directory exists at expected path.
        *   `contents.xcworkspacedata` file exists and is valid XML.
        *   File contains at least one `<FileRef>` referencing a valid project.
    *   **Enforcement:** Pre-commit hook, CI, and/or test suite must fail if any check fails.

*   **(CRITICAL AND MANDATORY) No Duplicate Asset Catalog References:**
    *   **Rule:** Each build target in `.xcodeproj` must reference each asset catalog (e.g., `Assets.xcassets`) at most once.
    *   **Rationale:** Prevents "multiple commands produce" build errors.
    *   **Required Checks:** No duplicate references to the same asset catalog in any build phase.
    *   **Enforcement:** Automated test or script must scan `project.pbxproj` for duplicate asset catalog entries.

*   **(CRITICAL AND MANDATORY) No Duplicate Type Definitions:**
    *   **Rule:** No type (struct/class/enum/protocol/typealias) may be defined in more than one file in the codebase.
    *   **Rationale:** Prevents Swift compiler errors due to duplicate type definitions.
    *   **Required Checks:** Automated scan of all `.swift` files for duplicate type names.
    *   **Enforcement:** Pre-commit hook, CI, or test suite must fail if duplicates are found.

*   **(CRITICAL AND MANDATORY) All Project File References Must Exist:**
    *   **Rule:** Every file referenced in `project.pbxproj` (Swift, Storyboard, XIB, Asset Catalog, etc.) must exist on disk at the referenced path.
    *   **Rationale:** Prevents "file not found" build errors.
    *   **Required Checks:** Automated scan of `project.pbxproj` for all file references; verify each exists.
    *   **Enforcement:** Pre-commit hook, CI, or test suite must fail if any referenced file is missing.

*   **(CRITICAL AND MANDATORY) Build Phase Section Integrity:**
    *   **Rule:** All required build phase sections must exist and be properly paired in `project.pbxproj`.
    *   **Rationale:** Prevents build failures due to corrupted or incomplete project configuration.
    *   **Required Checks:**
        *   All required sections (e.g., PBXBuildFile, PBXFileReference, PBXResourcesBuildPhase, etc.) are present.
        *   Each "Begin" section has a matching "End".
        *   Each build target has appropriate build phases (Sources, Resources, Frameworks).
    *   **Enforcement:** Automated test or script must validate section presence and pairing.

*   **(CRITICAL AND MANDATORY) CoreData Model Consistency:**
    *   **Rule:** Every referenced CoreData model must exist, contain at least one version, and be referenced in the project file.
    *   **Rationale:** Prevents build/runtime errors due to missing or inconsistent data models.
    *   **Required Checks:**
        *   `.xcdatamodeld` directory exists and contains at least one `.xcdatamodel` version.
        *   Model is referenced in `project.pbxproj` and included in a build phase.
        *   Model contains expected entities and relationships.
    *   **Enforcement:** Automated test or script must validate model existence, structure, and project references.

*   **(CRITICAL AND MANDATORY) Swift Package Manager Consistency:**
    *   **Rule:** If SPM is used, `Package.swift` must be valid, and all declared dependencies must resolve correctly. The project file must be consistent with `Package.swift` if it integrates SPM packages.
    *   **Rationale:** Prevents dependency resolution errors and inconsistencies between SPM and Xcode build systems.
    *   **Required Checks:**
        *   Run `swift package resolve` to check dependency resolution.
        *   If using an `.xcodeproj`, compare its linked SPM products against `Package.swift`.
    *   **Enforcement:** Pre-commit hook, CI, or test suite must fail if package resolution fails.

## 10. Creative Workarounds for Common Build Issues

## 11. Comprehensive File Recovery and Build Restoration Process

*This section provides a detailed, step-by-step process for recovering files and restoring builds when corruption, missing files, or other build failures occur. It expands on the protocol defined in `.cursorrules` (Section 1.15) and integrates with the Build Stability Enhancement Guide in `@XCODE_BUILD_GUIDE.md`.*

### 11.1. Automated Backup and Prevention Framework

*   **(CRITICAL AND MANDATORY) Proactive Backup Protocol:**
    1.  **Scheduled Automated Backups:**
        * Implement and maintain scheduled backup scripts (e.g., `scripts/backup/scheduled_project_backup.sh`) to run at defined intervals.
        * Backups MUST capture `.xcodeproj`, `.xcworkspace`, critical configuration files, and project structure in `temp/backup/YYYYMMDDHHMMSS/`.
        * Log all backup operations in `@BACKUP_LOG.MD` (within `docs/`).
    2.  **Pre-Change Backups:**
        * Before any significant project structure change, `.xcodeproj` modification, or configuration update, execute `scripts/backup/pre_change_backup.sh`.
        * This script MUST be integrated into pre-commit hooks and included in the task workflow for all structure-modifying tasks.
    3.  **GitHub Integration:**
        * After every successful build, use GitHub MCP to commit to a stable build branch.
        * Maintain a `build/stable-latest` branch that always points to the most recent stable build.
        * For major milestone builds, create permanent stable branches (e.g., `build/stable-v1.2.0`).
    4.  **Backup Rotation and Cleanup:**
        * Maintain maximum 3 local backups to conserve space.
        * Automated cleanup script (`scripts/backup/rotate_backups.sh`) MUST run after creating new backups.
        * Oldest backups are removed first, with critical pre-release backups preserved longer.

*   **(CRITICAL AND MANDATORY) File System Integrity Monitoring:**
    1.  **Project Structure Validation:**
        * Run `scripts/verify_project_integrity.sh` after all file operations to verify structure.
        * The script MUST check for missing files, correct directory structure, required configurations, and project file integrity.
    2.  **Automated Corruption Detection:**
        * Implement `.xcodeproj` and `.xcworkspace` parsing scripts to verify internal integrity.
        * Schedule regular integrity checks for critical project files.
        * Immediately notify on detection of potential corruption.

### 11.2. Detailed File Recovery Procedures

*   **(CRITICAL AND MANDATORY) Recovery of Corrupted Xcode Project Files:**
    1.  **Diagnosis and Assessment:**
        * Determine symptoms: unable to open, build errors, missing references.
        * Identify specific corrupted elements (entire project or specific sections).
        * Check `project.pbxproj` for XML/JSON syntax errors, UUID consistency.
    2.  **Located Known-Good Version:**
        * Check for timestamped backups in `temp/backup/`.
        * Review version control history for last known working commit.
        * If sandbox project is corrupted but production is intact, consider duplicating from production.
    3.  **Safely Preserve Current State:**
        * Create backup of corrupted file: `cp /path/to/corrupted.xcodeproj/project.pbxproj /temp/corrupted_prebacup_$(date +%Y%m%d%H%M%S).pbxproj`.
        * Document in `@BUILD_FAILURES.MD` with exact timestamp and condition.
    4.  **Restoration Process:**
        * Replace corrupted file with known good version:
          ```bash
          # Example restoration command
          cp /temp/backup/YYYYMMDDHHMMSS/Project.xcodeproj/project.pbxproj /path/to/Project.xcodeproj/project.pbxproj
          ```
        * If replacing entire `.xcodeproj` directory, ensure proper ownership and permissions.
    5.  **Verification:**
        * Attempt to open project in Xcode.
        * Run clean build with `xcodebuild clean build`.
        * Execute core tests to verify functionality.
    6.  **Reconciliation for Lost Changes:**
        * If recent changes were lost, review `@DEVELOPMENT_LOG.MD` and version control diffs.
        * Carefully reapply changes if needed, with testing after each change.
        * Consider using `xcodeproj` Ruby gem for programmatic changes rather than manual edits.

*   **(CRITICAL AND MANDATORY) Recovery of Missing File References:**
    1.  **Automated Detection:**
        * Run automated scanner for missing references:
          ```bash
          python3 scripts/build_fixes/remediate_missing_file_references.py --log-level debug
          ```
        * Review diagnostic output for specific issues.
    2.  **Automated Repair:**
        * Execute repair with appropriate flags:
          ```bash
          python3 scripts/build_fixes/remediate_missing_file_references.py --fix --backup
          ```
        * This will automatically correct common reference issues and create backup before changes.
    3.  **Manual Verification and Repair:**
        * If automated repair is incomplete, manually check:
          * Files exist on disk but missing from project
          * Files in project but missing from disk
          * Group structures with inconsistencies
        * Use Xcode's "Add Files to Project" for missing files rather than manual `.pbxproj` editing.
    4.  **Documentation:**
        * Document all changes in `@BUILD_FAILURES.MD` with specific error code (e.g., `PMBE-FILEREF-001`).
        * Include both automated and manual repair steps.

*   **(CRITICAL AND MANDATORY) Recovery from Workspace Corruption:**
    1.  **Workspace Integrity Check:**
        * Verify `contents.xcworkspacedata` contains valid XML and correct project references.
        * Check for workspace settings corruption in `xcuserdata` or `xcshareddata`.
    2.  **Restoration Options:**
        * Restore from backup if available.
        * Recreate workspace from project:
          ```bash
          # Create new workspace
          mkdir -p NewWorkspace.xcworkspace
          # Create contents file
          echo '<?xml version="1.0" encoding="UTF-8"?>' > NewWorkspace.xcworkspace/contents.xcworkspacedata
          echo '<Workspace version="1.0">' >> NewWorkspace.xcworkspace/contents.xcworkspacedata
          echo '   <FileRef location="group:Project.xcodeproj"></FileRef>' >> NewWorkspace.xcworkspace/contents.xcworkspacedata
          echo '</Workspace>' >> NewWorkspace.xcworkspace/contents.xcworkspacedata
          ```
        * If using XcodeGen, regenerate workspace from configuration.
    3.  **Scheme Recovery:**
        * Check for scheme files in `.xcodeproj/xcshareddata/xcschemes/`.
        * Recreate missing schemes in Xcode if needed.
        * Ensure schemes are shared if required for CI.

### 11.3. Build Restoration Workflow

*   **(CRITICAL AND MANDATORY) Full Build Restoration Protocol:**
    1.  **Initial Assessment:**
        * Identify nature of build failure (compile errors, link errors, missing dependencies).
        * Check `@BUILD_FAILURES.MD` for known issues matching symptoms.
        * Run diagnostic scripts from `scripts/diagnostics/` for relevant error category.
    2.  **Local Backup Restoration:**
        * For severe corruption or complex failures, execute full restoration:
          ```bash
          ./scripts/restore_known_working_build.sh --timestamp YYYYMMDDHHMMSS
          ```
        * This script should handle restoring project files, workspace, and configurations.
        * If no timestamp specified, use most recent backup.
    3.  **GitHub-Based Restoration:**
        * For local environment corruption or when backups are inadequate:
          ```bash
          ./scripts/github/restore_from_stable_build.sh --branch build/stable-v1.2.0
          ```
        * Verify GitHub MCP is available before restoration:
          ```bash
          ./scripts/github/verify_github_mcp.sh
          ```
        * This requires proper GitHub authentication configuration.
    4.  **Post-Restoration Validation:**
        * Clean, build, and test the restored project.
        * Verify key functionality.
        * Check for regression against known working features.

*   **(CRITICAL AND MANDATORY) Dependency Restoration:**
    1.  **Swift Package Manager:**
        * Reset and restore SPM state:
          ```bash
          rm -rf .build/
          rm -rf *.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/
          xcodebuild -resolvePackageDependencies
          ```
        * Verify Package.swift integrity and restore from backup if needed.
    2.  **Other Dependency Managers:**
        * For CocoaPods: `pod deintegrate && pod install`
        * For Carthage: `carthage clean && carthage bootstrap`

*   **(CRITICAL AND MANDATORY) Post-Restoration Protocol:**
    1.  **Documentation:**
        * Update `@BUILD_FAILURES.MD` with comprehensive details:
          * Exact symptoms and error messages
          * Restoration steps taken
          * Source of recovered files
          * Verification tests performed
        * Create `@TASKS.MD` entries for any necessary follow-up work.
    2.  **Prevention Measures:**
        * Review root cause and implement prevention:
          * New automated checks
          * Updated pre-commit hooks
          * Additional backup procedures
          * Enhanced monitoring
        * Update relevant scripts in `scripts/build_fixes/` and `scripts/diagnostics/`.
    3.  **Knowledge Management:**
        * Update `@COMMON_ERRORS.MD` with new pattern recognition.
        * Share learnings with team via documented postmortem.
        * Improve automated detection for similar issues.

### 11.4. Comprehensive Escalation and Communication Protocol

*   **(CRITICAL AND MANDATORY P0) Standardized Post-Mortem Process:**
    * EVERY build failure MUST undergo a comprehensive post-mortem process following this exact sequence:
      1. Use MCP server `memory` to recall any similar failures, past solutions, and relevant context from previous incidents.
      2. Use MCP server `sequential-thinking` to structure analysis and plan investigation approach in a logical, stepwise manner.
      3. Use MCP server `perplexity-ask` combined with web search_files to research the issue and discover industry solutions, best practices, and similar case studies.
      4. Use MCP server `context7` to retrieve the latest Apple/platform documentation relevant to the error and development environment.
      5. Document comprehensive findings in `@BUILD_FAILURES.MD` and `@AI_MODEL_STM.MD` with complete details, including exact error messages, system state, and initial hypotheses.
      6. Use MCP server `memory` to store a new plan of attack for addressing the failure for future reference and pattern identification.
      7. This sequence is MANDATORY before attempting any fixes and cannot be skipped or reordered for any reason.
    * The post-mortem documentation MUST include "Five Whys" analysis for SEVERITY 1-2 issues, trace the issue to root causes, and identify system-level improvements.
    * This step is COMPULSORY before proceeding with any resolution attempts and forms the foundation for all subsequent fix attempts.

*   **(CRITICAL AND MANDATORY P0) Programmatic Resolution Attempts:**
    * Systematically exhaust ALL programmatic ways to fix the issue before considering restoration.
    * Document each attempt, outcome, and reasoning in `@BUILD_FAILURES.MD`.
    * Continue attempts until at least 3 distinct approaches have been tried and failed.
    * Use diagnostic scripts from `scripts/diagnostics/` and fixer scripts from `scripts/fixers/`.

*   **(CRITICAL AND MANDATORY P0) GitHub Restoration Mandate:**
    * After exhausting programmatic fixes, IMMEDIATELY initiate GitHub restoration process.
    * Execute `scripts/github/restore_from_stable_build.sh [branch]` to restore from most recent stable branch.
    * This step is NOT optional and MUST be performed if programmatic fixes fail.
    * Verify GitHub MCP availability before restoration.
    * Test the restored build with a full validation cycle.

*   **(CRITICAL AND MANDATORY P0) Sandbox-Only Recovery Work:**
    * ALL restoration investigation and experimentation MUST be performed EXCLUSIVELY in the Sandbox environment.
    * NEVER allow cross-contamination between Production and Sandbox environments.
    * Folder structures MUST remain strictly separate during recovery process.
    * Apply all Sandbox file comment requirements from `.cursorrules` §5.3.1.
    * Violation of Sandbox isolation during recovery is a P0 STOP EVERYTHING violation.

*   **(CRITICAL AND MANDATORY P0) Restrictive Escalation Timing and Criteria:**
    * Escalation to user is PERMITTED ONLY if:
      * At least 5 distinct programmatic resolution approaches have been attempted and documented.
      * All GitHub restoration attempts (minimum 3 different approaches) have completely failed.
      * Data loss is evident and unrecoverable by ANY means documented in this framework.
      * The issue has persisted for more than 2 hours of continuous resolution attempts for SEVERITY 1 issues.
      * All MCP tools (memory, sequential-thinking, perplexity-ask, context7) have been exhaustively used.
    * Use SMEAC/VALIDATION REQUEST format only for true P0 escalations.
    * Include comprehensive logs, screenshots, and detailed documentation of ALL attempted solutions.
    * Reference `.cursorrules` §1.16 "Agent Autonomy and Escalation Protocol Refinement" and Core AI Agent Principles §3.5 for full escalation criteria.
    * The agent MUST independently attempt ALL available automated recovery options before escalation.

*   **(CRITICAL AND MANDATORY) Communication Requirements:**
    * Notify all impacted team members.
    * Provide regular status updates during resolution.
    * Document temporary workarounds if full resolution is delayed.
    * After resolution, conduct post-mortem and document in `@DEVELOPMENT_LOG.MD`.

### 11.5. File and Build Recovery Automation

*   **(CRITICAL AND MANDATORY) Required Recovery Automation Scripts:**
    * All projects MUST maintain the following scripts:
      * `scripts/backup/scheduled_project_backup.sh`: Automated backup creation
      * `scripts/backup/pre_change_backup.sh`: Pre-modification safety backup
      * `scripts/backup/rotate_backups.sh`: Backup rotation and cleanup
      * `scripts/restore_known_working_build.sh`: Full project restoration
      * `scripts/verify_project_integrity.sh`: Project structure validation
      * `scripts/build_fixes/remediate_missing_file_references.py`: Reference repair
      * `scripts/github/restore_from_stable_build.sh`: GitHub-based restoration
      * `scripts/diagnostics/xcode_project_validation.sh`: Project file validation
    * These scripts MUST be maintained, tested, and documented in `@SCRIPTS.MD`.
    * Integration into workflow automation is MANDATORY.

*   **(CRITICAL AND MANDATORY) Recovery Script Usage and Documentation:**
    * All recovery scripts MUST:
      * Create logs of actions taken
      * Verify success of operations
      * Create backups before making changes
      * Be well-commented and maintainable
      * Follow project scripting standards
      * Be referenced in appropriate documentation

---

*These comprehensive procedures ensure that any file corruption or build failure can be rapidly and safely remediated with minimal disruption to development workflow. The emphasis on automation, clear documentation, and preventative measures helps build resilience into the development process.*

## 5.7. MCP Server/Tool Utilization (CRITICAL AND MANDATORY)
- All build failure resolution and prevention processes MUST utilize:
    - `puppeteer` for web analysis
    - `perplexity-ask` for research
    - `momory` for information storage/recall
    - `context7` for latest documentation
    - `sequential-thinking` for planning/analysis
- These are REQUIRED for all troubleshooting, root cause analysis, and prevention planning. Violation triggers P0 STOP EVERYTHING.

## CRITICAL AND MANDATORY: Summary & Recommendation Protocol (2024-05-18 Update)

- All user-facing outputs (including SMEAC/VALIDATION REQUEST, checkpoint, and major status updates) MUST include:
  - A **Summary** section at the bottom, immediately before the **Recommendation/Next Steps** section.
  - The **Recommendation** must be clear, actionable, and mandatory.
- **Before writing the Recommendation, the AI agent MUST:**
  1. Use the `sequential-thinking` MCP server to plan the response and next steps.
  2. Use the `context7` MCP to retrieve or cross-reference any additional documentation or context required.
  3. Use the `perplexity` MCP to finalize research and ensure the recommendation is up-to-date and comprehensive.
- The SMEAC/VALIDATION REQUEST template MUST be updated to include these requirements, with the Summary and Recommendation sections at the bottom.

## 5.10. (CRITICAL AND MANDATORY) Mock/Fake Data & Integration Prohibition and Enforcement

- Mock/fake data, services, or integrations are permitted ONLY for development, testing, or sandbox environments.
- Every instance MUST be explicitly logged as technical debt in @TASKS.MD and trigger an update to @BLUEPRINT.MD, documenting the current state and plan for real integration.
- It is STRICTLY FORBIDDEN to ship any milestone (Alpha, Beta, Production, App Store, etc.) with features that use mock/fake data, services, or integrations.
- All milestone definitions MUST explicitly prohibit shipping features with mock/fake dependencies.
- Any use of mock/fake data/services/integrations MUST create subtasks for real integration and user validation, tracked to completion before release.
- This rule is compulsory and enforced at every milestone checkpoint and release process. Reference .cursorrules for full enforcement protocol.

---
*A robust framework for resolving and learning from build failures is essential for long-term project health and velocity. Strict adherence to these documentation, analysis, and prevention protocols is mandatory.*
