---
description: 
globs: 
alwaysApply: true
---
---
description: 
globs: 
alwaysApply: true
---
# Recent Lessons Learned & Continuous Improvement

- **Automated Checks & Programmatic Execution:** Always use automated scripts and programmatic tools for rule management, governance, and workflow automation before any manual intervention.
- **TDD & Sandbox-First Workflow:** All new features and bug fixes must be developed using TDD and validated in a sandbox before production.
- **Comprehensive Logging & Documentation:** Log all rule changes, protocol deviations, and governance actions in canonical logs for audit and continuous improvement. Update all relevant documentation and protocols after each incident or improvement.
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

# 10. Project Rules, Governance & Evolution

## 1. Purpose of Rule Governance

This document establishes the definitive guidelines for the creation, formatting, ongoing maintenance, and evolution of all project rule documents (typically `.md` files, including this one, and the root `.cursorrules` file). Its purpose is to ensure that the project's rule set remains clear, effective, actionable, consistent, and relevant to the evolving needs of the project and its team (including AI agents).

## 2. Structure of Project Rule Documents (`.md` files)

*   **(CRITICAL AND MANDATORY) Standard Structure:** Each file defining project rules **MUST** strictly adhere to the following structure, comprising a YAML frontmatter block followed by the rule body written in Markdown.

    ### 2.1. YAML Frontmatter
    *   The file **MUST** begin with a YAML frontmatter block enclosed by triple-dashed lines (`---`).
    *   **Required Fields:**
        *   `description:` (string, required): A clear, concise, one-line summary of what the rule or rule set enforces or suggests.
            *   Example: `Ensures all API error responses follow the standard error schema.` (For a specific rule)
            *   Example: `Defines coding standards and operational procedures for the iOS module.` (For a rule set)
        *   `globs:` (array of strings, required): A list of glob patterns specifying which files, paths, or project aspects this rule or rule set primarily governs or applies to. Use standard glob syntax (e.g., `*`, `**`, `?`). Be as specific as possible.
            *   Example: `["Source/Networking/**/*.swift", "Source/Models/APIError.swift"]`
        *   `alwaysApply:` (boolean, required): If `true`, the rule or rule set is considered universally applicable or a fundamental principle that should always be checked/enforced by AI agents and developers. If `false`, the rule might be context-dependent or applied more selectively.
    *   **Optional Fields (Recommended for Clarity):**
        *   `tags:` (array of strings, optional): Keywords for categorizing or searching for the rule (e.g., `["security", "swift", "api-design"]`).
        *   `version:` (string, optional): A version number for the rule document itself (e.g., `1.2.0`).
        *   `last_updated:` (string, optional): Date of the last significant update (e.g., `YYYY-MM-DD`).

        ```yaml
        --- # Example Frontmatter
        description: All new UI components must include a basic set of accessibility attributes.
        globs:
          - "SweetPad/Sources/Components/**/*.swift"
        alwaysApply: true
        tags: ["ui", "accessibility", "swiftui"]
        version: "1.0"
        last_updated: "2024-05-15"
        ---
        ```

    ### 2.2. Rule Body (Markdown)
    *   The content following the frontmatter is the rule body, written in Markdown.
    *   **Structure for Clarity:**
        *   **Main Points/Sections:** Use Markdown headings (`#`, `##`, `###`) to structure the document logically.
        *   **Core Rule Statements:** Use bolded main points (e.g., starting a bullet with `- **Main Point:**` or `*   **(CRITICAL AND MANDATORY) Main Point:**`) to highlight the core aspects or requirements of a rule.
        *   **Detailed Explanations:** Elaborate on main points using indented sub-bullets or paragraphs.
        *   **Criticality Markers:** Use `(CRITICAL AND MANDATORY)`, `(RECOMMENDED)`, or `(GUIDELINE)` prefixes for rule statements to indicate their level of importance and required adherence.

## 3. File Referencing Conventions

*   **(CRITICAL AND MANDATORY) Standard Syntax:** Use the `@` symbol followed by the filename (if unique and in a common location like `docs/`) or a relative path from the project root for unambiguous referencing.
    *   Format: `@FILENAME.EXT` or `@path/to/file.ext`.
    *   Example: `@BUILD_FAILURES.MD`, `@scripts/setup/configure_xcode.sh`, `@docs/01_Core_AI_Agent_Principles.md`.
