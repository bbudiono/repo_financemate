#!/usr/bin/env python3
"""
Fix group references in Xcode project - Simple version
"""

import re

def fix_group_references():
    """Fix group references to remove directory prefixes"""

    project_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    with open(project_file, 'r') as f:
        content = f.read()

    original_content = content
    changes_made = 0

    # Fix Services group references
    services_fixes = [
        ('Services/TransactionBuilder.swift', 'TransactionBuilder.swift'),
        ('Services/PaginationManager.swift', 'PaginationManager.swift'),
        ('Services/ImportTracker.swift', 'ImportTracker.swift'),
        ('Services/EmailCacheService.swift', 'EmailCacheService.swift'),
        ('Services/DashboardMetricsService.swift', 'DashboardMetricsService.swift')
    ]

    for wrong_path, correct_name in services_fixes:
        pattern = rf'\s+([A-F0-9]{{24}}) /\* {wrong_path} \*/'
        replacement = f'\t\t\g<1> /* {correct_name} */'
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            print(f"Fixed: {wrong_path} -> {correct_name}")
            changes_made += 1
            content = new_content

    if changes_made > 0:
        with open(project_file, 'w') as f:
            f.write(content)
        print(f" Fixed {changes_made} group references")
        return True
    else:
        print("ℹ️ No fixes needed")
        return False

if __name__ == "__main__":
    fix_group_references()