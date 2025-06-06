---
description: Task planning, workflow automation, dependency analysis, and enforcing that all code changes are traceable to tasks in `@TASKS.MD` and `tasks/tasks.json`.
globs: 
alwaysApply: false
---
---
description: MANDATORY When the agent is looking to work on new tasks, features; including implementation and/or planning of tasks. ALSO when iterative or automation is required (i.e. to "loop" through and do testing for example).
globs: 
alwaysApply: false
---
# Recent Lessons Learned & Continuous Improvement

- **Automated Checks & Programmatic Execution:** Always use automated scripts and programmatic tools for task management, workflow automation, and status updates before any manual intervention.
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

# 03. Task Management & Workflow Automation

## 1. Task Definition & Structure (`@TASKS.MD`)

*   **(CRITICAL AND MANDATORY) Authoritative Source:** `@TASKS.MD` (or the project-defined task tracking system, e.g., `tasks.json` managed by `taskmaster-ai`) is the authoritative source for all development tasks, their status, and workflow.
*   **(CRITICAL AND MANDATORY) Standard Task Format:** All tasks and sub-tasks **MUST** adhere to a standard format, including the following fields (refer to `@taskmaster_dev_workflow.md` or the Task Master documentation for full schema):
    *   `id`: Unique hierarchical identifier (e.g., `1`, `1.1`, `1.1.1`).
    *   `title`: Clear, concise title.
    *   `description`: Brief summary of the task.
    *   `status`: Current status (e.g., `pending`, `in-progress`, `done`, `blocked`, `deferred`).
    *   `priority`: Priority level (e.g., `P0`, `P1`, `P2`, `P3`, `P4`, or `high`, `medium`, `low`).
    *   `dependencies`: Array of task IDs that must be completed first.
    *   `details` (or `Comments/Notes`): **(CRITICAL)** Comprehensive notes, including:
        *   **Feature Goal:** Clear user-facing objective or technical goal, linking to `@BLUEPRINT.MD` if applicable.
        *   **API Relationships/Integrations:** Relevant internal/external services or APIs.
        *   **Detailed Feature Requirements:** Specific, measurable acceptance criteria. What defines "Done"?
        *   **Detailed Implementation Guide:** High-level plan, key classes/functions/files, algorithms, UI components, potential challenges. This section **MUST** be updated iteratively as implementation progresses (see Iterative Subtask Implementation in `@taskmaster_dev_workflow.md`).
    *   `testStrategy`: Specific approach for verifying task completion and correctness.
    *   `subtasks`: Array of sub-task objects following the same structure.
*   **(CRITICAL AND MANDATORY) Nodal Numbering:** Use nodal numbering for task IDs (e.g., Task `1`, Sub-task `1.1`, Sub-sub-task `1.1.1`) to clearly represent hierarchy.
*   **(CRITICAL AND MANDATORY) Task-Driven Code Change Enforcement:**
    - No code file (e.g., .swift, .js, .ts, etc.) may be edited, created, or deleted unless a corresponding actionable task exists in both @TASKS.MD and tasks/tasks.json, and the change is fully traceable to that task (task ID in code comments, commits, docs). See .cursorrules Section 4.0.
    - Any violation is a CRITICAL PROTOCOL BREACH: halt, log, escalate, and self-correct per .cursorrules Section 4.0.

## 2. Granular Task Breakdown & Complexity

*   **(CRITICAL AND MANDATORY) Mandatory Breakdown to Level 5-6:**
    *   Before starting implementation on any task from `@BLUEPRINT.MD` or any high-level task in `@TASKS.MD` (Level < 4), it **MUST** be broken down into **Level 5-6 sub-tasks** (e.g., `1.1.1.1.1` or `1.1.1.1.1.1`).
    *   This means a task should typically have 4 to 5 levels of sub-tasks beneath its initial high-level definition.
    *   The AI Agent **MUST ONLY WORK ON TASKS THAT ARE LEVEL 4 OR GREATER.** If the selected task is Level 1-3, the immediate next step is to break it down.
    *   Use `taskmaster-ai` `expand_task` tool/command or `sequential-thinking` MCP for this breakdown.
*   **(CRITICAL AND MANDATORY) Detailed Sub-Task Documentation:**
    *   For each task and sub-task (especially newly created ones), `@TASKS.MD` (or the associated task file/entry in the task system) **MUST** be updated using `filesystem` MCP `Edit` (or `taskmaster-ai` `update_subtask` / `update_task`) to include the **detailed documentation** in the `details` (or `Comments/Notes`) section as specified in section 1 above.
