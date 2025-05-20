# BUILD FAILURES DOCUMENTATION

## Build Failure: PMBE-PROJECT-001

### Basic Information
- **Timestamp:** [2025-05-10 11:43]
- **Error Code:** PMBE-PROJECT-001
- **Category:** project_configuration_errors / xcodeproj_structure
- **Severity:** SEVERITY 1
- **Task ID:** [N/A - Auto Iterate Build Verification]
- **Environment:**
  - Xcode Version: [Check required]
  - macOS Version: [Check required]
  - Swift/ObjC Version: [Check required]
  - Device/Simulator: N/A (macOS build)
  - Dependency Versions: N/A

### Error Details
- **Error Message (Exact):**
  ```
  xcodebuild: error: Unable to load workspace '_macOS/DocketMate.xcodeproj/project.xcworkspace'.
  Reason: The project 'DocketMate' is damaged and cannot be opened due to a parse error. Examine the project file for invalid edits or unresolved source control conflicts.
  CFPropertyListCreateFromXMLData(): Old-style plist parser: missing semicolon in dictionary on line 412. Parsing will be abandoned. Break on _CFPropertyListMissingSemicolon to debug.
  ```
- **Error Location:** _macOS/DocketMate.xcodeproj/project.pbxproj (line 412)
- **Preceding Actions:**
  - Restored project.pbxproj from backup
  - Repaired workspace file
  - Attempted build via MCP and direct xcodebuild
- **Relevant Code Snippet:**
  ```
  [See lines 400-420 of project.pbxproj]
  ```

### Analysis
- **Root Cause Analysis:** Syntax error (likely missing semicolon or bracket) in project.pbxproj at/around line 412, possibly due to manual or automated edits or merge conflict.
- **Error Pattern:** Known (plist parse error, missing semicolon)
- **Related Errors:** N/A
- **Contributing Factors:** Project file restoration, possible merge or edit error.

### Resolution
- **Solution Attempts:**
  1. MCP build: Failed (project not found or parse error)
  2. Direct xcodebuild: Failed (parse error at line 412)
  3. Workspace file repair: No effect
- **Successful Resolution:** Pending (next: restore project.pbxproj from backup)
- **Fix Verification:** Pending
- **Programmatic Fix Script/Command:**
  ```
  cp _macOS/DocketMate.xcodeproj/project.pbxproj.bak_working_20250510004038 _macOS/DocketMate.xcodeproj/project.pbxproj
  ```

### Prevention
- **Early Detection:** Run build after any project file edit; use linter/validator for pbxproj.
- **Prevention Mechanisms:** Always keep backup of known-good project.pbxproj; validate after merges.
- **Recommended Checks:** Validate pbxproj syntax after any automated or manual edit.
- **Related Documentation:** See .cursorrules Section 15, XCODE_BUILD_GUIDE.md

## Build Failure: PMBE-PROJECT-002

### Basic Information
- **Timestamp:** [2025-05-10 11:44]
- **Error Code:** PMBE-PROJECT-002
- **Category:** project_configuration_errors / xcodeproj_structure
- **Severity:** SEVERITY 1
- **Task ID:** [N/A - Auto Iterate Build Verification]
- **Environment:**
  - Xcode Version: [Check required]
  - macOS Version: [Check required]
  - Swift/ObjC Version: [Check required]
  - Device/Simulator: N/A (macOS build)
  - Dependency Versions: N/A

### Error Details
- **Error Message (Exact):**
  ```
  error: Could not compute dependency graph: missingTarget(guid: "8f9c91c36740e65c0fb0be117a540048c2d0741c9810a76b4f7235496fe737e0")
  ** CLEAN FAILED **
  The following build commands failed:
        Compute target dependency graph for package preparation
        Cleaning workspace DocketMate with scheme DocketMate and configuration Debug
(2 failures)
  ** BUILD FAILED **
  The following build commands failed:
        Compute target dependency graph for package preparation
        Building workspace DocketMate with scheme DocketMate and configuration Debug
(2 failures)
  ```
- **Error Location:** _macOS/DocketMate.xcodeproj/project.pbxproj (restored from backup)
- **Preceding Actions:**
  - Documented previous parse error
  - Restored project.pbxproj from backup
  - Attempted build via MCP and direct xcodebuild
