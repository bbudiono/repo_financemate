#!/usr/bin/env python3

"""
EMERGENCY: Force LoginView.swift into Swift compilation by directly modifying SwiftFileList
"""

import os
import subprocess

def run_command(cmd):
    """Run a shell command and return the result"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        print(f"❌ Error running command: {e}")
        return False, "", str(e)

def force_loginview_compilation():
    """Force LoginView.swift into compilation"""
    
    print("🚨 EMERGENCY: FORCING LOGINVIEW.SWIFT INTO COMPILATION")
    print("=" * 60)
    
    # Step 1: Define the SwiftFileList path
    swift_file_list_path = "/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Intermediates.noindex/FinanceMate.build/Debug/FinanceMate.build/Objects-normal/arm64/FinanceMate.SwiftFileList"
    
    print(f"✅ SwiftFileList path: {swift_file_list_path}")
    
    # Step 2: Check if SwiftFileList exists
    if not os.path.exists(swift_file_list_path):
        print("❌ SwiftFileList does not exist - build process hasn't started")
        return False
    
    # Step 3: Read current SwiftFileList
    with open(swift_file_list_path, 'r') as f:
        current_files = f.read().strip().split('\n')
    
    print(f"✅ Current SwiftFileList has {len(current_files)} files")
    
    # Step 4: Check if LoginView.swift is already in the list
    loginview_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents\\ -\\ Apps\\ (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/LoginView.swift"
    
    if loginview_path in current_files:
        print("✅ LoginView.swift already in SwiftFileList")
        return True
    
    # Step 5: Add LoginView.swift to the list
    current_files.append(loginview_path)
    
    # Step 6: Write updated SwiftFileList
    with open(swift_file_list_path, 'w') as f:
        f.write('\n'.join(current_files) + '\n')
    
    print("✅ LoginView.swift FORCED into SwiftFileList")
    print(f"✅ Updated SwiftFileList now has {len(current_files)} files")
    
    return True

def main():
    """Main function"""
    if force_loginview_compilation():
        print("\n🎉 EMERGENCY FIX SUCCESSFUL!")
        print("💡 LoginView.swift is now in compilation - ready for build retry")
        return True
    else:
        print("\n❌ EMERGENCY FIX FAILED")
        print("💡 Additional investigation required")
        return False

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)