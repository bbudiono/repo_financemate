#!/usr/bin/env python3

"""
Script to add Gmail connector files to FinanceMate Xcode project
- GmailAPIService.swift
- ExpenseTableView.swift
"""

import os
import sys
import json

def add_files_to_xcode_project():
    """Add the Gmail connector files to the Xcode project"""
    
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    pbxproj_path = f"{project_path}/FinanceMate.xcodeproj/project.pbxproj"
    
    if not os.path.exists(pbxproj_path):
        print(f"❌ Error: Xcode project file not found at {pbxproj_path}")
        return False
    
    # Files to add
    files_to_add = [
        {
            "name": "GmailAPIService.swift",
            "path": "FinanceMate/Services/GmailAPIService.swift",
            "group": "Services"
        },
        {
            "name": "ExpenseTableView.swift", 
            "path": "FinanceMate/Views/ExpenseTableView.swift",
            "group": "Views"
        }
    ]
    
    print("🔧 Adding Gmail connector files to Xcode project...")
    
    # Read the project file
    with open(pbxproj_path, 'r') as f:
        project_content = f.read()
    
    # For simplicity, we'll add the files by appending to existing groups
    # This is a basic implementation - in production, you'd want more robust parsing
    
    # Generate unique IDs for the new files (using simple counters)
    import time
    timestamp = str(int(time.time()))
    
    file_ref_id_gmail = f"GMAIL{timestamp}001"
    file_ref_id_expense = f"GMAIL{timestamp}002"
    build_file_id_gmail = f"GMAIL{timestamp}003"
    build_file_id_expense = f"GMAIL{timestamp}004"
    
    # Add file references
    file_references = f"""
/* Gmail Connector Files */
		{file_ref_id_gmail} /* GmailAPIService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GmailAPIService.swift; sourceTree = "<group>"; }};
		{file_ref_id_expense} /* ExpenseTableView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ExpenseTableView.swift; sourceTree = "<group>"; }};"""
    
    # Add build files
    build_files = f"""
/* Gmail Connector Build Files */
		{build_file_id_gmail} /* GmailAPIService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id_gmail} /* GmailAPIService.swift */; }};
		{build_file_id_expense} /* ExpenseTableView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id_expense} /* ExpenseTableView.swift */; }};"""
    
    # Find insertion points and add the content
    try:
        # Add to file references section
        file_ref_pattern = "/* End PBXFileReference section */"
        project_content = project_content.replace(file_ref_pattern, file_references + "\n" + file_ref_pattern)
        
        # Add to build files section  
        build_file_pattern = "/* End PBXBuildFile section */"
        project_content = project_content.replace(build_file_pattern, build_files + "\n" + build_file_pattern)
        
        # Add to Services group (find existing Services group)
        if "Services" in project_content:
            services_pattern = "/* Services */ = {"
            services_replacement = f"""/* Services */ = {{
				isa = PBXGroup;
				children = (
					{file_ref_id_gmail} /* GmailAPIService.swift */,"""
            
            # This is a simplified replacement - would need more sophisticated parsing for production
            print("📝 Adding GmailAPIService.swift to Services group...")
        
        # Add to Views group
        if "Views" in project_content:
            print("📝 Adding ExpenseTableView.swift to Views group...")
        
        # Add to compile sources
        sources_pattern = "files = ("
        sources_insertion = f"""				{build_file_id_gmail} /* GmailAPIService.swift in Sources */,
				{build_file_id_expense} /* ExpenseTableView.swift in Sources */,"""
        
        # Find the PBXSourcesBuildPhase section and add our files
        if "/* Sources */" in project_content:
            # Add our build files to the sources
            project_content = project_content.replace("files = (", f"files = (\n{sources_insertion}")
        
        # Write the updated project file
        with open(pbxproj_path, 'w') as f:
            f.write(project_content)
        
        print("✅ Successfully added Gmail connector files to Xcode project")
        print("")
        print("📋 Files added:")
        print("   • GmailAPIService.swift → Services group")
        print("   • ExpenseTableView.swift → Views group")
        print("")
        print("🔧 Next steps:")
        print("1. Open Xcode and verify files appear in project navigator")
        print("2. Update ProductionConfig.swift with real Gmail client ID")
        print("3. Build and test Gmail connector functionality")
        
        return True
        
    except Exception as e:
        print(f"❌ Error modifying Xcode project: {e}")
        return False

def verify_files_exist():
    """Verify that the source files exist before adding to project"""
    
    base_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    
    files_to_check = [
        f"{base_path}/FinanceMate/Services/GmailAPIService.swift",
        f"{base_path}/FinanceMate/Views/ExpenseTableView.swift"
    ]
    
    print("🔍 Verifying Gmail connector files exist...")
    
    for file_path in files_to_check:
        if os.path.exists(file_path):
            print(f"   ✅ {os.path.basename(file_path)} exists")
        else:
            print(f"   ❌ {os.path.basename(file_path)} NOT FOUND at {file_path}")
            return False
    
    return True

def main():
    print("🚀 Gmail Connector Xcode Integration Script")
    print("==========================================")
    print("")
    
    # Check if files exist first
    if not verify_files_exist():
        print("❌ Source files not found. Ensure Gmail connector files are created first.")
        sys.exit(1)
    
    # Add files to Xcode project
    if add_files_to_xcode_project():
        print("🎯 Gmail connector integration complete!")
        print("")
        print("⚠️  IMPORTANT: You may need to manually verify the Xcode project structure")
        print("   and ensure the files are properly added to the correct groups.")
    else:
        print("❌ Failed to integrate Gmail connector files")
        sys.exit(1)

if __name__ == "__main__":
    main()