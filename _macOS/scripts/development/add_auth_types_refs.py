#!/usr/bin/env python3
"""
Add missing PBXFileReference and PBXBuildFile for AuthTypes.swift
"""

PROJECT_FILE = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

def main():
    print("Adding missing references for AuthTypes.swift...")

    with open(PROJECT_FILE, 'r') as f:
        content = f.read()

    # Add PBXFileReference entry
    target_line = "\t\t8C6D5F4A0E7B3A9C1D2F8E6B /* LineItem.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LineItem.swift; sourceTree = \"<group>\"; };"
    new_line = "\t\t70S9531KKWNY0BJR5UH2IVFH /* AuthTypes.swift */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = Models/AuthTypes.swift; sourceTree = \"<group>\"; };"

    if target_line in content and "70S9531KKWNY0BJR5UH2IVFH /* AuthTypes.swift */ = {isa = PBXFileReference;" not in content:
        content = content.replace(target_line, target_line + "\n" + new_line)
        print("Added PBXFileReference for AuthTypes.swift")

    # Add PBXBuildFile entry
    target_line = "\t\t8C6D5F4A0E7B3A9C1D2F8E6B /* LineItem.swift in Sources */ = {isa = PBXBuildFile; fileRef = 8C6D5F4A0E7B3A9C1D2F8E6B /* LineItem.swift */; };"
    new_line = "\t\t6XPQ2U7TJ2EQVY5TK26ZST22 /* AuthTypes.swift in Sources */ = {isa = PBXBuildFile; fileRef = 70S9531KKWNY0BJR5UH2IVFH /* AuthTypes.swift */; };"

    if target_line in content and "6XPQ2U7TJ2EQVY5TK26ZST22 /* AuthTypes.swift in Sources */ = {isa = PBXBuildFile;" not in content:
        content = content.replace(target_line, target_line + "\n" + new_line)
        print("Added PBXBuildFile for AuthTypes.swift")

    # Add to Sources build phase
    target_line = "\t\t\t\t8C6D5F4A0E7B3A9C1D2F8E6B /* LineItem.swift in Sources */,"
    new_line = "\t\t\t\t6XPQ2U7TJ2EQVY5TK26ZST22 /* AuthTypes.swift in Sources */,"

    if target_line in content and "6XPQ2U7TJ2EQVY5TK26ZST22 /* AuthTypes.swift in Sources */," not in content:
        content = content.replace(target_line, target_line + "\n" + new_line)
        print("Added to Sources build phase")

    with open(PROJECT_FILE, 'w') as f:
        f.write(content)
    print(" AuthTypes.swift references added successfully!")

if __name__ == "__main__":
    main()