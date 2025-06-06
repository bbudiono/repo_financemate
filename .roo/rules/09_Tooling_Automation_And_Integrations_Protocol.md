---
description: Selecting and using the correct tools for builds, file operations, diagnostics, and integrations—ensures all actions are automated and logged before manual intervention.
globs: 
alwaysApply: false
---
---
description: 
globs: 
alwaysApply: true
---
# 09. Tooling, Automation & Integrations Protocol

## 1. Programmatic Execution & Automation First

*   **(CRITICAL AND MANDATORY) Programmatic Execution as Standard:**
    *   ALL diagnosis, file manipulation, dependency checks, build processes, test execution, code fixing, and documentation updates **MUST** be performed programmatically using defined tools (MCP Group tools, project scripts, direct `Bash` commands) whenever feasible.
    *   This principle minimizes manual errors, ensures reproducibility, and enables automation.
*   **(CRITICAL AND MANDATORY) Automation & Iterative Issue Resolution Rule:**
    *   All issue resolution and project operations **MUST** be attempted programmatically first.
    *   **AUTO-ITERATE on Issues:**
        1.  Attempt programmatic fix (using tools/scripts from the hierarchy in Section 2).
        2.  If unsuccessful, log the attempt (tool, command, parameters, error output) in `@DEVELOPMENT_LOG.MD` and `@BUILD_FAILURES.MD` (if applicable), and escalate to the next automated method in the hierarchy.
        3.  Only after all documented automated solutions fail (and these failures are logged), may manual user intervention be considered. Such instances **MUST** be treated as P0 issues for future automation improvement.
    *   Failed automation attempts **MUST** be logged in `@BUILD_FAILURES.MD`. Update `@TASKS.MD` and `@DEVELOPMENT_LOG.MD` accordingly.
*   **(CRITICAL AND MANDATORY) Continuous Improvement of Automation:**
    *   Document new automation scripts in `@SCRIPTS.MD` and `@README.MD` or `@BUILDING.MD`.
    *   Propose new tasks in `@TASKS.MD` to automate recurring manual steps or to improve existing automation scripts.

## 2. Troubleshooting & Operational Tooling Priority Hierarchy

*   **(CRITICAL AND MANDATORY) Hierarchical Approach to Tool Selection:** When performing any operational task (including troubleshooting, implementation, file manipulation, builds, tests), AI Agents and developers **MUST** STRICTLY follow this priority order of tools:
    1.  **PRIMARY: MCP Servers (Master Control Program Tools)**
        *   Always attempt to use appropriate MCP Group tools first (e.g., `XcodeBuildMCP` for Xcode tasks, `filesystem` MCP for file operations, `taskmaster-ai` MCP tools for task management, `ios-simulator` MCP, `github` MCP).
        *   Log detailed outputs and return codes from MCP tool calls in `@DEVELOPMENT_LOG.MD` and task-specific execution logs (`@TASK_<ID>_EXECUTION_LOG.MD`).
    2.  **SECONDARY: Project Scripts (`@scripts/` directory)**
        *   If the relevant MCP server functionality is unavailable, fails, or is insufficient, fall back to using established project scripts located in the `@scripts/` directory (or platform-specific script directories like `@_macOS/scripts/`).
        *   These scripts should be cataloged and documented in `@SCRIPTS.MD`.
        *   Document the specific MCP failure mode that led to this fallback.
    3.  **TERTIARY: Direct Terminal/Bash Commands**
        *   If both MCP Group tools and existing project scripts are inadequate, direct terminal commands (e.g., `Bash`, `Zsh`, `Python` or `Ruby` one-liners if appropriate for the task and safer than direct shell manipulation for complex parsing/editing) may be used.
        *   Use with caution, ensuring commands are precise and well-understood. Validate paths and operations carefully.
    4.  **QUATERNARY: Alternative Tools/APIs (Requires Justification)**
        *   Only if all above options fail or are demonstrably unsuitable, consider alternative well-vetted command-line tools or direct API interactions (e.g., with cloud services).
        *   This choice **MUST** be justified and documented extensively in `@DEVELOPMENT_LOG.MD` and, if related to a failure, in `@BUILD_FAILURES.MD`.
    5.  **LAST RESORT: Manual Steps (Requires Escalation & Documentation)**
        *   Manual intervention (requiring user action in a GUI or complex unscripted CLI sequence) should ONLY be suggested after ALL automated approaches have been exhausted, documented as failed, and the reasons analyzed.
        *   Treat any necessary manual step as a P0 priority for future automation. A task **MUST** be created in `@TASKS.MD` to automate this manual process.
