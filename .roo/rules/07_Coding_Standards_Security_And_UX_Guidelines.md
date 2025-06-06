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

- **Automated Checks & Programmatic Execution:** Always use automated scripts and programmatic tools for code quality, linting, formatting, and workflow operations before any manual intervention.
- **TDD & Sandbox-First Workflow:** All new features and bug fixes must be developed using TDD and validated in a sandbox before production.
- **Comprehensive Logging & Documentation:** Log all code quality issues, fixes, protocol deviations, and significant actions in canonical logs for audit and continuous improvement. Update all relevant documentation and protocols after each incident or improvement.
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

# 07. Coding Standards, Security & UX Guidelines

**(CRITICAL AND MANDATORY) Task-Driven Code Change Enforcement:**
- No code file (e.g., .swift, .js, .ts, etc.) may be edited, created, or deleted unless a corresponding actionable task exists in both TASKS.MD and tasks/tasks.json, and the change is fully traceable to that task (task ID in code comments, commits, docs). See .cursorrules Section 4.0.
- Any violation is a CRITICAL PROTOCOL BREACH: halt, log, escalate, and self-correct per .cursorrules Section 4.0.

## 1. Foundational Coding Principles

* **(CRITICAL AND MANDATORY) Clarity, Readability, Maintainability:**
    * All code **MUST** be written with the primary goals of clarity, ease of understanding, and long-term maintainability by any developer, including future AI agent versions.
    * Employ descriptive and unambiguous names for variables, functions, classes, enums, protocols, and all other identifiers.
    * Actively refactor overly complex logic or deeply nested structures to simpler, more linear alternatives where feasible without sacrificing correctness.
