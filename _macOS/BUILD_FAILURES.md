# Build Failure Troubleshooting Guide

**Purpose**: This document provides troubleshooting guidance for common build failures in FinanceMate.

**Last Updated**: 2025-10-09

## Common Build Issues

### 1. Xcode Build Failures

#### Issue: "Cannot find type 'XXX' in scope"
**Solution**:
- Check imports in affected files
- Verify file references in Xcode project
- Clean build folder: `Cmd+Shift+K`

#### Issue: "Code signing error"
**Solution**:
- Verify Apple Developer account is configured
- Check bundle identifier matches provisioning profile
- Ensure "Sign in with Apple" capability is enabled

### 2. Test Failures

#### Issue: Unit tests failing
**Solution**:
- Check test target dependencies
- Verify test files are included in test target
- Run tests individually to identify specific failures

#### Issue: E2E tests failing
**Solution**:
- Verify application builds successfully
- Check test environment setup
- Review test data requirements

### 3. Dependency Issues

#### Issue: Missing framework or library
**Solution**:
- Check framework search paths in build settings
- Verify required system frameworks are linked
- Update package dependencies if using Swift Package Manager

## Debugging Commands

```bash
# Clean build folder
xcodebuild clean -project FinanceMate.xcodeproj -scheme FinanceMate

# Build with detailed output
xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate build -verbose

# Run specific test
xcodebuild test -project FinanceMate.xcodeproj -scheme FinanceMate -only-testing:FinanceMateTests/TestClass/testMethod

# Check project structure
xcodebuild -list -project FinanceMate.xcodeproj
```

## Getting Help

1. Check the console output for specific error messages
2. Review the development log in `docs/DEVELOPMENT_LOG.md`
3. Consult the project BLUEPRINT.md for requirements
4. Check git history for recent changes that may have introduced issues

## Prevention

- Always run tests before committing changes
- Follow TDD methodology (write tests first)
- Keep Xcode and dependencies up to date
- Use version control to track changes

---

*This document should be updated as new build issues are discovered and resolved.*