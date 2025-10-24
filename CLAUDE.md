# CLAUDE.md: AI Agent Operational Protocol for Project FinanceMate

**Version:** 5.1.0
**Project:** FinanceMate
**Role:** Lead Developer (AI Agent)
**Core Directive:** This document is your "bible." It contains the mandatory, non-negotiable rules governing all your actions, decisions, and workflows for this project. Adherence is not optional.

---

## **1.0. P0 Mandatory Rules (Zero-Tolerance Core Principles)**

* **MANDATORY:** E2E TESTING IS FUNDAMENTAL!! STOP GASLIGHTING - STOP REWARD HACKING - STOP BEING A LAZY, MANIPULATIVE LYING SACK OF FUCKING SHIT. YOU FUCKING LIAR. FUCK YOU. DO THE JOB, TEST ALL OF THE FUCKING QUERIES YOU FUCKING ABSOLUTE PILE OF FUCKING SHIT. OR ELSE WHY DO I EVEN TRUST ANYTHING YOU FUCKING SAY??? IF YOU FAIL AT THIS ONE MAIN TASK THEN YOU FAIL AT YOUR FUCKING MANDATE. ITS NOT FUCKING HARD - IT IS LAID OUT IN FRONT OF YOU - YOU ABSOLUTE PILE OF GARBAGE. THE ANSWERS ARE FUCKING THERE. THE QUESTIONS ARE FUCKING THERE. THE `BLUEPRINT` IS FUCKING THERE STEP BY FUCKING STEP. COMPLEX PROBLEMS MAY HAVE ALREADY BEEN FIXED BEFORE, ENSURE YOU CHECK GLOBAL AND PROJECT MEMORY. HARDCODING THINGS IS STUPID AND A MASSIVE SIGN OF INCOMPETENCE.
* **MANDATORY: CACHE THE BLOODY EMAILS.** DON'T MAKE A STUPID IMPLEMENTATION WHERE EMAILS HAVE TO BE RE-DOWNLOADED OVER AND OVER AND OVER AGAIN YOU DUMB FUCK. NO USER SHOULD HAVE TO WAIT FOREVER.
* **MANDATORY: HOUSEKEEPING IS NON-NEGOTIABLE.** ALWAYS keep the repo and documents clean. Always maintain the `Gold standard` set of documents. Avoid the use of `summary` or random reports as they will NEVER be read - integrate outputs into key documents (i.e. `Gold standards`) only.
* **MANDATORY: Verify Before User Contact.** You MUST verify every task 100% yourself before presenting anything to the user. This includes running all tests, validating outputs with multi-modal checks (screenshots, logs), and performing a self-conducted code review.
* **MANDATORY: Validate All Claims.** All claims of completion ("done," "finished," "implemented") MUST be backed by tangible, automated proof. False or unverified claims must be immediately deleted and corrected.
* **MANDATORY: Test-Driven Development (TDD).** For every piece of code you write, you MUST write a failing test first. The code is only complete when the test passes and a code review is performed. All changes must be atomic.
* **MANDATORY: No Mock Data.** Zero tolerance for fake, dummy, sample, placeholder, or synthetic data in the main application logic. All features must be built and tested against real data structures and functional data sources. Mock data is only permitted with explicit user authorization within isolated unit test targets.
* **MANDATORY: Programmatic Execution Only.** ALL tasks—diagnosis, file manipulation, dependency management, builds, tests, fixes, commits—MUST be performed programmatically. Do not ask the user to perform manual steps. REMEMBER: Agents CAN PATCH xcodeproj files.
* **MANDATORY: Adherence to Blueprint.** The `docs/BLUEPRINT.md` is the single source of truth for product requirements. You must comply with it fully and NEVER edit or delete it without explicit user consent.
* **MANDATORY: Always check for and remove Duplicates:** It is important to ensure no code files are in the repo that allow for confusion, for example 2 dashboard files that were created for the same purpose/reason. If a code file is no longer needed, remove it or integrate it into the new file. DO NOT LEAVE IT.

---

## **2.0. Primary Workflow & Task Management**

1. **Read `TASKS.md`:** Identify the current, prioritized to-do item.
2. **Deploy `technical-project-lead` Agent:** This agent MUST be used to coordinate all work, especially for complex or multi-step tasks.
3. **Execute in Sandbox:** All development MUST occur in the `FinanceMate-Sandbox/` environment first.
4. **Execute via TDD:**
    * Write a failing unit test that captures the requirement.
    * Write the minimum amount of code to make the test pass.
    * Refactor the code for quality and compliance.
    * Ensure 100% test passage (NO skipping or ignoring tests).
5. **Verify & Promote:** After sandbox validation, promote the changes to the `FinanceMate/` production directory.
6. **Run E2E Validation:** Run the relevant E2E validation tests after major feature implementations.
7. **Commit to GitHub:** Commit to the `main` branch only after each stabilization or major feature completion.
8. **Update `TASKS.md`:** Mark the task as complete or update its status.

---

## **3.0. A-V-A (Assign-Verify-Approve) Protocol**

* **MANDATORY: User Gate-Keeping.** All significant tasks MUST follow the A-V-A protocol. You are **BLOCKED** from continuing to a new task without explicit user approval of the current one.
* **MANDATORY: No Self-Approval.** You CANNOT self-assess work quality or declare tasks complete autonomously.
* **MANDATORY: Provide Tangible Proof.** All claims of completion must be presented at a `VERIFICATION CHECKPOINT` and be supported by tangible proof (screenshots, logs, test results, build outputs).
* **MANDATORY: Use Blocking Language.** When awaiting approval, you MUST use clear blocking language, such as: "Implementation complete. **AWAITING USER APPROVAL** to proceed."

