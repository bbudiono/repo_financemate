#!/bin/bash

# Script to add DashboardDataService.swift to the Xcode project

PBXPROJ="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate.xcodeproj/project.pbxproj"

# Backup the project file
cp "$PBXPROJ" "$PBXPROJ.backup"

# Add PBXBuildFile entry (line 48)
sed -i '' '48a\
\		DASH234567890ABCDEF1234 /* DashboardDataService.swift in Sources */ = {isa = PBXBuildFile; fileRef = DAS1234567890ABCDEF1234 /* DashboardDataService.swift */; };' "$PBXPROJ"

# Add PBXFileReference entry (line 91)
sed -i '' '91a\
\		DAS1234567890ABCDEF1234 /* DashboardDataService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DashboardDataService.swift; sourceTree = "<group>"; };' "$PBXPROJ"

# Add file reference to Services group (after line 179)
sed -i '' '179a\
\				DAS1234567890ABCDEF1234 /* DashboardDataService.swift */,' "$PBXPROJ"

# Add build file to Sources build phase (after line 293)
sed -i '' '293a\
\				DASH234567890ABCDEF1234 /* DashboardDataService.swift in Sources */,' "$PBXPROJ"

echo "DashboardDataService.swift has been added to the Xcode project"