- **Relevant Code Snippet:**
  ```
  [N/A - error is in project structure, not code]
  ```

### Analysis
- **Root Cause Analysis:** The restored project.pbxproj references a missing or invalid target GUID, causing the dependency graph computation to fail. This may be due to an incomplete or mismatched backup, or a missing file/resource in the project.
- **Error Pattern:** Known (missingTarget GUID in Xcode project)
- **Related Errors:** PMBE-PROJECT-001
- **Contributing Factors:** Project file restoration, possible backup mismatch, or missing files.

### Resolution
- **Solution Attempts:**
  1. Restored project.pbxproj from backup: Build failed (missingTarget GUID)
  2. Direct xcodebuild: Build failed (same error)
- **Successful Resolution:** Pending (next: escalate to script-based repair or deeper backup analysis)
- **Fix Verification:** Pending
- **Programmatic Fix Script/Command:**
  ```
  [To be determined: may require script to scan/fix missing target references or restore additional files]
  ```

### Prevention
- **Early Detection:** Validate project.pbxproj for missing targets after restoration.
- **Prevention Mechanisms:** Ensure backups are complete and consistent; validate all referenced targets/files exist after restore.
- **Recommended Checks:** Use Xcode project validation tools or scripts after any restore.
- **Related Documentation:** See .cursorrules Section 15, XCODE_BUILD_GUIDE.md

## Build Failure: PMBE-PROJECT_CONFIGURATION-001

### Basic Information
- **Timestamp:** [Auto-generated]
- **Error Code:** PMBE-PROJECT_CONFIGURATION-001
- **Category:** project_configuration_errors / xcodeproj_structure
- **Severity:** SEVERITY 1
- **Task ID:** [Sandbox Build Restoration]
- **Environment:**
  - Xcode Version: [TBD]
  - macOS Version: [TBD]
  - Swift/ObjC Version: [TBD]
  - Device/Simulator: N/A
  - Dependency Versions: [TBD]

### Error Details
- **Error Message (Exact):**
  ```
  Sandbox build system cannot recognize temp Xcode project (_macOS/DocketMate_temp.xcodeproj). All attempts to build in the sandbox have failed. Build system reports: "The project directory exists, but is not recognized as a valid Xcode project."
  Attempts to build as both workspace and project failed. Directory structure was checked and re-copied, but issue persists.
  ```
- **Error Location:** _macOS/DocketMate_temp.xcodeproj
- **Preceding Actions:** Copied original .xcodeproj to temp, attempted build, removed nested directories, cleaned derived data, retried build.
- **Relevant Code Snippet:**
  ```bash
  cp -R _macOS/DocketMate.xcodeproj _macOS/DocketMate_temp.xcodeproj
  xcodebuild -project _macOS/DocketMate_temp.xcodeproj -scheme DocketMate -configuration Debug
  # Also attempted workspace build, cleaned derived data, removed nested dirs
  ```

### Analysis
- **Root Cause Analysis:** Likely project.pbxproj or workspace data corruption, or invalid directory structure after copy. Possible symlink or hidden file issue.
- **Error Pattern:** Known pattern: "Sandboxed Xcode project copy not recognized as valid project."
- **Related Errors:** [See previous build failures for project structure issues]
- **Contributing Factors:** Copying .xcodeproj as a directory may not preserve all internal references correctly.

### Resolution
- **Solution Attempts:**
  1. Copied .xcodeproj directory directly: Failed - not recognized as valid project.
  2. Removed nested directories: Failed - still not recognized.
  3. Cleaned derived data: Failed - no effect.
  4. Attempted build as workspace: Failed - not recognized.
  5. Will run automated diagnostic script next.
- **Successful Resolution:** [TBD]
- **Fix Verification:** [TBD]
- **Programmatic Fix Script/Command:**
  ```bash
  # To be added after diagnostic/fix
  ```

### Prevention
- **Early Detection:** Validate temp project structure after copy before build.
- **Prevention Mechanisms:** Use diagnostic scripts to check .xcodeproj integrity after copy.
- **Recommended Checks:** Directory structure, project.pbxproj validity, workspace data.
- **Related Documentation:** [Apple docs on Xcode project structure]

