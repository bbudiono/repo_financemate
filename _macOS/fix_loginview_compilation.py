#!/usr/bin/env python3

"""
P0 Critical Fix: Ensure LoginView.swift is properly included in compilation
"""

import sys
import os
import subprocess
import re

def run_command(cmd):
    """Run a shell command and return the result"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        print(f"❌ Error running command: {e}")
        return False, "", str(e)

def fix_loginview_compilation():
    """Ensure LoginView.swift is properly included in the compilation"""
    
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    
    print("🔧 P0 CRITICAL FIX: Ensuring LoginView.swift is included in compilation")
    
    # Check if project file exists
    if not os.path.exists(project_path):
        print(f"❌ Project file not found: {project_path}")
        return False
    
    # Read the project file
    with open(project_path, 'r') as f:
        project_content = f.read()
    
    # Check if LoginView.swift is already in the Sources build phase
    sources_section_pattern = r'\/\* Sources \*\/ = \{[^}]*files = \([^)]*\);'
    sources_match = re.search(sources_section_pattern, project_content, re.DOTALL)
    
    if not sources_match:
        print("❌ Sources build phase not found")
        return False
    
    sources_section = sources_match.group(0)
    print(f"📝 Found Sources build phase")
    
    # Check if LoginView.swift build file reference exists
    loginview_buildfile_pattern = r'([A-F0-9]{24}) \/\* LoginView\.swift in Sources \*\/'
    loginview_match = re.search(loginview_buildfile_pattern, sources_section)
    
    if loginview_match:
        print("✅ LoginView.swift already in Sources build phase")
        
        # Check if it's actually being found in the file list
        loginview_uuid = loginview_match.group(1)
        print(f"📝 LoginView build file UUID: {loginview_uuid}")
        
        # The issue might be with file paths or case sensitivity
        # Let's rebuild the project to force re-evaluation
        print("🔄 Clearing build cache to force re-evaluation")
        
        # Clear derived data
        success, stdout, stderr = run_command("rm -rf ~/Library/Developer/Xcode/DerivedData/FinanceMate-*")
        if success:
            print("✅ Cleared Xcode DerivedData cache")
        else:
            print(f"⚠️ Could not clear cache: {stderr}")
        
        return True
    else:
        print("❌ LoginView.swift not found in Sources build phase")
        return False

def main():
    """Main function to fix LoginView compilation issues"""
    
    print("=" * 60)
    print("P0 CRITICAL FIX: LoginView.swift Compilation Issue")
    print("=" * 60)
    
    if fix_loginview_compilation():
        print("\n🎉 LoginView.swift compilation fix attempted")
        print("💡 Next steps:")
        print("   1. Build the project again")
        print("   2. Verify LoginView compiles correctly")
        print("   3. Test Apple Sign-In functionality")
        return True
    else:
        print("\n❌ FAILED: Could not fix LoginView.swift compilation")
        print("💡 Manual investigation required")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)