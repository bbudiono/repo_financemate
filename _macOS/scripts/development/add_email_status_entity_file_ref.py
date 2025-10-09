#!/usr/bin/env python3
"""
Add missing PBXFileReference for EmailStatusEntity.swift
"""

PROJECT_FILE = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

def main():
    print("Adding missing PBXFileReference for EmailStatusEntity.swift...")

    with open(PROJECT_FILE, 'r') as f:
        content = f.read()

    # Check if already exists
    if "FCZR9PDJB2L7VW7YR7MOG7BZ /* EmailStatusEntity.swift */ = {isa = PBXFileReference;" in content:
        print("PBXFileReference already exists")
        return

    # Find the line after TransactionBuilder reference and insert the EmailStatusEntity reference
    target_line = "\t\t71BCE3AE60C68983B30B2975 /* TransactionBuilder.swift */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = Services/TransactionBuilder.swift; sourceTree = \"<group>\"; };"
    new_line = "\t\tFCZR9PDJB2L7VW7YR7MOG7BZ /* EmailStatusEntity.swift */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = EmailStatusEntity.swift; sourceTree = \"<group>\"; };"

    if target_line in content:
        content = content.replace(target_line, target_line + "\n" + new_line)
        print("Added PBXFileReference for EmailStatusEntity.swift")

        with open(PROJECT_FILE, 'w') as f:
            f.write(content)
        print(" Project file updated successfully")
    else:
        print(" Could not find TransactionBuilder reference to use as anchor")

if __name__ == "__main__":
    main()