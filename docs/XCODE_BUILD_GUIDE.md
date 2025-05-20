# DocketMate Xcode Build Guide

## 1. Overview

This guide provides critical information for building, maintaining, and troubleshooting the DocketMate Xcode project. It's essential for ensuring consistent build success, SweetPad compatibility, and project structure standards.

**Version:** 1.1.0  
**Last Updated:** 2025-05-10

## 2. Project Structure Standards

### 2.1 Essential Directory Structure

```
DocketMate/
├── App/                 # App configuration and entry point files
│   └── DocketMateApp.swift  # Main app entry point (@main)
├── ContentView.swift    # REQUIRED: Main entry point view - must be in root directory
├── Models/              # Data models
├── Services/            # Business logic services
│   ├── OCRService.swift
│   ├── OCRServiceProtocol.swift
│   └── OCRServiceWithFallback.swift
├── ViewModels/          # View state managers
├── Views/               # UI components
│   └── MainContentView.swift  # Main content container (optional - for complex applications)
├── Utilities/           # Helper functions and extensions
└── Assets.xcassets/     # Images and resources
```

### 2.2 Critical File Naming Requirements

* **DocketMateApp.swift:** Main application entry point with `@main` annotation
* **ContentView.swift:** Root view referenced by DocketMateApp - MUST be in the root directory
* Other view components should follow a consistent naming pattern (e.g., `EntityNameView.swift`)

## 3. Build Standards & Requirements

### 3.1 Standard Build Command

```bash
xcodebuild -project DocketMate.xcodeproj -scheme DocketMate clean build
```

### 3.2 SweetPad Compatibility Requirements

1. Project must maintain a stable entry point structure:
   - `DocketMateApp.swift` with `@main` annotation
   - `ContentView.swift` in the root directory 
   - Stable imports and SwiftUI references

2. Critical components for SweetPad:
   - No runtime dependencies that aren't satisfied in standard macOS environment
   - Proper SwiftUI imports and lifecycle handling

## 4. Build Stability Enhancement Guide

### 4.1 Build Failure Prevention

Before submitting changes, always:
1. Verify directory structure matches Section 2.1
2. Run `./scripts/build_fixes/verify_project_structure.rb` to check file integrity
3. Run `./scripts/code_check/find_duplicate_types.sh` to detect duplicate type definitions
4. Run `./scripts/build_fixes/pre_build_check.sh` for comprehensive verification
5. Test build with command in Section 3.1
6. Document any issues in BUILD_FAILURES.MD

For automated prevention, use:
```bash
# Set up Git hooks for automated pre-commit and pre-push checks
./scripts/setup_git_hooks.sh

# Create backups of critical files
./scripts/build_fixes/backup_critical_files.sh
```

For comprehensive prevention strategies, refer to the `BUILD_FAILURE_PREVENTION_GUIDE.md` document.

### 4.2 Common Build Issues & Resolution

#### Issue: "Cannot find 'MainContentView' in scope"
* **Resolution:** 
  1. Ensure ContentView.swift exists in the root directory
  2. Update DocketMateApp.swift to reference ContentView() not MainContentView()
  3. Run `./scripts/build_fixes/fix_quick.sh` to apply the fix automatically

#### Issue: "OCRServiceWithFallback missing type references"
* **Resolution:**
  1. Check OCRService.swift and OCRServiceProtocol.swift for proper type definitions
  2. Verify imports in OCRServiceWithFallback.swift
  3. Add appropriate protocols and types if missing

#### Issue: "Duplicate type definitions"
* **Resolution:**
  1. Run `./scripts/code_check/find_duplicate_types.sh` to identify duplicates
  2. Consolidate type definitions into a single location
  3. Use proper import statements to reference types

### 4.3 Automated Build Restoration

The project includes several scripts to automate build fixes:

* `scripts/build_fixes/fix_quick.sh`: Quick fix for ContentView reference issues
* `scripts/build_fixes/restore_project.rb`: Lists and restores available backup files
* `scripts/build_fixes/verify_project_structure.rb`: Validates project structure
* `scripts/build_fixes/fix_all_builds.sh`: Comprehensive build repair tool
* `scripts/build_fixes/backup_critical_files.sh`: Creates timestamped backups of critical files
* `scripts/code_check/find_duplicate_types.sh`: Detects duplicate type definitions
* `scripts/build_fixes/pre_build_check.sh`: Performs comprehensive pre-build verification

