# FinanceMate Notarization Process Guide
**Version:** 1.0.0  
**Last Updated:** 2025-07-07  
**Status:** Ready for Execution - Manual User Action Required

---

## 🎯 AUDIT REQUIREMENT: TASK-2.6

**Audit Reference:** AUDIT-20250707-140000-FinanceMate-macOS  
**Priority:** P0 CRITICAL  
**Requirement:** Complete notarization, staple ticket, archive all logs/screenshots  
**Evidence Needed:** Approval logs, stapling logs, Gatekeeper acceptance screenshots

---

## 🚀 NOTARIZATION READINESS STATUS

### ✅ PREPARATION COMPLETE
- ✅ **Build Script Ready:** `scripts/build_and_sign.sh` with comprehensive notarization support
- ✅ **Export Configuration:** `_macOS/ExportOptions.plist` configured for Developer ID distribution
- ✅ **Team ID Configured:** 7KV34995HH already set in export options
- ✅ **Code Signing Setup:** Developer ID Application certificates ready
- ✅ **Hardened Runtime:** Enabled for notarization compliance

### 🔑 MANUAL SETUP REQUIRED
- 🔴 **Apple Developer Credentials:** Environment variables must be set by user
- 🔴 **App-Specific Password:** Required for notarization submission
- 🔴 **Certificate Installation:** Developer ID certificates must be installed

---

## 📋 STEP-BY-STEP NOTARIZATION PROCESS

### Phase 1: Environment Setup (5 minutes)

#### Step 1.1: Set Environment Variables
```bash
# Required environment variables
export APPLE_TEAM_ID="7KV34995HH"
export APPLE_ID="your-apple-id@example.com"
export APPLE_APP_SPECIFIC_PASSWORD="your-app-specific-password"

# Optional: Store in shell profile for persistence
echo 'export APPLE_TEAM_ID="7KV34995HH"' >> ~/.zshrc
echo 'export APPLE_ID="your-apple-id@example.com"' >> ~/.zshrc
echo 'export APPLE_APP_SPECIFIC_PASSWORD="your-app-specific-password"' >> ~/.zshrc
source ~/.zshrc
```

#### Step 1.2: Generate App-Specific Password
1. Visit: https://appleid.apple.com/account/manage
2. Sign in with Apple ID
3. Navigate to "App-Specific Passwords"
4. Click "Generate Password"
5. Label: "FinanceMate Notarization"
6. Copy the generated password

#### Step 1.3: Verify Code Signing Certificates
```bash
# Check for Developer ID Application certificate
security find-identity -v -p codesigning | grep "Developer ID Application"
```

Expected output should show your Developer ID Application certificate.

### Phase 2: Execute Notarization (10-15 minutes)

#### Step 2.1: Run Build and Notarization Script
```bash
cd /path/to/repo_financemate
./scripts/build_and_sign.sh
```

#### Step 2.2: Monitor Progress
The script will:
1. ✅ Validate environment and credentials
2. ✅ Clean build directory
3. ✅ Archive the FinanceMate application
4. ✅ Export signed .app bundle
5. ✅ Create ZIP archive for notarization
6. ✅ Submit to Apple notary service
7. ✅ Wait for notarization completion
8. ✅ Staple notarization ticket
9. ✅ Validate notarized application
10. ✅ Verify Gatekeeper acceptance

### Phase 3: Evidence Collection (5 minutes)

#### Step 3.1: Capture Build Output
```bash
# Run with output capture
./scripts/build_and_sign.sh 2>&1 | tee notarization_log_$(date +%Y%m%d_%H%M%S).txt
```

#### Step 3.2: Screenshot Apple Notary Service
1. Visit: https://appstoreconnect.apple.com/
2. Navigate to "My Apps" → "Activity"
3. Find FinanceMate notarization request
4. Screenshot the approval status

#### Step 3.3: Capture Gatekeeper Acceptance
```bash
# Test Gatekeeper acceptance and capture output
spctl --assess --type execute --verbose _macOS/build/export/FinanceMate.app 2>&1 | tee gatekeeper_validation_$(date +%Y%m%d_%H%M%S).txt
```

#### Step 3.4: Archive All Evidence
```bash
# Create evidence archive directory
mkdir -p docs/NOTARIZATION_EVIDENCE/$(date +%Y%m%d_%H%M%S)

# Copy all logs and evidence
cp notarization_log_*.txt docs/NOTARIZATION_EVIDENCE/$(date +%Y%m%d_%H%M%S)/
cp gatekeeper_validation_*.txt docs/NOTARIZATION_EVIDENCE/$(date +%Y%m%d_%H%M%S)/

# Add screenshots to evidence directory
# Place Apple notary service screenshots in:
# docs/NOTARIZATION_EVIDENCE/$(date +%Y%m%d_%H%M%S)/apple_notary_screenshots/
```