*   **(CRITICAL AND MANDATORY) Task Complexity Analysis:**
    *   Before extensive breakdown, especially for epics or large features, perform a task complexity analysis (e.g., using `taskmaster-ai` `analyze_complexity` tool/command).
    *   Review the complexity report to guide the breakdown process, ensuring more complex parts receive finer granularity.

## 3. Task Prioritization

*   **(CRITICAL AND MANDATORY) Strict Prioritization Order:** Tasks **MUST** be selected and worked on according to the following strict order of priority:
    1.  **P0: Build Failures & Critical System Stability:** Any issues documented in `@BUILD_FAILURES.MD` that prevent a clean build, successful test run, or cause critical system instability. This includes restoring the application to its last known working state (see `@04_Build_Integrity_Xcode_And_SweetPad_Management.md`).
    2.  **P1: Critical Bugs:** Bugs documented in `@BUGS.MD` that severely impact application functionality or user experience, and are blocking progress towards the next milestone.
    3.  **P2: Milestone-Critical Tasks:** Tasks from `@TASKS.MD` that are essential for reaching the next major project milestone (Alpha, Beta, Production) as defined in `@BLUEPRINT.MD`.
    4.  **P3: Technical Debt Affecting Milestones:** Addressing documented technical debt from `@TECH_DEBT_LOG.MD` that poses a direct risk to achieving the next milestone.
    5.  **P4: Other Bugs & Technical Debt:** Remaining bugs and technical debt.
    6.  **P5: Product Feature Inbox / New Features:** Implementing new features or enhancements from the prioritized backlog in `@BLUEPRINT.MD` (see Section 4).
*   **(CRITICAL AND MANDATORY) Dependency First:** Within a priority level, tasks with all dependencies met **MUST** be addressed before tasks with pending dependencies.
*   **(CRITICAL AND MANDATORY) Task ID as Tie-Breaker:** If multiple tasks have the same priority and all dependencies met, address them in ascending order of their Task ID.
*   **(CRITICAL AND MANDATORY) Consult Taskmaster for Next Task:** Always use the `taskmaster-ai` `next_task` tool/command (or equivalent logic) to determine the next task to ensure adherence to these prioritization rules.

## 4. Feature Inbox Management (`@BLUEPRINT.MD`)

*   **(CRITICAL AND MANDATORY) Routine Inbox Review:** At the beginning of every major interaction, work session, or development cycle, the AI Agent **MUST**:
    1.  **Check Feature Inbox:** Review the 'Product Feature Inbox' section within `@BLUEPRINT.MD`.
    2.  **Triage All Items:** Programmatically process each item in the inbox:
        *   **Accepted Features:** Use `taskmaster-ai` `add_task` (or equivalent) to convert accepted features into new high-level tasks in `@TASKS.MD`. These tasks will then be subject to breakdown (Section 2).
        *   **Rejected Features:** Clearly mark features as 'Rejected' within `@BLUEPRINT.MD` with a brief justification comment.
        *   **Processed Items:** Remove or mark items as 'Processed' in `@BLUEPRINT.MD` once triaged into `@TASKS.MD` or rejected.
    3.  **Log Triage Actions:** Document all triage decisions (acceptance, rejection, new task IDs created) in `@DEVELOPMENT_LOG.MD`.
    4.  **Sync with Taskmaster System:** Ensure any newly created tasks in `@TASKS.MD` are properly integrated into the overall task management system (e.g., regenerating task files if using `taskmaster-ai`).

## 5. Workflow Automation & AUTO ITERATE Mode

