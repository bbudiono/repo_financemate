# Refactoring Plan: ContentView Monolith

**Objective:** To decompose the monolithic `ContentView.swift` into a set of clean, single-responsibility components, following the principles outlined in `ARCHITECTURE.md`.

---

### Phase 0: Pre-computation (Pre-requisites)

*   **DONE:** This plan assumes that `Phase 0` and `Phase 1, Step 1 & 2` of the main `REMEDIATION_PLAN.md` are complete. Scope creep has been removed, and project dependencies are fixed.
*   **DONE:** `AuthenticationService.swift` and `CommonTypes.swift` exist and are correctly structured.

---

### Phase 1: Establish Environment and State Management

*   **Step 1.1: Modify `FinanceMateApp.swift` (App Entry Point)**
    *   **Action:** Instantiate `AuthenticationService` as a `@StateObject`.
    *   **Action:** Pass `AuthenticationService` into the view hierarchy as an `.environmentObject()`.
    *   **Code Example:**
        ```swift
        @main
        struct FinanceMateApp: App {
            @StateObject private var authService = AuthenticationService()

            var body: some Scene {
                WindowGroup {
                    ContentView()
                        .environmentObject(authService)
                }
            }
        }
        ```

---

### Phase 2: Decompose `ContentView`

*   **Step 2.1: Create `AuthenticationView.swift`**
    *   **Action:** Create a new file at `_macOS/FinanceMate/Features/Authentication/View/AuthenticationView.swift`.
    *   **Action:** Move all UI code and logic related to the unauthenticated state from `ContentView.swift` into `AuthenticationView.swift`. This includes the welcome text, logo, and sign-in buttons.
    *   **Action:** The view should consume the `AuthenticationService` from the environment (`@EnvironmentObject`).
    *   **Action:** All methods like `handleSignInWithAppleResult` and `signInWithGoogle` must be removed from the view and their logic handled by the `AuthenticationService`. The buttons in this view will now call methods directly on `authService`.

*   **Step 2.2: Create `MainAppView.swift` (The Authenticated Shell)**
    *   **Action:** Create a new file at `_macOS/FinanceMate/Views/MainAppView.swift`.
    *   **Action:** Move the `NavigationSplitView` and all its related toolbar/menu logic from `ContentView.swift` into `MainAppView.swift`.
    *   **Action:** `MainAppView` will contain the `SidebarView` and the `DetailView` routing logic.
    *   **Action:** State variables like `@State private var selectedView` and `@State private var columnVisibility` will live here.

*   **Step 2.3: Refactor the `ContentView.swift` into a Router**
    *   **Action:** Delete almost all code from `ContentView.swift`.
    *   **Action:** `ContentView`'s only responsibility is to read the `authService.isAuthenticated` property from the environment and decide whether to show `AuthenticationView` or `MainAppView`.
    *   **Code Example:**
        ```swift
        struct ContentView: View {
            @EnvironmentObject private var authService: AuthenticationService

            var body: some View {
                Group {
                    if authService.isAuthenticated {
                        MainAppView()
                    } else {
                        AuthenticationView()
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut, value: authService.isAuthenticated)
            }
        }
        ```

---

### Phase 3: Extract Sub-Views

*   **Step 3.1: Create Individual Feature View Files**
    *   **Action:** For every non-trivial `case` in the `DetailView`'s `switch` statement (e.g., `DashboardView`, `DocumentsView`), create a new, separate `.swift` file in the appropriate `Features/` subdirectory as defined in `ARCHITECTURE.md`.
    *   **Action:** Move the placeholder views (`BudgetManagementPlaceholderView`, etc.) into their own files within the relevant feature folders.

*   **Step 3.2: Create Reusable Component Files**
    *   **Action:** Move `SidebarView` into its own file at `_macOS/FinanceMate/Views/SidebarView.swift`.
    *   **Action:** If any smaller, reusable components are identified (e.g., custom buttons, cards), they should also be extracted into their own files in a `Views/Reusable/` folder.

---

### Validation Criteria:

*   `ContentView.swift` must be under 50 lines of code.
*   No business logic (e.g., authentication handling) should remain in any `View` file. Views call methods on services or view models.
*   The project must compile successfully after the refactoring.
*   The application must launch and display the `AuthenticationView`.
*   After a (mocked) successful login, the `MainAppView` must appear. 