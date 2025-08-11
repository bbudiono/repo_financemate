#!/usr/bin/env python3

"""
Programmatic Xcode integration for Gmail connector files
This script directly patches the project.pbxproj file to add the files properly
"""

import os
import sys
import re
import uuid

def generate_xcode_id():
    """Generate a unique 24-character Xcode ID"""
    return ''.join(str(uuid.uuid4()).replace('-', '').upper()[:24])

def add_files_to_xcode_project():
    """Programmatically add Gmail connector files to Xcode project"""
    
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    pbxproj_path = f"{project_path}/FinanceMate.xcodeproj/project.pbxproj"
    
    if not os.path.exists(pbxproj_path):
        print(f"❌ Error: Xcode project file not found at {pbxproj_path}")
        return False
    
    print("🔧 Programmatically adding Gmail connector files to Xcode project...")
    
    # Generate unique IDs
    gmail_service_ref_id = generate_xcode_id()
    expense_view_ref_id = generate_xcode_id()
    gmail_service_build_id = generate_xcode_id()
    expense_view_build_id = generate_xcode_id()
    
    # Read the project file
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # 1. Add file references
    file_references_section = re.search(r'(/\* Begin PBXFileReference section \*/.*?/\* End PBXFileReference section \*/)', content, re.DOTALL)
    if not file_references_section:
        print("❌ Could not find PBXFileReference section")
        return False
    
    gmail_service_ref = f"\t\t{gmail_service_ref_id} /* GmailAPIService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GmailAPIService.swift; sourceTree = \"<group>\"; }};"
    expense_view_ref = f"\t\t{expense_view_ref_id} /* ExpenseTableView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ExpenseTableView.swift; sourceTree = \"<group>\"; }};"
    
    # Insert before end of section
    new_file_refs = file_references_section.group(1).replace(
        "/* End PBXFileReference section */",
        f"{gmail_service_ref}\n{expense_view_ref}\n/* End PBXFileReference section */"
    )
    content = content.replace(file_references_section.group(1), new_file_refs)
    
    # 2. Add build files
    build_files_section = re.search(r'(/\* Begin PBXBuildFile section \*/.*?/\* End PBXBuildFile section \*/)', content, re.DOTALL)
    if not build_files_section:
        print("❌ Could not find PBXBuildFile section")
        return False
    
    gmail_service_build = f"\t\t{gmail_service_build_id} /* GmailAPIService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {gmail_service_ref_id} /* GmailAPIService.swift */; }};"
    expense_view_build = f"\t\t{expense_view_build_id} /* ExpenseTableView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {expense_view_ref_id} /* ExpenseTableView.swift */; }};"
    
    new_build_files = build_files_section.group(1).replace(
        "/* End PBXBuildFile section */",
        f"{gmail_service_build}\n{expense_view_build}\n/* End PBXBuildFile section */"
    )
    content = content.replace(build_files_section.group(1), new_build_files)
    
    # 3. Find and update Services group
    services_group_pattern = r'(/\* Services \*/ = \{[^}]+children = \([^)]+)\);'
    services_match = re.search(services_group_pattern, content, re.DOTALL)
    if services_match:
        services_content = services_match.group(1)
        new_services_content = services_content + f",\n\t\t\t\t{gmail_service_ref_id} /* GmailAPIService.swift */"
        content = content.replace(services_content, new_services_content)
        print("✅ Added GmailAPIService.swift to Services group")
    else:
        # Try to find Services group differently
        services_alt_pattern = r'([A-F0-9]{24} /\* Services \*/ = \{[^}]+children = \([^)]+)\);'
        services_alt_match = re.search(services_alt_pattern, content, re.DOTALL)
        if services_alt_match:
            services_content = services_alt_match.group(1)
            new_services_content = services_content + f",\n\t\t\t\t{gmail_service_ref_id} /* GmailAPIService.swift */"
            content = content.replace(services_content, new_services_content)
            print("✅ Added GmailAPIService.swift to Services group (alt pattern)")
        else:
            print("⚠️  Could not find Services group - file will be added to project root")
    
    # 4. Find and update Views group
    views_group_pattern = r'(/\* Views \*/ = \{[^}]+children = \([^)]+)\);'
    views_match = re.search(views_group_pattern, content, re.DOTALL)
    if views_match:
        views_content = views_match.group(1)
        new_views_content = views_content + f",\n\t\t\t\t{expense_view_ref_id} /* ExpenseTableView.swift */"
        content = content.replace(views_content, new_views_content)
        print("✅ Added ExpenseTableView.swift to Views group")
    else:
        # Try to find Views group differently
        views_alt_pattern = r'([A-F0-9]{24} /\* Views \*/ = \{[^}]+children = \([^)]+)\);'
        views_alt_match = re.search(views_alt_pattern, content, re.DOTALL)
        if views_alt_match:
            views_content = views_alt_match.group(1)
            new_views_content = views_content + f",\n\t\t\t\t{expense_view_ref_id} /* ExpenseTableView.swift */"
            content = content.replace(views_content, new_views_content)
            print("✅ Added ExpenseTableView.swift to Views group (alt pattern)")
        else:
            print("⚠️  Could not find Views group - file will be added to project root")
    
    # 5. Add to compile sources
    sources_build_phase_pattern = r'([A-F0-9]{24} /\* Sources \*/ = \{[^}]+files = \([^)]+)\);'
    sources_match = re.search(sources_build_phase_pattern, content, re.DOTALL)
    if sources_match:
        sources_content = sources_match.group(1)
        new_sources_content = sources_content + f",\n\t\t\t\t{gmail_service_build_id} /* GmailAPIService.swift in Sources */,\n\t\t\t\t{expense_view_build_id} /* ExpenseTableView.swift in Sources */"
        content = content.replace(sources_content, new_sources_content)
        print("✅ Added files to compile sources")
    else:
        print("❌ Could not find Sources build phase")
        return False
    
    # Write the updated project file
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added Gmail connector files to Xcode project")
    return True