*   **(CRITICAL AND MANDATORY) AUTO ITERATE Mode Operation:** The AI Agent **MUST** operate in an "AUTO ITERATE" mode as its default for task execution.
    1.  **Acknowledge & Plan:** Load context (including relevant sections from `@XCODE_STYLE_GUIDE.MD` if UI-related).
    2.  **Select Goalpost & Assess/Plan/Research:**
        *   Select **ONE** sub-task from `@TASKS.MD` (Must be Level 4+). Verify Prerequisites.
        *   Perform Directory Cleanliness Check (as per `@08_Documentation_Directory_And_Configuration_Management.md`).
        *   **IF Task < Level 4, IMMEDIATE NEXT STEP IS TO BREAK IT DOWN** using `taskmaster-ai expand_task` or `sequential-thinking`, update `@TASKS.MD` with detailed notes for each new sub-task, THEN re-select a Level 4+ sub-task.
    3.  **Operate Loop (Implement -> Doc -> Build Verify -> UI/UX Verify -> Log -> Analyze -> Fix/Test -> Repeat):**
        *   (a) **Implement Increment:** Perform the coding or action for the sub-task, adhering to TDD principles.
        *   (b) **Self-Review:** Review code logic, compliance with `@XCODE_STYLE_GUIDE.MD` (if applicable), and other standards.
        *   (c) **Mandatory Docs Update:** Update `@TASKS.MD` (with detailed iterative notes for the sub-task), `@DEVELOPMENT_LOG.MD`, `@AI_MODEL_STM.MD`, `@TASK_<ID>_EXECUTION_LOG.MD`. Update `@BUILD_FAILURES.MD` or `@BUGS.MD` if issues are found/fixed.
        *   (d) **Build VERIFICATION:** Perform build verification as per `@04_Build_Integrity_Xcode_And_SweetPad_Management.md` (e.g., SweetPad Compatible).
        *   (e) **Log & Analyze Build Output:** Record build outputs, especially errors.
        *   (f) **Handle Build Outcome:**
            *   **If FAIL:** PRIORITY 0. **CONSULT KBs (`@BUILD_FAILURES.MD`, `@COMMON_ERRORS.MD`) FIRST.** Then, attempt to FIX BUILD (loop to 5.3.d). Log all attempts and outcomes in detail.
            *   **If PASS:** Proceed to 5.3.g.
        *   (g) **Functional/Other Testing:** Execute relevant tests (unit, integration, UI, etc.) as per `@06_Testing_Strategy_And_Quality_Assurance.md`. If any test FAIL -> treat as bug, log it, and loop to fix (similar to build failure).
    4.  **Goalpost Completion Check:** Verify that all acceptance criteria for the sub-task are met.
    5.  **Report & Request Validation (Checkpoint):** PAUSE. Perform Directory Cleanliness Check. Use the structured `VALIDATION REQUEST / CHECKPOINT` format as defined in `@01_Core_AI_Agent_Principles.md`.

## 6. Implementation Drift Handling

*   **(CRITICAL AND MANDATORY) Address Deviations Systematically:** When the actual implementation of a task or sub-task deviates significantly from the original plan (due to new discoveries, unforeseen complexities, or changed requirements):
    1.  **Log the Drift:** Document the deviation, the reasons for it, and its impact in the `details` section of the current task/sub-task in `@TASKS.MD` and in `@DEVELOPMENT_LOG.MD`.
    2.  **Update Current Task:** Modify the `description`, `details`, and `testStrategy` of the current task/sub-task to reflect the new reality.
    3.  **Assess Impact on Future Tasks:** Identify any dependent or related future tasks in `@TASKS.MD` that are affected by this drift.
    4.  **Update Affected Future Tasks:**
        *   For multiple future tasks: Use `taskmaster-ai update --from=<future_task_id_to_start_updates_from> --prompt="<explanation_of_drift_and_cascading_impact>"`.
        *   For a single future task: Use `taskmaster-ai update-task --id=<specific_future_task_id> --prompt="<explanation_of_drift_and_impact_on_this_task>"`.
        *   The prompt **MUST** clearly explain the nature of the drift from the preceding task and how it necessitates changes to the current task's scope, requirements, or approach.
    5.  **Re-Validate Dependencies:** Ensure the dependency chain in `@TASKS.MD` remains logical and correct after these updates.

## 7. Task Status Management

*   **(CRITICAL AND MANDATORY) Immediate Status Updates:** Task statuses in `@TASKS.MD` (or the task management system) **MUST** be updated immediately upon a change in state.
*   **Standard Statuses:**
    *   `pending`: Ready to be worked on, dependencies met.
    *   `in-progress`: Actively being worked on.
    *   `done`: Completed, verified, meets all acceptance criteria.
    *   `blocked`: Cannot proceed due to an impediment (blocker **MUST** be documented).
    *   `deferred`: Postponed, not currently planned for active work.
*   **(CRITICAL AND MANDATORY) Update via Tools:** Use `taskmaster-ai set_task_status` tool/command for all status changes to ensure consistency and trigger any associated automation (like task file regeneration).

## 8. Sequential Thinking & Branching Strategy

*   **(CRITICAL AND MANDATORY) Sequential Thinking Approach:**
    *   Use the `sequential thinking` MCP for all assessments, planning, and task breakdowns.
    *   Apply structured thinking patterns to break down complex problems into logical, sequential steps.
    *   Document the thinking process in `@AI_MODEL_STM.MD` and task-specific execution logs.