## Build Failure: PMBE-TOOLING-001

### Basic Information
- **Timestamp:** $(date '+%Y-%m-%d %H:%M')
- **Error Code:** PMBE-TOOLING-001
- **Category:** Tooling/Automation
- **Severity:** SEVERITY 3
- **Task ID:** 24.3
- **Environment:**
  - Xcode Version: [fill]
  - macOS Version: [fill]
  - Swift Version: [fill]
  - Device/Simulator: N/A
  - Dependency Versions: SwiftLint [fill]

### Error Details
- **Error Message (Exact):**
  "Missing fix-swiftlint.sh script for auto-fixing SwiftLint issues. Manual intervention required to fix style violations, increasing risk of build/test failures and inconsistent code style."
- **Error Location:** scripts/
- **Preceding Actions:** Attempted to run auto-fix for SwiftLint issues; script not found.
- **Relevant Code Snippet:**
  ```bash
  ./scripts/fix-swiftlint.sh
  # Not found
  ```

### Analysis
- **Root Cause Analysis:**
  The project lacked an auto-fix script for SwiftLint, requiring manual fixes for style violations. This increased the risk of inconsistent code style and build/test failures due to unaddressed lint errors.
- **Error Pattern:** Known (missing automation script)
- **Related Errors:** PMBE-TOOLING-002 (if future automation scripts are missing)
- **Contributing Factors:**
  - Incomplete automation for code style enforcement
  - Reliance on manual developer intervention

### Resolution
- **Solution Attempts:**
  1. Searched for fix-swiftlint.sh in scripts/ and project root: Not found
  2. Created scripts/fix-swiftlint.sh with usage instructions, error handling, and SwiftLint integration: Success
- **Successful Resolution:**
  The fix-swiftlint.sh script was created and integrated with the pre-commit hook system. Developers can now auto-fix style issues before committing, reducing build/test failures and improving code consistency.
- **Fix Verification:**
  Ran the script on files with known style issues; verified corrections. Pre-commit hook blocks commits with unresolved issues.
- **Programmatic Fix Script/Command:**
  ```bash
  ./scripts/fix-swiftlint.sh
  ```

### Prevention
- **Early Detection:**
  Add checks for required automation scripts in pre-commit/pre-push hooks.
- **Prevention Mechanisms:**
  Ensure all required scripts (lint, build, test, backup) exist and are executable. Reference them in documentation and hooks.
- **Recommended Checks:**
  - Run ./scripts/fix-swiftlint.sh before every commit
  - Keep automation scripts up to date
- **Related Documentation:**
  - README.MD (script usage)
  - DEVELOPMENT_LOG.MD (automation updates)

## Build Failure: PMBE-COMPILER-001

### Basic Information
- **Timestamp:** 2024-06-10 00:00
- **Error Code:** PMBE-COMPILER-001
- **Category:** compiler_errors / undefined_symbols
- **Severity:** SEVERITY 1 (Critical)
- **Task ID:** 25.4
- **Environment:**
  - Xcode Version: [TBD]
  - macOS Version: [TBD]
  - Swift/ObjC Version: [TBD]
  - Device/Simulator: [N/A]
  - Dependency Versions: [TBD]

### Error Details
- **Error Message (Exact):**
  ```
  No such module 'XCTest'
  ```
- **Error Location:** _macOS/DocketMateTests/Models/DocumentViewModelTests.swift, line 3
- **Preceding Actions:** Created placeholder test file for DocumentViewModel as part of TDD and build failure prevention.
- **Relevant Code Snippet:**
  ```swift
  import XCTest
  @testable import DocketMate
  ```

### Analysis
- **Root Cause Analysis:** Likely missing or misconfigured test target in Xcode project, or XCTest framework not linked.
- **Error Pattern:** Known pattern for missing test target or framework linkage.
- **Related Errors:** [None yet]
- **Contributing Factors:** Test directories and files were missing; project structure may not include test target setup.

### Resolution
- **Solution Attempts:**
  1. Standard import of XCTest: Failed - Error persists.
  2. Added header comments and clarified file context: Failed - Error persists.
  3. Escalation to project configuration and test target setup required.