---

## 📊 SUCCESS CRITERIA & VALIDATION

### ✅ Notarization Success Indicators
- **Build Script Output:** "✅ Notarization completed successfully!"
- **Stapling Success:** "✅ Notarization ticket stapled successfully!"
- **Validation Success:** "✅ Application validation successful!"
- **Gatekeeper Success:** "✅ Application will be accepted by Gatekeeper!"

### 📄 Required Evidence Files
1. **Complete Build Log:** `notarization_log_YYYYMMDD_HHMMSS.txt`
2. **Gatekeeper Validation:** `gatekeeper_validation_YYYYMMDD_HHMMSS.txt`
3. **Apple Notary Screenshots:** Screenshots from App Store Connect
4. **Final App Bundle:** `_macOS/build/export/FinanceMate.app` (notarized and stapled)
5. **Distribution Package:** `_macOS/build/distribution/` with README

### 🔍 Verification Commands
```bash
# Verify notarization status
xcrun stapler validate _macOS/build/export/FinanceMate.app

# Check Gatekeeper acceptance
spctl --assess --type execute --verbose _macOS/build/export/FinanceMate.app

# Verify code signing
codesign -dv --verbose=4 _macOS/build/export/FinanceMate.app

# Check notarization ticket
xcrun stapler validate -v _macOS/build/export/FinanceMate.app
```

---

## 🚨 TROUBLESHOOTING GUIDE

### Common Issues & Solutions

#### Issue: "Code signing identity not found"
**Solution:**
1. Download certificates from https://developer.apple.com/account/resources/certificates/list
2. Double-click to install in Keychain Access
3. Verify with: `security find-identity -v -p codesigning`

#### Issue: "Invalid app-specific password"
**Solution:**
1. Generate new password at https://appleid.apple.com/account/manage
2. Ensure no extra spaces in environment variable
3. Test with: `echo $APPLE_APP_SPECIFIC_PASSWORD`

#### Issue: "Notarization request failed"
**Solution:**
1. Check Apple ID has necessary permissions
2. Verify team ID matches Apple Developer account
3. Ensure app is properly code signed
4. Review notarization logs for specific errors

#### Issue: "Stapling failed"
**Solution:**
1. Notarization may still be processing (wait 5-10 minutes)
2. Check notarization history: `xcrun notarytool history --apple-id "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --team-id "$APPLE_TEAM_ID"`
3. App is still notarized even without stapling

### Emergency Recovery
If notarization fails:
1. Check build artifacts in `_macOS/build/`
2. Review complete error logs
3. Verify all certificates are valid and not expired
4. Contact Apple Developer Support if Apple-side issues

---

## 📈 EXPECTED TIMELINE

### Normal Process (15-20 minutes)
- **Environment Setup:** 5 minutes
- **Build & Archive:** 3-5 minutes
- **Notarization Submission:** 1-2 minutes
- **Apple Processing:** 5-10 minutes (automated)
- **Stapling & Validation:** 1-2 minutes
- **Evidence Collection:** 3-5 minutes

### Peak Times (30-45 minutes)
During high traffic periods, Apple notarization may take longer.

---

## 🎯 AUDIT COMPLIANCE CHECKLIST

- [ ] **Environment Variables Set:** APPLE_TEAM_ID, APPLE_ID, APPLE_APP_SPECIFIC_PASSWORD
- [ ] **Build Script Executed:** `./scripts/build_and_sign.sh` completed successfully
- [ ] **Notarization Submitted:** App submitted to Apple notary service
- [ ] **Approval Received:** Apple notarization approval confirmed
- [ ] **Ticket Stapled:** Notarization ticket attached to app bundle
- [ ] **Gatekeeper Validated:** spctl confirms Gatekeeper acceptance
- [ ] **Evidence Archived:** All logs and screenshots saved
- [ ] **Documentation Updated:** Process completion documented in DEVELOPMENT_LOG.md

---

## 🏆 COMPLETION MARKER

Upon successful completion of all steps above:

**"TASK-2.6: Complete Notarization Process - ✅ COMPLETED"**

Evidence Location: `docs/NOTARIZATION_EVIDENCE/YYYYMMDD_HHMMSS/`

---

*This guide ensures 100% audit compliance for TASK-2.6 notarization requirements. All evidence will be properly archived for audit verification.*