*   **(CRITICAL AND MANDATORY) Failure Documentation at Each Tier:**
    *   When any tool or approach fails, **BEFORE** moving to the next tier in the hierarchy:
        1.  Capture the exact command/tool used, parameters, and full error output.
        2.  Document this failure with a timestamp and context in `@DEVELOPMENT_LOG.MD` (and `@BUILD_FAILURES.MD` if it's a build-related failure), creating a structured entry like: "Tried [Tool/Command from Tier X], Failed because [Reason/Error], Moving to [Tool/Approach from Tier Y]".
        3.  For recurring failures of higher-tier tools, update `@BUILD_FAILURES.MD` or `@COMMON_ERRORS.MD` with observed patterns and attempted resolutions.
*   **(CRITICAL AND MANDATORY) Testing & Validation with Fallback Tools:**
    *   When using a lower-tier tool after a higher-tier failure, validate that:
        *   The issue is genuinely with the higher-tier tool/its current capability and not with incorrect parameters or usage patterns.
        *   The fallback tool uses identical or logically equivalent parameters/inputs where possible.
        *   The success or failure of the fallback approach is explicitly documented. Successful resolutions **SHOULD** trigger appropriate follow-up actions (e.g., commit via GitHub MCP if a build is fixed).
        *   A comparison of output or behavior between tool tiers is captured if it provides useful diagnostic information.
*   **(CRITICAL AND MANDATORY) Documentation for Future Automation:**
    *   Ensure all successful manual interventions (Last Resort) are documented in sufficient detail in `@DEVELOPMENT_LOG.MD` and the relevant task to allow for their future automation.
    *   Explicitly create scripting tasks in `@TASKS.MD` for any recurring manual processes or to enhance higher-tier tool capabilities based on lower-tier successes.

## 3. MCP Server Usage Protocols (Master Control Program)

*   **(CRITICAL AND MANDATORY) MCP as Primary Interface:** For AI agents and integrated tools, MCP Group tools **MUST** be the primary method of interacting with project functionalities (build system, file system, task management, etc.).
*   **(CRITICAL AND MANDATORY) Filesystem MCP:** All direct file system operations (Read, Write, Edit, List Directory, Glob, Grep, Move, Remove - with caution, Make Directory) **MUST** use the `filesystem` MCP server tools.
*   **(CRITICAL AND MANDATORY) XcodeBuildMCP:** The `XcodeBuildMCP` server **MUST** be the primary tool for all Xcode project operations (build, clean, run, test, list schemes/simulators, get build settings, get app paths, simulator management, log retrieval).
*   **(CRITICAL AND MANDATORY) Taskmaster-AI MCP:** For managing tasks (listing, adding, updating, expanding, getting next task, etc.), the `taskmaster-ai` MCP tools **MUST** be used by AI agents.
*   **(CRITICAL AND MANDATORY) GitHub MCP:** For version control operations like committing, pushing, branching, and potentially PR creation, the `github` MCP tools **SHOULD** be preferred by AI agents if available and functional.
*   **(CRITICAL AND MANDATORY) Tool Invocation and Logging:** All MCP tool calls, including parameters and full JSON responses (or summaries if excessively verbose), **MUST** be logged in `@DEVELOPMENT_LOG.MD` and the relevant `@TASK_<ID>_EXECUTION_LOG.MD`.
*   **(CRITICAL AND MANDATORY) Error Handling for MCP Calls:** Properly handle potential errors from MCP tool calls. Retry mechanisms can be implemented for transient issues, but persistent failures **MUST** be escalated according to the Tooling Priority Hierarchy (Section 2).
*   **(CRITICAL AND MANDATORY) Server Restart on Logic Changes:** If core logic in `scripts/modules/` (which might underpin MCP tools) or any MCP tool definitions themselves are modified, the MCP server(s) **MUST** be restarted to reflect these changes.

## 4. CLI (Command Line Interface) Tool Usage

*   **(GUIDELINE) CLI for User Interaction & Fallback:** The global `task-master` CLI (and other project-specific CLIs) are primarily for direct user interaction via the terminal or as a fallback if MCP server functionality is unavailable or insufficient for a specific, well-understood operation.
*   **(GUIDELINE) Consistency with MCP Tools:** CLI commands often mirror MCP tools (e.g., `task-master list` vs. `taskmaster-ai get_tasks` MCP tool). Prefer MCP tools for programmatic/agent use due to structured I/O.
*   **(CAUTION) Parsing CLI Output:** If using CLI output programmatically (e.g., an AI agent parsing `task-master list` output), be aware that CLI output formatting can change and may be less stable for parsing than structured MCP responses (JSON).

## 5. Patching Tool Selection Protocol (File Modifications)

*This consolidates rules from `cursor_rules.md` and general best practices.*

*   **(CRITICAL AND MANDATORY) Prioritize Safety and Structure Awareness:** When programmatically modifying files, especially complex structured files like Xcode project files, safety and awareness of the file's structure are paramount.
*   **(CRITICAL AND MANDATORY) Order of Preference for Patching/Editing Tools:**
    1.  **Prescribed Project Scripts/Tools:** Always first attempt to use any specific script or tool explicitly documented for the modification task in project guides (e.g., a dedicated script in `@scripts/utils/` for updating a specific configuration value, or an MCP tool designed for the purpose).
    2.  **Structure-Aware Libraries (via Scripting Languages):**
        *   **For `.xcodeproj` / `project.pbxproj` files:** **PRIMARILY USE** Ruby scripts leveraging the `xcodeproj` gem. This library understands the project file structure and significantly reduces the risk of corruption. Python scripts using `pbxproj` library are a viable alternative.
        *   **For `Info.plist` or other `.plist` files:** Use Python with `plistlib`, Ruby with `cfpropertylist`, or `PlistBuddy` via shell script.
        *   **For JSON files:** Use Python with `json` module, Ruby with `JSON`, `jq` via shell script.
        *   **For YAML files:** Use Python with `PyYAML`, Ruby with `yaml`.
        *   **For XML files (other than plists):** Use Python with `xml.etree.ElementTree`, Ruby with `REXML` or `Nokogiri`.
    3.  **High-Level Text Processing Tools (Use with Caution for Structured Files):**
        *   `sed` or `awk` via shell script can be used for simple, well-defined line-based changes in plain text files or build scripts. **AVOID** using them for complex structured files like `project.pbxproj` unless the pattern is extremely simple and thoroughly tested due to high risk of corruption.
    4.  **Direct File I/O in Scripting Languages (Python, Ruby):** For custom text processing not covered by standard libraries, direct file reading/writing in Python or Ruby is acceptable, but structure-awareness is lost unless implemented carefully.
    5.  **`filesystem` MCP `EditFile` Tool:** The generic `EditFile` tool (if it performs simple line replacement or content append/prepend) should be used cautiously for structured files. Prefer structure-aware tools where available. If `EditFile` is used, the instructions must be extremely precise and changes verified meticulously.
*   **(CRITICAL AND MANDATORY) NO Plain Text Search-and-Replace on Xcode Project Files:** **STRICTLY AVOID** using generic plain text search_files-and-replace operations (e.g., simple string replacement in Python without understanding the pbxproj structure, or naive `sed` commands) directly on `.xcodeproj` or `project.pbxproj` files. This is highly prone to corruption.
*   **(CRITICAL AND MANDATORY) Verification After Patching:** After any programmatic modification of a critical file (especially project files), verify its integrity: 
    *   For Xcode projects, attempt a build (see `@04_Build_Integrity_Xcode_And_SweetPad_Management.md`).
    *   For configuration files, ensure the application can load and parse them correctly.
*   **(CRITICAL AND MANDATORY) Logging Tool Usage:** All tool invocations for patching/editing, script executions, parameters used, and their outcomes (success or failure, summary of changes made) **MUST** be meticulously documented in `@DEVELOPMENT_LOG.MD` and relevant task logs.

## 6. Specific Integration Protocols (Example: OpenAI Agents SDK)

*This section outlines a template for integrating specific, complex SDKs or third-party services. The OpenAI Agents SDK is used as an example. Similar detailed protocols should be developed for other key integrations.*

### 6.1. OpenAI Agents SDK Integration Protocol (Derived from `@PROJECT_RULES_NATIVE_APP_V3_8.md` Section 16)

*   **(CRITICAL AND MANDATORY) Consult Reference Documentation:** Before and during implementation, AI Agents and developers **MUST** consult the project-specific OpenAI Agents SDK reference documents:
    *   Core Docs: `@docs/integrations/OPENAI_AGENTS_SDK.MD`, `OPENAI_AGENTS_QUICKSTART.MD`, `OPENAI_AGENTS_CONFIG.MD`, `OPENAI_AGENTS_REFERENCE.MD`, `OPENAI_AGENTS_USE_CASES.MD`.
    *   Example Implementations: `@docs/integrations/examples/openai_agents_minimal.py`, `_multi.py`, `_voice.py`, `_advanced.py`.
    *   Related KBs: `@BLUEPRINT.MD` (for project-specific requirements), `@ARCHITECTURE_GUIDE.MD` (for integration patterns).
*   **(CRITICAL AND MANDATORY) Security & API Key Management:**
    *   OpenAI API keys **MUST NEVER** be hardcoded. Load from environment (`.env` at project root) using `{SecurityMethod}` as per `@docs/integrations/OPENAI_AGENTS_CONFIG.MD`.
    *   Implement rate limiting, error handling, and retry mechanisms as per `@docs/integrations/OPENAI_AGENTS_REFERENCE.MD`.
*   **(CRITICAL AND MANDATORY) Code Structure & Organization:**
    *   Agent definitions **MUST** be modular, following patterns in examples (e.g., `openai_agents_advanced.py`).
    *   Organize capabilities by domain/function. Adhere to project error handling, type annotations, and docstrings.
*   **(CRITICAL AND MANDATORY) Tool Definitions & Safety:**
    *   Tools provided to agents **MUST** be carefully scoped, validated, and have appropriate guardrails (as in `openai_agents_advanced.py`).
    *   Implement structured validation for all tool inputs/outputs. Sensitive operations **MUST** require explicit confirmation.
*   **(CRITICAL AND MANDATORY) Testing Requirements:**
    *   Each agent capability **MUST** have unit tests. Mock OpenAI API for testing.
    *   Include integration tests with simulated conversations. Document testing approach.
*   **(CRITICAL AND MANDATORY) User Experience & Interaction Design:**
    *   Design agent conversations following patterns in `@docs/integrations/OPENAI_AGENTS_USE_CASES.MD`. Implement fallbacks.
    *   Agent UIs **MUST** conform to `@XCODE_STYLE_GUIDE.MD`. Provide loading indicators, handle streaming responses, and implement error visualization/recovery.
*   **(CRITICAL AND MANDATORY) Monitoring & Observability:**
    *   Implement structured logging for all agent interactions (redact sensitive info). Include correlation IDs.
    *   Log performance metrics (token usage, response times). Categorize and track agent-specific errors.
*   **(CRITICAL AND MANDATORY) Deployment & Operations:**
    *   Version agent definitions. Implement canary releases for significant changes. Document rollback procedures.
*   **(CRITICAL AND MANDATORY) Generic Implementation & `{projectname}` Placeholder:**
    *   Implementations **MUST** use `{projectname}` placeholder, not hardcoded names. Documentation and examples should be generic and reusable.
    *   Reference API keys from root `.env` and use proper environment separation.

## CRITICAL AND MANDATORY: Summary & Recommendation Protocol (2024-05-18 Update)

- All user-facing outputs (including SMEAC/VALIDATION REQUEST, checkpoint, and major status updates) MUST include:
  - A **Summary** section at the bottom, immediately before the **Recommendation/Next Steps** section.
  - The **Recommendation** must be clear, actionable, and mandatory.
- **Before writing the Recommendation, the AI agent MUST:**
  1. Use the `sequential-thinking` MCP server to plan the response and next steps.
  2. Use the `context7` MCP to retrieve or cross-reference any additional documentation or context required.
  3. Use the `perplexity` MCP to finalize research and ensure the recommendation is up-to-date and comprehensive.
- The SMEAC/VALIDATION REQUEST template MUST be updated to include these requirements, with the Summary and Recommendation sections at the bottom.

## 9.7. MCP Server/Tool Utilization (CRITICAL AND MANDATORY)
- All tooling, automation, and integrations processes MUST utilize:
    - `puppeteer` for web analysis
    - `perplexity-ask` for research
    - `momory` for information storage/recall
    - `context7` for latest documentation
    - `sequential-thinking` for planning/analysis
- These are REQUIRED for all automation, integration, and toolchain analysis. Violation triggers P0 STOP EVERYTHING.

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

---
*Effective and safe utilization of tooling, automation, and integrations is key to project velocity and stability. Strict adherence to these protocols is mandatory.*

## 9.9. (CRITICAL AND MANDATORY) Mock/Fake Data & Integration Prohibition and Enforcement

- Mock/fake data, services, or integrations are permitted ONLY for development, testing, or sandbox environments.
- Every instance MUST be explicitly logged as technical debt in @TASKS.MD and trigger an update to @BLUEPRINT.MD, documenting the current state and plan for real integration.
- It is STRICTLY FORBIDDEN to ship any milestone (Alpha, Beta, Production, App Store, etc.) with features that use mock/fake data, services, or integrations.
- All milestone definitions MUST explicitly prohibit shipping features with mock/fake dependencies.
- Any use of mock/fake data/services/integrations MUST create subtasks for real integration and user validation, tracked to completion before release.
- This rule is compulsory and enforced at every milestone checkpoint and release process. Reference .cursorrules for full enforcement protocol.
