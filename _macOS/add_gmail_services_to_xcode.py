#!/usr/bin/env python3
"""
Script to add Gmail service files to Xcode project for compilation.

This script will:
1. Add EmailConnectorService.swift to the Xcode project
2. Add GmailAPIService.swift to the Xcode project  
3. Add EmailOAuthManager.swift to the Xcode project
4. Add ProductionAPIConfig.swift to the Xcode project
5. Update ContentView.swift to use real EmailConnectorService instead of demo data
"""

import sys
import os
import re
import uuid
from pathlib import Path

def generate_uuid():
    """Generate a unique ID for Xcode project entries"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def read_project_file(project_path):
    """Read the Xcode project.pbxproj file"""
    try:
        with open(project_path, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error reading project file: {e}")
        return None

def write_project_file(project_path, content):
    """Write the updated project.pbxproj file"""
    try:
        with open(project_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    except Exception as e:
        print(f"Error writing project file: {e}")
        return False

def add_file_to_build_phase(content, file_id):
    """Add file to the compile sources build phase"""
    # Find the compile sources build phase
    compile_pattern = r'(\/\* Sources \*\/ = \{[^}]*files = \(\s*)((?:[^)]*\n)*)'
    
    match = re.search(compile_pattern, content, re.MULTILINE | re.DOTALL)
    if match:
        before = match.group(1)
        existing_files = match.group(2)
        after = content[match.end():]
        
        # Add the new file reference
        new_file_entry = f"\t\t\t\t{file_id} /* EmailConnectorService.swift in Sources */,\n"
        
        # Check if file is already present
        if file_id not in existing_files:
            updated_content = before + existing_files + new_file_entry + after
            return updated_content
    
    return content

def add_gmail_service_files(project_path):
    """Add Gmail service files to Xcode project"""
    
    # Read current project file
    content = read_project_file(project_path)
    if not content:
        return False
    
    print("Adding Gmail service files to Xcode project...")
    
    # Generate unique IDs for each file
    email_connector_file_id = generate_uuid()
    email_connector_build_id = generate_uuid()
    gmail_api_file_id = generate_uuid()
    gmail_api_build_id = generate_uuid()
    oauth_manager_file_id = generate_uuid()
    oauth_manager_build_id = generate_uuid()
    api_config_file_id = generate_uuid()
    api_config_build_id = generate_uuid()
    
    # File paths relative to project
    email_connector_path = "FinanceMate/Services/EmailConnectorService.swift"
    gmail_api_path = "FinanceMate/Services/GmailAPIService.swift"
    oauth_manager_path = "FinanceMate/Services/EmailOAuthManager.swift"
    api_config_path = "FinanceMate/Services/ProductionAPIConfig.swift"
    
    # Add file references section
    file_references = f"""
		{email_connector_file_id} /* EmailConnectorService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EmailConnectorService.swift; sourceTree = "<group>"; }};
		{gmail_api_file_id} /* GmailAPIService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GmailAPIService.swift; sourceTree = "<group>"; }};
		{oauth_manager_file_id} /* EmailOAuthManager.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EmailOAuthManager.swift; sourceTree = "<group>"; }};
		{api_config_file_id} /* ProductionAPIConfig.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProductionAPIConfig.swift; sourceTree = "<group>"; }};
"""
    
    # Find the end of the file references section and insert
    file_ref_pattern = r'(\/\* End PBXFileReference section \*\/)'
    content = re.sub(file_ref_pattern, file_references + r'\1', content)
    
    # Add build file entries
    build_files = f"""
		{email_connector_build_id} /* EmailConnectorService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {email_connector_file_id} /* EmailConnectorService.swift */; }};
		{gmail_api_build_id} /* GmailAPIService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {gmail_api_file_id} /* GmailAPIService.swift */; }};
		{oauth_manager_build_id} /* EmailOAuthManager.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {oauth_manager_file_id} /* EmailOAuthManager.swift */; }};
		{api_config_build_id} /* ProductionAPIConfig.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {api_config_file_id} /* ProductionAPIConfig.swift */; }};
"""
    
    # Add to build files section
    build_file_pattern = r'(\/\* End PBXBuildFile section \*\/)'
    content = re.sub(build_file_pattern, build_files + r'\1', content)
    
    # Add files to Services group
    services_group_pattern = r'(\/\* Services \*\/ = \{[^}]*children = \(\s*)((?:[^)]*\n)*?)(\s*\);)'
    
    services_files = f"""				{email_connector_file_id} /* EmailConnectorService.swift */,
				{gmail_api_file_id} /* GmailAPIService.swift */,
				{oauth_manager_file_id} /* EmailOAuthManager.swift */,
				{api_config_file_id} /* ProductionAPIConfig.swift */,
