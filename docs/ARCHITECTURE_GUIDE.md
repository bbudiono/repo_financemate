# ARCHITECTURE_GUIDE.md

## Implementation Patterns for DocketMate

### MVVM Pattern
- **Views**: SwiftUI views, stateless, bind to ViewModels
- **ViewModels**: ObservableObject, business logic, state, dependency injection for services
- **Models**: Codable structs for documents, line items, columns, settings

### Services
- Use protocol-oriented design for all services (e.g., `OCRServiceProtocol`, `SpreadsheetServiceProtocol`)
- Inject services into ViewModels for testability
- Use Apple Vision for OCR (default), fallback to Tesseract if needed
- Integrations (Office365, Google Sheets, Gmail) use dedicated service classes, each conforming to a protocol

### Dependency Injection
- Use initializer injection for ViewModels
- Use environment objects for app-wide services if needed

### Testability
- All ViewModels and Services must have protocols and mock implementations for unit testing
- Place tests in `_macOS/Tests/UnitTests` and `_macOS/Tests/UITests`

### SwiftUI Best Practices
- Use `@StateObject` for ViewModels in root views, `@ObservedObject` for children
- Use `@Published` for observable properties
- Use `.sheet`, `.alert`, and `.popover` for modal UI
- Use `LazyVGrid`/`LazyHGrid` for spreadsheet UI
- Support dark/light mode

### OAuth & API Integration
- Use OAuth 2.0 for authentication (Microsoft, Google)
- Store tokens securely in Keychain
- Use URLSession for REST API calls
- Handle errors gracefully, show user-friendly messages

### File Handling
- Use NSOpenPanel for file selection
- Use drag-and-drop modifiers in SwiftUI
- Support PDF, image, and document parsing

### Spreadsheet Handling
- Use custom data model for spreadsheet rows/columns
- Support dynamic columns (user-defined)
- Export to CSV/Excel using open-source libraries or custom code

### Logging & Error Handling
- Use OSLog for logging
- Centralize error handling in services

### References
- See ARCHITECTURE.md for module overview
- See CODE_QUALITY.md for style and linting rules

### Build Stability Architecture

To maintain robust build stability, DocketMate's architecture includes specific considerations for preventing and resolving build failures:

#### Project Structure for Build Stability
- **Modular Organization:**
  - Clearly separate modules with minimal cross-dependencies
  - Group related files in logical directories to prevent path resolution issues
  - Minimize circular dependencies between modules
  - Follow the directory structure specified in `XCODE_BUILD_GUIDE.md`

#### Code Organization to Prevent Build Failures
- **Type Declaration Management:**
  - Apply "Combined File Pattern" for interdependent types (place related models/protocols in single files)
  - Avoid duplicate type definitions across multiple files
  - Use clear namespacing for shared types
  - Prefer composition over inheritance to reduce dependency complexity

- **Import Strategy:**
  - Use precise imports (specific modules rather than umbrella imports)
  - Organize imports consistently at the top of files
  - Avoid complex conditional imports 
  - Minimize `@testable import` to test files only

#### Test Architecture
- **Test File Organization:**
  - Mirror source directory structure in test directories
  - Ensure test bundle target configurations match main app configuration
  - Place test resources (mock data, test assets) in dedicated test directories
  - Keep test implementations isolated from production code

- **Separate Test Modules:**
  - Use dedicated test schemes configured for proper discovery
  - Maintain proper Info.plist configuration for test targets
  - Configure test targets for consistent environment access
  - Create factory methods for test data to ensure consistency

#### Error Prevention Architecture
- **Diagnostic Infrastructure:**
  - Implement project validation scripts as part of the development workflow
  - Run file reference checks before commits
  - Check target membership of new files automatically
  - Maintain "known good" build configurations

- **Alternative Build Paths:**
  - Document and implement fallback build mechanisms
  - Create simplified build processes for CI environments
  - Maintain Swift Package Manager compatibility for alternative builds
  - Structure code to degrade gracefully when optional frameworks are unavailable

#### Continuous Integration Considerations
- **Reproducible Builds:**
  - Pin tool and dependency versions (Xcode, Swift, SPM packages)
  - Use consistent environment variables across build systems
  - Document and script environment setup
  - Implement build verification tests

#### Version Control Structure
- **Branch Protection:**
  - Require pre-commit validation scripts
  - Perform automatic project integrity checks on push
  - Maintain separate branches for experimental project structure changes
  - Document project structure changes in commit messages

#### Documentation Architecture
- **Build Knowledge Management:**
  - Maintain up-to-date `BUILD_FAILURES.MD` using the template in `.cursorrules`
  - Create symptom-based troubleshooting guides
  - Document known patterns and their resolution strategies
  - Keep `COMMON_ERRORS.MD` synchronized with discovery of new error patterns

This architecture ensures DocketMate maintains build stability while allowing for continuous development, by establishing structural preventions for common build issues. 