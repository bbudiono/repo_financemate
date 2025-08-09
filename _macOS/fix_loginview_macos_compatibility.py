#!/usr/bin/env python3

"""
Fix LoginView.swift for macOS compatibility by removing iOS-specific modifiers
and correcting GlassmorphismModifier usage
"""

import re

def fix_loginview_macos_compatibility():
    """Fix LoginView.swift for macOS compatibility"""
    
    print("🔧 FIXING LOGINVIEW.SWIFT FOR MACOS COMPATIBILITY")
    print("=" * 55)
    
    loginview_file = "FinanceMate/FinanceMate/Views/LoginView.swift"
    
    # Read the LoginView.swift file
    with open(loginview_file, 'r') as f:
        content = f.read()
    
    print("✅ Read LoginView.swift file")
    
    # Fix 1: Update GlassmorphismModifier usage
    # Replace .modifier(GlassmorphismModifier(.primary)) with correct syntax
    content = re.sub(
        r'\.modifier\(GlassmorphismModifier\(\.primary\)\)',
        '.modifier(GlassmorphismModifier(style: .primary, cornerRadius: 16))',
        content
    )
    
    print("✅ Fixed GlassmorphismModifier usage")
    
    # Fix 2: Remove iOS-specific keyboard and text modifiers
    ios_modifiers_to_remove = [
        r'\.keyboardType\([^)]+\)\s*\n',
        r'\.textContentType\([^)]+\)\s*\n', 
        r'\.autocapitalization\([^)]+\)\s*\n'
    ]
    
    for pattern in ios_modifiers_to_remove:
        content = re.sub(pattern, '', content, flags=re.MULTILINE)
    
    print("✅ Removed iOS-specific modifiers (.keyboardType, .textContentType, .autocapitalization)")
    
    # Write the updated LoginView.swift file
    with open(loginview_file, 'w') as f:
        f.write(content)
    
    print("✅ Updated LoginView.swift file")
    print("🎉 LOGINVIEW.SWIFT FIXED FOR MACOS COMPATIBILITY!")
    
    return True

if __name__ == "__main__":
    success = fix_loginview_macos_compatibility()
    exit(0 if success else 1)