"""
    
    def add_to_services_group(match):
        before = match.group(1)
        existing_files = match.group(2)
        after = match.group(3)
        
        # Check if files are already present
        if email_connector_file_id not in existing_files:
            return before + existing_files + services_files + after
        return match.group(0)
    
    content = re.sub(services_group_pattern, add_to_services_group, content, flags=re.MULTILINE | re.DOTALL)
    
    # Add to compile sources build phase
    compile_pattern = r'(\/\* Sources \*\/ = \{[^}]*files = \(\s*)((?:[^)]*\n)*?)(\s*\);)'
    
    compile_sources = f"""				{email_connector_build_id} /* EmailConnectorService.swift in Sources */,
				{gmail_api_build_id} /* GmailAPIService.swift in Sources */,
				{oauth_manager_build_id} /* EmailOAuthManager.swift in Sources */,
				{api_config_build_id} /* ProductionAPIConfig.swift in Sources */,
"""
    
    def add_to_compile_sources(match):
        before = match.group(1)
        existing_files = match.group(2)
        after = match.group(3)
        
        # Check if files are already present
        if email_connector_build_id not in existing_files:
            return before + existing_files + compile_sources + after
        return match.group(0)
    
    content = re.sub(compile_pattern, add_to_compile_sources, content, flags=re.MULTILINE | re.DOTALL)
    
    # Write updated project file
    if write_project_file(project_path, content):
        print("✅ Successfully added Gmail service files to Xcode project")
        print(f"   - EmailConnectorService.swift (ID: {email_connector_file_id})")
        print(f"   - GmailAPIService.swift (ID: {gmail_api_file_id})")
        print(f"   - EmailOAuthManager.swift (ID: {oauth_manager_file_id})")
        print(f"   - ProductionAPIConfig.swift (ID: {api_config_file_id})")
        return True
    else:
        print("❌ Failed to write updated project file")
        return False

def update_content_view():
    """Update ContentView.swift to use real EmailConnectorService"""
    
    content_view_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/ContentView.swift"
    
    try:
        with open(content_view_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ Error reading ContentView.swift: {e}")
        return False
    
    print("Updating ContentView.swift to use real EmailConnectorService...")
    
    # Replace demo GmailExpenseItem structure with real service integration
    # Find the GmailReceiptView and update it
    
    updated_content = content.replace(
        "    @State private var gmailExpenses: [GmailExpenseItem] = []",
        "    @StateObject private var emailConnector = EmailConnectorService()"
    )
    
    # Update the expense loading to use real service
    updated_content = updated_content.replace(
        "        gmailExpenses = createDemoGmailExpenses()",
        "        // Real service integration - expenses loaded from emailConnector"
    )
    
    # Update processing function to use real service
    process_function_replacement = '''    private func processGmailReceipts() {
        guard !isProcessing else { return }
        
        isProcessing = true
        processingStatus = "Connecting to Gmail API..."
        
        Task {
            do {
                await emailConnector.processEmails()
                
                DispatchQueue.main.async {
                    // Update UI with real Gmail data
                    self.isProcessing = false
                    self.processingStatus = "Processing complete"
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.processingStatus = "Error: \\(error.localizedDescription)"
                }
            }
        }
    }'''
    
    # Replace the demo processing function
    demo_function_pattern = r'    private func processGmailReceipts\(\) \{[^}]+\}(?:\s*\}){3}'
    updated_content = re.sub(demo_function_pattern, process_function_replacement, updated_content, flags=re.MULTILINE | re.DOTALL)
    
    # Update to use real expenses from service
    updated_content = updated_content.replace(
        "if !gmailExpenses.isEmpty {",
        "if !emailConnector.expenses.isEmpty {"
    )
    
    updated_content = updated_content.replace(
        "gmailExpenses.reduce(0) { $0 + $1.amount }",
        "emailConnector.totalExpenses"
    )
    
    # Write updated ContentView
    try:
        with open(content_view_path, 'w', encoding='utf-8') as f:
            f.write(updated_content)
        print("✅ Successfully updated ContentView.swift to use real EmailConnectorService")
        return True
    except Exception as e:
        print(f"❌ Error writing updated ContentView.swift: {e}")
        return False

def main():
    """Main integration function"""
    
    project_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_path = os.path.join(project_dir, "FinanceMate.xcodeproj", "project.pbxproj")
    
    print("🚀 Starting Gmail Services Integration...")
    print(f"Project path: {project_path}")
    
    # Verify project file exists
    if not os.path.exists(project_path):
        print(f"❌ Project file not found: {project_path}")
        return False
    
    # Phase 1: Add service files to Xcode project
    print("\n📁 Phase 1: Adding Gmail service files to Xcode project")
    if not add_gmail_service_files(project_path):
        print("❌ Failed to add Gmail service files")
        return False
    
    # Phase 2: Update ContentView to use real service
    print("\n🔄 Phase 2: Updating ContentView.swift to use real EmailConnectorService")
    if not update_content_view():
        print("❌ Failed to update ContentView.swift")
        return False
    
    print("\n✅ Gmail Services Integration Complete!")
    print("\nNext steps:")
    print("1. Build the project to verify compilation")
    print("2. Configure real Gmail OAuth credentials")
    print("3. Test Gmail API integration")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)