# Test Plan: AnalyticsView

**Objective:** To verify the correctness, performance, and UI integrity of the `AnalyticsView` component and its underlying data services.

---

### 1. Unit Tests (XCTest)

**Target:** `AnalyticsViewModel.swift` (Note: This file does not yet exist and must be created as part of the `ContentView` refactoring).

*   **Test Case 1.1: Initial State**
    *   **Given:** The ViewModel is initialized.
    *   **When:** No data has been loaded.
    *   **Then:**
        *   The view state should be `.loading`.
        *   All data-holding properties (e.g., `chartData`, `keyMetrics`) should be empty.

*   **Test Case 1.2: Successful Data Fetch**
    *   **Given:** The `AnalyticsService` dependency is mocked to return valid, sample financial data.
    *   **When:** The `fetchAnalytics()` method is called.
    *   **Then:**
        *   The view state transitions from `.loading` to `.loaded`.
        *   The `chartData` property is populated with correctly transformed data points for the UI.
        *   `keyMetrics` are calculated correctly (e.g., Total Spending, Top Category).

*   **Test Case 1.3: Data Fetch Failure**
    *   **Given:** The `AnalyticsService` dependency is mocked to throw a network error.
    *   **When:** The `fetchAnalytics()` method is called.
    *   **Then:**
        *   The view state transitions from `.loading` to `.error`.
        *   The associated error object contains the correct error information.
        *   Data properties remain empty.

*   **Test Case 1.4: Navigation Logic**
    *   **Given:** The ViewModel is in a `.loaded` state.
    *   **When:** The `navigateTo(destination:)` method is called with a specific data point (e.g., a budget category).
    *   **Then:**
        *   The `onNavigate` closure is called with the correct `NavigationItem`.

---

### 2. UI Tests (XCUITest)

**Target:** A new `AnalyticsView_UITests.swift` file within the `FinanceMateUITests` target.

*   **Test Case 2.1: View Appears Correctly in Loaded State**
    *   **Given:** The app is launched with mocked data that places the `AnalyticsView` in a fully loaded state.
    *   **When:** The view is presented.
    *   **Then:**
        *   The main chart is visible and displays the expected number of data points.
        *   Key metric cards (e.g., "Total Spending") are visible and display the correct formatted strings.
        *   The "Drill Down" or similar interactive elements are visible.
        *   **Evidence:** A screenshot named `AnalyticsView_LoadedState.png` is captured.

*   **Test Case 2.2: View Appears Correctly in Empty State**
    *   **Given:** The app is launched with mocked data that represents a user with no financial transactions.
    *   **When:** The view is presented.
    *   **Then:**
        *   An "Empty State" message (e.g., "No data to analyze yet.") is displayed prominently.
        *   The main chart and key metric cards are not visible.
        *   **Evidence:** A screenshot named `AnalyticsView_EmptyState.png` is captured.

*   **Test Case 2.3: View Appears Correctly in Error State**
    *   **Given:** The app is launched with a mocked error state for the analytics feature.
    *   **When:** The view is presented.
    *   **Then:**
        *   An "Error State" message (e.g., "Failed to load analytics.") is displayed.
        *   A "Retry" button is visible and enabled.
        *   **Evidence:** A screenshot named `AnalyticsView_ErrorState.png` is captured.

---

### 3. Performance Tests (XCTest)

**Target:** `AnalyticsViewModel_PerformanceTests.swift`

*   **Test Case 3.1: Data Transformation Performance**
    *   **Given:** A large (e.g., 10,000 transactions) mock dataset.
    *   **When:** The data transformation logic within the ViewModel is executed.
    *   **Then:**
        *   The test measures the time taken to process the data and asserts that it is within an acceptable performance baseline (e.g., under 50ms). This is done using `self.measure { ... }`.

---

### 4. Accessibility Audit

*   **Requirement:** All UI elements in `AnalyticsView` must be fully accessible.
*   **Validation Method:**
    1.  Run the Xcode Accessibility Inspector on the `AnalyticsView` in a running simulator.
    2.  Ensure all interactive elements have labels and hints.
    3.  Verify that chart data is represented in an accessible format (e.g., a table view for screen readers).
    4.  Ensure color contrast ratios meet WCAG AA standards.
*   **Evidence:** Screenshots of the Accessibility Inspector report showing no warnings. 