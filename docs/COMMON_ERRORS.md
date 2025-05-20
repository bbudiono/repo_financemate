# COMMON_ERRORS.md

## Summary
- **Type Visibility/Resolution:** Errors like "Cannot find type X in scope" or "X is ambiguous" often stem from duplicate type declarations across multiple files or incorrect target membership in the Xcode project. Ensure types are defined canonically and files are correctly included in targets. See [XCODE_BUILD_GUIDE.md](mdc:docs/XCODE_BUILD_GUIDE.md#11-module-visibility-and-import-issues-new-section) for programmatic checks.
- **Test Discovery:** Tests not being discovered can result from incorrect file/class naming conventions (must end in `Tests.swift`/`Tests`) or Xcode indexing issues. Renaming or cleaning DerivedData can help. Persistent issues may indicate deeper Xcode/xcodegen bugs. See [BUILD_FAILURES.MD](mdc:docs/BUILD_FAILURES.MD) for escalation details.
- **Project File Issues:** Errors like "project damaged", missing file references, or duplicated paths often point to `project.pbxproj` corruption or inconsistency. Use programmatic verification/repair (e.g., `xcodeproj` gem) or regenerate the project carefully. See [XCODE_BUILD_GUIDE.md](mdc:docs/XCODE_BUILD_GUIDE.md#2-project-file-path-issues) and [BUILD_FAILURES.MD](mdc:docs/BUILD_FAILURES.MD).
- **Main Entry Point Conflicts:** Errors involving `@main` attribute or `ContentView` redeclarations usually mean multiple app entry points exist (e.g., SwiftUI `App` struct and `main.swift`). Choose one entry point pattern (SwiftUI `App` or `AppDelegate`) and remove the other. See [BUILD_FAILURES.MD](mdc:docs/BUILD_FAILURES.MD).

## Error Log

| Error/Issue | Cause | Solution | Related Task/Bug |
|-------------|-------|----------|------------------| 
| "Cannot find type X in scope" | Duplicate declarations, incorrect target membership, index issues | Centralize type definitions, verify target membership, clean build/DerivedData | Task 30 |
| Test Discovery Failure | Naming conventions, index issues, Xcode bugs | Verify names, clean DerivedData, potentially manual Xcode intervention or escalate | Task 31, BUILD_FAILURES.MD |
| "Project damaged" / Missing References | `project.pbxproj` corruption/inconsistency | Programmatic verification/repair (xcodeproj gem), regenerate project | Task 30.4 |
| Duplicate `@main` / `ContentView` | Multiple app entry points | Choose one entry point pattern (SwiftUI App or AppDelegate), remove the other | Task 24.1 | 