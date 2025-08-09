#!/usr/bin/env python3

"""
P0 CRITICAL FIX: Complete LoginView.swift rebuild
This script completely removes and re-adds LoginView.swift to ensure compilation
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

def complete_loginview_rebuild():
    """Completely rebuild LoginView.swift references in the project"""
    
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    loginview_path = "FinanceMate/FinanceMate/Views/LoginView.swift"
    
    print("🔧 P0 CRITICAL FIX: Complete LoginView.swift rebuild")
    
    # Check if files exist
    if not os.path.exists(project_path):
        print(f"❌ Project file not found: {project_path}")
        return False
    
    if not os.path.exists(loginview_path):
        print(f"❌ LoginView.swift not found: {loginview_path}")
        return False
    
    # Backup the project file
    backup_path = f"{project_path}.backup_rebuild_{int(time.time())}"
    shutil.copy2(project_path, backup_path)
    print(f"✅ Created backup: {backup_path}")
    
    # Read the project file
    with open(project_path, 'r') as f:
        project_content = f.read()
    
    # PHASE 1: Remove ALL existing LoginView.swift references
    print("🗑️  PHASE 1: Removing ALL existing LoginView.swift references...")
    
    # Remove from PBXBuildFile section (all occurrences)
    project_content = re.sub(r'\t\t[A-F0-9]{24} /\* LoginView\.swift in Sources \*/ = \{isa = PBXBuildFile;.*?\};\n', '', project_content, flags=re.DOTALL)
    
    # Remove from PBXFileReference section (all occurrences)
    project_content = re.sub(r'\t\t[A-F0-9]{24} /\* LoginView\.swift \*/ = \{isa = PBXFileReference;.*?\};\n', '', project_content, flags=re.DOTALL)
    
    # Remove from PBXGroup (Views group) - all occurrences
    project_content = re.sub(r'\t\t\t\t[A-F0-9]{24} /\* LoginView\.swift \*/,?\n', '', project_content)
    
    # Remove from PBXSourcesBuildPhase - all occurrences
    project_content = re.sub(r'\t\t\t\t[A-F0-9]{24} /\* LoginView\.swift in Sources \*/,?\n', '', project_content)
    
    print("✅ Removed all existing LoginView.swift references")
    
    # PHASE 2: Generate NEW UUIDs and add fresh references
    print("🆕 PHASE 2: Adding fresh LoginView.swift references...")
    
    new_file_uuid = uuid.uuid4().hex[:24].upper()
    new_build_uuid = uuid.uuid4().hex[:24].upper()
    
    print(f"📝 Generated new UUIDs - File: {new_file_uuid}, Build: {new_build_uuid}")
    
    # Add new PBXFileReference at the END of the section
    file_ref_pattern = r'(/\* Begin PBXFileReference section \*/.*?)(\s*/\* End PBXFileReference section \*/)'
    file_ref_match = re.search(file_ref_pattern, project_content, re.DOTALL)
    
    if file_ref_match:
        file_ref_section = file_ref_match.group(1)
        end_marker = file_ref_match.group(2)
        new_file_ref_entry = f'\t\t{new_file_uuid} /* LoginView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LoginView.swift; sourceTree = "<group>"; }};\n'
        new_file_ref_section = file_ref_section + new_file_ref_entry + end_marker
        project_content = project_content.replace(file_ref_match.group(0), new_file_ref_section)
        print("✅ Added new PBXFileReference")
    else:
        print("❌ Could not find PBXFileReference section")
        return False
    
    # Add new PBXBuildFile at the END of the section
    build_file_pattern = r'(/\* Begin PBXBuildFile section \*/.*?)(\s*/\* End PBXBuildFile section \*/)'
    build_file_match = re.search(build_file_pattern, project_content, re.DOTALL)
    
    if build_file_match:
        build_file_section = build_file_match.group(1)
        end_marker = build_file_match.group(2)
        new_build_file_entry = f'\t\t{new_build_uuid} /* LoginView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {new_file_uuid} /* LoginView.swift */; }};\n'
        new_build_file_section = build_file_section + new_build_file_entry + end_marker
        project_content = project_content.replace(build_file_match.group(0), new_build_file_section)
        print("✅ Added new PBXBuildFile")
    else:
        print("❌ Could not find PBXBuildFile section")
        return False
    
    # Add to Views group (find Views folder and add LoginView.swift)
    views_group_pattern = r'(D930C6316FF88FC1E6BCF1AC /\* GlassmorphismModifier\.swift \*/,\n)(.*?)(\s+\);\s+path = Views;)'
    views_group_match = re.search(views_group_pattern, project_content, re.DOTALL)
    
    if views_group_match:
        views_before = views_group_match.group(1)
        views_content = views_group_match.group(2)
        views_after = views_group_match.group(3)
        
        new_login_entry = f'\t\t\t\t{new_file_uuid} /* LoginView.swift */,\n'
        new_views_section = views_before + new_login_entry + views_content + views_after
        project_content = project_content.replace(views_group_match.group(0), new_views_section)
        print("✅ Added LoginView.swift to Views group")
    else:
        # Try alternative pattern for Views group
        alt_views_pattern = r'(children = \(\n)(.*?)(D930C6316FF88FC1E6BCF1AC /\* GlassmorphismModifier\.swift \*/,\n)(.*?)(\s+\);\s+path = Views;)'
        alt_views_match = re.search(alt_views_pattern, project_content, re.DOTALL)
        
        if alt_views_match:
            children_start = alt_views_match.group(1)
            before_glassmorphism = alt_views_match.group(2)
            glassmorphism_line = alt_views_match.group(3)
            after_glassmorphism = alt_views_match.group(4)
            views_end = alt_views_match.group(5)
            
            new_login_entry = f'\t\t\t\t{new_file_uuid} /* LoginView.swift */,\n'
            new_views_section = children_start + before_glassmorphism + glassmorphism_line + new_login_entry + after_glassmorphism + views_end
            project_content = project_content.replace(alt_views_match.group(0), new_views_section)
            print("✅ Added LoginView.swift to Views group (alternative pattern)")
        else:
            print("❌ Could not find Views group")
            # Print some context for debugging
            lines = project_content.split('\n')
            for i, line in enumerate(lines):
                if 'GlassmorphismModifier.swift' in line:
                    print(f"Context around GlassmorphismModifier (line {i}):")
                    start = max(0, i-5)
                    end = min(len(lines), i+10)
                    for j in range(start, end):
                        prefix = ">>> " if j == i else "    "
                        print(f"{prefix}{j}: {lines[j]}")
                    break
            return False
    
    # Add to Sources build phase
    sources_pattern = r'(isa = PBXSourcesBuildPhase;.*?files = \()(.*?)(\s+\);\s+runOnlyForDeploymentPostprocessing = 0;)'
    sources_match = re.search(sources_pattern, project_content, re.DOTALL)
    
    if sources_match:
        sources_prefix = sources_match.group(1)
        sources_files = sources_match.group(2)
        sources_suffix = sources_match.group(3)
        
        new_sources_entry = f'\n\t\t\t\t{new_build_uuid} /* LoginView.swift in Sources */,'
        new_sources_section = sources_prefix + sources_files + new_sources_entry + sources_suffix
        project_content = project_content.replace(sources_match.group(0), new_sources_section)
        print("✅ Added LoginView.swift to Sources build phase")
    else:
        print("❌ Could not find Sources build phase")
        return False
    
    # PHASE 3: Write the updated project file
    with open(project_path, 'w') as f:
        f.write(project_content)
    
    print("✅ Project file completely rebuilt with fresh LoginView.swift references")
    
    # PHASE 4: Force complete cache clearing
    cache_dirs = [
        "~/Library/Developer/Xcode/DerivedData/FinanceMate-*",
        "~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/",
        "~/Library/Caches/com.apple.dt.Xcode/"
    ]
    
    for cache_dir in cache_dirs:
        success, stdout, stderr = run_command(f"rm -rf {cache_dir}")
        if success:
            print(f"✅ Cleared cache: {cache_dir}")
        else:
            print(f"⚠️ Could not clear cache {cache_dir}: {stderr}")
    
    return True

def main():
    """Main function to completely rebuild LoginView.swift"""
    
    print("=" * 60)
    print("P0 CRITICAL FIX: Complete LoginView.swift Rebuild")
    print("=" * 60)
    
    if complete_loginview_rebuild():
        print("\n🎉 LoginView.swift complete rebuild SUCCESS!")
        print("💡 Next steps:")
        print("   1. Clean build the project")
        print("   2. Build the project again")
        print("   3. Verify LoginView.swift compiles correctly")
        print("   4. Test Apple Sign-In functionality")
        return True
    else:
        print("\n❌ FAILED: Could not complete LoginView.swift rebuild")
        print("💡 Manual investigation required")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)