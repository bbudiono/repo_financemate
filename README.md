# FinanceMate

A professional macOS financial management application built with SwiftUI, featuring AI-powered document processing and multi-LLM agent coordination.

## Project Status

- **Production Build**: ✅ Working
- **Sandbox Build**: 🔧 In Progress (fixing compilation errors)
- **TestFlight Ready**: 70% Complete

## Quick Start

### Prerequisites
- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

### Build Instructions

1. **Production Build**
```bash
cd _macOS/FinanceMate
xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate build
```

2. **Sandbox Build** (Currently being fixed)
```bash
cd _macOS/FinanceMate-Sandbox
xcodebuild -project FinanceMate-Sandbox.xcodeproj -scheme FinanceMate-Sandbox build
```

## Architecture

### Core Components
- **AuthenticationService**: Google SSO, Apple Sign-In
- **RealLLMAPIService**: Multi-provider AI integration
- **DocumentProcessingService**: OCR and financial data extraction
- **MLACS**: Multi-LLM Agent Coordination System

### Development Workflow
This project follows a **Sandbox-First TDD** approach:
1. All features developed in Sandbox environment first
2. Comprehensive testing before production migration
3. Only permitted difference: "Sandbox" watermark

## Testing

### E2E Test Implementation ✅

The project includes a comprehensive E2E testing framework:

- **10 Test Suites** covering performance, stability, UI automation, and more
- **40+ Tests** with 100% pass rate
- **Screenshot Capture** during UI automation tests
- **CI/CD Integration** via GitHub Actions

#### Running Tests

```bash
# Quick headless tests
cd _macOS/FinanceMate
swift Scripts/run_headless_tests.swift

# Full E2E tests (requires Xcode)
bash Scripts/run_e2e_tests.sh
```

See [docs/E2E_TEST_IMPLEMENTATION.md](docs/E2E_TEST_IMPLEMENTATION.md) for complete details.

## Documentation

- [CLAUDE.md](CLAUDE.md) - AI assistant guide
- [docs/BLUEPRINT.md](docs/BLUEPRINT.md) - Architecture details
- [docs/TASKS.md](docs/TASKS.md) - Current task tracking
- [docs/E2E_TEST_IMPLEMENTATION.md](docs/E2E_TEST_IMPLEMENTATION.md) - E2E testing guide
- [.cursorrules](.cursorrules) - Development rules

## Current Focus

Fixing sandbox build errors and aligning environments for TestFlight submission.

## License

Proprietary - All rights reserved