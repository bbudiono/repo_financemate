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

---

*Please update this file with any new scripts, changes, or compliance notes as required by .cursorrules.*
