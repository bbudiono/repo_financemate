#!/usr/bin/env python3
"""
Patch Xcode project file to add LineItemViewModel and SplitAllocationViewModel to targets
"""

import re
import uuid
import sys

def generate_pbx_id():
    """Generate a 24-character hex ID for Xcode project"""
    return uuid.uuid4().hex[:24].upper()

def patch_project_file(project_path):
    """Patch the Xcode project file to add missing ViewModels"""
    
    # Read the project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Generate unique IDs for new files
    line_item_vm_ref = generate_pbx_id()
    split_alloc_vm_ref = generate_pbx_id()
    line_item_vm_build = generate_pbx_id()
    split_alloc_vm_build = generate_pbx_id()
    line_item_test_ref = generate_pbx_id()
    split_alloc_test_ref = generate_pbx_id()
    line_item_test_build = generate_pbx_id()
    split_alloc_test_build = generate_pbx_id()
    settings_vm_ref = generate_pbx_id()
    settings_vm_build = generate_pbx_id()
    
    # 1. Add PBXBuildFile entries (after existing ViewModel build files)
    build_files_addition = f"""		{line_item_vm_build} /* LineItemViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {line_item_vm_ref} /* LineItemViewModel.swift */; }};
		{split_alloc_vm_build} /* SplitAllocationViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {split_alloc_vm_ref} /* SplitAllocationViewModel.swift */; }};
		{settings_vm_build} /* SettingsViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {settings_vm_ref} /* SettingsViewModel.swift */; }};
		{line_item_test_build} /* LineItemViewModelTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {line_item_test_ref} /* LineItemViewModelTests.swift */; }};
		{split_alloc_test_build} /* SplitAllocationViewModelTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {split_alloc_test_ref} /* SplitAllocationViewModelTests.swift */; }};
"""
    
    # Insert after existing DashboardViewModel build file
    build_pattern = r'(2B37EF5E2BA52029B8E507EE /\* DashboardViewModel\.swift in Sources \*/ = {[^}]+};\n)'
    content = re.sub(build_pattern, r'\1' + build_files_addition, content)
    
    # 2. Add PBXFileReference entries (after existing ViewModel references)
    file_refs_addition = f"""		{line_item_vm_ref} /* LineItemViewModel.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LineItemViewModel.swift; sourceTree = "<group>"; }};
		{split_alloc_vm_ref} /* SplitAllocationViewModel.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationViewModel.swift; sourceTree = "<group>"; }};
		{settings_vm_ref} /* SettingsViewModel.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsViewModel.swift; sourceTree = "<group>"; }};
		{line_item_test_ref} /* LineItemViewModelTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LineItemViewModelTests.swift; sourceTree = "<group>"; }};
		{split_alloc_test_ref} /* SplitAllocationViewModelTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationViewModelTests.swift; sourceTree = "<group>"; }};
"""
    
    # Insert after existing DashboardViewModel reference
    ref_pattern = r'(4644212388479F3F7BF7B7DE /\* DashboardViewModel\.swift \*/ = {[^}]+};\n)'
    content = re.sub(ref_pattern, r'\1' + file_refs_addition, content)
    
    # 3. Add to production ViewModels group (8EED0ECEF59FFABBE1C4A0DE)
    # Find and update the production ViewModels group
    prod_vm_pattern = r'(8EED0ECEF59FFABBE1C4A0DE /\* ViewModels \*/ = {\s*isa = PBXGroup;\s*children = \(\s*4644212388479F3F7BF7B7DE /\* DashboardViewModel\.swift \*/,)'
    prod_vm_replacement = rf'\1\n\t\t\t\t{line_item_vm_ref} /* LineItemViewModel.swift */,\n\t\t\t\t{split_alloc_vm_ref} /* SplitAllocationViewModel.swift */,\n\t\t\t\t{settings_vm_ref} /* SettingsViewModel.swift */,'
    content = re.sub(prod_vm_pattern, prod_vm_replacement, content)
    
    # 4. Add to sandbox ViewModels group (EEC234358CD03D5F174A294E) 
    sandbox_vm_pattern = r'(EEC234358CD03D5F174A294E /\* ViewModels \*/ = {\s*isa = PBXGroup;\s*children = \(\s*BEBC2B26C6C3E10D334445AC /\* DashboardViewModel\.swift \*/,\s*F3E6B07F1FBE1C5755A4FE3F /\* TransactionsViewModel\.swift \*/,)'
    sandbox_vm_replacement = rf'\1\n\t\t\t\t{line_item_vm_ref} /* LineItemViewModel.swift */,\n\t\t\t\t{split_alloc_vm_ref} /* SplitAllocationViewModel.swift */,\n\t\t\t\t{settings_vm_ref} /* SettingsViewModel.swift */,'
    content = re.sub(sandbox_vm_pattern, sandbox_vm_replacement, content)
    
    # 5. Add test files to test ViewModels group
    # First find the test ViewModels group that contains DashboardViewModelTests
    test_vm_pattern = r'(children = \(\s*B34A9211E42A352FF0EE7BB3 /\* DashboardViewModelTests\.swift \*/,)'
    test_vm_replacement = rf'\1\n\t\t\t\t{line_item_test_ref} /* LineItemViewModelTests.swift */,\n\t\t\t\t{split_alloc_test_ref} /* SplitAllocationViewModelTests.swift */,'
    content = re.sub(test_vm_pattern, test_vm_replacement, content)
    
    # 6. Add to build phases - find the Sources section for FinanceMate target
    # Find the build phase that includes DashboardViewModel
    build_phase_pattern = r'(files = \([^)]*2B37EF5E2BA52029B8E507EE /\* DashboardViewModel\.swift in Sources \*/,)'
    
    # Extract the full files list and add our new files
    def add_to_build_phase(match):
        files_section = match.group(1)
        # Add our new build file references before the closing
        insertion = f'\n\t\t\t\t{line_item_vm_build} /* LineItemViewModel.swift in Sources */,\n\t\t\t\t{split_alloc_vm_build} /* SplitAllocationViewModel.swift in Sources */,\n\t\t\t\t{settings_vm_build} /* SettingsViewModel.swift in Sources */,'
        return files_section + insertion
    
    content = re.sub(build_phase_pattern, add_to_build_phase, content)
    
    # 7. Add test files to test build phase
    test_build_pattern = r'(files = \([^)]*AFDEE79B69BB56B3AF284F3D /\* DashboardViewModelTests\.swift in Sources \*/,)'
    
    def add_to_test_build_phase(match):
        files_section = match.group(1)
        insertion = f'\n\t\t\t\t{line_item_test_build} /* LineItemViewModelTests.swift in Sources */,\n\t\t\t\t{split_alloc_test_build} /* SplitAllocationViewModelTests.swift in Sources */,'
        return files_section + insertion
    
    content = re.sub(test_build_pattern, add_to_test_build_phase, content)
    
    # Write the patched content back
    with open(project_path, 'w') as f:
        f.write(content)
    
    print("✅ Successfully patched Xcode project file!")
    print(f"   - Added LineItemViewModel.swift (ID: {line_item_vm_ref})")
    print(f"   - Added SplitAllocationViewModel.swift (ID: {split_alloc_vm_ref})")
    print(f"   - Added SettingsViewModel.swift (ID: {settings_vm_ref})")
    print(f"   - Added LineItemViewModelTests.swift (ID: {line_item_test_ref})")
    print(f"   - Added SplitAllocationViewModelTests.swift (ID: {split_alloc_test_ref})")
    print("   - Updated production and sandbox ViewModels groups")
    print("   - Updated test ViewModels group")
    print("   - Added files to build phases")

if __name__ == "__main__":
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"
    
    # Create a backup first
    import shutil
    backup_path = project_path + ".backup"
    shutil.copy2(project_path, backup_path)
    print(f"📋 Created backup at: {backup_path}")
    
    try:
        patch_project_file(project_path)
    except Exception as e:
        print(f"❌ Error patching project file: {e}")
        print("   Restoring from backup...")
        shutil.copy2(backup_path, project_path)
        sys.exit(1)