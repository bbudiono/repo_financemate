#!/bin/bash

# Reset FinanceMate Authentication State
# This script clears all authentication data to show SSO buttons again

echo "🔧 Resetting FinanceMate Authentication State"
echo "============================================="

# Kill any running FinanceMate processes
echo "📱 Stopping FinanceMate application..."
killall FinanceMate 2>/dev/null || true

# Clear UserDefaults authentication data
echo "🔒 Clearing authentication session data..."
defaults delete com.ablankcanvas.financemate authenticated_user_id 2>/dev/null || true
defaults delete com.ablankcanvas.financemate authenticated_user_email 2>/dev/null || true  
defaults delete com.ablankcanvas.financemate authenticated_user_login_time 2>/dev/null || true
defaults delete com.ablankcanvas.financemate authentication_provider 2>/dev/null || true
defaults delete com.ablankcanvas.financemate is_temporary_bypass 2>/dev/null || true

# Clear debug/test settings
echo "🧪 Clearing test/debug session data..."
defaults delete com.ablankcanvas.financemate DisableAnimations 2>/dev/null || true
defaults delete com.ablankcanvas.financemate HeadlessMode 2>/dev/null || true

# Clear any guest mode data
echo "🚫 Clearing guest mode data..."  
defaults delete com.ablankcanvas.financemate guest_mode_active 2>/dev/null || true
defaults delete com.ablankcanvas.financemate skip_authentication 2>/dev/null || true

echo ""
echo "✅ Authentication state reset complete!"
echo ""
echo "🎯 Next steps:"
echo "   1. Launch FinanceMate application"
echo "   2. You should now see the SSO authentication screen with:"
echo "      • Apple 'Sign in with Apple' button (black style)"
echo "      • Google 'Continue with Google' button (gray style)"
echo "   3. Both buttons should be functional and visible"
echo ""
echo "📱 Launching FinanceMate now..."

# Launch the application
sleep 2
open -a FinanceMate

echo "🔍 If you still don't see SSO buttons, the app may be running in headless mode"
echo "   Check that no environment variables like HEADLESS_MODE=1 are set"