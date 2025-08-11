#!/usr/bin/env python3

"""
Fix Gmail connector file paths in Xcode project
The files need to be referenced with correct relative paths
"""

import os
import sys
import re

def fix_xcode_project():
    """Fix the Xcode project file to use correct paths for Gmail connector files"""
    
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    pbxproj_path = f"{project_path}/FinanceMate.xcodeproj/project.pbxproj"
    
    if not os.path.exists(pbxproj_path):
        print(f"❌ Error: Xcode project file not found at {pbxproj_path}")
        return False
    
    print("🔧 Fixing Gmail connector file paths in Xcode project...")
    
    # Read the project file
    with open(pbxproj_path, 'r') as f:
        project_content = f.read()
    
    # Remove any incorrect references to Gmail connector files
    lines_to_remove = [
        r'.*GmailAPIService\.swift.*',
        r'.*ExpenseTableView\.swift.*',
        r'.*GMAIL\d+.*'
    ]
    
    original_content = project_content
    
    for pattern in lines_to_remove:
        project_content = re.sub(pattern, '', project_content, flags=re.MULTILINE)
    
    # Clean up any empty lines that were left
    project_content = re.sub(r'\n\s*\n', '\n', project_content)
    
    if original_content != project_content:
        # Write the cleaned project file
        with open(pbxproj_path, 'w') as f:
            f.write(project_content)
        print("✅ Removed Gmail connector references from Xcode project")
    else:
        print("ℹ️  No Gmail connector references found to remove")
    
    return True

def create_proper_structure():
    """Create proper directory structure and check file locations"""
    
    base_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    
    # Expected file locations
    service_dir = f"{base_path}/FinanceMate/Services"
    view_dir = f"{base_path}/FinanceMate/Views"
    
    gmail_service_path = f"{service_dir}/GmailAPIService.swift" 
    expense_view_path = f"{view_dir}/ExpenseTableView.swift"
    
    print("🔍 Checking Gmail connector file structure...")
    
    # Check if directories exist
    if not os.path.exists(service_dir):
        print(f"❌ Services directory not found: {service_dir}")
        return False
    
    if not os.path.exists(view_dir):
        print(f"❌ Views directory not found: {view_dir}")
        return False
    
    # Check if files exist
    if os.path.exists(gmail_service_path):
        print(f"   ✅ GmailAPIService.swift exists at correct location")
    else:
        print(f"   ❌ GmailAPIService.swift not found at {gmail_service_path}")
        return False
    
    if os.path.exists(expense_view_path):
        print(f"   ✅ ExpenseTableView.swift exists at correct location")
    else:
        print(f"   ❌ ExpenseTableView.swift not found at {expense_view_path}")
        return False
    
    return True

def create_manual_xcode_instructions():
    """Create instructions for manually adding files to Xcode"""
    
    instructions_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/docs/MANUAL_XCODE_GMAIL_INTEGRATION.md"
    
    instructions = """# Manual Xcode Integration for Gmail Connector

**Date**: 2025-08-10  
**Status**: 🔧 **MANUAL INTEGRATION REQUIRED**  
**Purpose**: Add Gmail connector files to Xcode project manually  

---

## 🎯 **MANUAL STEPS REQUIRED**

The automated integration encountered path issues. Please follow these manual steps:

### **Step 1: Open Xcode Project**
1. Open `FinanceMate.xcodeproj` in Xcode
2. Ensure you can see the project navigator on the left

### **Step 2: Add GmailAPIService.swift**
1. Right-click on the **"Services"** group in project navigator
2. Select **"Add Files to FinanceMate..."**
3. Navigate to: `FinanceMate/Services/GmailAPIService.swift`
4. Click **"Add"**
5. Verify the file appears in the Services group

### **Step 3: Add ExpenseTableView.swift**
1. Right-click on the **"Views"** group in project navigator  
2. Select **"Add Files to FinanceMate..."**
3. Navigate to: `FinanceMate/Views/ExpenseTableView.swift`
4. Click **"Add"**
5. Verify the file appears in the Views group

### **Step 4: Verify Integration**
1. Build the project (⌘+B)
2. Verify both files compile without errors
3. Check that the "Email Receipts" tab appears in the app

---

## 🔧 **FILE LOCATIONS**

The Gmail connector files are located at:

```
FinanceMate/
├── Services/
│   └── GmailAPIService.swift        ← Add this to Services group
├── Views/
│   └── ExpenseTableView.swift       ← Add this to Views group
└── FinanceMate/
    └── ContentView.swift            ← Already updated with Email Receipts tab
```

---

## 🧪 **TESTING AFTER INTEGRATION**

Once files are added to Xcode:

1. **Build Verification**: Project should compile successfully
2. **Tab Navigation**: "Email Receipts" tab should appear
3. **Gmail Authentication**: Should prompt for Gmail OAuth when clicked
4. **Receipt Processing**: Should scan and display expenses from Gmail

---

## 🚨 **TROUBLESHOOTING**

### **Build Errors**
- Ensure both files are added to the main target (FinanceMate)
- Check that import statements are correct
- Verify file membership in target settings

### **Missing Tab**
- Ensure ContentView.swift includes the ExpenseTableView tab
- Check that the tab is properly configured in TabView

### **OAuth Issues**
- Ensure ProductionConfig.swift has valid Gmail client ID
- Check that Google Cloud Console is properly configured

---

## 🎯 **SUCCESS CRITERIA**

✅ **Integration Complete When:**
- Project builds successfully without errors
- "Email Receipts" tab visible in app navigation
- Gmail authentication flow works correctly
- Expense table displays real receipt data

---

**⚡ IMMEDIATE ACTION**: Open Xcode and manually add the two Gmail connector files to complete the integration.**
"""
    
    with open(instructions_path, 'w') as f:
        f.write(instructions)
    
    print(f"📋 Manual integration instructions created: {instructions_path}")

def main():
    print("🔧 Gmail Connector Xcode Path Fix")
    print("================================")
    print("")
    
    # Fix Xcode project by removing invalid references
    if not fix_xcode_project():
        print("❌ Failed to fix Xcode project")
        sys.exit(1)
    
    # Check file structure
    if not create_proper_structure():
        print("❌ Gmail connector file structure issues detected")
        sys.exit(1)
    
    # Create manual instructions
    create_manual_xcode_instructions()
    
    print("")
    print("🎯 Gmail connector path fix complete!")
    print("")
    print("📋 NEXT STEPS (MANUAL):")
    print("1. Open FinanceMate.xcodeproj in Xcode")
    print("2. Add GmailAPIService.swift to Services group")
    print("3. Add ExpenseTableView.swift to Views group")
    print("4. Build and test the integration")
    print("")
    print("📖 See: docs/MANUAL_XCODE_GMAIL_INTEGRATION.md for detailed steps")

if __name__ == "__main__":
    main()