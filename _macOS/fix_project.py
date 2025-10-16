#!/usr/bin/env python3
"""
Script to safely add missing Service files to Xcode project
"""

import re
import uuid

def generate_uuid():
    """Generate a random UUID string"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_service_to_project(project_content, service_name, relative_path):
    """Add a service file to Xcode project content"""

    # Generate unique identifiers
    file_id = generate_uuid()
    build_id = generate_uuid()

    # Add to PBXBuildFile section
    build_file_entry = f"\t\t{build_id} /* {service_name}.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {service_name}.swift */; }};\n"

    # Find the end of PBXBuildFile section
    build_file_pattern = r'(/\* End PBXBuildFile section \*/)'
    project_content = re.sub(build_file_pattern, build_file_entry + r'\1', project_content)

    # Add to PBXFileReference section
    file_ref_entry = f"\t\t{file_id} /* {service_name}.swift */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; name = {service_name}.swift; path = {relative_path}; sourceTree = \"<group>\"; }};\n"

    # Find the end of PBXFileReference section
    file_ref_pattern = r'(/\* End PBXFileReference section \*/)'
    project_content = re.sub(file_ref_pattern, file_ref_entry + r'\1', project_content)

    # Add to Services group
    services_entry = f"\t\t\t\t{file_id} /* {service_name}.swift */,\n"

    # Find Services group and add before closing parenthesis
    services_pattern = r'(\t\t\t\tDC524285E44B59635B116C6D /\* PDFExtractionService\.swift \*/,\n\t\t\t\);)'
    project_content = re.sub(services_pattern, services_entry + r'\1', project_content)

    # Add to PBXSourcesBuildPhase section
    sources_entry = f"\t\t\t\t{build_id} /* {service_name}.swift in Sources */,\n"

    # Find Sources build phase and add before closing parenthesis
    sources_pattern = r'(\t\t\t\t9B5C7ECD660ABFE356AA3387 /\* PDFExtractionService\.swift in Sources \*/,\n\t\t\t\);)'
    project_content = re.sub(sources_pattern, sources_entry + r'\1', project_content)

    return project_content

def main():
    """Main function to fix the Xcode project"""
    project_path = "FinanceMate.xcodeproj/project.pbxproj"

    # Read current project file
    with open(project_path, 'r') as f:
        content = f.read()

    # Services to add
    services = [
        ("EmailIntentAnalyzer", "Services/EmailIntentAnalyzer.swift"),
        ("MarketingContentDetector", "Services/MarketingContentDetector.swift"),
        ("ProfessionalCorrespondenceDetector", "Services/ProfessionalCorrespondenceDetector.swift"),
        ("EmailNegativePatternDetector", "Services/EmailNegativePatternDetector.swift"),
        ("ReceiptValidator", "Services/ReceiptValidator.swift"),
        ("MerchantDatabase", "MerchantDatabase.swift"),  # Note: different path
        ("TransactionFieldEditor", "Services/TransactionFieldEditor.swift")
    ]

    # Add each service
    for service_name, relative_path in services:
        print(f"Adding {service_name}...")
        content = add_service_to_project(content, service_name, relative_path)

    # Write updated content
    with open(project_path, 'w') as f:
        f.write(content)

    print("Project file updated successfully!")

if __name__ == "__main__":
    main()