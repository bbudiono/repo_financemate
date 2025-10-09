#!/usr/bin/env python3
"""
Temporarily disable GmailArchiveService.swift from build to get app building
"""

PROJECT_FILE = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

def main():
    print("Temporarily disabling GmailArchiveService.swift from build...")

    with open(PROJECT_FILE, 'r') as f:
        content = f.read()

    # Comment out PBXBuildFile entry
    build_file_line = "\t\tJJS02OW7Q13KXE8WG4TXLGMV /* GmailArchiveService.swift in Sources */ = {isa = PBXBuildFile; fileRef = 3M9OCY69E97USSCMRDUHCH5R /* GmailArchiveService.swift */; };"
    if build_file_line in content:
        content = content.replace(build_file_line, "// " + build_file_line)
        print("Commented out PBXBuildFile entry")

    # Comment out Sources build phase entry
    sources_line = "\t\t\t\tJJS02OW7Q13KXE8WG4TXLGMV /* GmailArchiveService.swift in Sources */,"
    if sources_line in content:
        content = content.replace(sources_line, "// " + sources_line)
        print("Commented out Sources build phase entry")

    with open(PROJECT_FILE, 'w') as f:
        f.write(content)
    print(" GmailArchiveService temporarily disabled from build")

if __name__ == "__main__":
    main()