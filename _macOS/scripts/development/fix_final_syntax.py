#!/usr/bin/env python3
"""
Final syntax fix for project.pbxproj file
"""

def fix_final_syntax():
    """Fix remaining syntax errors"""

    with open('FinanceMate.xcodeproj/project.pbxproj', 'r') as f:
        content = f.read()

    # Fix 1: Products group syntax
    content = content.replace(
        'C190AFCE18F9B21044E96663 /* Products */ = {\n\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t6AD7F62BE980B30C777D9BCC /* FinanceMate.app */,\n\t\t\t,\n\t\t\t\t66628D07F5A543ABB89311DA /* FinanceMateTests.xctest */);',
        'C190AFCE18F9B21044E96663 /* Products */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t6AD7F62BE980B30C777D9BCC /* FinanceMate.app */,\n\t\t\t\t66628D07F5A543ABB89311DA /* FinanceMateTests.xctest */,\n\t\t\t);'
    )

    # Fix 2: Targets list syntax
    content = content.replace(
        '\t\t\ttargets = (\n\t\t\t\t9BCE076CC14C69F83263D6C5 /* FinanceMate */,\n\t\t\t\n\t\t\tB87EA3F23D13482AB05B1734 /* FinanceMateTests,);',
        '\t\t\ttargets = (\n\t\t\t\t9BCE076CC14C69F83263D6C5 /* FinanceMate */,\n\t\t\t\tB87EA3F23D13482AB05B1734 /* FinanceMateTests */,\n\t\t\t);'
    )

    # Fix 3: Empty group name
    content = content.replace(
        '\t\tD1B154DBE4684DCCA4DF28D7 /*  */ = {',
        '\t\tD1B154DBE4684DCCA4DF28D7 /* ViewModels */ = {'
    )

    # Fix 4: Add missing FinanceMateTests group to main group
    # Find main group section and ensure FinanceMateTests is included
    if '16414403ABB84B6690859427 /* FinanceMateTests */' not in content:
        # Find where to insert the FinanceMateTests group
        main_group_start = content.find('664632500DD526A9BDF8015A /* ')
        if main_group_start != -1:
            # Find the children section
            children_start = content.find('children = (', main_group_start)
            if children_start != -1:
                # Find the closing parenthesis for children
                paren_count = 0
                for i, char in enumerate(content[children_start + len('children = ('):], start=children_start + len('children = (')):
                    if char == '(':
                        paren_count += 1
                    elif char == ')':
                        if paren_count == 0:
                            # Insert before the closing parenthesis
                            before = content[:i]
                            after = content[i:]
                            test_group_ref = '\n\t\t\t\t16414403ABB84B6690859427 /* FinanceMateTests */,\n\t\t\t'
                            content = before + test_group_ref + after
                            break

    # Fix 5: Ensure proper indentation for Products group
    content = content.replace(
        '\t\tC190AFCE18F9B21044E96663 /* Products */ = {',
        '\t\tC190AFCE18F9B21044E96663 /* Products */ = {'
    )

    # Fix 6: Fix Frameworks and Resources build phases for test target
    # Find the test target and ensure it has proper build phases
    if '482B033C849446609381DDD9 /* Frameworks */' not in content:
        # Add Frameworks build phase for test target
        frameworks_phase = '\t\t482B033C849446609381DDD9 /* Frameworks */ = {\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};\n'

        # Insert before the Sources build phase
        sources_pos = content.find('\t\tAC96302E629D401C85EC654A /* Sources */')
        if sources_pos != -1:
            content = content[:sources_pos] + frameworks_phase + content[sources_pos:]

    if 'C1A4C4CF994A4498B148513D /* Resources */' not in content:
        # Add Resources build phase for test target
        resources_phase = '\t\tC1A4C4CF994A4498B148513D /* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};\n'

        # Insert after Frameworks phase
        frameworks_pos = content.find('\t\t482B033C849446609381DDD9 /* Frameworks */')
        if frameworks_pos != -1:
            # Find end of this phase
            end_pos = content.find('\t\t};\n', frameworks_pos) + 5
            content = content[:end_pos] + resources_phase + content[end_pos:]

    # Write the fixed content
    with open('FinanceMate.xcodeproj/project.pbxproj', 'w') as f:
        f.write(content)

    print(" Fixed final syntax errors in project.pbxproj")

if __name__ == '__main__':
    fix_final_syntax()