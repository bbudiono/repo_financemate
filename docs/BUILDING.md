# BUILDING.md



## Build Instructions for FinanceMate

### Prerequisites
- Xcode 14.3+
- macOS 13+
- Swift 5.0+
- Ruby with `xcodeproj` gem (for some build verification scripts)

### Standard Build Command
```sh
xcodebuild -scheme FinanceMate -configuration Debug -workspace _macOS/FinanceMate.xcodeproj/project.xcworkspace -destination platform=macOS,arch=arm64 -allowProvisioningUpdates build
```

### Run the App
```sh
# First, find the built product path
BUILD_DIR=$(xcodebuild -project _macOS/FinanceMate.xcodeproj -configuration Debug -showBuildSettings | grep -m 1 'BUILT_PRODUCTS_DIR' | cut -d '=' -f2 | xargs)
APP_PATH="$BUILD_DIR/FinanceMate.app"

# Check if the app exists
if [ -d "$APP_PATH" ]; then
  open "$APP_PATH"
else
  echo "Error: App bundle not found at $APP_PATH. Build may have failed."
  exit 1
fi
```

### Verification Steps (Mandatory Before Release/Commit)

1.  **Directory Structure Check:** Ensure code/docs/logs/scripts are in correct locations per `.cursorrules`.
    ```sh
    ./scripts/verify-directory-structure.sh
    ```
2.  **Build Verification:** Ensure the project builds cleanly without errors.
    ```sh
    xcodebuild -project _macOS/FinanceMate.xcodeproj -scheme FinanceMate clean build
    ```
3.  **Test Verification:** Ensure all unit and UI tests pass.
    ```sh
    ./scripts/verify-tests.sh # Or: xcodebuild -project _macOS/FinanceMate.xcodeproj -scheme FinanceMate test
    ```
4.  **SweetPad Compatibility Check:** Ensure the build adheres to SweetPad requirements (this is implicitly covered by a successful build and test run using the correct scheme and configuration).

### Release Flow Outline (Draft)

1.  **Development Branch:**
    *   Implement features/fixes following TDD.
    *   Run all verification steps (`verify-directory-structure.sh`, `xcodebuild clean build`, `verify-tests.sh`).
    *   Commit changes with descriptive messages.
2.  **Staging/Release Branch:**
    *   Merge development changes.
    *   Run comprehensive verification steps again.
    *   Build Release configuration: `xcodebuild -scheme FinanceMate -configuration Release ... build`
    *   Perform manual QA/User Acceptance Testing (UAT) on the Release build.
    *   Tag the commit for release (e.g., `git tag v1.1.0`).
3.  **Production Release:**
    *   Deploy the tagged Release build (e.g., submit to App Store, distribute).
    *   Monitor for issues.
4.  **Rollback (If Needed):**
    *   Identify last known good tag/commit.
    *   Revert changes or check out the good tag.
    *   Re-build and re-deploy the known good version.
    *   Document the issue and rollback in `BUGS.MD` and `DEVELOPMENT_LOG.MD`.

### References
- See docs/XCODE_BUILD_GUIDE.md for full project structure and manual setup steps.
- See docs/XCODE_BUILD_CONFIGURATION.md for build settings.
- See docs/BUILD_FAILURES.MD for common issues and resolutions.
- See ./scripts/README.md for details on verification scripts. 