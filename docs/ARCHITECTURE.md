# ARCHITECTURE.md

## High-Level Architecture: FinanceMate

### Overview
FinanceMate is structured as a modular macOS SwiftUI application, following MVVM and service-oriented patterns. The app is divided into clear modules for UI, business logic, integrations, and utilities, supporting extensibility for future features (e.g., email integration).

### Main Modules
- **App**: Entry point, app lifecycle, environment setup
- **Views**: SwiftUI views for drag-and-drop, spreadsheet, settings, integrations
- **ViewModels**: State management, business logic, data transformation for views
- **Models**: Data structures for documents, line items, columns, user settings
- **Services**:
  - OCRService: Handles OCR using Apple Vision/Tesseract
  - SpreadsheetService: Manages spreadsheet data, columns, and export
  - IntegrationService: Handles Office365, Google Sheets, and Gmail APIs
  - FileService: Handles file import, drag-and-drop, and parsing
- **Utilities**: Helpers (e.g., Keychain, logging, error handling)

### Data Flow
- User drops/uploads document → FileService → OCRService → Models (LineItems) → SpreadsheetService → ViewModel → View
- Integrations update spreadsheet via IntegrationService

### Extensibility
- New integrations (e.g., Gmail) are added as new services and ViewModels
- All modules are testable and loosely coupled

### Security
- OAuth 2.0 for all external integrations
- No secrets hardcoded; use KeychainHelper

### Persistence
- UserDefaults/local file storage for settings and cached data

### References
- See BLUEPRINT.md for requirements and tech stack
- See ARCHITECTURE_GUIDE.md for implementation patterns 