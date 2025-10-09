#!/usr/bin/env python3
"""
Add missing SplitAllocation files to Xcode project
"""

import re
import uuid

def generate_file_ids():
    """Generate UUIDs for files"""
    split_allocation_ref = str(uuid.uuid4()).replace('-', '')[:24].upper()
    split_allocation_build = str(uuid.uuid4()).replace('-', '')[:24].upper()
    split_allocation_vm_ref = str(uuid.uuid4()).replace('-', '')[:24].upper()
    split_allocation_vm_build = str(uuid.uuid4()).replace('-', '')[:24].upper()
    return split_allocation_ref, split_allocation_build, split_allocation_vm_ref, split_allocation_vm_build

def create_file_references(split_allocation_ref, split_allocation_vm_ref):
    """Create file reference strings"""
    file_refs = f"\t\t{split_allocation_ref} /* SplitAllocation.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"FinanceMate/SplitAllocation.swift\"; sourceTree = \"<group>\"; }};\n\t\t{split_allocation_vm_ref} /* SplitAllocationViewModel.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"FinanceMate/ViewModels/SplitAllocationViewModel.swift\"; sourceTree = \"<group>\"; }};\n"
    return file_refs

def create_build_references(split_allocation_build, split_allocation_vm_build, split_allocation_ref, split_allocation_vm_ref):
    """Create build file reference strings"""
    build_files = f"\t\t{split_allocation_build} /* SplitAllocation.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {split_allocation_ref} /* SplitAllocation.swift */; }};\n\t\t{split_allocation_vm_build} /* SplitAllocationViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {split_allocation_vm_ref} /* SplitAllocationViewModel.swift */; }};\n"
    return build_files

def update_sources_section(content, split_allocation_build, split_allocation_vm_build):
    """Update Sources section with new files"""
    sources_pattern = r'(/\\* Sources \\*/ = \\{[^}]+files = \\([^)]+)\\);'
    sources_match = re.search(sources_pattern, content, re.DOTALL)

    if sources_match:
        sources_content = sources_match.group(1)
        new_sources = sources_content + f'\\n\\t\\t\\t\\t{split_allocation_build} /* SplitAllocation.swift in Sources */,\\n\\t\\t\\t\\t{split_allocation_vm_build} /* SplitAllocationViewModel.swift in Sources */,'
        content = content.replace(sources_content, new_sources)
    return content

def update_group_section(content, split_allocation_ref, split_allocation_vm_ref):
    """Update FinanceMate group with new files"""
    group_pattern = r'(/\* FinanceMate \\*/ = \\{[^}]+children = \\([^)]+)\\);'
    group_match = re.search(group_pattern, content, re.DOTALL)

    if group_match:
        group_content = group_match.group(1)
        new_group = group_content + f'\\n\\t\\t\\t\\t{split_allocation_ref} /* SplitAllocation.swift */,\\n\\t\\t\\t\\t{split_allocation_vm_ref} /* SplitAllocationViewModel.swift */,'
        content = content.replace(group_content, new_group)
    return content

def add_split_allocation_files():
    """Add SplitAllocation.swift and SplitAllocationViewModel.swift to project"""
    project_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    with open(project_file, 'r') as f:
        content = f.read()

    # Generate IDs
    split_allocation_ref, split_allocation_build, split_allocation_vm_ref, split_allocation_vm_build = generate_file_ids()

    # Create references
    file_refs = create_file_references(split_allocation_ref, split_allocation_vm_ref)
    build_files = create_build_references(split_allocation_build, split_allocation_vm_build, split_allocation_ref, split_allocation_vm_ref)

    # Apply changes
    content = content.replace('/* End PBXFileReference section */', file_refs + '/* End PBXFileReference section */')
    content = content.replace('/* End PBXBuildFile section */', build_files + '/* End PBXBuildFile section */')
    content = update_sources_section(content, split_allocation_build, split_allocation_vm_build)
    content = update_group_section(content, split_allocation_ref, split_allocation_vm_ref)

    with open(project_file, 'w') as f:
        f.write(content)

    return True

if __name__ == "__main__":
    if add_split_allocation_files():
        print(" Added SplitAllocation.swift and SplitAllocationViewModel.swift to project")