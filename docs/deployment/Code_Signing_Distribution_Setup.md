# Code Signing & Distribution Setup - FinanceMate

## Current Certificate Status Assessment

### Available Certificates ✅ VERIFIED
```
1) A8828E2953E86E04487E6F43ED714CC07A4C1525 "Apple Development: BERNHARD JOSHUA BUDIONO (ZK86L2658W)"
2) 6C7570D1F353AB4F226F37264B991BB1861B738A "Apple Development: bernhardbudiono@gmail.com (Y8ZX65UJYK)"
```

**Development Certificates:** ✅ 2 Available  
**Distribution Certificates:** ❌ **REQUIRED FOR TESTFLIGHT**  
**Team ID:** 7KV34995HH (Configured in project)  

---

## Phase 1: Apple Distribution Certificate Setup

### Required Actions for TestFlight Distribution

#### 1. Generate Certificate Signing Request (CSR)
```bash
# Using Keychain Access (Recommended)
# 1. Open Keychain Access
# 2. Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority
# 3. Fill in the following information:
#    - User Email Address: bernhardbudiono@gmail.com
#    - Common Name: BERNHARD JOSHUA BUDIONO
#    - CA Email Address: Leave empty
#    - Request is: Saved to disk
#    - Let me specify key pair information: CHECKED
# 4. Key Size: 2048 bits
# 5. Algorithm: RSA
# 6. Save as: FinanceMate_Distribution_CSR.certSigningRequest
```

#### 2. Apple Developer Portal Certificate Creation
**URL:** https://developer.apple.com/account/resources/certificates/list

**Steps:**
1. **Login:** Apple Developer account (bernhardbudiono@gmail.com)
2. **Navigate:** Certificates, Identifiers & Profiles → Certificates
3. **Create:** Click "+" to create new certificate
4. **Type:** "Apple Distribution" (for App Store distribution)
5. **Upload CSR:** Upload the generated FinanceMate_Distribution_CSR.certSigningRequest
6. **Download:** Download the generated certificate (.cer file)
7. **Install:** Double-click to install in Keychain Access

#### 3. Verification Commands
```bash
# Verify certificate installation
security find-identity -v -p codesigning | grep "Apple Distribution"

# Expected output after installation:
# X) [CERTIFICATE_HASH] "Apple Distribution: BERNHARD JOSHUA BUDIONO (7KV34995HH)"
```

---

## Phase 2: App Store Distribution Provisioning Profile

### Bundle Identifier Verification
**Current Bundle ID:** `com.ablankcanvas.financemate`  
**Status:** ✅ Configured in FinanceMate.xcodeproj  
**Team ID:** 7KV34995HH  

### Provisioning Profile Creation
**URL:** https://developer.apple.com/account/resources/profiles/list

**Steps:**
1. **Navigate:** Certificates, Identifiers & Profiles → Profiles
2. **Create:** Click "+" to create new profile
3. **Type:** "App Store" distribution profile
4. **App ID:** Select "com.ablankcanvas.financemate"
5. **Certificates:** Select the Apple Distribution certificate created above
6. **Name:** "FinanceMate App Store Distribution"
7. **Download:** Download the .mobileprovision file
8. **Install:** Double-click to install or drag to Xcode

### Profile Installation Verification
```bash
# List installed provisioning profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# Verify profile in Xcode
# Xcode → Preferences → Accounts → [Your Team] → Manage Certificates
```

---

## Phase 3: Xcode Project Configuration for Distribution

### Build Settings Modification
**Target:** FinanceMate  
**Configuration:** Release  

#### Code Signing Settings
```yaml
CODE_SIGN_STYLE: "Manual"
CODE_SIGN_IDENTITY: "Apple Distribution"
CODE_SIGN_IDENTITY[sdk=macosx*]: "Apple Distribution"
PROVISIONING_PROFILE_SPECIFIER: "FinanceMate App Store Distribution"
DEVELOPMENT_TEAM: "7KV34995HH"
```

#### Distribution Build Settings
```yaml
# Version Information
MARKETING_VERSION: "1.0.0"
CURRENT_PROJECT_VERSION: "1"

# Build Optimization
ENABLE_BITCODE: "NO"
SKIP_INSTALL: "NO"
COPY_PHASE_STRIP: "YES"
DEBUG_INFORMATION_FORMAT: "dwarf-with-dsym"
VALIDATE_PRODUCT: "YES"

# Deployment Settings
MACOSX_DEPLOYMENT_TARGET: "13.0"
SUPPORTS_MACCATALYST: "NO"
```

### Release Scheme Configuration
```xml
<!-- FinanceMate Scheme → Edit Scheme → Archive -->
<ArchiveAction>
  <BuildConfiguration>Release</BuildConfiguration>
  <RevealArchiveInOrganizer>YES</RevealArchiveInOrganizer>
  <CustomArchiveName>FinanceMate</CustomArchiveName>
</ArchiveAction>
```

---

## Phase 4: Distribution Build Process

### Pre-Build Verification Checklist
- [ ] **Distribution Certificate:** Apple Distribution certificate installed
- [ ] **Provisioning Profile:** App Store distribution profile installed  
- [ ] **Bundle ID:** com.ablankcanvas.financemate configured correctly
- [ ] **Version Numbers:** MARKETING_VERSION and CURRENT_PROJECT_VERSION set
- [ ] **Code Signing:** Manual signing with correct certificate selected
- [ ] **Entitlements:** FinanceMate.entitlements properly configured

### Archive Command (Production Ready)
```bash
# Clean build directory
cd "_macOS/FinanceMate"
xcodebuild clean -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Release

# Create archive for distribution
xcodebuild archive \
    -project FinanceMate.xcodeproj \
    -scheme FinanceMate \
    -configuration Release \
    -destination "generic/platform=macOS" \
    -archivePath "./FinanceMate.xcarchive" \
    -allowProvisioningUpdates

# Verify archive creation
ls -la FinanceMate.xcarchive/
```

