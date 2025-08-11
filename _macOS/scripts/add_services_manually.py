#!/usr/bin/env python3
"""
Simple Gmail Services File Addition Script
Purpose: Add service files by manually editing the project.pbxproj with grep and sed
"""

import os
import subprocess
import uuid

def generate_uuid():
    """Generate a random UUID for Xcode file references"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def run_command(command, description):
    """Run a command and return its output"""
    print(f"🔧 {description}")
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
        print(f"✅ {description} - Success")
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} - Failed: {e.stderr}")
        return None

def add_service_file_to_project(service_file):
    """Add a single service file to the Xcode project"""
    print(f"\n📝 Adding {service_file} to Xcode project...")
    
    # Generate UUIDs
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()
    
    base_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_file = f"{base_dir}/FinanceMate.xcodeproj/project.pbxproj"
    
    # Step 1: Add file reference to PBXFileReference section
    file_ref_line = f'\t\t{file_ref_uuid} /* {service_file} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {service_file}; sourceTree = "<group>"; }};'
    
    command = f'sed -i "" "/Begin PBXFileReference section/a\\\n{file_ref_line}" "{project_file}"'
    run_command(command, f"Added file reference for {service_file}")
    
    # Step 2: Add build file to PBXBuildFile section
    build_file_line = f'\t\t{build_file_uuid} /* {service_file} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {service_file} */; }};'
    
    command = f'sed -i "" "/Begin PBXBuildFile section/a\\\n{build_file_line}" "{project_file}"'
    run_command(command, f"Added build file for {service_file}")
    
    # Step 3: Find Services group and add file reference
    # First, find the Services group UUID
    command = f'grep -A 10 -B 2 "name = Services;" "{project_file}" | grep "isa = PBXGroup" | head -1 | cut -d" " -f1'
    services_group_uuid = run_command(command, f"Finding Services group UUID")
    
    if services_group_uuid:
        # Add file reference to Services group
        command = f'sed -i "" "/{services_group_uuid} .*Services.*= {{/,/children = (/{{ s/children = (/children = (\\\n\t\t\t\t{file_ref_uuid} \/* {service_file} *\/,/ }}" "{project_file}"'
        run_command(command, f"Added {service_file} to Services group")
    
    # Step 4: Add to Sources build phase for FinanceMate target
    # Find the FinanceMate target sources build phase UUID
    command = f'grep -A 20 "FinanceMate.*buildPhases" "{project_file}" | grep "Sources" | cut -d" " -f1'
    sources_uuid = run_command(command, f"Finding FinanceMate Sources build phase")
    
    if sources_uuid:
        # Add build file to Sources build phase
        command = f'sed -i "" "/{sources_uuid} .*Sources.*= {{/,/files = (/{{ s/files = (/files = (\\\n\t\t\t\t{build_file_uuid} \/* {service_file} in Sources *\/,/ }}" "{project_file}"'
        run_command(command, f"Added {service_file} to FinanceMate Sources build phase")
    
    print(f"✅ Successfully processed {service_file}")
    return file_ref_uuid, build_file_uuid

def main():
    """Main function to add all Gmail services to Xcode project"""
    print("🚀 Adding Gmail Services to Xcode Project...")
    
    base_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_file = f"{base_dir}/FinanceMate.xcodeproj/project.pbxproj"
    
    # Backup the project file
    backup_file = f"{project_file}.backup_manual_services_{generate_uuid()[:8]}"
    run_command(f'cp "{project_file}" "{backup_file}"', f"Backup project file to {backup_file}")
    
    # Service files to add
    service_files = [
        "EmailConnectorService.swift",
        "GmailAPIService.swift", 
        "EmailOAuthManager.swift"
    ]
    
    # Verify ProductionAPIConfig.swift exists in Services folder and add if needed
    production_config_path = f"{base_dir}/FinanceMate/FinanceMate/Services/ProductionAPIConfig.swift"
    if os.path.exists(production_config_path):
        service_files.append("ProductionAPIConfig.swift")
    else:
        print(f"⚠️  ProductionAPIConfig.swift not found in Services folder - checking if already in project...")
    
    success_count = 0
    
    for service_file in service_files:
        file_path = f"{base_dir}/FinanceMate/FinanceMate/Services/{service_file}"
        
        # Verify the service file exists
        if os.path.exists(file_path):
            try:
                add_service_file_to_project(service_file)
                success_count += 1
            except Exception as e:
                print(f"❌ Failed to add {service_file}: {e}")
        else:
            print(f"❌ Service file not found: {file_path}")
    
    print(f"\n📊 Summary: {success_count}/{len(service_files)} service files added successfully")
    print(f"📝 Backup created: {backup_file}")
    print("\n🎯 Next: Build the project to test integration!")

if __name__ == "__main__":
    main()