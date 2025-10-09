# Navigation & Build Troubleshooting Documentation

**Project**: FinanceMate
**Type**: Build System Navigation
**Framework**: Xcode Build System + Swift Compilation
**Last Updated**: 2025-10-06
**Total Failure Types**: 10
**Status**: [X] Complete / [X] Validated

---

## 1. Build System Navigation Structure

### Primary Build Flows
| Build Type | Command | Scheme | Configuration | Purpose | Output |
|------------|---------|--------|--------------|---------|--------|
| Development Build | xcodebuild build | FinanceMate-Sandbox | Debug | Feature development | Local app |
| Production Build | xcodebuild build | FinanceMate | Debug | Production testing | Signed app |
| Test Build | xcodebuild test | FinanceMate | Debug | Unit/E2E testing | Test results |
| Archive Build | xcodebuild archive | FinanceMate | Release | App Store submission | .xcarchive |

### Build Target Navigation
| Target | Purpose | Build Order | Dependencies | Output Location |
|--------|---------|------------|-------------|----------------|
| FinanceMate | Main application | 1 | Core Data, Models, Services | DerivedData/Build/Products |
| FinanceMateTests | Unit testing | 2 | FinanceMate | DerivedData/Build/Products |
| FinanceMateUITests | UI testing | 3 | FinanceMate | DerivedData/Build/Products |

---

## 2. Error Resolution Navigation Flows

### Flow 1: Code Signing Error Resolution
```
Step 1: Build Failure → "Code signing error" detected
  ↓ Check Xcode project settings
Step 2: FinanceMate Target → Signing & Capabilities
  ↓ Verify Team assignment
Step 3: Select Apple Developer Team
  ↓ Enable "Automatically manage signing"
Step 4: Clean and rebuild
  ✅ Code Signing Resolved (BF-001)
```

### Flow 2: Core Data Model Resolution
```
Step 1: Runtime Crash → "NSManagedObjectModel not found"
  ↓ Check Build Phases configuration
Step 2: Target → Build Phases → Compile Sources
  ↓ Verify .xcdatamodeld inclusion
Step 3: Add FinanceMateModel.xcdatamodeld to Compile Sources
  ↓ Clean and rebuild
Step 4: Test Core Data functionality
  ✅ Core Data Integration Resolved (BF-002)
```

### Flow 3: SwiftUI Preview Resolution
```
Step 1: Preview Error → "Failed to load bundle"
  ↓ Check scheme configuration
Step 2: FinanceMate-Sandbox Scheme → Edit Scheme
  ↓ Set Build Configuration to Debug
Step 3: Verify bundle identifier matches entitlements
  ↓ Restart Xcode preview
Step 4: Test SwiftUI previews
  ✅ Preview System Resolved (BF-003)
```

### Flow 4: Package Resolution Error Recovery
```
Step 1: Build Failure → "Failed to resolve package dependencies"
  ↓ Check network connectivity
Step 2: Clear package cache and derived data
  ↓ Reset Package Caches in Xcode
Step 3: File → Packages → Reset Package Caches
  ↓ Retry package resolution
Step 4: Rebuild project
  ✅ Package Dependencies Resolved (BF-004)
```

---

## 3. Development Environment Navigation

### Xcode Project Structure Navigation
```
FinanceMate.xcodeproj
├── Project Navigator
│   ├── FinanceMate (Main Target)
│   │   ├── Build Settings
│   │   ├── Build Phases
│   │   └── Build Rules
│   ├── FinanceMateTests (Test Target)
│   ├── FinanceMateUITests (UI Test Target)
│   └── Products
└── Scheme Management
    ├── FinanceMate (Production)
    ├── FinanceMate-Sandbox (Development)
    └── Test Schemes
```

### Build Configuration Navigation
| Configuration | Purpose | Build Settings | Code Signing | Optimization |
|--------------|---------|----------------|--------------|--------------|
| Debug | Development | No optimization | Development team | Fast build |
| Release | Production | Full optimization | Distribution cert | Optimized |
| Testing | Test execution | Debug symbols | Development team | Test-friendly |

---

## 4. Debug Navigation Paths

### Log File Navigation
| Log Type | Location | Access Method | Purpose |
|----------|----------|---------------|---------|
| Build Logs | Xcode → Report Navigator → Build | Xcode UI | Build errors/warnings |
| Test Logs | Xcode → Report Navigator → Test | Xcode UI | Test failures |
| Console Logs | Console.app → FinanceMate process | Console.app | Runtime errors |
| Crash Reports | ~/Library/Logs/DiagnosticReports/ | Finder | Crash analysis |