*   **(CRITICAL AND MANDATORY) Branching Strategy & Git Workflow:**
    *   Never commit directly to `master`/`main` except for completed, tested, milestone Level 3 features.
    *   Level 4-6 tasks must be developed on their own feature/fix branches, merged to their parent Level 3 branch only after passing all tests.
    *   Level 3 branches are merged to `main` only after all subtasks are complete and the build is stable.
    *   Always use a dedicated branch for build-stable checkpoints (e.g., `build/stable-YYYYMMDD`).
    *   Name branches according to this pattern: `<type>/<task-id>-<short-description>` (e.g., `feature/1.2.3-user-authentication`).

*   **(CRITICAL AND MANDATORY) GitHub Backup & Documentation:**
    *   After every successful build (all tests pass), commit and push to GitHub using the MCP.
    *   Include a detailed commit message referencing the build, what was fixed/added, and the current version.
    *   Update `@DEVELOPMENT_LOG.MD` and `@BUILD_FAILURES.MD` with every major change, restoration, or fix.
    *   If a build becomes broken to a state where it is not able to be rebuilt, then as a last resort restore to the last working master branch commit (ensuring the user accepts).
    *   Maintain a continuous GitHub backup policy to ensure no work is lost and recovery points are available.

## 9. Feature-First Development Approach

*   **(CRITICAL AND MANDATORY) Big Ticket Features Focus:**
    *   Always prioritize the implementation of "big ticket" features that deliver clear user value, as defined in `@BLUEPRINT.MD` and `@TASKS.MD`.
    *   Focus on features that are visible, interactive, and demonstrate modern best practices.
    *   Ensure every feature is integrated into the main app entry view and is testable by users.
    *   Polished features over quantity: Deliver fewer, higher-quality features that users can see and use, rather than many half-finished or backend-only changes.

*   **(CRITICAL AND MANDATORY) Creativity and Design Flair:**
    *   Always use best practice UX/UI concepts (padding, dynamic sizing, beautiful transitions, dark/light mode, rounded buttons, etc.)
    *   **The Principle of Living Interfaces:** Animate with purpose. Every motion, transition, and microinteraction should either inform the user or enhance the experience. Strive for UI elements that feel responsive and alive.
    *   **Weave a Haptic Tapestry:** Design a consistent and meaningful haptic language that confirms actions, provides texture to interactions, and adds a layer of satisfying, tactile feedback.
    *   **Embrace the Chameleon's Grace:** Create interfaces that subtly adapt based on context like time of day, user's current task focus, or the nature of the content being displayed.
    *   **Maintain the Narrative Thread:** Ensure every pixel and interaction tells the app's unique story. Every choice—from color palette to typography to animations—should consistently reinforce the app's core brand and purpose.
    *   **Engineer Serendipity & Joyful Detours:** Incorporate small, discoverable elements or interactions that add moments of surprise, playfulness, and joy to reward curiosity.

*   **(CRITICAL AND MANDATORY) Modern UI/UX Standards:**
    *   All UI/UX must follow `@XCODE_STYLE_GUIDE.MD` or the equivalent platform-specific style guide.
    *   Always refactor key entry points (e.g., `MainContentView.swift`) to integrate new features and maintain a modern, polished UX.
    *   Use semantic colors, dynamic type, accessibility labels, and responsive layouts.
    *   Refactor legacy or non-compliant UI as part of feature delivery.
    *   Every new feature should feel "production-ready"—no rough edges, placeholder UIs, or half-finished flows.
    *   Accessibility is non-optional: Every interactive element must be accessible with proper labels and support for assistive technologies.

## 10. Development Workflow Checklist

*   **(CRITICAL AND MANDATORY) Before Starting Any Feature:**
    *   Confirm the build is green and all tests pass.
    *   Review `@BUILD_FAILURES.MD` for recent issues and prevention strategies.
    *   Select the next prioritized feature from `@TASKS.MD` that is user-facing and high-impact.
    *   Break down the feature into granular, testable subtasks (Level 5-6).

*   **(CRITICAL AND MANDATORY) During Implementation:**
    *   Write failing or non-destructive tests for each subtask.
    *   Implement only the code needed to pass the tests.
    *   Refactor for clarity, maintainability, and UI/UX polish.
    *   Integrate the feature into the main app entry view for immediate visibility.