*   **(CRITICAL AND MANDATORY) Referencing Sections:** To reference a specific section within a document, use Markdown anchor links if the target document supports them (e.g., `@CODING_STYLE_GUIDE.MD#naming-conventions`).
*   **(CRITICAL AND MANDATORY) Purpose:** Consistent referencing is crucial for interconnecting rules, linking to supporting documentation, and enabling tools (like AI agents) to resolve and load context accurately.

## 4. Crafting Effective Code Examples

*   **(CRITICAL AND MANDATORY) Language-Specific Code Blocks:** Always use Markdown's language-specific fenced code blocks for syntax highlighting (e.g., ` ```swift ... ``` `).
*   **(CRITICAL AND MANDATORY) "DO" (✅) and "DON'T" (❌) Convention:** Clearly distinguish between correct/preferred and incorrect/discouraged implementations using ✅ (DO) and ❌ (DON'T) markers or equivalent visual cues. This provides immediate, scannable guidance.

    ```swift
    // ✅ DO: Use descriptive variable names and provide type information.
    let userProfile: UserProfile = await fetchUserProfile(userId: userID)

    // ❌ DON'T: Use overly terse or non-descriptive names.
    let d = await fetch(id) // Lacks clarity and type info
    ```
*   **(CRITICAL AND MANDATORY) Conciseness and Focus:** Examples **MUST** be minimal and directly illustrate the point of the rule. Avoid unnecessary complexity or unrelated code.
*   **(RECOMMENDED) Realism:** Whenever possible, base examples on patterns observed in the project codebase or make them highly representative of real-world scenarios within the project context.

## 5. Rule Content & Quality Guidelines

*   **(CRITICAL AND MANDATORY) Actionable and Specific:** Rules **MUST** provide clear, direct guidance that developers and AI agents can understand and implement. Avoid vague or overly broad statements.
*   **(CRITICAL AND MANDATORY) Justification (Rationale):** Briefly explain *why* each significant rule exists (e.g., "for performance reasons," "to improve readability," "to prevent common security vulnerability X"). This increases understanding and adherence.
*   **(CRITICAL AND MANDATORY) Keep Rules DRY (Don't Repeat Yourself):** If a concept is detailed in another rule document, reference it (e.g., `See @07_Coding_Standards_Security_And_UX_Guidelines.md for details on X.`) instead of duplicating content. This simplifies maintenance.
*   **(CRITICAL AND MANDATORY) Clarity and Conciseness:** Rules **MUST** be written in clear, simple language, avoiding jargon where possible, or explaining it if necessary.
*   **(CRITICAL AND MANDATORY) Up-to-Date References:** Any links or references to other documents, external standards, or tools **MUST** be kept current and accurate.
*   **(CRITICAL AND MANDATORY) Consistent Enforcement Expectation:** The patterns promoted by a rule should be consistently applicable and enforceable. If a rule has too many exceptions or is frequently bypassed, it indicates the rule itself may need refinement or deprecation.
*   **(RECOMMENDED) Consider Edge Cases:** If there are common, important edge cases or exceptions to a rule, mention them briefly or link to more detailed explanations if necessary.

## 6. Rule Evolution & Maintenance (Continuous Improvement)

*Project rules are living documents and **MUST** be continuously improved and maintained.*

### 6.1. Triggers for Rule Review & Improvement
*   **New Code Patterns:** Emergence of new, recurring code structures or idioms not covered by existing rules.
*   **Repetitive Implementations/Bugs:** Multiple instances of similar logic, components, or configurations that could be standardized, or frequent occurrence of specific bugs/anti-patterns that a rule could prevent.
*   **New Technologies/Libraries/Tools:** Adoption of new libraries, frameworks, or tools necessitating standardized usage patterns.
*   **Evolving Best Practices:** Changes in internal coding standards, industry best practices, or team conventions.
*   **Developer/AI Agent Feedback:** Suggestions, pain points, or ambiguities raised regarding rule clarity, applicability, or areas prone to errors.
*   **Performance/Security Imperatives:** Identification of common coding practices leading to performance bottlenecks or security vulnerabilities.
*   **Post-Refactor Updates:** After major codebase refactors or architectural changes, review and update relevant rules.

### 6.2. Analysis Process for Rule Changes
*   **Compare with Existing Rules:** Assess if a new pattern/issue is a variation of an existing rule or requires a new one.
*   **Identify Standardization Opportunities:** Look for commonalities that can be abstracted.
*   **Consult External Documentation:** Ensure alignment with official library/framework/language recommendations.
*   **Gauge Impact:** Consider the potential impact of a new or modified rule on the existing codebase and developer workflow.

### 6.3. Updating Rules (Adding New or Modifying Existing)
*   **Add New Rules When:**
    *   A new pattern/technology is used in 3+ distinct places or by multiple developers.
    *   A preventable bug/error occurs repeatedly.
    *   Code reviews consistently highlight the same issues.
    *   New security/performance imperatives require standardized implementation.
*   **Modify Existing Rules When:**
    *   Better examples emerge from the codebase.
    *   Edge cases are discovered that are not adequately covered.
    *   Related rules change, requiring consistency adjustments.
    *   The rule is found to be ambiguous, ineffective, overly restrictive, or outdated.

### 6.4. Rule Deprecation
*   **Mark as Deprecated:** Clearly mark outdated rules with `[DEPRECATED]` in their title or description. Provide a reason and timeframe if applicable.
*   **Provide Migration Paths:** If an old pattern is replaced, the deprecated rule **MUST** reference the new rule or provide guidance on migrating existing code.
*   **Update References:** Identify and update any other rules or documentation referencing the deprecated rule.
*   **Communicate Changes:** Announce deprecation of significant rules.
*   **Archive/Remove:** After a suitable transition period, deprecated rules can be archived or removed to keep the active rule set lean.

### 6.5. Documentation Updates for Rules
*   **Synchronize Examples:** Regularly verify code examples in rules are consistent with the current codebase.
*   **Update External References:** Periodically check and update links.
*   **Maintain Inter-Rule Links:** Ensure cross-references are accurate.
*   **Document Breaking Changes:** If a rule update introduces a breaking change in expected patterns, this **MUST** be clearly documented with adaptation guidance.
*   **Version Control Notes:** Use clear commit messages when updating rules, explaining the changes and reasons.

## 7. AI Agent Transparency & Operational Documentation

*   **(CRITICAL AND MANDATORY) AI Agent Task Execution Logging (`TASK_<ID>_EXECUTION_LOG.MD`):**
    *   For each task, the AI agent **MUST** create and maintain a `TASK_<ID>_EXECUTION_LOG.MD` document. This log is critical for transparency and debuggability.
    *   This log **MUST** explicitly detail the AI agent's "thinking process," including:
        *   The agent's interpretation of the user prompt and task requirements.
        *   The context gathered from various sources and how it was prioritized.
        *   How the task was broken down into sub-steps or a plan of action.
        *   Different approaches or solutions considered.
        *   The rationale behind decisions made at each step, including tool selection and parameter choices.
        *   Observations made during execution.
        *   Any encountered errors, deviations from the plan, and how they were addressed.
    *   This comprehensive record provides a traceable account of the agent's reasoning and actions, essential for debugging, knowledge sharing, and continuous improvement.

*   **(CRITICAL AND MANDATORY) AI Agent Short-Term Memory (STM) Logging (`AI_MODEL_STM.MD`):**
    *   All AI Agent Short-Term Memory (STM) snapshots, which detail the agent's internal state, key variables, and critical data points at significant junctures during task execution, **MUST** be written to a dedicated Key Document named `AI_MODEL_STM.MD`.
    *   This document serves as the primary, structured log for STM data and complements the narrative thought process documented in `TASK_<ID>_EXECUTION_LOG.MD`.
    *   STM snapshots should use a structured format (Markdown with headings or YAML/JSON blocks) to ensure consistency and readability. Example format:
        ```markdown
        ---
        **Timestamp:** YYYY-MM-DD HH:MM:SS Z
        **Current Task ID:** <Task ID>
        **Focus:** <Brief description of current focus/sub-step>
        **Key Context Loaded:**
          - `@BLUEPRINT.MD#SectionX`
          - `@BUILD_FAILURES.MD#ErrorY`
        **Recent Observations/Inputs:**
          - Build failed with error Z.
          - User provided clarification on requirement W.
        **Working Hypothesis/Plan:**
          - Attempting fix approach A for error Z.
          - Next, will verify with test suite B.
        **Uncertainties/Queries:**
          - Is dependency C compatible with version D?
        ---
        ```
    *   Entries in `AI_MODEL_STM.MD` should be timestamped and correlated with corresponding entries in `TASK_<ID>_EXECUTION_LOG.MD` where applicable.
    *   This structured logging of AI agent state is crucial for in-depth analysis of the AI's operational state, for debugging complex behaviors, and for fine-tuning agent performance.

## 8. Quality Checks & Rule Self-Assessment

To ensure the effectiveness, usability, and longevity of each project rule, the following quality attributes must be regularly assessed and maintained:

* **Actionable and Specific:** Rules should provide clear, direct guidance that developers can easily understand and implement. Avoid vague or overly broad statements.
* **Real-World Examples:** Examples illustrating the rule (both good and bad practice) should be derived from or closely mirror actual codebase scenarios.
* **Up-to-Date References:** Any links to external documentation, internal standards, or related tools should be current and accurate.
* **Consistent Enforcement:** The patterns promoted by the rule should be consistently applicable and enforced. If a rule has many exceptions, it may need refinement.
* **Clarity and Conciseness:** Rules should be written in clear, simple language, avoiding jargon where possible.
* **Justification:** Briefly explain the rationale behind the rule (e.g., performance, readability, security) to help developers understand its importance.
* **Discoverability:** Ensure rules are well-organized and easily searchable within the rule file structure.

## 9. Rule Implementation Monitoring & Feedback

* **Monitor Code Review Comments:** Regularly analyze code review discussions to identify recurring issues or suggestions that could be codified into new rules or improve existing ones.
* **Track Common Development Questions:** Pay attention to frequently asked questions in team channels or discussions, as these often indicate areas where clearer rules or documentation are needed.
* **Post-Refactor Updates:** After major codebase refactors or architectural changes, review and update relevant rules to ensure they align with the new structure and practices.
* **Integrate Documentation Links:** Actively add and maintain links within rules to relevant external documentation, style guides, or in-depth explanations.
* **Cross-Reference Related Rules:** Where appropriate, link related rules together to provide a more comprehensive understanding of interconnected concepts.
* **Periodic Review Sessions:** Schedule periodic reviews (e.g., quarterly) of all rule files to ensure overall health, relevance, and consistency of the rule set.
* **Feedback Mechanism:** Establish a clear channel for developers and AI agents to propose new rules, suggest modifications, or report issues with existing rules.

## CRITICAL AND MANDATORY: Summary & Recommendation Protocol (2024-05-18 Update)

- All user-facing outputs (including SMEAC/VALIDATION REQUEST, checkpoint, and major status updates) MUST include:
  - A **Summary** section at the bottom, immediately before the **Recommendation/Next Steps** section.
  - The **Recommendation** must be clear, actionable, and mandatory.
- **Before writing the Recommendation, the AI agent MUST:**
  1. Use the `sequential-thinking` MCP server to plan the response and next steps.
  2. Use the `context7` MCP to retrieve or cross-reference any additional documentation or context required.
  3. Use the `perplexity` MCP to finalize research and ensure the recommendation is up-to-date and comprehensive.
- The SMEAC/VALIDATION REQUEST template MUST be updated to include these requirements, with the Summary and Recommendation sections at the bottom.

## 10.7. MCP Server/Tool Utilization (CRITICAL AND MANDATORY)
- All project rules, governance, and evolution processes MUST utilize:
    - `puppeteer` for web analysis
    - `perplexity-ask` for research
    - `momory` for information storage/recall
    - `context7` for latest documentation
    - `sequential-thinking` for planning/analysis
- These are REQUIRED for all rule changes, governance, and project evolution analysis. Violation triggers P0 STOP EVERYTHING.

## 10.9. (CRITICAL AND MANDATORY) Mock/Fake Data & Integration Prohibition and Enforcement

- Mock/fake data, services, or integrations are permitted ONLY for development, testing, or sandbox environments.
- Every instance MUST be explicitly logged as technical debt in @TASKS.MD and trigger an update to @BLUEPRINT.MD, documenting the current state and plan for real integration.
- It is STRICTLY FORBIDDEN to ship any milestone (Alpha, Beta, Production, App Store, etc.) with features that use mock/fake data, services, or integrations.
- All milestone definitions MUST explicitly prohibit shipping features with mock/fake dependencies.
- Any use of mock/fake data/services/integrations MUST create subtasks for real integration and user validation, tracked to completion before release.
- This rule is compulsory and enforced at every milestone checkpoint and release process. Reference .cursorrules for full enforcement protocol.

---
*This governance framework ensures that project rules remain a valuable, living asset, guiding high-quality, consistent, and efficient development by both humans and AI agents.*

s