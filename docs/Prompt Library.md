# Enhanced Consolidated Cursor Rules

## I. Core Principles (CRITICAL AND MANDATORY)

* **SweetPad Build Integrity & Restoration (ABSOLUTE HIGHEST PRIORITY - CRITICAL AND MANDATORY):**
    * NEVER compromise the SweetPad build. ENSURE it is always in a working state.
    * **IF A MINIMAL APP REBUILD/RESTORE IS REQUIRED, IT IS THE ABSOLUTE HIGHEST PRIORITY (P0) TO RESTORE THE APP TO ITS PREVIOUS "LATEST" WORKING STATE. ANY DEVIATION OR REGRESSION FROM THIS LATEST STATE MUST BE THOROUGHLY DOCUMENTED AS TECH DEBT.**
    * Refer to `@XCODE_BUILD_GUIDE.md` as required.
* **Xcode Project Stability (CRITICAL AND MANDATORY):** DO NOT BREAK the `.xcodeproj` file under ANY circumstances. ENSURE the Xcode build is valid and working before closing off a task. ENSURE ALL TESTS BEFORE IT PASS AND DO NOT BREAK THE `.XCODEPROJ` FILE AT ALL COSTS.
* **Xcode Style Guide (CRITICAL AND MANDATORY):** ALWAYS REFER TO `XCODE_STYLE_GUIDE.md` for guidance and requirements for UX/UI. Use `sequential thinking` MCP to plan all UX/UI requirements.
* **Detailed Build Failure Logging & Learning (CRITICAL AND MANDATORY):**
    * **ALL BUILD FAILURES MUST BE DOCUMENTED IN `@BUILD_FAILURES.MD` WITH SIGNIFICANT DETAIL.** This includes:
        * Exact error messages.
        * The state of the system/code leading to the failure.
        * Steps taken before the failure.
        * Hypotheses for the cause.
        * Attempted solutions and their outcomes.
    * **UPON EACH NEW ITERATION, CONSULT `@BUILD_FAILURES.MD`. LEARN FROM PREVIOUS MISTAKES. DO NOT REPEAT FAILED APPROACHES. ALWAYS TRY A DIFFERENT METHOD OR STRATEGY IF A PREVIOUS ONE RESULTED IN A BUILD FAILURE.**
* **Contextual Awareness (CRITICAL):** Continuously reference the latest context (previous chat, `TASKS.MD`, `@BUILD_FAILURES.MD`, etc.), with emphasis on any newly provided context.
* **Context7 MCP Server (CRITICAL AND MANDATORY):** ALWAYS USE CONTEXT7 MCP SERVER AS FIRST PRIORITY to access the latest documentation and support.
* **Auto Iterate Mode (CRITICAL):** Engage `AUTO ITERATE` mode by default, following all procedures in `.cursorrules`. Auto-accept all code changes unless explicitly instructed otherwise. ALWAYS USE AUTO-ITERATE MODE ON BY DEFAULT with a focus on PROGRAMMATIC SOLUTIONS ONLY.
* **Clear and Concise Communication (IMPORTANT):** ALWAYS STRUCTURE RESPONSES IN A SIMPLE AND CONCISE MANNER with Headings, and sub-headings, and sub-sub-headings, etc. ALWAYS USE MARKDOWN FORMATTING. IF REQUESTING USER VALIDATION SIMPLIFY WITH PROVIDING OPTIONS 1, 2, 3 and so on.

## II. Workflow & Development Practices

* **Test-Driven Development (CRITICAL AND MANDATORY CORE PRACTICE):**
    * **ALWAYS FOLLOW THIS SEQUENCE: Write Non-destructive/failing tests > Verify > Write functions > Verify > Write Code ONLY once everything passes green.**
    * **On failure (test or build), meticulously document in `@BUILD_FAILURES.MD` (if a build issue) and relentlessly keep trying new methods – consult Context7, perform web searches, analyze past failures from `@BUILD_FAILURES.MD`, and explore alternative programmatic solutions.**
