# SCRIPTS.MD
Created by cleanup_directory_structure.sh on Tue May 20 07:19:33 AEST 2025
Please update with proper content.

## Canonical Build & Project Automation Scripts

### create_buildable_swiftui_app.sh
- **Purpose:** Canonical, project-agnostic script to create and verify a buildable SwiftUI macOS app (Production or Sandbox).
- **Usage:**
  - Production build: `bash scripts/create_buildable_swiftui_app.sh --env production --root <project_root> --app DocketMate`
  - Sandbox build:    `bash scripts/create_buildable_swiftui_app.sh --env sandbox --root <project_root> --app DocketMate`
- **Compliance:**
  - Fully project-agnostic, robust error handling, logs to `logs/` (never `{root}/`)
  - Enforces .cursorrules compliance for structure, naming, and build verification
  - Must be documented and updated if changed
- **Notes:**
  - All logs are written to `logs/create_buildable_swiftui_app_<env>_<timestamp>.log`
  - Script must be tested in Sandbox before Production use

### ensure_xcode_files.sh
- **Purpose:** Project-agnostic script to ensure required Xcode files exist and are properly structured.
- **Usage:**
  - `bash scripts/ensure_xcode_files.sh --app <app_name> --env <environment> --root <project_root>`
  - Example: `bash scripts/ensure_xcode_files.sh --app DocketMate --env sandbox --root /path/to/project`
- **Compliance:**
  - Fully project-agnostic with parameterized app name and environment 
  - Logs to `logs/` directory with timestamp (never to project root)
  - Creates minimal, compliant Swift files with proper CMD+Q functionality
  - Creates necessary directory structure and basic project files
- **Notes:**
  - Ensures existence of Sources, Resources, Tests directories
  - Generates Info.plist and entitlements files if missing
  - Writes logs to `logs/ensure_xcode_files_<env>_<timestamp>.log`

---

*Please update this file with any new scripts, changes, or compliance notes as required by .cursorrules.*
