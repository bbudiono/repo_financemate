# XCODE_BUILD_CONFIGURATION.md

## Xcode Build Settings for DocketMate

- Scheme: DocketMate
- Configuration: Debug/Release
- Workspace: _macOS/DocketMate.xcodeproj/project.xcworkspace
- Deployment Target: macOS 13+
- Swift Version: 5.0+
- Enable Automatic Code Signing
- Entitlements: _macOS/DocketMate/DocketMate.entitlements
- Asset Catalog: AppIcon, AccentColor
- Info.plist: Auto-generated

See BUILDING.md and XCODE_BUILD_GUIDE.md for build/run instructions.

## Key Application Views and Features

This section maps key application features to their primary views, providing paths and brief descriptions. This helps in understanding the UI structure and navigation flow.

| Feature Name          | Key View Name               | Full Path to View File                                      | Brief Description of View's Role                                  |
|-----------------------|-----------------------------|-------------------------------------------------------------|-------------------------------------------------------------------|
| **Main App Entry**    | `DocketMateApp`             | `_macOS/DocketMate/DocketMateApp.swift`                      | SwiftUI App instance and entry point. Manages app lifecycle.       |
| **Content Container** | `ContentView`               | `_macOS/DocketMate/ContentView.swift`                        | Root view of the app, hosts top-level navigation.                 |
| **Main Navigation**   | `MainContentView`           | `_macOS/DocketMate/Views/MainContentView.swift`              | TabView-based navigation between Dashboard and Settings.          |
| **Dashboard**         | `DashboardView`             | `_macOS/DocketMate/Views/DashboardView.swift`                | Main dashboard with analytics, recent documents, and quick actions. NavigationView with sidebar and main content. |
| **Dashboard Analytics** | `DashboardAnalyticsPanelView` | `_macOS/DocketMate/Views/DashboardAnalyticsPanelView.swift` | Analytics summary with metrics cards, time range selector.        |
| **Analytics Metrics** | `MetricCardView`            | `_macOS/DocketMate/Views/Dashboard/MetricCardView.swift`     | Individual metric card showing value, trend, and title.           |
| **Document Upload**   | `DocumentUploadView`        | `_macOS/DocketMate/Views/DocumentUploadView.swift`           | Interface for uploading documents via drag-and-drop.              |
| **Document Drop Area** | `DocumentDropArea`        | `_macOS/DocketMate/Views/DocumentDropArea.swift`             | SwiftUI drag-and-drop area for document files.                    |
| **File Picker**       | `FilePickerButton`          | `_macOS/DocketMate/Views/FilePickerButton.swift`             | Button that opens a file picker dialog.                           |
| **Authentication**    | `LoginView`                 | `_macOS/DocketMate/Views/Authentication/LoginView.swift`     | User authentication screen.                                       |
| **Placeholders**      | `ProfileView`               | `_macOS/DocketMate/Views/ProfileView.swift`                  | Empty placeholder for user profile page.                          |
|                       | `SettingsView`              | `_macOS/DocketMate/Views/SettingsView.swift`                  | Empty placeholder for settings page.                              |

## Key Application View Models

| View Model Name             | Full Path to File                                 | Associated View(s)                | Description                          |
|-----------------------------|---------------------------------------------------|-----------------------------------|--------------------------------------|
| `DashboardAnalyticsViewModel` | `_macOS/DocketMate/ViewModels/DashboardAnalyticsViewModel.swift` | `DashboardAnalyticsPanelView` | Manages analytics data and time range selection. |
| `SpreadsheetColumnViewModel`  | `_macOS/DocketMate/ViewModels/SpreadsheetColumnViewModel.swift` | Spreadsheet column customization | Manages column configuration.        |

## Key Service Components