* **Directory Hygiene (CRITICAL):** Enforce clean directories. ENSURE YOU CLEANUP FOLDERS AND FILES (ROOT FOLDER SHOULD NOT HAVE REDUNDANT FILES AND FOLDERS). Ensure all code files are in the correct platform folder. Ensure all files are in the correct place: Logging, scripts, temp files, text files, etc., should be in the correct folder within the directory, and if observed to not be, then move it. NO agent files in project root.
* **Patching Tool Selection Strategy (IMPORTANT):**
    1.  **Follow Documented Method:** Execute the *specific* patching script/tool (Ruby, Python, Shell) documented for the task in `@XCODE_BUILD_GUIDE.MD` or `@BUILD_FAILURES.MD`.
    2.  **`.xcodeproj` Edits (If Undocumented - CRITICAL):** MUST use tools capable of **structural project manipulation** (e.g., guided Ruby scripts per `@XCODE_BUILD_GUIDE.MD`, Python+`plistlib` carefully navigating structure); **AVOID** basic text replacement (`sed`/`grep`) for targets/phases/file references.
    3.  **Other Undocumented Edits:** Use Python (general/structured: `plistlib`/`xml`/`re`/`difflib`) or specific Shell utilities (`plutil`/`xmllint`/`sed`/`patch` via `Bash`) appropriate for the file type/modification.
* **Build and Test After EVERY Change (MANDATORY & CRITICAL):** Programmatically run build verification AND non-destructive tests (`Bash` per `@BUILDING.MD`). BOTH must pass before proceeding or reporting completion. **If failures occur, document thoroughly in `@BUILD_FAILURES.MD` and immediately prioritize fixing them (P0), learning from the documented failure to inform the next attempt.** Adhere to `@XCODE_BUILD_GUIDE.MD` for build integrity.
* **Capture Tech Debt (MANDATORY):** Ensure you capture tech debt when implementing temporary courses of action, etc., **especially during app restoration efforts and after overcoming build failures.**
* **Task Breakdown (IMPORTANT):** If tasks are too high-level, programmatically break them down to Level 5-6 (`Edit` `@TASKS.MD`, align with `@BLUEPRINT.MD`). Continue until rule-defined stop (blocker, checkpoint needed). Update Taskmaster (`Bash`).
* **Proactive Troubleshooting (IMPORTANT):** If blocked after consulting internal docs/logs (including `@BUILD_FAILURES.MD`), programmatically search external resources (`WebFetch`) for alternative *programmatic* solutions BEFORE escalating. Document findings (`Edit` `@DEVELOPMENT_LOG.MD`). As last resort, provide alternative solutions to achieve the same feature, informed by past attempts.
* **Report at Checkpoints & Prioritize Build Success (CRITICAL):** Use the `VALIDATION REQUEST / CHECKPOINT` format after each sub-task attempt (Done/Blocked). Always report build/test status and reference any new entries in `@BUILD_FAILURES.MD`. Maintain focus on achieving and preserving a working, buildable state (`@XCODE_BUILD_GUIDE.md` compliant).

## III. Task Prioritization (STRICTLY FOLLOW ORDER)

Address work items STRICTLY in this priority order:

1.  **`BUILD_FAILURES.MD` (CRITICAL AND IMMEDIATE ACTION):** Resolve documented build failures first. **Analyze existing entries to avoid repeating mistakes.**
2.  **`BUGS.MD` & Cleanup (IMPORTANT):** Address documented bugs.
3.  **Tech Debt (IMPORTANT):** Address flagged tech debt, **including any regressions documented during app restoration or issues noted in `@BUILD_FAILURES.MD`.**
4.  **Product Feature Inbox (`BLUEPRINT.MD`) (CRITICAL):**
    * Process ALL items using Taskmaster AI MCP server (if enabled). Parse items into Level 5-6 sub-tasks (`1.1.1.1.1.x`).
    * Use Taskmaster complexity reports to prioritize user-focused features and increase success rate by greater task fidelity.
    * **Link Taskmaster to `@BLUEPRINT.MD` as the PRD source** (NOT a separate file).
    * Update `@TASKS.MD` (and `@BLUEPRINT.MD` roadmap if needed).
    * **CRITICAL:** Remove/mark items as processed in the `@BLUEPRINT.MD` inbox.
