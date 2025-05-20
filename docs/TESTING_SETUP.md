# Xcode Test Target Setup for DocketMate-Sandbox

This document outlines the manual steps required to integrate the newly created test files into the `DocketMate-Sandbox` Xcode project and run them.

## 1. Create a New Test Target

If a Unit Test target doesn't already exist for `DocketMate-Sandbox`:

1.  Open `_macOS/DocketMateWorkspace.xcworkspace` in Xcode.
2.  Select the `DocketMate-Sandbox` project in the Project Navigator.
3.  Go to **File > New > Target...**
4.  Under the **macOS** tab, select **Unit Testing Bundle** and click **Next**.
5.  Name the Product Name (e.g., `DocketMateSandboxTests`).
6.  Ensure the **Team**, **Language** (Swift), and **Project** (`DocketMate-Sandbox`) are correctly set.
7.  For **Target to be Tested**, select `DocketMate-Sandbox`.
8.  Click **Finish**.

## 2. Add Test Files to the Test Target

1.  In Xcode's Project Navigator, locate the newly created test target (e.g., `DocketMateSandboxTests`).
2.  Right-click on the test target's group (folder) and select **Add Files to "DocketMateSandboxTests"...**
3.  Navigate to the `_macOS/DocketMate-Sandbox/Tests/AuthenticationTests/` directory.
4.  Select `AppleSignInViewTests.swift` and `GoogleSignInViewTests.swift`.
5.  **Important**: In the "Add to targets" section of the dialog, ensure **only your new test target** (e.g., `DocketMateSandboxTests`) is checked. Do **NOT** add these test files to the main `DocketMate-Sandbox` application target.
6.  Ensure "Copy items if needed" is checked.
7.  Click **Add**.

## 3. Verify Test Navigator

1.  Open the Test Navigator (View > Navigators > Show Test Navigator, or Cmd+6).
2.  You should see `AppleSignInViewTests` and `GoogleSignInViewTests` listed under your test target.
3.  The tests within these files should appear with a diamond icon, initially unfilled, indicating they haven't been run or are failing (which is expected at this stage).

## 4. Running Tests

1.  You can run individual tests, test classes, or the entire test suite from the Test Navigator or by clicking the diamond icons directly in the source editor next to the test functions/classes.
2.  To run all tests in the target, select the `DocketMate-Sandbox` scheme and your Mac as the run destination, then go to **Product > Test** (or Cmd+U).

Initially, all created tests are designed to fail (using `XCTFail`). This is the starting point for TDD. 