#!/usr/bin/env python3

"""
P0 Critical Fix: Add LoginView.swift to Xcode project target
This script fixes the missing LoginView.swift from the FinanceMate target compilation
"""

import sys
import os
import subprocess
import uuid

def run_command(cmd):
    """Run a shell command and return the result"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        print(f"❌ Error running command: {e}")
        return False, "", str(e)

def add_loginview_to_project():
    """Add LoginView.swift to the FinanceMate Xcode project target"""
    
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    loginview_path = "FinanceMate/FinanceMate/Views/LoginView.swift"
    
    print("🔧 P0 CRITICAL FIX: Adding LoginView.swift to Xcode project target")
    
    # Check if project file exists
    if not os.path.exists(project_path):
        print(f"❌ Project file not found: {project_path}")
        return False
    
    # Check if LoginView.swift exists
    if not os.path.exists(loginview_path):
        print(f"❌ LoginView.swift not found: {loginview_path}")
        return False
    
    # Read the project file
    with open(project_path, 'r') as f:
        project_content = f.read()
    
    # Generate a new UUID for the LoginView.swift file reference
    file_ref_uuid = str(uuid.uuid4()).upper().replace('-', '')[:24]
    build_file_uuid = str(uuid.uuid4()).upper().replace('-', '')[:24]
    
    print(f"📝 Generated UUIDs:")
    print(f"   File Reference UUID: {file_ref_uuid}")
    print(f"   Build File UUID: {build_file_uuid}")
    
    # Find the PBXFileReference section and add LoginView.swift
    if "/* LoginView.swift */" in project_content:
        print("✅ LoginView.swift already exists in project file")
        return True
    
    # Find the Views group and add LoginView.swift file reference
    views_section_start = project_content.find("/* Views */")
    if views_section_start == -1:
        print("❌ Views group not found in project file")
        return False
    
    # Find the children section for Views group
    views_section = project_content[views_section_start:views_section_start + 2000]
    children_start = views_section.find("children = (")
    if children_start == -1:
        print("❌ Views children section not found")
        return False
    
    # Find the insertion point (end of children array)
    insertion_point = views_section.find(");", children_start)
    if insertion_point == -1:
        print("❌ Views children end not found")
        return False
    
    # Calculate actual insertion point in the full content
    actual_insertion_point = views_section_start + insertion_point
    
    # Insert LoginView.swift reference
    loginview_ref = f"\t\t\t\t{file_ref_uuid} /* LoginView.swift */,\n"
    project_content = project_content[:actual_insertion_point] + loginview_ref + project_content[actual_insertion_point:]
    
    # Add PBXFileReference for LoginView.swift
    file_reference_section = "/* End PBXFileReference section */"
    file_ref_entry = f"\t\t{file_ref_uuid} /* LoginView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LoginView.swift; sourceTree = \"<group>\"; }};\n"
    
    file_ref_insertion = project_content.find(file_reference_section)
    if file_ref_insertion == -1:
        print("❌ PBXFileReference section not found")
        return False
    
    project_content = project_content[:file_ref_insertion] + file_ref_entry + project_content[file_ref_insertion:]
    
    # Add to Sources Build Phase
    sources_section = "/* Sources */ = {"
    sources_start = project_content.find(sources_section)
    if sources_start == -1:
        print("❌ Sources build phase not found")
        return False
    
    # Find the files array in Sources build phase
    files_start = project_content.find("files = (", sources_start)
    if files_start == -1:
        print("❌ Sources files array not found")
        return False
    
    # Find the end of files array
    files_end = project_content.find(");", files_start)
    if files_end == -1:
        print("❌ Sources files array end not found")
        return False
    
    # Insert LoginView.swift build file reference
    build_file_ref = f"\t\t\t\t{build_file_uuid} /* LoginView.swift in Sources */,\n"
    project_content = project_content[:files_end] + build_file_ref + project_content[files_end:]
    
    # Add PBXBuildFile for LoginView.swift
    build_file_section = "/* End PBXBuildFile section */"
    build_file_entry = f"\t\t{build_file_uuid} /* LoginView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* LoginView.swift */; }};\n"
    
    build_file_insertion = project_content.find(build_file_section)
    if build_file_insertion == -1:
        print("❌ PBXBuildFile section not found")
        return False
    
    project_content = project_content[:build_file_insertion] + build_file_entry + project_content[build_file_insertion:]
    
    # Create backup of original project file
    backup_path = f"{project_path}.backup_loginview_fix"
    with open(backup_path, 'w') as f:
        with open(project_path, 'r') as orig:
            f.write(orig.read())
    print(f"📄 Created backup: {backup_path}")
    
    # Write the updated project file
    with open(project_path, 'w') as f:
        f.write(project_content)
    
    print("✅ Successfully added LoginView.swift to Xcode project target")
    return True

def main():
    """Main function to fix the missing LoginView.swift issue"""
    
    print("=" * 60)
    print("P0 CRITICAL FIX: LoginView.swift Missing from Xcode Target")
    print("=" * 60)
    
    if add_loginview_to_project():
        print("\n🎉 SUCCESS: LoginView.swift has been added to the project target")
        print("💡 Next steps:")
        print("   1. Build the project again")  
        print("   2. Verify LoginView compiles correctly")
        print("   3. Test Apple Sign-In functionality")
        return True
    else:
        print("\n❌ FAILED: Could not add LoginView.swift to project target")
        print("💡 Manual fix required:")
        print("   1. Open Xcode")
        print("   2. Right-click on Views folder")
        print("   3. Add LoginView.swift to target")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)