### 4.4 Project Backup & Restoration Procedure

#### Automatic Backup Creation
```bash
# Create timestamped backups of critical files
./scripts/build_fixes/backup_critical_files.sh
```

#### Backup Detection:
```bash
find . -type f -name "*.bak*" | sort
```

#### Restoring from Backup:
```bash
./scripts/build_fixes/restore_project.rb --list  # List available backups
./scripts/build_fixes/restore_project.rb --restore=<timestamp>  # Restore specific backup
```

## Automated Missing File Reference Remediation

To prevent build failures caused by missing file references in the Xcode project, the `remediate_missing_file_references.py` script is integrated into the build and commit workflow.

### Purpose
- Scans the Xcode .pbxproj for missing file references (Swift, xib, storyboard, plist)
- Removes invalid references automatically (silent mode)
- Logs all actions to `diagnostics_report.txt`
- Creates a backup of the project file before any changes
- Idempotent: safe to run multiple times

### Integration
- **Pre-commit hook:** The script runs automatically before every commit via `.git/hooks/pre-commit` (see `scripts/build_fixes/setup_git_hooks.sh`).
- **Run Script Build Phase:** Add a Run Script Build Phase in Xcode with:
  ```sh
  python3 scripts/build_fixes/remediate_missing_file_references.py
  ```
  This ensures remediation occurs before every build.

### Usage & Troubleshooting
- No manual action is required for normal development; the script runs automatically.
- If a commit or build is blocked, check `diagnostics_report.txt` for details on removed references.
- If a valid file is incorrectly removed, restore from the backup (`.bak_YYYYMMDD_HHMMSS`) and update the project structure.
- For persistent issues, review the script and logs, and consult the BUILD_FAILURES.MD for known patterns and solutions.

### Notes
- The script is safe to run repeatedly and will not remove valid references.
- All actions are logged for audit and debugging purposes.
- Backups are created before every modification for safety.

### 4.3.1 Detailed Guide: remediate_missing_file_references.py

#### Purpose & Operation
- Scans the Xcode .pbxproj for missing file references (Swift, xib, storyboard, plist)
- Removes invalid references automatically (default: silent mode)
- Logs all actions to `diagnostics_report.txt`
- Creates a backup of the project file before any changes
- Idempotent: safe to run multiple times

#### Installation & Configuration
- **Manual:**
  1. Ensure Python 3 is installed (`python3 --version`)
  2. Place `remediate_missing_file_references.py` in `scripts/build_fixes/`
  3. Make executable: `chmod +x scripts/build_fixes/remediate_missing_file_references.py`
- **Pre-commit Hook:**
  - Run `./scripts/build_fixes/setup_git_hooks.sh` to install the pre-commit hook
- **Pre-build (Xcode):**
  - Add a Run Script Build Phase in Xcode:
    ```sh
    python3 scripts/build_fixes/remediate_missing_file_references.py
    ```
- **Configuration File (Optional):**
  - Supports `.remediate_missing_file_references.cfg` for team preferences (see script header for options)

#### Options & Modes
| Option/Flag         | Description                                 |
|---------------------|---------------------------------------------|
| --silent            | Run without user prompts (default in hooks) |
| --interactive       | Prompt before removing each reference       |
| --log-level [level] | Set logging verbosity (info, debug, warn)   |
| --dry-run           | Show actions without making changes         |
| --backup-only       | Only create backup, do not modify project   |

#### Usage Scenarios
- **Standard development:** Script runs automatically before build/commit
- **CI/CD:** Integrate as a validation step in CI pipeline
- **Manual remediation:** Run with `--interactive` for step-by-step review
- **Audit:** Use `--dry-run` to preview changes

#### Troubleshooting
- If a valid file is removed, restore from backup (`.bak_YYYYMMDD_HHMMSS`) and re-add the file
- Check `diagnostics_report.txt` for details on removed references
- Ensure script is executable and present in `scripts/build_fixes/`
- For persistent issues, review logs and consult BUILD_FAILURES.MD

#### Quick Reference Table
| Command Example                                             | Purpose                        |
|------------------------------------------------------------|--------------------------------|
| python3 scripts/build_fixes/remediate_missing_file_references.py         | Standard run (silent)          |
| python3 scripts/build_fixes/remediate_missing_file_references.py --dry-run | Preview changes only           |
| python3 scripts/build_fixes/remediate_missing_file_references.py --interactive | Prompt before each removal     |
| python3 scripts/build_fixes/remediate_missing_file_references.py --log-level debug | Verbose logging               |

