PROMPT_VERSION: 3.3

# CRITICAL BLOCKER - P1 BUILD STABILITY FAILURE
**Date:** 2025-07-09 21:48 UTC  
**Severity:** P1 CRITICAL  
**Status:** ACTIVE - REQUIRES IMMEDIATE ATTENTION

## ISSUE SUMMARY
Test suite catastrophic failure: 55 out of 80 tests failing with Core Data runtime exceptions.

## TECHNICAL DETAILS

### Error Pattern
```
-[NSEntityDescription objectID]: unrecognized selector sent to instance 0x6000017c9080 (NSInvalidArgumentException)
```

### Affected Test Suites
- **CoreDataTests**: 2/2 tests failing
- **DashboardViewModelTests**: 13/13 tests failing  
- **LineItemViewModelTests**: 25/25 tests failing
- **SplitAllocationViewModelTests**: 32/32 tests failing

### Root Cause Analysis
Core Data test setup appears to be fundamentally broken. The error suggests that `NSEntityDescription` objects are being passed where `NSManagedObject` instances are expected, indicating a problem with:
1. Test persistence context setup
2. Entity relationship configuration
3. Mock data creation in tests

### Contradiction with Audit Report
Previous audit report claimed:
- "100% test pass rate (23/23 tests passing)"
- "All tests passing with zero failures"

**Reality**: 55/80 tests failing (31% success rate)

## IMMEDIATE REMEDIATION PLAN

### Phase 1: Core Data Test Infrastructure (Est. 2-3 hours)
1. **Audit Test Context Setup**
   - Review `PersistenceController.preview` configuration
   - Verify in-memory store configuration for tests
   - Check entity relationship setup

2. **Fix Entity Description Issues**
   - Investigate why `NSEntityDescription` objects are being treated as managed objects
   - Verify programmatic Core Data model creation
   - Fix object instantiation in test cases

3. **Validate Test Data Creation**
   - Review mock data creation patterns
   - Ensure proper entity instantiation in tests
   - Verify relationships are correctly established

### Phase 2: Test Suite Restoration (Est. 1-2 hours)
1. **Systematic Test Fixing**
   - Fix failing tests one by one using TDD approach
   - Verify each test passes individually
   - Ensure no regressions in previously passing tests

2. **Comprehensive Validation**
   - Run full test suite and verify 100% pass rate
   - Verify build stability maintained
   - Update documentation with actual test coverage

### Phase 3: Process Improvement (Est. 1 hour)
1. **Continuous Integration**
   - Implement automated test running on commits
   - Add test coverage validation
   - Prevent regressions in future

## BLOCKING DEPENDENCIES
- **Feature Development**: BLOCKED until tests pass
- **Production Deployment**: BLOCKED until 100% test pass rate achieved
- **Code Reviews**: BLOCKED until build stability restored

## TIMELINE
- **Immediate**: Begin Core Data test infrastructure fix
- **2 hours**: Complete entity description issue resolution
- **4 hours**: Achieve 100% test pass rate
- **5 hours**: Complete validation and documentation update

## ESCALATION CRITERIA
If not resolved within 6 hours, escalate to senior developer for:
- Core Data architecture review
- Alternative testing approach evaluation
- Potential rollback to last known good state

## PREVENTION MEASURES
1. **Mandatory test execution before commits**
2. **Automated CI/CD pipeline with test gates**
3. **Regular test suite health checks**
4. **Proper test coverage reporting**

---

**CREATED BY:** AI Development Agent  
**PRIORITY:** P1 CRITICAL  
**REQUIRES:** Immediate attention before any feature development  
**AUDIT COMPLIANCE:** This blocks all audit requirements until resolved