| Service Name        | Full Path to File                             | Description                                      |
|---------------------|----------------------------------------------|--------------------------------------------------|
| `OCRService`        | `_macOS/DocketMate/Services/OCRService.swift` | Handles OCR text recognition using Vision framework. Extracts line items from document images. |
| `FileService`       | `_macOS/DocketMate/Services/FileService.swift` | Manages file import and type detection.         |
| `DocumentService`   | `_macOS/DocketMate/Services/DocumentService.swift` | Handles document operations and storage.    |

## View Dependencies and Navigation Structure

```
DocketMateApp
└── ContentView
    └── MainContentView (TabView)
        ├── DashboardView
        │   ├── Sidebar Navigation
        │   │   ├── DocumentUploadView
        │   │   │   ├── DocumentDropArea
        │   │   │   └── FilePickerButton
        │   │   ├── Spreadsheets (Placeholder)
        │   │   └── Settings (Placeholder)
        │   └── Main Content
        │       ├── Welcome Section
        │       ├── DashboardAnalyticsPanelView
        │       │   └── MetricCardView (Grid)
        │       ├── Quick Actions
        │       └── Recent Documents
        └── SettingsView (Placeholder)
```

## Icon Usage and Semantics

Icons are used throughout the application to improve usability and visual communication. The application uses SF Symbols for consistency with macOS design guidelines.

### Dashboard Icons

| Icon Name                       | SF Symbol                            | Usage Location                 | Meaning                       |
|---------------------------------|--------------------------------------|--------------------------------|-------------------------------|
| Dashboard                       | `list.dash.header.rectangle`         | MainContentView Tab            | Dashboard/overview            |
| Settings                        | `gearshape.fill`                     | MainContentView Tab            | App settings                  |
| Document Upload                 | `doc.badge.plus`                     | Dashboard Sidebar              | Upload new document           |
| Spreadsheets                    | `tablecells`                         | Dashboard Sidebar              | View spreadsheets             |
| Settings (Navigation)           | `gear`                               | Dashboard Sidebar              | App settings                  |
| Refresh                         | `arrow.clockwise`                    | Dashboard Toolbar              | Refresh dashboard data        |
| Upload Document (Quick Action)  | `doc.badge.plus`                     | Dashboard Quick Actions        | Upload document               |
| Create Spreadsheet              | `tablecells`                         | Dashboard Quick Actions        | Create new spreadsheet        |
| Search Documents                | `magnifyingglass`                    | Dashboard Quick Actions        | Search existing documents     |
| Export Data                     | `square.arrow.down`                  | Dashboard Quick Actions        | Export data to file           |
| View Analytics                  | `chart.bar.xaxis`                    | Dashboard Quick Actions        | View detailed analytics       |
| PDF Document                    | `doc.text`                           | Document Row                   | PDF document type             |
| Image Document                  | `doc.richtext`                       | Document Row                   | Image document type           |
| No Documents                    | `doc.text.magnifyingglass`           | Empty Documents Placeholder    | No documents found            |
| Trend Up                        | `arrow.up`                           | MetricCardView                 | Positive trend                |
| Trend Down                      | `arrow.down`                         | MetricCardView                 | Negative trend                |
| Error                           | `exclamationmark.triangle`           | Analytics Error State          | Error loading analytics       |

### File Picker Icons

| Icon Name                       | SF Symbol                            | Usage Location                 | Meaning                       |
|---------------------------------|--------------------------------------|--------------------------------|-------------------------------|
| Choose File                     | `doc.badge.plus`                     | FilePickerButton               | Select file from disk         |

## Color Semantics

The application uses semantic colors to convey meaning consistently:

| Color Name         | Asset Name                  | Usage                                        | Meaning                       |
|--------------------|-----------------------------|--------------------------------------------|-------------------------------|
| Success Green      | `SuccessColor`              | Positive trends, successful operations      | Positive/good outcomes        |
| Warning Orange     | `WarningColor`              | Processing status, caution states          | In progress/attention needed  |
| Destructive Red    | `DestructiveColor`          | Negative trends, errors, deletions         | Negative/danger/removal       |
| Accent Blue        | System accent color         | Buttons, selections, active states         | Interactive elements          | 