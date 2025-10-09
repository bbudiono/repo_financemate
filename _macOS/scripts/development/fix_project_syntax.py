#!/usr/bin/env python3
"""
Script to fix syntax errors in the project.pbxproj file
"""

def fix_project_file():
    """Fix syntax errors in the project file"""

    with open('FinanceMate.xcodeproj/project.pbxproj', 'r') as f:
        content = f.read()

    # Fix the syntax errors

    # Fix 1: Missing closing parenthesis in targets section
    content = content.replace(
        'targets = (\n\t\t\t\t9BCE076CC14C69F83263D6C5 /* FinanceMate */,\n\t\t\t\t\n\t\t\tB87EA3F23D13482AB05B1734 /* FinanceMateTests,);',
        'targets = (\n\t\t\t\t9BCE076CC14C69F83263D6C5 /* FinanceMate */,\n\t\t\t\tB87EA3F23D13482AB05B1734 /* FinanceMateTests */,\n\t\t\t);'
    )

    # Fix 2: TargetAttributes syntax error
    content = content.replace(
        '\t\t\t\t};\n\t\t\t\t\n\t\t\t\tB87EA3F23D13482AB05B1734 = {\n\t\t\t\t\tTestTargetID = B87EA3F23D13482AB05B1734;\n\t\t\t\t},};',
        '\t\t\t\t};\n\t\t\t\tB87EA3F23D13482AB05B1734 = {\n\t\t\t\t\tTestTargetID = B87EA3F23D13482AB05B1734;\n\t\t\t\t},\n\t\t\t\t};'
    )

    # Fix 3: Fix the sources build phase syntax
    content = content.replace(
        '\t\t\t\tD025CC06BDEE42D3ACC016A6 /* AutomationSection.swift in Sources */,);',
        '\t\t\t\tD025CC06BDEE42D3ACC016A6 /* AutomationSection.swift in Sources */,\n\t\t\t);'
    )

    # Fix 4: Add test files to the main group
    # Find the main group and add test group
    main_group_pattern = r'(664632500DD526A9BDF8015A /\* \*/ = \{)\s*(isa = PBXGroup;\s*children = \([^)]+)\);'
    import re

    match = re.search(main_group_pattern, content, re.DOTALL)
    if match:
        before_group = match.group(1)
        children = match.group(2)

        # Add FinanceMateTests group if not present
        if '16414403ABB84B6690859427' not in children:
            children += ',\n\t\t\t\t16414403ABB84B6690859427 /* FinanceMateTests */'

        replacement = f'{before_group}\n\t\t{children});'
        content = re.sub(main_group_pattern, replacement, content, flags=re.DOTALL)

    # Fix 5: Add test target to products group
    products_pattern = r'(C190AFCE18F9B21044E96663 /\* Products \*/ = \{)\s*(isa = PBXGroup;\s*children = \([^)]+)\);'

    match = re.search(products_pattern, content, re.DOTALL)
    if match:
        before_group = match.group(1)
        children = match.group(2)

        # Add FinanceMateTests.xctest if not present
        if '66628D07F5A543ABB89311DA' not in children:
            children += ',\n\t\t\t\t66628D07F5A543ABB89311DA /* FinanceMateTests.xctest */'

        replacement = f'{before_group}\n\t\t{children});'
        content = re.sub(products_pattern, replacement, content, flags=re.DOTALL)

    # Fix 6: Fix the build phase entries to use correct UUIDs
    # Update file references to match the actual test files
    file_ref_fixes = {
        'E728BDA24D7E5D5322C4F5B3': 'E93608D945AD4B39B48A076F',  # TransactionQueryHelperTests.swift
        'A3B5C8D9E7F2A4B6C8D0E1F2': 'A59135B9E2494F6F876181DC',  # AnthropicAPIClientTests.swift
    }

    for old_uuid, new_uuid in file_ref_fixes.items():
        content = content.replace(old_uuid, new_uuid)

    # Write the fixed content
    with open('FinanceMate.xcodeproj/project.pbxproj', 'w') as f:
        f.write(content)

    print(" Fixed syntax errors in project.pbxproj")

if __name__ == '__main__':
    fix_project_file()