### Debug Tool Navigation
```
Debug Workflow:
1. Build Failure → Identify error type
2. Error Code Lookup → Find BF-ID in documentation
3. Follow Resolution Flow → Step-by-step fix
4. Validate Fix → Rebuild and test
5. Document Success → Update build log if needed
```

---

## 5. Test System Navigation

### Test Execution Flow
```
Test Execution Navigation:
Step 1: Choose Test Target
  ↓ Unit Tests (FinanceMateTests)
  ↓ UI Tests (FinanceMateUITests)
  ↓ E2E Tests (test_financemate_complete_e2e.py)
Step 2: Select Test Scheme
  ↓ FinanceMate (Production tests)
  ↓ FinanceMate-Sandbox (Development tests)
Step 3: Configure Test Destination
  ↓ macOS (Primary platform)
  ↓ iOS (Future platform)
Step 4: Execute Tests
  ↓ Monitor test progress
  ↓ Analyze test results
Step 5: Review Test Reports
  ✅ Testing Complete
```

### Test Failure Resolution Navigation
| Failure Type | Detection | Resolution Path | Validation |
|--------------|-----------|-----------------|------------|
| Compilation Error | Build failure | Fix syntax/code errors | Rebuild |
| Test Logic Error | Test failure | Debug test code | Re-run test |
| Environment Error | Setup failure | Check test environment | Re-setup |
| Dependency Error | Import failure | Fix module imports | Rebuild |

---

## 6. Integration Points Navigation

### API Integration Testing Flow
```
API Integration Navigation:
1. Gmail API Test → OAuth flow validation
   ↓ Check Google Console configuration
   ↓ Verify redirect URIs
   ↓ Test token refresh
   ✅ Gmail API Integration Complete

2. Anthropic API Test → Claude integration validation
   ↓ Check API key configuration
   ↓ Test context building
   ↓ Verify response parsing
   ✅ AI Assistant Integration Complete

3. Core Data Test → Persistence validation
   ↓ Test model loading
   ↓ Verify CRUD operations
   ↓ Check data migration
   ✅ Data Persistence Complete
```

### Build Validation Checkpoints
| Checkpoint | Validation Method | Success Criteria | Failure Action |
|------------|-------------------|------------------|----------------|
| Code Compilation | xcodebuild build | Zero compile errors | Fix syntax errors |
| Unit Tests | xcodebuild test | 100% test passage | Debug failing tests |
| UI Tests | XCUITest execution | All UI scenarios pass | Fix UI test code |
| Integration Tests | API endpoint testing | All integrations functional | Fix API integration |
| Archive Build | xcodebuild archive | Successful archive creation | Fix archive issues |

---

## 7. Troubleshooting Command Navigation

### Essential Debug Commands
```bash
# Navigation to Project Directory
cd /path/to/FinanceMate/_macOS

# Clean Build Navigation
xcodebuild clean -project FinanceMate.xcodeproj -scheme FinanceMate

# Build Navigation (Development)
xcodebuild build -project FinanceMate.xcodeproj -scheme FinanceMate-Sandbox -configuration Debug

# Build Navigation (Production)
xcodebuild build -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug

# Test Execution Navigation
xcodebuild test -project FinanceMate.xcodeproj -scheme FinanceMate -destination 'platform=macOS'

# Archive Navigation
xcodebuild archive -project FinanceMate.xcodeproj -scheme FinanceMate -archivePath ./FinanceMate.xcarchive

# Signing Configuration Check
xcodebuild -showBuildSettings -project FinanceMate.xcodeproj -scheme FinanceMate | grep -i sign
```

### Environment Setup Navigation
```bash
# Environment Variables Check
echo $ANTHROPIC_API_KEY
echo $GOOGLE_OAUTH_CLIENT_ID

# Derived Data Navigation
open ~/Library/Developer/Xcode/DerivedData

# Crash Reports Navigation
open ~/Library/Logs/DiagnosticReports/

# Console Application Navigation
open -a Console
```

---

## 8. Recovery Workflow Navigation

### Complete Recovery Flow
```
Crisis Recovery Navigation:
1. Complete Failure Detection
   ↓ Identify all build/test failures
2. Systematic Documentation Review
   ↓ Check relevant BF-ID entries
3. Step-by-Step Resolution Execution
   ↓ Follow documented resolution flows
4. Validation at Each Step
   ↓ Verify fix before proceeding
5. Full System Test
   ↓ Execute complete test suite
6. Documentation Update
   ↓ Record new failure patterns
   ✅ System Recovery Complete
```