*   **(CRITICAL AND MANDATORY) After Each Change:**
    *   Run the full build and test suite.
    *   If any failure occurs:
        *   Halt feature work.
        *   Document the failure in `@BUILD_FAILURES.MD` using the required template.
        *   Apply or update diagnostic scripts as needed.
        *   Restore build stability before resuming feature work.

*   **(CRITICAL AND MANDATORY) Before Marking a Task as Done:**
    *   Ensure the feature is visible, interactive, and polished in the main app.
    *   Confirm all UI/UX requirements are met (semantic colors, accessibility, dynamic type).
    *   Update `@TASKS.MD` and `@DEVELOPMENT_LOG.MD` with detailed notes and rationale.
    *   Propose a commit with a descriptive message referencing the feature, build/test status, and documentation updates.
    *   Ensure the version number is updated in all relevant locations (e.g., `MainContentView.swift`).

#### Enhanced Protocol for Vague or Screenshot-Based Feedback (Cross-Reference)
- For any Product Feature Inbox item or user feedback that is vague, emotional, or primarily screenshot-based (e.g., "THIS LOOKS HORRENDOUS, WE NEED TO FIX THIS"), the enhanced protocol in `.cursorrules` MUST be followed:
    - Use `sequential-thinking` MCP for structured planning and clarification.
    - Draw inspiration from `docs/ExampleCode/` and the Corporate Style Guide.
    - Use `perplexity` MCP for research, cross-referencing with `@BLUEPRINT.md` and the Style Guide.
    - Synthesize a cohesive, standards-aligned plan before any code change.
    - Escalate for user clarification if ambiguity remains.
    - **No code changes may be made until this protocol is fully completed and documented.**
- All actions and rationale must be logged for auditability.

- If vague or screenshot-based feedback is encountered, IMMEDIATELY trigger the enhanced protocol as defined above and in `.cursorrules`.

## CRITICAL AND MANDATORY: Summary & Recommendation Protocol (2024-05-18 Update)

- All user-facing outputs (including SMEAC/VALIDATION REQUEST, checkpoint, and major status updates) MUST include:
  - A **Summary** section at the bottom, immediately before the **Recommendation/Next Steps** section.
  - The **Recommendation** must be clear, actionable, and mandatory.
- **Before writing the Recommendation, the AI agent MUST:**
  1. Use the `sequential-thinking` MCP server to plan the response and next steps.
  2. Use the `context7` MCP to retrieve or cross-reference any additional documentation or context required.
  3. Use the `perplexity` MCP to finalize research and ensure the recommendation is up-to-date and comprehensive.
- The SMEAC/VALIDATION REQUEST template MUST be updated to include these requirements, with the Summary and Recommendation sections at the bottom.

## 3.8. MCP Server/Tool Utilization (CRITICAL AND MANDATORY)
- All task management and workflow automation MUST utilize:
    - `puppeteer` for web analysis
    - `perplexity-ask` for research
    - `momory` for information storage/recall
    - `context7` for latest documentation
    - `sequential-thinking` for planning/analysis
- These are REQUIRED for all task planning, execution, and review. Violation triggers P0 STOP EVERYTHING.

## 3.9. (CRITICAL AND MANDATORY) Mock/Fake Data & Integration Prohibition and Enforcement

- Mock/fake data, services, or integrations are permitted ONLY for development, testing, or sandbox environments.
- Every instance MUST be explicitly logged as technical debt in @TASKS.MD and trigger an update to @BLUEPRINT.MD, documenting the current state and plan for real integration.
- It is STRICTLY FORBIDDEN to ship any milestone (Alpha, Beta, Production, App Store, etc.) with features that use mock/fake data, services, or integrations.
- All milestone definitions MUST explicitly prohibit shipping features with mock/fake dependencies.
- Any use of mock/fake data/services/integrations MUST create subtasks for real integration and user validation, tracked to completion before release.
- This rule is compulsory and enforced at every milestone checkpoint and release process. Reference .cursorrules for full enforcement protocol.

# 11. Product Feature Intake, Triage, and Workflow Protocol (CRITICAL AND MANDATORY)

## 11.1 Purpose

To ensure **all new product features, user feedback, and requirements changes**—regardless of source (Product Feature Inbox, User Feedback, direct User prompts, or Blueprint updates)—are processed through a **single, auditable, and standards-compliant workflow**. This guarantees traceability, prioritization, and alignment with project goals and technical governance.

---

## 11.2 Canonical Workflow (CRITICAL AND MANDATORY)

