#!/usr/bin/env python3
"""
Add missing PBXBuildFile for GmailArchiveService.swift
"""

PROJECT_FILE = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

def main():
    print("Adding missing PBXBuildFile for GmailArchiveService.swift...")

    with open(PROJECT_FILE, 'r') as f:
        content = f.read()

    # Check if already exists
    if "JJS02OW7Q13KXE8WG4TXLGMV /* GmailArchiveService.swift in Sources */ = {isa = PBXBuildFile;" in content:
        print("PBXBuildFile already exists")
        return

    # Find the line after EmailCacheService build file and insert the GmailArchiveService build file
    target_line = "\t\t0A5D945D9848B184FD19BAED /* EmailCacheService.swift in Sources */ = {isa = PBXBuildFile; fileRef = 779F3E7AB1C78B0F65C81E1C /* EmailCacheService.swift */; };"
    new_line = "\t\tJJS02OW7Q13KXE8WG4TXLGMV /* GmailArchiveService.swift in Sources */ = {isa = PBXBuildFile; fileRef = 3M9OCY69E97USSCMRDUHCH5R /* GmailArchiveService.swift */; };"

    if target_line in content:
        content = content.replace(target_line, target_line + "\n" + new_line)
        print("Added PBXBuildFile for GmailArchiveService.swift")

        with open(PROJECT_FILE, 'w') as f:
            f.write(content)
        print(" Project file updated successfully")
    else:
        print(" Could not find EmailCacheService build file to use as anchor")

if __name__ == "__main__":
    main()