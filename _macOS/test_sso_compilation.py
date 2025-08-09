#!/usr/bin/env python3
"""
Test SSO Component Compilation
Isolate and test individual SSO file compilation
"""

import os
import subprocess
import tempfile
import shutil

def create_minimal_test_project():
    """Create minimal test to verify SSO compilation"""
    
    # Create temporary directory
    temp_dir = tempfile.mkdtemp()
    print(f"📁 Created temp directory: {temp_dir}")
    
    try:
        # Copy essential SSO files to temp directory
        sso_files = [
            'FinanceMate/FinanceMate/Services/SSOManager.swift',
            'FinanceMate/FinanceMate/Services/TokenStorage.swift', 
            'FinanceMate/FinanceMate/Services/AppleAuthProvider.swift',
            'FinanceMate/FinanceMate/Services/GoogleAuthProvider.swift',
            'FinanceMate/FinanceMate/Models/UserSession.swift'
        ]
        
        print("📋 Copying SSO files to temp directory...")
        for file_path in sso_files:
            if os.path.exists(file_path):
                dest_path = os.path.join(temp_dir, os.path.basename(file_path))
                shutil.copy2(file_path, dest_path)
                print(f"✅ Copied: {os.path.basename(file_path)}")
            else:
                print(f"❌ Missing: {file_path}")
        
        # Try to compile individual files using swiftc
        print("\n🔧 Testing individual file compilation...")
        
        for file_path in sso_files:
            filename = os.path.basename(file_path)
            temp_file = os.path.join(temp_dir, filename)
            
            if os.path.exists(temp_file):
                try:
                    # Try syntax check only
                    result = subprocess.run([
                        'swiftc', '-parse', temp_file
                    ], capture_output=True, text=True, timeout=30)
                    
                    if result.returncode == 0:
                        print(f"✅ {filename} - Syntax OK")
                    else:
                        print(f"❌ {filename} - Syntax errors:")
                        print(f"   {result.stderr[:200]}...")
                        
                except subprocess.TimeoutExpired:
                    print(f"⏱️  {filename} - Compilation timeout")
                except Exception as e:
                    print(f"⚠️  {filename} - Error: {e}")
        
    finally:
        # Cleanup
        shutil.rmtree(temp_dir)
        print(f"\n🧹 Cleaned up temp directory")

def analyze_dependencies():
    """Analyze dependency relationships between SSO files"""
    
    print("\n🔍 DEPENDENCY ANALYSIS")
    print("=" * 40)
    
    sso_files = [
        'FinanceMate/FinanceMate/Services/SSOManager.swift',
        'FinanceMate/FinanceMate/Services/TokenStorage.swift',
        'FinanceMate/FinanceMate/Services/AppleAuthProvider.swift', 
        'FinanceMate/FinanceMate/Services/GoogleAuthProvider.swift'
    ]
    
    dependencies = {}
    
    for file_path in sso_files:
        if os.path.exists(file_path):
            filename = os.path.basename(file_path)
            deps = set()
            
            with open(file_path, 'r') as f:
                content = f.read()
                
                # Look for class/struct references
                for other_file in sso_files:
                    other_name = os.path.basename(other_file).replace('.swift', '')
                    if other_name != filename.replace('.swift', '') and other_name in content:
                        deps.add(other_name)
                
                # Look for specific types
                if 'OAuth2Provider' in content:
                    deps.add('OAuth2Provider (from UserSession)')
                if 'AuthenticationResult' in content:
                    deps.add('AuthenticationResult (from AuthenticationService)')
            
            dependencies[filename] = deps
    
    # Display dependency tree
    for filename, deps in dependencies.items():
        print(f"\n📄 {filename}:")
        if deps:
            for dep in sorted(deps):
                print(f"   → {dep}")
        else:
            print("   → No dependencies found")

def main():
    """Main execution"""
    print("🧪 SSO COMPILATION TEST")
    print("=" * 50)
    
    os.chdir('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS')
    
    analyze_dependencies()
    create_minimal_test_project()
    
    print("\n📊 ANALYSIS COMPLETE")

if __name__ == "__main__":
    main()