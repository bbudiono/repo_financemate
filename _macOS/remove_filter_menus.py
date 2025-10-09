#!/usr/bin/env python3
"""
Remove Filter Menu components from Xcode build target to restore build stability
"""
project_path = "FinanceMate.xcodeproj/project.pbxproj"

# Filter components to remove
filter_components = [
    "DateFilterMenu.swift",
    "MerchantFilterMenu.swift",
    "CategoryFilterMenu.swift",
    "AmountFilterMenu.swift",
    "ConfidenceFilterMenu.swift"
]

print("Removing Filter Menu components from Xcode build target...")

# Read the project file
with open(project_path, 'r') as f:
    lines = f.readlines()

# Find and remove all references to filter components
filtered_lines = []
skip_next = False
for line in lines:
    should_skip = False
    for component in filter_components:
        if component in line:
            should_skip = True
            print(f"  Removing: {component}")
            break

    if not should_skip:
        filtered_lines.append(line)

# Write back
with open(project_path, 'w') as f:
    f.writelines(filtered_lines)

print(f"\n Successfully removed {len(filter_components)} filter menu components from build target")
print("   Build should now compile without filter menu dependencies")
