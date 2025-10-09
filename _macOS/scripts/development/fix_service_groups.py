#!/usr/bin/env python3

"""
Script to add service files to the Services group in Xcode project
"""

import os
import re

def fix_service_groups():
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    # Service files to add to the Services group
    service_files = [
        ("962DA167C90245C9879D370A", "DashboardDataService.swift"),
        ("4B72D06D6E1B415789E0EA71", "TransactionValidationService.swift"),
        ("D50BB58B388642D1B16A14B0", "DashboardFormattingService.swift")
    ]

    # Read the current project file
    with open(project_path, 'r') as f:
        content = f.read()

    # Find the Services group and add our files
    services_group_pattern = r'(\t\t\t394E4BEBB6D3E4E94BB188EA /\* Services \*/ = \{\s*isa = PBXGroup;\s*children = \(\s*.*?\s*634D7FEF94094129900D472F /\* DashboardMetricsService\.swift \*/,)'

    new_service_entries = ""
    for uuid, filename in service_files:
        new_service_entries += f'\n\t\t\t\t{uuid} /* {filename} */,'

    # Insert the new entries into the Services group
    content = re.sub(services_group_pattern, r'\1' + new_service_entries + '\n\t\t\t);', content, flags=re.DOTALL)

    # Write the updated content back
    with open(project_path, 'w') as f:
        f.write(content)

    print(f" Added {len(service_files)} service files to Services group")
    return True

if __name__ == "__main__":
    fix_service_groups()