#!/usr/bin/env python3
"""Add DotEnvLoader.swift to Xcode project"""

import subprocess
import sys

def add_file_to_xcode():
    """Add DotEnvLoader.swift to the Xcode project"""
    cmd = [
        'ruby', '-e',
        '''
require 'xcodeproj'
project = Xcodeproj::Project.open("FinanceMate.xcodeproj")
target = project.targets.first
group = project.main_group["FinanceMate"]

# Check if file already exists
existing = group.files.find { |f| f.path == "DotEnvLoader.swift" }
if existing
    puts "DotEnvLoader.swift already in project"
else
    file_ref = group.new_file("DotEnvLoader.swift")
    target.source_build_phase.add_file_reference(file_ref)
    puts "Added DotEnvLoader.swift to project"
end

project.save
        '''
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, cwd='/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS')

    if result.returncode != 0:
        print(f"Error: {result.stderr}")
        return False

    print(result.stdout.strip())
    return True

if __name__ == "__main__":
    if add_file_to_xcode():
        print(" DotEnvLoader.swift added to Xcode project")
        sys.exit(0)
    else:
        print(" Failed to add DotEnvLoader.swift")
        sys.exit(1)