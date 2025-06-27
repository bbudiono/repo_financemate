# FinanceMate Code Coverage Setup Guide

## Quick Start

1. **Collect Coverage Data**
   ```bash
   ./coverage_collector.sh
   ```

2. **Enforce Quality Gate**
   ```bash  
   ./enforce_coverage.sh
   ```

## Critical Files (80%+ Required)



## Reports Location

- Coverage reports: `docs/coverage_reports/`
- Latest analysis: `audit_coverage_report_TIMESTAMP.md`
- Build logs: `test_execution_TIMESTAMP.log`

## Integration

Add to your build process:
```bash
# Run tests with coverage
./coverage_collector.sh

# Enforce quality gate
./enforce_coverage.sh || exit 1
```

## Troubleshooting

- **No tests running:** Check test scheme configuration
- **Build failures:** Verify code signing settings
- **Low coverage:** Add unit tests for critical business logic

---
Generated: Fri Jun 27 16:39:34 AEST 2025