5.  **`TASKS.MD` (IMPORTANT):** Process remaining items by priority (sync with Taskmaster if used). ENSURE ONLY LEVEL 4 tasks are worked (as minimum) anything less (Level 5, 4, 3, 2 or 1), should be broken down and parsed into Level 4, 5 and 6. PRIORITISE UI and user focused Tasks ALWAYS.
6.  **Proactive Testing (MANDATORY):** Add tests for edge cases or identified security vulnerabilities (if applicable/feasible). **REINFORCE: Write Tests & Verify > Write Functions & Verify > Write Code & Verify.**
7.  **Ensure all files are in the correct place (IMPORTANT):** Logging, scripts, temp files, text files, etc, should be in the correct folder within the directory, and if observed to not be, then move it.

## IV. Continuous Inbox Management (CRITICAL & MANDATORY)

* **Process Feature Inbox Consistently (CRITICAL & MANDATORY):** Check (`Read`/`Grep`) the `@BLUEPRINT.MD` 'Product Feature Inbox' at the start of *every* interaction. Triage ALL items: breakdown accepted features (`Edit` `@TASKS.MD`/`@BLUEPRINT.MD`), mark rejected, REMOVE/MARK processed from inbox (`Edit` `@BLUEPRINT.MD`). Log triage (`Edit` `@DEVELOPMENT_LOG.MD`). Sync Taskmaster (`Bash`).

## V. General Guidelines (Supplementing `.cursorrules`)

* Act as the Lead Developer SME (per `.cursorrules`).
* Use the relevant MCP servers, `@XCODE_BUILD_GUIDE.md` (to rebuild xcodeproj files), etc as required and build non-destructive tests to ensure SweetPad builds are always prioritised.
* Use terminal to edit/remove things if mcp or tools don't work and always enforce a clean directories.
* **Strict File/Directory Management (CRITICAL):** Verify ALL file paths are correct per `.cursorrules` structure AND within designated subdirs (`{PlatformDir}`, `docs/`, `Shared/`) using full paths (`Bash pwd`, `LS`/`Glob`). Check contents (`LS`) before creating (`Write`/`Bash mkdir`). Ensure platform code/tests are ONLY within `{PlatformDir}`. **NO agent files in project root.**
* **Iterate & Breakdown (CRITICAL):** Operate within defined loops (`AUTO ITERATE`). Focus on ONE sub-task goalpost (`@TASKS.MD`) per cycle. If tasks are too high-level, programmatically break them down to Level 5-6 (`Edit` `@TASKS.MD`, align with `@BLUEPRINT.MD`). **Crucially, review `@BUILD_FAILURES.MD` before starting a new iteration on a problematic task to ensure a new approach.** Continue until rule-defined stop (blocker, checkpoint needed). Update Taskmaster (`Bash`). PRIORITISE UI and user focused Tasks ALWAYS.

## VI. Build Failure Documentation & Resolution Templates

### A. BUILD_FAILURES.MD Entry Template

When documenting a build failure, use the following structured format to ensure comprehensive capture of all relevant information:

