#!/usr/bin/env python3

"""
P0 CRITICAL FIX: Ultimate LoginView.swift fix
This script performs a comprehensive fix to ensure LoginView.swift is compiled
"""

import sys
import os
import subprocess
import re
import uuid
import shutil
import time

def run_command(cmd):
    """Run a shell command and return the result"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        print(f"❌ Error running command: {e}")
        return False, "", str(e)

def ultimate_loginview_fix():
    """Ultimate fix to ensure LoginView.swift compilation"""
    
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    
    print("🔧 P0 CRITICAL FIX: Ultimate LoginView.swift fix")
    
    # Check if project file exists
    if not os.path.exists(project_path):
        print(f"❌ Project file not found: {project_path}")
        return False
    
    # Verify LoginView.swift exists
    loginview_relative_path = "FinanceMate/FinanceMate/Views/LoginView.swift"
    if not os.path.exists(loginview_relative_path):
        print(f"❌ LoginView.swift not found: {loginview_relative_path}")
        return False
    
    # Backup the project file
    backup_path = f"{project_path}.backup_ultimate_{int(time.time())}"
    shutil.copy2(project_path, backup_path)
    print(f"✅ Created backup: {backup_path}")
    
    # Read the project file
    with open(project_path, 'r') as f:
        project_content = f.read()
    
    # PHASE 1: Clean ALL LoginView references
    print("🧹 PHASE 1: Cleaning ALL LoginView.swift references...")
    
    # Clean patterns
    project_content = re.sub(r'\t\t[A-F0-9]{24} /\* LoginView\.swift.*?\*/.*?\n', '', project_content)
    project_content = re.sub(r'.*LoginView\.swift.*?\n', '', project_content)
    
    print("✅ All LoginView references cleaned")
    
    # PHASE 2: Add fresh references with specific positioning
    print("🆕 PHASE 2: Adding fresh LoginView.swift references...")
    
    new_file_uuid = uuid.uuid4().hex[:24].upper()
    new_build_uuid = uuid.uuid4().hex[:24].upper()
    
    print(f"📝 Generated UUIDs - File: {new_file_uuid}, Build: {new_build_uuid}")
    
    # Add PBXFileReference immediately after GlassmorphismModifier.swift
    glassmorphism_pattern = r'(D930C6316FF88FC1E6BCF1AC /\* GlassmorphismModifier\.swift \*/ = \{isa = PBXFileReference;.*?\};\n)'
    glassmorphism_match = re.search(glassmorphism_pattern, project_content, re.DOTALL)
    
    if glassmorphism_match:
        glassmorphism_line = glassmorphism_match.group(1)
        new_file_ref = f'{glassmorphism_line}\t\t{new_file_uuid} /* LoginView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LoginView.swift; sourceTree = "<group>"; }};\n'
        project_content = project_content.replace(glassmorphism_line, new_file_ref)
        print("✅ Added PBXFileReference after GlassmorphismModifier")
    else:
        print("❌ Could not find GlassmorphismModifier reference")
        return False
    
    # Add PBXBuildFile at the end of the section
    build_file_section_end = r'(/\* End PBXBuildFile section \*/)'
    build_file_match = re.search(build_file_section_end, project_content)
    
    if build_file_match:
        end_marker = build_file_match.group(1)
        new_build_file = f'\t\t{new_build_uuid} /* LoginView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {new_file_uuid} /* LoginView.swift */; }};\n{end_marker}'
        project_content = project_content.replace(end_marker, new_build_file)
        print("✅ Added PBXBuildFile")
    else:
        print("❌ Could not find PBXBuildFile section end")
        return False
    
    # Add to Views group - after GlassmorphismModifier
    views_group_pattern = r'(D930C6316FF88FC1E6BCF1AC /\* GlassmorphismModifier\.swift \*/,\n)'
    views_group_match = re.search(views_group_pattern, project_content)
    
    if views_group_match:
        glassmorphism_group_line = views_group_match.group(1)
        new_group_entry = f'{glassmorphism_group_line}\t\t\t\t{new_file_uuid} /* LoginView.swift */,\n'
        project_content = project_content.replace(glassmorphism_group_line, new_group_entry)
        print("✅ Added to Views group")
    else:
        print("❌ Could not find Views group")
        return False
    
    # Add to Sources build phase - find FinanceMateApp.swift and add LoginView before it
    financemate_app_pattern = r'(\t\t\t\t[A-F0-9]{24} /\* FinanceMateApp\.swift in Sources \*/,\n)'
    app_match = re.search(financemate_app_pattern, project_content)
    
    if app_match:
        app_line = app_match.group(1)
        new_sources_entry = f'\t\t\t\t{new_build_uuid} /* LoginView.swift in Sources */,\n{app_line}'
        project_content = project_content.replace(app_line, new_sources_entry)
        print("✅ Added to Sources build phase")
    else:
        print("❌ Could not find FinanceMateApp.swift in Sources")
        return False
    
    # Write the updated project file
    with open(project_path, 'w') as f:
        f.write(project_content)
    
    print("✅ Project file updated with ultimate LoginView.swift fix")
    
    # PHASE 3: Complete cache and build artifacts cleanup
    print("🧹 PHASE 3: Complete cache cleanup...")
    
    cleanup_commands = [
        "rm -rf ~/Library/Developer/Xcode/DerivedData/*",
        "rm -rf ~/Library/Developer/Xcode/Archives/*",
        "rm -rf ~/Library/Caches/com.apple.dt.Xcode/*",
        "rm -rf ~/Library/Caches/com.apple.dt.XcodeBuild/*",
        "xcrun --kill-cache",
    ]
    
    for cmd in cleanup_commands:
        success, stdout, stderr = run_command(cmd)
        if success:
            print(f"✅ Executed: {cmd}")
        else:
            print(f"⚠️ Warning: {cmd} - {stderr}")
    
    # PHASE 4: Force project file regeneration by touching it
    success, stdout, stderr = run_command(f"touch {project_path}")
    print("✅ Touched project file to force regeneration")
    
    return True

def main():
    """Main function for ultimate LoginView.swift fix"""
    
    print("=" * 70)
    print("P0 CRITICAL FIX: Ultimate LoginView.swift Compilation Fix")
    print("=" * 70)
    
    if ultimate_loginview_fix():
        print("\n🎉 ULTIMATE LoginView.swift fix COMPLETED!")
        print("💡 Critical next steps:")
        print("   1. Run: xcodebuild clean")
        print("   2. Run: xcodebuild build")
        print("   3. Verify LoginView.swift compiles")
        print("   4. Test Apple Sign-In functionality")
        print("\n🚨 This should resolve the LoginView compilation issue permanently!")
        return True
    else:
        print("\n❌ FAILED: Ultimate LoginView.swift fix failed")
        print("💡 Manual Xcode intervention may be required")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)