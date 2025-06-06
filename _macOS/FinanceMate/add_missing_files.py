#!/usr/bin/env python3

import os
import uuid
import hashlib

def generate_uuid():
    """Generate a 24-character hex UUID similar to Xcode's format"""
    return uuid.uuid4().hex.upper()[:24]

def add_files_to_pbxproj():
    """Add missing files to the FinanceMate Xcode project"""
    
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate.xcodeproj/project.pbxproj"
    
    # Define the missing files we need to add
    missing_view_files = [
        "ComprehensiveChatbotTestView.swift",
        "EnhancedAnalyticsView.swift", 
        "SpeculativeDecodingControlView.swift",
        "CrashAnalysisDashboardView.swift",
        "LLMBenchmarkView.swift"
    ]
    
    missing_service_files = [
        "ComprehensiveChatbotTestingService.swift",
        "RealAPITestingService.swift",
        "APIKeysIntegrationService.swift",
        "TaskMasterAIService.swift",
        "KeychainManager.swift",
        "UserSessionManager.swift",
        "TokenManager.swift"
    ]
    
    # Read the current project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Generate UUIDs for each file
    file_refs = {}
    build_files = {}
    
    for file in missing_view_files + missing_service_files:
        file_refs[file] = generate_uuid()
        build_files[file] = generate_uuid()
    
    # Add PBXFileReference entries
    file_reference_section = ""
    for file in missing_view_files:
        file_reference_section += f'\t\t{file_refs[file]} /* {file} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file}; sourceTree = "<group>"; }};\n'
    
    for file in missing_service_files:
        file_reference_section += f'\t\t{file_refs[file]} /* {file} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file}; sourceTree = "<group>"; }};\n'
    
    # Add PBXBuildFile entries
    build_file_section = ""
    for file in missing_view_files + missing_service_files:
        build_file_section += f'\t\t{build_files[file]} /* {file} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[file]} /* {file} */; }};\n'
    
    # Add files to PBXGroup sections
    views_group_addition = ""
    for file in missing_view_files:
        views_group_addition += f'\t\t\t\t{file_refs[file]} /* {file} */,\n'
    
    services_group_addition = ""
    for file in missing_service_files:
        services_group_addition += f'\t\t\t\t{file_refs[file]} /* {file} */,\n'
    
    # Add to Sources build phase
    sources_build_phase_addition = ""
    for file in missing_view_files + missing_service_files:
        sources_build_phase_addition += f'\t\t\t\t{build_files[file]} /* {file} in Sources */,\n'
    
    # Find insertion points and add content
    
    # 1. Add to PBXBuildFile section
    build_file_insert_point = content.find("/* End PBXBuildFile section */")
    content = content[:build_file_insert_point] + build_file_section + content[build_file_insert_point:]
    
    # 2. Add to PBXFileReference section  
    file_ref_insert_point = content.find("/* End PBXFileReference section */")
    content = content[:file_ref_insert_point] + file_reference_section + content[file_ref_insert_point:]
    
    # 3. Add to Views group (find the Views PBXGroup and add files)
    views_group_start = content.find('5A3E0825B270488F84D0B970B9505899 /* Views */ = {')
    views_group_end = content.find('};', views_group_start)
    views_children_end = content.rfind(',\n', views_group_start, views_group_end)
    content = content[:views_children_end+2] + views_group_addition + content[views_children_end+2:]
    
    # 4. Add to Services group  
    services_group_start = content.find('A1B2C3D4E5F6789012345678 /* Services */ = {')
    services_group_end = content.find('};', services_group_start)
    services_children_end = content.rfind(',\n', services_group_start, services_group_end)
    content = content[:services_children_end+2] + services_group_addition + content[services_children_end+2:]
    
    # 5. Add to Sources build phase
    sources_phase_start = content.find('D2B194BACCAE2FCF7AD52E55 /* Sources */ = {')
    sources_phase_end = content.find('};', sources_phase_start)
    sources_files_end = content.rfind(',\n', sources_phase_start, sources_phase_end)
    content = content[:sources_files_end+2] + sources_build_phase_addition + content[sources_files_end+2:]
    
    # Write the updated project file
    with open(project_path, 'w') as f:
        f.write(content)
    
    print("Successfully added missing files to FinanceMate.xcodeproj")
    print(f"Added {len(missing_view_files)} view files and {len(missing_service_files)} service files")
    print("\nAdded Files:")
    print("Views:")
    for file in missing_view_files:
        print(f"  - {file}")
    print("Services:")
    for file in missing_service_files:
        print(f"  - {file}")

if __name__ == "__main__":
    add_files_to_pbxproj()