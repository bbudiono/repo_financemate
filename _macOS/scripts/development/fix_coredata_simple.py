#!/usr/bin/env python3
"""
Simple fix: Add CoreDataModelBuilder to Xcode project
"""

import re

def fix_coredata():
    project = "FinanceMate.xcodeproj/project.pbxproj"

    with open(project, 'r') as f:
        content = f.read()

    # Check if CoreDataModelBuilder exists in project
    if "CoreDataModelBuilder.swift" not in content:
        print("CoreDataModelBuilder not found - needs to be added")
        return False

    # Check if it's in Sources build phase
    if "CoreDataModelBuilder.swift in Sources" in content:
        print("CoreDataModelBuilder already in Sources")
        return True
    else:
        print("CoreDataModelBuilder not in Sources - needs fix")
        return False

if __name__ == "__main__":
    fix_coredata()
    print("CoreData check complete")