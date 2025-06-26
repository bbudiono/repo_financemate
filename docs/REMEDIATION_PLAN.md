# AI DEV AGENT REMEDIATION PLAN

**OBJECTIVE:** Restore the `FinanceMate-Sandbox` project to a buildable, architecturally sound, and securely configured state.

**PRECONDITIONS:** Execute each phase in order. Do not proceed to the next phase until the current one is successfully completed and verified.

---

### PHASE 1: ACHIEVE INITIAL COMPILATION (Resolve COMP-001)

**Goal:** Fix the most immediate compilation error to enable further diagnostics.

**Action 1.1: Modify Source File**
Apply the following one-line change to make the `AgentTaskType` enum conform to `Equatable`.

```swift
// FILE: _macOS/FinanceMate-Sandbox/FinanceMate-Sandbox/Services/MLACS/FinanceMateAgents.swift

// ... existing code ...
public enum AgentTaskType: Equatable {
// ... existing code ...
```

**Action 1.2: Attempt Build**
Execute the test script. This build is **expected to fail**, but with a *different* error than before (likely related to duplicate types). Capturing this new error is the goal.

```bash
./_macOS/FinanceMate-Sandbox/run_sandbox_tests.sh
```

**Deliverable:** The complete, unedited output from the build script.

---

### PHASE 2: REPAIR PROJECT ARCHITECTURE (Resolve ARCH-003)

**Goal:** Fix the broken dependency between the sandbox and the main application.

**Action 2.1: Modify Xcode Project File**
This is a critical, manual edit of the `project.pbxproj` file. The goal is to add a target dependency.

*   **Locate:** The `PBXNativeTarget` section for `FinanceMate-Sandbox` (ID: `9D478BB92DDDCF7E0089DCB7`).
*   **Find:** The empty `dependencies` array within that section.
*   **Add:** A new `PBXTargetDependency` entry. You will need to find the UUID for the main `FinanceMate` target from its own project file (`_macOS/FinanceMate/FinanceMate.xcodeproj/project.pbxproj`) and insert it here. The result should look conceptually like this (UUID will vary):

```text
// FILE: _macOS/FinanceMate-Sandbox/FinanceMate-Sandbox.xcodeproj/project.pbxproj

// ... inside the PBXNativeTarget for FinanceMate-Sandbox ...
            dependencies = (
                {
                    isa = PBXTargetDependency;
                    target = /* UUID_OF_FINANCEMATE_APP_TARGET_HERE */;
                    targetProxy = /* ...new PBXContainerItemProxy entry... */;
                },
            );
// ...
```
*Note: This is a complex operation. An alternative is to open the project in Xcode, drag the `FinanceMate` target into the "Frameworks, Libraries, and Embedded Content" section of the `FinanceMate-Sandbox` target's "General" tab, and save.*

---

### PHASE 3: CLEANUP AND DEDUPLICATION (Resolve ARCH-001, ARCH-002)

**Goal:** Remove the duplicated source files from the sandbox now that it can see the production code.

**Action 3.1: Delete Duplicated Files**
Execute the following commands from the workspace root:

```bash
rm "_macOS/FinanceMate-Sandbox/FinanceMate-Sandbox/Services/MLACS/FinanceMateAgents.swift"
# Add rm commands for any other duplicated files discovered during the build phase.
```

**Action 3.2: Remove References from Project**
The file references to the deleted files must also be removed from `_macOS/FinanceMate-Sandbox/FinanceMate-Sandbox.xcodeproj/project.pbxproj`. This is best done via Xcode to avoid corrupting the project file.

---

### PHASE 4: SECURE THE SANDBOX (Resolve SEC-003, SEC-004)

**Goal:** Align the sandbox security model with the production model.

**Action 4.1: Overwrite Entitlements**
The sandbox entitlements are dangerously permissive. Replace them with the production ones.

```bash
cp "_macOS/FinanceMate/FinanceMate.entitlements" "_macOS/FinanceMate-Sandbox/FinanceMate-Sandbox/FinanceMate-Sandbox.entitlements"
```

---

### PHASE 5: VERIFY THE FIX

**Goal:** Achieve a successful build and test run.

**Action 5.1: Clean and Build**
Perform a clean build to ensure all changes are correctly applied.

```bash
xcodebuild clean -project _macOS/FinanceMate-Sandbox/FinanceMate-Sandbox.xcodeproj -scheme "FinanceMate-Sandbox"
```

**Action 5.2: Execute Tests**
Run the test script again.

```bash
./_macOS/FinanceMate-Sandbox/run_sandbox_tests.sh
```

**Deliverable:** The final build and test log. Success is defined as `** TEST SUCCEEDED **`. 