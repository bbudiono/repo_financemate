#!/usr/bin/env python3

"""
Emergency fix: Force LoginView.swift into Swift compilation
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
    
    # Find DerivedData directory
    success, stdout, stderr = run_command("find ~/Library/Developer/Xcode/DerivedData -name 'FinanceMate-*' -type d")
    if not success or not stdout.strip():
        print("❌ Could not find FinanceMate DerivedData directory")
        return False
    
    derived_data_dir = stdout.strip().split('\n')[0]
    swift_file_list_path = f"{derived_data_dir}/Build/Intermediates.noindex/FinanceMate.build/Debug/FinanceMate.build/Objects-normal/arm64/FinanceMate.SwiftFileList"
    
    print(f"✅ DerivedData: {derived_data_dir}")
    
    # Check if SwiftFileList exists
    if not os.path.exists(swift_file_list_path):
        print("❌ SwiftFileList does not exist")
        return False
    
    # Read current SwiftFileList
    with open(swift_file_list_path, 'r') as f:
        current_files = f.read().strip().split('\n')
    
    print(f"✅ Current SwiftFileList has {len(current_files)} files")
    
    # Add LoginView.swift to the list
    loginview_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents\\ -\\ Apps\\ (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/LoginView.swift"
    
    if loginview_path not in current_files:
        current_files.append(loginview_path)
        
        # Write updated SwiftFileList
        with open(swift_file_list_path, 'w') as f:
            f.write('\n'.join(current_files) + '\n')
        
        print("✅ LoginView.swift FORCED into SwiftFileList")
    else:
        print("✅ LoginView.swift already in SwiftFileList")
    
    return True

if __name__ == "__main__":
    success = force_loginview_compilation()
    exit(0 if success else 1)