### Archive Validation
```bash
# Validate archive before upload
xcodebuild -validateArchive \
    -archivePath "./FinanceMate.xcarchive" \
    -destination generic/platform=macOS

# Check for common issues
codesign --verify --deep --strict FinanceMate.xcarchive/Products/Applications/FinanceMate.app
```

---

## Phase 5: App Store Connect Upload

### Method 1: Xcode Organizer (Recommended)
```
1. Open Xcode → Window → Organizer
2. Select "Archives" tab
3. Find FinanceMate.xcarchive
4. Click "Distribute App"
5. Select "App Store Connect"
6. Choose "Upload"
7. Select distribution certificate and provisioning profile
8. Review content and upload
```

### Method 2: Command Line (Alternative)
```bash
# Export for App Store
xcodebuild -exportArchive \
    -archivePath "./FinanceMate.xcarchive" \
    -exportPath "./FinanceMate_Export" \
    -exportOptionsPlist ExportOptions.plist

# Upload to App Store Connect
xcrun altool --upload-app \
    --type osx \
    --file "./FinanceMate_Export/FinanceMate.pkg" \
    --username "bernhardbudiono@gmail.com" \
    --password "@keychain:Application Loader: bernhardbudiono@gmail.com"
```

### ExportOptions.plist Template
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>destination</key>
    <string>upload</string>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>7KV34995HH</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

---

## Phase 6: Troubleshooting Common Issues

### Certificate Issues
```bash
# Problem: "No matching provisioning profiles found"
# Solution: Verify bundle ID matches provisioning profile

# Check bundle ID in project
grep -r "PRODUCT_BUNDLE_IDENTIFIER" FinanceMate.xcodeproj/project.pbxproj

# Problem: "Certificate not trusted"
# Solution: Download and install Apple intermediate certificates
curl -O https://developer.apple.com/certificationauthority/AppleWWDRCA.cer
open AppleWWDRCA.cer
```

### Code Signing Issues
```bash
# Problem: "Code signing failed"
# Solution: Check code signing settings

# Verify code signing identity
codesign -dv --verbose=4 /path/to/FinanceMate.app

# Problem: "Provisioning profile doesn't match"
# Solution: Regenerate provisioning profile with correct certificate
```

### Archive Issues
```bash
# Problem: "Archive failed to create"
# Solution: Clean derived data and retry

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/FinanceMate-*

# Problem: "Generic iOS Device not available"
# Solution: Ensure correct destination platform
```

---

## Phase 7: Post-Upload Verification

### App Store Connect Verification
1. **Login:** https://appstoreconnect.apple.com
2. **Navigate:** My Apps → FinanceMate
3. **Check Build:** TestFlight → iOS Builds (should show processing)
4. **Wait for Processing:** Usually 5-30 minutes for macOS apps

### Processing Status Monitoring
```yaml
Processing States:
  - "Processing": Archive is being processed by Apple
  - "Ready to Submit": Build is ready for TestFlight or App Store review
  - "Invalid Binary": Build rejected, check email for details
  - "Missing Compliance": Export compliance information needed
```

### Email Notifications
Monitor email (bernhardbudiono@gmail.com) for:
- Processing completion notifications
- Missing information requests
- Export compliance requirements
- Beta testing invitation confirmations

---

## Phase 8: Security and Compliance

### Entitlements Verification
**File:** FinanceMate.entitlements
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.authentication-services.autofill-credential-provider</key>
    <false/>
    <key>com.apple.security.cs.allow-jit</key>
    <false/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <false/>
    <key>com.apple.security.device.audio-input</key>
    <false/>
    <key>com.apple.security.device.camera</key>
    <false/>
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <false/>
</dict>
</plist>
```

### Export Compliance
**Encryption Usage:** Yes (uses HTTPS and local encryption)  
**Compliance Required:** Export administration regulations compliance  
**Documentation:** Required for App Store submission  

```yaml
Encryption Details:
  - HTTPS for network communications
  - AES-GCM for local data encryption
  - OAuth2 token encryption
  - Standard cryptographic protocols only
```

---

## Timeline and Next Steps

### Immediate Actions (Next 24-48 hours)
1. **Generate CSR:** Create certificate signing request
2. **Request Certificate:** Apple Distribution certificate via Developer Portal
3. **Create Profile:** App Store distribution provisioning profile
4. **Configure Xcode:** Update project settings for distribution

### Short-term Actions (Next 3-7 days)
1. **Test Archive:** Create and validate distribution archive
2. **Upload Build:** Submit to App Store Connect
3. **Monitor Processing:** Verify successful processing
4. **Prepare TestFlight:** Set up internal testing group

### Success Metrics
```yaml
Technical Targets:
  Archive_Success: "Clean archive creation with no errors"
  Upload_Success: "Successful App Store Connect upload"
  Processing_Success: "Build processes without rejection"
  TestFlight_Ready: "Available for internal testing"

Timeline Targets:
  Certificate_Setup: "24-48 hours"
  First_Upload: "3-7 days"
  TestFlight_Beta: "7-14 days"
  App_Store_Submission: "14-30 days"
```

---

**STATUS:** 🔄 **READY TO BEGIN - DISTRIBUTION CERTIFICATE REQUIRED**  
**NEXT CRITICAL ACTION:** Generate CSR and request Apple Distribution certificate  
**TIMELINE:** 24-48 hours for certificate setup, 3-7 days for first TestFlight upload  
**DEPENDENCY:** Apple Developer Portal access and certificate approval process