### Partial Recovery Strategies
| Issue Type | Quick Fix Strategy | Complete Resolution Strategy |
|------------|-------------------|----------------------------|
| Build Error | Fix immediate syntax error | Review entire build configuration |
| Test Failure | Fix specific test case | Review test architecture |
| API Error | Check API credentials | Review integration architecture |
| Performance Issue | Optimize specific code | Review overall performance strategy |

---

## 9. Prevention Navigation

### Pre-Build Checklist Navigation
```
Pre-Build Validation Flow:
1. Environment Check
   ↓ Verify .env file configuration
   ↓ Check network connectivity
   ↓ Confirm Xcode version compatibility
2. Project Structure Check
   ↓ Verify all files present
   ↓ Check target membership
   ↓ Validate build phases
3. Dependency Validation
   ↓ Check package references
   ↓ Verify framework linking
   ↓ Confirm resource inclusion
4. Configuration Review
   ↓ Check build settings
   ↓ Verify signing configuration
   ↓ Validate scheme settings
   ✅ Ready to Build
```

### Pre-Test Checklist Navigation
```
Pre-Test Validation Flow:
1. Test Environment Setup
   ↓ Clean build completed
   ↓ Test data available
   ↓ External services accessible
2. Test Configuration Check
   ↓ Test schemes properly configured
   ↓ Test destinations available
   ↓ Test data initialized
3. Test Execution Readiness
   ↓ All tests compile
   ↓ Test dependencies resolved
   ↓ Test environment stable
   ✅ Ready to Test
```

---

## 10. Navigation Component Mapping

### File System Navigation
```
Project Root Navigation:
/Users/bernhardbudiono/.../repo_financemate/
├── _macOS/
│   ├── FinanceMate.xcodeproj
│   ├── FinanceMate/
│   │   ├── App/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Models/
│   │   └── Services/
│   ├── FinanceMateTests/
│   └── FinanceMateUITests/
├── docs/
│   ├── BUILD_FAILURES.md
│   ├── NAVIGATION_BUILD_FAILURES.md
│   └── API.md
├── tests/
└── scripts/
```

### Build Output Navigation
```
Build Output Locations:
DerivedData/
├── Build/
│   ├── Products/
│   │   ├── Debug/
│   │   │   ├── FinanceMate.app
│   │   │   ├── FinanceMateTests.xctest
│   │   │   └── FinanceMateUITests.xctest
│   │   └── Release/
│   └── Intermediates/
├── Logs/
│   ├── Build/
│   ├── Test/
│   └── Archive/
└── Archives/
    └── FinanceMate.xcarchive/
```

---

## 11. Validation Checklist

Build Navigation Documentation Completeness:

- [x] All build types documented (4/4)
- [x] Build target navigation explained (3/3)
- [x] Error resolution flows documented (4/4)
- [x] Debug navigation paths defined (2/2)
- [x] Test system navigation mapped (2/2)
- [x] Integration point flows documented (3/3)
- [x] Command navigation provided (2/2)
- [x] Recovery workflows defined (2/2)
- [x] Prevention navigation established (2/2)
- [x] File system navigation mapped (2/2)
- [x] Component hierarchy documented
- [x] Last updated date current (2025-10-06)

**Completeness**: 12/12 items (100%)

---

## 12. Maintenance

### When to Update This Document
✅ New build failure pattern identified
✅ New resolution workflow developed
✅ Build system configuration changed
✅ Test system architecture modified
✅ New integration points added

### Auto-Update Commands
```bash
# Validate build failure documentation
python3 ~/.claude/hooks/build_failure_validator.py docs/BUILD_FAILURES.md

# Check navigation structure accuracy
python3 ~/.claude/hooks/navigation_structure_validator.py docs/NAVIGATION_BUILD_FAILURES.md build

# Update failure patterns from logs
python3 ~/.claude/scripts/analyze_build_logs.py ~/Library/Developer/Xcode/DerivedData/
```

### Review Schedule
- **After new failures**: Immediate update required
- **Monthly**: Verify resolution accuracy
- **Before deployment**: Mandatory validation

---

**Document Version**: 1.0
**Last Modified**: 2025-10-06
**Next Review**: 2025-11-06