# Target Architecture & Project Structure

**Objective:** To define a clean, scalable, and maintainable project structure for the FinanceMate macOS application. This document serves as the blueprint for the refactoring efforts outlined in the `REMEDIATION_PLAN.md`.

---

## Root Directory Structure

The top-level directory should be organized by domain, not by file type. This promotes high cohesion and low coupling.

```
FinanceMate/
├── FinanceMate/                   # Main Application Target
│   ├── Application/               # App lifecycle, entry point, environment setup
│   │   ├── FinanceMateApp.swift
│   │   └── AppEnvironment.swift
│   ├── Core/                      # Shared models, utilities, extensions
│   │   ├── CommonTypes.swift
│   │   ├── Extensions/
│   │   └── Utils/
│   ├── Features/                  # Feature-based modules
│   │   ├── Authentication/
│   │   │   ├── View/
│   │   │   │   └── AuthenticationView.swift
│   │   │   └── ViewModel/
│   │   │       └── AuthenticationViewModel.swift
│   │   ├── Dashboard/
│   │   │   ├── View/
│   │   │   └── ViewModel/
│   │   ├── Analytics/
│   │   │   ├── View/
│   │   │   │   └── AnalyticsView.swift
│   │   │   └── ViewModel/
│   │   │       └── AnalyticsViewModel.swift
│   │   └── Settings/
│   │       ├── View/
│   │       └── ViewModel/
│   ├── Infrastructure/            # Low-level services (Networking, Persistence)
│   │   ├── Security/
│   │   │   ├── AuthenticationService.swift
│   │   │   ├── OAuth2Manager.swift
│   │   │   └── KeychainManager.swift
│   │   └── Networking/
│   │       └── APIClient.swift
│   ├── Resources/                 # Assets, Plists, etc.
│   │   └── Assets.xcassets
│   └── Views/                     # Shared, reusable UI components and top-level containers
│       ├── ContentView.swift      # The top-level router/view
│       ├── SidebarView.swift
│       └── LoadingView.swift
├── FinanceMate-Sandbox/           # Sandbox Target
│   └── FinanceMate_SandboxApp.swift # Sandbox-specific entry point
├── FinanceMateTests/              # Unit Test Target
│   ├── Features/
│   │   └── Analytics/
│   │       └── AnalyticsViewModelTests.swift
│   └── Infrastructure/
│       └── Security/
│           ├── AuthenticationServiceTests.swift
│           └── OAuth2ManagerTests.swift
├── FinanceMateUITests/            # UI Test Target
│   └── AuthenticationE2ETests.swift
└── temp/                          # Temporary audit/plan files
    ├── ARCHITECTURE.md
    ├── AUDIT_REPORT.md
    ├── EVIDENCE_LOG.md
    ├── REMEDIATION_PLAN.md
    ├── TECH_DEBT_REGISTER.md
    └── TEST_PLAN_ANALYTICS.md
```

## Key Principles:

1.  **Feature-Based Slicing:** Code related to a single feature (e.g., Analytics) should be co-located under a `Features/` directory. This includes Views, ViewModels, and any feature-specific models.
2.  **Clear Separation of Layers:**
    *   **Application:** The `App` struct and environment setup.
    *   **Features:** User-facing screens and their logic.
    *   **Infrastructure:** App-wide services like security and networking. Not tied to any single feature.
    *   **Core:** Truly universal types and helpers that can be used by any layer.
3.  **Lean `Views` Directory:** The top-level `Views` directory should only contain *truly reusable* view components or the main application container views (`ContentView`, `SidebarView`). Feature-specific views belong in their feature's folder.
4.  **Mirrored Test Targets:** The `FinanceMateTests` and `FinanceMateUITests` targets should mirror the structure of the main `FinanceMate` target where applicable. This makes finding corresponding tests trivial.
5.  **Single Source of Truth:** There will be only one `CommonTypes.swift` in `Core/`. Duplication is strictly forbidden. The Sandbox target will depend on the main target for all its code. 