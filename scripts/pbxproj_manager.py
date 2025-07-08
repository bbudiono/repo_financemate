#!/usr/bin/env python3
"""
pbxproj_manager.py - Advanced Xcode project.pbxproj manipulation

This script provides robust automation for Xcode project configuration:
1. Apple Developer Team ID configuration
2. Core Data model build phase integration
3. Build settings validation and updates

Usage:
    python3 pbxproj_manager.py --team-id YOUR_TEAM_ID --project-path PATH_TO_XCODEPROJ
    python3 pbxproj_manager.py --add-coredata --coredata-path PATH_TO_XCDATAMODELD
    python3 pbxproj_manager.py --validate --project-path PATH_TO_XCODEPROJ
"""

import argparse
import os
import re
import sys
import uuid
import shutil
from datetime import datetime
from pathlib import Path


class PBXProjManager:
    """Manages Xcode project.pbxproj file modifications"""
    
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.pbxproj_path = self.project_path / "project.pbxproj"
        self.content = ""
        self.backup_path = None
        
        if not self.pbxproj_path.exists():
            raise FileNotFoundError(f"Project file not found: {self.pbxproj_path}")
        
        self._load_content()
    
    def _load_content(self):
        """Load project file content"""
        with open(self.pbxproj_path, 'r', encoding='utf-8') as f:
            self.content = f.read()
    
    def _save_content(self):
        """Save project file content with backup"""
        # Create backup
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.backup_path = self.pbxproj_path.with_suffix(f".pbxproj.backup-{timestamp}")
        shutil.copy2(self.pbxproj_path, self.backup_path)
        
        # Write new content
        with open(self.pbxproj_path, 'w', encoding='utf-8') as f:
            f.write(self.content)
    
    def update_development_team(self, team_id):
        """Update DEVELOPMENT_TEAM in all build configurations"""
        print(f"🔄 Updating DEVELOPMENT_TEAM to: {team_id}")
        
        # Pattern to match DEVELOPMENT_TEAM entries
        pattern = r'DEVELOPMENT_TEAM = [^;]*;'
        replacement = f'DEVELOPMENT_TEAM = {team_id};'
        
        # Count existing entries
        existing_count = len(re.findall(pattern, self.content))
        
        # Update all entries
        self.content = re.sub(pattern, replacement, self.content)
        
        # Verify changes
        new_count = len(re.findall(f'DEVELOPMENT_TEAM = {team_id};', self.content))
        
        if new_count == existing_count and new_count > 0:
            print(f"✅ Successfully updated {new_count} DEVELOPMENT_TEAM entries")
            return True
        elif new_count == 0:
            print("❌ No DEVELOPMENT_TEAM entries found to update")
            return False
        else:
            print(f"⚠️  Updated {new_count} entries, expected {existing_count}")
            return True
    
    def add_coredata_model(self, coredata_path):
        """Add Core Data model to build phase"""
        print(f"💾 Adding Core Data model to build phase: {coredata_path}")
        
        coredata_path = Path(coredata_path)
        if not coredata_path.exists():
            raise FileNotFoundError(f"Core Data model not found: {coredata_path}")
        
        # Check if already added
        if "FinanceMateModel.xcdatamodeld" in self.content:
            print("✅ Core Data model already configured in build phase")
            return True
        
        # Generate unique IDs
        fileref_id = self._generate_pbx_id()
        buildfile_id = self._generate_pbx_id()
        
        # Get relative path for the model
        model_name = coredata_path.name
        relative_path = f"Models/{model_name}"
        
        # Add PBXFileReference
        if not self._add_file_reference(fileref_id, model_name, relative_path):
            print("❌ Failed to add PBXFileReference")
            return False
        
        # Add PBXBuildFile
        if not self._add_build_file(buildfile_id, fileref_id, model_name):
            print("❌ Failed to add PBXBuildFile")
            return False
        
        # Add to Sources build phase
        if not self._add_to_sources_build_phase(buildfile_id, model_name):
            print("❌ Failed to add to Sources build phase")
            return False
        
        # Add to Models group
        if not self._add_to_models_group(fileref_id, model_name):
            print("⚠️  Could not add to Models group (group may not exist)")
        
        print("✅ Successfully added Core Data model to build phase")
        return True
    
    def _generate_pbx_id(self):
        """Generate a unique 24-character hex ID for pbxproj"""
        return ''.join([format(x, 'X') for x in uuid.uuid4().bytes[:12]])
    
    def _add_file_reference(self, file_id, model_name, relative_path):
        """Add PBXFileReference entry"""
        # Find the PBXFileReference section
        fileref_pattern = r'(/\* Begin PBXFileReference section \*/.*?)(\s*/\* End PBXFileReference section \*/)'
        match = re.search(fileref_pattern, self.content, re.DOTALL)
        
        if not match:
            print("❌ Could not find PBXFileReference section")
            return False
        
        # Create new file reference entry
        fileref_entry = f'\t\t{file_id} /* {model_name} */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.xcdatamodel; path = {model_name}; sourceTree = "<group>"; versionGroupType = wrapper.xcdatamodel; }};\n'
        
        # Insert before the end of the section
        new_section = match.group(1) + fileref_entry + match.group(2)
        self.content = self.content.replace(match.group(0), new_section)
        
        return True
    
    def _add_build_file(self, build_id, file_id, model_name):
        """Add PBXBuildFile entry"""
        # Find the PBXBuildFile section
        buildfile_pattern = r'(/\* Begin PBXBuildFile section \*/.*?)(\s*/\* End PBXBuildFile section \*/)'
        match = re.search(buildfile_pattern, self.content, re.DOTALL)
        
        if not match:
            print("❌ Could not find PBXBuildFile section")
            return False
        
        # Create new build file entry
        buildfile_entry = f'\t\t{build_id} /* {model_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {model_name} */; }};\n'
        
        # Insert before the end of the section
        new_section = match.group(1) + buildfile_entry + match.group(2)
        self.content = self.content.replace(match.group(0), new_section)
        
        return True
    
    def _add_to_sources_build_phase(self, build_id, model_name):
        """Add build file to Sources build phase"""
        # Find Sources build phases
        sources_pattern = r'([\w\d]+) /\* Sources \*/ = \{[^}]*isa = PBXSourcesBuildPhase;[^}]*files = \(([^)]*)\);[^}]*runOnlyForDeploymentPostprocessing = 0;[^}]*\};'
        matches = re.findall(sources_pattern, self.content, re.DOTALL)
        
        added_to_main = False
        for phase_id, files_content in matches:
            # Check if this is the main app target (contains FinanceMateApp.swift)
            if 'FinanceMateApp.swift' in files_content:
                # Add our build file
                new_files_content = files_content.rstrip() + f'\n\t\t\t\t{build_id} /* {model_name} in Sources */,'
                self.content = self.content.replace(files_content, new_files_content)
                added_to_main = True
                break
        
        if not added_to_main:
            print("⚠️  Could not identify main app target for Sources build phase")
            # Try to add to first Sources build phase as fallback
            if matches:
                phase_id, files_content = matches[0]
                new_files_content = files_content.rstrip() + f'\n\t\t\t\t{build_id} /* {model_name} in Sources */,'
                self.content = self.content.replace(files_content, new_files_content)
                print("⚠️  Added to first available Sources build phase")
        
        return True
    
    def _add_to_models_group(self, file_id, model_name):
        """Add file reference to Models group"""
        # Find Models group
        models_pattern = r'([\w\d]+) /\* Models \*/ = \{[^}]*isa = PBXGroup;[^}]*children = \(([^)]*)\);'
        match = re.search(models_pattern, self.content, re.DOTALL)
        
        if not match:
            # Try to find any group that might contain models
            return False
        
        group_id, children_content = match.groups()
        new_children_content = children_content.rstrip() + f'\n\t\t\t\t{file_id} /* {model_name} */,'
        self.content = self.content.replace(children_content, new_children_content)
        
        return True
    
    def validate_configuration(self):
        """Validate current project configuration"""
        print("🔍 Validating project configuration...")
        
        issues = []
        
        # Check for DEVELOPMENT_TEAM
        team_entries = re.findall(r'DEVELOPMENT_TEAM = ([^;]*);', self.content)
        if not team_entries:
            issues.append("❌ No DEVELOPMENT_TEAM entries found")
        else:
            unique_teams = set(team_entries)
            if len(unique_teams) == 1:
                print(f"✅ DEVELOPMENT_TEAM configured: {unique_teams.pop()}")
            else:
                issues.append(f"⚠️  Multiple DEVELOPMENT_TEAM values found: {unique_teams}")
        
        # Check for Core Data model
        if "FinanceMateModel.xcdatamodeld" in self.content:
            print("✅ Core Data model configured in build phase")
        else:
            issues.append("❌ Core Data model not found in build phase")
        
        # Check for signing style
        signing_styles = re.findall(r'CODE_SIGN_STYLE = ([^;]*);', self.content)
        if signing_styles:
            unique_styles = set(signing_styles)
            if "Automatic" in unique_styles:
                print("✅ Automatic code signing configured")
            else:
                print(f"⚠️  Code signing style: {unique_styles}")
        
        if issues:
            print("\n🚨 Configuration Issues Found:")
            for issue in issues:
                print(f"   {issue}")
            return False
        else:
            print("\n✅ Project configuration is valid!")
            return True
    
    def save_changes(self):
        """Save all changes to project file"""
        self._save_content()
        if self.backup_path:
            print(f"📋 Backup created: {self.backup_path}")
        print(f"✅ Project file updated: {self.pbxproj_path}")


