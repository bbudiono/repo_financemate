# Final Project Setup Instructions

After running the `create_project.command` script, you'll have a complete file structure with all the Swift files and resources, but you'll need to create the actual Xcode projects to use them. Follow these instructions to complete the setup:

## Creating the Xcode Projects

### 1. Production Target

1. Open Xcode
2. Select File → New → Project
3. Choose macOS → App
4. Enter your project details:
   - Product Name: Same as you entered in the script
   - Team: Your development team
   - Organization Identifier: com.yourcompany
   - Interface: SwiftUI
   - Language: Swift
5. Click Next and save the project inside the `_macOS/YourProjectName/` directory, replacing the empty `.xcodeproj` folder

### 2. Sandbox Target

1. In Xcode, select File → New → Project
2. Choose macOS → App
3. Enter your project details:
   - Product Name: YourProjectName-Sandbox
   - Team: Your development team
   - Organization Identifier: com.yourcompany
   - Interface: SwiftUI
   - Language: Swift
4. Click Next and save the project inside the `_macOS/YourProjectName-Sandbox/` directory, replacing the empty `.xcodeproj` folder

## Adding Generated Files to Projects

### For Production Target:

1. Open the production project
2. In the Project Navigator, right-click on the project name
3. Select "Add Files to 'YourProjectName'..."
4. Navigate to and select:
   - All Swift files from `Sources/` directory
   - Resources directory
   - Entitlements file
5. Ensure "Copy items if needed" is NOT checked
6. Select "Create groups" for the added files
7. Click Add

### For Sandbox Target:

1. Open the sandbox project
2. In the Project Navigator, right-click on the project name
3. Select "Add Files to 'YourProjectName-Sandbox'..."
4. Navigate to and select:
   - All Swift files from `Sources/` directory
   - Resources directory
   - Entitlements file
5. Ensure "Copy items if needed" is NOT checked
6. Select "Create groups" for the added files
7. Click Add

## Configuring the Projects

### For Both Projects:

1. Select the project in the Project Navigator
2. Select the target
3. Go to the "Signing & Capabilities" tab
4. Add "Sign in with Apple" capability
5. Set your Bundle Identifier to match what's in the Info.plist
6. Select your Team for signing
7. Go to the "Info" tab and verify the URL schemes match what's in the Info.plist

### Creating the Workspace

1. In Xcode, select File → New → Workspace
2. Name it the same as your project
3. Save it in the `_macOS/` directory
4. Close all projects
5. Open the workspace
6. Drag and drop both `.xcodeproj` files into the workspace

## Testing the Setup

1. Select the production or sandbox scheme in Xcode
2. Build and run the app
3. Test the Apple Sign-In button
4. Configure your Google OAuth credentials and test Google authentication

## Troubleshooting

If you encounter any issues:

1. Verify the Bundle Identifiers match between Info.plist and project settings
2. Check that the URL schemes are properly configured for OAuth callbacks
3. Ensure entitlements files are correctly associated with the targets
4. Verify that all required frameworks are linked (AppKit, SwiftUI, AuthenticationServices)

The authentication flows should work correctly if all files are added and configured properly.
