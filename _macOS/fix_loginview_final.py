#!/usr/bin/env python3

"""
Final comprehensive LoginView.swift fix with forced project rebuild
This script ensures LoginView.swift is properly integrated and executable is created
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

def fix_loginview_final():
    """Final comprehensive fix for LoginView.swift integration"""
    
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    
    print("🔧 FINAL COMPREHENSIVE LOGINVIEW.SWIFT FIX")
    print("=" * 50)
    
    # Step 1: Verify file exists
    loginview_path = "FinanceMate/FinanceMate/Views/LoginView.swift"
    if not os.path.exists(loginview_path):
        print(f"❌ LoginView.swift not found at {loginview_path}")
        return False
    
    print(f"✅ LoginView.swift found at {loginview_path}")
    
    # Step 2: Force complete cache clearing
    print("\n🧹 COMPLETE CACHE CLEARING...")
    
    # Clear ALL DerivedData
    success, stdout, stderr = run_command("rm -rf ~/Library/Developer/Xcode/DerivedData/*")
    if success:
        print("✅ Cleared ALL Xcode DerivedData")
    
    # Clear module cache
    success, stdout, stderr = run_command("rm -rf ~/Library/Developer/Xcode/DerivedData.noindex")
    success, stdout, stderr = run_command("rm -rf ~/Library/Developer/Xcode/UserData/IB\ Support/Simulator\ Devices")
    
    # Clear project build directory
    success, stdout, stderr = run_command("rm -rf build/")
    print("✅ Cleared project build directory")
    
    # Step 3: Read and analyze project file
    with open(project_path, 'r') as f:
        project_content = f.read()
    
    # Step 4: Ensure LoginView.swift file reference exists
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
    
    # Step 5: Ensure LoginView.swift build file reference exists
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
    
    # Step 6: Force LoginView.swift into Sources build phase (remove and re-add)
    sources_pattern = r'(isa = PBXSourcesBuildPhase;.*?files = \()(.*?)(\);.*?runOnlyForDeploymentPostprocessing = 0;)'
    sources_match = re.search(sources_pattern, project_content, re.DOTALL)
    
    if sources_match:
        sources_files = sources_match.group(2)
        
        # Remove any existing LoginView entry
        sources_files_cleaned = re.sub(r'\s*[A-F0-9]{24} /\* LoginView\.swift in Sources \*/,?\n?', '', sources_files)
        
        # Add LoginView entry
        loginview_sources_entry = f'\t\t\t\t{loginview_build_uuid} /* LoginView.swift in Sources */,\n'
        new_sources_files = sources_files_cleaned + loginview_sources_entry
        
        new_sources_section = sources_match.group(1) + new_sources_files + sources_match.group(3)
        project_content = project_content.replace(sources_match.group(0), new_sources_section)
        print("✅ LoginView.swift added to Sources build phase")
    else:
        print("❌ Could not find Sources build phase")
        return False
    
    # Step 7: Write updated project file
    with open(project_path, 'w') as f:
        f.write(project_content)
    
    print("✅ Project file updated successfully")
    
    # Step 8: Force clean build
    print("\n🔨 PERFORMING COMPLETE REBUILD...")
    
    # Clean
    success, stdout, stderr = run_command("xcodebuild clean -project FinanceMate.xcodeproj -scheme FinanceMate")
    if success:
        print("✅ Xcode clean completed")
    else:
        print(f"❌ Xcode clean failed: {stderr}")
        return False
    
    # Build with verbose output
    print("\n🏗️ BUILDING WITH VERBOSE OUTPUT...")
    success, stdout, stderr = run_command("xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate build")
    
    if success:
        print("✅ Build completed successfully!")
        
        # Verify executable was created
        executable_path = "/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app/Contents/MacOS/FinanceMate"
        
        # Find actual DerivedData directory
        success, stdout, stderr = run_command("find ~/Library/Developer/Xcode/DerivedData -name 'FinanceMate-*' -type d")
        if success and stdout.strip():
            derived_data_dir = stdout.strip().split('\n')[0]  # Take first match
            executable_path = f"{derived_data_dir}/Build/Products/Debug/FinanceMate.app/Contents/MacOS/FinanceMate"
            
            if os.path.exists(executable_path):
                print(f"✅ Executable created successfully: {executable_path}")
                return True
            else:
                print(f"⚠️ Build succeeded but executable not found at: {executable_path}")
        
        return True
    else:
        print(f"❌ Build failed:")
        print(stdout)
        print(stderr)
        return False

def main():
    """Main function"""
    print("FINAL COMPREHENSIVE LOGINVIEW.SWIFT FIX FOR FINANCEMATE")
    print("=" * 60)
    
    if fix_loginview_final():
        print("\n🎉 FINAL FIX COMPLETED SUCCESSFULLY")
        print("💡 Next steps:")
        print("   1. Launch the app: open [path-to-FinanceMate.app]")
        print("   2. Test Apple Sign-In functionality")
        print("   3. Verify Error 1000 resolution")
        return True
    else:
        print("\n❌ FINAL FIX FAILED")
        print("💡 Manual investigation required")
        return False

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)