* **(CRITICAL AND MANDATORY) DRY (Don't Repeat Yourself):**
    * Duplication of code logic, constants, or configuration **MUST** be strictly avoided.
    * Encapsulate reusable logic into well-defined functions, methods, classes, extensions, or shared components/modules as appropriate for the language and architecture.
* **(CRITICAL AND MANDATORY) KISS (Keep It Simple, Stupid):**
    * Favor simple, straightforward, and elegant solutions over those that are unnecessarily complex or clever.
    * Complexity should only be introduced when genuinely required by the problem domain and **MUST** be thoroughly justified and documented.
* **(CRITICAL AND MANDATORY) Comprehensive Code Commenting & Documentation:**
    * Provide detailed, clear, and concise comments for **ALL** significant code sections, complex logic, non-obvious decisions, and public-facing APIs. This is a non-negotiable standard.
    * This includes commenting every new code block, updates to existing code, and proactively ensuring that existing, under-documented codebase elements are brought up to standard.
    * Comments **MUST** explain the "why" (intent, rationale behind design choices, business rules) and any complex "hows" (intricate algorithms, specific workarounds). Comments should not merely restate what the code itself clearly says.
    * **MUST** use language-standard documentation comment syntax for all public APIs (e.g., `///` for Swift DocC, Javadoc for Java/Kotlin, JSDoc for JavaScript/TypeScript, Python Docstrings). These comments should be complete enough to generate useful API documentation.
* **(CRITICAL AND MANDATORY) Deliberate Action & Purposeful Design (Pause, Think, Analyze, Assess):**
    * Before initiating *any* code changes, file modifications, or architectural decisions, the agent (or developer) **MUST** engage in a "Pause, Think, Analyze, Assess" cycle.
    * A Chain of Thought (CoT) or equivalent documented reasoning process **MUST** be employed to evaluate objectives, constraints, potential impacts, and alternative solutions. This process should be logged (e.g., in `AI_MODEL_STM.MD` or commit messages).
    * Strictly avoid impulsive or "trial-and-error" file creation/editing. All actions related to code structure and content **MUST** be purposeful, justified, and aligned with project goals and architectural guidelines.
* **(CRITICAL AND MANDATORY) Self-Critique, Rigorous Verification, and Continuous Learning:**
    * Upon completing any task or significant code segment, a self-critique and rigorous verification process **MUST** be performed.
    * Objectively assess the work against requirements, coding standards, security guidelines, UX principles, and overall quality benchmarks.
    * "Lessons learned" from successes, failures, or near-misses **MUST** be documented and shared (e.g., in `DEVELOPMENT_LOG.MD`, `BUILD_FAILURES.MD`, or a dedicated knowledge base) to enhance collective knowledge and inform preventative strategies.
* **(CRITICAL AND MANDATORY) Strategic File and Code Management:**
    * Minimize the creation of new files. Prioritize updating, refactoring, and intelligently modifying existing files and structures.
    * New files or modules should only be introduced when essential and clearly justified by architectural needs, new distinct areas of functionality, or to improve modularity and maintainability. This justification **MUST** be documented.
* **(CRITICAL AND MANDATORY) Version Control Hygiene:**
    * After every successful build representing a stable and meaningful changeset, a checkpoint **MUST** be implemented by committing changes to the version control system (Git).
    * Commit messages **MUST** be clear, concise, and informative, adhering to project-defined conventions (e.g., Conventional Commits, linking to task IDs).
    * The application's version number **MUST** be consistently updated in designated project configuration files (e.g., `Info.plist`, `build.gradle`, `package.json`, `docs/BLUEPRINT.MD`) following significant changes, adhering to Semantic Versioning (see `Release Notes & Versioning Protocol`).
    * The updated version number **MUST** be accurately reflected in appropriate UI locations (e.g., About screen, main view as specified).
* **(CRITICAL AND MANDATORY) Conflicted File Resolution Protocol:**
    * Immediately identify and resolve any version control conflicted files (e.g., those containing "Conflicted Copy," `<<<<<<< HEAD`, `=======`, `>>>>>>>` markers).
    * Automated tooling or scripts (e.g., `filesystem` MCP or custom scripts) should be used for efficient detection and, where safe, removal of simple conflict artifacts. Complex merge conflicts require careful manual or AI-assisted resolution.

## 2. Language-Specific Conventions & Automated Linting/Formatting

* **(CRITICAL AND MANDATORY) Adherence to Project Coding Standards Document:**
    * All code, regardless of language, **MUST** strictly adhere to the language-specific conventions, formatting rules, style guides, and architectural best practices defined in the project's official `@CODING_STANDARDS.MD` document (or its equivalent, e.g., a dedicated section within project rules or `ARCHITECTURE_GUIDE.MD`). This document is the single source of truth for language style.
* **(CRITICAL AND MANDATORY) Automated Linting and Formatting Enforcement:**
    * For every primary programming language used in the project, an automated linter and code formatter **MUST** be configured and consistently applied.
    * Configuration files for these tools (e.g., `.swiftlint.yml`, `.eslintrc.js`, `.rubocop.yml`, `pyproject.toml` for Black/Ruff) **MUST** reside at the project root (or a standard config location) and be committed to version control.
    * These configurations **MUST** enforce the rules outlined in `@CODING_STANDARDS.MD`.
* **(CRITICAL AND MANDATORY) Example: SwiftLint for Swift Projects:**
    * **Installation & Configuration:** SwiftLint **MUST** be installed (e.g., via Homebrew, Mint, or CocoaPods) and its configuration file (`.swiftlint.yml`) **MUST** be present at the project root.
    * **Defined Rules:** The `.swiftlint.yml` **MUST** define and enable rules covering (but not limited to):
        * Whitespace, indentation (e.g., tabs vs. spaces as per project standard), line length (e.g., max 120 characters).
        * Strict avoidance of force unwrapping (`!`) and force casting (`as!`) except in explicitly justified and documented scenarios (e.g., `@IBOutlets` after `viewDidLoad`). Prefer `guard let`, `if let`, and `as?`.
        * Correct and consistent usage of access control modifiers (`private`, `fileprivate`, `internal`, `public`, `open`).
        * Mandatory documentation comments (`///`) for all `public` and `open` APIs.
        * Adherence to Swift API Design Guidelines for naming conventions (e.g., UpperCamelCase for types/protocols, lowerCamelCase for functions/variables/enum cases).
        * Prohibition of trailing whitespace, redundant `self.`, and other common style violations.
        * Rules for code complexity (e.g., cyclomatic complexity, function body length).
        * Exclusion of third-party library code (e.g., `Pods/`, `Carthage/`, `.build/`) and auto-generated files from linting.
    * **Build Phase Integration:** A build phase script **MUST** be integrated into the Xcode project (or CI pipeline) to automatically run SwiftLint during compilation. This script **MUST** be configured to fail the build if any linting errors (or warnings, if configured as such) are detected.
    * **Auto-Correction Script:** A shell script (e.g., `@scripts/lint-and-fix.sh` or `swiftlint --fix`) **MUST** be provided and documented, allowing developers/AI to automatically correct common SwiftLint violations.
    * **Pre-Commit/Pre-Merge Compliance:** All Swift code **MUST** pass all SwiftLint checks without errors (and ideally without warnings) before being committed locally and pushed, and absolutely before being merged into main development branches.
* **(CRITICAL AND MANDATORY) Linters & Formatters for Other Languages:**
    * If other languages are utilized (e.g., Python: Ruff, Black, Pylint; JavaScript/TypeScript: ESLint, Prettier; Kotlin: ktlint, Detekt; Java: Checkstyle, SpotBugs), appropriate linters and formatters **MUST** be similarly configured, integrated into the build/CI process, and enforced with the same rigor as SwiftLint.
    * Project-specific configuration files and auto-fix commands/scripts **MUST** be provided and documented in `@CODING_STANDARDS.MD` or a relevant tooling guide.

## 3. UI/UX Design and Implementation Standards

* **(CRITICAL AND MANDATORY) Strict Adherence to Official UI/UX Style Guide:**
    * All UI/UX design and implementation, encompassing all views, components, layouts, typography, color palettes, spacing systems, iconography, animations, and interaction patterns, **MUST** strictly and meticulously adhere to the project's official UX/UI Style Guide.
    * This guide might be named `@XCODE_STYLE_GUIDE.MD` (if Xcode/Apple-centric), `@DESIGN_SYSTEM.MD`, a Figma link, or an equivalent document as explicitly specified in `docs/BLUEPRINT.MD`. This is the **single source of truth** for all visual and interaction design.
* **(CRITICAL AND MANDATORY) Semantic and Tokenized Design:**
    * **MUST** use semantic color names (e.g., `Theme.colors.primaryAction`, `Theme.colors.text.body`), font styles (e.g., `Theme.typography.headline1`, `Theme.typography.buttonLabel`), and spacing tokens/constants (e.g., `Theme.spacing.small`, `Theme.spacing.containerPadding`) as defined in the Style Guide and `docs/BLUEPRINT.MD` (under `LayoutConstants` or `Theme`).
    * Hardcoding specific color hex values, font point sizes, or pixel/point values for spacing directly in view code is **STRICTLY PROHIBITED** unless explicitly part of a low-level drawing routine that cannot use tokens.
    * UI elements **MUST** be implemented to correctly adapt to different appearance modes (Light/Dark Mode), accessibility settings (Dynamic Type, increased contrast, reduced motion), and relevant device characteristics (screen size, orientation).
* **(CRITICAL AND MANDATORY) Modern and Platform-Appropriate UI Patterns:**
    * Employ modern UI/UX patterns, components, and interaction paradigms that are best practice for the target platform(s) (e.g., current SwiftUI best practices for Apple platforms, Material Design for Android unless a fully custom system is defined).
    * Avoid legacy, deprecated, or platform-inconsistent UI patterns unless specifically justified by unique requirements and documented with approval.
* **(CRITICAL AND MANDATORY) Accessibility as a Core, Non-Optional Requirement:**
    * All interactive UI elements (buttons, sliders, inputs, custom controls) **MUST** be fully accessible by default.
    * Provide clear, concise, and localized accessibility labels, hints, values, and traits for all UI elements.
    * Ensure logical and intuitive keyboard navigation order and proper focus management for all interactive components.
    * Thoroughly test UI with platform-specific accessibility tools (e.g., VoiceOver, Voice Control, Switch Control for Apple platforms; TalkBack for Android).
    * All UI implementations **MUST** strive to meet or exceed the WCAG (Web Content Accessibility Guidelines) conformance level specified in the `@XCODE_STYLE_GUIDE.MD` or project accessibility statement (e.g., AA or AAA).
* **(CRITICAL AND MANDATORY) UI/UX Review Integrated into Development Loop:**
    * During the "AUTO ITERATE" mode's self-review step (or any manual code review), a specific check for compliance with the `@XCODE_STYLE_GUIDE.MD` (and general UX best practices) **MUST** be performed for any and all UI-related changes.
    * The `VALIDATION REQUEST / CHECKPOINT` report (see `Master Operating Protocol`) **MUST** include an explicit statement on the UI/UX Style Guide compliance status for the completed work. Any deviations must be noted and justified.
* **(CRITICAL AND MANDATORY) Content Padding and Safe Area Adherence:**
    * All primary content views **MUST** respect safe areas by default to avoid content overlapping with system UI (status bars, notches, home indicators).
    * Standardized padding (e.g., `Theme.padding.container` or `LayoutConstants.screenEdgeMargin`) **MUST** be applied around the main content area within its bounding container, ensuring content is not flush against screen edges unless part of an intentional full-bleed design element specified in the Style Guide.
* **(CRITICAL AND MANDATORY) macOS Specific UI Guidelines (Example for Sidebar Apps):**
    * **Sidebar Structure:** If implementing a sidebar-based layout (common in macOS apps):
        * Utilize standard SwiftUI layout containers like `NavigationSplitView` (macOS 13+) or a carefully structured `NavigationView` with a `List` sidebar, or an `HSplitView`/`HStack` for full custom control if standard views are insufficient. The choice **MUST** be documented.
        * Sidebar width **MUST** be configurable via `LayoutConstants.sidebarWidth` in `docs/BLUEPRINT.MD` (e.g., default `220` points).
    * **Sidebar Item Usability:**
        * Sidebar items (icons and text) **MUST** be clearly legible, with icons typically 20-24pt and text using a readable font (e.g., `Theme.typography.sidebarItem` or `.headline` equivalent).
        * Adequate spacing (e.g., `LayoutConstants.sidebarItemIconTextSpacing`) **MUST** exist between an icon and its text.
        * Each sidebar item (row) **MUST** have sufficient vertical padding (e.g., `LayoutConstants.sidebarItemVerticalPadding`) for easy click targets.
        * Text **MUST NOT** be truncated; use line limits, wrapping, or ensure sidebar width accommodates typical labels.
        * Icons and text **MUST** be vertically centered within their row and horizontally aligned to the leading edge with appropriate leading padding (e.g., `LayoutConstants.sidebarItemLeadingPadding`).
    * **Navigation Bar/Header Consistency (if custom):**
        * If a custom header/toolbar is used above main content, its height, background, and typography **MUST** be defined in `LayoutConstants` and `Theme` in `docs/BLUEPRINT.MD`.
        * It **MUST NOT** conflict with or awkwardly duplicate system-provided navigation elements if `NavigationView` or `NavigationSplitView` titles are also used.
* **(CRITICAL AND MANDATORY) Font Hierarchy & Theming Consistency:**
    * `docs/BLUEPRINT.MD` (or the linked Style Guide) **MUST** define a clear typographic hierarchy (e.g., `Theme.typography.display`, `Theme.typography.headline`, `Theme.typography.body`, `Theme.typography.caption`) and a comprehensive color palette (e.g., `Theme.colors.primary`, `Theme.colors.background.canvas`, `Theme.colors.text.primary`).
    * The AI/developer **MUST** use these semantic tokens, not hardcode font names, sizes, or color values directly.
* **(CRITICAL AND MANDATORY) Spacing Systems and Visual Grouping:**
    * A clear spacing scale (e.g., `Theme.spacing.xsmall`, `Theme.spacing.medium`, `Theme.spacing.xlarge`) **MUST** be defined and used consistently for padding, margins, and gaps between UI elements.
    * Logical groups of UI elements **MUST** have consistent internal spacing and appropriate external margins to delineate them from other groups, enhancing visual structure.
    * `Spacer()` views in SwiftUI, or equivalent constructs, **MUST** be used judiciously to achieve balanced and adaptive layouts, avoiding overly cramped or excessively sparse interfaces.
* **(CRITICAL AND MANDATORY) Iconography Standards (SF Symbols Focus for Apple Platforms):**
    * For Apple platforms, all non-branded icons **SHOULD** be SF Symbols by default, unless highly custom iconography is a core part of the brand and specified in the Style Guide with asset provision.
    * The AI/developer **MUST** select SF Symbols that are semantically appropriate for the action or item they represent.
    * SF Symbols **MUST** be rendered using a font scale, explicit point size, or frame size that ensures they are visually harmonious and correctly aligned with adjacent text or UI elements.
* **(CRITICAL AND MANDATORY) Iterative UI Refinement & Self-Correction (Agent Specific):**
    * After generating initial UI code, the AI agent **MUST** perform a "UI Sanity Check" by asking itself and validating:
        * 'Are all interactive elements clearly tappable/clickable with sufficient hit targets (min 44x44pt equivalent)?'
        * 'Is all text legible with sufficient contrast against its background (WCAG AA minimum)?'
        * 'Is spacing and alignment consistent across similar elements and screens, adhering to defined spacing tokens?'
        * 'Does the layout adapt gracefully if placeholder text, content, or localization changes typical string lengths?'
        * 'Does the UI strictly adhere to all `LayoutConstants` and `Theme` definitions from `docs/BLUEPRINT.MD`?'
        * 'Are all platform-specific HIG (e.g., macOS HIG for sidebars, window titles) followed unless a deviation is explicitly documented and approved?'
    * This self-check process, its findings, and any subsequent refinements **MUST** be logged by the AI in `docs/AI_MODEL_STM.MD` and summarized in `docs/DEVELOPMENT_LOG.MD`.
* **(CRITICAL AND MANDATORY) Comprehensive SwiftUI Preview Providers:**
    * ALL generated SwiftUI views **MUST** include a `PreviewProvider` struct.
    * Previews **MUST** showcase the view in various relevant states (e.g., empty, loading, error, populated with data), with different data inputs (e.g., short and long text strings, zero and many items in a list), and for different device traits where applicable (e.g., Light and Dark Mode using `.preferredColorScheme(.dark)`, different Dynamic Type sizes using `.environment(\.sizeCategory, .accessibilityExtraLarge)`).
    * For container views, previews **MUST** include realistic and representative child content.
    * Previews should be named descriptively (e.g., `MyView_Previews_EmptyState`, `MyView_Previews_DarkMode`).
* **(CRITICAL AND MANDATORY) Adherence to Apple's Human Interface Guidelines (HIG) / Platform Conventions:**
    * For applications targeting Apple platforms, the AI/developer **MUST** prioritize layout, component behavior, and interaction patterns that align with Apple's official Human Interface Guidelines (HIG) for the specific platform (macOS, iOS, watchOS, etc.). This includes aspects like window structure, navigation paradigms, control sizing, spacing conventions, and system integrations.
    * Deviations from HIG **MUST** be intentional, justified by clear design or functional requirements outlined in `docs/BLUEPRINT.MD` (or the Style Guide), and documented in `docs/DEVELOPMENT_LOG.MD` with the rationale. "Accidental" non-conformance is not acceptable.

## 4. Secure Coding Practices (Cross-references `@SECURITY_GUIDELINES.MD`)

* **(CRITICAL AND MANDATORY) Strict Adherence to `@SECURITY_GUIDELINES.MD`:**
    * All development activities, code, and architectural decisions **MUST** strictly follow and implement all security principles, requirements, checklists, and best practices outlined in the project's dedicated `@SECURITY_GUIDELINES.MD` document. This document is the authoritative source for security policy.
* **(CRITICAL AND MANDATORY) Robust Input Validation and Sanitization:**
    * All external input received by the application—from users (UI fields, URLs), APIs (network responses), files, inter-process communication, environment variables, etc.—**MUST** be rigorously validated, sanitized, and type-checked *before* it is processed, stored, or used in any operations.
    * Validation **MUST** check for type, length, format, range, and character set as appropriate to prevent injection attacks (SQLi, XSS, command injection), buffer overflows, path traversal, crashes, and data corruption.
* **(CRITICAL AND MANDATORY) Secure Output Encoding:**
    * All data output from the application—when displayed in UIs, written to logs, saved to files, or sent to other systems/APIs—**MUST** be appropriately encoded for the context in which it will be used.
    * This is critical to prevent Cross-Site Scripting (XSS) in web views or HTML-based content, log injection, and other similar vulnerabilities. Use context-aware output encoding libraries or platform-provided mechanisms.
* **(CRITICAL AND MANDATORY) Secure Secret Management (No Hardcoding):**
    * API keys, passwords, database credentials, private certificates, encryption keys, access tokens, and any other sensitive secrets **MUST NOT** be hardcoded in source code, configuration files committed to version control, or any other easily accessible artifact.
    * Secrets **MUST** be managed using approved mechanisms as defined in `@SECURITY_GUIDELINES.MD` and specified by the `{SecurityMethod}` placeholder in `docs/BLUEPRINT.MD`. Examples include:
        * Environment variables loaded from an ignored `.env` file at runtime.
        * Platform-specific secure storage (e.g., iOS/macOS Keychain, Android Keystore).
        * A dedicated secrets management service (e.g., HashiCorp Vault, AWS Secrets Manager, Azure Key Vault) with appropriate access controls.
* **(CRITICAL AND MANDATORY) Dependency Security Management:**
    * Project dependencies (libraries, frameworks, packages) **MUST** be regularly scanned for known vulnerabilities using industry-standard tools (e.g., OWASP Dependency-Check, Snyk, Trivy, GitHub Dependabot alerts).
    * Vulnerable dependencies **MUST** be updated or patched promptly based on the assessed risk and severity, following the project's defined dependency management and update policy (cross-reference `@08_Documentation_Directory_And_Configuration_Management.md` or equivalent).
* **(CRITICAL AND MANDATORY) Secure Error Handling & Minimized Information Leakage:**
    * Errors **MUST** be handled gracefully and informatively for the user, without revealing sensitive internal system details, stack traces, unnecessary user data, or verbose debugging information in error messages displayed to end-users or in production logs accessible to unauthorized parties.
    * Detailed technical error information, including stack traces, **MUST** be logged securely to a restricted location intended only for developers/administrators for debugging purposes. Ensure these logs do not inadvertently capture sensitive data.
* **(CRITICAL AND MANDATORY) Robust Authentication and Authorization:**
    * Implement strong, industry-standard authentication mechanisms to verify user identity as required by the application.
    * Enforce granular authorization checks to ensure users and system components only have access to the resources and functionalities they are explicitly permitted to use (Principle of Least Privilege).
    * Refer to `@SECURITY_GUIDELINES.MD` for specific requirements on password policies, multi-factor authentication (MFA), session management, and API access controls.
* **(CRITICAL AND MANDATORY) Prohibition of Realistic Fake Sensitive Data:**
    * **NEVER** use, generate, or embed fake but realistic-looking sensitive data (e.g., patterned like credit card numbers, social security numbers, phone numbers, personal addresses) for testing, examples, mockups, or placeholder content, even if it seems benign or "generated."
    * Instead, use clearly abstract, non-sensitive placeholders like `"VALID_TEST_API_KEY"`, `"user@example.com"`, `"123 Main Street, Anytown"`, or data that is structurally valid but semantically gibberish for the sensitive field.

## 5. Error Handling and Reporting Standards

* **(CRITICAL AND MANDATORY) Comprehensive and Robust Error Handling:**
    * Implement comprehensive error handling for all operations that have the potential to fail. This includes, but is not limited to, network requests, file I/O, data parsing/serialization, complex calculations, database operations, and interactions with external services.
    * Errors **MUST NOT** be silently ignored or "swallowed." Unhandled errors can lead to unpredictable application behavior, crashes, data corruption, or security vulnerabilities.
* **(CRITICAL AND MANDATORY) Clear and Actionable Error Reporting:**
    * **For Users:** When an operation fails due to a recoverable or user-affecting error, provide clear, concise, and user-friendly error messages in the UI. These messages should explain the problem in simple terms (avoiding technical jargon) and, where possible, guide the user on potential next steps or corrective actions.
    * **For Developers/Logging:** Log detailed technical error information for all significant errors. This log entry **MUST** include:
        * A timestamp.
        * The specific error type or code.
        * A descriptive error message.
        * The context in which the error occurred (e.g., function name, module, task ID).
        * Relevant parameters or state that might have contributed to the error (ensure no sensitive data is logged insecurely).
        * Stack traces, where applicable and helpful for debugging.
    * Ensure logged error details do not leak sensitive information (as per Section 4).
* **(CRITICAL AND MANDATORY) Consistent Error Types and Mechanisms:**
    * Employ consistent error handling mechanisms and types throughout the entire codebase for a given language or architectural layer.
    * **Swift Example:** Utilize Swift's `Error` protocol extensively. Define custom, specific error `enum`s or `struct`s conforming to `Error` for domain-specific and module-specific errors to provide better context and enable more granular error handling. Use the `Result<Success, Failure: Error>` type for asynchronous operations or functions that can fail. Avoid overuse of `NSError` unless interacting with Objective-C APIs that require it.
    * **Other Languages:** Use idiomatic error handling for the language (e.g., exceptions in Python/Java, `error` values in Go, standardized error objects/codes for APIs).
    * Project-specific error handling patterns, custom error base classes/protocols, or global error handling strategies **MUST** be defined and documented in `@CODING_STANDARDS.MD` or `@ARCHITECTURE_GUIDE.MD`.

## 6. Structured Workflow for Swift Development (Focus on Views)

* **(CRITICAL AND MANDATORY) Methodical and Documented Approach for New Swift Files (Especially Views):**
    * A structured, deliberate, and documented approach is **MANDATORY** *before initiating the coding of any new Swift files, with particular emphasis on SwiftUI Views or UIKit `UIView`/`UIViewController` subclasses.* The following sequential steps **MUST** be adhered to and evidenced in task management or logs:

    1.  **Deliberate Planning & Requirement Analysis (Pause, Think, Analyze, Plan):**
        * Halt immediate coding. Dedicate focused time to thoroughly understand the requirements (from `docs/BLUEPRINT.MD`, `docs/TASKS.MD`, user stories).
        * Analyze potential complexities, edge cases, dependencies, and performance considerations.
        * Formulate a clear implementation plan, including component breakdown, data flow, and state management strategy. Document this plan (e.g., in `docs/AI_MODEL_STM.MD` or task comments).

    2.  **Task Clarification, Granularity, and Context Verification:**
        * Ensure the assigned task (e.g., from `docs/TASKS.MD`) has been effectively broken down to a granular, actionable level (e.g., Level 5-6 detail as per project task hierarchy).
        * Verify that all necessary information, context (e.g., API contracts, data models, design mockups/specs), and acceptance criteria are available and understood. If not, seek clarification *before* proceeding.

    3.  **Comprehensive Information Gathering & Best Practice Review:**
        * Utilize tools like the `sequential-thinking` MCP Server (or equivalent structured analysis process) for in-depth problem decomposition and solution brainstorming.
        * Conduct targeted research (e.g., quick web searches, review of Apple documentation, relevant articles) for similar UI patterns, platform-specific best practices, and potential solutions to anticipated challenges.
        * Thoroughly consult the project's `docs/BLUEPRINT.MD` for feature specifications and `docs/XCODE_STYLE_GUIDE.MD` (or equivalent) for design guidelines relevant to the new View.

    4.  **Internal Codebase Context & Style Assimilation:**
        * Review the `docs/ExampleCode/` directory for curated examples of similar components or patterns within the project.
        * Analyze relevant sections of the existing established codebase to understand and align with:
            * The prevailing Swift coding style and conventions (beyond global linting rules).
            * Adopted architectural patterns (e.g., MVVM, TCA, VIPER).
            * Commonly used utility functions, extensions, and base classes/protocols.
            * Specific best practices for writing Swift code within *this project's unique context*.

    5.  **Test-Driven Development (TDD) or Behavior-Driven Development (BDD) Approach - Test First:**
        * Within a dedicated sandbox environment or directly in the test targets, proactively write a comprehensive suite of automated tests *before* implementing the main feature code for the View. This suite **MUST** include, as applicable:
            * **Initially Failing Tests:** At least one test that will specifically pass once the core functionality is correctly implemented.
            * **Unit Tests:** For ViewModel logic, data transformations, utility functions, and individual non-UI components related to the View.
            * **Snapshot Tests (for UI Views):** If using a snapshot testing library, create initial snapshots that will define the expected appearance (these may fail initially or capture a placeholder state).
            * **UI Interaction Tests (Limited/Unit-Level):** For simple UI logic contained within the View itself (e.g., state changes based on internal actions, if not handled by a ViewModel).
            * **(If applicable for complex views/logic) Integration Tests:** Testing the View's interaction with its ViewModel and any services it directly uses (mocked).
        * Define criteria for broader **End-to-End (E2E) Tests**, **UI Automation Tests** (using XCUITest), **Performance Tests**, and **Security Tests** that will cover this new View, even if the tests themselves are implemented in a separate phase or by a different team/process. The View's design should facilitate testability for these.
        * Clearly define **User Acceptance Test (UAT) criteria** based on the requirements.

    6.  **Iterative Test Validation & Refinement during Pre-Development:**
        * Execute all written pre-development tests. They should initially fail (or show differences for snapshot tests).
        * Adjust and refine the tests for clarity, correctness, and coverage until they accurately represent the desired behavior and appearance.

    7.  **High-Quality Code Implementation for the Swift View/File:**
        * Only after the preceding planning and test setup steps are satisfactorily completed, proceed to write the Swift code for the View or file.
        * Strive to produce the highest quality code possible: clean, efficient, well-documented, robust, and secure.
        * Ensure the implementation precisely fulfills all specified functional requirements and adheres to all design specifications from the Style Guide.
        * Follow all coding standards (Section 1 & 2) and security practices (Section 4).

    8.  **Comprehensive Post-Implementation Testing & Validation:**
        * After the initial implementation is complete, execute the full suite of relevant tests (unit, snapshot, UI, integration) in both the Sandbox/Development environment and, if applicable, a Production-like testing environment.
        * All tests related to the new View **MUST** pass.
        * If any test failures occur:
            * Meticulously document each failure (following the project's `Build Failure Protocol` or general bug reporting standards).
            * Return to Step 5 (or Step 7 if it's a simple implementation bug) to analyze the root cause and implement corrections. Iterate until all tests pass.
        * Manually verify UI against mockups/specs and test UAT criteria.

    9.  **Strive for Efficient Single-Cycle Feature Completion (where quality permits):**
        * While thoroughness is paramount, aim to complete the entire development and testing cycle for a discrete feature or task (like a single View) within a single, efficient iteration where possible, without compromising quality, testing, or documentation.

* **(CRITICAL AND MANDATORY) Segregated Development Environments & Promotion Process:**
    * Maintain clearly distinct and isolated Sandbox/Development, Testing/QA, Staging, and Production environments.
    * Each environment **MUST** have its own dedicated configurations (e.g., API endpoints, database connections, feature flags), managed securely and not leaked between environments.
    * Code promotion from one environment to the next (e.g., Dev -> QA -> Staging -> Prod) **MUST** follow a defined, documented, and rigorously tested process, typically involving CI/CD pipelines, automated testing gates, and appropriate approvals.

## 7. Automated UI/UX Snapshotting, Navigation & Validation Protocol (Cross-references `.cursorrules`, `docs/SCRIPTS.MD`, `behaviours_visual-ai-snapshot.md`)

* **(CRITICAL AND MANDATORY) Universal Compliance with Snapshotting Protocol:**
    * All UI/UX automation, testing involving visual verification, and related documentation **MUST** fully comply with the project's generic, project-agnostic screenshot navigation and validation protocol.
    * This protocol is canonically defined in `.cursorrules` (Master Operating Protocol), detailed in `docs/UI_UX_TESTING_GUIDE.MD` or `docs/SCRIPTS.MD` (for specific script usage), and potentially in specialized behavior files like `behaviours_visual-ai-snapshot.md`.
* **(CRITICAL AND MANDATORY) Programmatic Navigation Preceding Snapshots:**
    * Screenshots intended for UI validation or documentation **MUST** be preceded by programmatic navigation to the relevant screen, view, or specific UI state. The exact navigation path or steps taken **MUST** be logged.
* **(CRITICAL AND MANDATORY) Post-Mortem Analysis for Snapshots:**
    * Each significant screenshot or set of screenshots taken as part of a task **MUST** be analyzed as part of the task's completion. This analysis, including any discrepancies found or validations passed, **MUST** be documented using the standard `VALIDATION REQUEST / CHECKPOINT` template format or a similar structured log entry.
* **(CRITICAL AND MANDATORY) Full Enforcement of Automated UX/UI Snapshotting & OCR Checks:**
    * All code changes that result in any modification to the UI or UX **MUST** comply with the full automated snapshotting and Optical Character Recognition (OCR) validation protocol as defined in `.cursorrules` and related documents.
    * Both automated code reviews (e.g., CI checks, AI self-review) and human code reviews **MUST** verify the presence and correctness of:
        * Generated screenshots in the designated `docs/UX_Snapshots/` directory, following naming conventions.
        * Log entries detailing the OCR validation process and outcomes (pass/fail, discrepancies found).
* **(CRITICAL AND MANDATORY) Blockage and Escalation for Non-Compliance:**
    * If required screenshots or OCR validation logs are missing, incomplete, or show unaddressed failures for UI/UX changes, the merge/commit of these changes **MUST** be blocked.
    * The issue **MUST** be escalated via a SMEAC/VALIDATION REQUEST or equivalent project-defined blocking mechanism, detailing the non-compliance.
* **(CRITICAL AND MANDATORY) OCR Results Processing and Ephemeral Nature:**
    * OCR results (extracted text) **MUST** be processed in-memory by the validation script or AI agent.
    * These results are for immediate, transient validation against expected text content, localization strings, or accessibility labels.
    * **DO NOT STORE OR PERSIST OCR .TXT FILES** or raw OCR output to the repository or long-term storage.
    * If any intermediate text files are generated by the underlying OCR tool as part of its process, these files **MUST** be deleted immediately by the automation script after the necessary text has been extracted and used for in-memory validation.
* **(CRITICAL AND MANDATORY) Canonical Protocol Reference:**
    * The absolute source of truth for the detailed UX/UI snapshotting and OCR validation protocol is always the `.cursorrules` (Master Operating Protocol), supplemented by specific implementation details in `docs/UI_UX_TESTING_GUIDE.MD` and any referenced `*.md` behavior files (e.g., `behaviours_visual-ai-snapshot.md`). All agents and developers **MUST** defer to these documents.

#### Cross-Reference: Enhanced Protocol for Vague or Screenshot-Based Feedback
- For any UI/UX change or code update resulting from vague, emotional, or screenshot-based feedback, the enhanced protocol in `.cursorrules` MUST be followed:
    - Structured planning with `sequential-thinking` MCP
    - Inspiration from `docs/ExampleCode/` and the Corporate Style Guide
    - Research with `perplexity` MCP, cross-referenced with `@BLUEPRINT.md` and the Style Guide
    - Synthesis of a standards-aligned, actionable plan before any code change
    - Escalation for user clarification if ambiguity remains
    - **No code changes may be made until this protocol is fully completed and documented.**
- All actions, sources, and rationale must be logged for auditability.

## CRITICAL AND MANDATORY: Summary & Recommendation Protocol (2024-05-18 Update)

- All user-facing outputs (including SMEAC/VALIDATION REQUEST, checkpoint, and major status updates) MUST include:
  - A **Summary** section at the bottom, immediately before the **Recommendation/Next Steps** section.
  - The **Recommendation** must be clear, actionable, and mandatory.
- **Before writing the Recommendation, the AI agent MUST:**
  1. Use the `sequential-thinking` MCP server to plan the response and next steps.
  2. Use the `context7` MCP to retrieve or cross-reference any additional documentation or context required.
  3. Use the `perplexity` MCP to finalize research and ensure the recommendation is up-to-date and comprehensive.
- The SMEAC/VALIDATION REQUEST template MUST be updated to include these requirements, with the Summary and Recommendation sections at the bottom.

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

## 7.8. MCP Server/Tool Utilization (CRITICAL AND MANDATORY)
- All coding standards, security, and UX guideline processes MUST utilize:
    - `puppeteer` for web analysis
    - `perplexity-ask` for research
    - `momory` for information storage/recall
    - `context7` for latest documentation
    - `sequential-thinking` for planning/analysis
- These are REQUIRED for all code review, UX/UI validation, and security analysis. Violation triggers P0 STOP EVERYTHING.

## 7.9. (CRITICAL AND MANDATORY) Mock/Fake Data & Integration Prohibition and Enforcement

- Mock/fake data, services, or integrations are permitted ONLY for development, testing, or sandbox environments.
- Every instance MUST be explicitly logged as technical debt in @TASKS.MD and trigger an update to @BLUEPRINT.MD, documenting the current state and plan for real integration.
- It is STRICTLY FORBIDDEN to ship any milestone (Alpha, Beta, Production, App Store, etc.) with features that use mock/fake data, services, or integrations.
- All milestone definitions MUST explicitly prohibit shipping features with mock/fake dependencies.
- Any use of mock/fake data/services/integrations MUST create subtasks for real integration and user validation, tracked to completion before release.
- This rule is compulsory and enforced at every milestone checkpoint and release process. Reference .cursorrules for full enforcement protocol.

---
*Adherence to these comprehensive coding standards, robust security practices, and meticulous UX/UI guidelines is not merely encouraged but is a fundamental, non-negotiable requirement for contributing to this project. These standards are essential for creating high-quality, secure, maintainable, and user-delighting software.*

* **(CRITICAL AND MANDATORY) macOS UI/UX Best Practices Compliance:**
    * All best practice rules for UI/UX, dynamic layout, responsive resizing, and accessibility **ARE COMPULSORY** and **MUST** be followed at all times. This includes, but is not limited to:
        * Using standard SwiftUI layout containers (e.g., `NavigationSplitView`, `HSplitView`, `VSplitView`, `GeometryReader`, `ScrollView`) for dynamic and responsive layouts.
        * Ensuring all content, including text, icons, and controls, dynamically resizes and adapts to window size changes without truncation or cutoff.
        * Avoiding fixed frame sizes unless absolutely necessary; prefer flexible, relative sizing and padding.
        * Sidebar width **MUST** be configurable via a constant (e.g., `LayoutConstants.sidebarWidth`).
        * Sidebar items (icons and text) **MUST** be clearly legible, with proper font size, spacing, and alignment.
        * Text **MUST NOT** be truncated; use line limits, wrapping, or ensure sufficient width.
        * All UI elements **MUST** be accessible, with appropriate accessibility labels, traits, and identifiers.
        * Custom headers/toolbars **MUST** have their dimensions and typography defined in constants and **MUST NOT** conflict with system navigation elements.
    * **Compliance with these best practices is required for all macOS UI/UX code. Non-compliance is considered a critical error.**