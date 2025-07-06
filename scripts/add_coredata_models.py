#!/usr/bin/env python3

import re
import uuid
import sys
import os

def generate_uuid():
    """Generate a UUID for Xcode project files"""
    return str(uuid.uuid4()).replace('-', '')[:24].upper()

def add_files_to_xcode_project():
    """Add Core Data model files to Xcode project"""
    project_file = '_macOS/FinanceMate.xcodeproj/project.pbxproj'
    
    if not os.path.exists(project_file):
        print(f"❌ Project file not found: {project_file}")
        return False
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Files to add
    files_to_add = [
        'LineItem+CoreDataClass.swift',
        'LineItem+CoreDataProperties.swift',
        'SplitAllocation+CoreDataClass.swift',
        'SplitAllocation+CoreDataProperties.swift'
    ]
    
    # Generate UUIDs for new files
    file_refs = {}
    build_files = {}
    
    for filename in files_to_add:
        file_refs[filename] = generate_uuid()
        build_files[filename] = generate_uuid()
    
    # Find the FinanceMate target
    finance_mate_target_match = re.search(r'(\w+) \/\* FinanceMate \*\/ = \{', content)
    if not finance_mate_target_match:
        print("❌ Could not find FinanceMate target")
        return False
    
    finance_mate_target_id = finance_mate_target_match.group(1)
    
    # Find Models group
    models_group_match = re.search(r'(\w+) \/\* Models \*\/ = \{', content)
    if not models_group_match:
        print("❌ Could not find Models group")
        return False
    
    models_group_id = models_group_match.group(1)
    
    # Add file references
    file_references_section = re.search(r'\/\* Begin PBXFileReference section \*\/(.*?)\/\* End PBXFileReference section \*\/', content, re.DOTALL)
    if file_references_section:
        new_file_refs = ""
        for filename in files_to_add:
            new_file_refs += f"\t\t{file_refs[filename]} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{filename}\"; sourceTree = \"<group>\"; }};\n"
        
        # Insert before the end of the section
        content = content.replace('/* End PBXFileReference section */', new_file_refs + '\t/* End PBXFileReference section */')
    
    # Add build files
    build_files_section = re.search(r'\/\* Begin PBXBuildFile section \*\/(.*?)\/\* End PBXBuildFile section \*\/', content, re.DOTALL)
    if build_files_section:
        new_build_files = ""
        for filename in files_to_add:
            new_build_files += f"\t\t{build_files[filename]} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[filename]} /* {filename} */; }};\n"
        
        # Insert before the end of the section
        content = content.replace('/* End PBXBuildFile section */', new_build_files + '\t/* End PBXBuildFile section */')
    
    # Add to Models group children
    models_group_pattern = f'{models_group_id} \/\* Models \*\/ = {{[^}}]*children = \\([^)]*\\);'
    models_group_match = re.search(models_group_pattern, content, re.DOTALL)
    
    if models_group_match:
        # Find the children array and add our files
        children_pattern = f'({models_group_id} \/\* Models \*\/ = {{[^}}]*children = \\()([^)]*)(\\);)'
        
        def add_children(match):
            prefix = match.group(1)
            existing_children = match.group(2)
            suffix = match.group(3)
            
            new_children = existing_children
            for filename in files_to_add:
                new_children += f"\n\t\t\t\t{file_refs[filename]} /* {filename} */,"
            
            return prefix + new_children + suffix
        
        content = re.sub(children_pattern, add_children, content, flags=re.DOTALL)
    
    # Add to FinanceMate target sources
    target_sources_pattern = f'({finance_mate_target_id} \/\* FinanceMate \*\/ = {{[^}}]*buildPhases = \\([^)]*)(\\w+) \/\* Sources \*\/,([^)]*\\);)'
    target_match = re.search(target_sources_pattern, content, re.DOTALL)
    
    if target_match:
        sources_phase_id = target_match.group(2)
        
        # Find the Sources build phase and add our files
        sources_pattern = f'({sources_phase_id} \/\* Sources \*\/ = {{[^}}]*files = \\()([^)]*)(\\);)'
        
        def add_sources(match):
            prefix = match.group(1)
            existing_files = match.group(2)
            suffix = match.group(3)
            
            new_files = existing_files
            for filename in files_to_add:
                new_files += f"\n\t\t\t\t{build_files[filename]} /* {filename} in Sources */,"
            
            return prefix + new_files + suffix
        
        content = re.sub(sources_pattern, add_sources, content, flags=re.DOTALL)
    
    # Write the modified project file
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added Core Data model files to Xcode project")
    for filename in files_to_add:
        print(f"   • {filename}")
    
    return True

if __name__ == "__main__":
    if add_files_to_xcode_project():
        print("\n🎯 Core Data model integration complete!")
        print("📝 Next steps:")
        print("   1. Test production build")
        print("   2. Run comprehensive test suite")
        print("   3. Verify app launches without Core Data crashes")
    else:
        print("\n❌ Failed to add Core Data model files")
        sys.exit(1)