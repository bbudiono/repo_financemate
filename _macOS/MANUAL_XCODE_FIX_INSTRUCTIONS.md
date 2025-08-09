
# MANUAL XCODE PROJECT FIX INSTRUCTIONS

## Problem: SSO files not visible to each other during compilation

## Solution: Manual Xcode Project Configuration

### Step 1: Open Xcode Project
1. Open FinanceMate.xcodeproj in Xcode
2. Select FinanceMate project in navigator
3. Select FinanceMate target

### Step 2: Verify File References
In Project Navigator, ensure these files are present:
- FinanceMate/Services/SSOManager.swift
- FinanceMate/Services/AppleAuthProvider.swift  
- FinanceMate/Services/GoogleAuthProvider.swift
- FinanceMate/Services/TokenStorage.swift
- FinanceMate/Services/AuthenticationService.swift
- FinanceMate/Models/UserSession.swift

### Step 3: Check Build Phases
1. Select FinanceMate target
2. Go to Build Phases tab
3. Expand "Compile Sources"
4. Ensure ALL SSO files are listed
5. If missing, drag files from navigator to Compile Sources

### Step 4: Check Compilation Order
In Compile Sources, ensure this order:
1. UserSession.swift (first - defines OAuth2Provider)  
2. TokenStorage.swift
3. AppleAuthProvider.swift
4. GoogleAuthProvider.swift
5. SSOManager.swift
6. AuthenticationService.swift
7. AuthenticationViewModel.swift (last - uses SSOManager)

### Step 5: Clean and Build
1. Product → Clean Build Folder (Cmd+Shift+K)
2. Product → Build (Cmd+B)

### Step 6: If Still Fails
The issue might be circular dependencies or module visibility.
Consider adding explicit imports or restructuring the code.