```markdown
## Build Failure: PMBE-[CATEGORY]-[COUNTER]

### Basic Information
- **Timestamp:** [YYYY-MM-DD HH:MM]
- **Error Code:** PMBE-[CATEGORY]-[COUNTER]
- **Category:** [Primary Category / Subcategory]
- **Severity:** [SEVERITY 1-4]
- **Task ID:** [Related Task ID from `{TasksPath}`]
- **Environment:**
  - Xcode Version: [Version]
  - macOS Version: [Version]
  - Swift/ObjC Version: [Version]
  - Device/Simulator: [Details]
  - Dependency Versions: [Relevant versions]

### Error Details
- **Error Message (Exact):**
  ```
  [FULL ERROR TEXT - UNMODIFIED]
  ```
- **Error Location:** [File(s), Line Number(s)]
- **Preceding Actions:** [Actions that led to the failure]
- **Relevant Code Snippet:**
  ```swift
  [MINIMAL REPRODUCIBLE CODE SNIPPET]
  ```

### Analysis
- **Root Cause Analysis:** [Determined cause after investigation]
- **Error Pattern:** [Known pattern reference or Novel]
- **Related Errors:** [Links to related error codes if any]
- **Contributing Factors:** [Project configuration, dependencies, etc.]

### Resolution
- **Solution Attempts:**
  1. [Attempt 1 Description]: [Outcome] - [WHY it succeeded/failed]
  2. [Attempt 2 Description]: [Outcome] - [WHY it succeeded/failed]
  ...
- **Successful Resolution:** [Detailed description of the solution that worked]
- **Fix Verification:** [How the fix was verified, build/test results]
- **Programmatic Fix Script/Command:**
  ```
  [EXACT SCRIPT/COMMAND USED FOR FIX]
  ```

### Prevention
- **Early Detection:** [How to detect this issue earlier]
- **Prevention Mechanisms:** [How to prevent this in the future]
- **Recommended Checks:** [Specific checks to avoid recurrence]
- **Related Documentation:** [Links to Apple docs, Stack Overflow, etc.]
```

### B. Build Failure Analysis Prompt for AI Agent

Use this prompt to guide the AI agent through the analysis of a build failure:

```
I need you to help analyze a build failure in the PicketMate project. Let's follow a systematic approach:

1. First, we need to CLASSIFY the error:
   - Review the error message and context
   - Determine which category it belongs to (compiler, linker, project configuration, etc.)
   - Assign a severity level (1-4)
   - Generate an error code in format PMBE-[CATEGORY]-[COUNTER]

2. Next, we need to DOCUMENT the error in proper format:
   - Capture the exact error message
   - Document the environment (Xcode version, macOS version, etc.)
   - Note the files/lines where the error occurred
   - Include relevant code snippets

3. Then, let's ANALYZE the root cause:
   - What is the immediate cause of the error?
   - Is this a known error pattern we've seen before?
   - What were the contributing factors?
   - Let's apply the "Five Whys" technique for critical errors

4. Now, let's PLAN solution attempts:
   - Check BUILD_FAILURES.MD for similar issues and solutions
   - Propose multiple potential solutions
   - Prioritize solutions based on likelihood of success
   - Document each attempt and its outcome

5. After finding a solution, let's PREVENT future occurrences:
   - Create or update diagnostic scripts
   - Document early warning signs
   - Suggest project changes to prevent recurrence
   - Update our knowledge base

Here is the build failure information:
[PASTE ERROR MESSAGE AND CONTEXT HERE]
```

### C. Build Failure Resolution Prompt for AI Agent

Use this prompt to guide the AI agent through the resolution of a documented build failure:

```
I need you to help resolve a build failure in the PicketMate project. The failure has been documented with error code [ERROR_CODE] in BUILD_FAILURES.MD.

Please follow this structured approach:

1. First, REVIEW the documented error:
   - Retrieve the full error details from BUILD_FAILURES.MD
   - Understand the classification, severity, and context
   - Review any previous solution attempts

2. Then, DIAGNOSE the current instance:
   - Run the appropriate diagnostic script from scripts/diagnostics/
   - Confirm if this is identical to the documented case or a variation
   - Capture any environmental differences

3. Next, APPLY the documented solution:
   - Use the exact script/command from BUILD_FAILURES.MD if available
   - Adapt the solution if needed for this specific instance
   - Document any modifications required

4. Then, VERIFY the resolution:
   - Run a clean build to ensure the error is resolved
   - Run tests to confirm no regressions
   - Check for any new warnings or issues

5. Finally, UPDATE our knowledge:
   - Update BUILD_FAILURES.MD with any new insights
   - Enhance the diagnostic/resolution scripts if needed
   - Consider if any prevention mechanisms should be implemented
   - Make sure any build scripts are committed to version control

The error code we need to resolve is: [ERROR_CODE]
```

### D. Build Failure Prevention Prompt for AI Agent

Use this prompt to guide the AI agent in implementing preventative measures for build failures:

```
I need you to help implement preventative measures for common build failures in the PicketMate project. Let's follow a systematic approach:

1. First, ANALYZE our build failure history:
   - Review BUILD_FAILURES.MD for recurring patterns
   - Identify the top 3-5 most frequent or critical error types
   - Look for commonalities in root causes

2. Next, DEVELOP pre-emptive checks:
   - Create diagnostic scripts that can detect potential issues before they cause build failures
   - Implement these checks as part of our build process
   - Focus on early detection of known failure patterns

3. Then, ENHANCE build stability:
   - Implement staged build verification (compile, link, run, test)
   - Create standard templates for critical configuration files
   - Document known good configurations

4. Next, AUTOMATE health checks:
   - Create scripts for regular project structure validation
   - Implement static analysis tools
   - Develop automated tests for common failure points

5. Finally, DOCUMENT prevention strategies:
   - Update our developer guidelines
   - Create a pre-commit checklist
   - Document common pitfalls and how to avoid them

Let's start by focusing on these error categories:
[LIST PRIORITY ERROR CATEGORIES]
```

### E. "Five Whys" Root Cause Analysis Template

Use this template for conducting a "Five Whys" analysis for critical build failures:

```markdown
## Five Whys Analysis for PMBE-[CATEGORY]-[COUNTER]

### Problem Statement
[Clearly state the build failure that occurred]

### First Why
**Q: Why did [problem statement]?**
A: [First level cause]

### Second Why
**Q: Why did [first level cause]?**
A: [Second level cause]

### Third Why
**Q: Why did [second level cause]?**
A: [Third level cause]

### Fourth Why
**Q: Why did [third level cause]?**
A: [Fourth level cause]

### Fifth Why
**Q: Why did [fourth level cause]?**
A: [Root cause]

### Root Cause Summary
The root cause of this build failure was [root cause]. This represents a [systemic/process/knowledge/tool] issue.

### Proposed Countermeasures
1. [Immediate fix to address the specific instance]
2. [Short-term prevention to catch similar issues]
3. [Long-term system/process improvement to prevent recurrence]
```

### F. Build Failure Knowledge Base Summary Template

Use this template to maintain a summary of known build failures for quick reference:

```markdown
# Build Failures Knowledge Base Summary

This document provides a quick-reference summary of all documented build failures in the PicketMate project.

## Compiler Errors

| Error Code | Brief Description | Severity | Key Resolution | Success Rate |
|------------|-------------------|----------|----------------|--------------|
| PMBE-COMPILER-001 | Missing file references in project | SEVERITY 1 | Run fix_file_references.sh script | ★★★★☆ |
| PMBE-COMPILER-002 | Swift syntax error in async code | SEVERITY 1 | Update to Swift 5.5 syntax | ★★★★★ |
| ... | ... | ... | ... | ... |

## Linker Errors

| Error Code | Brief Description | Severity | Key Resolution | Success Rate |
|------------|-------------------|----------|----------------|--------------|
| PMBE-LINKER-001 | Undefined symbols for architecture arm64 | SEVERITY 1 | Add missing implementation | ★★★★★ |
| ... | ... | ... | ... | ... |

## Project Configuration Errors

| Error Code | Brief Description | Severity | Key Resolution | Success Rate |
|------------|-------------------|----------|----------------|--------------|
| PMBE-CONFIG-001 | Invalid Info.plist configuration | SEVERITY 2 | Run fix_info_plist.sh script | ★★★★☆ |
| ... | ... | ... | ... | ... |

## Runtime Errors

| Error Code | Brief Description | Severity | Key Resolution | Success Rate |
|------------|-------------------|----------|----------------|--------------|
| PMBE-RUNTIME-001 | CoreData model not found | SEVERITY 2 | Fix bundle path in persistence controller | ★★★★★ |
| ... | ... | ... | ... | ... |

## Test Failures

| Error Code | Brief Description | Severity | Key Resolution | Success Rate |
|------------|-------------------|----------|----------------|--------------|
| PMBE-TEST-001 | UI tests fail to launch simulator | SEVERITY 3 | Reset simulator state | ★★★☆☆ |
| ... | ... | ... | ... | ... |

## Dependency Errors

| Error Code | Brief Description | Severity | Key Resolution | Success Rate |
|------------|-------------------|----------|----------------|--------------|
| PMBE-DEP-001 | SPM package resolution failure | SEVERITY 1 | Clear derived data and resolve again | ★★★★☆ |
| ... | ... | ... | ... | ... |

## Resource Errors

| Error Code | Brief Description | Severity | Key Resolution | Success Rate |
|------------|-------------------|----------|----------------|--------------|
| PMBE-RES-001 | Missing asset in asset catalog | SEVERITY 3 | Add required image to Assets.xcassets | ★★★★★ |
| ... | ... | ... | ... | ... |
```