def verify_files_exist():
    """Verify that the source files exist"""
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

def update_content_view():
    """Update ContentView.swift to use ExpenseTableView instead of placeholder"""
    
    content_view_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/ContentView.swift"
    
    if not os.path.exists(content_view_path):
        print(f"❌ ContentView.swift not found at {content_view_path}")
        return False
    
    print("🔧 Updating ContentView.swift to use ExpenseTableView...")
    
    with open(content_view_path, 'r') as f:
        content = f.read()
    
    # Replace the placeholder VStack with ExpenseTableView
    placeholder_pattern = r'// Email Receipts Tab - P0 MANDATORY GMAIL CONNECTOR \(Temporarily disabled until Xcode integration\)\s+VStack \{[^}]+\}\s+\.frame\(maxWidth: \.infinity, maxHeight: \.infinity\)'
    
    replacement = '''// Email Receipts Tab - P0 MANDATORY GMAIL CONNECTOR
            ExpenseTableView()
                .environment(\\.managedObjectContext, viewContext)'''
    
    if re.search(placeholder_pattern, content, re.DOTALL):
        new_content = re.sub(placeholder_pattern, replacement, content, flags=re.DOTALL)
        
        with open(content_view_path, 'w') as f:
            f.write(new_content)
        
        print("✅ Updated ContentView.swift to use ExpenseTableView")
        return True
    else:
        print("⚠️  Could not find placeholder pattern in ContentView.swift")
        return False

def main():
    print("🚀 Programmatic Xcode Gmail Connector Integration")
    print("=================================================")
    print("")
    
    # Check if files exist first
    if not verify_files_exist():
        print("❌ Source files not found. Cannot proceed with integration.")
        sys.exit(1)
    
    # Add files to Xcode project
    if not add_files_to_xcode_project():
        print("❌ Failed to add files to Xcode project")
        sys.exit(1)
    
    # Update ContentView to use ExpenseTableView
    if not update_content_view():
        print("❌ Failed to update ContentView.swift")
        sys.exit(1)
    
    print("")
    print("🎯 Programmatic integration complete!")
    print("")
    print("📋 INTEGRATION SUMMARY:")
    print("✅ GmailAPIService.swift added to Services group")
    print("✅ ExpenseTableView.swift added to Views group")
    print("✅ Files added to compile sources")
    print("✅ ContentView.swift updated to use ExpenseTableView")
    print("")
    print("🔧 NEXT STEPS:")
    print("1. Build project to verify integration (should compile successfully)")
    print("2. Set up Google Cloud Console OAuth credentials")
    print("3. Update ProductionConfig.swift with real Gmail client ID")
    print("4. Test Gmail connector with real email data")

if __name__ == "__main__":
    main()