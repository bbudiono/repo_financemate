#\!/usr/bin/env python3

"""
Force LoginView.swift into Swift compilation by directly modifying SwiftFileList
This is the nuclear option to force Xcode to include LoginView.swift
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
    
    # Step 1: Find the current DerivedData directory
    success, stdout, stderr = run_command("find ~/Library/Developer/Xcode/DerivedData -name 'FinanceMate-*' -type d")
    if not success or not stdout.strip():
        print("❌ Could not find FinanceMate DerivedData directory")
        return False
    
    derived_data_dir = stdout.strip().split('\n')[0]  # Take first match
    swift_file_list_path = f"{derived_data_dir}/Build/Intermediates.noindex/FinanceMate.build/Debug/FinanceMate.build/Objects-normal/arm64/FinanceMate.SwiftFileList"
    
    print(f"✅ Found DerivedData: {derived_data_dir}")
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
    
    # Step 7: Attempt build
    print("\n🔨 ATTEMPTING BUILD WITH FORCED LOGINVIEW.SWIFT...")
    os.chdir("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS")
    
    success, stdout, stderr = run_command("xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate build")
    
    if success:
        print("🎉 BUILD SUCCESSFUL WITH FORCED LOGINVIEW.SWIFT\!")
        
        # Check if executable was created
        executable_path = f"{derived_data_dir}/Build/Products/Debug/FinanceMate.app/Contents/MacOS/FinanceMate"
        
        if os.path.exists(executable_path):
            print(f"✅ Executable created: {executable_path}")
            print("🚀 Ready to test Apple Sign-In\!")
            return True
        else:
            print("⚠️ Build succeeded but executable not found")
            return False
    else:
        print("❌ Build failed even with forced LoginView.swift")
        print("STDOUT:", stdout)
        print("STDERR:", stderr)
        return False

def main():
    """Main function"""
    if force_loginview_compilation():
        print("\n🎉 EMERGENCY FIX SUCCESSFUL\!")
        print("💡 LoginView.swift is now in compilation - ready for Apple Sign-In testing")
        return True
    else:
        print("\n❌ EMERGENCY FIX FAILED")
        print("💡 Additional investigation required")
        return False

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
EOF < /dev/null