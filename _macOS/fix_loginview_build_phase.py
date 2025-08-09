#!/usr/bin/env python3

"""
P0 Critical Fix: Add LoginView.swift to build phases correctly
This script ensures LoginView.swift is properly included in the compilation
"""

import sys
import os
import subprocess
import re
import uuid

def run_command(cmd):
    """Run a shell command and return the result"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        print(f"❌ Error running command: {e}")
        return False, "", str(e)

def fix_loginview_build_phase():
    """Add LoginView.swift to the build phases correctly"""
    
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    
    print("🔧 P0 CRITICAL FIX: Adding LoginView.swift to build phases")
    
    # Check if project file exists
    if not os.path.exists(project_path):
        print(f"❌ Project file not found: {project_path}")
        return False
    
    # Read the project file
    with open(project_path, 'r') as f:
        project_content = f.read()
    
    # Find the LoginView.swift file reference
    loginview_file_pattern = r'([A-F0-9]{24}) /\* LoginView\.swift \*/ = \{isa = PBXFileReference.*?\};'
    loginview_file_match = re.search(loginview_file_pattern, project_content, re.DOTALL)
    
    if not loginview_file_match:
        print("❌ LoginView.swift file reference not found in project")
        return False
    
    loginview_file_uuid = loginview_file_match.group(1)
    print(f"📝 Found LoginView.swift file reference: {loginview_file_uuid}")
    
    # Check if there's already a build file reference for LoginView.swift
    loginview_build_pattern = r'([A-F0-9]{24}) /\* LoginView\.swift in Sources \*/ = \{isa = PBXBuildFile.*?\};'
    loginview_build_match = re.search(loginview_build_pattern, project_content)
    
    loginview_build_uuid = None
    if loginview_build_match:
        loginview_build_uuid = loginview_build_match.group(1)
        print(f"📝 Found existing LoginView.swift build reference: {loginview_build_uuid}")
    else:
        # Create a new build file reference
        loginview_build_uuid = uuid.uuid4().hex[:24].upper()
        build_file_entry = f'\t\t{loginview_build_uuid} /* LoginView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {loginview_file_uuid} /* LoginView.swift */; }};'
        
        # Find the PBXBuildFile section and add the new entry
        build_file_section_pattern = r'(/\* Begin PBXBuildFile section \*/.*?)(/\* End PBXBuildFile section \*/)'
        build_file_match = re.search(build_file_section_pattern, project_content, re.DOTALL)
        
        if build_file_match:
            build_file_section = build_file_match.group(1)
            new_build_file_section = build_file_section + build_file_entry + '\n'
            project_content = project_content.replace(build_file_match.group(1), new_build_file_section)
            print(f"✅ Added LoginView.swift build file reference: {loginview_build_uuid}")
        else:
            print("❌ Could not find PBXBuildFile section")
            return False
    
    # Now ensure LoginView.swift is in the Sources build phase
    sources_pattern = r'(isa = PBXSourcesBuildPhase;.*?files = \()(.*?)(\);.*?runOnlyForDeploymentPostprocessing = 0;)'
    sources_match = re.search(sources_pattern, project_content, re.DOTALL)
    
    if not sources_match:
        print("❌ Could not find Sources build phase")
        return False
    
    sources_prefix = sources_match.group(1)
    sources_files = sources_match.group(2)
    sources_suffix = sources_match.group(3)
    
    # Check if LoginView.swift is already in the Sources build phase
    if loginview_build_uuid not in sources_files:
        # Add LoginView.swift to the Sources build phase
        loginview_sources_entry = f'\t\t\t\t{loginview_build_uuid} /* LoginView.swift in Sources */,\n'
        new_sources_files = sources_files + loginview_sources_entry
        
        # Replace the Sources build phase
        new_sources_section = sources_prefix + new_sources_files + sources_suffix
        old_sources_section = sources_match.group(0)
        project_content = project_content.replace(old_sources_section, new_sources_section)
        print(f"✅ Added LoginView.swift to Sources build phase")
    else:
        print("✅ LoginView.swift already in Sources build phase")
    
    # Write the updated project file
    with open(project_path, 'w') as f:
        f.write(project_content)
    
    print("✅ Project file updated successfully")
    
    # Clear derived data to force rebuild
    success, stdout, stderr = run_command("rm -rf ~/Library/Developer/Xcode/DerivedData/FinanceMate-*")
    if success:
        print("✅ Cleared Xcode DerivedData cache")
    else:
        print(f"⚠️ Could not clear cache: {stderr}")
    
    return True

def main():
    """Main function to fix LoginView.swift build phase issues"""
    
    print("=" * 60)
    print("P0 CRITICAL FIX: LoginView.swift Build Phase Issue")
    print("=" * 60)
    
    if fix_loginview_build_phase():
        print("\n🎉 LoginView.swift build phase fix completed")
        print("💡 Next steps:")
        print("   1. Build the project again")
        print("   2. Verify LoginView.swift compiles correctly")
        print("   3. Test Apple Sign-In functionality")
        return True
    else:
        print("\n❌ FAILED: Could not fix LoginView.swift build phase")
        print("💡 Manual investigation required")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)