def main():
    parser = argparse.ArgumentParser(description="Xcode project.pbxproj automation tool")
    parser.add_argument('--project-path', required=True, help='Path to .xcodeproj directory')
    parser.add_argument('--team-id', help='Apple Developer Team ID')
    parser.add_argument('--add-coredata', action='store_true', help='Add Core Data model to build phase')
    parser.add_argument('--coredata-path', help='Path to .xcdatamodeld file')
    parser.add_argument('--validate', action='store_true', help='Validate project configuration')
    
    args = parser.parse_args()
    
    try:
        # Initialize project manager
        manager = PBXProjManager(args.project_path)
        
        changes_made = False
        
        # Update team ID if provided
        if args.team_id:
            if manager.update_development_team(args.team_id):
                changes_made = True
        
        # Add Core Data model if requested
        if args.add_coredata:
            if not args.coredata_path:
                print("❌ --coredata-path is required when using --add-coredata")
                sys.exit(1)
            
            if manager.add_coredata_model(args.coredata_path):
                changes_made = True
        
        # Save changes if any were made
        if changes_made:
            manager.save_changes()
        
        # Validate configuration
        if args.validate or changes_made:
            if not manager.validate_configuration():
                sys.exit(1)
        
        print("\n🎉 Project configuration completed successfully!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()