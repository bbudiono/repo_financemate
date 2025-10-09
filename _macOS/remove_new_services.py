#!/usr/bin/env python3
"""
Remove newly-added services causing dependency cascade from Xcode build target
"""
project_path = "FinanceMate.xcodeproj/project.pbxproj"

# Services to remove (added in refactoring but not properly integrated)
services_to_remove = [
    "GmailFilterManager.swift",
    "GmailFilterService.swift",
    "EmailConnectorService.swift"
]

print("Removing newly-added services from Xcode build target...")

# Read the project file
with open(project_path, 'r') as f:
    lines = f.readlines()

# Find and remove all references
filtered_lines = []
for line in lines:
    should_skip = False
    for service in services_to_remove:
        if service in line:
            should_skip = True
            print(f"  Removing: {service}")
            break

    if not should_skip:
        filtered_lines.append(line)

# Write back
with open(project_path, 'w') as f:
    f.writelines(filtered_lines)

print(f"\n Successfully removed {len(services_to_remove)} services from build target")
print("   Build should now compile with stable service dependencies")
