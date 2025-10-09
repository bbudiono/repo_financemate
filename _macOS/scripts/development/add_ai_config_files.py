#!/usr/bin/env python3
"""
Add AI Configuration files to Xcode project
"""

import re
import sys

def add_file_to_project(project_file, file_path, file_name):
    """Add a file to the Xcode project"""

    # Read project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Check if file already exists
    if file_name in content:
        print(f"File {file_name} already in project")
        return True

    # Find FinanceMate sources section and add the new file
    sources_pattern = r'(FinanceMate\.sources = \(\s*.*?)(\s*\);)'

    def add_source_file(match):
        prefix = match.group(1)
        suffix = match.group(2)

        # Add the new source file
        new_file = f'\n\t\t{file_path} /* Sources */,\n'
        return prefix + new_file + suffix

    new_content = re.sub(sources_pattern, add_source_file, content, flags=re.DOTALL)

    # Write back
    with open(project_file, 'w') as f:
        f.write(new_content)

    print(f"Added {file_name} to project")
    return True

def main():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    files_to_add = [
        ("FinanceMate/Views/Settings/AIConfigurationSettingsSection.swift", "AIConfigurationSettingsSection.swift"),
        ("FinanceMate/ViewModels/AIConfigurationViewModel.swift", "AIConfigurationViewModel.swift"),
        ("FinanceMate/Models/AIModel.swift", "AIModel.swift"),
        ("FinanceMate/Models/AIProvider.swift", "AIProvider.swift"),
        ("FinanceMate/Models/LLMJudgeConfiguration.swift", "LLMJudgeConfiguration.swift"),
        ("FinanceMate/Services/AIModelConfigurationManager.swift", "AIModelConfigurationManager.swift"),
        ("FinanceMate/Services/AIModelDiscoveryService.swift", "AIModelDiscoveryService.swift"),
        ("FinanceMate/Services/ModelHealthCheckService.swift", "ModelHealthCheckService.swift"),
        ("FinanceMate/Services/AIServiceProtocols.swift", "AIServiceProtocols.swift"),
        ("FinanceMate/Services/OllamaService.swift", "OllamaService.swift"),
        ("FinanceMate/Services/OpenAIService.swift", "OpenAIService.swift"),
        ("FinanceMate/Services/AnthropicService.swift", "AnthropicService.swift"),
        ("FinanceMate/Services/OllamaHealthCheckerService.swift", "OllamaHealthCheckerService.swift"),
        ("FinanceMate/Services/OpenAIHealthCheckerService.swift", "OpenAIHealthCheckerService.swift"),
        ("FinanceMate/Services/AnthropicHealthCheckerService.swift", "AnthropicHealthCheckerService.swift"),
        ("FinanceMate/Views/Settings/AIModelSelectionView.swift", "AIModelSelectionView.swift"),
        ("FinanceMate/Views/Settings/AIModelSelectionComponents.swift", "AIModelSelectionComponents.swift")
    ]

    for file_path, file_name in files_to_add:
        add_file_to_project(project_file, file_path, file_name)

    print("AI Configuration files added to project")

if __name__ == "__main__":
    main()