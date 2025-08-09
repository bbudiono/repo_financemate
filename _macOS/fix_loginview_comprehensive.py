#!/usr/bin/env python3

"""
Comprehensive LoginView.swift fix for FinanceMate build
This script performs all necessary fixes to get LoginView.swift working
"""

import os
import re
import uuid
import subprocess
import shutil

def run_command(cmd):
    """Run a shell command and return the result"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        print(f"❌ Error running command: {e}")
        return False, "", str(e)

def fix_loginview_comprehensive():
    """Comprehensive fix for LoginView.swift integration"""
    
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    
    print("🔧 COMPREHENSIVE LOGINVIEW.SWIFT FIX")
    print("=" * 50)
    
    # Step 1: Verify file exists
    loginview_path = "FinanceMate/FinanceMate/Views/LoginView.swift"
    if not os.path.exists(loginview_path):
        print(f"❌ LoginView.swift not found at {loginview_path}")
        return False
    
    print(f"✅ LoginView.swift found at {loginview_path}")
    
    # Step 2: Read project file
    with open(project_path, 'r') as f:
        project_content = f.read()
    
    # Step 3: Find or create LoginView.swift file reference
    loginview_file_pattern = r'([A-F0-9]{24}) /\* LoginView\.swift \*/ = \{isa = PBXFileReference.*?\};'
    loginview_file_match = re.search(loginview_file_pattern, project_content, re.DOTALL)
    
    if not loginview_file_match:
        # Create new file reference
        loginview_file_uuid = uuid.uuid4().hex[:24].upper()
        file_ref_entry = f'\t\t{loginview_file_uuid} /* LoginView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LoginView.swift; sourceTree = "<group>"; }};'
        
        # Find PBXFileReference section
        file_ref_pattern = r'(/\* Begin PBXFileReference section \*/.*?)(/\* End PBXFileReference section \*/)'
        file_ref_match = re.search(file_ref_pattern, project_content, re.DOTALL)
        
        if file_ref_match:
            file_ref_section = file_ref_match.group(1)
            new_file_ref_section = file_ref_section + file_ref_entry + '\n'
            project_content = project_content.replace(file_ref_match.group(1), new_file_ref_section)
            print(f"✅ Created LoginView.swift file reference: {loginview_file_uuid}")
        else:
            print("❌ Could not find PBXFileReference section")
            return False
    else:
        loginview_file_uuid = loginview_file_match.group(1)
        print(f"✅ Found existing LoginView.swift file reference: {loginview_file_uuid}")
    
    # Step 4: Find or create LoginView.swift build file reference
    loginview_build_pattern = r'([A-F0-9]{24}) /\* LoginView\.swift in Sources \*/ = \{isa = PBXBuildFile.*?\};'
    loginview_build_match = re.search(loginview_build_pattern, project_content)
    
    if not loginview_build_match:
        # Create new build file reference
        loginview_build_uuid = uuid.uuid4().hex[:24].upper()
        build_file_entry = f'\t\t{loginview_build_uuid} /* LoginView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {loginview_file_uuid} /* LoginView.swift */; }};'
        
        # Find PBXBuildFile section
        build_file_pattern = r'(/\* Begin PBXBuildFile section \*/.*?)(/\* End PBXBuildFile section \*/)'
        build_file_match = re.search(build_file_pattern, project_content, re.DOTALL)
        
        if build_file_match:
            build_file_section = build_file_match.group(1)
            new_build_file_section = build_file_section + build_file_entry + '\n'
            project_content = project_content.replace(build_file_match.group(1), new_build_file_section)
            print(f"✅ Created LoginView.swift build file reference: {loginview_build_uuid}")
        else:
            print("❌ Could not find PBXBuildFile section")
            return False
    else:
        loginview_build_uuid = loginview_build_match.group(1)
        print(f"✅ Found existing LoginView.swift build file reference: {loginview_build_uuid}")
    
    # Step 5: Add LoginView.swift to Sources build phase
    sources_pattern = r'(isa = PBXSourcesBuildPhase;.*?files = \()(.*?)(\);.*?runOnlyForDeploymentPostprocessing = 0;)'
    sources_match = re.search(sources_pattern, project_content, re.DOTALL)
    
    if sources_match:
        sources_files = sources_match.group(2)
        if loginview_build_uuid not in sources_files:
            loginview_sources_entry = f'\t\t\t\t{loginview_build_uuid} /* LoginView.swift in Sources */,\n'
            new_sources_files = sources_files + loginview_sources_entry
            
            new_sources_section = sources_match.group(1) + new_sources_files + sources_match.group(3)
            project_content = project_content.replace(sources_match.group(0), new_sources_section)
            print("✅ Added LoginView.swift to Sources build phase")
        else:
            print("✅ LoginView.swift already in Sources build phase")
    else:
        print("❌ Could not find Sources build phase")
        return False
    
    # Step 6: Add LoginView.swift to Views group
    views_group_pattern = r'([A-F0-9]{24}) /\* Views \*/ = \{.*?children = \((.*?)\);.*?name = Views;.*?\};'
    views_group_match = re.search(views_group_pattern, project_content, re.DOTALL)
    
    if views_group_match:
        views_children = views_group_match.group(2)
        if loginview_file_uuid not in views_children:
            loginview_group_entry = f'\t\t\t\t{loginview_file_uuid} /* LoginView.swift */,\n'
            new_views_children = views_children + loginview_group_entry
            
            new_views_group = views_group_match.group(0).replace(views_children, new_views_children)
            project_content = project_content.replace(views_group_match.group(0), new_views_group)
            print("✅ Added LoginView.swift to Views group")
        else:
            print("✅ LoginView.swift already in Views group")
    else:
        print("⚠️ Could not find Views group - LoginView.swift may not appear in Xcode navigator")
    
    # Step 7: Write updated project file
    with open(project_path, 'w') as f:
        f.write(project_content)
    
    print("✅ Project file updated successfully")
    
    # Step 8: Clear all caches and rebuild
    print("\n🧹 CLEARING ALL BUILD CACHES...")
    
    # Clear DerivedData
    success, stdout, stderr = run_command("rm -rf ~/Library/Developer/Xcode/DerivedData/FinanceMate-*")
    if success:
        print("✅ Cleared Xcode DerivedData")
    else:
        print(f"⚠️ Could not clear DerivedData: {stderr}")
    
    # Clear module cache
    success, stdout, stderr = run_command("rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache*")
    if success:
        print("✅ Cleared Module Cache")
    
    # Clean Xcode build
    print("\n🔨 PERFORMING CLEAN BUILD...")
    success, stdout, stderr = run_command("xcodebuild clean -project FinanceMate.xcodeproj -scheme FinanceMate")
    if success:
        print("✅ Xcode clean completed")
    else:
        print(f"❌ Xcode clean failed: {stderr}")
        return False
    
    return True

def main():
    """Main function"""
    print("COMPREHENSIVE LOGINVIEW.SWIFT FIX FOR FINANCEMATE")
    print("=" * 60)
    
    if fix_loginview_comprehensive():
        print("\n🎉 COMPREHENSIVE FIX COMPLETED SUCCESSFULLY")
        print("💡 Next steps:")
        print("   1. Build the project: xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate build")
        print("   2. Test Apple Sign-In functionality")
        return True
    else:
        print("\n❌ COMPREHENSIVE FIX FAILED")
        print("💡 Manual investigation required")
        return False

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)