#!/usr/bin/env python3
"""
Fix the double-nested FinanceMate/FinanceMate path issue in project.pbxproj.
Changes line 267 from `path = FinanceMate;` to `path = .;`
"""

project_file = '/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj'

print("Reading project.pbxproj...")
with open(project_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")

# Find and fix line 267 (0-indexed: 266)
if len(lines) > 266:
    line_267 = lines[266]
    print(f"Line 267 before: {line_267.rstrip()}")

    if 'path = FinanceMate;' in line_267:
        lines[266] = line_267.replace('path = FinanceMate;', 'path = .;')
        print(f"Line 267 after:  {lines[266].rstrip()}")

        print("\nWriting fixed project.pbxproj...")
        with open(project_file, 'w', encoding='utf-8') as f:
            f.writelines(lines)

        print(" Fixed!")
        print("\nThe double nesting issue has been resolved.")
        print("Next step: Run the build to verify the fix works.")
    else:
        print("️  Line 267 doesn't contain 'path = FinanceMate;'")
        print("The file may have already been fixed or the line number has changed.")
else:
    print(f"️  File has only {len(lines)} lines, expected at least 267.")

print("\n" + "="*70)
print("TEST THE BUILD:")
print("="*70)
print("cd _macOS && xcodebuild build -project FinanceMate.xcodeproj -scheme FinanceMate -destination 'platform=macOS'")
