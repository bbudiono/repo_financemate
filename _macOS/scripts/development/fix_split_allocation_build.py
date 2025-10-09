#!/usr/bin/env python3
"""
GREEN Phase: Fix SplitAllocation type resolution - Minimal intervention
"""

import re

def fix_split_allocation_build():
    """GREEN Phase: Add SplitAllocation.swift to Xcode target Sources"""
    print("🟢 GREEN PHASE: SplitAllocation build target inclusion")

    with open("FinanceMate.xcodeproj/project.pbxproj", 'r') as f:
        content = f.read()

    # Check Sources build phase for SplitAllocation
    sources_match = re.search(r'PBXSourcesBuildPhase.*?files = \((.*?)\);', content, re.DOTALL)
    if sources_match:
        sources_content = sources_match.group(1)
        if "864357FBBBCB4F06B0E8E18B" not in sources_content:
            # Add SplitAllocation to Sources
            new_sources = sources_content.strip() + ",\n\t\t\t\t\t864357FBBBCB4F06B0E8E18B /* SplitAllocation.swift in Sources */,"
            content = content.replace(sources_content, new_sources)

            with open("FinanceMate.xcodeproj/project.pbxproj", 'w') as f:
                f.write(content)
            print("    Added SplitAllocation.swift to Sources build phase")
        else:
            print("    SplitAllocation.swift already in build")
    return True

if __name__ == "__main__":
    fix_split_allocation_build()
    print("🟢 GREEN PHASE: SplitAllocation build fix applied")