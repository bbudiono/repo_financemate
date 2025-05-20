# XCODE_TROUBLESHOOTING.md

## Common Xcode/macOS Build & Run Issues

| Issue | Symptom | Solution | Related Doc |
|-------|---------|----------|-------------|
| Code signing error | Build fails with signing error | Check automatic signing, entitlements, and Apple ID in Xcode | XCODE_BUILD_CONFIGURATION.md |
| App not launching | App builds but does not open | Check build output path, run from Products/Debug | BUILDING.md |
| Asset catalog error | Missing icons/colors | Verify asset catalog files exist and are referenced in project | XCODE_BUILD_GUIDE.md | 