#!/usr/bin/env python3
"""
Patch Xcode project file to add View files
"""

import re

def patch_views():
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"
    
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Check if already patched
    if 'LineItemEntryView.swift' in content and 'SplitAllocationView.swift' in content:
        print("✅ Project already contains View files!")
        return
    
    # Add file references for Views
    view_refs = """		VIEWREF0123456789VIEWREF01 /* LineItemEntryView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LineItemEntryView.swift; sourceTree = "<group>"; };
		VIEWREF0123456789VIEWREF02 /* SplitAllocationView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationView.swift; sourceTree = "<group>"; };
"""
    
    # Insert after an existing view file reference
    content = content.replace(
        '88211B32F54FEC04C1A3EE94 /* DashboardView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DashboardView.swift; sourceTree = "<group>"; };',
        '88211B32F54FEC04C1A3EE94 /* DashboardView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DashboardView.swift; sourceTree = "<group>"; };\n' + view_refs
    )
    
    # Add build file entries
    build_files = """		VIEWBUILD987654321BUILD01 /* LineItemEntryView.swift in Sources */ = {isa = PBXBuildFile; fileRef = VIEWREF0123456789VIEWREF01 /* LineItemEntryView.swift */; };
		VIEWBUILD987654321BUILD02 /* SplitAllocationView.swift in Sources */ = {isa = PBXBuildFile; fileRef = VIEWREF0123456789VIEWREF02 /* SplitAllocationView.swift */; };
"""
    
    # Add after existing view build files
    content = content.replace(
        'A66AE32C45175DC5CD75106C /* DashboardView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 88211B32F54FEC04C1A3EE94 /* DashboardView.swift */; };',
        'A66AE32C45175DC5CD75106C /* DashboardView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 88211B32F54FEC04C1A3EE94 /* DashboardView.swift */; };\n' + build_files
    )
    
    # Add to production Views group - find the Views group that contains DashboardView.swift
    # Need to search for Views group pattern
    views_group_pattern = r'(\w+ /\* Views \*/ = {\s+isa = PBXGroup;\s+children = \(\s+[^)]*88211B32F54FEC04C1A3EE94 /\* DashboardView\.swift \*/,)'
    
    def add_to_views_group(match):
        return match.group(1) + '\n\t\t\t\tVIEWREF0123456789VIEWREF01 /* LineItemEntryView.swift */,\n\t\t\t\tVIEWREF0123456789VIEWREF02 /* SplitAllocationView.swift */,'
    
    content = re.sub(views_group_pattern, add_to_views_group, content, flags=re.MULTILINE | re.DOTALL)
    
    # Add to build phases
    # Find the Sources build phase section and add our files
    sources_pattern = r'(A66AE32C45175DC5CD75106C /\* DashboardView\.swift in Sources \*/,)'
    
    def add_to_sources(match):
        return match.group(1) + '\n\t\t\t\tVIEWBUILD987654321BUILD01 /* LineItemEntryView.swift in Sources */,\n\t\t\t\tVIEWBUILD987654321BUILD02 /* SplitAllocationView.swift in Sources */,'
    
    content = re.sub(sources_pattern, add_to_sources, content)
    
    # Also need to update Transaction entity for createdAt property
    # This is a temporary fix - should be done properly through Core Data model
    print("\n⚠️  Note: Transaction.createdAt property needs to be added to Core Data model")
    
    # Write back
    with open(project_path, 'w') as f:
        f.write(content)
    
    print("✅ Successfully patched Xcode project file with View files!")
    print("   - Added LineItemEntryView.swift")
    print("   - Added SplitAllocationView.swift")
    print("   - Updated Views group and build phases")

if __name__ == "__main__":
    patch_views()