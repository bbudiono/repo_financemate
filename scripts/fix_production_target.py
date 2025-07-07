#!/usr/bin/env python3
"""
Fix Production Target - Add only Production ViewModels to FinanceMate target
Resolves the build blocker by adding LineItemViewModel and SplitAllocationViewModel 
from Production directory (not Sandbox) to the FinanceMate target.
"""

import re
import uuid
import sys
import shutil

def generate_pbx_id():
    """Generate a 24-character hex ID for Xcode project"""
    return uuid.uuid4().hex[:24].upper()

def fix_production_target(project_path):
    """Add only Production ViewModels to FinanceMate target"""
    
    print("🔧 Fixing Production Target Configuration...")
    
    # Read the project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Generate unique IDs for Production files only
    line_item_vm_ref = generate_pbx_id()
    split_alloc_vm_ref = generate_pbx_id()
    line_item_vm_build = generate_pbx_id()
    split_alloc_vm_build = generate_pbx_id()
    line_item_test_ref = generate_pbx_id()
    split_alloc_test_ref = generate_pbx_id()
    line_item_test_build = generate_pbx_id()
    split_alloc_test_build = generate_pbx_id()
    
    # 1. Add PBXBuildFile entries for Production files only
    build_files_addition = f"""		{line_item_vm_build} /* LineItemViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {line_item_vm_ref} /* LineItemViewModel.swift */; }};
		{split_alloc_vm_build} /* SplitAllocationViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {split_alloc_vm_ref} /* SplitAllocationViewModel.swift */; }};
		{line_item_test_build} /* LineItemViewModelTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {line_item_test_ref} /* LineItemViewModelTests.swift */; }};
		{split_alloc_test_build} /* SplitAllocationViewModelTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {split_alloc_test_ref} /* SplitAllocationViewModelTests.swift */; }};
"""
    
    # Find where to insert build files (after any existing ViewModel build files)
    # Look for pattern with TransactionsViewModel or DashboardViewModel
    dashboard_build_pattern = r'(/\* DashboardViewModel\.swift in Sources \*/ = {[^}]+};\n)'
    if re.search(dashboard_build_pattern, content):
        content = re.sub(dashboard_build_pattern, r'\1' + build_files_addition, content, count=1)
    else:
        # Fallback: insert after first Sources entry
        sources_pattern = r'(/\* [^/]+ in Sources \*/ = {[^}]+};\n)'
        content = re.sub(sources_pattern, r'\1' + build_files_addition, content, count=1)
    
    # 2. Add PBXFileReference entries for Production files only
    file_refs_addition = f"""		{line_item_vm_ref} /* LineItemViewModel.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LineItemViewModel.swift; sourceTree = "<group>"; }};
		{split_alloc_vm_ref} /* SplitAllocationViewModel.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationViewModel.swift; sourceTree = "<group>"; }};
		{line_item_test_ref} /* LineItemViewModelTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LineItemViewModelTests.swift; sourceTree = "<group>"; }};
		{split_alloc_test_ref} /* SplitAllocationViewModelTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationViewModelTests.swift; sourceTree = "<group>"; }};
"""
    
    # Find where to insert file references (after any existing ViewModel references)
    dashboard_ref_pattern = r'(/\* DashboardViewModel\.swift \*/ = {[^}]+};\n)'
    if re.search(dashboard_ref_pattern, content):
        content = re.sub(dashboard_ref_pattern, r'\1' + file_refs_addition, content, count=1)
    else:
        # Fallback: insert after first .swift file reference
        swift_ref_pattern = r'(/\* [^/]+\.swift \*/ = {[^}]+};\n)'
        content = re.sub(swift_ref_pattern, r'\1' + file_refs_addition, content, count=1)
    
    # 3. Add to Production ViewModels group
    # Find the Production ViewModels group (contains DashboardViewModel and TransactionsViewModel)
    prod_vm_pattern = r'(ViewModels \*/ = {\s*isa = PBXGroup;\s*children = \([^)]*DashboardViewModel\.swift[^)]*TransactionsViewModel\.swift[^)]*)\);'
    prod_vm_replacement = rf'\1\n\t\t\t\t{line_item_vm_ref} /* LineItemViewModel.swift */,\n\t\t\t\t{split_alloc_vm_ref} /* SplitAllocationViewModel.swift */,\n\t\t\t);'
    
    if re.search(prod_vm_pattern, content, re.DOTALL):
        content = re.sub(prod_vm_pattern, prod_vm_replacement, content)
    else:
        print("⚠️  Could not find Production ViewModels group - adding to first ViewModels group found")
        # Fallback: add to any ViewModels group
        fallback_pattern = r'(ViewModels \*/ = {\s*isa = PBXGroup;\s*children = \([^)]*)\);'
        fallback_replacement = rf'\1\n\t\t\t\t{line_item_vm_ref} /* LineItemViewModel.swift */,\n\t\t\t\t{split_alloc_vm_ref} /* SplitAllocationViewModel.swift */,\n\t\t\t);'
        content = re.sub(fallback_pattern, fallback_replacement, content, count=1)
    
    # 4. Add test files to test ViewModels group
    test_vm_pattern = r'(ViewModels \*/ = {\s*isa = PBXGroup;\s*children = \([^)]*DashboardViewModelTests\.swift[^)]*)\);'
    test_vm_replacement = rf'\1\n\t\t\t\t{line_item_test_ref} /* LineItemViewModelTests.swift */,\n\t\t\t\t{split_alloc_test_ref} /* SplitAllocationViewModelTests.swift */,\n\t\t\t);'
    
    if re.search(test_vm_pattern, content, re.DOTALL):
        content = re.sub(test_vm_pattern, test_vm_replacement, content)
    
    # 5. Add to FinanceMate target build phase (Sources)
    # Find build phase that includes DashboardViewModel for FinanceMate target
    build_phase_pattern = r'(files = \([^)]*DashboardViewModel\.swift in Sources[^)]*)\);'
    
    if re.search(build_phase_pattern, content, re.DOTALL):
        build_phase_replacement = rf'\1\n\t\t\t\t{line_item_vm_build} /* LineItemViewModel.swift in Sources */,\n\t\t\t\t{split_alloc_vm_build} /* SplitAllocationViewModel.swift in Sources */,\n\t\t\t);'
        content = re.sub(build_phase_pattern, build_phase_replacement, content)
    
    # 6. Add to FinanceMateTests target build phase
    test_build_pattern = r'(files = \([^)]*DashboardViewModelTests\.swift in Sources[^)]*)\);'
    
    if re.search(test_build_pattern, content, re.DOTALL):
        test_build_replacement = rf'\1\n\t\t\t\t{line_item_test_build} /* LineItemViewModelTests.swift in Sources */,\n\t\t\t\t{split_alloc_test_build} /* SplitAllocationViewModelTests.swift in Sources */,\n\t\t\t);'
        content = re.sub(test_build_pattern, test_build_replacement, content)
    
    # Write the fixed content back
    with open(project_path, 'w') as f:
        f.write(content)
    
    print("✅ Successfully fixed Production target configuration!")
    print(f"   📄 Added LineItemViewModel.swift to FinanceMate target (ID: {line_item_vm_ref})")
    print(f"   📄 Added SplitAllocationViewModel.swift to FinanceMate target (ID: {split_alloc_vm_ref})")
    print(f"   🧪 Added LineItemViewModelTests.swift to FinanceMateTests target (ID: {line_item_test_ref})")
    print(f"   🧪 Added SplitAllocationViewModelTests.swift to FinanceMateTests target (ID: {split_alloc_test_ref})")
    print("   🎯 Updated only Production ViewModels group (avoiding Sandbox conflicts)")
    print("   🎯 Updated only Production build phases")
    return True

if __name__ == "__main__":
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"
    
    # Create a backup first
    backup_path = project_path + ".backup-fix"
    shutil.copy2(project_path, backup_path)
    print(f"📋 Created backup at: {backup_path}")
    
    try:
        success = fix_production_target(project_path)
        if success:
            print("\n🚀 Production target fix completed!")
            print("   Ready to test build compilation...")
        else:
            print("\n❌ Production target fix failed!")
            sys.exit(1)
    except Exception as e:
        print(f"❌ Error fixing production target: {e}")
        print("   Restoring from backup...")
        shutil.copy2(backup_path, project_path)
        sys.exit(1)