#### Validation & Review
- All documentation and script changes should be reviewed by at least two developers
- New users should follow this section to validate clarity and completeness
- Feedback should be collected and used to update this guide

## 5. Troubleshooting Guide

### 5.1 Escalation Path

1. **Level 1:** Run verify script to identify issues
   ```bash
   ./scripts/build_fixes/verify_project_structure.rb
   ```

2. **Level 2:** Apply quick fix for common issues
   ```bash
   ./scripts/build_fixes/fix_quick.sh
   ```

3. **Level 3:** Check for duplicate types
   ```bash
   ./scripts/code_check/find_duplicate_types.sh
   ```

4. **Level 4:** Perform comprehensive pre-build verification
   ```bash
   ./scripts/build_fixes/pre_build_check.sh
   ```

5. **Level 5:** Comprehensive build fix
   ```bash
   ./scripts/build_fixes/fix_all_builds.sh
   ```

6. **Level 6:** Restore from backup
   ```bash
   ./scripts/build_fixes/restore_project.rb --restore=<timestamp>
   ```

7. **Level 7:** Manual intervention (document steps in BUILD_FAILURES.MD)

### 5.2 Creating New Build Fix Scripts

When creating new prevention or fix scripts:

1. **Place in appropriate directory:**
   - Prevention scripts in `scripts/prevention/`
   - Fix scripts in `scripts/build_fixes/`
   - Code analysis in `scripts/code_check/`

2. **Proper Documentation:**
   - Header comment with purpose, usage, and version
   - Command-line help
   - Example usage
   - Return codes

3. **Testing:**
   - Verify in test environment
   - Include test cases
   - Document limitations

4. Follow these naming conventions:
   - fix_*.sh: Scripts that apply fixes
   - verify_*.rb/sh: Scripts that check for issues
   - backup_*.sh: Scripts that create backups
   - restore_*.rb/sh: Scripts that restore from backups

5. All scripts should be executable:
   ```bash
   chmod +x scripts/build_fixes/your_script.sh
   ```

6. Document in BUILD_FAILURES.MD and in the script header.

## 6. Testing Standards

### 6.1 Required Tests

All changes should include:
1. Build verification test
2. Functional tests for affected components
3. UI tests for view changes

### 6.2 Test Command

```bash
xcodebuild -project DocketMate.xcodeproj -scheme DocketMate test
```

### 6.3 Pre-Commit Testing

Use the Git hooks to run tests before committing:

```bash
# Install Git hooks
./scripts/setup_git_hooks.sh

# Run pre-commit checks manually
.git/hooks/pre-commit

# Force build verification during commit
CHECK_BUILD=1 git commit
```

## 7. Documentation Requirements

All build issues and fixes must be documented in:
1. `BUILD_FAILURES.MD` - Detailed issue record
2. `DEVELOPMENT_LOG.MD` - Chronological development history
3. `BUILD_FAILURE_PREVENTION_GUIDE.md` - Comprehensive prevention strategies

## 8. Continuous Integration

### 8.1 CI Pipeline Configuration

Configure CI systems to run prevention checks:

```yaml
# Example CI configuration
stages:
  - validation
  - build
  - test

validation:
  script:
    - ./scripts/build_fixes/verify_project_structure.rb
    - ./scripts/code_check/find_duplicate_types.sh

build:
  script:
    - xcodebuild -project DocketMate.xcodeproj -scheme DocketMate clean build

test:
  script:
    - xcodebuild -project DocketMate.xcodeproj -scheme DocketMate test
```

### 8.2 Automated Notifications

Configure alerts for build failures:
1. Immediate Team Notification for SEVERITY 1 failures
2. Daily Digest of lower severity issues
3. Trend Analysis of recurring problems

## 9. Reference

### 9.1 Build Tool Versions
- Xcode: 15.4+
- Swift: 5.9+
- macOS: 13.0+

### 9.2 Documentation
- Swift Package Manager: [Swift.org](https://swift.org/package-manager/)
- Xcode Build System: [Apple Developer](https://developer.apple.com/documentation/xcode)
- SwiftUI: [Apple Developer](https://developer.apple.com/documentation/swiftui)

### 9.3 Project-Specific Tools
- `scripts/build_fixes/`: Build fix and restoration scripts
- `scripts/code_check/`: Code analysis tools
- `scripts/`: Setup and utility scripts 