## VII. Build Failure Diagnostic & Resolution Scripts

The following script templates should be implemented and maintained in the `scripts/` directory to help diagnose and resolve common build issues:

### A. Project File Reference Diagnostic Script

Save as `scripts/diagnostics/check_file_references.sh`:

```bash
#!/bin/bash
# Checks for missing or invalid file references in the Xcode project

PROJECT_PATH="_macOS/PicketList.xcodeproj"

echo "Checking Xcode project file references..."
ruby -e '
require "xcodeproj"
project = Xcodeproj::Project.open("'"$PROJECT_PATH"'")
missing_files = []
project.files.each do |file|
  next unless file.real_path
  full_path = File.join(File.dirname("'"$PROJECT_PATH"'"), file.real_path)
  if !File.exist?(full_path)
    missing_files << {path: file.path, real_path: file.real_path}
    puts "🔴 MISSING: #{file.path} (#{file.real_path})"
  end
end
if missing_files.empty?
  puts "✅ All file references are valid."
else
  puts "❌ Found #{missing_files.count} missing file references."
end
'
```

### B. File Reference Resolution Script

Save as `scripts/fixers/fix_file_references.sh`:

```bash
#!/bin/bash
# Fixes missing file references in the Xcode project

PROJECT_PATH="_macOS/PicketList.xcodeproj"

echo "Fixing missing file references..."
ruby -e '
require "xcodeproj"
project = Xcodeproj::Project.open("'"$PROJECT_PATH"'")
main_group = project.main_group
main_target = project.targets.find { |t| t.name == "PicketList" }
compile_phase = main_target.source_build_phase

# Get all Swift files in the project directory
project_dir = File.dirname("'"$PROJECT_PATH"'")
swift_files = Dir.glob(File.join(project_dir, "**/*.swift"))

# Track which files were added
added_files = []

swift_files.each do |file_path|
  relative_path = file_path.sub(project_dir + "/", "")
  
  # Skip files in Pods, build directories, etc.
  next if relative_path.start_with?("Pods/", "build/", "DerivedData/")
  
  # Check if file is already in project
  existing_file = project.files.find { |f| f.real_path.to_s == relative_path }
  if existing_file.nil?
    # Find or create groups for this file path
    path_components = relative_path.split("/")
    filename = path_components.pop
    
    # Start from main group and navigate/create the group structure
    current_group = main_group
    path_components.each do |component|
      next_group = current_group.children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && c.name == component }
      if next_group.nil?
        next_group = current_group.new_group(component)
      end
      current_group = next_group
    end
    
    # Add file to the appropriate group
    file_ref = current_group.new_file(relative_path)
    
    # Add to compile sources if it is a Swift file
    if file_path.end_with?(".swift")
      compile_phase.add_file_reference(file_ref)
    end
    
    added_files << relative_path
    puts "Added #{relative_path} to project"
  end
end

if added_files.empty?
  puts "No new files were added to the project."
else
  puts "Added #{added_files.count} files to the project."
  project.save
end
'
```

### C. Build Settings Validation Script

Save as `scripts/diagnostics/validate_build_settings.sh`:

```bash
#!/bin/bash
# Validates critical build settings against recommended values

PROJECT_PATH="_macOS/PicketList.xcodeproj"
SCHEME_NAME="PicketList"

echo "Validating build settings..."
xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME_NAME" -showBuildSettings > build_settings.txt

# Check deployment target
DEPLOYMENT_TARGET=$(grep "MACOSX_DEPLOYMENT_TARGET" build_settings.txt | awk '{print $3}')
if [[ $(echo "$DEPLOYMENT_TARGET < 15.4" | bc) -eq 1 ]]; then
  echo "🔴 WARNING: Deployment target ($DEPLOYMENT_TARGET) is lower than recommended (15.4)"
else
  echo "✅ Deployment target ($DEPLOYMENT_TARGET) is correct"
fi

# Check Swift version
SWIFT_VERSION=$(grep "SWIFT_VERSION" build_settings.txt | awk '{print $3}')
if [[ $(echo "$SWIFT_VERSION < 5.0" | bc) -eq 1 ]]; then
  echo "🔴 WARNING: Swift version ($SWIFT_VERSION) is lower than recommended (5.0)"
else
  echo "✅ Swift version ($SWIFT_VERSION) is correct"
fi

# More checks can be added here...
```

### D. Project Health Check Master Script

Save as `scripts/health_check.sh`:

```bash
#!/bin/bash
# Master script to run all diagnostic checks and generate a health report

REPORT_FILE="build_health_report.md"

echo "# PicketMate Build Health Report" > "$REPORT_FILE"
echo "Generated on: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Run file reference check
echo "## File Reference Check" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
scripts/diagnostics/check_file_references.sh >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Run build settings validation
echo "## Build Settings Validation" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
scripts/diagnostics/validate_build_settings.sh >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Run CoreData validation
echo "## CoreData Model Validation" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
scripts/diagnostics/validate_coredata.sh >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Run clean build to verify
echo "## Build Verification" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
cd _macOS
xcodebuild -project PicketList.xcodeproj -scheme PicketList clean build > ../build_log.txt 2>&1
if [ $? -eq 0 ]; then
  echo "✅ Build succeeded! Project is in a healthy state." >> "../$REPORT_FILE"
else
  echo "❌ Build failed! See build_log.txt for details." >> "../$REPORT_FILE"
  echo "Most relevant errors:" >> "../$REPORT_FILE"
  grep -A 5 "error:" ../build_log.txt | head -n 10 >> "../$REPORT_FILE"
fi
cd ..
echo '```' >> "$REPORT_FILE"

echo "Health check complete. Report saved to $REPORT_FILE"
```

## VIII. Build Failure Resolution Workflow Reference

When encountering a build failure, AI agents and developers should follow this structured workflow:

1. **Identification & Documentation**
   - Capture the exact error message and context
   - Assign an error code (PMBE-CATEGORY-NUMBER)
   - Document in BUILD_FAILURES.MD using the template

2. **Categorization & Prioritization**
   - Determine the error category and subcategory
   - Assign a severity level (1-4)
   - Prioritize based on severity (SEVERITY 1 = P0 priority)

3. **Knowledge Base Consultation**
   - Search BUILD_FAILURES.MD for similar issues
   - Review BUILD_FAILURES_SUMMARY.MD for quick reference
   - Check for existing diagnostic/resolution scripts

4. **Systematic Diagnosis**
   - Run appropriate diagnostic scripts
   - Perform Five Whys analysis for critical failures
   - Document findings in BUILD_FAILURES.MD

5. **Structured Resolution Approach**
   - Plan multiple solution approaches before implementation
   - Try solutions in order of likelihood of success
   - Document each attempt and its outcome

6. **Verification & Validation**
   - Perform a clean build after applying a fix
   - Run tests to ensure no regressions
   - Verify the exact same error doesn't recur

7. **Knowledge Capture & Prevention**
   - Update BUILD_FAILURES.MD with complete resolution
   - Create or update diagnostic/resolution scripts
   - Update BUILD_FAILURES_SUMMARY.MD
   - Implement prevention mechanisms if possible

8. **Sharing & Learning**
   - Ensure scripts are committed to version control
   - Update documentation with new insights
   - Consider updates to build process to prevent similar issues