#!/usr/bin/env python3
"""
EMERGENCY SWIFT CONCURRENCY COMPLETE FIX
Comprehensive solution to eliminate ALL Swift Concurrency patterns causing TaskLocal crashes
"""

import os
import re
import shutil
from pathlib import Path

def create_backup(file_path):
    """Create backup with timestamp"""
    backup_path = f"{file_path}.backup_emergency_fix_{int(__import__('time').time())}"
    shutil.copy2(file_path, backup_path)
    return backup_path

def remove_all_concurrency_patterns(content):
    """Remove ALL Swift Concurrency patterns comprehensively"""
    
    # 1. Remove @MainActor annotations completely
    content = re.sub(r'@MainActor\s*\n?', '', content)
    
    # 2. Convert async func to synchronous func
    content = re.sub(r'async\s+func\s+', 'func ', content)
    content = re.sub(r'func\s+([^(]+)\([^)]*\)\s*async\s*throws\s*->', r'func \1() throws ->', content)
    content = re.sub(r'func\s+([^(]+)\([^)]*\)\s*async\s*->', r'func \1() ->', content)
    content = re.sub(r'async\s+throws', 'throws', content)
    content = re.sub(r'async\s*{', '{', content)
    
    # 3. Remove await keywords
    content = re.sub(r'\bawait\s+', '', content)
    
    # 4. Replace Task blocks with synchronous execution
    content = re.sub(r'Task\s*{\s*@MainActor\s+in\s*([^}]+)\s*}', r'// Synchronous execution\n\1', content, flags=re.DOTALL)
    content = re.sub(r'Task\s*{\s*([^}]+)\s*}', r'// Synchronous execution\n\1', content, flags=re.DOTALL)
    content = re.sub(r'Task\.detached\s*{\s*([^}]+)\s*}', r'// Synchronous execution\n\1', content, flags=re.DOTALL)
    
    # 5. Replace MainActor.run with direct execution
    content = re.sub(r'MainActor\.run\s*{\s*([^}]+)\s*}', r'\1', content, flags=re.DOTALL)
    
    # 6. Replace withCheckedThrowingContinuation with direct Core Data patterns
    content = re.sub(
        r'try await withCheckedThrowingContinuation\s*{\s*continuation\s+in\s*([^}]+)\s*}',
        r'// Direct synchronous execution\n\1',
        content,
        flags=re.DOTALL
    )
    
    # 7. Replace async test methods with synchronous expectation patterns
    content = re.sub(r'func\s+(test[^(]+)\(\)\s*async\s*{', r'func \1() {', content)
    
    # 8. Remove TaskLocal and related patterns
    content = re.sub(r'TaskLocal[^;]+;?\n?', '', content)
    content = re.sub(r'XCTSwiftErrorObservation[^;]+;?\n?', '', content)
    
    # 9. Convert async/await patterns to synchronous Core Data
    content = re.sub(
        r'context\.perform\s*{\s*([^}]+)\s*continuation\.resume\([^)]+\)\s*}',
        r'context.performAndWait {\n\1\n}',
        content,
        flags=re.DOTALL
    )
    
    # 10. Add synchronous fallback comments
    content = re.sub(
        r'(//.*EMERGENCY FIX.*\n)',
        r'\1// COMPREHENSIVE FIX: Removed ALL Swift Concurrency patterns to eliminate TaskLocal crashes\n',
        content
    )
    
    return content

def fix_swift_file(file_path):
    """Fix a single Swift file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
        
        # Create backup
        backup_path = create_backup(file_path)
        print(f"Created backup: {backup_path}")
        
        # Apply fixes
        fixed_content = remove_all_concurrency_patterns(original_content)
        
        # Only write if there were changes
        if fixed_content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            print(f"FIXED: {file_path}")
            return True
        else:
            print(f"No changes needed: {file_path}")
            return False
            
    except Exception as e:
        print(f"ERROR fixing {file_path}: {e}")
        return False

def main():
    """Main execution function"""
    
    # Directories to process
    base_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS")
    
    directories_to_fix = [
        base_path / "FinanceMate/FinanceMate/ViewModels",
        base_path / "FinanceMate/FinanceMate/Services", 
        base_path / "FinanceMate/FinanceMate/Analytics",
        base_path / "FinanceMateTests/ViewModels",
        base_path / "FinanceMateTests/Services",
        base_path / "FinanceMate-SandboxTests/ViewModels",
        base_path / "FinanceMate-SandboxTests/Services"
    ]
    
    files_fixed = 0
    total_files = 0
    
    print("🚨 EMERGENCY SWIFT CONCURRENCY COMPREHENSIVE FIX INITIATED")
    print("=" * 60)
    
    for directory in directories_to_fix:
        if directory.exists():
            print(f"\nProcessing directory: {directory}")
            
            # Process all Swift files in directory
            for swift_file in directory.glob("*.swift"):
                total_files += 1
                if fix_swift_file(swift_file):
                    files_fixed += 1
    
    print("\n" + "=" * 60)
    print(f"EMERGENCY FIX COMPLETE:")
    print(f"Files processed: {total_files}")
    print(f"Files fixed: {files_fixed}")
    print(f"Success rate: {(files_fixed/total_files)*100:.1f}%" if total_files > 0 else "No files processed")
    
    print("\n🎯 EXPECTED RESULTS:")
    print("- Zero TaskLocal crashes during test execution")
    print("- All Swift Concurrency patterns removed") 
    print("- Synchronous Core Data operations only")
    print("- Stable test execution without memory issues")
    
    print("\n⚠️  VERIFICATION REQUIRED:")
    print("Run: xcodebuild test -project FinanceMate.xcodeproj -scheme FinanceMate -destination 'platform=macOS'")

if __name__ == "__main__":
    main()