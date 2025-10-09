#!/usr/bin/env python3
"""
Add missing PBXFileReference for GmailArchiveService.swift
"""

PROJECT_FILE = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

def main():
    print("Adding missing PBXFileReference for GmailArchiveService.swift...")

    with open(PROJECT_FILE, 'r') as f:
        content = f.read()

    # Check if already exists
    if "3M9OCY69E97USSCMRDUHCH5R /* GmailArchiveService.swift */ = {isa = PBXFileReference;" in content:
        print("PBXFileReference already exists")
        return

    # Find the line after EmailCacheService reference and insert the GmailArchiveService reference
    target_line = "\t\t779F3E7AB1C78B0F65C81E1C /* EmailCacheService.swift */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = Services/EmailCacheService.swift; sourceTree = \"<group>\"; };"
    new_line = "\t\t3M9OCY69E97USSCMRDUHCH5R /* GmailArchiveService.swift */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = Services/GmailArchiveService.swift; sourceTree = \"<group>\"; };"

    if target_line in content:
        content = content.replace(target_line, target_line + "\n" + new_line)
        print("Added PBXFileReference for GmailArchiveService.swift")

        with open(PROJECT_FILE, 'w') as f:
            f.write(content)
        print(" Project file updated successfully")
    else:
        print(" Could not find EmailCacheService reference to use as anchor")

if __name__ == "__main__":
    main()