- **Successful Resolution:** [Pending]
- **Fix Verification:** [Pending]
- **Programmatic Fix Script/Command:**
  ```
  # To be determined after root cause analysis and test target setup.
  ```

### Prevention
- **Early Detection:** Ensure test targets and framework linkage are verified before adding test files.
- **Prevention Mechanisms:** Add automated checks for test target presence and correct linkage in build scripts.
- **Recommended Checks:** Validate test target and framework linkage after project initialization and before test file creation.
- **Related Documentation:** [Apple XCTest Documentation](https://developer.apple.com/documentation/xctest)

## Build Failure: PMBE-COMPILER-002

### Basic Information
- **Timestamp:** 2024-06-11 14:10
- **Error Code:** PMBE-COMPILER-002
- **Category:** compiler_errors / type_errors, project_configuration_errors / xcodeproj_structure
- **Severity:** SEVERITY 1 (Critical)
- **Task ID:** 25.8 (Expand Test Suite, Build Failure Prevention)
- **Environment:**
  - Xcode Version: [FILL IN]
  - macOS Version: [FILL IN]
  - Swift Version: [FILL IN]
  - Device/Simulator: N/A (macOS)
  - Dependency Versions: N/A

### Error Details
- **Error Message (Exact):**
  ```
  No such module 'DocketMate' (in TestPersistenceController.swift)
  Cannot override instance method parameter of type 'NSItemProvider.CompletionHandler?' with non-optional type ...
  Invalid redeclaration of 'uploadFile(data:filename:)'
  ... (see logs/build_logs/category_viewmodel_test_run.log for full output)
  ```
- **Error Location:**
  - _macOS/Tests/UnitTests/TestPersistenceController.swift:3
  - _macOS/Tests/DocketMateTests/DocumentUploadViewModelTests.swift
  - _macOS/Tests/DocketMateTests/DocumentUploadViewModelTests_Enhanced.swift
- **Preceding Actions:**
  - Refactored PersistenceController to public for test injection
  - Updated CategoryViewModel and TestPersistenceController for DI
  - Ran xcodebuild test (see logs/build_logs/category_viewmodel_test_run.log)
- **Relevant Code Snippet:**
  ```swift
  import DocketMate // Fails in test target
  ```

### Analysis
- **Root Cause Analysis:**
  - Test target cannot import DocketMate module; likely project/target config or modulemap issue.
  - Additional unrelated test files have protocol conformance and override errors, blocking test suite.
- **Error Pattern:**
  - Known: Test target import/module config issues are common after module refactor or new public types.
- **Related Errors:**
  - PMBE-COMPILER-001 (if exists)
- **Contributing Factors:**
  - Recent refactor to public types, possible missing target membership or modulemap update.

### Resolution
- **Solution Attempts:**
  1. Made PersistenceController public: [FAILED] - Import error persists.
  2. Switched between 'import' and '@testable import': [FAILED] - No effect.
  3. Verified xcodebuild path and test invocation: [FAILED] - Project builds, but test target fails.
- **Successful Resolution:**
  - [PENDING]
- **Fix Verification:**
  - [PENDING]
- **Programmatic Fix Script/Command:**
  - [PENDING]

### Prevention
- **Early Detection:**
  - Run test target build after any module visibility or target config change.
- **Prevention Mechanisms:**
  - Ensure all new/modified files are added to correct targets in Xcode project.
  - Add CI check for test target module import.
- **Recommended Checks:**
  - Validate target membership for all source files.
  - Run 'xcodebuild test' after module changes.
- **Related Documentation:**
  - https://developer.apple.com/documentation/xcode/configuring-target-membership
  - https://stackoverflow.com/questions/24102184/no-such-module-error-in-xcode

### Resolution Attempt (2024-06-11 14:20)
- Discovered that PersistenceController.swift and TestPersistenceController.swift are not referenced in the Xcode project file (project.pbxproj).
- This is a root cause for module import errors in tests.
- **Next Step:** Add these files to both main and test targets in the Xcode project programmatically, then re-run the build/test suite.

## Build Failure: Missing File References in Xcode Project

### Symptoms
- Build fails with errors about missing source files, resources, or Info.plist
- Xcode reports file not found or cannot locate referenced file
- Example error messages:
  - `error: /path/to/File.swift: No such file or directory`
  - `error: The file "Info.plist" couldn't be opened because there is no such file.`
  - `error: Could not find resource 'Main.storyboard' referenced from project.pbxproj`

### Diagnostic Flowchart
1. **Did the build fail with a missing file error?**
   - Yes → Proceed to step 2
   - No → Check other build failure categories
2. **Is the missing file actually present in the file system?**
   - Yes → Manually re-add the file to the Xcode project
   - No → Remove the reference or restore the file from backup
3. **Did the automated script run?**
   - Yes → Check `diagnostics_report.txt` for actions taken
   - No → Run `remediate_missing_file_references.py` manually
4. **Did the script remove a valid reference?**
   - Yes → Restore from backup (`.bak_YYYYMMDD_HHMMSS`), re-add file
   - No → Proceed with build

### Automated Prevention
- The `remediate_missing_file_references.py` script (see [XCODE_BUILD_GUIDE.md](XCODE_BUILD_GUIDE.md#4.3.1-detailed-guide-remediate_missing_file_referencespy)) runs before every commit and build
- It scans the .pbxproj for missing file references and removes them automatically
- All actions are logged in `diagnostics_report.txt`
- A backup of the project file is created before any changes

### Manual Remediation
- If a valid file is removed, restore the backup (`.bak_YYYYMMDD_HHMMSS`) and re-add the file to the project
- Review `diagnostics_report.txt` for details on removed references
- If the script fails, check for file system permissions or path issues
- For edge cases, manually inspect the .pbxproj and restore missing references as needed

### Log Interpretation Guide
- Each run of the script appends to `diagnostics_report.txt`:
  - Example log entry:
    ```
    [2025-05-10 10:15:23] Removed reference to missing file: Models/ObsoleteModel.swift
    [2025-05-10 10:15:23] Created backup: _macOS/DocketMate.xcodeproj/project.pbxproj.bak_20250510_101523
    ```
- **Key points:**
  - Timestamps indicate when actions occurred
  - Each removed reference is listed with its path
  - Backups are always created before modification
  - If no actions are taken, the script will log "No missing references found."

### Troubleshooting
- Ensure the script is executable and present in `scripts/build_fixes/`
- If build failures persist, review the logs and consult the XCODE_BUILD_GUIDE.md for further steps
- For edge cases, manually inspect the .pbxproj and restore missing references as needed

### Prevention
- Always commit with the pre-commit hook enabled
- Do not bypass the build phase script unless necessary for emergency fixes
- Keep backups of the project file for recovery
- Reference: See [XCODE_BUILD_GUIDE.md](XCODE_BUILD_GUIDE.md#4.3.1-detailed-guide-remediate_missing_file_referencespy) for full script documentation and usage

### Quick Reference: remediate_missing_file_references.py

| Command Example                                             | Purpose                        |
|------------------------------------------------------------|--------------------------------|
| python3 scripts/build_fixes/remediate_missing_file_references.py         | Standard run (silent)          |
| python3 scripts/build_fixes/remediate_missing_file_references.py --dry-run | Preview changes only           |
| python3 scripts/build_fixes/remediate_missing_file_references.py --interactive | Prompt before each removal     |
| python3 scripts/build_fixes/remediate_missing_file_references.py --log-level debug | Verbose logging               |

**Configuration Options:**
- `.remediate_missing_file_references.cfg` (optional):
  - Set default mode (silent/interactive)
  - Adjust log level (info/debug/warn)
  - Toggle backup-only mode

**Troubleshooting Steps:**
- If a valid file is removed, restore from backup and re-add to project
- Check `diagnostics_report.txt` for details
- Ensure script is executable and present in `scripts/build_fixes/`
- For persistent issues, consult [XCODE_BUILD_GUIDE.md](XCODE_BUILD_GUIDE.md#4.3.1-detailed-guide-remediate_missing_file_referencespy)

**Full Documentation:**
- See [XCODE_BUILD_GUIDE.md](XCODE_BUILD_GUIDE.md#4.3.1-detailed-guide-remediate_missing_file_referencespy) for comprehensive usage, configuration, and troubleshooting

## Build Stability Enhancement Guide

To ensure ongoing build stability for the DocketMate project, the following strategies should be implemented:

### 1. Project File Backup & Restoration

#### Automatic Backup Creation
- Every successful build should trigger a backup of critical project configuration files
- The following files should be automatically backed up with timestamps:
  - DocketMate.xcodeproj/project.pbxproj
  - Key entry point files (DocketMateApp.swift, MainContentView.swift)
  - Any modified service files (e.g., OCRServiceWithFallback.swift)

#### Backup Detection & Restoration
When build failures occur, the system should:
1. Identify the most recent successful build backup
2. Present restoration options with timestamps
3. Provide a script to restore to known-good state

#### Implementation
The `scripts/build_fixes/fix_main_content_view.rb` script demonstrates this approach with:
- Timestamped backups: `.bak_YYYYMMDDHHMMSS` format
- Verification of file existence before restoration
- Clear documentation of backup locations

### 2. Xcode Project Structure Verification

To prevent structural issues:
1. Run a verification script before each build that:
   - Ensures all referenced files exist
   - Checks for duplicate file references
   - Validates entry point consistency

2. Implement a standardized import structure:
   ```swift
   // Required at top of main app files
   import SwiftUI
   // Additional imports as needed
   ```

### 3. Standard Rebuild Commands

For consistent build verification, use these commands:

```bash
# Clean build (primary verification)
xcodebuild -project DocketMate.xcodeproj -scheme DocketMate clean build

# Quick rebuild (incremental)
xcodebuild -project DocketMate.xcodeproj -scheme DocketMate build

# Debug build with verbose output
xcodebuild -project DocketMate.xcodeproj -scheme DocketMate -configuration Debug build
```

### 4. Critical Build Fix Script Listing

| Script Name | Purpose | Usage |
|-------------|---------|-------|
| fix_main_content_view.rb | Fixes MainContentView reference issues | `ruby scripts/build_fixes/fix_main_content_view.rb` |
| restore_project.rb | Restores project.pbxproj from backup | `ruby scripts/build_fixes/restore_project.rb [timestamp]` |
| verify_project_structure.rb | Verifies critical file existence | `ruby scripts/build_fixes/verify_project_structure.rb` |

### 5. Pre-Commit Build Validation

Before committing code:
1. Clean build the project
2. Run any tests that exist
3. Verify app launch in simulator
4. Backup the current known-good state

This ensures changes don't break the build and provides a restoration point if issues are discovered later.

### 6. SweetPad Compatibility Verification

For SweetPad compatibility:
1. Verify proper MainContentView implementation
2. Ensure OCR services implement required protocols
3. Validate app structure follows SweetPad integration points ## [2024-05-10] Build Failure: Missing CONTRIBUTING.md, LICENSE, and GitHub issue templates after task 1.5. Automated remediation performed. All files now present and verified.

# 2025-06-18: Production Build Failure - Missing Core App Files

**Category:** compiler_errors
**Severity:** 1 (Critical)
**Error Code:** PMBE-COMPILER-001

**Basic Info:**
- Date: 2025-06-18
- Environment: Production
- Build Target: DocketMate (Release)
- Command: xcodebuild -workspace DocketMate.xcworkspace -scheme DocketMate -configuration Release clean build

**Error Details:**
- Build input files cannot be found:
  - _macOS/Docketmate/Sources/AppDelegate.swift
  - _macOS/Docketmate/Sources/ContentView.swift
  - _macOS/Docketmate/Sources/DocketMateApp.swift
  - _macOS/Docketmate/Sources/UI/MainContentView.swift
- Error: Did you forget to declare these files as outputs of any script phases or custom build rules which produce them? (in target 'DocketMate' from project 'DocketMate')

**Preceding Actions:**
- Routine production build verification as mandated by .cursorrules
- No recent changes to production app sources (last major changes were directory cleanups and TDD feature work)

**Initial Hypothesis:**
- Core app files may have been deleted, moved, or not restored after a previous cleanup or recovery operation.
- Possible accidental deletion or misplacement during directory restructuring.

**Next Steps:**
1. Run post-mortem protocol (see .cursorrules §9.1)
2. Check for backups in temp/backup/
3. Check for files in Sandbox or other locations
4. If not recoverable, use scripts/create_buildable_swiftui_app.sh to restore minimal skeleton
5. Document all actions and outcomes