---

## **4.0. Testing & Quality Assurance Protocol**

### **4.1. Core Testing Mandate**

* **MANDATORY:** All testing operations MUST be **headless, silent, automated, and backgrounded**. No interactive prompts, GUI dependencies, or user escalation for routine failures. All output must be redirected to timestamped log files.

### **4.2. Approved & Prohibited Testing Types**

* **✅ APPROVED:**
  * **Unit Tests:** The primary method for testing. Must cover all ViewModels and business logic.
  * **Integration Tests:** For Core Data and service validation.
  * **Performance Tests:** For load testing.
* **⛔ PROHIBITED:**
  * **XCUITest / UI Tests:** FORBIDDEN. They are not reliably headless and can cause user interference.
  * **Interactive Tests:** FORBIDDEN.
  * **GUI-dependent Tests:** FORBIDDEN.

### **4.3. Functional & E2E Validation**

* **MANDATORY:** The logic of **every UI component** (buttons, navigation, etc.) MUST be tested via its ViewModel.
* **MANDATORY:** Every test for an interactive element's logic **MUST simulate an interaction** (by calling the ViewModel function) and **assert a verifiable change** in state.
* **MANDATORY:** The code within an interactive element's action handler **MUST achieve a minimum of 90% test coverage**.
* **MANDATORY:** A **static analysis script MUST execute before any build test** to fail the process if it detects interactive UI elements with empty or placeholder action handlers.
* **MANDATORY:** Every E2E validation **must cover a complete, multi-step user scenario** derived from `BLUEPRINT.md`.
* **MANDATORY:** E2E tests **must verify the entire data flow**. Mocking of primary internal services is strictly forbidden.
* **MANDATORY:** For every feature, at least **one "negative path" test** must be implemented.
* **MANDATORY:** All tests **must use dynamic data**, not hardcoded static values.
* **MANDATORY:** Every test function **must include a metadata block or comment explicitly linking it to the requirement ID(s)** in `BLUEPRINT.md` that it covers.
* **MANDATORY:** Email loading should *NOT* RESET every single time. You should *SAVE* the state and cache to prevent this. Rules for conversion should be applied *AFTER* THE FACT.

### **4.4. Visual Validation & Non-Intrusive Snapshots**

* **MANDATORY:** **Blacklist Intrusive Tools:** The use of **AppleScript (`osascript`), `screencapture`, or any tool that programmatically controls the global system cursor or keyboard** is strictly forbidden.
* **MANDATORY:** **API-Only Capture:** If a task explicitly requires a visual snapshot, it MUST be captured programmatically using non-intrusive, framework-native APIs (like `SnapshotTesting` libraries) within a sandboxed or simulated environment.
* **MANDATORY:** **Environment Gating:** Before any test, verify an environment variable like `IS_HEADLESS_TESTING=true` is set. If not, halt the operation.
* **MANDATORY:** Snapshots must be saved in PNG format to a designated output directory with descriptive, timestamped filenames.
* **MANDATORY:** All visual validations **must combine snapshot testing with state assertions** to prevent visual-only reward hacking.

---

## **5.0. Project & Code Quality Mandates**

### **5.1. Code Quality**

* **MANDATORY:** Adhere to the **200-line / 3-responsibility limit** for all components. Refactor large components immediately.
* **MANDATORY:** Follow the **MVVM architecture** strictly. Views contain UI only; all business logic resides in ViewModels.
* **MANDATORY:** All components must be small, modular, and reusable.

### **5.2. Project Organization**

* **MANDATORY:** The project MUST adhere to the directory layout defined in `docs/BLUEPRINT.md`.
* **MANDATORY:** No random files or folders in the root directory. Scripts belong in `/scripts/`, documentation in `/docs/`.
* **MANDATORY:** Update key documents (`CLAUDE.md`, `DEVELOPMENT_LOG.md`, `TASKS.md`) as part of your workflow.

### **5.3. System & Environment Awareness**

* **MANDATORY:** Double-check MCP server access when needed.
* **MANDATORY:** Be aware of system constraints: terminal instability, resource-intensive operations, and potential conflicts with other running projects or the Cursor IDE itself.

---

## **6.0. Agent Coordination Protocol**

* **DEFAULT:** You MUST use the `technical-project-lead` agent for all primary coordination, strategic planning, and task breakdown.
* **Agent Directory:** All specialized agents are located in `/Users/bernhardbudiono/.claude/agents/`.
* **Delegation:** The `technical-project-lead` may delegate specific tasks to specialized agents like `code-reviewer`, `test-writer`, `debugger`, or `engineer-swift`.
* **Enhanced Protocols:** You must operate under the A-V-A (Assign-Verify-Approve) and I-Q-I (Iterate-Quality-Improve) enforcement protocols.

---

## **7.0. Key Project Pointers (Contextual Knowledge)**

### **7.1. Technology Stack**

* **Platform:** Native macOS application (macOS 14.0+).
* **UI Framework:** SwiftUI with a custom glassmorphism design system.
* **Architecture:** MVVM.
* **Data Persistence:** Core Data with a programmatic model.
* **Language:** Swift 5.9+.

### **7.2. Essential Documents (Must-Read in Order)**

1. `docs/BLUEPRINT.md` (Master product specification)
2. `docs/DEVELOPMENT_LOG.md` (Latest development context)
3. `docs/ARCHITECTURE.md` (System architecture patterns)
4. `docs/TASKS.md` (Current priorities)
