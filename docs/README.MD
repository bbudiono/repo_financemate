# DocketMate

A modern macOS document management application for legal professionals.

## Project Structure

The repository contains two Xcode projects and a shared workspace:

1. `DocketMate` - The production version of the application
2. `DocketMate-Sandbox` - The development/testing version of the application
3. `DocketMateWorkspace` - A shared workspace containing both projects

Both applications share a common codebase, with the Sandbox version used for testing new features. The Sandbox version is clearly identified with a "SANDBOX" watermark overlay.

## Getting Started

### Prerequisites

- macOS 12.0+
- Xcode 14.0+
- Swift 5.7+

### Building the Projects

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/docketmate.git
   cd docketmate
   ```

2. Generate the Xcode projects (if needed):
   ```bash
   cd _macOS/DocketMate
   chmod +x generate_project.swift
   ./generate_project.swift
   
   cd ../DocketMate-Sandbox
   chmod +x generate_project.swift
   ./generate_project.swift
   ```

3. Open the projects in Xcode:
   - For the shared workspace (recommended): Open `_macOS/DocketMateWorkspace.xcworkspace`
   - For the production app only: Open `_macOS/DocketMate/DocketMate.xcodeproj`
   - For the sandbox app only: Open `_macOS/DocketMate-Sandbox/DocketMate-Sandbox.xcodeproj`

4. Build and run the application using the Xcode Run button.

## Features

- Document organization and management
- Document upload functionality
- User profile management
- Application settings

## Development

The application is built using SwiftUI and follows the MVVM architecture pattern.

### Project Organization

- `Sources/` - Contains the Swift source files for the application
- `Resources/` - Contains resource files (images, plists, etc.)

## License

[MIT License](LICENSE)