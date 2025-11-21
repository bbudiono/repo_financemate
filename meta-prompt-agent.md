# FinanceMate Meta-Prompt Directive v4.0.0
**Last Updated**: 2025-11-21T23:30:00+10:00
**Version**: 4.0.0 (Feature #1 Implementation + Repository Cleanup + Asset Generation)
**Phase**: FEATURE DELIVERY MODE (User Approved)
**Status**: Build GREEN → Tests 166/166 (100%) → **EXECUTING: Feature #1 + Cleanup + Assets**

---

## 🎯 MISSION: DELIVER FEATURE #1 + REPOSITORY EXCELLENCE + APP ASSETS

### User Approval ✅
**"yes approved."** - Proceed with Feature #1: Archive Processed Items

### Concurrent Objectives (Next 90-120 Minutes)
1. **Feature #1:** Auto-archive Gmail emails on transaction import (BLUEPRINT Line 136)
2. **Repository Cleanup:** Consolidate docs, delete redundant files, enforce Gold Standard
3. **Asset Generation:** App icons, logos, promo video using Gemini (veo-3+, nano-banana)
4. **Continuous Refactoring:** Identify files >250 lines, duplicate code, KISS violations
5. **Quality Assurance:** Code review >92/100, UX review >90/100, Gemini brutal review

---

## 🚀 FEATURE #1: ARCHIVE PROCESSED ITEMS (ATOMIC TDD)

### BLUEPRINT Requirement (Line 136)
> "The 'Gmail Receipts' table MUST automatically hide or archive items that have been successfully imported into the 'Transactions' table. A toggle or filter must be available for the user to view these archived items."

### Implementation Plan (3 Atomic Tasks)

```xml
<feature id="1" name="Archive_Processed_Items" user_approved="true">
  <task id="1.1" atomic="true" time="30min" priority="P1">
    <objective>Auto-archive Gmail emails when transactions imported</objective>

    <tdd_red>
      <file>FinanceMateTests/GmailArchivingTests.swift</file>
      <test>
        func testEmailAutoArchivedOnImport() {
            // Given: Email with needsReview status
            let mockEmail = GmailEmail(id: "test-1", status: .needsReview)
            viewModel.emails = [mockEmail]
            let extracted = ExtractedTransaction(id: "test-1", merchant: "Test", amount: 100)

            // When: Transaction imported
            viewModel.createTransaction(from: extracted)

            // Then: Email should be archived
            XCTAssertEqual(viewModel.emails.first?.status, .archived)
        }
      </test>
      <expected>FAIL - status still .needsReview</expected>
    </tdd_red>

    <tdd_green>
      <file>GmailViewModel.swift</file>
      <method>createTransaction(from:) - Line ~307</method>
      <minimal_code>
        func createTransaction(from extracted: ExtractedTransaction) {
            if transactionBuilder.createTransaction(from: extracted) != nil {
                archiveEmail(id: extracted.id)  // ← ADD THIS LINE
            } else {
                errorMessage = "Failed to save transaction"
            }
        }
      </minimal_code>
      <expected>PASS - test passes, 166 existing tests still pass</expected>
    </tdd_green>

    <tdd_refactor>
      <check>archiveEmail() implementation adequate?</check>
      <check>Should Core Data save be called explicitly?</check>
      <check>Should there be logging for debugging?</check>
      <decision>Keep minimal unless tests require more</decision>
    </tdd_refactor>

    <verification>
      swift test --filter GmailArchivingTests
      python3 -m pytest tests/ -v | grep "passed"
      # Expected: 167/167 (1 new + 166 existing)
    </verification>

    <code_review agent="code-reviewer" target="92"/>
    <commit msg="feat: Auto-archive Gmail emails on transaction import (Feature #1.1)"/>
  </task>

  <task id="1.2" atomic="true" time="30min" priority="P1" depends_on="1.1">
    <objective>Validate UI toggle works (likely already complete)</objective>

    <tdd_red>
      <file>FinanceMateTests/GmailUITests.swift</file>
      <test>
        func testArchivedToggleFiltersEmails() {
            // Given: 10 emails (5 needsReview, 5 archived)
            viewModel.emails = createMixedStatusEmails()

            // When: Toggle OFF (default)
            viewModel.showArchivedEmails = false
            // Then: Only needsReview visible
            XCTAssertEqual(viewModel.filteredEmails.count, 5)

            // When: Toggle ON
            viewModel.showArchivedEmails = true
            // Then: All visible
            XCTAssertEqual(viewModel.filteredEmails.count, 10)
        }
      </test>
      <expected>PASS immediately (feature already exists)</expected>
    </tdd_red>

    <implementation>
      <note>Feature already implemented in GmailViewModel.swift</note>
      <action>If test passes, just commit the test. No code changes needed.</action>
    </implementation>

    <commit msg="test: Validate archive toggle filtering logic (Feature #1.2)"/>
  </task>

  <task id="1.3" atomic="true" time="45min" priority="P1" depends_on="1.1,1.2">
    <objective>E2E validation of complete archive workflow</objective>

    <test>
      <file>tests/test_gmail_archiving_workflow.py</file>
      <workflow>
        1. Launch app programmatically
        2. Load cached Gmail emails from Core Data
        3. Trigger extraction on first email
        4. Import extracted transaction
        5. Query Core Data: Email status should be .archived
        6. Check GmailViewModel.filteredEmails (toggle OFF)
        7. Verify archived email NOT in filtered list
        8. Toggle showArchivedEmails = ON
        9. Verify archived email NOW in filtered list
        10. Screenshot before/after toggle
      </workflow>

      <success_criteria>
        - No user interaction required
        - Tests actual Core Data persistence
        - Validates UI filtering respects toggle
        - Captures visual proof (screenshots)
      </success_criteria>
    </test>

    <commit msg="test: E2E validation of archive workflow (Feature #1.3)"/>
  </task>

  <task id="1.4" atomic="true" time="20min" priority="P1" depends_on="1.3">
    <objective>Multi-agent code review</objective>

    <reviews parallel="true">
      <code_review agent="code-reviewer" target="92">
        Scope: All Feature #1 code changes
        Criteria: KISS, thread safety, edge cases
      </code_review>

      <ux_review agent="ui-ux-architect" target="90">
        Scope: Archive toggle UX
        Criteria: Intuitive, clear feedback, no confusion
      </ux_review>

      <gemini_review agent="gemini-general">
        Scope: Complete Feature #1 implementation
        Focus: Brutal assessment, find edge cases
      </gemini_review>
    </reviews>

    <documentation>
      <update file="docs/DEVELOPMENT_LOG.md">
        Entry: Feature #1 complete, test results, review scores
      </update>

      <update file="docs/TASKS.md">
        Mark: Feature #1 complete (awaiting user validation)
        Add: Next feature options for user approval
      </update>
    </documentation>

    <user_acceptance_request>
      "Feature #1 (Archive Processed Items) implemented:
      - Auto-archive on import: ✅
      - UI toggle: ✅ (validated)
      - E2E test: ✅ (168/168 passing)
      - Code review: [score]/100
      - UX review: [score]/100

      Please test:
      1. Import a Gmail transaction
      2. Verify it disappears from table
      3. Toggle 'Show Archived' ON
      4. Verify transaction reappears

      If working: Reply 'I APPROVE FEATURE #1'
      If broken: Provide screenshot"
    </user_acceptance_request>
  </task>

  <estimated_completion>90 minutes total</estimated_completion>
</feature>
```

---

## 🧹 REPOSITORY CLEANUP (PARALLEL EXECUTION)

### Objective: Minimal, Clean, Gold Standard Compliant Repository

**Deploy `refactorer` agent concurrently:**

```xml
<repository_cleanup priority="P1_CONCURRENT" agent="refactorer">
  <phase id="RC.1" name="SCAN" time="15min">
    <scan_commands>
      # Find redundant documentation
      find . -name "*.md" ! -path "./_macOS/*" | \
        grep -iE "(temp|summary|report|status|backup|old|_20[0-9]{6})"

      # Find test output clutter
      find test_output/ -type f -mtime +7

      # Find duplicate scripts
      find scripts/ \( -name "*.py" -o -name "*.sh" \) | \
        xargs -I {} basename {} | sort | uniq -d

      # Find orphaned Swift files (not in Xcode project)
      find _macOS -name "*.swift" ! -path "*DerivedData*" | \
        while read f; do
          grep -q "$(basename $f)" _macOS/FinanceMate.xcodeproj/project.pbxproj || echo "$f"
        done

      # Find backup files
      find . \( -name "*.backup" -o -name "*.bak" -o -name "*~" \)
    </scan_commands>

    <deliverable>
      <file>temp/cleanup_analysis.txt</file>
      <content>
        List of files to:
        - DELETE (redundant, backup, orphaned)
        - MIGRATE (merge into Gold Standard docs)
        - KEEP (verify necessity)
      </content>
    </deliverable>
  </phase>

  <phase id="RC.2" name="MIGRATE" time="15min" depends_on="RC.1">
    <migrate_content>
      <!-- Find all temp/summary/report .md files -->
      <source_pattern>*_SUMMARY.md, *_REPORT.md, temp/*.md</source_pattern>
      <target>docs/DEVELOPMENT_LOG.md</target>
      <method>
        1. Read each file
        2. Extract relevant content (skip redundant)
        3. Append to DEVELOPMENT_LOG under dated section
        4. Verify content migrated
        5. DELETE source file
      </method>
    </migrate_content>

    <consolidate_scripts>
      <action>Review scripts/ directory for duplicates</action>
      <method>
        1. Identify duplicate functionality
        2. Merge into single authoritative script
        3. Update documentation
        4. DELETE duplicates
      </method>
    </consolidate_scripts>
  </phase>

  <phase id="RC.3" name="EXECUTE_CLEANUP" time="10min" depends_on="RC.2">
    <delete_files>
      <!-- After migration complete -->
      <targets>
        - temp/ directory (move useful content first)
        - *_SUMMARY.md files (after merging)
        - *_REPORT.md files >7 days old
        - *.backup, *.bak files
        - test_output/ files >7 days
        - Orphaned .swift files
      </targets>

      <command>
        git rm [files]
        git commit -m "chore: Repository cleanup - remove redundant files and consolidate docs"
        git push origin main
      </command>
    </delete_files>

    <verification>
      <command>find . -name "*.md" ! -path "./_macOS/*" | wc -l</command>
      <expected>~8-10 files (Gold Standard only)</expected>

      <command>ls -la | grep -iE "(temp|backup|summary|report)"</command>
      <expected>No matches (all cleaned)</expected>
    </verification>
  </phase>

  <success_criteria>
    - ✅ Redundant .md files: DELETED or MERGED
    - ✅ Test output >7 days: ARCHIVED/DELETED
    - ✅ Duplicate scripts: CONSOLIDATED
    - ✅ Orphaned files: DELETED
    - ✅ Backup files: DELETED
    - ✅ Gold Standard docs: UPDATED with migrated content
    - ✅ Commit: Cleanup commit pushed to GitHub
  </success_criteria>

  <estimated_completion>40 minutes (parallel with Feature #1)</estimated_completion>
</repository_cleanup>
```

---

## 🎨 ASSET GENERATION USING GEMINI (PARALLEL EXECUTION)

### Objective: Professional App Assets for FinanceMate

**Deploy `gemini-general` agent concurrently:**

```xml
<asset_generation priority="P2_CONCURRENT" agent="gemini-general">
  <task id="AG.1" model="nano-banana" time="30min">
    <objective>Generate app icon and logo</objective>

    <specifications>
      <app_icon>
        <size>1024x1024 PNG (required by Apple)</size>
        <style>Modern, clean, financial theme</style>
        <colors>Match FinanceMate glassmorphism theme</colors>
        <motif>Australian financial symbols ($ AUD, chart, wallet)</motif>
        <background>Subtle gradient or glassmorphic effect</background>
      </app_icon>

      <logo_variants>
        <format>SVG (scalable) + PNG exports</format>
        <sizes>512x512, 256x256, 128x128, 64x64, 32x32</sizes>
        <modes>Light mode + Dark mode variants</modes>
        <usage>Menu bar, documentation, marketing</usage>
      </logo_variants>
    </specifications>

    <gemini_prompt>
      "Create a modern, professional app icon for FinanceMate - an Australian personal finance management application.

      Requirements:
      - 1024x1024px high resolution
      - Financial theme (charts, money, analytics)
      - Australian market appeal (consider AUD symbol)
      - Clean, minimalist design
      - Works at small sizes (64x64)
      - Glassmorphism aesthetic (subtle translucency)
      - Professional color palette

      Generate 3 variants and select the best design.

      Also create:
      - Logo SVG (horizontal and stacked layouts)
      - Light and dark mode variants
      - Export in required sizes (512, 256, 128, 64, 32px)"
    </gemini_prompt>

    <output_location>
      <app_icon>_macOS/FinanceMate/Assets.xcassets/AppIcon.appiconset/</app_icon>
      <logos>assets/branding/logos/</logos>
    </output_location>

    <integration>
      <xcode_assets>
        1. Copy generated icons to AppIcon.appiconset/
        2. Update Contents.json with correct filenames
        3. Verify Xcode recognizes new icon
        4. Build and check app icon appears
      </xcode_assets>
    </integration>

    <deliverable>
      - AppIcon.appiconset/ populated with all sizes
      - assets/branding/logos/ with SVG + PNG variants
      - Design rationale in assets/branding/DESIGN_NOTES.md
    </deliverable>
  </task>

  <task id="AG.2" model="veo-3+" time="45min">
    <objective>Generate promotional video and feature animations</objective>

    <promo_video>
      <duration>30 seconds</duration>
      <script>
        0:00-0:05: FinanceMate logo reveal
        0:05-0:10: Gmail receipt import demo
        0:10-0:15: Automatic extraction and categorization
        0:15-0:20: AI assistant answering financial questions
        0:20-0:25: Transaction management and reporting
        0:25-0:30: Call to action with logo
      </script>
      <style>Professional, clean, Australian market</style>
      <output>assets/marketing/financemate_promo_30s.mp4</output>
    </promo_video>

    <feature_animations>
      <animation name="gmail_extraction" duration="10s">
        Visual: Email icon → Extraction → Transaction card
        Purpose: Explain core feature in app documentation
        Output: assets/animations/gmail_extraction.mp4
      </animation>

      <animation name="archive_toggle" duration="8s">
        Visual: Transaction list → Import button → Item fades out → Toggle reveals it
        Purpose: Feature #1 demonstration
        Output: assets/animations/archive_toggle.mp4
      </animation>

      <animation name="ai_assistant_context" duration="12s">
        Visual: Navigate screens → AI placeholder updates → Ask question → Response
        Purpose: Feature #3 preview
        Output: assets/animations/ai_context_aware.mp4
      </animation>
    </feature_animations>

    <gemini_command>
      Using veo-3+ (Google's video generation model):
      
      gemini-cli video generate \
        --model veo-3+ \
        --prompt "[detailed video script]" \
        --duration 30 \
        --output assets/marketing/financemate_promo_30s.mp4

      Repeat for each feature animation with specific prompts.
    </gemini_command>

    <deliverable>
      - assets/marketing/financemate_promo_30s.mp4
      - assets/animations/gmail_extraction.mp4
      - assets/animations/archive_toggle.mp4
      - assets/animations/ai_context_aware.mp4
    </deliverable>
  </task>

  <task id="AG.3" model="nano-banana" time="30min">
    <objective>Generate UI icons and visual assets</objective>

    <icon_sets>
      <toolbar_icons>
        - dashboard.png (home icon)
        - transactions.png (list icon)
        - gmail.png (email icon)
        - settings.png (gear icon)
        Size: 32x32, 64x64 @2x
        Style: Match SF Symbols aesthetic
      </toolbar_icons>

      <category_icons>
        - groceries.png, transport.png, entertainment.png
        - shopping.png, utilities.png, health.png
        Size: 24x24, 48x48 @2x
        Style: Colorful, recognizable
      </category_icons>

      <status_badges>
        - confidence_high.png (green check)
        - confidence_medium.png (orange caution)
        - confidence_low.png (red warning)
        Size: 16x16, 32x32 @2x
      </status_badges>
    </icon_sets>

    <integration>
      <xcode>
        1. Add to FinanceMate.xcassets/Icons/
        2. Reference in SwiftUI: Image("dashboard")
        3. Verify icons display correctly
      </xcode>
    </integration>

    <deliverable>
      - assets/icons/ directory with all icon sets
      - Integration into FinanceMate.xcassets
      - Documentation of icon usage
    </deliverable>
  </task>

  <total_time>105 minutes (parallel execution)</total_time>
</asset_generation>
```

---

## 🔄 CONTINUOUS REFACTORING PROTOCOL

### Automated Code Quality Scanning

**Deploy `refactorer` agent in background:**

```xml
<continuous_refactoring mode="BACKGROUND_MONITORING">
  <scan id="REF.1" frequency="AFTER_EACH_COMMIT">
    <objective>Identify files exceeding size limits</objective>

    <command>
      find _macOS/FinanceMate -name "*.swift" -exec wc -l {} + | \
      awk '$1 > 250 {printf "%s: %d lines (%.0f%% over limit)\n", $2, $1, ($1-250)/250*100}' | \
      sort -t: -k2 -nr
    </command>

    <action>
      For each file >250 lines:
      1. Analyze responsibilities (should be 1-3 max)
      2. Identify natural split points
      3. Create atomic refactoring plan
      4. Ensure tests cover existing functionality
      5. Split file maintaining all tests passing
      6. Code review refactored structure
    </action>

    <example>
      If IntelligentExtractionService.swift is 380 lines:
      - Extract PDF methods → IntelligentExtractionService+PDF.swift
      - Extract cache methods → IntelligentExtractionService+Cache.swift
      - Keep core pipeline in main file
      - Result: 3 files averaging ~130 lines each
    </example>
  </scan>

  <scan id="REF.2" frequency="AFTER_EACH_COMMIT">
    <objective>Detect code duplication</objective>

    <patterns>
      <!-- Find similar function signatures -->
      <command>
        grep -roh "func [a-zA-Z_][a-zA-Z0-9_]*(" _macOS/FinanceMate --include="*.swift" | \
        sort | uniq -d
      </command>

      <!-- Find repeated string literals -->
      <command>
        grep -roh '"[^"]\{30,\}"' _macOS/FinanceMate --include="*.swift" | \
        sort | uniq -d
      </command>

      <!-- Find similar code blocks (manual review) -->
      <heuristic>
        - Similar if/else chains
        - Repeated switch statements
        - Copy-pasted validation logic
      </heuristic>
    </patterns>

    <action>
      1. Extract duplicate logic to shared utility
      2. Create reusable component/extension
      3. Update all call sites
      4. Verify tests pass
      5. Delete duplicate code
    </action>
  </scan>

  <scan id="REF.3" frequency="BEFORE_USER_APPROVAL">
    <objective>KISS compliance check</objective>

    <violations>
      <check>Functions >50 lines (break down)</check>
      <check>Nested if/else >3 levels (flatten)</check>
      <check>Force unwraps in production (use guard/if let)</check>
      <check>Magic numbers (extract to constants)</check>
      <check>Commented code (delete or document why)</check>
    </violations>

    <action>
      Address violations before requesting user approval
      Each fix: Test → Code → Verify → Commit
    </action>
  </scan>

  <deliverable>
    <file>temp/refactoring_scan_results.txt</file>
    <migrate_to>docs/TASKS.md (as P4 refactoring tasks)</migrate_to>
    <delete_after>File merged into TASKS.md</delete_after>
  </deliverable>
</continuous_refactoring>
```

---

## 🎯 PARALLEL AGENT COORDINATION

### Maximum Concurrency Strategy

```yaml
Execution_Timeline_90_Minutes:
  Minute_0:
    DEPLOY_ALL_AGENTS:
      - engineer-swift: Start Feature #1 Task 1.1 (TDD cycle)
      - refactorer: Start repository cleanup scan
      - gemini-general: Start app icon generation (nano-banana)

  Minute_30:
    engineer-swift: Task 1.1 complete, start Task 1.2
    refactorer: Scan complete, start migration
    gemini-general: Icon done, start promo video (veo-3+)
    DEPLOY_NEW: code-reviewer (review Task 1.1)

  Minute_60:
    engineer-swift: Task 1.2 complete, start Task 1.3 (E2E test)
    refactorer: Migration done, execute cleanup
    gemini-general: Promo video rendering, start feature animations
    code-reviewer: Review complete, provide feedback

  Minute_90:
    engineer-swift: All tasks complete, 168/168 tests passing
    refactorer: Cleanup commit pushed
    gemini-general: All assets generated and integrated
    DEPLOY_FINAL: ui-ux-architect (UX review) + gemini-general (brutal review)

Safe_Parallelism:
  ✅ Feature implementation + Repository cleanup
  ✅ Code review + Asset generation
  ✅ UX review + Gemini review (after implementation)
  ✅ Documentation updates + Test execution

Sequential_Dependencies:
  ❌ Must wait: Task 1.2 depends on 1.1 complete
  ❌ Must wait: E2E test depends on all tasks complete
  ❌ Must wait: Reviews depend on code written
  ❌ Must wait: User acceptance depends on reviews complete
```

---

## 📊 SUCCESS METRICS - PHASE 2 COMPLETE

### Feature #1 Delivery
```yaml
Code_Changes:
  - GmailViewModel.swift: +1 line (archiveEmail call)
  - FinanceMateTests/: +2 test files (unit + UI tests)
  - tests/: +1 E2E test file

Test_Results:
  - Passing: 168/168 (100%)
  - New tests: 3 (archiving unit + UI + E2E)
  - Build: GREEN
  - No regressions

Code_Quality:
  - Code review: >92/100
  - UX review: >90/100
  - Gemini review: Approved
  - KISS: Minimal change, maximum impact

Commits:
  - feat: Auto-archive on import
  - test: Archive toggle validation
  - test: E2E archive workflow
  - docs: Feature #1 completion

User_Validation:
  - Screenshot: Before/after archive toggle
  - Approval: "I APPROVE FEATURE #1"
```

### Repository Cleanup
```yaml
Files_Deleted:
  - Redundant .md files: ~10-15 files
  - Old test outputs: ~20-30 files
  - Backup files: ~5-10 files
  - Orphaned Swift files: ~2-5 files

Content_Migrated:
  - Merged into DEVELOPMENT_LOG.md
  - Updated TASKS.md with refactoring items
  - No data loss, just consolidation

Gold_Standard_Structure:
  - docs/: 6-8 files only (BLUEPRINT, CLAUDE, DEVELOPMENT_LOG, TASKS, ARCHITECTURE, README)
  - Root: Clean, minimal
  - Subdirs: Organized, purposeful

Commit:
  - chore: Repository cleanup
```

### Assets Generated
```yaml
App_Icon:
  - 1024x1024 master
  - All required iOS/macOS sizes
  - Integrated into AppIcon.appiconset/
  - Verified in Xcode

Logos:
  - SVG master files
  - PNG exports (512, 256, 128, 64, 32px)
  - Light + Dark mode variants
  - Organized in assets/branding/

Videos:
  - Promo video: 30s MP4
  - Feature animations: 3 videos
  - Stored in assets/marketing/ and assets/animations/

UI_Icons:
  - Toolbar icons: 4 sets
  - Category icons: 6+ sets
  - Status badges: 3 sets
  - Integrated into .xcassets

Commit:
  - feat: Add professional app assets and branding
```

---

## 🔁 ITERATION CONTINUATION LOGIC

### After Phase 2 Completes:

```python
def assess_next_phase():
    """
    Determine next action after Feature #1 + Cleanup + Assets complete
    """

    # Check exit conditions
    if tests_passing < 168:
        return "FIX_TEST_FAILURES"

    if build_status != "GREEN":
        return "FIX_BUILD"

    if feature_1_user_approved:
        # Present next feature options
        return present_feature_options([
            "Feature #2: Visual Indicators for Splits (60 min)",
            "Feature #3: Context-Aware AI Assistant (120 min)",
            "Feature #5: Expanded Settings (90 min)",
            "STOP: Polish and prepare for deployment"
        ])

    if quality_score < 95:
        return "QUALITY_IMPROVEMENTS"

    if blueprint_compliance < 95:
        return "BLUEPRINT_GAP_ANALYSIS"

    # MVP potentially complete
    return "REQUEST_DEPLOYMENT_APPROVAL"
```

### Iteration Checkpoints

**After EVERY task completion:**
```bash
# 1. Verify no regressions
xcodebuild build && echo "Build: OK" || echo "Build: BROKEN - STOP"
python3 -m pytest tests/ -q | tail -1  # Should show 168/168

# 2. Update documentation
echo "Update DEVELOPMENT_LOG.md with task completion"
echo "Update TASKS.md with status"

# 3. Commit atomically
git add [specific files]
git commit -m "[atomic change description]"
git push origin main

# 4. Deploy code review (parallel)
# Agent: code-reviewer reviews the commit

# 5. Assess next task
if [ tests_passing -eq 168 ] && [ user_approved_feature ]; then
    echo "PROCEED TO NEXT FEATURE"
elif [ refactoring_needed ]; then
    echo "ADDRESS REFACTORING"
else
    echo "REQUEST USER DIRECTION"
fi
```

---

## 🚦 QUALITY GATES - DO NOT PROCEED WITHOUT

### Before Requesting User Approval:
- ✅ Build: GREEN (BUILD SUCCEEDED)
- ✅ Tests: 168/168 passing (100%)
- ✅ Code review: >92/100
- ✅ UX review: >90/100 (if UI changes)
- ✅ Gemini review: Completed (brutal assessment)
- ✅ Documentation: DEVELOPMENT_LOG + TASKS updated
- ✅ Repository: Clean (no redundant files)
- ✅ Commits: All atomic, pushed to GitHub

### Before Moving to Next Feature:
- ✅ User approval: "I APPROVE FEATURE #[N]"
- ✅ Screenshot: Visual proof feature works
- ✅ No regressions: All tests still passing
- ✅ Quality maintained: >92/100 score

---

## 📚 EXECUTION RESOURCES

### Agent Deployment Commands

```bash
# Primary implementation
technical-project-lead → Coordinates all agents and tasks

# Concurrent specialists
engineer-swift → Feature implementation (TDD)
code-reviewer → Continuous quality monitoring
refactorer → Repository cleanup + code quality scan
ui-ux-architect → UX validation (post-implementation)
gemini-general → Asset generation (icons, videos)
debugger → Test failure analysis (if needed)

# Parallel execution where safe:
engineer-swift + refactorer + gemini-general (all can run concurrently)
code-reviewer + ui-ux-architect (after code written)
```

### Critical File Paths
```bash
PROJECT_ROOT="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate"

DOCS="$PROJECT_ROOT/docs"
MACOS="$PROJECT_ROOT/_macOS"
TESTS="$PROJECT_ROOT/tests"
ASSETS="$PROJECT_ROOT/assets"
SCRIPTS="$PROJECT_ROOT/scripts"

# Feature #1 files
GMAIL_VIEWMODEL="$MACOS/FinanceMate/GmailViewModel.swift"
ARCHIVING_TESTS="$MACOS/FinanceMateTests/GmailArchivingTests.swift"
E2E_ARCHIVE_TEST="$TESTS/test_gmail_archiving_workflow.py"
```

### Validation Commands
```bash
# Build
xcodebuild -project $MACOS/FinanceMate.xcodeproj -scheme FinanceMate build

# Tests
python3 -m pytest $TESTS/ -v --tb=short

# Repository cleanup
find $PROJECT_ROOT -name "*.md" ! -path "*/_macOS/*"
```

---

## 🎬 FINAL EXECUTION DIRECTIVE

### Technical-Project-Lead: BEGIN NOW

**Execute in this order:**

1. **Deploy 3 agents in PARALLEL** (Minute 0)
   - engineer-swift: Feature #1 implementation
   - refactorer: Repository cleanup
   - gemini-general: Asset generation

2. **Monitor and coordinate** (Continuous)
   - Track progress of each agent
   - Deploy code-reviewer when code ready
   - Deploy ui-ux-architect when UI ready
   - Ensure no conflicts

3. **Verify and validate** (Minute 90)
   - All tests passing (168/168)
   - All reviews approved (>90/100)
   - All assets generated and integrated
   - Repository clean and organized

4. **Request user acceptance** (Minute 90)
   - Present Feature #1 for testing
   - Show before/after cleanup
   - Display generated assets
   - Request: "I APPROVE FEATURE #1" or feedback

5. **Iterate** (If approved)
   - Present next feature options
   - Continue with approved feature
   - Repeat process

**DO NOT STOP** until user says STOP or MVP complete.

**QUALITY REQUIREMENT:** >95% before deployment

**DOCUMENTATION:** Update after EVERY task

**HONESTY:** No false claims, evidence-based assessments only

---

**BEGIN PARALLEL EXECUTION NOW.**

*Meta-Prompt v4.0.0 - Optimized for: Feature Delivery + Repository Excellence + Creative Assets*