### 11.2.1 Intake & Initial Capture (CRITICAL AND MANDATORY)
- **All new feature ideas, feedback, or requirements changes** MUST be captured in a canonical intake location:
    - `docs/PRODUCT_FEATURE_INBOX.MD` for features/ideas.
    - `docs/USER_FEEDBACK.MD` for user/customer feedback.
    - Direct prompts from the User or changes to `docs/BLUEPRINT.MD` MUST be logged in the appropriate intake doc and referenced in `DEVELOPMENT_LOG.MD`.
- **NO feature, feedback, or requirements change may be worked on unless it is first logged in the intake system.**

### 11.2.2 Identification & Triage (CRITICAL AND MANDATORY)
- **Programmatically triage** each new item to determine if it:
    - Fits an existing task (feature, bug, tech debt, enhancement).
    - Is a new, distinct task.
    - Is technical debt or a bug (log in `TASKS.MD` and/or `BUGS.MD` as appropriate).
- **Triage MUST be performed using:**
    - Automated tools (preferably `taskmaster-ai` for task matching/creation).
    - LLM-based analysis for wording, categorization, and initial prioritization.
    - Reference to current `TASKS.MD`, `tasks/tasks.json`, and `BLUEPRINT.MD`.
- **NO code, design, or documentation work may begin until triage is complete and the item is properly categorized.**

### 11.2.3 Task Creation & Documentation (CRITICAL AND MANDATORY)
- **For new or updated tasks:**
    - Add a **rough outline and description** to `TASKS.MD` (and `tasks/tasks.json`), referencing the intake source and rationale.
    - Ensure the task is worded clearly, with sufficient context for downstream automation and review.
    - If the item fits an existing task, update the task's description, comments, or status as needed.
- **All new or updated tasks MUST be traceable to their intake source.**

### 11.2.4 Automated Breakdown & Detailing (CRITICAL AND MANDATORY)
- **All new tasks MUST be:**
    - **Broken down to Level 5-6 granularity** (where possible) using `taskmaster-ai` tools.
    - Supplemented with detail from:
        - `perplexity-ask` (for research, best practices, and competitive analysis).
        - `web-search_files` (for up-to-date external context).
        - `context7` MCP server (for latest project documentation and context).
    - The breakdown and research results MUST be appended to the task entry in `TASKS.MD` and `tasks/tasks.json`.
- **NO implementation work may begin until breakdown and detailing are complete.**

### 11.2.5 Traceability & Logging (CRITICAL AND MANDATORY)
- **All actions, decisions, and tool invocations** MUST be logged in `DEVELOPMENT_LOG.MD` and, where appropriate, in `AI_MODEL_STM.MD` and `TASK_<ID>_EXECUTION_LOG.MD`.
- **Every feature or feedback item MUST be traceable** from intake through to task creation, breakdown, and implementation.
- **Failure to log or trace any item is a protocol breach and MUST be escalated and documented.**

### 11.2.6 Continuous Review & Feedback Loop (CRITICAL AND MANDATORY)
- **Regularly review** the Product Feature Inbox and User Feedback docs for untriaged or stale items.
- **Update or escalate** as needed, ensuring no item is left unprocessed or unprioritized.
- **Automated scripts or MCP tools MUST be used to check for untriaged items at the start of every major work session.**

---

## 11.3 Compliance & Enforcement (CRITICAL AND MANDATORY)

- **All steps in this protocol are enforceable and auditable.**
- **Automated compliance checks** (scripts, MCP tools) MUST be run before any feature/feedback work begins, and at regular intervals, to ensure:
    - All new items are logged, triaged, and broken down.
    - No work is performed on unlogged or untriaged items.
    - All actions and decisions are logged in canonical locations.
- **Violations of this protocol are CRITICAL PROTOCOL BREACHES:**
    - Must be logged in `DEVELOPMENT_LOG.MD` and, if related to a build or release, in `BUILD_FAILURES.MD`.
    - Must be escalated to the project lead or responsible party.
    - Repeated or willful violations may result in restricted commit access or other enforcement actions as defined in `.cursorrules`.
- **Reference:** See `.cursorrules` Section 4.0 and @01_Core_AI_Agent_Principles.md for enforcement and escalation procedures.

---

## 11.4 Alignment with Existing Protocols

This workflow is **fully aligned** with all referenced project rules and protocols. **No conflicts** are present; this section formalizes and enforces the intake-to-task workflow, ensuring all new product features and feedback are processed in a compliant, programmatic, and auditable manner.

---
*Effective task management and workflow automation are foundational to project success. Strict adherence to these protocols is mandatory.*
