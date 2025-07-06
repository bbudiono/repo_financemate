#!/usr/bin/env python3
"""
Simplified approach to patch Xcode project file
"""

import re

def patch_project():
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"
    
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Check if already patched
    if 'LineItemViewModel.swift' in content and 'SplitAllocationViewModel.swift' in content:
        print("✅ Project already contains ViewModels!")
        return
    
    # Add file references
    file_refs = """		ABCDEF0123456789ABCDEF01 /* LineItemViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LineItemViewModel.swift; sourceTree = "<group>"; };
		ABCDEF0123456789ABCDEF02 /* SplitAllocationViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationViewModel.swift; sourceTree = "<group>"; };
		ABCDEF0123456789ABCDEF03 /* SettingsViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsViewModel.swift; sourceTree = "<group>"; };
		ABCDEF0123456789ABCDEF04 /* LineItemViewModelTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LineItemViewModelTests.swift; sourceTree = "<group>"; };
		ABCDEF0123456789ABCDEF05 /* SplitAllocationViewModelTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationViewModelTests.swift; sourceTree = "<group>"; };
"""
    
    # Insert after an existing file reference
    content = content.replace(
        '4644212388479F3F7BF7B7DE /* DashboardViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DashboardViewModel.swift; sourceTree = "<group>"; };',
        '4644212388479F3F7BF7B7DE /* DashboardViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DashboardViewModel.swift; sourceTree = "<group>"; };\n' + file_refs
    )
    
    # Add build file entries
    build_files = """		FEDCBA0987654321FEDCBA01 /* LineItemViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = ABCDEF0123456789ABCDEF01 /* LineItemViewModel.swift */; };
		FEDCBA0987654321FEDCBA02 /* SplitAllocationViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = ABCDEF0123456789ABCDEF02 /* SplitAllocationViewModel.swift */; };
		FEDCBA0987654321FEDCBA03 /* SettingsViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = ABCDEF0123456789ABCDEF03 /* SettingsViewModel.swift */; };
		FEDCBA0987654321FEDCBA04 /* LineItemViewModelTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = ABCDEF0123456789ABCDEF04 /* LineItemViewModelTests.swift */; };
		FEDCBA0987654321FEDCBA05 /* SplitAllocationViewModelTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = ABCDEF0123456789ABCDEF05 /* SplitAllocationViewModelTests.swift */; };
"""
    
    content = content.replace(
        '2B37EF5E2BA52029B8E507EE /* DashboardViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = 4644212388479F3F7BF7B7DE /* DashboardViewModel.swift */; };',
        '2B37EF5E2BA52029B8E507EE /* DashboardViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = 4644212388479F3F7BF7B7DE /* DashboardViewModel.swift */; };\n' + build_files
    )
    
    # Add to production ViewModels group
    content = content.replace(
        '8EED0ECEF59FFABBE1C4A0DE /* ViewModels */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t4644212388479F3F7BF7B7DE /* DashboardViewModel.swift */,',
        '8EED0ECEF59FFABBE1C4A0DE /* ViewModels */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t4644212388479F3F7BF7B7DE /* DashboardViewModel.swift */,\n\t\t\t\tABCDEF0123456789ABCDEF01 /* LineItemViewModel.swift */,\n\t\t\t\tABCDEF0123456789ABCDEF02 /* SplitAllocationViewModel.swift */,\n\t\t\t\tABCDEF0123456789ABCDEF03 /* SettingsViewModel.swift */,'
    )
    
    # Add to test ViewModels group
    content = content.replace(
        '2973720C2939DD407F7C44AB /* ViewModels */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\tB34A9211E42A352FF0EE7BB3 /* DashboardViewModelTests.swift */,',
        '2973720C2939DD407F7C44AB /* ViewModels */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\tB34A9211E42A352FF0EE7BB3 /* DashboardViewModelTests.swift */,\n\t\t\t\tABCDEF0123456789ABCDEF04 /* LineItemViewModelTests.swift */,\n\t\t\t\tABCDEF0123456789ABCDEF05 /* SplitAllocationViewModelTests.swift */,'
    )
    
    # Add to build phases
    content = content.replace(
        '2B37EF5E2BA52029B8E507EE /* DashboardViewModel.swift in Sources */,',
        '2B37EF5E2BA52029B8E507EE /* DashboardViewModel.swift in Sources */,\n\t\t\t\tFEDCBA0987654321FEDCBA01 /* LineItemViewModel.swift in Sources */,\n\t\t\t\tFEDCBA0987654321FEDCBA02 /* SplitAllocationViewModel.swift in Sources */,\n\t\t\t\tFEDCBA0987654321FEDCBA03 /* SettingsViewModel.swift in Sources */,'
    )
    
    content = content.replace(
        'AFDEE79B69BB56B3AF284F3D /* DashboardViewModelTests.swift in Sources */,',
        'AFDEE79B69BB56B3AF284F3D /* DashboardViewModelTests.swift in Sources */,\n\t\t\t\tFEDCBA0987654321FEDCBA04 /* LineItemViewModelTests.swift in Sources */,\n\t\t\t\tFEDCBA0987654321FEDCBA05 /* SplitAllocationViewModelTests.swift in Sources */,'
    )
    
    # Write back
    with open(project_path, 'w') as f:
        f.write(content)
    
    print("✅ Successfully patched Xcode project file!")
    print("   - Added LineItemViewModel.swift")
    print("   - Added SplitAllocationViewModel.swift")
    print("   - Added SettingsViewModel.swift")
    print("   - Added test files")
    print("   - Updated all necessary sections")

if __name__ == "__main__":
    patch_project()